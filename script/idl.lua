local idl = {
    clang_args = olua.array(),
    modules = olua.ordered_map(false),
    exclude_types = olua.ordered_map(false),
    type_convs = olua.ordered_map(false),
    macros = olua.array(),

    ---@type idl.ModuleDescriptor?
    current_module = nil
}

---@alias luatype
---|>'"nil"'
---| '"any"'
---| '"boolean"'
---| '"string"'
---| '"number"'
---| '"integer"'
---| '"function"'
---| '"table"'
---| '"thread"'
---| '"userdata"'
---| '"lightuserdata"'

---@alias booltype
---|>'"true"'
---| '"false"'

local function error_value(key, value, valuetype)
    value = tostring(value)
    olua.error("can't convert '${value}' to ${valuetype} for '${key}'")
end

---@return string
local function checkstring(key, v)
    if type(v) ~= "string" then
        error_value(key, v, "string")
    end
    return v
end

---@return boolean
local function checkboolean(key, v)
    if v == "true" then
        v = true
    elseif v == "false" then
        v = false
    else
        error_value(key, v, "boolean")
    end
    return v
end

---@return integer
local function checkinteger(key, v)
    local n = tonumber(v)
    if not n or not (n == math.floor(n)) then
        error_value(key, v, "integer")
    end
    return n ---@type integer
end

---@return function
local function checkfunction(key, v)
    if type(v) ~= "function" then
        error_value(key, v, "function")
    end
    return v
end

---@generic T
---@param cmd T
---@param store table<string, any>
---@param key string
---@param field? string
---@param tofunc? fun(key: string, v: any):any
local function add_value_command(cmd, store, key, tofunc, field)
    tofunc = tofunc or checkstring
    field = field or key
    cmd[key] = function (v)
        store[field] = tofunc(key, v)
        return cmd
    end
end

---------------------------------------------------------------------------------
-- define module
-------------------------------------------------------------------------------

local function check_module()
    if not idl.current_module then
        error("You should define a module!!!")
    end
end

---@param args string[]
function clang(args)
    for _, v in ipairs(args) do
        idl.clang_args:push(v)
    end
end

---Define config module.
---@param name string
function module(name)
    ---@class idl.ModuleDescriptor
    ---@field path string # Module config file path.
    ---@field name string
    ---@field headers? string
    ---@field filepath? string
    ---@field codeblock? string
    ---@field outputdir? string
    ---@field apidir? string
    ---@field luaopen? string
    ---@field entry? string
    ---@field luacls fun(cppcls:string):string
    idl.current_module = {
        name = name,
        class_types = olua.ordered_map(),
        wildcard_types = olua.ordered_map(),
        typedef_types = olua.ordered_map(),
        type_convs = olua.ordered_map(),
        luacls = function (cppcls)
            return string.gsub(cppcls, "::", ".")
        end,
    }
    idl.macros:clear()
    idl.modules:set(name, idl.current_module)
end

---Define included headers
---@param headers string
function headers(headers)
    check_module()
    idl.current_module.headers = headers
end

---Insert codes into the beginning of generated file.
---@param codeblock string
function codeblock(codeblock)
    check_module()
    idl.current_module.codeblock = codeblock
end

---Insert codes into the `luaopen_[moudle]` function.
---@param luaopen string
function luaopen(luaopen)
    check_module()
    idl.current_module.luaopen = luaopen
end

---Specify the entry `class`, when you require a module, return this `class`.
---@param cppcls string
function entry(cppcls)
    check_module()
    idl.current_module.entry = checkstring(cppcls)
end

---@param dir string
function outputdir(dir)
    check_module()
    idl.current_module.outputdir = dir
end

---@param dir string
function apidir(dir)
    check_module()
    idl.current_module.apidir = dir
end

---@param maker fun(cppcls:string):string
function luacls(maker)
    check_module()
    idl.current_module.luacls = maker
end

---@param cppcls string
function excludetype(cppcls)
    idl.exclude_types:replace(olua.pretty_typename(cppcls), true)
    idl.exclude_types:replace(olua.pretty_typename(cppcls .. " *"), true)
end

---@param path string
function import(path)
    assert(loadfile(path))()
end

---@param cond string
function macro(cond)
    if #cond > 0 then
        idl.macros:push(cond)
    else
        idl.macros:pop()
    end
end

---
--- Define a type convertor.
---
---@param cppcls string C++ class name
---@return Typedef
function typedef(cppcls)
    check_module()

    ---@class TypedefDescriptor
    ---@field cppcls string
    ---@field luacls? string
    ---@field conv? string
    ---@field luatype? string
    ---@field packable? boolean
    ---@field packvars? integer
    ---@field smartptr? boolean
    ---@field override? boolean
    local cls = { cppcls = cppcls }

    for c in cppcls:gmatch("[^;\n\r]+") do
        c = olua.pretty_typename(c)
        local t = setmetatable({ cppcls = c }, { __index = cls })
        idl.current_module.typedef_types:set(c, t)
        idl.type_convs:set(c, t)
    end

    ---@class Typedef
    ---@field luacls fun(luacls:string):Typedef
    ---@field conv fun(conv:string):Typedef
    ---@field luatype fun(luatype:luatype):Typedef
    ---@field packable fun(packable:booltype):Typedef
    ---@field packvars fun(packvars:string):Typedef
    ---@field smartptr fun(smartptr:booltype):Typedef
    ---@field override fun(override:booltype):Typedef
    local Typedef = {}

    add_value_command(Typedef, cls, "luacls")
    add_value_command(Typedef, cls, "conv")
    add_value_command(Typedef, cls, "luatype")
    add_value_command(Typedef, cls, "packable", checkboolean)
    add_value_command(Typedef, cls, "packvars", checkinteger)
    add_value_command(Typedef, cls, "smartptr", checkboolean)
    add_value_command(Typedef, cls, "override", checkboolean)

    return Typedef
end

-------------------------------------------------------------------------------
-- typeconf
-------------------------------------------------------------------------------

---Set attribute for c++ function parameters or return value.
---@alias TypeconfFuncAttr fun(attr:string):TypeconfFunc

---@class TypeconfFuncBase : idl.Typeconf
---@field insert_before fun(code:string):TypeconfFunc # Insert codes before the c++ function invoked.
---@field insert_after fun(code:string):TypeconfFunc # Insert codes after the c++ function invoked.
---@field insert_cbefore fun(code:string):TypeconfFunc # Insert codes before the c++ callback function invoked.
---@field insert_cafter fun(code:string):TypeconfFunc # Insert codes after the c++ callback function invoked.
---@field ret TypeconfFuncAttr
---@field arg1 TypeconfFuncAttr
---@field arg2 TypeconfFuncAttr
---@field arg3 TypeconfFuncAttr
---@field arg4 TypeconfFuncAttr
---@field arg5 TypeconfFuncAttr
---@field arg6 TypeconfFuncAttr
---@field arg7 TypeconfFuncAttr
---@field arg8 TypeconfFuncAttr
---@field arg9 TypeconfFuncAttr
---@field arg10 TypeconfFuncAttr
---@field package optional fun(optional:boolean):TypeconfFunc
---@field package readonly fun(readonly:boolean):TypeconfFunc

---@param cmd TypeconfFuncBase
---@param cls idl.TypeconfDescriptor
---@param func TypeconfFuncDescriptor|TypeconfCallbackDescriptor
---@param name string
local function add_insert_command(cmd, cls, func, name)
    ---@class TypeconfInsertDescriptor
    ---@field name string
    ---@field before? string
    ---@field after? string
    ---@field cbefore? string
    ---@field cafter? string
    local entry = { name = name }
    cls.inserts:set(name, entry)

    add_value_command(cmd, entry, "insert_before", nil, "before")
    add_value_command(cmd, entry, "insert_after", nil, "after")
    add_value_command(cmd, entry, "insert_cbefore", nil, "cbefore")
    add_value_command(cmd, entry, "insert_cafter", nil, "cafter")
end

---@param cmd TypeconfFuncBase
---@param cls idl.TypeconfDescriptor
---@param func TypeconfFuncDescriptor|TypeconfCallbackDescriptor
---@param name string
local function add_attr_command(cmd, cls, func, name)
    ---@class TypeconfAttrDescriptor
    ---@field optional? boolean
    ---@field readonly? boolean
    ---@field ret? string
    ---@field arg1? string
    ---@field arg2? string
    ---@field arg3? string
    ---@field arg4? string
    ---@field arg5? string
    ---@field arg6? string
    ---@field arg7? string
    ---@field arg8? string
    ---@field arg9? string
    ---@field arg10? string
    local entry = {}
    cls.attrs:set(name, entry)

    add_value_command(cmd, entry, "optional", checkboolean)
    add_value_command(cmd, entry, "readonly", checkboolean)
    add_value_command(cmd, entry, "ret")
    add_value_command(cmd, entry, "arg1")
    add_value_command(cmd, entry, "arg2")
    add_value_command(cmd, entry, "arg3")
    add_value_command(cmd, entry, "arg4")
    add_value_command(cmd, entry, "arg5")
    add_value_command(cmd, entry, "arg6")
    add_value_command(cmd, entry, "arg7")
    add_value_command(cmd, entry, "arg8")
    add_value_command(cmd, entry, "arg9")
    add_value_command(cmd, entry, "arg10")
end


---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
---@return TypeconfFunc
local function typeconf_func(cmd, cls, name)
    ---@class TypeconfFuncDescriptor
    local func = {
        name = name,
        ---@type string|nil
        body = nil
    }
    cls.funcs:set(name, func)

    ---@class TypeconfFunc : TypeconfFuncBase
    ---@field body fun(body:string):TypeconfFunc
    local TypeconfFunc = {}

    add_value_command(TypeconfFunc, func, "body")
    add_attr_command(TypeconfFunc, cls, func, name)
    add_insert_command(TypeconfFunc, cls, func, name)

    ---@type TypeconfFunc
    return setmetatable(TypeconfFunc, { __index = cmd })
end

---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
---@return idl.typeconf.Callback
local function typeconf_callback(cmd, cls, name)
    ---@class TypeconfCallbackDescriptor
    local callback = {
        name = name,
        tag_scope = "object",
        localvar = true,
    }
    cls.callbacks:set(name, callback)

    ---@class idl.typeconf.Callback : TypeconfFuncBase
    ---@field localvar fun(localvar:booltype):idl.typeconf.Callback
    local TypeconfCallback = {}

    add_value_command(TypeconfCallback, callback, "localvar", checkboolean)
    add_attr_command(TypeconfCallback, cls, callback, name)
    add_insert_command(TypeconfCallback, cls, callback, name)


    ---Make callback key.
    ---@param maker string|string[]
    function TypeconfCallback.tag_maker(maker)
        callback.tag_maker = maker
        return TypeconfCallback
    end

    ---@alias idl.TypeCallback.TagMode
    ---|>'"startwith"'
    ---| '"equal"'
    ---| '"new"'
    ---| '"replace"'

    ---How to store or remove the callback.
    ---@param mode idl.TypeCallback.TagMode|idl.TypeCallback.TagMode[]
    ---@return idl.typeconf.Callback
    function TypeconfCallback.tag_mode(mode)
        callback.tag_mode = mode
        return TypeconfCallback
    end

    ---Specify where to store the callback.
    ---* `-1`: Store callback in return value.
    ---* `0`: Store callback in `.classobj` when it is a static function, otherwise store in `self` value.
    ---* `1,2,...N`: Store callback in the `N` argument value.
    ---@param store string
    ---@return idl.typeconf.Callback
    function TypeconfCallback.tag_store(store)
        callback.tag_store = checkinteger("tag_store", store)
        return TypeconfCallback
    end

    ---Mark the lifecycle of the callback, default is `object`.
    ---* `once`: Remove callback after the callback invoked.
    ---* `function`: Remove callback after the c++ function invoked.
    ---* `object`: Callback will exist until the c++ object die.
    ---@param scope "once"|"function"|"object"
    function TypeconfCallback.tag_scope(scope)
        callback.tag_scope = checkstring("tag_scope", scope)
        return TypeconfCallback
    end

    ---@type idl.typeconf.Callback
    return setmetatable(TypeconfCallback, { __index = cmd })
end

---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
---@return idl.TypeconfEnum
local function typeconf_enum(cmd, cls, name)
    ---@class ild.typeconf.EnumDescriptor
    ---@field name string
    ---@field value string
    ---@field comment? string
    local enum = { name = name }
    cls.enums:set(name, enum)

    ---@class idl.TypeconfEnum : idl.Typeconf
    ---@field value fun(value:string):idl.TypeconfEnum
    local TypeconfEnum = {}

    add_value_command(TypeconfEnum, enum, "value")
    add_value_command(TypeconfEnum, enum, "comment")

    ---@type idl.TypeconfEnum
    return setmetatable(TypeconfEnum, { __index = cmd })
end

---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
local function typeconf_const(cmd, cls, name)
    ---@class idl.typeconf.ConstDescriptor
    ---@field value string
    ---@field typename string
    local const = { name = name }
    cls.consts:set(name, const)

    ---@class idl.TypeconfConst : idl.Typeconf
    ---@field value fun(value:string):idl.TypeconfConst
    ---@field typename fun(typename:string):idl.TypeconfConst
    local TypeconfConst = {}
    add_value_command(TypeconfConst, const, "value")
    add_value_command(TypeconfConst, const, "typename")

    ---@type idl.TypeconfConst
    return setmetatable(TypeconfConst, { __index = cmd })
end

---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
local function typeconf_prop(cmd, cls, name)
    ---@class idl.Typeconf.PropDescriptor
    ---@field get string
    ---@field set string
    local prop = { name = name }

    cls.props:set(name, prop)

    ---@class idl.TypeconfProp : idl.Typeconf
    ---@field get fun(get:string):idl.TypeconfProp
    ---@field set fun(get:string):idl.TypeconfProp
    local TypeconfProp = {}

    add_value_command(TypeconfProp, prop, "get")
    add_value_command(TypeconfProp, prop, "set")

    ---@type idl.TypeconfProp
    return setmetatable(TypeconfProp, { __index = cmd })
end

---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
local function typeconf_var(cmd, cls, name)
    ---@class idl.Typeconf.VarDescriptor
    ---@field body string
    local var = { name = name }

    if name ~= "*" then
        cls.excludes:replace(name, true)
        cls.vars:set(name, var)
    else
        name = "var*"
    end

    ---@class idl.TypeconfVar : idl.Typeconf
    ---@field body fun(body:string):idl.TypeconfVar
    ---@field ret fun(attr:string):idl.TypeconfVar
    ---@field optional fun(optional:booltype):idl.TypeconfVar
    ---@field readonly fun(readonly:booltype):idl.TypeconfVar
    local TypeconfVar = {}

    local attr = {}
    cls.attrs:set(name, attr)

    add_value_command(TypeconfVar, var, "body")
    add_value_command(TypeconfVar, attr, "optional", checkboolean)
    add_value_command(TypeconfVar, attr, "readonly", checkboolean)
    add_value_command(TypeconfVar, attr, "ret")

    ---@type idl.TypeconfVar
    return setmetatable(TypeconfVar, { __index = cmd })
end

---@param cmd idl.Typeconf
---@param cls idl.TypeconfDescriptor
---@param name string
local function typeconf_alian(cmd, cls, name)
    ---@class idl.Typeconf.VarDescriptor
    ---@field alias string
    local alias = { name = name }
    cls.aliases:set(name, alias)

    ---@class idl.TypeconfAlias : idl.Typeconf
    ---@field to fun(to:string):idl.TypeconfAlias
    local TypeconfAlias = {}

    add_value_command(TypeconfAlias, alias, "to", checkstring, "alias")

    ---@type idl.TypeconfAlias
    return setmetatable(TypeconfAlias, { __index = cmd })
end

---
---Config a c++ class
---
---@param cppcls string the c++ class name
---@return idl.Typeconf
function typeconf(cppcls)
    check_module()

    ---@class idl.TypeconfDescriptor
    ---@field kind integer
    ---@field supercls? string
    ---@field comment? string
    ---@field funcdecl? string # std::function declaration
    ---@field luacls? string
    local cls = {
        ---@type string c++ full class name
        cppcls = cppcls,
        ---@type string lua class name
        luacls = idl.current_module.luacls(cppcls),
        funcdecl = nil,
        comment = nil,
        conv = "olua_$$_object",
        extends = olua.ordered_map(),
        excludes = olua.ordered_map(),
        wildcards = olua.ordered_map(),
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
        template_types = olua.ordered_map(),
        options = { reg_luatype = true, fromtable = true },
        ---@type fun(name:string, kind?:'func'|'var'|'enum'):string
        luaname = function (name, kind) return name end,
    }

    ---@type 'exclude'|'include'|nil
    local mode = nil

    local macros = olua.array()

    if idl.exclude_types:has(cppcls) then
        olua.error([[
            typeconf '${cls.cppcls}' will not configured
                you should do one of:
                    * remove excludetype '${cls.cppcls}'
        ]])
    end

    if cppcls:find("[%^%%%$%*%+]") then -- ^%$*+
        idl.current_module.wildcard_types:set(cppcls, cls)
    else
        idl.current_module.class_types:set(cppcls, cls)
    end

    idl.type_convs:set(cppcls, cls)
    if #idl.macros > 0 then
        cls.macros:set("*", { name = "*", value = idl.macros:at(-1) })
    end

    ---@class idl.Typeconf
    ---@field supercls fun(supercls:string):idl.Typeconf
    ---@field luaopen fun(luaopen:string):idl.Typeconf
    ---@field codeblock fun(codeblock:string):idl.Typeconf
    ---@field luaname fun(maker:fun(cppcls:string, kind?:'func'|'var'|'enum'):string):idl.Typeconf
    ---@field indexerror fun(mode:"r" | "w" | "rw"):idl.Typeconf
    ---@field fromtable fun(fromtable:booltype):idl.Typeconf
    ---@field packable fun(packable:booltype):idl.Typeconf
    ---@field packvars fun(packvars:string):idl.Typeconf
    ---@field private maincls fun(cls:idl.TypeconfDescriptor):idl.Typeconf
    local Typeconf = {}

    add_value_command(Typeconf, cls, "supercls")
    add_value_command(Typeconf, cls, "luaopen")
    add_value_command(Typeconf, cls, "codeblock")
    add_value_command(Typeconf, cls, "luaname", function (_, v) return v end)
    add_value_command(Typeconf, cls, "maincls", function (_, v) return v end)
    add_value_command(Typeconf, cls.options, "indexerror")
    add_value_command(Typeconf, cls.options, "fromtable", checkboolean)
    add_value_command(Typeconf, cls.options, "packable", checkboolean)
    add_value_command(Typeconf, cls.options, "packvars", checkinteger)

    ---Extend a c++ class with another class, all static members of `extcls`
    ---will be copied to the current class.
    ---@param extcls string
    ---@return idl.Typeconf
    function Typeconf.extend(extcls)
        cls.extends:set(extcls, true)
        typeconf(extcls)
            .maincls(cls)
        return Typeconf
    end

    ---Exclude members from a c++ class, support lua regex.
    ---@param name string
    function Typeconf.exclude(name)
        if mode and mode ~= "exclude" then
            olua.unuse(cls) -- get cls as upvalue
            olua.error("can't use .include and .exclude at the same time in typeconf '${cls.cppcls}'")
        end
        mode = "exclude"
        if name == "*" or not name:find("[^_%w]") then
            cls.excludes:set(name, true)
        else
            cls.wildcards:set(name, true)
        end
        return Typeconf
    end

    ---Include members from a c++ class.
    function Typeconf.include(name)
        if mode and mode ~= "include" then
            olua.unuse(cls) -- get cls as upvalue
            olua.error("can't use .include and .exclude at the same time in typeconf '${cls.cppcls}'")
        end
        mode = "include"
        cls.includes:set(name, true)
        return Typeconf
    end

    ---@param cond string
    function Typeconf.macro(cond)
        if #cond > 0 then
            macros:push(cond)
        else
            macros:pop()
        end
        return Typeconf
    end

    ---Define a enum value.
    ---@param name string
    ---@return idl.TypeconfEnum
    function Typeconf.enum(name)
        return typeconf_enum(Typeconf, cls, name)
    end

    function Typeconf.const(name)
        return typeconf_const(Typeconf, cls, name)
    end

    ---@param name string
    ---@return TypeconfFunc
    function Typeconf.func(name)
        cls.excludes:replace(name, true)
        if #macros > 0 then
            cls.macros:set(name, { name = name, value = macros:at(-1) })
        end
        return typeconf_func(Typeconf, cls, name)
    end

    ---@param name string
    ---@return idl.typeconf.Callback
    function Typeconf.callback(name)
        return typeconf_callback(Typeconf, cls, name)
    end

    ---@param name string
    ---@return idl.TypeconfProp
    function Typeconf.prop(name)
        return typeconf_prop(Typeconf, cls, name)
    end

    ---@param name string
    ---@return idl.TypeconfVar
    function Typeconf.var(name)
        return typeconf_var(Typeconf, cls, name)
    end

    function Typeconf.alias(name)
        return typeconf_alian(Typeconf, cls, name)
    end

    return Typeconf
end

---Config a c++ class without export any members.
---@param cppcls string
function typeonly(cppcls)
    local cls = typeconf(cppcls)
    cls.exclude "*"
    return cls
end

---@param cppcls string
---@param fromcls idl.TypeconfDescriptor
function idl.typecopy(cppcls, fromcls)
    typeconf(cppcls)

    ---@type idl.TypeconfDescriptor
    local cls = idl.current_module.class_types:get(cppcls)
    for k, v in pairs(fromcls) do
        if k == "cppcls" or k == "luacls" then
            goto continue
        end
        if type(v) == "table" then
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

return idl
