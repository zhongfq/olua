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

---@alias integertype string

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
    ---@field codeblock? string
    ---@field output_dir? string
    ---@field api_dir? string
    ---@field luaopen? string
    ---@field entry? string
    ---@field luacls fun(cxxcls:string):string
    idl.current_module = {
        name = name,
        class_types = olua.ordered_map(false),
        wildcard_types = olua.ordered_map(),
        typedef_types = olua.ordered_map(),
        luacls = function (cxxcls)
            return string.gsub(cxxcls, "::", ".")
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
    idl.current_module.codeblock = olua.trim(codeblock)
end

---Insert codes into the `luaopen_[moudle]` function.
---@param luaopen string
function luaopen(luaopen)
    check_module()
    idl.current_module.luaopen = olua.trim(luaopen)
end

---Specify the entry `class`, when you require a module, return this `class`.
---@param cxxcls string
function entry(cxxcls)
    check_module()
    idl.current_module.entry = checkstring("entry", cxxcls)
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

---@param maker fun(cxxcls:string):string
function luacls(maker)
    check_module()
    idl.current_module.luacls = maker
end

---@param cxxcls string
function exclude_type(cxxcls)
    idl.exclude_types:replace(olua.pretty_typename(cxxcls), true)
    idl.exclude_types:replace(olua.pretty_typename(cxxcls .. " *"), true)
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
---@param cxxcls string C++ class name
---@return idl.typedef
function typedef(cxxcls)
    check_module()

    ---@class idl.model.typedef_desc
    ---@field cxxcls string
    ---@field conv string
    ---@field luacls? string
    ---@field luatype? string
    ---@field packable? boolean
    ---@field packvars? integer
    ---@field smartptr? boolean
    ---@field override? boolean
    local cls = { cxxcls = cxxcls }

    for c in cxxcls:gmatch("[^;\n\r]+") do
        c = olua.pretty_typename(c)
        local t = setmetatable({ cxxcls = c }, { __index = cls })
        idl.current_module.typedef_types:set(c, t)
        idl.type_convs:set(c, t)
    end

    ---@class idl.typedef
    ---@field luacls fun(luacls:string):idl.typedef
    ---@field conv fun(conv:string):idl.typedef
    ---@field luatype fun(luatype:luatype):idl.typedef
    ---@field packable fun(packable:booltype):idl.typedef
    ---@field packvars fun(packvars:integertype):idl.typedef
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

---@class idl.model.type_desc
---@field type string
---@field name? string
---@field comment? string
---@field attr olua.array

---@class idl.model.func_desc
---@field cxxfn string # C++ function name
---@field luafn? string # Lua function name
---@field prototype? string # C++ prototype
---@field display_name? string # C++ prototype without return type
---@field comment? string
---@field luacats? string
---@field macro? string
---@field is_exposed? boolean
---@field is_static? boolean
---@field is_extended? boolean
---@field is_contructor? boolean
---@field is_variable? boolean
---@field is_variadic? boolean
---@field ret idl.model.type_desc
---@field args olua.array # idl.model.type_desc[]
---@field body? string
---@field insert_before? string
---@field insert_after? string
---@field insert_cbefore? string
---@field insert_cafter? string
---@field tag_scope? idl.callback_tag_scope
---@field tag_store? integer
---@field tag_mode? idl.callback_tag_mode
---@field tag_maker? string
---@field tag_usepool? boolean

---@class idl.model.prop_desc
---@field name string
---@field get string
---@field set? string

---@class idl.model.var_desc
---@field name string
---@field get string
---@field set? string

---@class idl.model.const_desc
---@field name string
---@field type string
---@field value string
---@field comment? string

---@param CMD idl.cmd.member
---@param member idl.conf.member_desc
---@param name string
---@param store_name? string
local function add_attr_command(CMD, member, name, store_name)
    local attr = olua.array()
    member.attrs:set(store_name or name, attr)

    CMD[name] = function (str)
        str = checkstring(name, str)
        for v in string.gmatch(str, "@[^@]+") do
            attr:push(v)
        end
        return CMD
    end
end

local function typeconf_member(parent, cls, name)
    ---@class idl.cmd.member : idl.cmd.typeconf
    local CMD = {}

    ---@class idl.conf.inst_desc
    ---@field cxxfn string
    ---@field type string

    ---@class idl.conf.member_desc
    ---@field body? string
    ---@field macro? string
    ---@field index? integer
    ---@field CMD idl.cmd.member
    local member = {
        name = name,
        attrs = olua.ordered_map(),
        insts = olua.array(), --@type idl.conf.inst_desc[]
        CMD = CMD,
    }
    cls.conf.members:set(name, member)

    ---@param body string
    function CMD.body(body)
        member.body = olua.trim(body)
        return CMD
    end

    ---LuaCAST
    ---@param luacats string
    ---@return idl.cmd.member
    function CMD.luacats(luacats)
        member.luacats = olua.trim(checkstring("luacats", luacats))
        return CMD
    end

    ---@alias idl.callback_tag_scope
    ---|>'"once"'       # Remove callback after the callback invoked.
    ---| '"invoker"'    # Remove callback after the c++ function invoked.
    ---| '"object"'     # Callback will exist until the c++ object die.

    ---@param scope idl.callback_tag_scope
    ---@return idl.cmd.member
    function CMD.tag_scope(scope)
        ---@type idl.callback_tag_scope
        member.tag_scope = checkstring("tag_scope", scope)
        return CMD
    end

    ---Specify where to store the callback.
    ---* `-1`: Store callback in return value.
    ---* `0`: Store callback in `.classobj` when it is a static function, otherwise store in `self` value.
    ---* `1,2,...N`: Store callback in the `N` argument value.
    ---@param store integertype
    ---@return idl.cmd.member
    function CMD.tag_store(store)
        member.tag_store = checkinteger("callback_store", store)
        return CMD
    end

    ---@alias idl.callback_tag_mode
    ---|>'"startwith"'
    ---| '"equal"'
    ---| '"new"'
    ---| '"replace"'

    ---How to store or remove the callback.
    ---@param mode idl.callback_tag_mode
    ---@return idl.cmd.member
    function CMD.tag_mode(mode)
        ---@type idl.callback_tag_mode
        member.tag_mode = checkstring("tag_mode", mode)
        return CMD
    end

    ---Make callback key.
    ---@param maker string
    ---@return idl.cmd.member
    function CMD.tag_maker(maker)
        member.tag_maker = checkstring("tag_maker", maker)
        return CMD
    end

    ---Use object pool in callback, default is `true`.
    ---@param usepool booltype
    ---@return idl.cmd.member
    function CMD.tag_usepool(usepool)
        member.tag_usepool = checkboolean("tag_usepool", usepool)
        return CMD
    end

    ---Insert codes before the c++ function invoked.
    ---@param code string
    ---@return idl.cmd.member
    function CMD.insert_before(code)
        member.insert_before = olua.trim(code)
        return CMD
    end

    ---Insert codes after the c++ function invoked.
    ---@param code string
    ---@return idl.cmd.member
    function CMD.insert_after(code)
        member.insert_after = olua.trim(code)
        return CMD
    end

    ---Insert codes before the c++ callback function invoked.
    ---@param code string
    ---@return idl.cmd.member
    function CMD.insert_cbefore(code)
        member.insert_cbefore = olua.trim(code)
        return CMD
    end

    ---Insert codes after the c++ callback function invoked.
    ---@param code string
    ---@return idl.cmd.member
    function CMD.insert_cafter(code)
        member.insert_cafter = olua.trim(code)
        return CMD
    end

    ---@type idl.cmd.member
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.cmd.typeconf
---@param cls idl.model.class_desc
---@param name string
---@return idl.cmd.func
local function typeconf_func(parent, cls, name)
    ---@class idl.cmd.func : idl.cmd.member
    ---@field body fun(body:string):idl.cmd.func
    ---@field luacats fun(luacats:string):idl.cmd.func
    ---@field tag_scope fun(store:idl.callback_tag_scope):idl.cmd.func
    ---@field tag_store fun(store:integertype):idl.cmd.func
    ---@field tag_mode fun(mode:idl.callback_tag_mode):idl.cmd.func
    ---@field tag_maker fun(maker:string):idl.cmd.func
    ---@field tag_usepool fun(usepool:booltype):idl.cmd.func
    ---@field insert_before fun(code:string):idl.cmd.func
    ---@field insert_after fun(code:string):idl.cmd.func
    ---@field insert_cbefore fun(code:string):idl.cmd.func
    ---@field insert_cafter fun(code:string):idl.cmd.func
    ---@field ret fun(attr:string):idl.cmd.func
    ---@field arg1 fun(attr:string):idl.cmd.func
    ---@field arg2 fun(attr:string):idl.cmd.func
    ---@field arg3 fun(attr:string):idl.cmd.func
    ---@field arg4 fun(attr:string):idl.cmd.func
    ---@field arg5 fun(attr:string):idl.cmd.func
    ---@field arg6 fun(attr:string):idl.cmd.func
    ---@field arg7 fun(attr:string):idl.cmd.func
    ---@field arg8 fun(attr:string):idl.cmd.func
    ---@field arg9 fun(attr:string):idl.cmd.func
    ---@field arg10 fun(attr:string):idl.cmd.func
    local CMD = typeconf_member(parent, cls, name)

    ---@type idl.conf.member_desc
    local member = cls.conf.members:get(name)

    add_attr_command(CMD, member, "ret")
    add_attr_command(CMD, member, "arg1")
    add_attr_command(CMD, member, "arg2")
    add_attr_command(CMD, member, "arg3")
    add_attr_command(CMD, member, "arg4")
    add_attr_command(CMD, member, "arg5")
    add_attr_command(CMD, member, "arg6")
    add_attr_command(CMD, member, "arg7")
    add_attr_command(CMD, member, "arg8")
    add_attr_command(CMD, member, "arg9")
    add_attr_command(CMD, member, "arg10")

    ---Instantiate the template function, `fn` contains the new function name and argument type.
    ---
    ---eg: `get<T> => getString<std::string>`
    ---@param fn string
    ---@return idl.cmd.func
    function CMD.inst(fn)
        local cxxfn, type = fn:match("([^<]+)<(.+)>")
        olua.assert(cxxfn and not type:find(","), "invalid template function: ${fn}")
        member.insts:push({ cxxfn = cxxfn, type = type })
        cls.conf.excludes:set(cxxfn, true)
        return CMD
    end

    ---@type idl.cmd.func
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.cmd.typeconf
---@param cls idl.model.class_desc
---@param name string
local function typeconf_var(parent, cls, name)
    ---@class idl.cmd.var : idl.cmd.member
    ---@field luacats fun(luacats:string):idl.cmd.var
    ---@field tag_scope fun(store:idl.callback_tag_scope):idl.cmd.var
    ---@field tag_store fun(store:integertype):idl.cmd.var
    ---@field tag_mode fun(mode:idl.callback_tag_mode):idl.cmd.var
    ---@field tag_maker fun(maker:string):idl.cmd.var
    ---@field tag_usepool fun(usepool:booltype):idl.cmd.var
    ---@field insert_before fun(code:string):idl.cmd.var
    ---@field insert_after fun(code:string):idl.cmd.var
    ---@field insert_cbefore fun(code:string):idl.cmd.var
    ---@field insert_cafter fun(code:string):idl.cmd.var
    ---@field attr fun(attr:string):idl.cmd.var
    ---@field index fun(index:integertype):idl.cmd.var
    local CMD = typeconf_member(parent, cls, name)

    ---@type idl.conf.member_desc
    local member = cls.conf.members:get(name)

    add_attr_command(CMD, member, "attr", "var")
    add_value_command(CMD, member, "index", checkinteger)

    ---@type idl.cmd.var
    return setmetatable(CMD, { __index = parent })
end

---@param parent idl.cmd.typeconf
---@param cls idl.model.class_desc
---@param name string
local function typeconf_prop(parent, cls, name)
    ---@class idl.conf.prop_desc
    ---@field get string
    ---@field set? string
    local prop = { name = name }

    cls.conf.props:set(name, prop)

    ---@class idl.cmd.prop : idl.cmd.typeconf
    ---@field get fun(get:string):idl.cmd.prop
    ---@field set fun(get:string):idl.cmd.prop
    local CMD = {}

    ---@param get string
    ---@return idl.cmd.prop
    function CMD.get(get)
        prop.get = olua.trim(get)
        return CMD
    end

    ---@param set string
    ---@return idl.cmd.prop
    function CMD.set(set)
        prop.set = olua.trim(set)
        return CMD
    end

    ---@type idl.cmd.prop
    return setmetatable(CMD, { __index = parent })
end

---
---Config a c++ class
---
---@param cxxcls string the c++ class name
---@return idl.cmd.typeconf
function typeconf(cxxcls)
    check_module()

    ---@class idl.cmd.typeconf
    ---@field luaname fun(maker:fun(cxxcls:string, kind?:'func'|'var'|'enum'):string):idl.cmd.typeconf
    ---@field indexerror fun(mode:"r" | "w" | "rw"):idl.cmd.typeconf
    ---@field packable fun(packable:booltype):idl.cmd.typeconf
    ---@field packvars fun(packvars:string):idl.cmd.typeconf
    ---@field private maincls fun(cls:idl.model.class_desc):idl.cmd.typeconf
    local CMD = {}

    ---@class idl.conf.typeconf_desc
    ---@field kind integer
    ---@field luacls string
    ---@field maincls? idl.model.class_desc
    ---@field funcdecl? string # std::function declaration
    ---@field conv string
    local conf = {
        luacls = idl.current_module.luacls(cxxcls),
        conv = "olua_$$_object",
        extends = olua.ordered_map(false),
        excludes = olua.ordered_map(),
        wildcards = olua.ordered_map(),
        includes = olua.ordered_map(),
        usings = olua.ordered_map(false),
        members = olua.ordered_map(false),
        props = olua.ordered_map(false),
        supers = olua.ordered_map(false),
        template_types = olua.ordered_map(false),
        ---@type fun(name:string, kind?:'func'|'var'|'enum'):string
        luaname = function (name, kind) return name end,
    }

    ---@class idl.model.class_option_desc
    ---@field reg_luatype boolean
    ---@field disallow_assign? boolean
    ---@field disallow_gc? boolean
    ---@field indexerror? "r" | "w" | "rw"
    ---@field packable? boolean
    ---@field packvars? integer

    ---@class idl.model.class_desc
    ---@field supercls? string
    ---@field comment? string
    ---@field luacats? string
    ---@field luaopen? string
    ---@field codeblock? string
    ---@field options idl.model.class_option_desc
    ---@field conf idl.conf.typeconf_desc
    ---@field CMD idl.cmd.typeconf
    local cls = {
        ---@type string c++ full class name
        cxxcls = cxxcls,
        luacls = conf.luacls,
        options = { reg_luatype = true },
        funcs = olua.ordered_map(false),
        enums = olua.ordered_map(false),
        props = olua.ordered_map(false),
        vars = olua.ordered_map(false),
        consts = olua.ordered_map(false),
        conf = conf,
        CMD = CMD,
    }

    setmetatable(cls, { __olua_ignore = { CMD = true, conf = true } })

    ---@type 'exclude'|'include'|nil
    local mode = nil

    local macros = olua.array()

    if idl.exclude_types:has(cxxcls) then
        olua.error([[
            typeconf '${cls.cxxcls}' will not configured
                you should do one of:
                    * remove exclude_type '${cls.cxxcls}'
        ]])
    end

    if cxxcls:find("[%^%%%$%*%+]") then -- ^%$*+
        idl.current_module.wildcard_types:set(cxxcls, cls)
    else
        idl.current_module.class_types:set(cxxcls, cls)
    end

    idl.type_convs:set(cxxcls, setmetatable({ cxxcls = cxxcls }, { __index = cls.conf }))
    if #idl.macros > 0 then
        cls.macro = idl.macros:at(-1)
    end

    ---@param luaopen string
    ---@return idl.cmd.typeconf
    function CMD.luaopen(luaopen)
        cls.luaopen = olua.trim(luaopen)
        return CMD
    end

    ---@param codeblock string
    ---@return idl.cmd.typeconf
    function CMD.codeblock(codeblock)
        cls.codeblock = olua.trim(codeblock)
        return CMD
    end

    ---LuaCAST
    ---@param luacats string
    ---@return idl.cmd.typeconf
    function CMD.luacats(luacats)
        cls.luacats = olua.trim(checkstring("luacats", luacats))
        return CMD
    end

    add_value_command(CMD, cls.conf, "luaname", function (_, v) return v end)
    add_value_command(CMD, cls.conf, "maincls", function (_, v) return v end)
    add_value_command(CMD, cls.options, "indexerror")
    add_value_command(CMD, cls.options, "packable", checkboolean)
    add_value_command(CMD, cls.options, "packvars", checkinteger)

    ---Extend a c++ class with another class, all static members of `extcls`
    ---will be copied into the current class.
    ---@param extcls string
    ---@return idl.cmd.typeconf
    function CMD.extend(extcls)
        cls.conf.extends:set(extcls, true)
        typeconf(extcls)
            .maincls(cls)
        return CMD
    end

    ---Exclude members from a c++ class, support lua regex.
    ---@param name string
    ---@return idl.cmd.typeconf
    function CMD.exclude(name)
        if mode and mode ~= "exclude" then
            olua.use(cls) -- get cls as upvalue
            olua.error("can't use .include and .exclude at the same time in typeconf '${cls.cxxcls}'")
        end
        mode = "exclude"
        if name == "*" or not name:find("[^_%w]") then
            cls.conf.excludes:set(name, true)
        else
            cls.conf.wildcards:set(name, true)
        end
        return CMD
    end

    ---Include members from a c++ class. If use `include`, all members of `class` don't included will be ignored.
    ---@param name string
    ---@return idl.cmd.typeconf
    function CMD.include(name)
        if mode and mode ~= "include" then
            olua.use(cls) -- get cls as upvalue
            olua.error("can't use .include and .exclude at the same time in typeconf '${cls.cxxcls}'")
        end
        mode = "include"
        cls.conf.includes:set(name, true)
        return CMD
    end

    ---@param cond string
    ---@return idl.cmd.typeconf
    function CMD.macro(cond)
        if #cond > 0 then
            macros:push(cond)
        else
            macros:pop()
        end
        return CMD
    end

    ---@param name string
    ---@return idl.cmd.func
    function CMD.func(name)
        local func = typeconf_func(CMD, cls, name)
        if #macros > 0 then
            cls.conf.members:get(name).macro = macros:at(-1)
        end
        return func
    end

    ---@param name string
    ---@return idl.cmd.prop
    function CMD.prop(name)
        return typeconf_prop(CMD, cls, name)
    end

    ---@param name string
    ---@return idl.cmd.var
    function CMD.var(name)
        return typeconf_var(CMD, cls, name)
    end

    return CMD
end

---Config a c++ class without export any members.
---@param cxxcls string
function typeonly(cxxcls)
    local cls = typeconf(cxxcls)
    cls.exclude "*"
    return cls
end

---@param cxxcls string
---@param fromcls idl.model.class_desc
---@return idl.cmd.typeconf
function idl.typecopy(cxxcls, fromcls)
    local CMD = typeconf(cxxcls)

    local cls = idl.current_module.class_types:get(cxxcls) ---@type idl.model.class_desc
    for k, v in pairs(fromcls.conf) do
        if k == "cxxcls" or k == "luacls" then
            goto continue
        end
        cls.conf[k] = olua.clone(v)
        ::continue::
    end

    if fromcls.luaopen then
        CMD.luaopen(fromcls.luaopen)
    end

    if fromcls.codeblock then
        CMD.codeblock(fromcls.codeblock)
    end

    return CMD
end

return idl
