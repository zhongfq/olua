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

local format = olua.format
local clang_tu

local type_cursors = olua.newhash(true)
local exclude_types = olua.newhash(true)
local visited_types = olua.newhash(true)
local alias_types = olua.newhash(true)
local type_convs = olua.newhash(true)
local module_files = olua.newarray()
local logfile = io.open('autobuild/autoconf.log', 'w')
local deferred = {clang_args = {}, modules = olua.newarray()}
local metamethod = {
    __index = true, __newindex = true,
    __gc = true, __pairs = true, __len = true, __eq = true, __tostring = true,
    __add = true, __sub = true, __mul = true, __mod = true, __pow = true,
    __div = true, __idiv = true,
    __band = true, __bor = true, __bxor = true, __shl = true, __shr = true,
    __unm = true, __bnot = true, __lt = true, __le = true,
    __concat = true, __call = true, __close = true
}

local kFLAG_POINTEE = 1 << 1     -- pointee type
local kFLAG_ENUM = 1 << 2        -- enum type
local kFLAG_ALIAS = 1 << 3       -- alias type
local kFLAG_CONV = 1 << 4        -- conv type
local kFLAG_FUNC = 1 << 5        -- function type
local kFLAG_STRUCT = 1 << 6      -- struct type
local kFLAG_TEMPLATE = 1 << 7    -- template type

local KEEP_POINTER = true

local function has_kflag(cls, kind)
    return ((cls.kind or 0) & kind) ~= 0
end

local function log(fmt, ...)
    logfile:write(string.format(fmt, ...))
    logfile:write('\n')
end

local function is_templdate_type(cppcls)
    return cppcls:find('<')
end

local function create_conv_func(cppcls)
    return 'olua_$$_' .. string.gsub(cppcls, '::', '_')
end

local function raw_type(cppcls, keep_pointer)
    local from, to = cppcls:find('^const ')
    if from then
        cppcls = cppcls:sub(to + 1)
    end
    if keep_pointer and cppcls:find('%*$') then
        return cppcls:gsub('<.*>', '')
    elseif cppcls:find('^struct ') then
        return cppcls:match('^struct [^< ]+')
    elseif cppcls:find('^enum ') then
        return cppcls:match('^enum [^< ]+')
    else
        return cppcls:match('[^< ]+')
    end
end

local function add_type_conv_func(cls)
    if not cls.includes then
        -- typedef type
        if not cls.conv then
            if cls.decltype then
                local ti = olua.typeinfo(cls.decltype, nil, true)
                if not ti then
                    olua.error("decltype '${cls.decltype}' for '${cls.cppcls}' is not found")
                end
                cls.conv = ti.conv
            else
                cls.conv = create_conv_func(cls.cppcls)
            end
        end
        for cppcls in string.gmatch(cls.cppcls, '[^ ;]+') do
            type_convs:replace(cppcls, cls.conv)
        end
    elseif has_kflag(cls, kFLAG_CONV) then
        type_convs:replace(cls.cppcls, create_conv_func(cls.cppcls))
    else
        type_convs:replace(cls.cppcls, true)
    end
end

local function parse_from_ast(type)
    local cur = type.declaration
    if cur.kind == CursorKind.NoDeclFound then
        return type.name
    end

    local exps = olua.newarray('::')
    while cur and cur.kind ~= CursorKind.TranslationUnit do
        local value = raw_type(cur.name)
        if cur.isInlineNamespace then
            cur = cur.parent
        elseif value then
            exps:insert(value)
            cur = cur.parent
        else
            break
        end
    end
    return tostring(exps)
end

local typename

local function parse_from_type(type, template_types, try_underlying)
    local kind = type.kind
    local name = type.name
    local template_arg_types = type.templateArgumentTypes
    local decl = type.declaration
    local underlying = decl.underlyingType
    local pointee = type.pointeeType
    if #template_arg_types > 0 and (not try_underlying or not underlying) then
        local exps = olua.newarray('')
        local astname = parse_from_ast(type)
        exps:push(type.isConstQualified and 'const ' or nil)
        exps:push(astname)
        if is_templdate_type(name) then
            exps:push('<')
            for i, v in ipairs(template_arg_types) do
                exps:push(i > 1 and ', ' or nil)
                exps:push(typename(v, template_types))
            end
            exps:push('>')
        end
        return tostring(exps)
    elseif kind == TypeKind.LValueReference then
        return parse_from_type(pointee, template_types, try_underlying) .. ' &'
    elseif kind == TypeKind.RValueReference then
        return parse_from_type(pointee, template_types, try_underlying) .. ' &&'
    elseif kind == TypeKind.Pointer and pointee.kind == TypeKind.Pointer then
        return parse_from_type(pointee, template_types, try_underlying) .. '*'
    elseif kind == TypeKind.Pointer then
        return parse_from_type(pointee, template_types, try_underlying) .. ' *'
    elseif kind == TypeKind.FunctionProto then
        local exps = olua.newarray('')
        local result_type = parse_from_type(type.resultType)
        exps:push(result_type)
        exps:push(result_type:find('[%*&]') and '' or ' ')
        exps:push('(')
        for i, v in ipairs(type.argTypes) do
            exps:push(i > 1 and ', ' or nil)
            exps:push(parse_from_type(v))
        end
        exps:push(')')
        return tostring(exps)
    elseif try_underlying and underlying then
        local const = name:match('^const ') or ''
        return const .. parse_from_type(underlying, template_types)
    elseif template_types and template_types:has(name) then
        return template_types:get(name)
    elseif kind >= TypeKind.FirstBuiltin and kind <= TypeKind.LastBuiltin then
        return name
    elseif kind == TypeKind.Typedef or kind == TypeKind.Unexposed then
        return name
    else
        --[[
            name: size_t
             raw: size_t
             ast: size_t

            name: const std::string::size_type
             raw: std::string::size_type
             ast: std::basic_string::size_type

            name: enum EventType
             raw: EventType
             ast: olua::test::EventType
        ]]
        local rawtype = name:match('[^ ]+$')
        local astname = parse_from_ast(type)
        if name == astname or not olua.is_end_with(astname, rawtype) then
            return name
        else
            return name:gsub('[^ ]+$', astname)
        end
    end
end

local function check_alias_typename(tn, underlying)
    local rawtn = raw_type(tn)
    local raw_underlying = raw_type(underlying)
    local has_conv = type_convs:has(raw_underlying)
    local has_ti = olua.typeinfo(raw_underlying, nil, true)
    if has_conv or (has_ti and not is_templdate_type(underlying)) then
        alias_types:replace(rawtn, raw_underlying)
        return tn, true
    elseif has_ti then
        return underlying, true
    else
        return tn, false
    end
end

function typename(type, template_types)
    local tn = parse_from_type(type, template_types)
    local rawtn = raw_type(tn, KEEP_POINTER)

    if exclude_types:has(rawtn) then
        return tn
    end

    rawtn = raw_type(tn)
    if not type_convs:has(rawtn) and not olua.typeinfo(rawtn, nil, true) then
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
        local alias = parse_from_type(type, template_types, true)
        tn, valid = check_alias_typename(tn, alias)
        if not valid then
            alias = type.canonicalType.name
            tn = check_alias_typename(tn, alias)
        end
    end
    return tn
end

local function is_excluded_typename(name)
    if exclude_types:has(name) then
        return true
    elseif name:find('<') then
        return is_excluded_typename(name:gsub('<.*>', ''))
    end
end

local function is_excluded_type(type)
    if type.kind == TypeKind.IncompleteArray then
        return true
    end

    local tn = typename(type)
    local rawtn = raw_type(tn, KEEP_POINTER)
    if is_templdate_type(rawtn) then
        for _, subtype in ipairs(type.templateArgumentTypes) do
            if is_excluded_type(subtype) then
                return true
            end
        end
    end
    return is_excluded_typename(rawtn)
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
        if c.kind == CursorKind.AnnotateAttr and c.name == '@exclude' then
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
        if kind == TypeKind.LValueReference or kind == TypeKind.RValueReference then
            return is_func_type(tn.pointeeType)
        elseif cur.kind == CursorKind.TypedefDecl or cur.kind == CursorKind.TypeAliasDecl then
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
    return setmetatable({}, {__index = (attrs:get(fn) or attrs:get(wildcard or '*') or {})})
end

local M = {}

function M:parse()
    assert(not self.class_file)
    assert(not self.type_file)
    local filename = self.name:gsub('_', '-')
    self.class_file = format('autobuild/autogen-${filename}.lua')
    self.type_file = format('autobuild/autogen-${filename}-types.lua')

    module_files:push(self)

    -- scan method, variable, enum, const value
    for _, cls in ipairs(self.class_types:clone()) do
        local cur = type_cursors:get(cls.cppcls)
        olua.assert(cur, [[
            cursor not found for class '${cls.cppcls}'
        ]])
        self:visit(cur, cls.cppcls)
    end

    -- check class
    for _, cls in ipairs(self.class_types) do
        if not visited_types:has(cls.cppcls) then
            olua.error([[
                class not found: ${cls.cppcls}
                    * add include header file in your config file or check the class name
            ]])
        end
        for _, supercls in ipairs(cls.supers) do
            if not visited_types:has(supercls) then
                olua.error([[
                    super class not configured: ${cls.cppcls} -> ${supercls}
                    you should do one of:
                        * add in config file: typeconf '${supercls}'
                        * set in build file: OLUA_AUTO_EXPORT_PARENT = true
                ]])
            end
        end
    end
end

function M:visit_method(cls, cur)
    if cur.isVariadic
        or cur.isCXXCopyConstructor
        or cur.isCXXMoveConstructor
        or cur.name:find('operator *[%-=+/*><!()]?')
        or cur.name == 'as'  -- 'as used to cast object'
        or has_deprecated_attr(cur)
        or is_excluded_type(cur.resultType)
        or has_exclude_attr(cur)
    then
        return
    end

    local fn = cur.name
    local luaname = fn
    local attr = get_attr_copy(cls, fn)
    local callback = cls.callbacks:get(fn) or {}
    local static = cur.isCXXMethoStatic
    local declexps = olua.newarray('')
    local protoexps = olua.newarray('')

    parse_attr_from_annotate(attr, cur)
    
    for i, arg in ipairs(cur.arguments) do
        local v = (attr['arg' .. i]) or ''
        if not v:find('@ret') and is_excluded_type(arg.type) then
            return
        end
    end

    declexps:push(attr.ret and (attr.ret .. ' ') or nil)
    declexps:push(static and 'static ' or nil)

    local cb_kind

    if cur.kind ~= CursorKind.Constructor then
        local tn = typename(cur.resultType, cls.template_types)
        if is_func_type(cur.resultType) then
            cb_kind = 'ret'
            if callback.localvar ~= false then
                declexps:push('@localvar ')
            end
        end
        local tn_decl = tn .. olua.typespace(tn)
        declexps:push(tn_decl)
        protoexps:push(tn_decl)
        luaname = cls.luaname(fn, 'func')
    end

    local optional = false
    local min_args = 0
    local num_args = 0
    declexps:push(fn .. '(')
    protoexps:push(fn .. '(')
    for i, arg in ipairs(cur.arguments) do
        local tn = typename(arg.type, cls.template_types)
        local display_name = cur.displayName
        local argn = 'arg' .. i
        num_args = num_args + 1
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
            assert(not cb_kind, cls.cppcls .. '::' .. display_name)
            cb_kind = 'arg'
            if callback.localvar ~= false then
                declexps:push('@localvar ')
            end
        end
        if has_default_value(arg) and not string.find(attr[argn] or '', '@ret') then
            declexps:push('@optional ')
            optional = true
        else
            min_args = min_args + 1
            assert(not optional, cls.cppcls .. '::' .. display_name)
        end
        declexps:push(attr[argn] and (attr[argn] .. ' ') or nil)
        declexps:push(tn)
        declexps:push(olua.typespace(tn))
        declexps:push(arg.name)
    end
    declexps:push(')')
    protoexps:push(')')

    local decl = tostring(declexps)
    local prototype =  tostring(protoexps)
    cls.excludes:replace(cur.displayName, true)
    cls.excludes:replace(prototype, true)
    if cur.kind == CursorKind.FunctionDecl then
        decl = 'static ' .. decl
        static = true
    end
    if decl:find('@getter') then
        if num_args == 0 then
            cls.props:push(fn, {
                name = fn,
                get = decl,
            })
            return
        else
            olua.print([[
                ignore getter '${fn}', because function has argument
                    prototype: ${decl}
            ]])
        end
    end
    cls.funcs:push(prototype, {
        decl = decl,
        luaname = luaname == fn and 'nil' or olua.stringify(luaname),
        name = fn,
        static = static,
        num_args = num_args,
        min_args = min_args,
        cb_kind = cb_kind,
        prototype = prototype,
        display_name = cur.displayName,
        isctor = cur.kind == CursorKind.Constructor,
    })
end

function M:visit_var(cls, cur)
    if cur.type.isConstQualified
        or is_excluded_type(cur.type)
        or has_exclude_attr(cur)
        or has_deprecated_attr(cur)
    then
        return
    end

    local exps = olua.newarray('')
    local attr = get_attr_copy(cls, cur.name, 'var*')
    local tn = typename(cur.type, cls.template_types)
    local cb_kind

    if tn:find('%[') then
        return
    end

    parse_attr_from_annotate(attr, cur, true)

    if attr.readonly then
        exps:push('@readonly ')
    end

    local length = string.match(tn, '%[(%d+)%]$')
    if length then
        exps:pushf('@array(${length})')
        exps:push(' ')
        tn = string.gsub(tn, ' %[%d+%]$', '')
    elseif attr.optional or (has_default_value(cur) and attr.optional == nil) then
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
    exps:push(tn)
    exps:push(olua.typespace(tn))
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
    cls.indexerror = 'rw'
    cls.kind = cls.kind or kFLAG_ENUM
end

function M:visit_alias_class(alias, cppcls)
    local cls = self:will_visit(alias)
    cls.kind = cls.kind or kFLAG_POINTEE
    if is_func_type(cppcls) then
        cls.kind = cls.kind | kFLAG_FUNC
        cls.decltype = cppcls
        cls.luacls = self.luacls(alias)
    else
        cls.kind = cls.kind | kFLAG_ALIAS
        cls.supercls = cppcls
        cls.luacls = self.luacls(cppcls)
    end
end

function M:visit_class(cppcls, cur, template_types)
    local cls = self:will_visit(cppcls)
    local skipsuper = false

    cls.kind = cls.kind or kFLAG_POINTEE

    if cur.kind == CursorKind.ClassTemplate then
        olua.assert(template_types, [[
            don't config template class:
                you should remove: typeconf '${cls.cppcls}'
        ]])
        cls.kind = cls.kind | kFLAG_TEMPLATE
    elseif cur.kind == CursorKind.StructDecl then
        cls.kind = cls.kind | kFLAG_STRUCT
    elseif cur.kind == CursorKind.Namespace then
        cls.reg_luatype = false
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
            local supercls = typename(c.type)
            local rawsupercls = raw_type(supercls)
            local supercursor = type_cursors:get(rawsupercls)

            if is_excluded_typename(rawsupercls)
                or is_excluded_typename(rawsupercls .. ' *')
            then
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
            local vn = c.name
            local ct = c.type
            local mode = #cls.includes > 0 and 'include' or 'exclude'
            if not OLUA_ENABLE_WITH_UNDERSCORE
                and c.name:find('^_')
                and not metamethod[c.name]
            then
                goto continue
            end
            if (mode == 'include' and not cls.includes:has(vn))
                or (cls.excludes:has('*') or cls.excludes:has(vn))
            then
                goto continue
            end
            if ct.isConstQualified and kind == CursorKind.VarDecl then
                if not is_excluded_type(ct) then
                    cls.consts:push(vn, {name = vn, typename = ct.name})
                end
            else
                self:visit_var(cls, c)
            end
        elseif kind == CursorKind.Constructor
            or kind == CursorKind.FunctionDecl
            or kind == CursorKind.CXXMethod
        then
            local mode = #cls.includes > 0 and 'include' or 'exclude'
            if not OLUA_ENABLE_WITH_UNDERSCORE
                and c.name:find('^_')
                and not metamethod[c.name]
            then
                goto continue
            end
            if (mode == 'include' and not cls.includes:has(c.name))
                or cls.excludes:has('*')
                or cls.excludes:has(c.name)
                or cls.excludes:has(c.displayName)
                or (kind == CursorKind.Constructor and
                    (cls.excludes:has('new') or cur.isCXXMethoAbstract))
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
            self:visit(cur.underlyingType.declaration, cppcls)
        end
    end
end

local function try_add_wildcard_type(cppcls)
    for _, m in ipairs(deferred.modules) do
        if not m.class_types:has(cppcls) then
            for type, conf in pairs(m.wildcard_types) do
                if cppcls:find(type) then
                    m.CMD._typefrom(cppcls, conf)
                end
            end
        end
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
            try_add_wildcard_type(cppcls)
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
            try_add_wildcard_type(cppcls)
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
    append(format('chunk = ${module.chunk?}'))
    append(format('luaopen = ${module.luaopen?}'))
    append('')

    for _, cls in ipairs(module.class_types) do
        if not has_kflag(cls, kFLAG_CONV) then
            goto continue
        end

        local macro = (cls.macros:get('*') or {}).value
        append(format([[typeconv '${cls.cppcls}']]))
        append(format([[.export(${cls.export})]], 4))
        for _, v in ipairs(cls.macros) do
            append(format([[.macro('${v.name}', '${v.value}')]], 4))
        end
        for _, v in ipairs(cls.vars) do
            append(format('.var(${v.name?}, ${v.snippet?})', 4))
        end
        append('')

        ::continue::
    end
end

local function write_module_typedef(module)
    local t = olua.newarray('\n')

    local function writeLine(fmt, ...)
        t:push(string.format(fmt, ...))
    end

    writeLine("-- AUTO BUILD, DON'T MODIFY!")
    writeLine('')
    for _, td in ipairs(module.typedef_types) do
        local arr = {}
        for k, v in pairs(td) do
            arr[#arr + 1] = {k, v}
        end
        table.sort(arr, function (a, b) return a[1] < b[1] end)
        writeLine("typedef {")
        for _, p in ipairs(arr) do
            local key, value = p[1], p[2]
            writeLine(format('${key} = ${value?},', 4))
        end
        writeLine("}")
        writeLine("")
    end

    for _, cls in ipairs(module.class_types) do
        if cls.maincls then
            goto continue
        end

        local conv
        local cppcls = cls.cppcls
        local supercls =  'nil'
        local decltype, luacls, num_vars = 'nil', 'nil', 'nil'

        if cls.supercls then
            supercls = olua.stringify(cls.supercls, "'")
        end
        if has_kflag(cls, kFLAG_FUNC) then
            luacls = olua.stringify(cls.luacls, "'")
            decltype = olua.stringify(cls.decltype, "'")
            conv = 'olua_$$_callback'
        elseif has_kflag(cls, kFLAG_ENUM) then
            conv = 'olua_$$_uint'
            luacls = olua.stringify(cls.luacls, "'")
            decltype = olua.stringify('lua_Unsigned')
        elseif has_kflag(cls, kFLAG_POINTEE) then
            if has_kflag(cls, kFLAG_STRUCT) then
                cppcls = format('${cppcls} *; struct ${cppcls} *')
            else
                cppcls = cppcls .. ' *'
            end
            luacls = olua.stringify(cls.luacls, "'")
            conv = 'olua_$$_obj'
        elseif has_kflag(cls, kFLAG_CONV) then
            conv = 'olua_$$_' .. string.gsub(cls.cppcls, '[.:]+', '_')
            num_vars = #cls.vars
        else
            error(cls.cppcls .. ' ' .. cls.kind)
        end

        t:pushf([[
            typedef {
                cppcls = '${cppcls}',
                luacls = ${luacls},
                supercls = ${supercls},
                decltype = ${decltype},
                conv = '${conv}',
                num_vars = ${num_vars},
            }
        ]])

        if has_kflag(cls, kFLAG_POINTEE) and has_kflag(cls, kFLAG_CONV) then
            cppcls = cppcls:gsub('[ *]+', '')
            luacls = 'nil'
            conv = 'olua_$$_' .. string.gsub(cls.cppcls, '[.:]+', '_')
            num_vars =  #cls.vars
            t:pushf([[
                typedef {
                    cppcls = '${cppcls}',
                    luacls = ${luacls},
                    supercls = ${supercls},
                    decltype = ${decltype},
                    conv = '${conv}',
                    num_vars = ${num_vars},
                }
            ]])
        end

        ::continue::
    end

    olua.write(module.type_file, tostring(t))
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
        search_parent(arr, name, supercls)
        for _, func in ipairs(arr) do
            cls.funcs:push_if_not_exist(func.prototype, func)
        end
    end
end

local function write_cls_func(module, cls, append)
    search_using_func(module, cls)

    local group_by_name = olua.newhash()
    for _, func in ipairs(cls.funcs) do
        local arr = group_by_name:get(func.name)
        if not arr then
            arr = {}
            group_by_name:push(func.name, arr)
        end
        if func.snippet or is_new_func(module, cls.supercls, func) then
            arr.has_new = true
        else
            func = setmetatable({
                decl = '@using ' .. func.decl
            }, {__index = func})
        end
        arr[#arr + 1] = func
    end

    for _, arr in ipairs(group_by_name) do
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
                local rawsuper = raw_type(supercls, KEEP_POINTER)
                ascls:take(rawsuper)
                remove_first_as_cls(visited_types:get(supercls))
            end
        end
        remove_first_as_cls(cls)
     end
     if #ascls > 0 then
        table.sort(ascls.values)
        ascls = table.concat(ascls.values, ' ')
        local decl = format("'@as(${ascls}) void *as(const char *cls)'")
        append(format(".func(nil, ${decl})", 4))
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
            tag_store = olua.stringify(v.tag_store)
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
        log(format([[
            funcs => name = '${v.name}'
                    funcs = {
                        ${funcs}
                    }
                    tag_maker = ${tag_maker}
                    tag_mode = ${tag_mode}
                    tag_store = ${tag_store}
                    tag_scope = ${tag_scope}
        ]], 4))
    end
end

local function write_cls_insert(module, cls, append)
    for _, v in ipairs(cls.inserts) do
        if v.before or v.after or v.cbefore or v.cafter then
            append(format([[
                .insert('${v.name}', {
                    before = ${v.before?},
                    after = ${v.after?},
                    cbefore = ${v.cbefore?},
                    cafter = ${v.cafter?},
                })
            ]], 4))
        end
    end
end

local function write_cls_alias(module, cls, append)
    for _, v in ipairs(cls.aliases) do
        append(format(".alias('${v.name}', '${v.alias}')", 4))
    end
end

local function copy_super_funcs(cls, super)
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
                    decl = format("@copyfrom(${super.cppcls}) ${func.decl}")
                }, {__index = func}))
            end
        end
        ::continue::
    end
    for _, sc in ipairs(super.supers) do
        copy_super_funcs(cls, visited_types:get(sc))
    end
end

local function copy_super_var(cls, super)
    for _, var in ipairs(super.vars) do
        if not cls.vars:has(var.name)
            and not cls.excludes:has(var.name)
        then
            cls.vars:push(var.name, setmetatable({
                snippet = format("@copyfrom(${super.cppcls}) ${var.snippet}")
            }, {__index = var}))
        end
    end
    for _, sc in ipairs(super.supers) do
        copy_super_var(cls, visited_types:get(sc))
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
        for _, supercls in ipairs(cls.supers) do
            if cls.supercls == supercls then
                goto continue
            end
            local super = visited_types:get(supercls)
            copy_super_funcs(cls, super)
            copy_super_var(cls, super)
            ::continue::
        end
    end
    for _, cls in ipairs(module.class_types) do
        if (has_kflag(cls, kFLAG_CONV) and not has_kflag(cls, kFLAG_POINTEE))
            or has_kflag(cls, kFLAG_ALIAS)
            or cls.maincls
        then
            goto continue
        end

        log("[%s]", cls.cppcls)
        append(format([[
            typeconf '${cls.cppcls}'
                .supercls(${cls.supercls?})
                .reg_luatype(${cls.reg_luatype?})
                .chunk(${cls.chunk?})
                .luaopen(${cls.luaopen?})
                .indexerror(${cls.indexerror?})
        ]]))

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

    append(format([[
        -- AUTO BUILD, DON'T MODIFY!

        dofile "${module.type_file}"
    ]]))
    append('')

    write_module_metadata(module, append)
    write_module_classes(module, append)
    write_module_typedef(module, append)

    olua.write(module.class_file, tostring(t))
end

local function parse_modules()
    local headers = olua.newarray('\n')
    for _, m in ipairs(deferred.modules) do
        headers:push(m.headers)
    end

    do
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
        clang_tu = clang.createIndex(false, true):parse(HEADER_PATH, flags)
        for _, v in ipairs(clang_tu.diagnostics) do
            if v.severity == DiagnosticSeverity.Error
                or v.severity == DiagnosticSeverity.Fatal
            then
                error('parse header error')
            end
        end
        prepare_cursor(clang_tu.cursor)
        os.remove(HEADER_PATH)
    end

    for _, m in ipairs(deferred.modules) do
        for _, cls in ipairs(m.typedef_types) do
            add_type_conv_func(cls)
        end
        for _, cls in ipairs(m.class_types) do
            add_type_conv_func(cls)
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
        write_module(m)
    end
end

local function write_ignored_types()
    local file = io.open('autobuild/autoconf-ignore.log', 'w')
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

local function write_alias_types()
    local types = olua.newarray('\n')
    for alias, cppcls in pairs(alias_types) do
        if visited_types:get(alias) then
            goto continue
        end
        local cls = visited_types:get(cppcls)
        if not cls then
            local ti = olua.typeinfo(cppcls)
            types:push({
                cppcls = alias,
                decltype = ti.decltype,
                conv = ti.conv,
            })
        elseif has_kflag(cls, kFLAG_ENUM) then
            types:push({
                cppcls = alias,
                decltype = 'lua_Unsigned',
                conv = 'olua_$$_uint',
            })
        elseif type(type_convs:get(cppcls)) == 'string' then
            types:push({
                cppcls = alias,
                decltype = alias,
                conv = type_convs:get(cppcls),
            })
        elseif has_kflag(cls, kFLAG_STRUCT) then
            goto continue
        else
            error('TODO:' .. alias .. ' => ' .. cppcls)
        end
        ::continue::
    end
    local typedefs = olua.newarray('\n')
    for i, v in ipairs(olua.sort(types, 'cppcls')) do
        typedefs:pushf([[
            typedef {
                cppcls = '${v.cppcls}',
                decltype = '${v.decltype}',
                conv = '${v.conv}',
            }
        ]])
        typedefs:push('')
    end

    olua.write('autobuild/alias-types.lua', format([[
        ${typedefs}
    ]]))
end

local function write_makefile()
    local class_files = olua.newarray('\n')
    local type_files = olua.newarray('\n')
    type_files:push('dofile "autobuild/alias-types.lua"')
    for _, v in ipairs(module_files) do
        class_files:pushf('export "${v.class_file}"')
        type_files:pushf('dofile "${v.type_file}"')
    end
    olua.write('autobuild/make.lua', format([[
        require "olua.tools"

        ${type_files}

        ${class_files}
    ]]))
end

local function deferred_autoconf()
    parse_modules()
    write_ignored_types()
    write_alias_types()
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
    add_value_command(CMD, 'indexerror', cls)
    add_value_command(CMD, '_maincls', cls, "maincls", totable)

    if has_kflag(cls, kFLAG_CONV) then
        cls.export = false
        add_value_command(CMD, 'export', cls, nil, tobool)
    end

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
        cls.excludes:push(name, true)
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

    function CMD.alias(value)
        local name, alias = string.match(value, '([^ ]+) *-> *([^ ]+)')
        assert(name, value)
        cls.aliases:push(name, {name = name, alias = alias})
    end

    return olua.command_proxy(CMD)
end

local function make_typedef_command(cls)
    local CMD = {}
    add_value_command(CMD, 'vars', cls, 'num_vars', tonum)
    add_value_command(CMD, 'decltype', cls)
    add_value_command(CMD, 'conv', cls)
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

    function CMD.exclude(tn)
        tn = olua.pretty_typename(tn)
        exclude_types:replace(tn, true)
    end

    function CMD.include(filepath)
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

    function CMD.typeconf(classname, kind)
        local cls = {
            cppcls = assert(classname, 'not specify classname'),
            luacls = module.luacls(classname),
            extends = olua.newhash(),
            excludes = olua.newhash(),
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
            kind = kind,
            supers = olua.newhash(),
            reg_luatype = true,
            template_types = olua.newhash(),
            luaname = function (n) return n end,
        }
        local last = module.class_types:get(classname)
        if last then
            if last.kind == kind then
                olua.error('class conflict: ${classname}')
            else
                if kind == kFLAG_CONV then
                    cls = last
                end
                if not cls.kind then
                    cls.kind = kFLAG_POINTEE
                end
                cls.kind = cls.kind | kFLAG_CONV
                module.class_types:take(classname)
            end
        end
        if classname:find('[%^%%%$%*%+]') then -- ^%$*+
            module.wildcard_types:push(classname, cls)
        else
            module.class_types:push(classname, cls)
        end
        if macro then
            cls.macros:push('*', {name = '*', value = macro})
        end
        return make_typeconf_command(cls, CMD)
    end

    function CMD.typeonly(classname)
        local cls = CMD.typeconf(classname)
        cls.exclude '*'
        return cls
    end

    function CMD.typedef(classname)
        local cls = {cppcls = classname}
        module.typedef_types:push(classname, cls)
        return make_typedef_command(cls)
    end

    function CMD.typeconv(classname)
        return CMD.typeconf(classname, kFLAG_CONV)
    end

    function CMD._typefrom(classname, fromcls)
        CMD.typeconf(classname)
        local cls = module.class_types:get(classname)
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
        deferred.modules:push(module)
    end
end

olua.autoconf = setmetatable({}, M)
