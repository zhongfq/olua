_ENV.olua_clang_args = {}

_ENV.olua_modules = olua.ordered_map()

---@type ModuleDescriptor
local current_module = _ENV.current_module

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
    if not (type(v) == "number" and v == math.floor(v)) then
        error_value(key, v, "integer")
    end
    return v
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
    if not current_module then
        error("You should define a module!!!")
    end
end

---@param args string[]
function clang(args)
    _ENV.clang_args = args
end

---Define config module.
---@param name string
function module(name)
    ---@class ModuleDescriptor
    ---@field name string
    ---@field codeblock? string
    ---@field outputdir? string
    ---@field apidir? string
    ---@field luaopen? string
    ---@field entry? string
    ---@field luacls fun(cppcls:string):string
    current_module = {
        name = name,
        class_types = olua.ordered_map(),
        wildcard_types = olua.ordered_map(),
        typedef_types = olua.ordered_map(),
        type_convs = olua.ordered_map(),
        luacls = function (cppcls)
            return string.gsub(cppcls, "::", ".")
        end,
    }
    olua_modules:set(name, current_module)
end

---Insert codes into the beginning of generated file.
---@param codeblock string
function codeblock(codeblock)
    check_module()
    current_module.codeblock = codeblock
end

---Insert codes into the `luaopen_[moudle]` function.
---@param luaopen string
function luaopen(luaopen)
    check_module()
    current_module.luaopen = luaopen
end

---Specify the entry `class`, when you require a module, return this `class`.
---@param cppcls string
function entry(cppcls)
    check_module()
    current_module.entry = checkstring(cppcls)
end

---@param dir string
function outputdir(dir)
    check_module()
    current_module.outputdir = dir
end

---@param dir string
function apidir(dir)
    check_module()
    current_module.apidir = dir
end

---@param maker fun(cppcls:string):string
function luacls(maker)
    check_module()
    current_module.luacls = maker
end

function exclude_type(tn)
end

---
--- Define a type convertor.
---
---@param cppcls string C++ class name
---@return Typedef
function typedef(cppcls)
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
        -- c = olua.pretty_typename(c)
        local t = setmetatable({ cppcls = c }, { __index = cls })
        m.typedef_types:set(c, t)
        m.type_convs:set(c, t)
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
    add_value_command(Typedef, cls, "packable")
    add_value_command(Typedef, cls, "packvars")
    add_value_command(Typedef, cls, "smartptr")
    add_value_command(Typedef, cls, "override")

    return Typedef
end

-------------------------------------------------------------------------------
-- typeconf
-------------------------------------------------------------------------------

---Set attribute for c++ function parameters or return value.
---@alias TypeconfFuncAttr fun(attr:string):TypeconfFunc

---@class TypeconfFuncBase : Typeconf
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
---@param cls TypeconfDescriptor
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
---@param cls TypeconfDescriptor
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


---@param cmd Typeconf
---@param cls TypeconfDescriptor
---@param name string
---@return TypeconfFunc
local function typedef_func(cmd, cls, name)
    ---@class TypeconfFuncDescriptor
    local func = {
        name = name,
        ---@type string|nil
        body = nil
    }

    ---@class TypeconfFunc : TypeconfFuncBase
    ---@field body fun(body:string):TypeconfFunc
    local TypeconfFunc = {}

    add_value_command(TypeconfFunc, func, "body")
    add_attr_command(TypeconfFunc, cls, func, name)
    add_insert_command(TypeconfFunc, cls, func, name)

    ---@type TypeconfFunc
    return setmetatable(TypeconfFunc, { __index = cmd })
end

---@param cmd Typeconf
---@param cls TypeconfDescriptor
---@param name string
---@return typeconf.Callback
local function typedef_callback(cmd, cls, name)
    ---@class TypeconfCallbackDescriptor
    local callback = {
        name = name,
        tag_scope = "object",
        localvar = true,
    }

    ---@class typeconf.Callback : TypeconfFuncBase
    ---@field localvar fun(localvar:booltype):typeconf.Callback
    ---@field tag_maker fun(tag_maker:string):typeconf.Callback
    ---@field tag_mode fun(tag_mode:string):typeconf.Callback
    local TypeconfCallback = {}

    add_value_command(TypeconfCallback, callback, "localvar", checkboolean)
    add_value_command(TypeconfCallback, callback, "tag_maker")
    add_value_command(TypeconfCallback, callback, "tag_mode")
    add_attr_command(TypeconfCallback, cls, callback, name)
    add_insert_command(TypeconfCallback, cls, callback, name)

    ---Specify where to store the callback.
    ---* `-1`: Store callback in return value.
    ---* `0`: Store callback in `.classobj` when it is a static function, otherwise store in `self` value.
    ---* `1,2,...N`: Store callback in the `N` argument value.
    ---@param store integer
    ---@return typeconf.Callback
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

    ---@type typeconf.Callback
    return setmetatable(TypeconfCallback, { __index = cmd })
end

---
---config a c++ class
---
---@param cppcls string the c++ class name
---@return Typeconf
function typeconf(cppcls)
    ---@class TypeconfDescriptor
    ---@field kind integer
    ---@field supercls? string
    ---@field comment? string
    ---@field funcdecl? string # std::function declaration
    ---@field luacls? string
    local cls = {
        ---@type string c++ full class name
        cppcls = cppcls,
        ---@type string lua class name
        luacls = m.luacls(cppcls),
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

    if cppcls:find("[%^%%%$%*%+]") then -- ^%$*+
        current_module.wildcard_types:set(cppcls, cls)
    else
        current_module.class_types:set(cppcls, cls)
    end

    ---@class TypeconfEnum : Typeconf
    ---@field value fun(value:string):TypeconfEnum
    local TypeconfEnum = {}

    ---@class TypeconfConst : Typeconf
    ---@field value fun(value:string):TypeconfConst
    ---@field typename fun(typename:string):TypeconfConst
    local TypeconfConst = {}

    ---@class Typeconf
    ---@field supercls fun(supercls:string):Typeconf
    ---@field luaopen fun(luaopen:string):Typeconf
    ---@field chunk fun(chunk:string):Typeconf
    ---@field luaname fun(maker:fun(cppcls:string):string):Typeconf
    ---@field indexerror fun(mode:"r" | "w" | "rw"):Typeconf
    ---@field fromtable fun(fromtable:booltype):Typeconf
    ---@field packable fun(packable:booltype):Typeconf
    ---@field packvars fun(packvars:string):Typeconf
    ---@field private maincls fun(cls:string):Typeconf
    ---@field extend fun(cls:string):Typeconf
    ---@field exclude fun(name:string):Typeconf
    ---@field include fun(name:string):Typeconf
    ---@field macro fun(name:string):Typeconf
    ---@field enum fun(name:string):TypeconfEnum
    ---@field const fun(name:string):TypeconfConst
    local Typeconf = {}

    ---@param name string
    ---@return TypeconfFunc
    function Typeconf.func(name)
        return typedef_func(Typeconf, cls, name)
    end

    ---@param name string
    ---@return typeconf.Callback
    function Typeconf.callback(name)
        return typedef_callback(Typeconf, cls, name)
    end

    return Typeconf
end
