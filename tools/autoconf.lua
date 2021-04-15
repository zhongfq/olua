local olua = require "olua"
local clang = require "clang"
local writer = require 'autoconf-writer'

local format = olua.format
local clang_tu

local M = {}

function M.init(path)
    local HEADER_PATH = 'autobuild/.autoconf.h'
    local clang_args = dofile(path)
    local header = io.open(HEADER_PATH, 'w')
    header:write(format [[
        #ifndef __AUTOCONF_H__
        #define __AUTOCONF_H__

        ${clang_args.HEADERS}

        #endif
    ]])
    header:close()
    local index = clang.createIndex(false, true)
    for i, v in ipairs(clang_args.FLAGS) do
        local HOMEDIR = olua.HOMEDIR
        clang_args.FLAGS[i] = format(v)
    end
    clang_tu = index:parse(HEADER_PATH, clang_args.FLAGS)
    os.remove(HEADER_PATH)
end

function M:parse(path)
    assert(not self.FILE_PATH)
    assert(not self.TYPE_FILE_PATH)
    local FILENAME = self.NAME:gsub('_', '-')
    self.FILE_PATH = format('autobuild/${FILENAME}.lua')
    self.TYPE_FILE_PATH = format('autobuild/${FILENAME}-types.lua')

    writer.module_files:push(self)

    for cls in pairs(self.EXCLUDE_TYPE) do
        writer.ignored_types[cls] = false
    end

    local function toconv(cls)
        return 'olua_$$_' .. string.gsub(cls.CPPCLS, '::', '_')
    end

    for _, v in ipairs(self.TYPEDEFS) do
        writer.type_convs[v.CPPCLS] = assert(v.CONV, 'no conv function: ' .. v.CPPCLS)
    end

    for _, cls in pairs(self.CLASSES) do
        writer.type_convs[cls.CPPCLS] = cls.KIND == 'conv' and toconv(cls) or true
    end

    self:visit(clang_tu:cursor())
    self:check_class()

    writer.write_module(self)
end

function M:has_define_class(cls)
    local name = string.match(cls.CPPCLS, '[^:]+$')
    return string.find(cls.CHUNK or '', 'class +' .. name) ~= nil
end

function M:check_class()
    for _, cls in ipairs(self.CLASSES) do
        if not writer.visited_types[cls.CPPCLS] then
            if #cls.FUNC > 0 or #cls.PROP > 0 then
                cls.KIND = 'class'
                cls.REG_LUATYPE = self:has_define_class(cls)
                writer.visited_types[cls.CPPCLS] = cls
                writer.ignored_types[cls.CPPCLS] = false
            else
                error(format([[
                    class not found: ${cls.CPPCLS}
                      *** add include header file in 'conf/clang-args.lua' or check the class name
                ]]))
            end
        end
    end
    for _, cls in ipairs(self.CLASSES) do
        if cls.SUPERCLS and not writer.visited_types[cls.SUPERCLS]then
            error(format('super class not found: ${cls.CPPCLS} -> ${cls.SUPERCLS}'))
        end
    end
end

function M:visit_enum(cur, cppcls)
    cppcls = cppcls or self:fullname(cur)
    local cls = self.CLASSES[cppcls]
    writer.visited_types[cppcls] = cls
    writer.ignored_types[cppcls] = false
    if cur:kind() ~= 'TypeAliasDecl' then
        for _, c in ipairs(cur:children()) do
            local VALUE =  c:name()
            local name = cls.MAKE_LUANAME(VALUE, 'ENUM')
            cls.ENUM[name] = {
                NAME = name,
                VALUE = format('${cls.CPPCLS}::${VALUE}'),
            }
        end
        cls.KIND = 'enum'
        writer.alias_types[cls.CPPCLS] = nil
    else
        cls.KIND = 'enumAlias'
    end
end

function M:is_excluded_typeanme(name)
    if self.EXCLUDE_TYPE[name] then
        return true
    elseif string.find(name, '<') then
        name = string.gsub(name, '<.*>', '')
        return self:is_excluded_typeanme(name)
    end
end

function M:is_excluded_type(type, cur)
    if type:kind() == 'IncompleteArray' then
        return true
    end

    local tn = cur and self:typename(type, cur) or type:name()
    -- remove const and &
    -- const T * => T *
    -- const T & => T
    local rawtn = tn:gsub('^const *', ''):gsub(' *&$', '')
    if self:is_excluded_typeanme(rawtn) then
        return true
    elseif tn ~= type:canonicalType():name() then
        return self:is_excluded_type(type:canonicalType())
    end
end

function M:fullname(cur)
    if cur:kind() == 'Namespace' then
        local ns = olua.newarray('::')
        while cur and cur:kind() ~= 'TranslationUnit' do
            ns:insert(cur:name())
            cur = cur:parent()
        end
        return tostring(ns)
    else
        return (cur:type() or cur):name()
    end
end

function M:typename(type, cur)
    local tn = type:name()
    -- remove const, & and *: const T * => T
    local rawtn = tn:match('([%w:_]+) ?[&*]?$')
    if not rawtn then
        local ftype = type:templateArgumentAsType()[1]
        if ftype and ftype:kind() == 'FunctionProto' then
            local exps = olua.newarray('')
            exps:push(tn:find('^const') and 'const ' or nil)
            exps:push('std::function<')
            exps:push(ftype:resultType():name())
            exps:push(' (')
            for i, v in ipairs(ftype:argTypes()) do
                exps:push(i > 1 and ', ' or nil)
                exps:push(v:name())
            end
            exps:push(')>')
            exps:push(tn:find('&$') and ' &' or nil)
            return tostring(exps)
        else
            return tn
        end
    end

    -- typedef std::function<void (Object *)> ClickListener
    -- const ClickListener & => const olua::ClickListener &
    for _, cu in ipairs(cur:children()) do
        if cu:kind() == 'TypeRef' then
            local typeref = cu:name():match('([^ ]+)$')
            if rawtn ~= typeref and string.find(typeref, rawtn .. '$') then
                tn = tn:gsub(rawtn, typeref)
                rawtn = typeref
                break
            end
        end
    end

    local alias = writer.alias_types[rawtn]
    if alias and not writer.type_convs[rawtn] then
        -- namespace::alias<K, V> => namespace::alias
        if olua.typeinfo(alias:gsub('<.+>', ''), nil, true) then
            -- rawtn: olua::ClickListener
            -- alias: std::function<void (Object *)>
            -- const olua::ClickListener & => const std::function<void (Object *)> &
            return string.gsub(tn, rawtn, alias)
        end
    end

    return tn
end

local DEFAULT_ARG_TYPES = {
    IntegerLiteral = true,
    FloatingLiteral = true,
    ImaginaryLiteral = true,
    StringLiteral = true,
    CharacterLiteral = true,
    CXXBoolLiteralExpr = true,
    CXXNullPtrLiteralExpr = true,
    GNUNullExpr = true,
    DeclRefExpr = true,
    CallExpr = true,
}

function M:has_default_value(cur)
    for _, c in ipairs(cur:children()) do
        if DEFAULT_ARG_TYPES[c:kind()] then
            return true
        elseif self:has_default_value(c) then
            return true
        end
    end
end

function M:has_unexposed_attr(cur)
    for _, c in ipairs(cur:children()) do
        -- attribute(deprecated) ?
        if c:kind() == 'UnexposedAttr' then
            return true
        end
    end
end

function M:is_func_type(tn)
    local rawtn = tn:match('([%w:_]+) ?[&*]?$')
    local decl = writer.alias_types[rawtn] or ''
    return tn:find('std::function') or decl:find('std::function')
end

function M:visit_method(cls, cur)
    if cur:isVariadic()
            or cur:name():find('^_')
            or cur:isCopyConstructor()
            or cur:isMoveConstructor()
            or cur:name():find('operator *[%-=+/*><!()]?')
            or self:is_excluded_type(cur:resultType(), cur)
            or self:has_unexposed_attr(cur) then
        return
    end

    local fn = cur:name()
    local attr = cls.ATTR[fn] or cls.ATTR['*'] or {}
    local callback = cls.CALLBACK[fn] or {}
    local exps = olua.newarray('')
    local declexps = olua.newarray('')

    for i, arg in ipairs(cur:arguments()) do
        local attrn = (attr['ARG' .. i]) or ''
        if not attrn:find('@out') and self:is_excluded_type(arg:type(), arg) then
            return
        end
    end

    exps:push(attr.RET and (attr.RET .. ' ') or nil)
    exps:push(cur:isStatic() and 'static ' or nil)

    local cbkind

    if cur:kind() ~= 'Constructor' then
        local tn = self:typename(cur:resultType(), cur)
        if self:is_func_type(tn) then
            cbkind = 'RET'
            if callback.NULLABLE then
                exps:push('@nullable ')
            end
            if callback.LOCAL ~= false then
                exps:push('@local ')
            end
        end
        exps:push(tn)
        exps:push(olua.typespace(tn))
    end

    local optional = false
    exps:push(fn .. '(')
    declexps:push(fn .. '(')
    for i, arg in ipairs(cur:arguments()) do
        local tn = self:typename(arg:type(), arg)
        local DISPLAY_NAME = cur:displayName()
        local ARGN = 'ARG' .. i
        if i > 1 then
            exps:push(', ')
            declexps:push(', ')
        end
        declexps:push(tn)
        if self:is_func_type(tn) then
            if cbkind then
                error(format('has more than one std::function: ${cls.CPPCLS}::${DISPLAY_NAME}'))
            end
            assert(not cbkind, cls.CPPCLS .. '::' .. DISPLAY_NAME)
            cbkind = 'ARG'
            if callback.NULLABLE then
                exps:push('@nullable ')
            end
            if callback.LOCAL ~= false then
                exps:push('@local ')
            end
        end
        if self:has_default_value(arg) and not string.find(attr[ARGN] or '', '@out') then
            exps:push('@optional ')
            optional = true
        else
            assert(not optional, cls.CPPCLS .. '::' .. DISPLAY_NAME)
        end
        exps:push(attr[ARGN] and (attr[ARGN] .. ' ') or nil)
        exps:push(tn)
        exps:push(olua.typespace(tn))
        exps:push(arg:name())
    end
    exps:push(')')
    declexps:push(')')

    local func = tostring(exps)
    if self.EXCLUDE_PASS(cls.CPPCLS, fn, func) then
        return
    else
        local prototype =  tostring(declexps)
        cls.EXCLUDE_FUNC:replace(cur:displayName(), true)
        cls.EXCLUDE_FUNC:replace(prototype, true)
        local static = cur:isStatic()
        if cur:kind() == 'FunctionDecl' then
            func = 'static ' .. func
            static = true
        end
        cls.FUNC[prototype] = {
            FUNC = func,
            NAME = fn,
            STATIC = static,
            NUM_ARGS = #cur:arguments(),
            CALLBACK_KIND = cbkind,
            PROTOTYPE = prototype,
        }
    end
end

function M:visit_var(cls, cur)
    if cur:type():isConst() or self:is_excluded_type(cur:type(), cur) then
        return
    end

    local exps = olua.newarray('')
    local attr = cls.ATTR[cur:name()] or cls.ATTR['*'] or {}
    local tn = self:typename(cur:type(), cur)
    local cbkind

    local length = string.match(tn, '%[(%d+)%]$')
    if length then
        exps:pushf('@array(${length})')
        exps:push(' ')
        tn = string.gsub(tn, ' %[%d+%]$', '')
    elseif attr.OPTIONAL or (self:has_default_value(cur) and attr.OPTIONAL == nil) then
        exps:push('@optional ')
    end

    if self:is_func_type(tn) then
        cbkind = 'VAR'
        exps:push('@nullable ')
        local callback = cls.CALLBACK:take(cur:name()) or {}
        if callback.LOCAL ~= false then
            exps:push('@local ')
        end
    end

    exps:push(attr.RET and (attr.RET .. ' ') or nil)
    exps:push(cur:kind() == 'VarDecl' and 'static ' or nil)
    exps:push(tn)
    exps:push(olua.typespace(tn))
    exps:push(cur:name())

    local decl = tostring(exps)
    if self.EXCLUDE_PASS(cls.CPPCLS, cur:name(), decl) then
        return
    else
        local name = cls.MAKE_LUANAME(cur:name(), 'VAR')
        cls.VAR[name] = {
            NAME = name,
            SNIPPET = decl,
            CALLBACK_KIND = cbkind
        }
    end
end

function M:visit_alias_class(cppcls, super)
    local cls = self.CLASSES[cppcls]
    writer.visited_types[cppcls] = cls
    writer.ignored_types[cppcls] = false
    if self:is_func_type(super) then
        cls.KIND = 'classFunc'
        cls.DECLTYPE = super
        cls.LUACLS = self.MAKE_LUACLS(cppcls)
    else
        cls.KIND = cls.KIND or 'classAlias'
        cls.SUPERCLS = super
        cls.LUACLS = self.MAKE_LUACLS(super)
    end
end

function M:visit_class(cur, cppcls)
    cppcls = cppcls or self:fullname(cur)
    local cls = self.CLASSES[cppcls]
    writer.visited_types[cppcls] = cls
    writer.ignored_types[cppcls] = false
    cls.KIND = cls.KIND or 'class'

    if cur:kind() == 'Namespace' then
        cls.REG_LUATYPE = false
    end

    for _, c in ipairs(cur:children()) do
        local kind = c:kind()
        local access = c:access()
        if access == 'private' or access == 'protected' then
            goto continue
        elseif kind == 'CXXBaseSpecifier' then
            if not cls.SUPERCLS then
                cls.SUPERCLS = c:type():name()
            end
        elseif kind == 'UsingDeclaration' then
            for _, cc in ipairs(c:children()) do
                if cc:kind() == 'TypeRef' then
                    cls.USING[c:name()] = cc:name():match('([^ ]+)$')
                    break
                end
            end
        elseif kind == 'FieldDecl' or kind == 'VarDecl' then
            local vn = c:name()
            local ct = c:type()
            if cls.EXCLUDE_FUNC['*'] or cls.EXCLUDE_FUNC[vn] or vn:find('^_') then
                goto continue
            end
            if ct:isConst() and kind == 'VarDecl' then
                if not self:is_excluded_type(ct, c) then
                    cls.CONST[vn] = {NAME = vn, TYPENAME = ct:name()}
                end
            else
                self:visit_var(cls, c)
            end
        elseif kind == 'Constructor' or kind == 'FunctionDecl' or kind == 'CXXMethod' then
            if (cls.EXCLUDE_FUNC['*'] or cls.EXCLUDE_FUNC[c:name()] or cls.EXCLUDE_FUNC[c:displayName()]) or
                (kind == 'Constructor' and (cls.EXCLUDE_FUNC['new'] or cur:isAbstract())) then
                goto continue
            end
            self:visit_method(cls, c)
        else
            self:visit(c)
        end

        ::continue::
    end
end

function M:visit(cur)
    local kind = cur:kind()
    local children = cur:children()
    local cls = self:fullname(cur)
    local need_visit = self.CLASSES[cls] and not writer.visited_types[cls]
    if self:has_unexposed_attr(cur) then
        return
    elseif #children == 0 or string.find(cls, "^std::") then
        return
    elseif kind == 'Namespace' then
        if need_visit then
            self:visit_class(cur)
        else
            for _, c in ipairs(children) do
                self:visit(c)
            end
        end
    elseif kind == 'ClassDecl' or kind == 'StructDecl' then
        if need_visit then
            self:visit_class(cur)
        else
            if not self.EXCLUDE_TYPE[cls] and writer.ignored_types[cls] == nil then
                writer.ignored_types[cls] = true
            end
            for _, c in ipairs(cur:children()) do
                self:visit(c)
            end
        end
    elseif kind == 'EnumDecl' then
        if need_visit then
            self:visit_enum(cur)
        end
    elseif kind == 'TypeAliasDecl' then
        local ut = cur:underlyingType()
        local name = self:typename(ut, cur)
        local isenum = ut:declaration():kind() == 'EnumDecl'
        local alias = ((isenum and 'enum ' or '') .. name)
        writer.alias_types[cls] = writer.alias_types[name] or alias
        if need_visit then
            self:visit_alias_class(cls, writer.alias_types[cls])
        end
    elseif kind == 'TypedefDecl' then
        local decl = cur:underlyingType():declaration()
        local utk = decl:kind()
        local isenum = utk == 'EnumDecl'
        local name
        --[[
            namespace test {
                typedef enum TAG_ {
                } TAG
            }
            cur:underlyingType():name() => enum TAG_
            cur:type():canonicalType():name() => test::TAG_
        ]]
        if utk == 'StructDecl' or utk == 'EnumDecl' then
            name = self:typename(decl:type(), decl)
        else
            name = self:typename(cur:underlyingType(), decl)
        end

        local alias = ((isenum and 'enum ' or '') .. name)
        writer.alias_types[cls] = writer.alias_types[name] or alias

        if need_visit then
            if utk == 'StructDecl' then
                self:visit_class(decl, cls)
            elseif utk == 'EnumDecl' then
                self:visit_enum(decl, cls)
            else
                self:visit_alias_class(cls, writer.alias_types[cls])
            end
        end
    else
        for _, c in ipairs(children) do
            self:visit(c)
        end
    end
end

function M.__call(_, path)
    local module = dofile(path)
    setmetatable(module, {__index = M})
    module:parse(path)
end

-------------------------------------------------------------------------------
-- define config module
-------------------------------------------------------------------------------
local function add_command(cls)
    local CMD = {}

    function CMD.EXCLUDE_FUNC(name)
        cls.EXCLUDE_FUNC[name] = true
        return CMD
    end

    function CMD.IFDEF(name, value)
        cls.IFDEF[name] = {NAME = name, VALUE = value}
        return CMD
    end

    function CMD.ATTR(name, attrs)
        cls.ATTR[name] = attrs
        return CMD
    end

    function CMD.ENUM(name, value)
        cls.ENUM[name] = {NAME = name, VALUE = value}
        return CMD
    end

    function CMD.CONST(name, value, typename)
        cls.CONST[name] = {NAME = name, VALUE = value, TYPENAME = typename}
    end
    
    function CMD.FUNC(fn, snippet)
        cls.EXCLUDE_FUNC[fn] = true
        cls.FUNC[fn] = {NAME = fn, SNIPPET = snippet}
        return CMD
    end

    function CMD.CALLBACK(cb)
        if not cb.NAME then
            cb.NAME = olua.func_name(cb.FUNCS[1])
            cls.EXCLUDE_FUNC[cb.NAME] = true
        end
        assert(#cb.NAME > 0, 'no callback function name')
        cls.CALLBACK[cb.NAME] = cb
        return CMD
    end

    function CMD.PROP(name, get, set)
        cls.PROP[name] = {NAME = name, GET = get, SET = set}
        return CMD
    end

    function CMD.VAR(name, snippet)
        local varname = olua.func_name(snippet)
        assert(#varname > 0, 'no variable name')
        cls.EXCLUDE_FUNC[varname] = true
        cls.VAR[name or varname] = {NAME = name, SNIPPET = snippet}
        return CMD
    end
    
    function CMD.ALIAS(name, alias)
        cls.ALIAS[name] = {NAME = name, ALIAS = alias}
        return CMD
    end

    function CMD.INSERT(names, codes)
        names = type(names) == 'string' and {names} or names
        for _, n in ipairs(names) do
            cls.INSERT[n] = {NAME = n, CODES = codes}
        end
        return CMD
    end

    function CMD.__index(_, key)
        return cls[key]
    end

    function CMD.__newindex(_, key, value)
        cls[key] = value
    end

    return setmetatable(CMD, CMD)
end

function M.typemod(name)
    local INDEX = 1
    local modinst = {
        CLASSES = olua.newhash(),
        EXCLUDE_TYPE = {},
        TYPEDEFS = olua.newhash(),
        NAME = name,
    }

    modinst.EXCLUDE_TYPE = setmetatable({}, {__call = function (_, tn)
        modinst.EXCLUDE_TYPE[tn] = true
    end})

    function modinst.EXCLUDE_PASS()
    end

    function modinst.include(path)
        loadfile(path)(modinst)
    end

    function modinst.typeconf(classname)
        local cls = {
            CPPCLS = assert(classname, 'not specify classname'),
            LUACLS = modinst.MAKE_LUACLS(classname),
            EXCLUDE_FUNC = olua.newhash(),
            USING = olua.newhash(),
            ATTR = olua.newhash(),
            ENUM = olua.newhash(),
            CONST = olua.newhash(),
            FUNC = olua.newhash(),
            CALLBACK = olua.newhash(),
            PROP = olua.newhash(),
            VAR = olua.newhash(),
            ALIAS = olua.newhash(),
            INSERT = olua.newhash(),
            IFDEF = olua.newhash(),
            INDEX = INDEX,
            REG_LUATYPE = true,
            MAKE_LUANAME = function (n) return n end,
        }
        INDEX = INDEX + 1
        assert(not modinst.CLASSES[classname], 'class conflict: ' .. classname)
        modinst.CLASSES[classname] = cls
        return add_command(cls)
    end

    function modinst.typeonly(classname)
        local cls = modinst.typeconf(classname)
        cls.EXCLUDE_FUNC '*'
        return cls
    end

    function modinst.typedef(info)
        modinst.TYPEDEFS[info.CPPCLS] = info
    end

    function modinst.typeconv(classname)
        local cls = modinst.typeconf(classname)
        cls.KIND = 'conv'
        return cls
    end

    return modinst
end

return setmetatable(M, M)