local clang = require 'clang'
local TypeKind = require 'clang.TypeKind'
local CursorKind = require 'clang.CursorKind'
local CXXAccessSpecifier = require 'clang.CXXAccessSpecifier'
local DiagnosticSeverity = require 'clang.DiagnosticSeverity'

if not olua.isdir('autobuild') then
    olua.mkdir('autobuild')
end

olua.print('lua clang: v%s', clang.version)

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

local clang_tu

local type_cursors    = olua.ordered_map(false)
local comment_cursors = olua.ordered_map(false)
local exclude_types   = olua.ordered_map(false)
local visited_types   = olua.ordered_map(false)
local alias_types     = olua.ordered_map(false)
local type_convs      = olua.ordered_map(false)
local type_checker    = olua.array()
local clang_args      = {}
local modules         = olua.ordered_map()
local metamethod      = {
    __index = true,
    __newindex = true,
    __gc = true,
    __pairs = true,
    __len = true,
    __eq = true,
    __tostring = true,
    __add = true,
    __sub = true,
    __mul = true,
    __mod = true,
    __pow = true,
    __div = true,
    __idiv = true,
    __band = true,
    __bor = true,
    __bxor = true,
    __shl = true,
    __shr = true,
    __unm = true,
    __bnot = true,
    __lt = true,
    __le = true,
    __concat = true,
    __call = true,
    __close = true
}

local kFLAG_POINTER   = 1 << 1 -- pointer type
local kFLAG_ENUM      = 1 << 2 -- enum type
local kFLAG_ALIAS     = 1 << 3 -- alias type
local kFLAG_FUNC      = 1 << 4 -- function type
local kFLAG_TEMPLATE  = 1 << 5 -- template type
local kFLAG_SKIP      = 1 << 6 -- don't export

local KEEP_CONST      = 1 << 1
local KEEP_TEMPLATE   = 1 << 2
local KEEP_POINTER    = 1 << 3

local function has_flag(flag, k)
    return (flag & k) ~= 0
end

local function has_type_flag(cls, kind)
    return has_flag(cls.kind or 0, kind)
end

local function raw_typename(cppcls, flag)
    if cppcls == '' then
        return ''
    else
        flag = flag or 0
        if not has_flag(flag, KEEP_CONST) then
            cppcls = cppcls:gsub('^const ', '')
        end
        if not has_flag(flag, KEEP_TEMPLATE) then
            cppcls = cppcls:gsub('<.*>', '')
        end
        if not has_flag(flag, KEEP_POINTER) then
            cppcls = cppcls:gsub('[ &*]+$', '')
        else
            cppcls = cppcls:gsub('[ &]+$', '')
        end
        return olua.pretty_typename(cppcls)
    end
end

---@param tn string
---@return string
local function trim_prefix_colon(tn)
    if tn:find(' ::') then
        tn = tn:gsub(' ::', ' ')
    end
    if tn:find('^::') then
        tn = tn:gsub('^::', '')
    end
    return tn
end

---@param type clang.Type | {declaration: clang.Cursor, name: string}
---@return string
local function parse_from_ast(type)
    local cur = type.declaration
    if cur.kind == CursorKind.NoDeclFound then
        return trim_prefix_colon(type.name)
    end

    local exps = olua.array():set_joiner('::')
    while cur and cur.kind ~= CursorKind.TranslationUnit do
        local value = raw_typename(cur.name)
        if cur.isInlineNamespace then
            cur = cur.parent
        elseif value then
            exps:unshift(value)
            cur = cur.parent
        else
            break
        end
    end
    return trim_prefix_colon(tostring(exps))
end

local typename

---@param type clang.Type
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
        local exps = olua.array()
        local astname = parse_from_ast(type)
        exps:push(astname)
        if olua.is_templdate_type(tn) then
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
        local exps = olua.array()
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
            if astname:find('::operator') then
                return tn
            end
            return tn:gsub(rawtn, astname)
        end
    end
end

local function check_alias_typename(tn, underlying)
    -- try pointer version
    local rawptn = raw_typename(tn, KEEP_POINTER)
    local rawp_underlying = raw_typename(underlying, KEEP_POINTER)
    if rawptn == rawp_underlying then
        return tn, false
    elseif type_convs:has(rawp_underlying) then
        alias_types:replace(rawptn, rawp_underlying)
        return tn, true
    end

    if rawptn:find('%*$') then
        local rawtn = raw_typename(tn)
        local raw_underlying = raw_typename(underlying)
        if type_convs:has(raw_underlying) then
            alias_types:replace(rawtn, raw_underlying)
            return tn, true
        end
    end

    local has_ti = olua.typeinfo(rawp_underlying, nil, false)
    if has_ti and not olua.is_templdate_type(underlying) then
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

    if exclude_types:has(rawptn) then
        return tn
    end

    if not type_convs:has(rawtn)
        and not type_convs:has(rawptn)
        and not olua.typeinfo(rawptn, nil, false)
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
    return exclude_types:has(rawptn) or name:find('%*%*$')
end

---@param type clang.Type
---@return boolean
local function is_excluded_type(type)
    if type.kind == TypeKind.IncompleteArray then
        return true
    end

    local tn = typename(type)
    if olua.is_templdate_type(tn) then
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
                    exps = exps or olua.array():set_joiner(' ')
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
    return setmetatable({}, { __index = attr or {} })
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

---@param cur clang.Cursor
local function get_comment(cur)
    local comment = cur.rawCommentText
    if comment then
        local see = comment:match('@oluasee +([%w$_:]+)')
        if see then
            local see_cursor = comment_cursors:get(see)
            if see_cursor then
                local see_comment = see_cursor.rawCommentText
                if see_comment then
                    comment = see_comment
                end
            else
                print(olua.format('[WARNING]: @oluasee ${see} not found'))
            end
        end

        return olua.base64_encode(comment)
    end
end

local M = {}

function M:parse()
    assert(not self.class_file)
    self.class_file = olua.format('autobuild/${self.filename}.idl')

    -- scan method, variable, enum, const value
    for _, cls in ipairs(self.class_types:toarray()) do
        local cur = type_cursors:get(cls.cppcls)
        if cur then
            self:visit(cur, cls.cppcls)
        end
    end
end

---@param cls TypeconfDescriptor
---@param cur clang.Cursor
function M:visit_method(cls, cur)
    if has_deprecated_attr(cur)
        or cur.isCXXMoveConstructor
        or cur.name:find('operator *[%-=+/*><!()]?')
        or cur.name == 'as' -- 'as used to cast object'
        or has_exclude_attr(cur)
    then
        return
    end

    local fn = cur.name
    local display_name = cur.displayName
    local luaname = fn
    local arguments = cur.arguments
    local result_type = cur.resultType
    local typefrom = olua.format('${cls.cppcls} -> ${cur.prettyPrinted}')
    local attr = get_attr_copy(cls, fn)
    local callback = cls.callbacks:get(fn) or {}
    local static = cur.isCXXMethodStatic
    local declexps = olua.array()
    local protoexps = olua.array()

    parse_attr_from_annotate(attr, cur)

    local comment = get_comment(cur)
    if comment then
        declexps:push(olua.format('@comment(${comment})'))
        declexps:push(' ')
    end

    for i, c in ipairs({ { type = result_type }, table.unpack(arguments) }) do
        local mark = (attr['arg' .. (i - 1)]) or ''
        if is_excluded_type(c.type) then
            if cls.includes:has(fn) then
                print(olua.format([=[
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

    if cur.kind == CursorKind.FunctionDecl then
        static = true
    end
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
                declexps:push(olua.format('${arg.name}_$${vi}'))
            end
        end
    end

    declexps:push(')')
    protoexps:push(')')

    local decl = tostring(declexps)
    local prototype = tostring(protoexps)
    cls.excludes:replace(display_name, true)
    cls.excludes:replace(prototype, true)

    if decl:find('@getter') or decl:find('@setter') then
        local what = decl:find('@getter') and 'get' or 'set'
        olua.assert((what == 'get' and num_args == 0) or num_args == 1, [[
            ${what}ter function has wrong argument:
                prototype: ${decl}
        ]])
        local prop = cls.props:get(luaname)
        if not prop then
            prop = { name = luaname }
            cls.props:set(luaname, prop)
        end
        prop[what] = decl
    else
        cls.funcs:set(prototype, {
            decl = decl,
            luaname = luaname == fn and 'nil' or olua.format([['${luaname}']]),
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

---@param cls TypeconfDescriptor
---@param cur clang.Cursor
function M:visit_var(cls, cur)
    if is_excluded_type(cur.type)
        or has_exclude_attr(cur)
        or has_deprecated_attr(cur)
        or cur.type.name:find('%[')
    then
        return
    end

    local exps = olua.array()
    local typefrom = olua.format('${cls.cppcls} -> ${cur.prettyPrinted}')
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
    cls.vars:set(name, {
        name = name,
        body = decl,
        cb_kind = cb_kind
    })
end

---@param cppcls string
---@return TypeconfDescriptor
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

---@param cppcls any
---@param cur clang.Cursor
function M:visit_enum(cppcls, cur)
    local cls = self:will_visit(cppcls)
    local filter = {}
    for _, c in ipairs(cur.children) do
        ---@type string
        local value = c.name
        local intvalue
        local name = cls.luaname(value --[[@as string]], 'enum')
        local range = c.commentRange
        local comment = c.rawCommentText
        if not filter[range.startLine] then
            filter[range.startLine] = true
        else
            comment = ''
        end
        value = olua.format('${cls.cppcls}::${value}')
        if c.kind == CursorKind.EnumConstantDecl then
            intvalue = c.enumConstantDeclValue
        end
        cls.enums:set(name, {
            name = name,
            value = value,
            intvalue = intvalue,
            comment = comment
        })
    end
    type_convs:get(cppcls).conv = 'olua_$$_enum'
    cls.options.indexerror = 'rw'
    cls.kind = cls.kind or kFLAG_ENUM
end

function M:visit_alias_class(alias, cppcls)
    local cls = self:will_visit(alias)
    cls.kind = cls.kind or kFLAG_POINTER
    if is_func_type(cppcls) then
        cls.kind = cls.kind | kFLAG_FUNC
        cls.funcdecl = cppcls
        cls.luacls = self.luacls(alias)
        type_convs:get(alias).conv = 'olua_$$_callback'
    else
        cls.kind = cls.kind | kFLAG_ALIAS
        cls.supercls = cppcls
        cls.luacls = self.luacls(cppcls)
    end
end

---@param cppcls string
---@param cur clang.Cursor
---@param template_types any
---@param specializedcls any
function M:visit_class(cppcls, cur, template_types, specializedcls)
    local cls = self:will_visit(cppcls)
    local skipsuper = false

    cls.kind = cls.kind or kFLAG_POINTER

    local comment = get_comment(cur)
    if comment then
        cls.comment = comment
    end

    if cur.kind == CursorKind.ClassTemplate then
        type_convs:replace(raw_typename(cppcls), true)
        olua.assert(template_types, [[
            don't config template class:
                you should remove: typeconf '${cls.cppcls}'
        ]])
        cls.kind = cls.kind | kFLAG_TEMPLATE
        if specializedcls then
            cls.template_types:set(specializedcls, cppcls)
        end
        cls.options.fromtable = false
    elseif cur.kind == CursorKind.Namespace then
        cls.options.reg_luatype = false
        cls.options.fromtable = false
    end

    for _, c in ipairs(cur.children) do
        local kind = c.kind
        local access = c.cxxAccessSpecifier
        if kind == CursorKind.Constructor then
            if c.isCXXMethodDeleted then
                cls.options.fromtable = false
            end
        end
        if access == CXXAccessSpecifier.Private
            or access == CXXAccessSpecifier.Protected
        then
            if kind == CursorKind.FunctionDecl or kind == CursorKind.CXXMethod then
                cls.excludes:replace(c.displayName, true)
            end
            if kind == CursorKind.Destructor then
                cls.options.disallow_gc = true
            elseif c.name == 'operator=' then
                cls.options.disallow_assign = true
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
            cls.template_types:set(c.name, tn)
        elseif kind == CursorKind.CXXBaseSpecifier then
            local supercls = parse_from_type(c.type)
            local rawsupercls = raw_typename(supercls)
            local supercursor = type_cursors:get(rawsupercls)

            cls.options.fromtable = false

            if is_excluded_typename(rawsupercls) then
                skipsuper = true
                goto continue
            end

            if olua.is_templdate_type(supercls) then
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
                    assert(supercursor, 'no cursor for ' .. rawsupercls)
                    if not self.class_types:has(rawsupercls) then
                        self.CMD.typeconf(rawsupercls)
                    end
                    self:visit_class(rawsupercls, supercursor)
                    super = self.class_types:take(rawsupercls)
                    if super.supercls then
                        self.class_types:insert('after', super.supercls, rawsupercls, super)
                    else
                        self.class_types:insert('front', nil, rawsupercls, super)
                    end
                end
            end

            if not cls.supercls and not skipsuper then
                skipsuper = true
                cls.supercls = supercls
            end
            cls.supers:set(supercls, supercls)
        elseif kind == CursorKind.UsingDeclaration then
            for _, cc in ipairs(c.children) do
                if cc.kind == CursorKind.TypeRef then
                    cls.usings:set(c.name, cc.name:match('([^ ]+)$'))
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
                    cls.consts:set(varname, { name = varname, typename = vartype.name })
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
                or c.isCXXMethodDeleted
                or (isConstructor and (cls.excludes:has('new')))
                or (isConstructor and cur.kind == CursorKind.ClassTemplate)
                or (isConstructor and cur.isCXXAbstract)
            then
                goto continue
            end
            self:visit_method(cls, c)
        end

        ::continue::
    end
end

---@param cur clang.Cursor
---@param cppcls string
function M:visit(cur, cppcls)
    local kind = cur.kind
    local children = cur.children
    local astcls = parse_from_ast({ declaration = cur, name = cur.name })
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
                    typedef olua::pointer<int> olua_int;

                    specialized: olua::pointer<int>
                         cppcls: olua_int
                      packedcls: int
                ]]
                local arg_types = {}
                for i, v in ipairs(cur.type.templateArgumentTypes) do
                    arg_types[i] = parse_from_type(v)
                end
                local specializedcls = parse_from_type(cur.underlyingType)
                self:visit_class(cppcls, specialized, arg_types, specializedcls)

                if specializedcls:find('^olua::pointer') then
                    local typedef = self.CMD.typedef
                    local packedcls = specializedcls:match('<(.*)>') .. ' *'
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
    for _, m in ipairs(modules) do
        if m.class_types:has(cppcls) or type_convs:has(cppcls) then
            goto continue
        end
        for type, conf in pairs(m.wildcard_types) do
            if cppcls:find(type) then
                if exclude_types:has(cppcls) then
                    print(olua.format([=[
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

---@param cur clang.Cursor
local function prepare_cursor(cur)
    local kind = cur.kind
    local cppcls = parse_from_ast({ declaration = cur, name = cur.name })
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
            type_cursors:replace(cppcls, cur)
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
            type_cursors:replace(cppcls, cur)
            type_cursors:replace(typename(cur.type), cur)
            try_add_wildcard_type(cppcls, cur)
        end
    elseif kind == CursorKind.UnexposedDecl or kind == CursorKind.LinkageSpec then
        for _, v in ipairs(cur.children) do
            prepare_cursor(v)
        end
    end
    if cur.rawCommentText then
        comment_cursors:replace(cppcls, cur)
    end
    if kind == CursorKind.TranslationUnit then
        alias_types:clear()
    end
end

-------------------------------------------------------------------------------
-- output config
-------------------------------------------------------------------------------
local function write_module_metadata(module, append)
    append(olua.format([[
        name = "${module.name}"
        path = "${module.path}"
        metapath = ${module.metapath??}
        entry = ${module.entry??}
    ]]))

    append(olua.format('headers = ${module.headers?}'))
    append(olua.format('chunk = ${module.chunk??}'))
    append(olua.format('luaopen = ${module.luaopen??}'))
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
                    arr[#arr+1] = func
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
                if not cls.funcs:has(func.prototype) then
                    cls.funcs:replace(func.prototype, func)
                end
            end
        elseif not cls.supers:has(where) then
            olua.error([[unexpect copy using error: using ${where}:${name}]])
        end
    end
end

---@param module ModuleDescriptor
---@param cls TypeconfDescriptor
---@param append any
local function write_cls_func(module, cls, append)
    search_using_func(module, cls)

    local group = olua.ordered_map()
    for _, func in ipairs(cls.funcs) do
        local arr = group:get(func.name)
        if not arr then
            arr = {}
            group:set(func.name, arr)
        end
        if func.body or func.name == 'as'
            or is_new_func(module, cls.supercls, func)
        then
            arr.has_new = true
        else
            func = setmetatable({
                decl = '@using ' .. func.decl
            }, { __index = func })
        end
        arr[#arr+1] = func
    end

    for _, arr in ipairs(group) do
        if not arr.has_new then
            goto continue
        end
        local funcs = olua.array():set_joiner("', '", "'", "'")
        local has_callback = false
        local fi = arr[1]
        for _, v in ipairs(arr) do
            if v.cb_kind or cls.callbacks:has(v.name) then
                has_callback = true
            end
            funcs[#funcs+1] = v.decl
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
                    cls.props:replace(name, {
                        name = name,
                        get = getfunc.decl,
                        set = setfunc and setfunc.decl or nil
                    })
                end
            end
        end
        if not has_callback then
            if #funcs > 0 then
                append(olua.format('.func(${fi.luaname}, ${funcs})', 4))
            else
                append(olua.format(".func('${fi.name}', ${fi.body?})", 4))
            end
        else
            local tag_maker = fi.name:gsub('^set', ''):gsub('^get', '')
            local mode = fi.cb_kind == 'ret' and 'equal' or 'replace'
            local callback = cls.callbacks:get(fi.name)
            if callback then
                callback.funcs = funcs
                callback.tag_maker = callback.tag_maker or olua.format('${tag_maker}')
                callback.tag_mode = callback.tag_mode or mode
                callback.tag_store = callback.tag_store or (fi.isctor and -1 or nil)
            else
                cls.callbacks:set(fi.name, {
                    name = fi.name,
                    funcs = funcs,
                    tag_maker = olua.format '${tag_maker}',
                    tag_mode = mode,
                    tag_store = (fi.isctor and -1 or nil),
                })
            end
        end

        ::continue::
    end
end

---@param module ModuleDescriptor
---@param cls TypeconfDescriptor
---@param append any
local function write_cls_options(module, cls, append)
    for _, v in ipairs(olua.array():fill_with_table(cls.options):sort('key')) do
        append(olua.format([[.option('${v.key}', ${v.value?})]], 4))
    end
end

local function write_cls_macro(module, cls, append)
    for _, v in ipairs(cls.macros) do
        append(olua.format([[.macro('${v.name}', '${v.value}')]], 4))
    end
end

local function write_cls_const(module, cls, append)
    for _, v in ipairs(cls.consts) do
        append(olua.format([[.const('${v.name}', '${cls.cppcls}::${v.name}', '${v.typename}')]], 4))
    end
end

local function write_cls_enum(module, cls, append)
    for _, e in ipairs(cls.enums) do
        local comment = e.comment
        local intvalue = e.intvalue
        if not intvalue then
            intvalue = "nil"
        end
        if comment then
            comment = olua.base64_encode(comment)
        else
            comment = ''
        end
        append(olua.format(".enum('${e.name}', '${e.value}', ${intvalue}, '${comment}')", 4))
    end
end

local function write_cls_var(module, cls, append)
    for _, var in ipairs(cls.vars) do
        append(olua.format(".var('${var.name}', ${var.body?})", 4))
    end
end

local function write_cls_prop(module, cls, append)
    for _, p in ipairs(cls.props) do
        append(olua.format([[.prop('${p.name}', ${p.get?}, ${p.set?})]], 4))
    end
end

local function write_cls_callback(module, cls, append)
    for i, v in ipairs(cls.callbacks) do
        assert(v.funcs, cls.cppcls .. '::' .. v.name)
        local funcs = olua.array():set_joiner("',\n'", "'", "'"):concat(v.funcs)
        local tag_maker = olua.array():set_joiner("', '", "'", "'")
        local tag_mode = olua.array():set_joiner("', '", "'", "'")
        local tag_store = v.tag_store or '0'
        local tag_scope = v.tag_scope or 'object'
        if type(v.tag_store) == 'string' then
            tag_store = olua.format([["${v.tag_store}"]])
        end
        assert(v.tag_maker, 'no tag maker')
        assert(v.tag_mode, 'no tag mode')
        if type(v.tag_maker) == 'string' then
            tag_maker:push(v.tag_maker)
        else
            tag_maker:concat(v.tag_maker)
            tag_maker = olua.array(olua.format('{${tag_maker}}'))
        end
        if type(v.tag_mode) == 'string' then
            tag_mode:push(v.tag_mode)
        else
            tag_mode:concat(v.tag_mode)
            tag_mode = olua.array(olua.format('{${tag_mode}}'))
        end
        append(olua.format([[
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
            append(olua.format([[
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
        append(olua.format(".alias('${v.name}', '${v.alias}')", 4))
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
                func.decl = olua.format('@extend(${extcls.cppcls}) ${func.decl}')
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

        append(olua.format([[
            typeconf '${cls.cppcls}'
                .supercls(${cls.supercls??})
                .chunk(${cls.chunk??})
                .luaopen(${cls.luaopen??})
                .comment(${cls.comment??})
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
    local t = olua.array():set_joiner('\n')

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
    local headers = olua.array():set_joiner('\n')
    for _, m in ipairs(modules) do
        headers:push(m.headers)
    end

    local HEADER_PATH = 'autobuild/.autoconf.h'
    local header = assert(io.open(HEADER_PATH, 'w'))
    header:write(olua.format [[
        #ifndef __AUTOCONF_H__
        #define __AUTOCONF_H__

        ${headers}

        #endif
    ]])
    header:close()
    local has_target = false
    local has_stdv = false
    local flags = olua.array()
    flags:push('-DOLUA_AUTOCONF')
    for i, v in ipairs(clang_args) do
        flags[#flags+1] = v
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
        flags:concat({
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
        flags[i] = olua.format(v)
    end
    olua.print('clang: start parse translation unit')
    clang_tu = clang.createIndex(false, true):parse(HEADER_PATH, flags)
    for _, v in ipairs(clang_tu.diagnostics) do
        if v.severity == DiagnosticSeverity.Error
            or v.severity == DiagnosticSeverity.Fatal
        then
            error('parse header error')
        end
    end
    olua.print('clang: start prepare cursor')
    prepare_cursor(clang_tu.cursor)
    olua.print('clang: complete prepare cursor')
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
end

local function parse_types()
    for _, m in ipairs(modules) do
        for _, cls in ipairs(m.typedef_types) do
            init_conv_func(cls)
        end
        for _, cls in ipairs(m.class_types) do
            init_conv_func(cls)
        end
    end

    for _, m in ipairs(modules) do
        for _, cls in ipairs(m.class_types) do
            for fn, func in pairs(cls.funcs) do
                if not func.body then
                    cls.funcs:take(fn)
                    cls.excludes:take(fn)
                end
            end
            for vn, vi in pairs(cls.vars) do
                if not vi.body then
                    cls.vars:take(vn)
                    cls.excludes:take(vn)
                end
            end
        end
        setmetatable(m, { __index = M })
        olua.print('parsing: %s', m.file)
        m:parse()
    end
end

local function check_errors()
    local class_not_found = olua.array()
    local supercls_not_found = olua.array()
    local type_not_found = olua.array()

    -- check class and super class
    for _, m in ipairs(modules) do
        for _, cls in ipairs(m.class_types) do
            if not visited_types:has(cls.cppcls) then
                class_not_found:push(olua.format([[
                    => ${cls.cppcls}
                ]]))
            end
            for _, supercls in ipairs(cls.supers) do
                if not visited_types:has(supercls) then
                    supercls_not_found:push(olua.format([[
                        => ${cls.cppcls} -> ${supercls}
                    ]]))
                end
            end
        end
    end

    -- check type info
    table.sort(type_checker, function (e1, e2) return e1.type < e2.type end)
    local filter = {}
    olua.ipairs(type_checker, function (_, entry)
        if is_func_type(entry.type) then
            if not olua.is_pointer_type(entry.type) then
                return
            end
        elseif not olua.is_templdate_type(entry.type)
            or not olua.is_pointer_type(entry.type)
        then
            local rawtn = raw_typename(entry.type)
            local rawptn = raw_typename(entry.type, KEEP_POINTER)
            if type_convs:has(rawtn)
                or type_convs:has(rawptn)
                or alias_types:has(rawtn)
                or alias_types:has(rawptn)
                or olua.typeinfo(rawptn, nil, false)
            then
                return
            end
        else
            -- template type with pointer
            local rawtn = raw_typename(entry.type, KEEP_TEMPLATE)
            local rawptn = raw_typename(entry.type, KEEP_TEMPLATE | KEEP_POINTER)
            if type_convs:has(rawtn) or type_convs:has(rawptn) then
                return
            end
        end

        if OLUA_VERBOSE then
            type_not_found:push(olua.format([[
                => ${entry.type} (${entry.kind})
                        from: ${entry.from}
            ]]))
        elseif not filter[entry.type] then
            filter[entry.type] = true
            type_not_found:push(olua.format([[
                => ${entry.type} (${entry.kind})
            ]]))
        end
    end)

    if #class_not_found > 0 then
        print('')
        print(olua.format([[
            class not configured:
                ${class_not_found}
            you should do:
                * add include header file in your config file or check the class name
        ]]))
    end

    if #supercls_not_found > 0 then
        print('')
        print(olua.format([[
            super class not configured:
                ${supercls_not_found}
            you should do one of:
                * add in config file: typeconf 'MissedSuperClass'
                * set in build file: OLUA_AUTO_EXPORT_PARENT = true
        ]]))
    end

    if #type_not_found > 0 then
        print('')
        print(olua.format([[
            type info not found:
                ${type_not_found}
            you should do one of:
                * if has the type convertor, use typedef 'NotFoundType'
                * if type is pointer or enum, use typeconf 'NotFoundType'
                * if type not wanted, use excludetype 'NotFoundType' or .exclude 'MethodName'
            more debug info set 'OLUA_VERBOSE = true'
        ]]))
    end

    if #class_not_found > 0
        or #supercls_not_found > 0
        or #type_not_found > 0
    then
        print('')
        error('You should fix above errors!')
    end
end

local function copy_super_funcs()
    ---@param cls TypeconfDescriptor
    ---@param super TypeconfDescriptor
    local function copy_funcs(cls, super)
        local rawsuper = raw_typename(super.cppcls)
        for _, func in ipairs(super.funcs) do
            if func.name == '__gc' then
                goto continue
            end
            if func.body then
                if not cls.funcs:has(func.name) and not cls.excludes:has(func.name) then
                    cls.funcs:set(func.name, setmetatable({}, { __index = func }))
                end
            else
                if not cls.funcs:has(func.prototype)
                    and not func.isctor
                    and not cls.excludes:has(func.display_name)
                then
                    cls.funcs:set(func.prototype, setmetatable({
                        decl = olua.format('@copyfrom(${rawsuper}) ${func.decl}')
                    }, { __index = func }))
                end
            end
            ::continue::
        end
    end

    ---@param cls TypeconfDescriptor
    ---@param super TypeconfDescriptor
    local function copy_vars(cls, super)
        local rawsuper = raw_typename(super.cppcls)
        for _, var in ipairs(super.vars) do
            if not cls.vars:has(var.name)
                and not cls.excludes:has(var.name)
            then
                cls.vars:set(var.name, setmetatable({
                    body = olua.format('@copyfrom(${rawsuper}) ${var.body}')
                }, { __index = var }))
            end
        end
    end

    ---@param cls TypeconfDescriptor
    ---@param super TypeconfDescriptor
    local function copy_props(cls, super)
        local rawsuper = raw_typename(super.cppcls)
        for _, prop in ipairs(super.props) do
            if not cls.excludes:has(prop.name) and not cls.props:has(prop.name) then
                local get = prop.get
                local set = prop.set
                if get and not get:find('{') then
                    get = olua.format('@copyfrom(${rawsuper}) ${get}')
                end
                if set and not set:find('{') then
                    set = olua.format('@copyfrom(${rawsuper}) ${set}')
                end
                cls.props:set(prop.name, { name = prop.name, get = get, set = set })
            end
        end
    end

    ---@param cls TypeconfDescriptor
    ---@param super TypeconfDescriptor
    local function copy_super(cls, super)
        copy_props(cls, super)
        copy_vars(cls, super)
        copy_funcs(cls, super)

        for _, sc in ipairs(super.supers) do
            copy_super(cls, visited_types:get(sc))
        end
    end

    for _, m in ipairs(modules) do
        ---@cast m ModuleDescriptor
        for _, cls in ipairs(m.class_types) do
            ---@cast cls TypeconfDescriptor
            for _, supercls in ipairs(cls.supers) do
                if cls.supercls == supercls then
                    goto continue
                end
                ---@type TypeconfDescriptor
                local super = visited_types:get(supercls)
                copy_super(cls, super)
                if #cls.supers == 1 and olua.is_templdate_type(super.cppcls) then
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
    for _, m in ipairs(modules) do
        ---@cast m ModuleDescriptor
        for _, cls in ipairs(m.class_types) do
            -- find as
            local ascls_map = olua.ordered_map()
            ---@cast cls TypeconfDescriptor
            if #cls.supers > 1 then
                local function find_as_cls(c)
                    for supercls in pairs(c.supers) do
                        ascls_map:replace(supercls, supercls)
                        find_as_cls(visited_types:get(supercls))
                    end
                end
                find_as_cls(cls)

                -- remove first super class
                local function remove_first_as_cls(c)
                    local supercls = c.supercls
                    if supercls then
                        local rawsuper = raw_typename(supercls, KEEP_POINTER)
                        ascls_map:take(rawsuper)
                        remove_first_as_cls(visited_types:get(supercls))
                    end
                end
                remove_first_as_cls(cls)
            end
            local ascls_arr = ascls_map:toarray()
            if #ascls_arr > 0 then
                ascls_arr:sort()
                local ascls_str = ascls_arr:join(' ')
                cls.funcs:set('as', {
                    name = 'as',
                    luaname = 'nil',
                    decl = olua.format('@as(${ascls_str}) void *as(const char *cls)')
                })
            end
        end
    end
end

local function validate_fromtable()
    for _, m in ipairs(modules) do
        for _, cls in ipairs(m.class_types) do
            local options = cls.options
            local has_var = false
            for _, var in ipairs(cls.vars) do
                if not var.body:find('static ') then
                    has_var = true
                end
            end
            if not has_var then
                options.fromtable = false
            end

            if options.fromtable then
                local has_ctor = false
                local min_args = math.maxinteger
                for _, func in ipairs(cls.funcs) do
                    if func.isctor then
                        has_ctor = true
                        min_args = math.min(min_args, func.min_args)
                    end
                end
                if has_ctor then
                    options.fromtable = min_args == 0
                end
            end

            options.fromtable = options.fromtable or nil
            options.reg_luatype = options.reg_luatype or nil
        end
    end
end

local function parse_modules()
    parse_headers()
    parse_types()
    check_errors()
    copy_super_funcs()
    find_as()
    validate_fromtable()

    for _, m in ipairs(modules) do
        write_module(m)
    end
end

local function write_ignored_types()
    local file = assert(io.open('autobuild/ignore-types.log', 'w'))
    local ignored_types = {}
    for cppcls, cur in pairs(type_cursors) do
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
            ignored_types[#ignored_types+1] = cppcls
        end
    end
    table.sort(ignored_types)
    for _, cls in pairs(ignored_types) do
        file:write(string.format('[ignore class] %s\n', cls))
    end
end

local function write_typedefs()
    local types = olua.array()
    local typedefs = olua.array():set_joiner('\n')

    typedefs:push("-- AUTO BUILD, DON'T MODIFY!\n")

    for _, m in ipairs(modules) do
        olua.ipairs(m.typedef_types, function (_, td)
            if td.packable then
                olua.assert(td.packvars, [[
                    no 'packvars' for packable type '${td.cppcls}'
                ]])
            end
            local filename = m.filename
            local cls = visited_types:get(raw_typename(td.cppcls))
            if cls and has_type_flag(cls, kFLAG_POINTER) then
                return
            end
            typedefs:push(olua.format([[
                typedef {
                    from = 'module: ${filename}.lua -> typedef "${td.cppcls}"',
                    cppcls = '${td.cppcls}',
                    luacls = ${td.luacls??},
                    luatype = ${td.luatype??},
                    conv = '${td.conv}',
                    packable = ${td.packable??},
                    packvars = ${td.packvars??},
                    smartptr = ${td.smartptr??},
                    replace = ${td.replace??},
                }
            ]]))
            typedefs:push('')
        end)

        olua.ipairs(m.class_types, function (_, cls)
            if cls.maincls then
                return
            end

            local packvars
            local filename = m.filename
            if has_type_flag(cls, kFLAG_POINTER) and cls.options.packable then
                packvars = cls.options.packvars or #cls.vars
            end
            typedefs:push(olua.format([[
                typedef {
                    from = 'module: ${filename}.lua -> typeconf "${cls.cppcls}"',
                    cppcls = '${cls.cppcls}',
                    luacls = ${cls.luacls??},
                    supercls = ${cls.supercls??},
                    funcdecl = ${cls.funcdecl??},
                    conv = '${cls.conv}',
                    packable = ${cls.options.packable??},
                    packvars = ${packvars??},
                }
            ]]))
            typedefs:push('')
        end)
    end

    olua.pairs(alias_types, function (alias, cppcls)
        if visited_types:get(raw_typename(alias)) then
            return
        end
        local cls = visited_types:get(raw_typename(cppcls))
        local from = olua.format('alias: ${alias} -> ${cppcls}')
        if not cls then
            local ti = assert(type_convs:get(cppcls) or olua.typeinfo(cppcls))
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
                funcdecl = cls.funcdecl,
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
                conv = 'olua_$$_object'
            })
        end
    end)

    for i, v in ipairs(olua.sort(types, 'cppcls')) do
        typedefs:push(olua.format([[
            typedef {
                from = '${v.from}',
                cppcls = '${v.cppcls}',
                conv = '${v.conv}',
                luacls = ${v.luacls??},
                funcdecl = ${v.funcdecl??},
                packable = ${v.packable??},
                packvars = ${v.packvars??},
            }
        ]]))
        typedefs:push('')
    end

    olua.write('autobuild/typedefs.idl', table.concat(typedefs, '\n'))
end

local function write_makefile()
    local class_files = olua.array():set_joiner('\n')
    for _, v in ipairs(modules) do
        class_files:push(olua.format('export "${v.class_file}"'))
    end
    olua.write('autobuild/make.lua', olua.format([[
        require "init"

        dofile "autobuild/typedefs.idl"

        ${class_files}
    ]]))
end

local function deferred_autoconf()
    parse_modules()
    write_ignored_types()
    write_typedefs()
    write_makefile()

    if OLUA_AUTO_BUILD ~= false then
        dofile('autobuild/make.lua')
    end
end

-------------------------------------------------------------------------------
-- define config module
-------------------------------------------------------------------------------
local function checkstr(key, v)
    if type(v) ~= 'string' then
        v = type(v)
        olua.error("command '${key}' expect 'string', got '${v}'")
    end
    return v
end

local function tonum(key, v)
    return tonumber(v)
end

local function checkfunc(key, v)
    if type(v) ~= 'function' then
        v = type(v)
        olua.error("command '${key}' expect 'function', got '${v}'")
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
    local funcs = { ... }
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

---@param CMD any
---@param name any
---@param cls TypeconfDescriptor
local function add_attr_command(CMD, name, cls)
    local entry = {}
    cls.attrs:set(name, entry)
    add_value_command(CMD, 'optional', entry, nil, tobool)
    add_value_command(CMD, 'readonly', entry, nil, tobool)
    add_value_command(CMD, 'ret', entry)
    for i = 1, 25 do
        add_value_command(CMD, 'arg' .. i, entry)
    end
end

---@param CMD any
---@param name any
---@param cls TypeconfDescriptor
local function add_insert_command(CMD, name, cls)
    local entry = { name = name }
    cls.inserts:set(name, entry)
    add_value_command(CMD, 'insert_before', entry, 'before')
    add_value_command(CMD, 'insert_after', entry, 'after')
    add_value_command(CMD, 'insert_cbefore', entry, 'cbefore')
    add_value_command(CMD, 'insert_cafter', entry, 'cafter')
end

---@param cls TypeconfDescriptor
---@param ModuleCMD any
---@return table
local function make_typeconf_command(cls, ModuleCMD)
    local CMD = {}
    local macro = nil
    local mode = nil

    add_value_command(CMD, 'chunk', cls)
    add_value_command(CMD, 'luaname', cls, nil, checkfunc)
    add_value_command(CMD, 'supercls', cls)
    add_value_command(CMD, 'luaopen', cls)
    add_value_command(CMD, 'indexerror', cls.options)
    add_value_command(CMD, 'fromtable', cls.options, nil, tobool)
    add_value_command(CMD, 'packable', cls.options, nil, tobool)
    add_value_command(CMD, 'packvars', cls.options, nil, tonum)
    add_value_command(CMD, '_maincls', cls, 'maincls', totable)

    function CMD.extend(extcls)
        cls.extends:set(extcls, true)
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
            cls.excludes:set(name, true)
        else
            cls.wildcards:set(name, true)
        end
    end

    function CMD.include(name)
        if mode and mode ~= 'include' then
            local cppcls = cls.cppcls
            olua.error("can't use .include and .exclude at the same time in typeconf '${cppcls}'")
        end
        mode = 'include'
        name = checkstr('include', name)
        cls.includes:set(name, true)
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
        local entry = { name = name }
        local SubCMD = {}
        name = checkstr('enum', name)
        cls.enums:set(name, entry)
        add_value_command(SubCMD, 'value', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.const(name)
        local entry = { name = name }
        local SubCMD = {}
        name = checkstr('const', name)
        cls.consts:set(name, entry)
        add_value_command(SubCMD, 'value', entry)
        add_value_command(SubCMD, 'typename', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.func(name)
        local entry = { name = name }
        local SubCMD = {}
        name = checkstr('func', name)
        cls.excludes:replace(name, true)
        if macro then
            cls.macros:set(name, { name = name, value = macro })
        end
        cls.funcs:set(name, entry)
        add_value_command(SubCMD, 'body', entry)
        add_attr_command(SubCMD, name, cls)
        add_insert_command(SubCMD, name, cls)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.callback(name)
        local entry = { name = name }
        local SubCMD = {}
        name = checkstr('callback', name)
        cls.callbacks:set(name, entry)
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
        local entry = { name = name }
        local SubCMD = {}
        name = checkstr('prop', name)
        cls.props:set(name, entry)
        add_value_command(SubCMD, 'get', entry)
        add_value_command(SubCMD, 'set', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.var(name, body)
        local entry = { name = name }
        local SubCMD = {}
        name = checkstr('var', name)
        if name ~= '*' then
            cls.excludes:replace(name, true)
            cls.vars:replace(name, entry)
            add_value_command(SubCMD, 'body', entry)
        else
            name = 'var*'
        end
        add_attr_command(SubCMD, name, cls)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.alias(name)
        local entry = { name = name }
        local SubCMD = {}
        add_value_command(SubCMD, 'to', entry, 'alias')
        cls.aliases:set(name, entry)
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
    add_value_command(CMD, 'luatype', cls)
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
        local build_func = debug.getinfo(2, 'f').func
        if debug.gethook() then
            build_func()
            deferred_autoconf()
            M.__call = function () end
            return
        else
            debug.sethook(function ()
                if debug.getinfo(2, 'f').func == build_func then
                    debug.sethook(nil)
                    deferred_autoconf()
                end
            end, 'r')
        end
    end

    local macro = nil
    local CMD = {}
    local m = {
        CMD = CMD,
        headers = '',
        class_types = olua.ordered_map(),
        wildcard_types = olua.ordered_map(),
        typedef_types = olua.ordered_map(),
        luacls = function (cppname)
            return string.gsub(cppname, '::', '.')
        end,
    }

    add_value_command(CMD, 'module', m, 'name')
    add_value_command(CMD, 'metapath', m)
    add_value_command(CMD, 'entry', m)
    add_value_command(CMD, 'path', m)
    add_value_command(CMD, 'luaopen', m)
    add_value_command(CMD, 'headers', m)
    add_value_command(CMD, 'chunk', m)
    add_value_command(CMD, 'luacls', m, nil, checkfunc)

    function CMD.excludetype(tn)
        exclude_types:replace(olua.pretty_typename(tn), true)
        exclude_types:replace(olua.pretty_typename(tn .. ' *'), true)
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

    ---@alias typeconf fun(cppcls: string):table
    function CMD.typeconf(cppcls)
        local cls = {
            cppcls = assert(cppcls, 'not specify cppcls'),
            luacls = m.luacls(cppcls),
            extends = olua.ordered_map(),
            excludes = olua.ordered_map(),
            wildcards = olua.ordered_map(), -- exclude wildcards
            includes = olua.ordered_map(),
            usings = olua.ordered_map(),
            attrs = olua.ordered_map(),
            enums = olua.ordered_map(),
            consts = olua.ordered_map(),
            funcs = olua.ordered_map(),
            callbacks = olua.ordered_map(),
            props = olua.ordered_map(),
            vars = olua.ordered_map(),
            aliases = olua.ordered_map(),
            inserts = olua.ordered_map(),
            macros = olua.ordered_map(),
            supers = olua.ordered_map(),
            funcdecl = nil,
            comment = nil,
            conv = 'olua_$$_object',
            options = { reg_luatype = true, fromtable = true },
            template_types = olua.ordered_map(),
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
            m.wildcard_types:set(cppcls, cls)
        else
            m.class_types:set(cppcls, cls)
        end
        if macro then
            cls.macros:set('*', { name = '*', value = macro })
        end
        type_convs:set(cppcls, cls)
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
            local t = setmetatable({ cppcls = c }, { __index = cls })
            m.typedef_types:set(c, t)
            type_convs:set(c, t)
        end
        return make_typedef_command(cls)
    end

    function CMD._typecopy(cppcls, fromcls)
        CMD.typeconf(cppcls)
        local cls = m.class_types:get(cppcls)
        for k, v in pairs(fromcls) do
            if k == 'cppcls' or k == 'luacls' then
                goto continue
            end
            if type(v) == 'table' then
                if v.clone then
                    cls[k] = v:clone()
                else
                    cls[k] = olua.clone(v)
                end
            else
                cls[k] = v
            end

            ::continue::
        end
    end

    function CMD.clang(args)
        clang_args = args
        m = nil
    end

    assert(loadfile(path, nil, setmetatable({}, {
        __index = function (_, k)
            return CMD[k] or _ENV[k]
        end,
        __newindex = function (_, k)
            olua.error("create command '${k}' is not available")
        end
    })))()

    if m and m.name then
        m.file = path
        m.filename = path:match('([^/\\]+).lua$')
        modules:set(m.name, m)
    end
end

olua.autoconf = setmetatable({}, M)
