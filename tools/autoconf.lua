local olua = require "olua"
local clang = require "clang"
local TypeKind = require "clangwrapper.TypeKind"
local CursorKind = require "clangwrapper.CursorKind"
local CXXAccessSpecifier = require "clangwrapper.CXXAccessSpecifier"
local DiagnosticSeverity = require "clangwrapper.DiagnosticSeverity"

if not olua.isdir('autobuild') then
    olua.mkdir('autobuild')
end

print(' lua clang: v' .. clang.version)

-- auto export after config
if OLUA_AUTO_BUILD == nil then
    OLUA_AUTO_BUILD = true
end

-- print more debug info
if OLUA_VERBOSE == nil then
    OLUA_VERBOSE = false
end

-- auto generate property
if OLUA_AUTO_GEN_PROP == nil then
    OLUA_AUTO_GEN_PROP = true
end

-- enable auto export parent
if OLUA_AUTO_EXPORT_PARENT == nil then
    OLUA_AUTO_EXPORT_PARENT = false
end

-- enable export deprecated function
if OLUA_ENABLE_DEPRECATED == nil then
    OLUA_ENABLE_DEPRECATED = false
end

-- enable var or method name with underscore
if OLUA_ENABLE_WITH_UNDERSCORE == nil then
    OLUA_ENABLE_WITH_UNDERSCORE = false
end

-- max args for variadic method, this will generate overload method
if OLUA_MAX_VARIADIC_ARGS == nil then
    OLUA_MAX_VARIADIC_ARGS = 16
end

local format = olua.format
local clang_tu

local type_cursors = olua.newhash(true)
local exclude_types = olua.newhash(true)
local visited_types = olua.newhash(true)
local alias_types = olua.newhash(true)
local type_convs = olua.newhash(true)
local type_checker = olua.newarray()
local module_files = olua.newarray()
local deferred = {clang_args = {}, modules = olua.newhash()}
local metamethod = {
    __index = true, __newindex = true,
    __gc = true, __pairs = true, __len = true, __eq = true, __tostring = true,
    __add = true, __sub = true, __mul = true, __mod = true, __pow = true,
    __div = true, __idiv = true,
    __band = true, __bor = true, __bxor = true, __shl = true, __shr = true,
    __unm = true, __bnot = true, __lt = true, __le = true,
    __concat = true, __call = true, __close = true
}

local kFLAG_POINTER   = 1 << 1    -- pointer type
local kFLAG_ENUM      = 1 << 2    -- enum type
local kFLAG_ALIAS     = 1 << 3    -- alias type
local kFLAG_FUNC      = 1 << 4    -- function type
local kFLAG_TEMPLATE  = 1 << 5    -- template type
local kFLAG_SKIP      = 1 << 6    -- don't export

local KEEP_POINTER = 1 << 1
local KEEP_CONST = 1 << 2

local function has_flag(flag, k)
    return (flag & k) ~= 0
end

local function has_type_flag(cls, kind)
    return has_flag(cls.kind or 0, kind)
end

local function is_templdate_type(cppcls)
    return cppcls:find('<')
end

local function raw_typename(cppcls, flag)
    if cppcls == '' then
        return ''
    else
        flag = flag or 0
        if not has_flag(flag, KEEP_CONST) then
            cppcls = cppcls:gsub('^const ', '')
        end
        if has_flag(flag, KEEP_POINTER)  and cppcls:find('%*$') then
            cppcls = cppcls:gsub('<.*>', '')
        else
            cppcls = cppcls:match('[^<%[&*]+')
        end
        return olua.pretty_typename(cppcls)
    end
end

local function trim_prefix_colon(tn)
    if tn:find(' ::') then
        tn = tn:gsub(' ::', ' ')
    end
    if tn:find('^::') then
        tn = tn:gsub('^::', '')
    end
    return tn
end

local function parse_from_ast(type)
    local cur = type.declaration
    if cur.kind == CursorKind.NoDeclFound then
        return trim_prefix_colon(type.name)
    end

    local exps = olua.newarray('::')
    while cur and cur.kind ~= CursorKind.TranslationUnit do
        local value = raw_typename(cur.name)
        if cur.isInlineNamespace then
            cur = cur.parent
        elseif value then
            exps:insert(value)
            cur = cur.parent
        else
            break
        end
    end
    return trim_prefix_colon(tostring(exps))
end

local typename

local function parse_from_type(type, template_types, try_underlying, level, willcheck)
    local kind = type.kind
    local tn = trim_prefix_colon(type.name)
    local template_arg_types = type.templateArgumentTypes
    local underlying = type.declaration.underlyingType
    local pointee = type.pointeeType
    if level and level > 4 then
        return tn
    elseif type.isConstQualified then
        pointee = type.unqualifiedType
        return 'const ' .. parse_from_type(pointee, template_types, try_underlying, level, willcheck)
    elseif #template_arg_types > 0 and (not try_underlying or not underlying) then
        local exps = olua.newarray('')
        local astname = parse_from_ast(type)
        exps:push(astname)
        if is_templdate_type(tn) then
            level = (level or 0) + 1
            exps:push('<')
            for i, v in ipairs(template_arg_types) do
                exps:push(i > 1 and ', ' or nil)
                exps:push(typename(v, template_types, level, willcheck))
            end
            exps:push('>')
        end
        tn = tostring(exps)
        return template_types and template_types:get(tn) or tn
    elseif kind == TypeKind.LValueReference then
        return parse_from_type(pointee, template_types, try_underlying, level) .. ' &'
    elseif kind == TypeKind.RValueReference then
        return parse_from_type(pointee, template_types, try_underlying, level) .. ' &&'
    elseif kind == TypeKind.Pointer and pointee.kind == TypeKind.Pointer then
        return parse_from_type(pointee, template_types, try_underlying, level) .. '*'
    elseif kind == TypeKind.Pointer then
        return parse_from_type(pointee, template_types, try_underlying, level) .. ' *'
    elseif kind == TypeKind.FunctionProto then
        local exps = olua.newarray('')
        local result_type = typename(type.resultType, template_types, level, willcheck)
        exps:push(result_type)
        exps:push(result_type:find('[*&]') and '' or ' ')
        exps:push('(')
        for i, v in ipairs(type.argTypes) do
            exps:push(i > 1 and ', ' or nil)
            exps:push(typename(v, template_types, level, willcheck))
        end
        exps:push(')')
        return tostring(exps)
    elseif try_underlying and underlying then
        return parse_from_type(underlying, template_types, false, level)
    elseif template_types and template_types:has(tn) then
        return template_types:get(tn)
    elseif kind >= TypeKind.FirstBuiltin and kind <= TypeKind.LastBuiltin then
        return tn
    elseif kind == TypeKind.Typedef or kind == TypeKind.Unexposed then
        return tn
    else
        --[[
               tn: size_t
            rawrn: size_t
              ast: size_t

               tn: std::string::size_type
            rawrn: std::string::size_type
              ast: std::basic_string::size_type

               tn: enum EventType
            rawrn: EventType
              ast: olua::test::EventType
        ]]
        local rawtn = tn:match('[^ ]+$')
        local astname = parse_from_ast(type)
        if tn == astname or not olua.is_end_with(astname, rawtn) then
            return tn
        else
            return tn:gsub(rawtn, astname)
        end
    end
end

local function check_alias_typename(tn, underlying)
    local rawtn = raw_typename(tn)
    local rawptn = raw_typename(tn, KEEP_POINTER)
    local raw_underlying = raw_typename(underlying)
    local rawp_underlying = raw_typename(underlying, KEEP_POINTER)
    local has_ti = olua.typeinfo(rawp_underlying, nil, false)

    if rawptn == rawp_underlying then
        return tn, false
    elseif type_convs:has(rawp_underlying) then
        alias_types:replace(rawptn, rawp_underlying)
        return tn, true
    elseif type_convs:has(raw_underlying) then
        alias_types:replace(rawtn, raw_underlying)
        return tn, true
    elseif has_ti and not is_templdate_type(underlying) then
        if underlying:find('^const ') then
            --[[
                typedef char GLchar;
                void set(const GLchar *);
                        tn: const GLchar *
                underlying: const char *

                basictype.lua has register 'const char *' and 'char *'
            ]]
            local const_raw_underlying = raw_typename(underlying, KEEP_POINTER | KEEP_CONST)
            local ti = olua.typeinfo(const_raw_underlying, nil, false)
            if not olua.has_const_flag(ti) then
                local const_rawtn = raw_typename(tn, KEEP_POINTER | KEEP_CONST)
                alias_types:replace(const_rawtn, const_raw_underlying)
            end
        end
        alias_types:replace(rawptn, rawp_underlying)
        return tn, true
    elseif has_ti then
        return underlying, true
    else
        return tn, false
    end
end

local function get_pointee_type(type)
    local kind = type.kind
    if kind == TypeKind.LValueReference
        or kind == TypeKind.RValueReference
        or kind == TypeKind.Pointer
    then
        return get_pointee_type(type.pointeeType)
    else
        return type
    end
end

function typename(type, template_types, level, willcheck)
     --[[
            tn: const uint32_t *
         rawtn: uint32_t
        rawptn: uint32_t *
    ]]
    
    local tn = parse_from_type(type, template_types, false, level, willcheck)
    local rawtn = raw_typename(tn)
    local rawptn = raw_typename(tn, KEEP_POINTER)

    if exclude_types:has(rawtn) or exclude_types:has(rawptn) then
        return tn
    end

    if not type_convs:has(rawtn)
        and not type_convs:has(rawptn)
        and not olua.typeinfo(rawtn, nil, false)
    then
        --[[
            typedef std::function<void()> ClickEvent;
              -- type: ClickEvent
              -- underlying: std::function<void()>

            typedef long __darwin_time_t
            typedef __darwin_time_t time_t
              -- type: time_t
              -- underlying: __darwin_time_t
              -- canonical: long
        ]]

        -- try underlying_type
        local valid
        local alias = parse_from_type(type, template_types, true, level, willcheck)
        tn, valid = check_alias_typename(tn, alias)
        if not valid then
            alias = trim_prefix_colon(type.canonicalType.name)
            tn = check_alias_typename(tn, alias)
        end
    end

    if willcheck and type.kind ~= TypeKind.FunctionProto then
        type_checker:push({
            type = tn,
            from = willcheck,
            kind = get_pointee_type(type).declaration.kindSpelling
        })
    end

    return tn
end

local function is_excluded_typename(name)
    local rawptn = raw_typename(name, KEEP_POINTER):match('[^ ]+ *%**$')
    local rawtn = raw_typename(name):match('[^ ]+$')
    if exclude_types:has(rawtn) or exclude_types:has(rawptn) then
        return true
    end
    if name:find('%*%*$') then
        return true
    end
end

local function is_excluded_type(type)
    if type.kind == TypeKind.IncompleteArray then
        return true
    end

    local tn = typename(type)
    if is_templdate_type(tn) then
        for _, subtype in ipairs(get_pointee_type(type).templateArgumentTypes) do
            if is_excluded_type(subtype) then
                return true
            end
        end
    end
    return is_excluded_typename(tn)
end

local DEFAULT_ARG_TYPES = {
    [CursorKind.IntegerLiteral] = true,
    [CursorKind.FloatingLiteral] = true,
    [CursorKind.ImaginaryLiteral] = true,
    [CursorKind.StringLiteral] = true,
    [CursorKind.CharacterLiteral] = true,
    [CursorKind.CXXBoolLiteralExpr] = true,
    [CursorKind.CXXNullPtrLiteralExpr] = true,
    [CursorKind.GNUNullExpr] = true,
    [CursorKind.DeclRefExpr] = true,
    [CursorKind.CallExpr] = true,
}

local function has_default_value(cur)
    for _, c in ipairs(cur.children) do
        if DEFAULT_ARG_TYPES[c.kind] then
            return true
        elseif has_default_value(c) then
            return true
        end
    end
end

local function has_deprecated_attr(cur)
    if OLUA_ENABLE_DEPRECATED then
        return false
    end
    return cur.isDeprecated
end

local function has_exclude_attr(cur)
    for _, c in ipairs(cur.children) do
        if c.kind == CursorKind.AnnotateAttr and c.name:find('@exclude') then
            return true
        end
    end
end

local function is_func_type(tn)
    if type(tn) == 'string' then
        return tn:find('std::function')
    else
        local kind = tn.kind
        local cur = tn.declaration
        if kind == TypeKind.LValueReference
            or kind == TypeKind.RValueReference
            or kind == TypeKind.Pointer
        then
            return is_func_type(tn.pointeeType)
        elseif cur.kind == CursorKind.TypedefDecl
            or cur.kind == CursorKind.TypeAliasDecl
        then
            return is_func_type(cur.underlyingType)
        else
            return is_func_type(typename(cur.underlyingType or tn))
        end
    end
end

local function parse_attr_from_annotate(attr, cur, isvar)
    local function parse_and_merge_attr(node, key)
        local exps = nil
        for _, c in ipairs(node.children) do
            if c.kind == CursorKind.AnnotateAttr then
                local name = c.name
                if name:find('^@') then
                    exps = exps or olua.newarray(' ')
                    exps:push(name)
                end
            end
        end
        if exps then
            exps:push(attr[key])
            attr[key] = tostring(exps)
        end
    end

    parse_and_merge_attr(cur, 'ret')
    if not isvar then
        for i, arg in ipairs(cur.arguments) do
            parse_and_merge_attr(arg, 'arg' .. i)
        end
    end
end

local function get_attr_copy(cls, fn, wildcard)
    local attrs = (cls.maincls or cls).attrs
    local attr = attrs:get(fn) or attrs:get(wildcard or '*')
    return setmetatable({}, {__index = attr or {}})
end

local function is_excluded_memeber(cls, cur)
    local mode = #cls.includes > 0 and 'include' or 'exclude'
    local name = cur.name

    if not OLUA_ENABLE_WITH_UNDERSCORE
        and name:find('^_')
        and not metamethod[name]
    then
        return true
    end

    if (mode == 'include' and not cls.includes:has(name))
        or cls.excludes:has('*')
        or cls.excludes:has(name)
        or cls.excludes:has(cur.displayName)
    then
        return true
    end

    for wc in pairs(cls.wildcards) do
        if name:find(wc) then
            return true
        end
    end
end

local M = {}

function M:parse()
    assert(not self.class_file)
    self.class_file = format('autobuild/${self.filename}.idl')

    module_files:push(self)

    -- scan method, variable, enum, const value
    for _, cls in ipairs(self.class_types:clone()) do
        local cur = type_cursors:get(cls.cppcls)
        if cur then
            self:visit(cur, cls.cppcls)
        end
    end
end

function M:visit_method(cls, cur)
    if has_deprecated_attr(cur)
        or cur.isCXXMoveConstructor
        or cur.name:find('operator *[%-=+/*><!()]?')
        or cur.name == 'as'  -- 'as used to cast object'
        or has_exclude_attr(cur)
    then
        return
    end

    local fn = cur.name
    local display_name = cur.displayName
    local luaname = fn
    local arguments = cur.arguments
    local result_type = cur.resultType
    local typefrom = format('${cls.cppcls} -> ${cur.prettyPrinted}')
    local attr = get_attr_copy(cls, fn)
    local callback = cls.callbacks:get(fn) or {}
    local static = cur.isCXXMethoStatic
    local declexps = olua.newarray('')
    local protoexps = olua.newarray('')

    parse_attr_from_annotate(attr, cur)

    for i, c in ipairs({{type = result_type}, table.unpack(arguments)}) do
        local mark = (attr['arg' .. (i - 1)]) or ''
        if is_excluded_type(c.type) then
            if cls.includes:has(fn) then
                print(format([=[
                    [WARNING]: function '${fn}' included in class '${cls.cppcls}' will be ignored
                                   because '${c.type.name}' has been excluded
                ]=], 1))
            end
            return
        end
    end

    if cur.isVariadic then
        declexps:push('@variadic ')
    end

    declexps:push(attr.ret and (attr.ret .. ' ') or nil)
    declexps:push(static and 'static ' or nil)

    local cb_kind

    if cur.kind ~= CursorKind.Constructor then
        local tn = typename(result_type, cls.template_types, nil, typefrom)
        if is_func_type(result_type) then
            cb_kind = 'ret'
            if callback.localvar ~= false then
                declexps:push('@localvar ')
            end
        end
        declexps:push(olua.decltype(tn, nil, true))
        protoexps:push(declexps[#declexps])
        luaname = cls.luaname(fn, 'func')
    end

    local name_from_attr = string.match(attr.ret or '', '@name%(([^)]+)%)')
    if name_from_attr then
        luaname = name_from_attr
    end

    local optional = false
    local min_args = 0
    local num_args = #arguments
    declexps:push(fn .. '(')
    protoexps:push(fn .. '(')
    for i, arg in ipairs(arguments) do
        local tn = typename(arg.type, cls.template_types, nil, typefrom)
        local argn = 'arg' .. i
        declexps:push(i > 1 and ', ' or nil)
        protoexps:push(i > 1 and ', ' or nil)
        protoexps:push(tn)
        if is_func_type(arg.type) then
            if cb_kind then
                olua.error([[
                    has more than one std::function:
                        class: ${cls.cppcls}
                         func: ${display_name}
                ]])
            end
            cb_kind = 'arg'
            if callback.localvar ~= false then
                declexps:push('@localvar ')
            end
        end
        if has_default_value(arg) then
            declexps:push('@optional ')
            optional = true
        else
            min_args = min_args + 1
            assert(not optional, cls.cppcls .. '::' .. display_name)
        end
        declexps:push(attr[argn] and (attr[argn] .. ' ') or nil)
        declexps:push(olua.decltype(tn, nil, true))
        declexps:push(arg.name)

        if cur.isVariadic and i == num_args then
            for vi = 1, OLUA_MAX_VARIADIC_ARGS do
                protoexps:push(', ')
                protoexps:push(tn)
                declexps:push(', ')
                declexps:push('@optional ')
                declexps:push(attr[argn] and (attr[argn] .. ' ') or nil)
                declexps:push(olua.decltype(tn, nil, true))
                declexps:pushf("${arg.name}_$${vi}")
            end
        end
    end

    declexps:push(')')
    protoexps:push(')')

    local decl = tostring(declexps)
    local prototype =  tostring(protoexps)
    cls.excludes:replace(display_name, true)
    cls.excludes:replace(prototype, true)
    if cur.kind == CursorKind.FunctionDecl then
        decl = 'static ' .. decl
        static = true
    end
    if decl:find('@getter') or decl:find('@setter') then
        local what = decl:find('@getter') and 'get' or 'set'
        olua.assert((what == 'get' and num_args == 0) or num_args == 1, [[
            ${what}ter function has wrong argument:
                prototype: ${decl}
        ]])
        local prop = cls.props:get(luaname)
        if not prop then
            prop = {name = luaname}
            cls.props:push(luaname, prop)
        end
        prop[what] = decl
    else
        cls.funcs:push(prototype, {
            decl = decl,
            luaname = luaname == fn and 'nil' or format([['${luaname}']]),
            name = fn,
            static = static,
            num_args = num_args,
            min_args = min_args,
            cb_kind = cb_kind,
            prototype = prototype,
            display_name = display_name,
            isctor = cur.kind == CursorKind.Constructor,
        })
    end
end

function M:visit_var(cls, cur)
    if is_excluded_type(cur.type)
        or has_exclude_attr(cur)
        or has_deprecated_attr(cur)
        or cur.type.name:find('%[')
    then
        return
    end

    local exps = olua.newarray('')
    local typefrom = format('${cls.cppcls} -> ${cur.prettyPrinted}')
    local attr = get_attr_copy(cls, cur.name, 'var*')
    local tn = typename(cur.type, cls.template_types, nil, typefrom)
    local cb_kind

    parse_attr_from_annotate(attr, cur, true)

    if attr.readonly or cur.type.isConstQualified then
        exps:push('@readonly ')
    end

    if attr.optional or (has_default_value(cur) and attr.optional == nil) then
        exps:push('@optional ')
    end

    if is_func_type(cur.type) then
        cb_kind = 'var'
        exps:push('@nullable ')
        local callback = cls.callbacks:take(cur.name) or {}
        if callback.localvar ~= false then
            exps:push('@localvar ')
        end
    end

    exps:push(attr.ret and (attr.ret .. ' ') or nil)
    exps:push(cur.kind == CursorKind.VarDecl and 'static ' or nil)
    exps:push(olua.decltype(tn, nil, true))
    exps:push(cur.name)

    local decl = tostring(exps)
    local name = cls.luaname(cur.name, 'var')
    cls.vars:push(name, {
        name = name,
        snippet = decl,
        cb_kind = cb_kind
    })
end

function M:will_visit(cppcls)
    local cls = self.class_types:get(cppcls)
    if visited_types:has(cppcls) then
        olua.error([[
            ${cppcls} already visited
            you should do one of:
                * if you set OLUA_AUTO_EXPORT_PARENT = true, remove "typeconf '${cppcls}'"
                    or move "typeconf '${cppcls}'" before subclass
                * check whether "typeconf '${cppcls}'" in multi config file
        ]])
    end
    visited_types:replace(cppcls, cls)
    return cls
end

function M:visit_enum(cppcls, cur)
    local cls = self:will_visit(cppcls)
    for _, c in ipairs(cur.children) do
        local value =  c.name
        local name = cls.luaname(value, 'enum')
        cls.enums:push(name, {
            name = name,
            value = format('${cls.cppcls}::${value}'),
        })
    end
    cls.options.indexerror = 'rw'
    cls.kind = cls.kind or kFLAG_ENUM
end

function M:visit_alias_class(alias, cppcls)
    local cls = self:will_visit(alias)
    cls.kind = cls.kind or kFLAG_POINTER
    if is_func_type(cppcls) then
        cls.kind = cls.kind | kFLAG_FUNC
        cls.underlying = cppcls
        cls.luacls = self.luacls(alias)
    else
        cls.kind = cls.kind | kFLAG_ALIAS
        cls.supercls = cppcls
        cls.luacls = self.luacls(cppcls)
    end
end

function M:visit_class(cppcls, cur, template_types, specializedcls)
    local cls = self:will_visit(cppcls)
    local skipsuper = false

    cls.kind = cls.kind or kFLAG_POINTER

    if cur.kind == CursorKind.ClassTemplate then
        type_convs:push_if_not_exist(raw_typename(cppcls), true)
        olua.assert(template_types, [[
            don't config template class:
                you should remove: typeconf '${cls.cppcls}'
        ]])
        cls.kind = cls.kind | kFLAG_TEMPLATE
        if specializedcls then
            cls.template_types:push(specializedcls, cppcls)
        end
    elseif cur.kind == CursorKind.Namespace then
        cls.options.reg_luatype = false
    end
    
    for _, c in ipairs(cur.children) do
        local kind = c.kind
        local access = c.cxxAccessSpecifier
        if access == CXXAccessSpecifier.Private
            or access == CXXAccessSpecifier.Protected
        then
            if kind == CursorKind.FunctionDecl or kind == CursorKind.CXXMethod then
                cls.excludes:replace(c.displayName, true)
            end
            if kind == CursorKind.Destructor then
                cls.options.disable_gc = true
            end
            goto continue
        elseif kind == CursorKind.TemplateTypeParameter then
            local tn = table.remove(template_types, 1)
            if not tn then
                olua.error([[
                    template type not found:
                          cppcls: ${cls.cppcls}
                        typename: ${c.name}
                ]])
            end
            cls.template_types:push(c.name, tn)
        elseif kind == CursorKind.CXXBaseSpecifier then
            local supercls = parse_from_type(c.type)
            local rawsupercls = raw_typename(supercls)
            local supercursor = type_cursors:get(rawsupercls)

            if is_excluded_typename(rawsupercls) then
                skipsuper = true
                goto continue
            end

            if is_templdate_type(supercls) then
                skipsuper = true
                local arg_types = {}
                for i, v in ipairs(c.type.templateArgumentTypes) do
                    arg_types[i] = parse_from_type(v)
                end
                self.CMD.typeconf(supercls)
                self:visit_class(supercls, supercursor, arg_types)
            elseif OLUA_AUTO_EXPORT_PARENT then
                local super = visited_types:get(rawsupercls)
                if not super then
                    assert(supercursor, "no cursor for " .. rawsupercls)
                    if not self.class_types:has(rawsupercls) then
                        self.CMD.typeconf(rawsupercls)
                    end
                    self:visit_class(rawsupercls, supercursor)
                    super = self.class_types:take(rawsupercls)
                    if super.supercls then
                        local pos = visited_types:get(super.supercls)
                        self.class_types:insert('after', pos, rawsupercls, super, 1)
                    else
                        self.class_types:insert('front', nil, rawsupercls, super)
                    end
                end
            end

            if not cls.supercls and not skipsuper then
                skipsuper = true
                cls.supercls = supercls
            end
            cls.supers:push(supercls, supercls)
        elseif kind == CursorKind.UsingDeclaration then
            for _, cc in ipairs(c.children) do
                if cc.kind == CursorKind.TypeRef then
                    cls.usings:push(c.name, cc.name:match('([^ ]+)$'))
                    break
                end
            end
        elseif kind == CursorKind.FieldDecl or kind == CursorKind.VarDecl then
            local varname = c.name
            local vartype = c.type
            if is_excluded_memeber(cls, c) then
                goto continue
            end
            if vartype.isConstQualified and kind == CursorKind.VarDecl then
                if not is_excluded_type(vartype) then
                    cls.consts:push(varname, {name = varname, typename = vartype.name})
                end
            else
                self:visit_var(cls, c)
            end
        elseif kind == CursorKind.Constructor
            or kind == CursorKind.FunctionDecl
            or kind == CursorKind.CXXMethod
        then
            local isConstructor = kind == CursorKind.Constructor
            if is_excluded_memeber(cls, c)
                or (isConstructor and (cls.excludes:has('new')))
                or (isConstructor and cur.kind == CursorKind.ClassTemplate)
                or (isConstructor and cur.isCXXMethoAbstract)
            then
                goto continue
            end
            self:visit_method(cls, c)
        end

        ::continue::
    end
end

function M:visit(cur, cppcls)
    local kind = cur.kind
    local children = cur.children
    local astcls = parse_from_ast({declaration = cur, name = cur.name})
    cppcls = cppcls or astcls
    if kind == CursorKind.Namespace then
        self:visit_class(cppcls, cur)
    elseif kind == CursorKind.ClassTemplate
        or kind == CursorKind.ClassDecl
        or kind == CursorKind.StructDecl
        or kind == CursorKind.UnionDecl
    then
        if astcls ~= cppcls and type_convs:has(astcls) then
            self:visit_alias_class(cppcls, astcls)
        else
            self:visit_class(cppcls, cur)
        end
    elseif kind == CursorKind.EnumDecl then
        self:visit_enum(cppcls, cur)
    elseif kind == CursorKind.TypeAliasDecl then
        self:visit(cur.underlyingType.declaration, cppcls)
    elseif kind == CursorKind.TypedefDecl then
        local underlying = typename(cur.underlyingType)
        if is_func_type(underlying) then
            self:visit_alias_class(cppcls, underlying)
        else
            local decl = cur.underlyingType.declaration
            local specialized = decl.specializedTemplate
            if specialized then
                --[[
                    typedef olua::span<int> olua_int;

                    specialized: olua::span<int>
                         cppcls: olua_int
                      packedcls: int
                ]]
                local arg_types = {}
                for i, v in ipairs(cur.type.templateArgumentTypes) do
                    arg_types[i] = parse_from_type(v)
                end
                local specializedcls = parse_from_type(cur.underlyingType)
                self:visit_class(cppcls, specialized, arg_types, specializedcls)
                
                if specializedcls:find('^olua::span')
                    or specializedcls:find('^olua::pointer')
                then
                    local typedef = self.CMD.typedef
                    local packedcls = specializedcls:match('<(.*)>') .. ' *'
                    type_convs:push_if_not_exist(packedcls, true)
                    typedef(packedcls)
                        .luacls(self.luacls(cppcls))
                        .conv(specializedcls:match('^olua::[^<]+'):gsub('::', '_$$_'))
                end
            else
                self:visit(decl, cppcls)
            end
        end
    end
end

local function try_add_wildcard_type(cppcls, cur)
    if cur.name:find('[.(/]') then
        -- (unnamed enum at src/protobuf.pb.h:1015:3)
        return
    end
    for _, m in ipairs(deferred.modules) do
        if m.class_types:has(cppcls) then
            goto continue
        end
        for type, conf in pairs(m.wildcard_types) do
            if cppcls:find(type) then
                if exclude_types:has(cppcls) then
                    print(format([=[
                        [WARNING]: '${cppcls}' matched by '${type}' will be ignored
                                       because '${cppcls}' has been excluded
                    ]=], 1))
                else
                    m.CMD._typecopy(cppcls, conf)
                end
            end
        end
        ::continue::
    end
end

local function add_type_cursor(cppcls, cursor)
    local last = type_cursors:get(cppcls)
    if not last or #last.children < #cursor.children then
        type_cursors:replace(cppcls, cursor)
    end
end

local function prepare_cursor(cur)
    local kind = cur.kind
    local cppcls = parse_from_ast({declaration = cur, name = cur.name})
    if kind == CursorKind.ClassDecl
        or kind == CursorKind.EnumDecl
        or kind == CursorKind.ClassTemplate
        or kind == CursorKind.StructDecl
        or kind == CursorKind.UnionDecl
        or kind == CursorKind.Namespace
        or kind == CursorKind.TranslationUnit
    then
        local children = cur.children
        if #children > 0 then
            add_type_cursor(cppcls, cur)
            type_cursors:push_if_not_exist(cppcls, cur)
            try_add_wildcard_type(cppcls, cur)
            for _, v in ipairs(children) do
                prepare_cursor(v)
            end
        end
    elseif kind == CursorKind.TypeAliasDecl
        or kind == CursorKind.TypedefDecl
    then
        local children = cur.children
        if #children > 0 then
            type_cursors:push_if_not_exist(cppcls, cur)
            type_cursors:push_if_not_exist(typename(cur.type), cur)
            try_add_wildcard_type(cppcls, cur)
        end
    end
    if kind == CursorKind.TranslationUnit then
        alias_types:clear()
    end
end

-------------------------------------------------------------------------------
-- output config
-------------------------------------------------------------------------------
local function write_module_metadata(module, append)
    append(format([[
        name = "${module.name}"
        path = "${module.path}"
    ]]))

    append(format('headers = ${module.headers?}'))
    append(format('chunk = ${module.chunk??}'))
    append(format('luaopen = ${module.luaopen??}'))
    append('')
end

local function is_new_func(module, supercls, func)
    if not supercls or func.static then
        return true
    end

    local super = visited_types:get(supercls)
    if not super then
        olua.error("not found super class '${supercls}'")
    elseif super.funcs:has(func.prototype) or super.excludes:has(func.name) then
        return false
    else
        return is_new_func(module, super.supercls, func)
    end
end

local function parse_prop_name(func)
    if (func.name:find('^[gG]et') or func.name:find('^[iI]s'))
        and (func.num_args == 0 or (func.extended and func.num_args == 1))
    then
        -- getABCd isAbc => ABCd Abc
        local name
        if func.name:find('^[gG]et') then
            name = func.name:gsub('^[gG]et_*', '')
        else
            name = func.name:gsub('^[iI]s_*', '')
        end
        return string.gsub(name, '^%u+', function (str)
            if #str > 1 and #str ~= #name then
                if #str == #name - 1 then
                    -- ABCDs => abcds
                    return str:lower()
                else
                    -- ABCd => abCd
                    return str:sub(1, #str - 1):lower() .. str:sub(#str)
                end
            else
                -- AbcdEF => abcdEF
                return str:lower()
            end
        end)
    end
end

local function search_using_func(module, cls)
    local function search_parent(arr, name, supercls)
        local super = visited_types:get(supercls)
        if super then
            for _, func in ipairs(super.funcs) do
                if func.name == name then
                    arr[#arr + 1] = func
                end
            end
            if #arr == 0 and super.supercls then
                search_parent(arr, name, super.supercls)
            end
        end
    end
    for name, where in pairs(cls.usings) do
        local arr = {}
        local supercls = cls.supercls
        while supercls and supercls ~= where do
            local super = visited_types:get(supercls)
            if super then
                supercls = super.supercls
            end
        end
        if supercls then
            search_parent(arr, name, supercls)
            for _, func in ipairs(arr) do
                cls.funcs:push_if_not_exist(func.prototype, func)
            end
        elseif not cls.supers:has(where) then
            olua.error([[unexpect copy using error: using ${where}:${name}]])
        end
    end
end

local function write_cls_func(module, cls, append)
    search_using_func(module, cls)

    local group = olua.newhash()
    for _, func in ipairs(cls.funcs) do
        local arr = group:get(func.name)
        if not arr then
            arr = {}
            group:push(func.name, arr)
        end
        if func.snippet or func.name == 'as'
            or is_new_func(module, cls.supercls, func)
        then
            arr.has_new = true
        else
            func = setmetatable({
                decl = '@using ' .. func.decl
            }, {__index = func})
        end
        arr[#arr + 1] = func
    end

    for _, arr in ipairs(group) do
        if not arr.has_new then
            goto continue
        end
        local funcs = olua.newarray("', '", "'", "'")
        local has_callback = false
        local fi = arr[1]
        for _, v in ipairs(arr) do
            if v.cb_kind or cls.callbacks:has(v.name) then
                has_callback = true
            end
            funcs[#funcs + 1] = v.decl
        end

        if #arr == 1 and OLUA_AUTO_GEN_PROP then
            local name = parse_prop_name(fi)
            if name then
                local setfunc
                local getfunc = fi
                local setname = '^set_*' .. name:lower() .. '$'
                local lessone, moreone
                for _, f in ipairs(cls.funcs) do
                    if f.name:lower():find(setname) then
                        setfunc = f
                        --[[
                            void setName(n)
                            void setName(n, i)
                        ]]
                        if f.min_args <= (f.extended and 2 or 1) then
                            lessone = true
                        end
                        if f.min_args > (f.extended and 2 or 1) then
                            moreone = true
                        end
                    end
                end
                if lessone or not moreone then
                    cls.props:push_if_not_exist(name, {
                        name = name,
                        get = getfunc.decl,
                        set = setfunc and setfunc.decl or nil
                    })
                end
            end
        end
        if not has_callback then
            if #funcs > 0 then
                append(format(".func(${fi.luaname}, ${funcs})", 4))
            else
                append(format(".func('${fi.name}', ${fi.snippet?})", 4))
            end
        else
            local tag_maker = fi.name:gsub('^set', ''):gsub('^get', '')
            local mode = fi.cb_kind == 'ret' and 'equal' or 'replace'
            local callback = cls.callbacks:get(fi.name)
            if callback then
                callback.funcs = funcs
                callback.tag_maker = callback.tag_maker or format('${tag_maker}')
                callback.tag_mode = callback.tag_mode or mode
            else
                cls.callbacks:push(fi.name, {
                    name = fi.name,
                    funcs = funcs,
                    tag_maker = olua.format '${tag_maker}',
                    tag_mode = mode,
                })
            end
        end

        ::continue::
    end
end

local function write_cls_options(module, cls, append)
    for _, v in ipairs(olua.toarray(cls.options)) do
        append(format([[.option('${v.key}', ${v.value?})]], 4))
    end
end

local function write_cls_macro(module, cls, append)
    for _, v in ipairs(cls.macros) do
        append(format([[.macro('${v.name}', '${v.value}')]], 4))
    end
end

local function write_cls_const(module, cls, append)
    for _, v in ipairs(cls.consts) do
        append(format([[.const('${v.name}', '${cls.cppcls}::${v.name}', '${v.typename}')]], 4))
    end
end

local function write_cls_enum(module, cls, append)
    for _, e in ipairs(cls.enums) do
        append(format(".enum('${e.name}', '${e.value}')", 4))
    end
end

local function write_cls_var(module, cls, append)
    for _, var in ipairs(cls.vars) do
        append(format(".var('${var.name}', ${var.snippet?})", 4))
    end
end

local function write_cls_prop(module, cls, append)
    for _, p in ipairs(cls.props) do
        append(format([[.prop('${p.name}', ${p.get?}, ${p.set?})]], 4))
    end
end

local function write_cls_callback(module, cls, append)
    for i, v in ipairs(cls.callbacks) do
        assert(v.funcs, cls.cppcls .. '::' .. v.name)
        local funcs = olua.newarray("',\n'", "'", "'"):merge(v.funcs)
        local tag_maker = olua.newarray("', '", "'", "'")
        local tag_mode = olua.newarray("', '", "'", "'")
        local tag_store = v.tag_store or '0'
        local tag_scope = v.tag_scope or 'object'
        if type(v.tag_store) == 'string' then
            tag_store = format([["${v.tag_store}"]])
        end
        assert(v.tag_maker, 'no tag maker')
        assert(v.tag_mode, 'no tag mode')
        if type(v.tag_maker) == 'string' then
            tag_maker:push(v.tag_maker)
        else
            tag_maker:merge(v.tag_maker)
            tag_maker = format('{${tag_maker}}')
        end
        if type(v.tag_mode) == 'string' then
            tag_mode:push(v.tag_mode)
        else
            tag_mode:merge(v.tag_mode)
            tag_mode = format('{${tag_mode}}')
        end
        append(format([[
            .callback {
                funcs =  {
                    ${funcs}
                },
                tag_maker = ${tag_maker},
                tag_mode = ${tag_mode},
                tag_store = ${tag_store},
                tag_scope = '${tag_scope}',
            }
        ]], 4))
    end
end

local function write_cls_insert(module, cls, append)
    for _, v in ipairs(cls.inserts) do
        if v.before or v.after or v.cbefore or v.cafter then
            append(format([[
                .insert('${v.name}', {
                    before = ${v.before??},
                    after = ${v.after??},
                    cbefore = ${v.cbefore??},
                    cafter = ${v.cafter??},
                })
            ]], 4))
        end
    end
end

local function write_cls_alias(module, cls, append)
    for _, v in ipairs(cls.aliases) do
        if not v.alias then
            olua.error([[
                alias not found for '${v.name}'
                    from: ${cls.cppcls}
            ]])
        end
        append(format(".alias('${v.name}', '${v.alias}')", 4))
    end
end

local function write_module_classes(module, append)
    append('')
    for _, cls in ipairs(module.class_types) do
        for v in pairs(cls.extends) do
            local extcls = module.class_types:get(v)
            for _, func in ipairs(extcls.funcs) do
                if not func.static then
                    olua.error([[
                        extend only support static function:
                            class: ${extcls.cppcls}
                             func: ${func.prototype}
                    ]])
                end
                func.extended = true
                func.decl = format("@extend(${extcls.cppcls}) ${func.decl}")
                cls.funcs:replace(func.prototype, func)
            end
        end
    end
    for _, cls in ipairs(module.class_types) do
        if has_type_flag(cls, kFLAG_ALIAS)
            or has_type_flag(cls, kFLAG_SKIP)
            or cls.maincls
        then
            goto continue
        end

        append(format([[
            typeconf '${cls.cppcls}'
                .supercls(${cls.supercls??})
                .chunk(${cls.chunk??})
                .luaopen(${cls.luaopen??})
        ]]))
        write_cls_options(module, cls, append)
        write_cls_macro(module, cls, append)
        write_cls_const(module, cls, append)
        write_cls_func(module, cls, append)
        write_cls_enum(module, cls, append)
        write_cls_var(module, cls, append)
        write_cls_callback(module, cls, append)
        write_cls_prop(module, cls, append)
        write_cls_insert(module, cls, append)
        write_cls_alias(module, cls, append)

        append('')

        ::continue::
    end
end

local function write_module(module)
    local t = olua.newarray('\n')

    local function append(str)
        t:push(str)
    end

    append([[-- AUTO BUILD, DON'T MODIFY!]])
    append('')

    write_module_metadata(module, append)
    write_module_classes(module, append)

    olua.write(module.class_file, tostring(t))
end

local function parse_headers()
    local headers = olua.newarray('\n')
    for _, m in ipairs(deferred.modules) do
        headers:push(m.headers)
    end

    local HEADER_PATH = 'autobuild/.autoconf.h'
    local header = io.open(HEADER_PATH, 'w')
    header:write(format [[
        #ifndef __AUTOCONF_H__
        #define __AUTOCONF_H__

        ${headers}

        #endif
    ]])
    header:close()
    local has_target = false
    local has_stdv = false
    local flags = olua.newarray()
    flags:push('-DOLUA_AUTOCONF')
    for i, v in ipairs(deferred.clang_args) do
        flags[#flags + 1] = v
        if v:find('^-target') then
            has_target = true
        end
        if v:find('^-std') then
            has_stdv = true
        end
    end
    if not has_stdv then
        flags:push('-std=c++11')
    end
    if not has_target then
        flags:merge({
            '-x', 'c++', '-nostdinc',
            '-U__SSE__',
            '-DANDROID',
            '-target', 'armv7-none-linux-androideabi',
            '-idirafter', '${OLUA_HOME}/include/c++',
            '-idirafter', '${OLUA_HOME}/include/c',
            '-idirafter', '${OLUA_HOME}/include/android-sysroot/x86_64-linux-android',
            '-idirafter', '${OLUA_HOME}/include/android-sysroot',
        })
    end
    for i, v in ipairs(flags) do
        local OLUA_HOME = olua.OLUA_HOME
        flags[i] = format(v)
    end
    print('     clang: start parse translation unit')
    clang_tu = clang.createIndex(false, true):parse(HEADER_PATH, flags)
    for _, v in ipairs(clang_tu.diagnostics) do
        if v.severity == DiagnosticSeverity.Error
            or v.severity == DiagnosticSeverity.Fatal
        then
            error('parse header error')
        end
    end
    print('     clang: start prepare cursor')
    prepare_cursor(clang_tu.cursor)
    print('     clang: complete prepare cursor')
    os.remove(HEADER_PATH)
end

local function init_conv_func(cls)
    local function convertor(cppcls)
        return 'olua_$$_' .. cppcls:gsub('::', '_'):gsub('[ *]', '')
    end
    if not cls.includes then
        -- typedef type
        if not cls.conv then
            cls.conv = convertor(cls.cppcls)
        end
    end
    type_convs:push_if_not_exist(cls.cppcls, true)
end

local function parse_types()
    for _, m in ipairs(deferred.modules) do
        for _, cls in ipairs(m.typedef_types) do
            init_conv_func(cls)
        end
        for _, cls in ipairs(m.class_types) do
            init_conv_func(cls)
        end
    end

    for _, m in ipairs(deferred.modules) do
        for _, cls in ipairs(m.class_types) do
            for fn, func in pairs(cls.funcs) do
                if not func.snippet then
                    cls.funcs:take(fn)
                    cls.excludes:take(fn)
                end
            end
            for vn, vi in pairs(cls.vars) do
                if not vi.snippet then
                    cls.vars:take(vn)
                    cls.excludes:take(vn)
                end
            end
        end
        setmetatable(m, {__index = M})
        m:parse()
    end
end

local function check_errors()
    local class_not_found = olua.newarray()
    local supercls_not_found = olua.newarray()
    local type_not_found = olua.newarray()
    local conv_not_found = olua.newarray()

    -- check class and super class
    for _, m in ipairs(deferred.modules) do
        for _, cls in ipairs(m.class_types) do
            if not visited_types:has(cls.cppcls) then
                class_not_found:pushf([[
                    => ${cls.cppcls}
                ]])
            end
            for _, supercls in ipairs(cls.supers) do
                if not visited_types:has(supercls) then
                    supercls_not_found:pushf([[
                        => ${cls.cppcls} -> ${supercls}
                    ]])
                end
            end
        end
    end

    -- check type info
    table.sort(type_checker, function (e1, e2) return e1.type < e2.type end)
    local filter = {}
    for _, entry in ipairs(type_checker) do
        local rawtn = raw_typename(entry.type)
        local rawptn = raw_typename(entry.type, KEEP_POINTER)
        local has_conv = type_convs:has(rawtn)
        local has_ti = olua.typeinfo(rawptn, nil, false)
        local has_alias = alias_types:has(rawtn) or alias_types:has(rawptn)
        if not (has_conv or has_ti or has_alias) then
            if OLUA_VERBOSE then
                type_not_found:pushf([[
                    => ${entry.type} (${entry.kind})
                            from: ${entry.from}
                ]])
            elseif not filter[entry.type] then
                filter[entry.type] = true
                type_not_found:pushf([[
                    => ${entry.type} (${entry.kind})
                ]])
            end
        elseif is_templdate_type(entry.type) and olua.is_pointer_type(entry.type) then
            rawptn = entry.type:gsub('^const ', '')
            if not (type_convs:has(rawptn) or type_convs:has(rawtn)) then
                if OLUA_VERBOSE then
                    conv_not_found:pushf([[
                        => ${entry.type} (${entry.kind})
                                from: ${entry.from}
                    ]])
                elseif not filter[entry.type] then
                    filter[entry.type] = true
                    conv_not_found:pushf([[
                        => ${entry.type} (${entry.kind})
                    ]])
                end
            end
        end
    end

    if #class_not_found > 0 then
        olua.print('')
        olua.print([[
            class not configured:
                ${class_not_found}
            you should do:
                * add include header file in your config file or check the class name
        ]])
    end

    if #supercls_not_found > 0 then
        olua.print('')
        olua.print([[
            super class not configured:
                ${supercls_not_found}
            you should do one of:
                * add in config file: typeconf 'MissedSuperClass'
                * set in build file: OLUA_AUTO_EXPORT_PARENT = true
        ]])
    end

    if #type_not_found > 0 then
        olua.print('')
        olua.print([[
            type info not found:
                ${type_not_found}
            you should do one of:
                * if has the type convertor, use typedef 'NotFoundType'
                * if type is pointer or enum, use typeconf 'NotFoundType'
                * if type not wanted, use excludetype 'NotFoundType'
            more debug info set 'OLUA_VERBOSE = true'
        ]])
    end

    if #conv_not_found > 0 then
        olua.print('')
        olua.print([[
            convertor not found:
                ${conv_not_found}
            you should do one of:
                * if has the type convertor, use typedef 'NotFoundType'
                * if type not wanted, use ".exclude 'MethodName'"
                * if type you wanted, try 'olua::span' or 'olua::pointer'
            more debug info set 'OLUA_VERBOSE = true'
        ]])
    end

    if #class_not_found > 0
        or #supercls_not_found > 0
        or #type_not_found > 0
        or #conv_not_found > 0
    then
        olua.print('')
        error('You should fix above errors!')
    end
end

local function copy_super_funcs()
    local function copy_funcs(cls, super)
        local rawsuper = raw_typename(super.cppcls)
        for _, func in ipairs(super.funcs) do
            if func.name == '__gc' then
                goto continue
            end
            if func.snippet then
                if not cls.funcs:has(func.name) and not cls.excludes:has(func.name) then
                    cls.funcs:push(func.name, setmetatable({}, {__index = func}))
                end
            else
                if not cls.funcs:has(func.prototype)
                    and not func.isctor
                    and not cls.excludes:has(func.display_name)
                then
                    cls.funcs:push(func.prototype, setmetatable({
                        decl = format("@copyfrom(${rawsuper}) ${func.decl}")
                    }, {__index = func}))
                end
            end
            ::continue::
        end
    end

    local function copy_vars(cls, super)
        local rawsuper = raw_typename(super.cppcls)
        for _, var in ipairs(super.vars) do
            if not cls.vars:has(var.name)
                and not cls.excludes:has(var.name)
            then
                cls.vars:push(var.name, setmetatable({
                    snippet = format("@copyfrom(${rawsuper}) ${var.snippet}")
                }, {__index = var}))
            end
        end
    end

    local function copy_props(cls, super)
        local rawsuper = raw_typename(super.cppcls)
        for _, prop in ipairs(super.props) do
            if not cls.excludes:has(prop.name) and not cls.props:has(prop.name) then
                local get = prop.get
                local set = prop.set
                if get and not get:find('{') then
                    get = format('@copyfrom(${rawsuper}) ${get}')
                end
                if set and not set:find('{') then
                    set = format('@copyfrom(${rawsuper}) ${set}')
                end
                cls.props:push(prop.name, {name = prop.name, get = get, set = set})
            end
        end
    end

    local function copy_super(cls, super)
        copy_props(cls, super)
        copy_vars(cls, super)
        copy_funcs(cls, super)

        for _, sc in ipairs(super.supers) do
            copy_super(cls, visited_types:get(sc))
        end
    end

    for _, m in ipairs(deferred.modules) do
        for _, cls in ipairs(m.class_types) do
            for _, supercls in ipairs(cls.supers) do
                if cls.supercls == supercls then
                    goto continue
                end
                local super = visited_types:get(supercls)
                copy_super(cls, super)
                if #cls.supers == 1 and is_templdate_type(super.cppcls) then
                    -- see find 'find_as_cls'
                    -- no 'as' func, no need to export
                    super.kind = super.kind | kFLAG_SKIP
                end
                ::continue::
            end
        end
    end
end

local function find_as()
    for _, m in ipairs(deferred.modules) do
        for _, cls in ipairs(m.class_types) do
            -- find as
            local ascls = olua.newhash()
            if #cls.supers > 1 then
                local function find_as_cls(c)
                    for supercls in pairs(c.supers) do
                        ascls:replace(supercls, supercls)
                        find_as_cls(visited_types:get(supercls))
                    end
                end
                find_as_cls(cls)

                -- remove first super class
                local function remove_first_as_cls(c)
                    local supercls = c.supercls
                    if supercls then
                        local rawsuper = raw_typename(supercls, KEEP_POINTER)
                        ascls:take(rawsuper)
                        remove_first_as_cls(visited_types:get(supercls))
                    end
                end
                remove_first_as_cls(cls)
            end
            if #ascls > 0 then
                table.sort(ascls.values)
                ascls = table.concat(ascls.values, ' ')
                cls.funcs:push('as', {
                    name = 'as',
                    luaname = 'nil',
                    decl = format("@as(${ascls}) void *as(const char *cls)")
                })
            end
        end
    end
end

local function parse_modules()
    parse_headers()
    parse_types()
    check_errors()
    copy_super_funcs()
    find_as()

    for _, m in ipairs(deferred.modules) do
        write_module(m)
    end
end

local function write_ignored_types()
    local file = io.open('autobuild/ignore-types.log', 'w')
    local ignored_types = {}
    for cppcls, cur in  pairs(type_cursors) do
        local kind = cur.kind
        if not cppcls:find('^std::')
            and (kind == CursorKind.ClassDecl
                or kind == CursorKind.EnumDecl
                or kind == CursorKind.ClassTemplate
                or kind == CursorKind.StructDecl)
            and not (visited_types:has(cppcls)
                or exclude_types:has(cppcls)
                or alias_types:has(cppcls)
                or type_convs:has(cppcls))
        then
            ignored_types[#ignored_types + 1] = cppcls
        end
    end
    table.sort(ignored_types)
    for _, cls in pairs(ignored_types) do
        file:write(string.format("[ignore class] %s\n", cls))
    end
end

local function write_typedefs()
    local types = olua.newarray()
    local typedefs = olua.newarray('\n')

    typedefs:push("-- AUTO BUILD, DON'T MODIFY!\n")

    for _, m in ipairs(deferred.modules) do
        for _, td in ipairs(m.typedef_types) do
            if td.packable then
                olua.assert(td.packvars, [[
                    no 'packvars' for packable type '${td.cppcls}'
                ]])
            end
            typedefs:pushf([[
                typedef {
                    from = 'module: ${m.filename}.lua -> typedef "${td.cppcls}"',
                    cppcls = '${td.cppcls}',
                    luacls = ${td.luacls??},
                    conv = '${td.conv}',
                    packable = ${td.packable??},
                    packvars = ${td.packvars??},
                    smartptr = ${td.smartptr??},
                    replace = ${td.replace??},
                }
            ]])
            typedefs:push('')
        end

        for _, cls in ipairs(m.class_types) do
            if cls.maincls then
                goto continue
            end

            local cppcls = cls.cppcls
            local conv, declfunc, packvars
            if has_type_flag(cls, kFLAG_FUNC) then
                declfunc = cls.underlying
                conv = 'olua_$$_callback'
            elseif has_type_flag(cls, kFLAG_ENUM) then
                conv = 'olua_$$_enum'
            elseif has_type_flag(cls, kFLAG_POINTER) then
                conv = 'olua_$$_object'
                if cls.options.packable then
                    packvars = cls.options.packvars or #cls.vars
                end
            else
                error(cls.cppcls .. ' ' .. cls.kind)
            end

            typedefs:pushf([[
                typedef {
                    from = 'module: ${m.filename}.lua -> typeconf "${cppcls}"',
                    cppcls = '${cppcls}',
                    luacls = ${cls.luacls??},
                    supercls = ${cls.supercls??},
                    declfunc = ${declfunc??},
                    conv = '${conv}',
                    packable = ${cls.options.packable??},
                    packvars = ${packvars??},
                }
            ]])
            typedefs:push('')

            ::continue::
        end
    end

    for alias, cppcls in pairs(alias_types) do
        if visited_types:get(raw_typename(alias)) then
            goto continue
        end
        local cls = visited_types:get(raw_typename(cppcls))
        local from = "alias: ${alias} -> ${cppcls}"
        if not cls then
            local ti = olua.typeinfo(cppcls)
            types:push({
                from = from,
                cppcls = alias,
                conv = ti.conv,
                luacls = ti.luacls,
            })
        elseif has_type_flag(cls, kFLAG_FUNC) then
            types:push({
                from = from,
                cppcls = alias,
                luacls = cls.luacls,
                declfunc = cls.underlying,
                conv = 'olua_$$_callback',
            })
        elseif has_type_flag(cls, kFLAG_ENUM) then
            types:push({
                from = from,
                cppcls = alias,
                conv = 'olua_$$_enum',
            })
        else
            olua.assert(has_type_flag(cls, kFLAG_POINTER), [[
                '${cls.cppcls}' not a pointee type
            ]])
            local packvars
            local packable = cls.options.packable
            if packable then
                packvars = cls.options.packvars or #cls.vars
            end
            types:push({
                from = from,
                cppcls = alias,
                luacls = cls.luacls,
                packvars = packvars,
                packable = packable,
                conv = "olua_$$_object"
            })
        end
        ::continue::
    end
    
    for i, v in ipairs(olua.sort(types, 'cppcls')) do
        typedefs:pushf([[
            typedef {
                from = '${v.from}',
                cppcls = '${v.cppcls}',
                conv = '${v.conv}',
                luacls = ${v.luacls??},
                declfunc = ${v.declfunc??},
                packable = ${v.packable??},
                packvars = ${v.packvars??},
            }
        ]])
        typedefs:push('')
    end

    olua.write('autobuild/typedefs.idl', table.concat(typedefs, '\n'))
end

local function write_makefile()
    local class_files = olua.newarray('\n')
    for _, v in ipairs(module_files) do
        class_files:pushf('export "${v.class_file}"')
    end
    olua.write('autobuild/make.lua', format([[
        require "olua.tools"

        dofile "autobuild/typedefs.idl"

        ${class_files}
    ]]))
end

local function deferred_autoconf()
    parse_modules()
    write_ignored_types()
    write_typedefs()
    write_makefile()

    exclude_types = nil
    visited_types = nil
    alias_types = nil
    type_convs = nil
    module_files = nil
    deferred = nil

    if OLUA_AUTO_BUILD ~= false then
        dofile('autobuild/make.lua')
    end
end

-------------------------------------------------------------------------------
-- define config module
-------------------------------------------------------------------------------
local function checkstr(key, v)
    if type(v) ~= 'string' then
        error(string.format("command '%s' expect 'string', got '%s'", key, type(v)))
    end
    return v
end

local function tonum(key, v)
    return tonumber(v)
end

local function checkfunc(key, v)
    if type(v) ~= 'function' then
        error(string.format("command '%s' expect 'function', got '%s'", key, type(v)))
    end
    return v
end

local function totable(key, v)
    return type(v) == 'table' and v or nil
end

local function tobool(key, v)
    if v == 'true' then
        return true
    elseif v == 'false' then
        return false
    end
end

local function toany(...)
    local funcs = {...}
    return function (key, ...)
        for _, f in ipairs(funcs) do
            local v = f(key, ...)
            if v ~= nil then
                return v
            end
        end
        return checkstr(key, ...)
    end
end

local function add_value_command(CMD, key, store, field, tofunc)
    tofunc = tofunc or checkstr
    field = field or key
    CMD[key] = function (v)
        store[field] = tofunc(key, v)
    end
end

local function add_attr_command(CMD, name, cls)
    local entry = {}
    cls.attrs:push(name, entry)
    add_value_command(CMD, 'optional', entry, nil, tobool)
    add_value_command(CMD, 'readonly', entry, nil, tobool)
    add_value_command(CMD, 'ret', entry)
    for i = 1, 25 do
        add_value_command(CMD, 'arg' .. i, entry)
    end
end

local function add_insert_command(CMD, name, cls)
    local entry = {name = name}
    cls.inserts:push(name, entry)
    add_value_command(CMD, 'insert_before', entry, 'before')
    add_value_command(CMD, 'insert_after', entry, 'after')
    add_value_command(CMD, 'insert_cbefore', entry, 'cbefore')
    add_value_command(CMD, 'insert_cafter', entry, 'cafter')
end

local function make_typeconf_command(cls, ModuleCMD)
    local CMD = {}
    local macro = nil
    local mode = nil

    add_value_command(CMD, 'chunk', cls)
    add_value_command(CMD, 'luaname', cls, nil, checkfunc)
    add_value_command(CMD, 'supercls', cls)
    add_value_command(CMD, 'luaopen', cls)
    add_value_command(CMD, 'indexerror', cls.options)
    add_value_command(CMD, 'packable', cls.options, nil, tobool)
    add_value_command(CMD, 'packvars', cls.options, nil, tonum)
    add_value_command(CMD, '_maincls', cls, "maincls", totable)

    function CMD.extend(extcls)
        cls.extends:push(extcls, true)
        ModuleCMD.typeconf(extcls)
            ._maincls(cls)
    end

    function CMD.exclude(name)
        if mode and mode ~= 'exclude' then
            local cppcls = cls.cppcls
            olua.error("can't use .include and .exclude at the same time in typeconf '${cppcls}'")
        end
        mode = 'exclude'
        name = checkstr('exclude', name)
        if name == '*' or not name:find('[^_%w]') then
            cls.excludes:push(name, true)
        else
            cls.wildcards:push(name, true)
        end
    end

    function CMD.include(name)
        if mode and mode ~= 'include' then
            local cppcls = cls.cppcls
            olua.error("can't use .include and .exclude at the same time in typeconf '${cppcls}'")
        end
        mode = 'include'
        name = checkstr('include', name)
        cls.includes:push(name, true)
    end

    function CMD.macro(cond)
        cond = checkstr('macro', cond)
        if cond == '' then
            macro = nil
        else
            macro = cond
        end
    end

    function CMD.enum(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('enum', name)
        cls.enums:push(name, entry)
        add_value_command(SubCMD, 'value', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.const(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('const', name)
        cls.consts:push(name, entry)
        add_value_command(SubCMD, 'value', entry)
        add_value_command(SubCMD, 'typename', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.func(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('func', name)
        cls.excludes:replace(name, true)
        if macro then
            cls.macros:push(name, {name = name, value = macro})
        end
        cls.funcs:push(name, entry)
        add_value_command(SubCMD, 'snippet', entry)
        add_attr_command(SubCMD, name, cls)
        add_insert_command(SubCMD, name, cls)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.callback(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('callback', name)
        cls.callbacks:push(name, entry)
        add_value_command(SubCMD, 'localvar', entry, nil, tobool)
        add_value_command(SubCMD, 'tag_maker', entry, nil, toany(totable))
        add_value_command(SubCMD, 'tag_mode', entry, nil, toany(totable))
        add_value_command(SubCMD, 'tag_store', entry, nil, tonum)
        add_value_command(SubCMD, 'tag_scope', entry, nil)
        add_attr_command(SubCMD, name, cls)
        add_insert_command(SubCMD, name, cls)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.prop(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('prop', name)
        cls.props:push(name, entry)
        add_value_command(SubCMD, 'get', entry)
        add_value_command(SubCMD, 'set', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.var(name, snippet)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('var', name)
        if name ~= '*' then
            cls.excludes:replace(name, true)
            cls.vars:replace(name, entry)
            add_value_command(SubCMD, 'snippet', entry)
        else
            name = 'var*'
        end
        add_attr_command(SubCMD, name, cls)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.alias(name)
        local entry = {name = name}
        local SubCMD = {}
        add_value_command(SubCMD, 'to', entry, 'alias')
        cls.aliases:push(name, entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    return olua.command_proxy(CMD)
end

local function make_typedef_command(cls)
    local CMD = {}
    add_value_command(CMD, 'conv', cls)
    add_value_command(CMD, 'packable', cls, nil, tobool)
    add_value_command(CMD, 'packvars', cls, nil, tonum)
    add_value_command(CMD, 'smartptr', cls, nil, tobool)
    add_value_command(CMD, 'luacls', cls)
    add_value_command(CMD, 'replace', cls, nil, tobool)
    return olua.command_proxy(CMD)
end

--
-- module conf
-- autoconf 'conf/lua-exmpale.lua'
--
local has_hook = false

function M.__call(_, path)
    if not has_hook then
        has_hook = true
        local debug_getinfo = debug.getinfo
        local build_func = debug_getinfo(2, "f").func
        local count = 0
        debug.sethook(function ()
            count = count + 1
            if debug_getinfo(2, "f").func == build_func then
                debug.sethook(nil)
                deferred_autoconf()
            end
        end, 'r')
    end

    local macro = nil
    local CMD = {}
    local module = {
        CMD = CMD,
        headers = '',
        class_types = olua.newhash(),
        wildcard_types = olua.newhash(),
        typedef_types = olua.newhash(),
        luacls = function (cppname)
            return string.gsub(cppname, "::", ".")
        end,
    }

    add_value_command(CMD, 'module', module, 'name')
    add_value_command(CMD, 'path', module)
    add_value_command(CMD, 'luaopen', module)
    add_value_command(CMD, 'headers', module)
    add_value_command(CMD, 'chunk', module)
    add_value_command(CMD, 'luacls', module, nil, checkfunc)

    function CMD.excludetype(tn)
        tn = olua.pretty_typename(tn)
        exclude_types:replace(tn, true)
    end

    function CMD.import(filepath)
        assert(loadfile(filepath, nil, CMD))()
    end

    function CMD.macro(cond)
        cond = checkstr('macro', cond)
        if cond == '' then
            macro = nil
        else
            macro = cond
        end
    end

    function CMD.typeconf(cppcls)
        local cls = {
            cppcls = assert(cppcls, 'not specify cppcls'),
            luacls = module.luacls(cppcls),
            extends = olua.newhash(),
            excludes = olua.newhash(),
            wildcards = olua.newhash(), -- exclude wildcards
            includes = olua.newhash(),
            usings = olua.newhash(),
            attrs = olua.newhash(),
            enums = olua.newhash(),
            consts = olua.newhash(),
            funcs = olua.newhash(),
            callbacks = olua.newhash(),
            props = olua.newhash(),
            vars = olua.newhash(),
            aliases = olua.newhash(),
            inserts = olua.newhash(),
            macros = olua.newhash(),
            supers = olua.newhash(),
            underlying = nil,
            options = {reg_luatype = true},
            template_types = olua.newhash(),
            luaname = function (n) return n end,
        }
        if exclude_types:has(cls.cppcls) then
            olua.error([[
                typeconf '${cls.cppcls}' will not configured
                you should do one of:
                    * remove excludetype '${cls.cppcls}'
            ]])
        end
        if cppcls:find('[%^%%%$%*%+]') then -- ^%$*+
            module.wildcard_types:push(cppcls, cls)
        else
            module.class_types:push(cppcls, cls)
        end
        if macro then
            cls.macros:push('*', {name = '*', value = macro})
        end
        return make_typeconf_command(cls, CMD)
    end

    function CMD.typeonly(cppcls)
        local cls = CMD.typeconf(cppcls)
        cls.exclude '*'
        return cls
    end

    function CMD.typedef(cppcls)
        local cls = {}
        for c in cppcls:gmatch('[^;\n\r]+') do
            c = olua.pretty_typename(c)
            local t = setmetatable({cppcls = c}, {__index = cls})
            module.typedef_types:push(c, t)
        end
        return make_typedef_command(cls)
    end

    function CMD._typecopy(cppcls, fromcls)
        CMD.typeconf(cppcls)
        local cls = module.class_types:get(cppcls)
        for k, v in pairs(fromcls) do
            if k == 'cppcls' or k == 'luacls' then
                goto continue
            end
            if type(v) == 'table' then
                cls[k] = v:clone()
            else
                cls[k] = v
            end

            ::continue::
        end
    end

    function CMD.clang(clang_args)
        deferred.clang_args = clang_args
        module = nil
    end

    assert(loadfile(path, nil, setmetatable({}, {
        __index = function (_, k)
            return CMD[k] or _ENV[k]
        end,
        __newindex = function (_, k)
            olua.error("create command '${k}' is not available")
        end
    })))()

    if module and module.name then
        module.filename = path:match('([^/\\]+).lua$')
        deferred.modules:push(module.name, module, "(module name)")
    end
end

olua.autoconf = setmetatable({}, M)
