local olua = require "olua"
local clang = require "clang"
local confwriter = require 'autoconf-writer'

local format = olua.format

local ignored_type = {}
local visited_type = {}
local refed_type = {}
local type_alias = {}
local type_convs = {}
local module_files = {}
local clang_tu

local M = {}

local logfile = io.open('autobuild/autoconf.log', 'w')

local function log(fmt, ...)
    logfile:write(string.format(fmt, ...))
    logfile:write('\n')
end

function M.addref(cppcls)
    refed_type[cppcls] = true
end

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
    self.conf = dofile(path)
    self.filename = self.conf.NAME:gsub('_', '-')
    self.classes = {}

    self.file_path = format('autobuild/${self.filename}.lua')
    self.type_file_path = format('autobuild/${self.filename}-types.lua')

    module_files[#module_files + 1] = {
        file_path = self.file_path,
        type_file_path = self.type_file_path
    }

    for cls in pairs(self.conf.EXCLUDE_TYPE) do
        ignored_type[cls] = false
    end

    local function toconv(cls)
        return 'auto_olua_$$_' .. string.gsub(cls.CPPCLS, '::', '_')
    end

    for _, v in ipairs(self.conf.TYPEDEFS) do
        type_convs[v.CPPCLS] = assert(v.CONV, 'no conv function: ' .. v.CPPCLS)
    end

    for _, cls in pairs(self.conf.CLASSES) do
        type_convs[cls.CPPCLS] = cls.ASCONV and toconv(cls) or true
    end

    self:visit(clang_tu:cursor())
    self:check_class()

    confwriter.write_module(setmetatable({
        visited_type = visited_type,
        ignored_type = ignored_type,
        log = log,
    }, {__index = self}))
end

local function is_ref_class(cls)
    if refed_type[cls.CPPCLS] then
        return true
    elseif cls.SUPERCLS then
        return is_ref_class(visited_type[cls.SUPERCLS])
    end
end

function M:check_class()
    for name, conf in pairs(self.conf.CLASSES) do
        if conf.NOTCONF then
            local cls = self:create_class(conf.CPPCLS)
            cls.KIND = 'Class'
            cls.SUPERCLS = conf.SUPERCLS
            visited_type[cls.CPPCLS] = cls
        elseif not visited_type[name] then
            error(format("class not found: ${name}"))
        end
    end
    table.sort(self.classes, function (a, b)
        return a.CONF.INDEX < b.CONF.INDEX
    end)
    for _, cls in ipairs(self.classes) do
        if cls.SUPERCLS and not visited_type[cls.SUPERCLS]then
            error(format('super class not found: ${cls.CPPCLS} -> ${cls.SUPERCLS}'))
        end
        if is_ref_class(cls) then
            refed_type[cls.CPPCLS] = true
        end
        if cls.CONF.ASCONV then
            cls.KIND = 'Conv'
        end
    end
end

function M:create_class(cppcls)
    local cls = {
        CPPCLS = cppcls,
        LUACLS = self.conf.MAKE_LUACLS(cppcls),
        FUNCS = {},
        VARS = {},
        CONSTS = {},
        ENUMS = {},
        INST_FUNCS = {},
        CONF = self.conf.CLASSES[cppcls],
    }
    visited_type[cppcls] = cls
    ignored_type[cppcls] = false
    self.classes[#self.classes + 1] = cls
    return cls
end

function M:visit_enum(cur, cppcls)
    local cls = self:create_class(cppcls or self:classname(cur))
    if cur:kind() ~= 'TypeAliasDecl' then
        for _, c in ipairs(cur:children()) do
            local kind = c:kind()
            assert(kind == 'EnumConstantDecl', kind)
            cls.ENUMS[#cls.ENUMS + 1] = c:name()
        end
        cls.KIND = 'Enum'
        type_alias[cls.CPPCLS] = nil
    else
        cls.KIND = 'EnumAlias'
    end
end

function M:is_excluded_typeanme(name)
    if self.conf.EXCLUDE_TYPE[name] then
        return true
    elseif string.find(name, '<') then
        name = string.gsub(name, '<.*>', '')
        return self:is_excluded_typeanme(name)
    end
end

function M:is_excluded_type(type)
    if type:kind() == 'IncompleteArray' then
        return true
    end

    local tn = type:name()
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

function M:classname(cur)
    local type = cur:type()
    if type then
        return type:name()
    elseif cur:kind() == 'Namespace' then
        local ns = olua.newarray('::')
        while cur and cur:kind() ~= 'TranslationUnit' do
            ns:insert(cur:name())
            cur = cur:parent()
        end
        return tostring(ns)
    else
        return cur:name()
    end
end

function M:typename(cur, type)
    local tn = type:name()
    -- remove const, & and *: const T * => T
    local rawtn = tn:match('([%w:_]+) ?[&*]?$')
    if not rawtn then
        return tn
    end

    -- typedef std::function<void (Object *)> ClickListener
    -- const ClickListener & => const olua::ClickListener &
    for _, cu in ipairs(cur:children()) do
        if cu:kind() == 'TypeRef' then
            local ftn = cu:name():match('([^ ]+)$')
            if string.find(ftn, rawtn .. '$') then
                tn = tn:gsub(rawtn, ftn)
                rawtn = ftn
                break
            end
        end
    end

    local alias = type_alias[rawtn]
    if alias and not type_convs[rawtn] then
        local rawalias = string.gsub(alias, '<.+>', '')
        if olua.typeinfo(rawalias, nil, true) then
            -- old: const olua::ClickListener &
            -- new: const std::function<void (Object *)> &
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
        else
            if self:has_default_value(c) then
                return true
            end
        end
    end
end

function M:visit_method(cls, cur)
    if cur:isVariadic() or cur:name():find('^_') then
        return
    end

    if cur:kind() == 'Constructor' then
        if cur:isCopyConstructor() or
            cur:isMoveConstructor() then
            return
        end
    elseif cur:name():find('operator *[%-=+/*><!()]?')
            or self:is_excluded_type(cur:resultType()) then
        return
    end

    for _, c in ipairs(cur:children()) do
        -- attribute(deprecated) ?
        if c:kind() == 'UnexposedAttr' then
            return
        end
    end

    local fn = cur:name()
    local attr = cls.CONF.ATTR[fn] or {}
    local callback = cls.CONF.CALLBACK[fn] or {}
    local exps = olua.newarray('')
    local dn_exps = olua.newarray('')

    for i, arg in ipairs(cur:arguments()) do
        local attrn = (attr['ARG' .. i]) or ''
        if not attrn:find('@out') and self:is_excluded_type(arg:type()) then
            return
        end
    end

    exps:push(attr.RET and (attr.RET .. ' ') or nil)
    exps:push(cur:isStatic() and 'static ' or nil)

    local cbtype

    if cur:kind() ~= 'Constructor' then
        local tn = self:typename(cur, cur:resultType())
        if string.find(tn, 'std::function') then
            cbtype = 'RET'
            if callback.NULLABLE then
                exps:push('@nullable ')
            end
            if callback.LOCAL ~= false then
                exps:push('@local ')
            end
        end
        exps:push(tn)
        if not string.find(tn, '[*&]$') then
            exps:push(' ')
        end
    end

    local optional = false
    exps:push(fn .. '(')
    dn_exps:push(fn .. '(')
    for i, arg in ipairs(cur:arguments()) do
        local tn = self:typename(arg, arg:type())
        local display_name = cur:displayName()
        local ARGN = 'ARG' .. i
        if i > 1 then
            exps:push(', ')
            dn_exps:push(', ')
        end
        if string.find(tn, 'std::function') then
            if cbtype then
                error(format('has more than one std::function: ${cls.CPPCLS}::${display_name}'))
            end
            assert(not cbtype, cls.CPPCLS .. '::' .. cur:displayName())
            cbtype = 'ARG'
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
            assert(not optional, cls.CPPCLS .. '::' .. display_name)
        end
        exps:push(attr[ARGN] and (attr[ARGN] .. ' ') or nil)
        exps:push(tn)
        dn_exps:push(tn)
        if not string.find(tn, '[*&]$') then
            exps:push(' ')
            dn_exps:push(' ')
        end
        exps:push(arg:name())
    end
    exps:push(')')
    dn_exps:push(')')

    local decl = tostring(exps)
    if self.conf.EXCLUDE_PASS(cls.CPPCLS, fn, decl) then
        return
    else
        if cbtype then
            refed_type[cls.CPPCLS] = true
        end
        return decl, tostring(dn_exps), cbtype
    end
end

function M:visit_field(cls, cur)
    if cur:type():isConst() then
        return nil
    end

    if self:is_excluded_type(cur:type()) then
        return
    end

    local exps = olua.newarray('')

    if self:has_default_value(cur) then
        exps:push('@optional ')
    end

    local tn = self:typename(cur, cur:type())
    local cbtype
    if string.find(tn, 'std::function') then
        cbtype = 'VAR'
        exps:push('@nullable ')
        local callback = cls.CONF.CALLBACK:take(cur:name()) or {}
        if callback.LOCAL ~= false then
            exps:push('@local ')
        end
    end
    if cur:kind() == 'VarDecl' then
        exps:push('static ')
    end
    exps:push(tn)
    if not string.find(tn, '[*&]$') then
        exps:push(' ')
    end

    exps:push(cur:name())

    local decl = tostring(exps)
    if self.conf.EXCLUDE_PASS(cls.CPPCLS, cur:name(), decl) then
        return
    else
        if cbtype then
            refed_type[cls.CPPCLS] = true
        end
        return {NAME = cur:name(), SNIPPET = decl, CALLBACK_TYPE = cbtype}
    end
end

function M:visit_class(cur, cppcls)
    local filter = {}
    local cls = self:create_class(cppcls or self:classname(cur))
    local conf = cls.CONF
    cls.SUPERCLS = conf.SUPERCLS
    cls.KIND = 'Class'

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
        elseif kind == 'FieldDecl' or kind == 'VarDecl' then
            local vn = c:name()
            local ct = c:type()
            if conf.EXCLUDE['*'] or conf.EXCLUDE[vn] or vn:find('^_') then
                goto continue
            end
            if ct:isConst() and kind == 'VarDecl' then
                if not self:is_excluded_type(ct) then
                    cls.CONSTS[#cls.CONSTS + 1] = {NAME = vn, TYPENAME = ct:name()}
                end
            else
                cls.VARS[#cls.VARS + 1] = self:visit_field(cls, c)
            end
        elseif kind == 'Constructor' or kind == 'FunctionDecl' or kind == 'CXXMethod' then
            local displayName = c:displayName()
            local fn = c:name()
            if (conf.EXCLUDE['*'] or conf.EXCLUDE[fn] or filter[displayName]) or
                (kind == 'Constructor' and (conf.EXCLUDE['new'] or cur:isAbstract())) then
                goto continue
            end
            local func, prototype, cbtype = self:visit_method(cls, c)
            if func and not filter[prototype] then
                filter[displayName] = true
                filter[prototype] = true
                local static = c:isStatic()
                if kind == 'FunctionDecl' then
                    func = 'static ' .. func
                    static = true
                elseif not c:isStatic() then
                    cls.INST_FUNCS[prototype] = cls.CPPCLS
                end
                cls.FUNCS[#cls.FUNCS + 1] = {
                    FUNC = func,
                    NAME = fn,
                    STATIC = static,
                    ARGS = #c:arguments(),
                    CALLBACK_TYPE = cbtype,
                    PROTOTYPE = prototype,
                }
            end
        else
            self:visit(c)
        end

        ::continue::
    end
end

function M:visit(cur)
    local kind = cur:kind()
    local children = cur:children()
    local cls = self:classname(cur)
    local need_visit = self.conf.CLASSES[cls] and not visited_type[cls]
    if #children == 0 or string.find(cls, "^std::") then
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
            if not self.conf.EXCLUDE_TYPE[cls] and ignored_type[cls] == nil then
                ignored_type[cls] = true
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
        if ut:declaration():kind() == 'EnumDecl' then
            type_alias[cls] = 'enum ' ..  self:typename(cur, ut)
        else
            type_alias[cls] = self:typename(cur, ut)
        end
    elseif kind == 'TypedefDecl' then
        local c = children[1]
        if c and c:kind() == 'UnexposedAttr' then
            return
        end

        local alias = cur:type():name()
        local decl = cur:underlyingType():declaration()
        local utk = decl:kind()
        local name
        --[[
            namespace test {
                typedef enum TAG_ {
                } TAG
            }
            cur:underlyingType():name() => enum TAG_
            cur:type():canonicalType():name() => test::TAG_
        ]]
        if utk == 'StructDecl' then
            name = self:typename(decl, decl:type())
            if need_visit then
                self:visit_class(decl, cls)
            end
        elseif utk == 'EnumDecl' then
            if need_visit then
                self:visit_enum(decl, cls)
            end
            name = 'enum ' .. self:typename(decl, decl:type())
        else
            name = self:typename(cur, cur:underlyingType())
        end
        type_alias[alias] = type_alias[name] or name
    else
        for _, c in ipairs(children) do
            self:visit(c)
        end
    end
end

function M.__call(_, path)
    local inst = setmetatable({}, {__index = M})
    inst:parse(path)
end

function M.__gc()
    xpcall(function ()
        confwriter.write_alias_and_log({
            visited_type = visited_type,
            ignored_type = ignored_type,
            refed_type = refed_type,
            type_alias = type_alias,
            type_convs = type_convs,
            module_files = module_files,
            log = log,
        })
    end,
    function (message)
        print(debug.traceback(message))
    end)
end

-------------------------------------------------------------------------------
-- define config module
-------------------------------------------------------------------------------
local function command(func)
    return setmetatable({}, {__call = func})
end

local function create_table(classname)
    local t = {}
    local arr = {}
    local map = {}

    function t:__index(key)
        if type(key) == 'number' then
            return arr[key]
        else
            return map[key]
        end
    end

    function t:__newindex(key, value)
        assert(type(key) == 'string', 'only support string field')
        assert(not map[key], 'field conflict: ' .. classname .. '.' .. key)
        map[key] = value
        arr[#arr + 1] = value
    end

    function t:__pairs()
        return pairs(map)
    end

    function t:__ipairs()
        return ipairs(arr)
    end

    function t:take(key)
        local value = map[key]
        if value then
            for i, v in ipairs(arr) do
                if value == v then
                    table.remove(arr, i)
                    break
                end
            end
        end
        return value
    end

    function t:toarray()
        return arr
    end

    return setmetatable(t, t)
end

local function add_command(cls)
    local CMD = {}

    function CMD.ATTR(name, attrs)
        cls.ATTR[name] = attrs
        return CMD
    end

    function CMD.ALIAS(name, alias)
        cls.ALIAS[name] = {NAME = name, ALIAS = alias}
        return CMD
    end

    function CMD.EXCLUDE(name)
        cls.EXCLUDE[name] = true
        return CMD
    end

    function CMD.FUNC(fn, snippet)
        cls.EXCLUDE[fn] = true
        cls.FUNC[fn] = {FUNC = fn, SNIPPET = snippet}
        return CMD
    end

    function CMD.CALLBACK(cb)
        if not cb.NAME then
            cb.NAME = olua.funcname(cb.FUNCS[1])
            cls.EXCLUDE[cb.NAME] = true
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
        local varname = olua.funcname(snippet)
        assert(#varname > 0, 'no variable name')
        cls.EXCLUDE[varname] = true
        cls.VAR[name or varname] = {NAME = name, SNIPPET = snippet}
        return CMD
    end

    function CMD.ENUM(name, value)
        cls.ENUM[name] = {NAME = name, VALUE = value}
        return CMD
    end

    function CMD.INJECT(names, codes)
        names = type(names) == 'string' and {names} or names
        for _, n in ipairs(names) do
            cls.INJECT[n] = {NAME = n, CODES = codes}
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
        CLASSES = {},
        EXCLUDE_TYPE = {},
        TYPEDEFS = {},
        NAME = name,
    }

    modinst.EXCLUDE_TYPE = command(function (_, tn)
        modinst.EXCLUDE_TYPE[tn] = true
    end)

    function modinst.EXCLUDE_PASS()
    end

    function modinst.include(path)
        loadfile(path)(modinst)
    end

    function modinst.typeconf(classname)
        local cls = {
            CPPCLS = assert(classname, 'not specify classname'),
            ATTR = create_table(classname),
            ALIAS = create_table(classname),
            EXCLUDE = create_table(classname),
            FUNC = create_table(classname),
            CALLBACK = create_table(classname),
            PROP = create_table(classname),
            VAR = create_table(classname),
            ENUM = create_table(classname),
            INJECT = create_table(classname),
            INDEX = INDEX,
            MAKE_LUANAME = function (n) return n end,
        }
        INDEX = INDEX + 1
        assert(not modinst.CLASSES[classname], 'class conflict: ' .. classname)
        modinst.CLASSES[classname] = cls
        return add_command(cls)
    end

    function modinst.typeonly(classname)
        local cls = modinst.typeconf(classname)
        cls.EXCLUDE '*'
        return cls
    end

    function modinst.typedef(info)
        modinst.TYPEDEFS[#modinst.TYPEDEFS + 1] = info
    end

    function modinst.typeconv(classname)
        local cls = modinst.typeconf(classname)
        cls.ASCONV = true
        return cls
    end

    return modinst
end

return setmetatable(M, M)