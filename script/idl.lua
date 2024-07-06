local idl = {
    clang_args = olua.array(),
    modules = olua.ordered_map(false),
    exclude_types = olua.ordered_map(false),
    type_convs = olua.ordered_map(false),
    macros = olua.array(),

    ---@type idl.model.module_desc?
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
    ---@class idl.model.module_desc
    ---@field path string # Module config file path.
    ---@field name string
    ---@field headers? string
    ---@field filepath? string
    ---@field codeblock? string
    ---@field output_dir? string
    ---@field api_dir? string
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
function output_dir(dir)
    check_module()
    idl.current_module.output_dir = dir
end

---@param dir string
function api_dir(dir)
    check_module()
    idl.current_module.api_dir = dir
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
---@return idl.typedef
function typedef(cppcls)
    check_module()

    ---@class idl.model.typedef_desc
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

    ---@class idl.typedef
    ---@field luacls fun(luacls:string):idl.typedef
    ---@field conv fun(conv:string):idl.typedef
    ---@field luatype fun(luatype:luatype):idl.typedef
    ---@field packable fun(packable:booltype):idl.typedef
    ---@field packvars fun(packvars:string):idl.typedef
    ---@field smartptr fun(smartptr:booltype):idl.typedef
    ---@field override fun(override:booltype):idl.typedef
    local CMD = {}

    add_value_command(CMD, cls, "luacls")
    add_value_command(CMD, cls, "conv")
    add_value_command(CMD, cls, "luatype")
    add_value_command(CMD, cls, "packable", checkboolean)
    add_value_command(CMD, cls, "packvars", checkinteger)
    add_value_command(CMD, cls, "smartptr", checkboolean)
    add_value_command(CMD, cls, "override", checkboolean)

    return CMD
end

-------------------------------------------------------------------------------
-- typeconf
-------------------------------------------------------------------------------

---@class idl.model.class_option
---@field reg_luatype? boolean
---@field indexerror? "r" | "w" | "rw"
---@field fromtable? boolean

---@class idl.model.type_model
---@field type string
---@field name? string
---@field comment? string
---@field attr? string

---@class idl.model.func_model
---@field cppfunc string
---@field luafunc string
---@field prototype string
---@field funcdesc string
---@field comment? string
---@field macro? string
---@field is_exposed? boolean
---@field is_static? boolean
---@field is_contructor? boolean
---@field is_variadic? boolean
---@field ret idl.model.type_model
---@field args idl.model.type_model[]
---@field tag_scope? idl.callback_tag_scope
---@field tag_mode? idl.callback_tag_mode
---@field tag_maker? string
---@field tag_store? integer
---@field localvar? boolean
---@field insert_before? string
---@field insert_after? string
---@field insert_cbefore? string
---@field insert_cafter? string

---@class idl.model.class_model
---@field cppcls string
---@field options idl.model.class_option
---@field comment? string
---@field funcs table<string, idl.model.func_model[]>

---Set attribute for c++ function parameters or return value.
---@alias idl.typeconf.func_attr fun(attr:string):idl.typeconf.func

---@class idl.typeconf.func_base : idl.typeconf
---@field insert_before fun(code:string):idl.typeconf.func # Insert codes before the c++ function invoked.
---@field insert_after fun(code:string):idl.typeconf.func # Insert codes after the c++ function invoked.
---@field insert_cbefore fun(code:string):idl.typeconf.func # Insert codes before the c++ callback function invoked.
---@field insert_cafter fun(code:string):idl.typeconf.func # Insert codes after the c++ callback function invoked.
---@field ret idl.typeconf.func_attr
---@field arg1 idl.typeconf.func_attr
---@field arg2 idl.typeconf.func_attr
---@field arg3 idl.typeconf.func_attr
---@field arg4 idl.typeconf.func_attr
---@field arg5 idl.typeconf.func_attr
---@field arg6 idl.typeconf.func_attr
---@field arg7 idl.typeconf.func_attr
---@field arg8 idl.typeconf.func_attr
---@field arg9 idl.typeconf.func_attr
---@field arg10 idl.typeconf.func_attr
---@field package optional fun(optional:boolean):idl.typeconf.func
---@field package readonly fun(readonly:boolean):idl.typeconf.func

---@param CMD idl.typeconf.func_base
---@param cls idl.model.class_desc
---@param func idl.model.func_desc|idl.model.callback_desc
---@param name string
local function add_insert_command(CMD, cls, func, name)
    ---@class TypeconfInsertDescriptor
    ---@field name string
    ---@field before? string
    ---@field after? string
    ---@field cbefore? string
    ---@field cafter? string
    local entry = { name = name }
    cls.inserts:set(name, entry)

    add_value_command(CMD, entry, "insert_before", nil, "before")
    add_value_command(CMD, entry, "insert_after", nil, "after")
    add_value_command(CMD, entry, "insert_cbefore", nil, "cbefore")
    add_value_command(CMD, entry, "insert_cafter", nil, "cafter")
end

---@param CMD idl.typeconf.func_base
---@param cls idl.model.class_desc
---@param func idl.model.func_desc|idl.model.callback_desc
---@param name string
local function add_attr_command(CMD, cls, func, name)
    ---@class idl.model.attr_desc
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

    add_value_command(CMD, entry, "optional", checkboolean)
    add_value_command(CMD, entry, "readonly", checkboolean)
    add_value_command(CMD, entry, "ret")
    add_value_command(CMD, entry, "arg1")
    add_value_command(CMD, entry, "arg2")
    add_value_command(CMD, entry, "arg3")
    add_value_command(CMD, entry, "arg4")
    add_value_command(CMD, entry, "arg5")
    add_value_command(CMD, entry, "arg6")
    add_value_command(CMD, entry, "arg7")
    add_value_command(CMD, entry, "arg8")
    add_value_command(CMD, entry, "arg9")
    add_value_command(CMD, entry, "arg10")
end


---@param parent idl.typeconf
---@param cls idl.model.class_desc
---@param name string
---@return idl.typeconf.func
local function typeconf_func(parent, cls, name)
    ---@class idl.model.func_desc
    local func = {
        name = name,
        ---@type string|nil
        body = nil
    }
    cls.funcs:set(name, func)

    ---@class idl.typeconf.func : idl.typeconf.func_base
    local CMD = {}

    ---@param body string
    function CMD.body(body)
        func.body = olua.trim(body)
        return CMD
    end

    add_attr_command(CMD, cls, func, name)
    add_insert_command(CMD, cls, func, name)

    ---@type idl.typeconf.func
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.typeconf
---@param cls idl.model.class_desc
---@param name string
---@return idl.typeconf.callback
local function typeconf_callback(parent, cls, name)
    ---@class idl.model.callback_desc
    local callback = {
        name = name,
        tag_scope = "object",
        localvar = true,
    }
    cls.callbacks:set(name, callback)

    ---@class idl.typeconf.callback : idl.typeconf.func_base
    ---@field localvar fun(localvar:booltype):idl.typeconf.callback
    local CMD = {}

    add_value_command(CMD, callback, "localvar", checkboolean)
    add_attr_command(CMD, cls, callback, name)
    add_insert_command(CMD, cls, callback, name)


    ---Make callback key.
    ---@param maker string|string[]
    function CMD.tag_maker(maker)
        callback.tag_maker = maker
        return CMD
    end

    ---@alias idl.callback_tag_mode
    ---|>'"startwith"'
    ---| '"equal"'
    ---| '"new"'
    ---| '"replace"'

    ---@alias idl.callback_tag_scope
    ---|>'"once"'       # Remove callback after the callback invoked.
    ---| '"function"'   # Remove callback after the c++ function invoked.
    ---| '"object"'     # Callback will exist until the c++ object die.

    ---How to store or remove the callback.
    ---@param mode idl.callback_tag_mode|idl.callback_tag_mode[]
    ---@return idl.typeconf.callback
    function CMD.tag_mode(mode)
        callback.tag_mode = mode
        return CMD
    end

    ---Specify where to store the callback.
    ---* `-1`: Store callback in return value.
    ---* `0`: Store callback in `.classobj` when it is a static function, otherwise store in `self` value.
    ---* `1,2,...N`: Store callback in the `N` argument value.
    ---@param store string
    ---@return idl.typeconf.callback
    function CMD.tag_store(store)
        callback.tag_store = checkinteger("tag_store", store)
        return CMD
    end

    ---Mark the lifecycle of the callback, default is `object`.
    ---@param scope idl.callback_tag_scope
    function CMD.tag_scope(scope)
        callback.tag_scope = checkstring("tag_scope", scope)
        return CMD
    end

    ---@type idl.typeconf.callback
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.typeconf
---@param cls idl.model.class_desc
---@param name string
---@return idl.typeconf.enum
local function typeconf_enum(parent, cls, name)
    ---@class idl.model.enum_desc
    ---@field name string
    ---@field value string
    ---@field comment? string
    local enum = { name = name }
    cls.enums:set(name, enum)

    ---@class idl.typeconf.enum : idl.typeconf
    ---@field value fun(value:string):idl.typeconf.enum
    local CMD = {}

    add_value_command(CMD, enum, "value")
    add_value_command(CMD, enum, "comment")

    ---@type idl.typeconf.enum
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.typeconf
---@param cls idl.model.class_desc
---@param name string
local function typeconf_const(parent, cls, name)
    ---@class idl.model.const_desc
    ---@field value string
    ---@field typename string
    local const = { name = name }
    cls.consts:set(name, const)

    ---@class idl.typeconf.const : idl.typeconf
    ---@field value fun(value:string):idl.typeconf.const
    ---@field typename fun(typename:string):idl.typeconf.const
    local CMD = {}
    add_value_command(CMD, const, "value")
    add_value_command(CMD, const, "typename")

    ---@type idl.typeconf.const
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.typeconf
---@param cls idl.model.class_desc
---@param name string
local function typeconf_prop(parent, cls, name)
    ---@class idl.model.prop_desc
    ---@field get string
    ---@field set string
    local prop = { name = name }

    cls.props:set(name, prop)

    ---@class idl.typeconf.prop : idl.typeconf
    ---@field get fun(get:string):idl.typeconf.prop
    ---@field set fun(get:string):idl.typeconf.prop
    local CMD = {}

    add_value_command(CMD, prop, "get")
    add_value_command(CMD, prop, "set")

    ---@type idl.typeconf.prop
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.typeconf
---@param cls idl.model.class_desc
---@param name string
local function typeconf_var(parent, cls, name)
    ---@class idl.model.var_desc
    ---@field body string
    local var = { name = name }

    if name ~= "*" then
        cls.excludes:replace(name, true)
        cls.vars:set(name, var)
    else
        name = "var*"
    end

    ---@class idl.typeconf.var : idl.typeconf
    ---@field body fun(body:string):idl.typeconf.var
    ---@field ret fun(attr:string):idl.typeconf.var
    ---@field optional fun(optional:booltype):idl.typeconf.var
    ---@field readonly fun(readonly:booltype):idl.typeconf.var
    local CMD = {}

    local attr = {}
    cls.attrs:set(name, attr)

    add_value_command(CMD, var, "body")
    add_value_command(CMD, attr, "optional", checkboolean)
    add_value_command(CMD, attr, "readonly", checkboolean)
    add_value_command(CMD, attr, "ret")

    ---@type idl.typeconf.var
    return setmetatable(CMD, { __index = parent })
end

---
---Config a c++ class
---
---@param cppcls string the c++ class name
---@return idl.typeconf
function typeconf(cppcls)
    check_module()

    ---@class idl.model.class_desc
    ---@field kind integer
    ---@field supercls? string
    ---@field comment? string
    ---@field funcdecl? string # std::function declaration
    ---@field luacls? string
    ---@field maincls? string
    local cls = {
        ---@type string c++ full class name
        cppcls = cppcls,
        ---@type string lua class name
        luacls = idl.current_module.luacls(cppcls),
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
        inserts = olua.ordered_map(),
        macros = olua.ordered_map(),
        supers = olua.ordered_map(),
        template_types = olua.ordered_map(),
        options = { reg_luatype = true, fromtable = true },
        ---@type fun(name:string, kind?:'func'|'var'|'enum'):string
        luaname = function (name, kind) return name end,

        ---@type idl.model.class_model
        model = {
            cppcls = cppcls,
            options = {},
            funcs = {},
            props = {},
            vars = {},
        }
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

    ---@class idl.typeconf
    ---@field luaopen fun(luaopen:string):idl.typeconf
    ---@field codeblock fun(codeblock:string):idl.typeconf
    ---@field luaname fun(maker:fun(cppcls:string, kind?:'func'|'var'|'enum'):string):idl.typeconf
    ---@field indexerror fun(mode:"r" | "w" | "rw"):idl.typeconf
    ---@field fromtable fun(fromtable:booltype):idl.typeconf
    ---@field packable fun(packable:booltype):idl.typeconf
    ---@field packvars fun(packvars:string):idl.typeconf
    ---@field private maincls fun(cls:idl.model.class_desc):idl.typeconf
    local CMD = {}

    add_value_command(CMD, cls, "luaopen")
    add_value_command(CMD, cls, "codeblock")
    add_value_command(CMD, cls, "luaname", function (_, v) return v end)
    add_value_command(CMD, cls, "maincls", function (_, v) return v end)
    add_value_command(CMD, cls.options, "indexerror")
    add_value_command(CMD, cls.options, "fromtable", checkboolean)
    add_value_command(CMD, cls.options, "packable", checkboolean)
    add_value_command(CMD, cls.options, "packvars", checkinteger)

    ---Extend a c++ class with another class, all static members of `extcls`
    ---will be copied into the current class.
    ---@param extcls string
    ---@return idl.typeconf
    function CMD.extend(extcls)
        cls.extends:set(extcls, true)
        typeconf(extcls)
            .maincls(cls)
        return CMD
    end

    ---Exclude members from a c++ class, support lua regex.
    ---@param name string
    ---@return idl.typeconf
    function CMD.exclude(name)
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
        return CMD
    end

    ---Include members from a c++ class. If use `include`, all members of `class` don't included will be ignored.
    ---@param name string
    ---@return idl.typeconf
    function CMD.include(name)
        if mode and mode ~= "include" then
            olua.unuse(cls) -- get cls as upvalue
            olua.error("can't use .include and .exclude at the same time in typeconf '${cls.cppcls}'")
        end
        mode = "include"
        cls.includes:set(name, true)
        return CMD
    end

    ---@param cond string
    ---@return idl.typeconf
    function CMD.macro(cond)
        if #cond > 0 then
            macros:push(cond)
        else
            macros:pop()
        end
        return CMD
    end

    ---Define a enum value.
    ---@param name string
    ---@return idl.typeconf.enum
    function CMD.enum(name)
        return typeconf_enum(CMD, cls, name)
    end

    ---Define a const value.
    ---@param name string
    ---@return idl.typeconf.const
    function CMD.const(name)
        return typeconf_const(CMD, cls, name)
    end

    ---@param name string
    ---@return idl.typeconf.func
    function CMD.func(name)
        cls.excludes:replace(name, true)
        if #macros > 0 then
            cls.macros:set(name, { name = name, value = macros:at(-1) })
        end
        return typeconf_func(CMD, cls, name)
    end

    ---@param name string
    ---@return idl.typeconf.callback
    function CMD.callback(name)
        return typeconf_callback(CMD, cls, name)
    end

    ---@param name string
    ---@return idl.typeconf.prop
    function CMD.prop(name)
        return typeconf_prop(CMD, cls, name)
    end

    ---@param name string
    ---@return idl.typeconf.var
    function CMD.var(name)
        return typeconf_var(CMD, cls, name)
    end

    return CMD
end

---Config a c++ class without export any members.
---@param cppcls string
function typeonly(cppcls)
    local cls = typeconf(cppcls)
    cls.exclude "*"
    return cls
end

---@param cppcls string
---@param fromcls idl.model.class_desc
---@return idl.typeconf
function idl.typecopy(cppcls, fromcls)
    local CMD = typeconf(cppcls)

    local cls = idl.current_module.class_types:get(cppcls) ---@type idl.model.class_desc
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

    return CMD
end

return idl
