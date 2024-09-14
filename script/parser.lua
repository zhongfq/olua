---@type {[string]: idl.gen.typeinfo}
local typeinfo_map   = {}
local class_map      = {}

local kFLAG_CONST    = 1 << 1 -- is const
local kFLAG_LVALUE   = 1 << 2 -- is left value
local kFLAG_RVALUE   = 1 << 3 -- is right value
local kFLAG_POINTER  = 1 << 4 -- is pointer
local kFLAG_CALLBACK = 1 << 5 -- is callback
local kFLAG_CAST     = 1 << 6 -- cast ref to pointer

local format         = olua.format

local function has_flag(kind, flag)
    return (kind & flag) ~= 0
end

---@param cxxcls string
---@return idl.gen.class_desc
function olua.get_class(cxxcls)
    return class_map[cxxcls]
end

---@param tn string
---@return string
function olua.pretty_typename(tn)
    tn = tn:gsub("^ *", "")           -- trim head space
    tn = tn:gsub(" *$", "")           -- trim tail space
    tn = tn:gsub(" +", " ")           -- remove needless space
    tn = tn:gsub(" *([<>]+) *", "%1") -- remove space around '<>'
    tn = tn:gsub(" *([*&]) *", "%1")  -- remove space around '*&'
    tn = tn:gsub("[*&]+", " %1")      -- add one space before '*&'
    return tn
end

---@param cpptype string
---@return idl.gen.typeinfo
local function lookup_typeinfo(cpptype)
    local tn = cpptype
    local ti = typeinfo_map[tn]
    if not ti then
        tn = tn:gsub("^const ", "")
        ti = typeinfo_map[tn]
    end
    if not ti and cpptype:find("[*]$") then
        ti = lookup_typeinfo(cpptype:gsub("[ *]+$", ""))
    end

    return ti
end

---@param cpptype string
---@param errors olua.ordered_map
local function throw_type_error(cpptype, errors)
    print("try type:")
    print("    " .. table.concat(errors:values(), "\n    "))
    local rawtn = cpptype:gsub(" [*&]+$", "")
    olua.use(rawtn)
    olua.error([[
        type info not found: ${cpptype}
        you should do one of:
            * if has the type convertor, use typedef '${cpptype}'
            * if type is pointer or enum, use typeconf '${rawtn}'
            * if type not wanted, use exclude_type '${rawtn}'
    ]])
end

---@param cls any
---@param cpptype any
---@param throwerror any
---@return idl.gen.typeinfo[]
local function subtype_typeinfo(cls, cpptype, throwerror)
    local subtypes = {}
    for subcpptype in cpptype:match("<(.*)>"):gmatch(" *([^,]+)") do
        local subti = olua.typeinfo(subcpptype, cls, throwerror)
        if not subti.smartptr and subcpptype:find("<") then
            olua.error([[
                unsupport template class as template args:
                       type: ${cpptype}
                    subtype: ${subcpptype}
            ]])
        end
        subtypes[#subtypes + 1] = subti
    end
    if throwerror then
        olua.assert(next(subtypes), "not found subtype: " .. cpptype)
    end
    return subtypes
end

---@class idl.gen.typeinfo : idl.model.typedef_desc
---@field flag number
---@field funcdecl? string
---@field callback? idl.gen.func_desc
---@field subtypes? idl.gen.typeinfo[]

--- Get typeinfo.
---
---```c++
--- func: void addChild(const std::vector<const Object *> &child, const char *name)
--- child = {
---     cxxcls = std::vector
---     flag = kFLAG_CONST | kFLAG_LVALUE
---     subtypes = {
---         [1] = {
---             cxxcls = 'Object *'
---             flag = kFLAG_CONST | kFLAG_POINTER
---         }
---     }
--- }
--- name {
---     cxxcls = const char *          -- basictype.lua
---     flag = kFLAG_POINTER
--- }
---```
---@param cpptype string
---@param cls? idl.gen.class_desc
---@param throwerror? boolean
---@param errors? olua.ordered_map
---@return idl.gen.typeinfo
function olua.typeinfo(cpptype, cls, throwerror, errors)
    local ti, subtypes -- for tn<T, ...>
    local flag = 0

    ---@type idl.gen.typeinfo
    local not_found = nil

    throwerror = throwerror ~= false
    errors = errors or olua.ordered_map()
    cpptype = olua.pretty_typename(cpptype)

    if cpptype:find("^const") then
        flag = flag | kFLAG_CONST
    end

    if cpptype:find("%*%*+$") then
        if throwerror then
            olua.error("type not support: ${cpptype}")
        else
            return not_found
        end
    elseif cpptype:find("%*$") then
        flag = flag | kFLAG_POINTER
    elseif cpptype:find("&&$") then
        flag = flag | kFLAG_RVALUE
    elseif cpptype:find("&$") then
        flag = flag | kFLAG_LVALUE
    end

    if not has_flag(flag, kFLAG_CONST) and has_flag(flag, kFLAG_LVALUE) then
        -- try: T & -> T *
        ti = olua.typeinfo(cpptype:gsub("&+$", "*"), cls, false)
        if ti and ti.luacls then
            ti.flag = ti.flag | kFLAG_CAST
            return ti
        end
    end

    cpptype = cpptype:gsub("[ &]+$", "")

    -- parse template args
    if cpptype:find("<") then
        subtypes = subtype_typeinfo(cls, cpptype, throwerror)
        cpptype = olua.pretty_typename(cpptype:gsub("<.*>", ""))
    end

    ti = lookup_typeinfo(cpptype)
    errors:replace(cpptype, cpptype)

    if ti then
        ti = setmetatable({}, { __index = ti })
        ti.subtypes = subtypes
        ti.flag = ti.cxxcls:find("^const ") and flag & (~kFLAG_CONST) or flag

        if ti.subtypes then
            local tti = lookup_typeinfo(olua.decltype(ti, true))
            if tti then
                ti = setmetatable({}, { __index = tti })
                ti.flag = flag
            end
            if ti.smartptr then
                ti.cxxcls = olua.decltype(ti, true)
                ti.luacls = ti.subtypes[1].luacls
                ti.subtypes = nil
            end
        end
    end

    if not ti then
        if throwerror then
            throw_type_error(cpptype, errors)
        else
            return not_found
        end
    elseif not olua.is_pointer_type(ti.cxxcls)
        and olua.has_pointer_flag(ti)
        and not ti.luacls
    then
        if throwerror then
            local decltype = olua.decltype(ti, true)
            olua.use(decltype)
            olua.error([[
                convertor not found: '${decltype}'
            ]])
        else
            return not_found
        end
    end

    return ti
end

--[[
    function arg variable must declared with no const type

    eg: Object::call(const int arg1)

    Object *self = nullptr;
    int arg1;
    olua_to_obj(L, 1, &self, "Object");
    olua_check_integer(L, 2, &arg1);
    self->call(arg1);
]]
---@param ti string|idl.gen.typeinfo
---@param checkvalue? boolean
---@param addspace? boolean
---@param exps? olua.array
---@return string
function olua.decltype(ti, checkvalue, addspace, exps)
    if type(ti) == "string" then
        if addspace and not ti:find("[*&]$") then
            ti = ti .. " "
        end
        return ti
    end

    exps = exps or olua.array("")
    if not checkvalue and olua.has_const_flag(ti) then
        exps:push("const ")
    end
    if not checkvalue and olua.has_cast_flag(ti) then
        exps:push(ti.cxxcls:gsub("[ *]+$", ""))
    else
        exps:push(ti.cxxcls)
    end
    if olua.has_callback_flag(ti) then
        exps:push("<")
        olua.decltype(ti.callback.ret.type, false, true, exps)
        exps:push("(")
        for i, ai in ipairs(ti.callback.args) do
            exps:push(i > 1 and ", " or nil)
            olua.decltype(ai.type, false, false, exps)
        end
        exps:push(")")
        exps:push(">")
    elseif ti.subtypes then
        exps:push("<")
        for i, subti in ipairs(ti.subtypes) do
            exps:push(i > 1 and ", " or nil)
            olua.decltype(subti, false, false, exps)
        end
        exps:push(">")
    end
    if not checkvalue then
        exps:push(olua.has_lvalue_flag(ti) and " &" or nil)
        exps:push(olua.has_rvalue_flag(ti) and " &&" or nil)
    end
    if not checkvalue and olua.has_cast_flag(ti) then
        exps:push(" &")
    elseif olua.has_pointer_flag(ti) and not olua.is_pointer_type(ti.cxxcls) then
        exps:push(" *")
    end
    if addspace and not exps[#exps]:find("[*&]$") then
        exps:push(" ")
    end
    return tostring(exps)
end

---@param t string[]
---@return idl.gen.attr_desc
local function parse_attr(t)
    local attr = {}
    olua.foreach(t, function (v)
        local name, value = v:match("@([^(]+)(%b())")
        if value then
            value = value:sub(2, -2)
        else
            name = v:match("@([^(]+)")
            value = ""
        end
        attr[name] = olua.split(value, " ")
    end)
    return attr
end

local composite_types = {
    const = true,
    struct = true,
    enum = true,
    union = true,
    signed = true,
    unsigned = true,
    char = true,
    short = true,
    int = true,
    long = true,
    double = true,
}

local function parse_type(str)
    -- str = std::function <void (float int)> &arg, ...
    local attr = {}
    local tn = str:match("^[%w_: ]+%b<>[ &*]*") -- parse template type
    if not tn then
        local substr = str
        while true do
            local _, to = substr:find(" *[%w_:]+[ &*]*")
            if not to then
                olua.assert(tn, "no type")
                break
            end
            local subtn = olua.pretty_typename(substr:sub(1, to))
            subtn = subtn:gsub("[ &*]*$", "") -- rm ' *&'
            if composite_types[subtn] then
                tn = (tn and tn or "") .. substr:sub(1, to)
                substr = substr:sub(to + 1)
            elseif not tn then
                tn = substr:sub(1, to)
                substr = substr:sub(to + 1)
                break
            else
                local ptn = olua.pretty_typename(tn)
                ptn = ptn:gsub("[ &*]*$", "") -- rm ' *&'
                if ptn == "struct" or ptn == "const" then
                    tn = (tn and tn or "") .. substr:sub(1, to)
                    substr = substr:sub(to + 1)
                end
                break
            end
        end
    end
    str = str:sub(#tn + 1)
    str = str:gsub("^ *", "")

    if attr.type then
        tn = olua.assert(table.concat(attr.type, " "), "no replaceable type")
    end

    return olua.pretty_typename(tn), attr, str
end

---@param tn any
---@param cls any
---@param cb any
---@return any
local function type_func_info(tn, cls, cb)
    local ti
    if not tn:find("std::function") then
        ti = olua.typeinfo(tn, cls)
        ti.callback = cb
    else
        ti = olua.typeinfo("std::function", cls)
        ti.flag = ti.flag | kFLAG_CALLBACK
        ti.callback = cb
    end
    return ti
end

local parse_args

---@param cls idl.gen.class_desc
---@param tn string
---@return idl.gen.func_desc
local function parse_callback(cls, tn)
    if not tn:find("std::function") then
        tn = assert(olua.typeinfo(tn, cls).funcdecl)
    end
    local rtn, rattr, str = parse_type(tn:match("<(.*)>"))
    str = str:gsub("^[^(]+", "") -- match callback args
    return {
        ret = {
            type = olua.typeinfo(rtn, cls),
            attr = rattr
        },
        args = parse_args(cls, str),
    }
end

--[[
    arg struct: void func(@pack const std::vector<int> &points = value)
    {
        type             -- type info
        varname          -- var name: points
        attr             -- attr: {pack = true}
        callback = {     -- eg: std::function<void (float, const A *a)>
            args         -- callback functions args: float, A *a
            ret          -- return type info: void type info
        }
    }
]]
---@param cls idl.gen.class_desc
---@param declstr string
function parse_args(cls, declstr)
    local args = {}
    local count = 0
    declstr = declstr:match("%((.*)%)")
    olua.assert(declstr, "malformed args string")

    while #declstr > 0 do
        local tn, attr, varname, from, to
        tn, attr, declstr = parse_type(declstr)
        if tn == "void" then
            return args, count
        end

        from, to, varname = declstr:find("^([^ ,]+)")

        if varname then
            declstr = declstr:sub(to + 1)
        end

        declstr = declstr:gsub("^[^,]*,? *", "") -- skip ','

        -- is callback
        if olua.is_func_type(tn, cls) then
            local cb = parse_callback(cls, tn)
            args[#args + 1] = {
                type = type_func_info(tn, cls, cb),
                varname = varname or "",
                attr = attr,
                callback = cb,
            }
        else
            local ti = olua.typeinfo(tn, cls)
            args[#args + 1] = {
                type = ti,
                varname = varname or "",
                attr = attr,
            }
        end

        local packvars = args[#args].type.packvars or 1
        if attr.pack and packvars > 0 then
            count = count + olua.assert(packvars, args[#args].type.cxxcls)
        else
            count = count + 1
        end
    end

    return args, count
end

---@param type_model idl.model.type_desc
---@param cls idl.gen.class_desc
---@return idl.gen.type_desc
function olua.parse_type(type_model, cls)
    local tn = type_model.type

    local desc = type_model --[[@as idl.gen.type_desc]]
    desc.attr = parse_attr(type_model.attr)

    if desc.attr.type then
        tn = olua.assert(table.concat(desc.attr.type, " "), "no replaceable type")
    end

    if olua.is_func_type(tn, cls) then
        local cb = parse_callback(cls, tn)
        desc.type = type_func_info(tn, cls, cb)
    else
        desc.type = olua.typeinfo(tn, cls)
    end

    return desc
end

---@param cls any
---@param fi idl.model.func_desc
---@return string
local function gen_func_desc(cls, fi)
    local exps = olua.array("")
    if #fi.ret.attr > 0 then
        exps:push(olua.join(fi.ret.attr, " "))
        exps:push(" ")
    end
    exps:push(fi.is_static and not fi.is_contructor and "static " or nil)
    if fi.is_variable then
        if fi.ret.type == "void" then
            exps:push(olua.decltype(fi.args[1].type, nil, true))
        else
            exps:push(olua.decltype(fi.ret.type, nil, true))
        end
        exps:push(fi.cxxfn)
    else
        if fi.is_contructor then
            exps:push(cls.cxxcls)
        else
            exps:push(olua.decltype(fi.ret.type, nil, true))
            exps:push(fi.cxxfn)
        end
        exps:push("(")
        for i, v in ipairs(fi.args) do
            exps:push(i > 1 and ", " or nil)
            if #v.attr > 0 then
                exps:push(olua.join(v.attr, " "))
                exps:push(" ")
            end
            exps:push(olua.decltype(v.type, false, true))
            exps:push(v.name)
        end
        exps:push(")")
    end
    return tostring(exps)
end

---@param func idl.gen.func_desc
---@param cls? idl.gen.class_desc
function olua.gen_luafn(func, cls)
    local args = olua.array(", ")

    if not func.is_static and cls then
        args:pushf("self: ${cls.luacls}")
    end

    for idx, arg in ipairs(func.args) do
        ---@cast arg idl.gen.type_desc
        if arg.type.cxxcls ~= "lua_State" then
            local name = arg.name or ("arg" .. idx)
            local type = olua.luatype(arg.type)
            name = name:gsub("%$", "")
            olua.use(type)
            args:pushf("${name}: ${type}")
        end
    end

    local exps = olua.array("")
    exps:push("fun(")
    exps:push(tostring(args))
    exps:push(")")

    if func.ret.type.cxxcls ~= "void" then
        exps:push(": " .. olua.luatype(func.ret.type))
    end

    return tostring(exps)
end

---@param comment string
---@return string
function olua.process_comment(comment)
    comment = comment:gsub("^[/* \n\r]+", "") -- remove leading comment
    comment = comment:gsub("\r\n", "\n")      -- remove carriage return
    comment = comment:gsub("[\t]", " ")       -- remove tab
    comment = comment:gsub("[\n]+[/* ]+", "\n")
    comment = comment:gsub("[/* \n]+$", "")   -- remove trailing comment
    comment = comment:gsub("\\code", "```")
    comment = comment:gsub("\\endcode", "```")
    comment = comment:gsub("\\c ([^ ,.]+)", "`%1`") -- convert \c NAME to `NAME`
    comment = comment:gsub("^ *@", "\\")            -- convert @ to \\
    comment = comment:gsub("\n *@", "\n\\")         -- convert @ to \\
    comment = comment:gsub("\\brief *", "")
    return comment
end

---@param ti idl.gen.typeinfo
---@return string
function olua.luatype(ti)
    if ti.luacls == "void" then
        return "nil"
    elseif ti.luacls == "void *" then
        return "any"
    elseif ti.luatype == "array" then
        return olua.luatype(ti.subtypes[1]) .. "[]"
    elseif ti.luatype == "map" then
        local key_luatype = olua.luatype(ti.subtypes[1])
        local value_luatype = olua.luatype(ti.subtypes[2])
        -- { [string]: boolean }
        return string.format("{ [%s]: %s }", key_luatype, value_luatype)
    elseif ti.luacls == "std.function" then
        return olua.gen_luafn(ti.callback)
    else
        return ti.luatype or ti.luacls or "any"
    end
end

---@param tn string|idl.gen.typeinfo
---@param cls? idl.gen.class_desc
---@return boolean
function olua.is_func_type(tn, cls)
    local cpptype = type(tn) == "table" and tn.cxxcls or tn --[[@as string]]
    if cpptype:find("std::function") then
        return true
    else
        return olua.typeinfo(cpptype, cls).funcdecl ~= nil
    end
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_rvalue_flag(ti)
    return has_flag(ti.flag, kFLAG_RVALUE)
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_lvalue_flag(ti)
    return has_flag(ti.flag, kFLAG_LVALUE)
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_const_flag(ti)
    return has_flag(ti.flag, kFLAG_CONST)
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_pointer_flag(ti)
    return has_flag(ti.flag, kFLAG_POINTER)
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_pointee_flag(ti)
    return has_flag(ti.flag, kFLAG_RVALUE | kFLAG_LVALUE | kFLAG_POINTER)
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_callback_flag(ti)
    return has_flag(ti.flag, kFLAG_CALLBACK)
end

---@param ti idl.gen.typeinfo
---@return boolean
function olua.has_cast_flag(ti)
    return has_flag(ti.flag, kFLAG_CAST)
end

---@param ti idl.gen.typeinfo|string
---@return boolean
function olua.is_pointer_type(ti)
    if type(ti) == "string" then
        -- is 'T *'?
        return ti:find("%*$") ~= nil
    elseif ti.luacls and not olua.is_value_type(ti) and not olua.is_func_type(ti) then
        return true
    else
        return false
    end
end

---@param cxxcls string
---@return boolean
function olua.is_templdate_type(cxxcls)
    return cxxcls:find("<") ~= nil
end

---@param cls idl.gen.class_desc
---@return boolean
function olua.is_enum_type(cls)
    local ti = typeinfo_map[cls.cxxcls]
    return ti.conv == "olua_$$_enum"
end

---@param func idl.gen.func_desc
---@return boolean
function olua.is_oluaret(func)
    return func.ret.type.cxxcls == "olua_Return"
end

---@param ti idl.gen.typeinfo
---@return string
function olua.initial_value(ti)
    if olua.has_pointer_flag(ti) then
        return " = nullptr"
    elseif ti.conv == "olua_$$_bool" then
        return " = false"
    elseif ti.conv == "olua_$$_integer" or ti.conv == "olua_$$_number" then
        return " = 0"
    elseif ti.conv == "olua_$$_enum" then
        return format(" = (${ti.cxxcls})0"), nil
    else
        return ""
    end
end

local valuetype = {
    ["olua_$$_bool"] = true,
    ["olua_$$_string"] = true,
    ["olua_$$_callback"] = true,
    ["olua_$$_integer"] = true,
    ["olua_$$_number"] = true,
    ["olua_$$_enum"] = true,
}

---Enum has cxx cls, but declared as lua_Unsigned
---@param ti idl.gen.typeinfo
---@return unknown
function olua.is_value_type(ti)
    return valuetype[ti.conv]
end

---@param ti idl.gen.typeinfo
---@param fn string
function olua.conv_func(ti, fn)
    return ti.conv:gsub("[$]+", fn)
end

---@param typeinfo idl.gen.typeinfo
function olua.typedef(typeinfo)
    for tn in typeinfo.cxxcls:gmatch("[^\n\r;]+") do
        tn = olua.pretty_typename(tn)
        if #tn > 0 then
            local previous = typeinfo_map[tn]
            ---@type idl.gen.typeinfo
            local ti = setmetatable({}, { __index = typeinfo })
            ti.cxxcls = tn
            olua.assert(ti.override or not previous, [[
                type info conflict: ${ti.cxxcls}
                    previous: from ${previous.from}
                     current: from ${typeinfo.from}
            ]])
            typeinfo_map[tn] = ti

            local rawtn = tn:gsub("<.*>[ *]*", "")
            if tn:find("<") and not typeinfo_map[rawtn] then
                typeinfo_map[rawtn] = {
                    cxxcls = rawtn,
                    luacls = ti.luacls:gsub("<.*>", ""),
                    conv = ti.conv,
                    flag = 0,
                }
            end
        end
    end
end

function olua.export(path)
    local m = dofile(path)

    ---@class idl.gen.module_desc : idl.model.module_desc
    ---@field class_types olua.array # idl.gen.class_desc[]
    ---@field private luacls unknown

    ---@class idl.gen.class_desc : idl.model.class_desc
    ---@field luacls string

    ---@class idl.gen.attr_desc
    ---@field addref? table # @addref
    ---@field as? table
    ---@field delref? table
    ---@field extend? [string] # @extend
    ---@field nullable? table
    ---@field optional? table
    ---@field operator? table
    ---@field pack? table
    ---@field postnew? table
    ---@field template? olua.array
    ---@field type? table
    ---@field unpack? table
    ---@field using? table

    ---@class idl.gen.const_desc : idl.model.const_desc
    ---@field type idl.gen.typeinfo

    ---@class idl.gen.prop_desc : idl.model.prop_desc
    ---@field get idl.gen.func_desc
    ---@field set? idl.gen.func_desc

    ---@class idl.gen.var_desc : idl.model.var_desc
    ---@field get idl.gen.func_desc
    ---@field set? idl.gen.func_desc

    ---@class idl.gen.type_desc : idl.model.type_desc
    ---@field type idl.gen.typeinfo
    ---@field attr idl.gen.attr_desc

    ---@class idl.gen.func_desc : idl.model.func_desc
    ---@field funcdesc string
    ---@field index integer
    ---@field ret idl.gen.type_desc
    ---@field args olua.array # idl.gen.type_desc[]

    olua.make_array(m.class_types):foreach(function (cls)
        ---@cast cls idl.gen.class_desc
        class_map[cls.cxxcls] = cls

        local func_map = {}

        olua.make_ordered_map(cls.funcs):foreach(function (arr)
            ---@cast arr idl.gen.func_desc[]
            for _, func in ipairs(arr) do
                if func.prototype then
                    func_map[func.prototype] = func
                end
            end
        end)

        olua.make_ordered_map(cls.props):foreach(function (prop)
            ---@cast prop idl.gen.prop_desc
            if prop.get then
                prop.get = func_map[prop.get]
                if not prop.get then
                    olua.error("get function not found: ${cls.cxxcls} => ${prop.get}")
                end
            end
            if prop.set then
                prop.set = func_map[prop.set]
                if not prop.set then
                    olua.error("set function not found: ${cls.cxxcls} => ${prop.set}")
                end
            end
        end)

        olua.make_ordered_map(cls.vars):foreach(function (var)
            ---@cast var idl.gen.var_desc|idl.model.var_desc
            if var.get then
                var.get = func_map[var.get]
                if not var.get then
                    olua.error("get function not found: ${cls.cxxcls} => ${var.get}")
                end
            end
            if var.set then
                var.set = func_map[var.set]
                if not var.set then
                    olua.error("set function not found: ${cls.cxxcls} => ${var.set}")
                end
            end
        end)

        olua.make_ordered_map(cls.consts):foreach(function (const)
            ---@cast const idl.gen.const_desc|idl.model.const_desc
            local tn = const.type --[[@as string]]
            const.type = olua.typeinfo(tn, cls)
        end)

        cls.enums = olua.make_ordered_map(cls.enums)
        cls.funcs:foreach(function (arr)
            olua.make_array(arr):foreach(function (func, idx)
                ---@cast func idl.gen.func_desc
                func.index = idx
                if func.body then
                    func.funcdesc = ""
                    func.luafn = func.luafn or func.cxxfn
                else
                    func.funcdesc = gen_func_desc(cls, func)
                    func.ret = olua.parse_type(func.ret, cls)
                    olua.make_array(func.args):foreach(function (arg, idx)
                        ---@cast arg idl.model.type_desc
                        func.args[idx] = olua.parse_type(arg, cls)
                    end)
                end
            end)
        end)
    end)

    olua.gen_header(m)
    olua.gen_source(m)
    olua.gen_annotation(m)
end

return olua
