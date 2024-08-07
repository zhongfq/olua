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

function olua.get_class(cls)
    return cls == "*" and class_map or class_map[cls]
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

local function lookup_typeinfo(cpptype)
    local tn = cpptype
    local ti = typeinfo_map[tn]
    if not ti then
        tn = tn:gsub("^const ", "")
        ti = typeinfo_map[tn]
    end
    if not ti and cpptype:find("[*]$") then
        ti, tn = lookup_typeinfo(cpptype:gsub("[ *]+$", ""))
    end
    return ti, tn
end

---@param cpptype string
---@param errors ordered_map
local function throw_type_error(cpptype, errors)
    print("try type:")
    print("    " .. table.concat(errors:values(), "\n    "))
    local rawtn = cpptype:gsub(" [*&]+$", "")
    olua.error([[
        type info not found: ${cpptype}
        you should do one of:
            * if has the type convertor, use typedef '${cpptype}'
            * if type is pointer or enum, use typeconf '${rawtn}'
            * if type not wanted, use excludetype '${rawtn}'
    ]])
end

local function search_type_from_class(cls, cpptype, errors)
    if cls and cls.cppcls then
        local nsarr = {}
        for ns in cls.cppcls:gmatch("[^:]+") do
            nsarr[#nsarr + 1] = ns:match("[^ *&]+") -- remove * &
        end
        while #nsarr > 0 do
            -- const Object * => const ns::Object *
            local ns = table.concat(nsarr, "::")
            local tn = olua.pretty_typename(cpptype:gsub("[%w:_]+ *[*&]*$", ns .. "::%1"))
            local ti = olua.typeinfo(tn, nil, false, errors)
            nsarr[#nsarr] = nil
            if ti then
                return ti, tn
            end
        end
    end

    if cls and cls.supercls then
        local super = typeinfo_map[cls.supercls]
        olua.assert(super, "super class '${cls.supercls}' of '${cls.cppcls}' is not found")
        return olua.typeinfo(cpptype, super, false, errors)
    end
end

local function subtype_typeinfo(cls, cpptype, throwerror)
    local subtis = {}
    for subcpptype in cpptype:match("<(.*)>"):gmatch(" *([^,]+)") do
        local subti = olua.typeinfo(subcpptype, cls, throwerror)
        if not subti.smartptr and subcpptype:find("<") then
            olua.error([[
                unsupport template class as template args:
                       type: ${cpptype}
                    subtype: ${subcpptype}
            ]])
        end
        subtis[#subtis + 1] = subti
    end
    if throwerror then
        olua.assert(next(subtis), "not found subtype: " .. cpptype)
    end
    return subtis
end

--- Get typeinfo.
---
---```c++
--- func: void addChild(const std::vector<const Object *> &child, const char *name)
--- child = {
---     cppcls = std::vector
---     flag = kFLAG_CONST | kFLAG_LVALUE
---     subtis = {
---         [1] = {
---             cppcls = 'Object *'
---             flag = kFLAG_CONST | kFLAG_POINTER
---         }
---     }
--- }
--- name {
---     cppcls = const char *          -- basictype.lua
---     flag = kFLAG_POINTER
--- }
---```
---@param cpptype any
---@param cls any
---@param throwerror any
---@param errors any
---@return nil
---@overload fun(cpptype: string, cls: any): any
function olua.typeinfo(cpptype, cls, throwerror, errors)
    local tn, ti, subtis -- for tn<T, ...>
    local flag = 0

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
            return nil
        end
    elseif cpptype:find("%*$") then
        flag = flag | kFLAG_POINTER
    elseif cpptype:find("&&$") then
        flag = flag | kFLAG_RVALUE
    elseif cpptype:find("&$") then
        flag = flag | kFLAG_LVALUE
    end

    if not has_flag(flag, kFLAG_CONST) and has_flag(flag, kFLAG_LVALUE) then
        local pti = olua.typeinfo(cpptype:gsub("&+$", "*"), cls, false)
        if pti and pti.luacls then
            ti = pti
            ti.flag = ti.flag | kFLAG_CAST
            return ti
        end
    end

    cpptype = cpptype:gsub("[ &]+$", "")

    -- parse template args
    if cpptype:find("<") then
        subtis = subtype_typeinfo(cls, cpptype, throwerror)
        cpptype = olua.pretty_typename(cpptype:gsub("<.*>", ""))
    end

    ti, tn = lookup_typeinfo(cpptype)
    errors:replace(cpptype, cpptype)

    if ti then
        ti = setmetatable({}, { __index = ti })
    else
        repeat
            -- search in class namespace
            ti, tn = search_type_from_class(cls, cpptype, errors)
            if ti then
                cpptype = tn
                goto found
            end

            -- type not found
            if throwerror then
                throw_type_error(cpptype, errors)
            else
                return
            end

            ::found::
        until true
    end

    if tn:find("^const ") then
        flag = flag & (~kFLAG_CONST)
    end

    ti.subtypes = subtis
    ti.flag = flag

    if ti.subtypes then
        local tti = lookup_typeinfo(olua.decltype(ti, true))
        if tti then
            ti = setmetatable({}, { __index = tti })
            ti.flag = flag
        end
        if ti.smartptr then
            ti.cppcls = olua.decltype(ti, true)
            ti.luacls = ti.subtypes[1].luacls
            ti.subtypes = nil
        end
    end

    if not olua.is_pointer_type(ti.cppcls)
        and olua.has_pointer_flag(ti)
        and not ti.luacls
    then
        if throwerror then
            local decltype = olua.decltype(ti, true)
            olua.error([[
                convertor not found: '${decltype}'
            ]])
        else
            return nil
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
        exps:push(ti.cppcls:gsub("[ *]+$", ""))
    else
        exps:push(ti.cppcls)
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
    elseif olua.has_pointer_flag(ti)
        and not olua.is_pointer_type(ti.cppcls)
    then
        exps:push(" *")
    end
    if addspace and not exps[#exps]:find("[*&]$") then
        exps:push(" ")
    end
    return tostring(exps)
end

local function parse_attr(t)
    local attr = {}
    olua.foreach(t, function (v)
        local name, value = v:match("@(%w+)%(?([^)]*)%)?")
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

local function parse_callback(cls, tn)
    if not tn:find("std::function") then
        tn = olua.typeinfo(tn, cls).funcdecl
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
            count = count + olua.assert(packvars, args[#args].type.cppcls)
        else
            count = count + 1
        end
    end

    return args, count
end

---@param type_model idl.model.type_model
---@param cls any
function olua.parse_type(type_model, cls)
    local attr = parse_attr(type_model.attr)

    type_model.attr = attr

    local tn = type_model.type

    if attr.type then
        tn = olua.assert(table.concat(attr.type, " "), "no replaceable type")
    end

    if olua.is_func_type(tn, cls) then
        local cb = parse_callback(cls, tn)
        type_model.type = type_func_info(tn, cls, cb)
    else
        type_model.type = olua.typeinfo(tn, cls)
    end

    return type_model
end

function olua.func_name(funcdecl)
    local _, _, str = parse_type(funcdecl)
    return str:match("[^ ()]+")
end

local function gen_func_desc(cls, fi)
    local exps = olua.array("")
    if #fi.ret.attr > 0 then
        exps:push(olua.join(fi.ret.attr, " "))
        exps:push(" ")
    end
    exps:push(fi.is_static and not fi.is_contructor and "static " or nil)
    if fi.is_contructor then
        exps:push(cls.cppcls)
    else
        exps:push(olua.decltype(fi.ret.type, nil, true))
        exps:push(fi.cppfunc)
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
    return tostring(exps)
end

function olua.gen_func_prototype(cls, fi)
    -- generate function prototype: void func(int, A *, B *)
    local exps = olua.array("")
    exps:push(fi.is_static and "static " or nil)
    exps:push(olua.decltype(fi.ret.type, nil, true))
    exps:push(fi.cppfunc)
    exps:push("(")
    for i, v in ipairs(fi.args) do
        exps:push(i > 1 and ", " or nil)
        exps:push(olua.decltype(v.type))
    end
    exps:push(")")
    fi.prototype = tostring(exps)
    return fi.prototype
end

---@param cls ParserTypeconf
---@param name any
---@param ... unknown
---@return table
function olua.parse_func(cls, name, ...)
    local arr = { max_args = 0 }
    for _, funcdecl in ipairs({ ... }) do
        local fi = { ret = {} }
        olua.willdo([[
            parse func:
                class = ${cls.cppcls}
                func = ${funcdecl}
        ]])
        if funcdecl:find("{") then
            fi.luafunc = assert(name)
            fi.cppfunc = name
            fi.body = olua.trim(funcdecl)
            fi.funcdesc = "<function body>"
            fi.ret.type = olua.typeinfo("void", cls)
            fi.ret.attr = {}
            fi.args = {}
            fi.prototype = false
            fi.max_args = #fi.args
        else
            local tn, attr, str = parse_type(funcdecl)
            local ctor = cls.cppcls:match("[^:]+$")
            local fromcls = cls
            if attr.copyfrom then
                fromcls = olua.typeinfo(attr.copyfrom[1] .. " *", cls)
            end
            if tn == ctor and str:find("^ *%(") then
                tn = tn .. " *"
                str = "new" .. str
                fi.ctor = true
                attr.static = true
            end
            fi.cppfunc = olua.assert(str:match("[^ ()]+"), "invalid func")
            fi.luafunc = name or fi.cppfunc
            fi.static = attr.static
            fi.funcdesc = funcdecl:gsub("@comment%([^()]+%) *", "")
            if olua.is_func_type(tn, fromcls) then
                local cb = parse_callback(fromcls, tn)
                fi.ret = {
                    type = type_func_info(tn, fromcls, cb),
                    attr = attr,
                    callback = cb,
                }
            else
                fi.ret.type = olua.typeinfo(tn, fromcls)
                fi.ret.attr = attr
                if fi.ctor then
                    fi.ret.type.flag = fi.ret.type.flag | kFLAG_POINTER
                end
            end
            fi.args, fi.max_args = parse_args(fromcls, str:sub(#fi.cppfunc + 1))
            olua.gen_func_prototype(cls, fi)
            cls.parsed_funcs:set(funcdecl, fi)
        end
        arr[#arr + 1] = fi
        arr.max_args = math.max(arr.max_args, fi.max_args)
        fi.index = #arr
    end

    return arr
end

local function parse_prop(cls, name, declget, declset)
    local pi = {}
    pi.name = assert(name, "no prop name")

    if declget then
        if cls.parsed_funcs:has(declget) then
            pi.get = cls.parsed_funcs:get(declget)
        else
            pi.get = olua.parse_func(cls, name, declget)[1]
        end
    end

    if declset then
        if cls.parsed_funcs:has(declset) then
            pi.set = cls.parsed_funcs:get(declset)
        else
            pi.set = olua.parse_func(cls, name, declset)[1]
        end
    end

    if not pi.get.body then
        assert(pi.get.ret.type.cppcls ~= "void", pi.get.funcdesc)
    elseif declget then
        pi.get.cppfunc = "get_" .. pi.get.cppfunc
    end

    if pi.set and pi.set.body and declset then
        pi.set.cppfunc = "set_" .. pi.set.cppfunc
    end

    return pi
end

function olua.luacls(cppcls)
    local ti = typeinfo_map[cppcls .. " *"] or typeinfo_map[cppcls]
    assert(ti, "type not found: " .. cppcls)
    return ti.luacls
end

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
    else
        return ti.luatype or ti.luacls or "any"
    end
end

function olua.is_func_type(tn, cls)
    if type(tn) == "table" then
        tn = tn.cppcls
    end
    if tn:find("std::function") then
        return true
    else
        local ti = olua.typeinfo(tn, cls)
        return ti and ti.funcdecl
    end
end

function olua.has_rvalue_flag(ti)
    return has_flag(ti.flag, kFLAG_RVALUE)
end

function olua.has_lvalue_flag(ti)
    return has_flag(ti.flag, kFLAG_LVALUE)
end

function olua.has_const_flag(ti)
    return has_flag(ti.flag, kFLAG_CONST)
end

function olua.has_pointer_flag(ti)
    return has_flag(ti.flag, kFLAG_POINTER)
end

function olua.has_pointee_flag(ti)
    return has_flag(ti.flag, kFLAG_RVALUE | kFLAG_LVALUE | kFLAG_POINTER)
end

function olua.has_callback_flag(ti)
    return has_flag(ti.flag, kFLAG_CALLBACK)
end

function olua.has_cast_flag(ti)
    return has_flag(ti.flag, kFLAG_CAST)
end

function olua.is_pointer_type(ti)
    if type(ti) == "string" then
        -- is 'T *'?
        return ti:find("%*$")
    else
        return ti.luacls and not olua.is_value_type(ti)
            and not olua.is_func_type(ti)
    end
end

function olua.is_templdate_type(cppcls)
    return cppcls:find("<")
end

function olua.is_enum_type(cls)
    local ti = typeinfo_map[cls.cppcls]
    return ti.conv == "olua_$$_enum"
end

function olua.is_oluaret(fi)
    return fi.ret.type.cppcls == "olua_Return"
end

function olua.initial_value(ti)
    if olua.has_pointer_flag(ti) then
        return " = nullptr"
    elseif ti.conv == "olua_$$_bool" then
        return " = false"
    elseif ti.conv == "olua_$$_integer" or ti.conv == "olua_$$_number" then
        return " = 0"
    elseif ti.conv == "olua_$$_enum" then
        return format(" = (${ti.cppcls})0"), nil
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

-- enum has cpp cls, but declared as lua_Unsigned
function olua.is_value_type(ti)
    return valuetype[ti.conv]
end

function olua.conv_func(ti, fn)
    return ti.conv:gsub("[$]+", fn)
end

function olua.typedef(typeinfo)
    for tn in typeinfo.cppcls:gmatch("[^\n\r;]+") do
        tn = olua.pretty_typename(tn)
        if #tn > 0 then
            local previous = typeinfo_map[tn]
            local ti = setmetatable({}, { __index = typeinfo })
            ti.cppcls = tn
            olua.assert(ti.replace or not previous, [[
                type info conflict: ${ti.cppcls}
                    previous: from ${previous.from}
                     current: from ${typeinfo.from}
            ]])
            typeinfo_map[tn] = ti

            local rawtn = tn:gsub("<.*>[ *]*", "")
            if tn:find("<") and not typeinfo_map[rawtn] then
                typeinfo_map[rawtn] = {
                    cppcls = rawtn,
                    luacls = ti.luacls:gsub("<.*>", ""),
                    conv = ti.conv
                }
            end
        end
    end
end

local function typeconf(cppcls)
    local CMD = {}
    ---@class ParserTypeconf
    local cls = {
        cppcls = cppcls,
        funcs = olua.array(),
        consts = olua.array(),
        enums = olua.array(),
        props = olua.array(),
        vars = olua.array(),
        macros = {},
        options = {},
        parsed_funcs = olua.ordered_map(),
    }

    class_map[cls.cppcls] = cls

    function CMD.option(key, value)
        cls.options[key] = value
    end

    function CMD.supercls(supercls)
        cls.supercls = supercls
    end

    function CMD.chunk(chunk)
        cls.chunk = chunk
    end

    function CMD.luaopen(luaopen)
        cls.luaopen = luaopen
    end

    function CMD.comment(comment)
        cls.comment = comment
    end

    function CMD.macro(name, value)
        cls.macros[name] = value
    end

    function CMD.func(name, ...)
        cls.funcs:push(olua.parse_func(cls, name, ...))

        local arr = cls.funcs[#cls.funcs]
        for idx = 1, #arr do
            -- gen_func_overload(cls, arr[idx], arr)
        end
    end

    --[[
        {
            ...
            std::function<void (float)> argN = [storeobj, func](float v) {
                ...
                ${cbefore}
                olua_callback(L, ...)
                ${cafter}
            };
            ...
            ${before}
            self->callfunc(arg1, arg2, ....);
            ${after}
            ...
        return 1;
        }
    ]]
    function CMD.insert(name, codes)
        local found
        local function trim(code)
            return code and olua.trim(code) or nil
        end
        local function apply_insert(fi)
            if fi and (fi.cppfunc == name or fi.luafunc == name) then
                found = true
                fi.insert.before = trim(codes.before)
                fi.insert.after = trim(codes.after)
                fi.insert.cbefore = trim(codes.cbefore)
                fi.insert.cafter = trim(codes.cafter)
            end
        end

        for _, arr in ipairs(cls.funcs) do
            for _, fi in ipairs(arr) do
                apply_insert(fi)
            end
        end
        for _, pi in ipairs(cls.props) do
            apply_insert(pi.get)
            apply_insert(pi.set)
        end
        for _, vi in ipairs(cls.vars) do
            apply_insert(vi.get)
            apply_insert(vi.set)
        end

        olua.assert(found, "function not found: ${cls.cppcls}::${name}")
    end

    --[[
        {
            tag_maker    -- make callback key
            tag_mode     -- how to store or remove function
            tag_store    -- where to store or remove function
            tag_scope    -- once, function, object
                            * once      remove after callback invoked
                            * function  remove after function invoked
                            * object    callback will exist until object die
        }

        TAG: .callback#[id++]@tag

        userdata.uservalue {
            .callback#0@click = clickfunc1,
            .callback#1@click = clickfunc2,
            .callback#2@remove = removefunc,
        }

        remove all callback:
            {tag_maker = "", tag_mode = "startwith", REMOVE = true}

        remove click callback:
            {tag_maker = "click", tag_mode = "equal", REMOVE = true}

        add new callback:
            {tag_maker = 'click', tag_mode = "new"}

        replace previous callback:
            {tag_maker = 'click', tag_mode = "replace"}
    ]]
    function CMD.callback(opt)
        cls.funcs:push(olua.parse_func(cls, nil, table.unpack(opt.funcs)))
        for i, fi in ipairs(cls.funcs[#cls.funcs]) do
            fi.callback = setmetatable({}, { __index = opt })
            if type(fi.callback.tag_maker) == "table" then
                fi.callback.tag_maker = assert(fi.callback.tag_maker[i])
            end
            if type(fi.callback.tag_mode) == "table" then
                fi.callback.tag_mode = assert(fi.callback.tag_mode[i])
            end
        end

        local arr = cls.funcs[#cls.funcs]
        for idx = 1, #arr do
            -- gen_func_overload(cls, arr[idx], arr)
        end
    end

    function CMD.var(name, declstr)
        local readonly, static
        local rawstr = declstr
        declstr, readonly = declstr:gsub("@readonly *", "")
        declstr = declstr:gsub("[; ]*$", "")
        declstr, static = declstr:gsub("^ *static *", "")

        olua.willdo([[
            parse var:
                class = ${cls.cppcls}
                var = ${declstr}
        ]])

        local args = parse_args(cls, "(" .. declstr .. ")")
        name = name or args[1].varname

        -- variable is callback?
        local cb_get
        local cb_set
        if args[1].callback then
            cb_set = {
                tag_maker = name,
                tag_mode = "replace",
                tag_store = 0,
                tag_scope = "object",
            }
            cb_get = {
                tag_maker = name,
                tag_mode = "equal",
                tag_store = 0,
                tag_scope = "object",
            }
        end

        -- make getter/setter function
        cls.vars[#cls.vars + 1] = {
            name = assert(name),
            get = {
                luafunc = name,
                cppfunc = "get_" .. args[1].varname,
                varname = args[1].varname,
                insert = {},
                funcdesc = rawstr,
                ret = {
                    type = args[1].type,
                    attr = args[1].attr,
                },
                static = static > 0,
                variable = true,
                args = {},
                index = 0,
                callback = cb_get,
            },
            set = {
                luafunc = name,
                cppfunc = "set_" .. args[1].varname,
                varname = args[1].varname,
                insert = {},
                static = static > 0,
                funcdesc = rawstr,
                ret = {
                    type = olua.typeinfo("void", cls),
                    attr = {},
                },
                variable = true,
                args = args,
                index = 0,
                callback = cb_set,
            },
        }

        if readonly > 0 then
            cls.vars[#cls.vars].set = nil
        end
    end

    function CMD.prop(name, get, set)
        cls.props:push(parse_prop(cls, name, get, set))
    end

    function CMD.const(name, value, typename)
        olua.willdo([[
            parse const:
                class = ${cls.cppcls}
                const = ${typename} ${name}
        ]])
        cls.consts:push({
            name = assert(name),
            value = value,
            type = olua.typeinfo(typename, cls),
        })
    end

    function CMD.enum(name, value, intvalue, comment)
        cls.enums:push({
            name = name,
            value = value or (cls.cppcls .. "::" .. name),
            intvalue = intvalue,
            comment = olua.base64_decode(comment)
        })
    end

    return cls, CMD
end

function olua.export(path)
    local m = dofile(path)

    olua.make_array(m.class_types):foreach(function (cls)
        class_map[cls.cppcls] = cls
        cls.funcs = olua.make_ordered_map(cls.funcs)

        olua.make_ordered_map(cls.props):foreach(function (prop)
            for _, arr in ipairs(cls.funcs) do
                -- TODO: check get set exist
                for _, func in ipairs(arr) do
                    if prop.get and prop.get == func.prototype then
                        prop.get = func
                    end
                    if prop.set and prop.set == func.prototype then
                        prop.set = func
                    end
                end
            end
        end)

        olua.make_ordered_map(cls.vars):foreach(function (var)
            for _, arr in ipairs(cls.funcs) do
                -- TODO: check get set exist
                for _, func in ipairs(arr) do
                    if var.get and var.get == func.prototype then
                        var.get = func
                    end
                    if var.set and var.set == func.prototype then
                        var.set = func
                    end
                end
            end
        end)

        olua.make_ordered_map(cls.consts):foreach(function (const)
            const.type = olua.typeinfo(const.type, cls)
        end)

        cls.enums = olua.make_ordered_map(cls.enums)
        cls.funcs:foreach(function (arr)
            olua.make_array(arr):foreach(function (func, idx)
                ---@cast func idl.model.func_model
                if func.body then
                    func.funcdesc = ""
                    return
                end
                func.index = idx
                func.funcdesc = gen_func_desc(cls, func)
                func.ret = olua.parse_type(func.ret, cls)
                olua.make_array(func.args):foreach(function (arg, idx)
                    ---@cast arg idl.model.type_model
                    func.args[idx] = olua.parse_type(arg, cls)
                end)
            end)
        end)
    end)

    olua.gen_header(m)
    olua.gen_source(m)
    olua.gen_metafile(m)
end

return olua
