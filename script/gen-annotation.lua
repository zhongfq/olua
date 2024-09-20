local operator = {
    __add = "add",
    __sub = "sub",
    __mul = "mul",
    __div = "div",
    __mod = "mod",
    __pow = "pow",
    __unm = "unm",
    __band = "band",
    __bor = "bor",
    __bxor = "bxor",
    __shl = "shl",
    __shr = "shr",
    __call = "call",
}


---@param func idl.gen.func_desc
---@param cls? idl.gen.class_desc
local function gen_luafn(func, cls)
    local args = olua.array(", ")

    if not func.is_static and cls then
        args:pushf("self: ${cls.luacls}")
    end

    local idx = 0
    for _, arg in ipairs(func.args) do
        if arg.type.cxxcls ~= "lua_State" then
            if arg.attr.pack then
                local arg_cls = olua.get_class(arg.type.cxxcls)
                for _, var in ipairs(arg_cls.vars) do
                    idx = idx + 1
                    local name = var.name or ("arg" .. idx)
                    local type = olua.luatype(var.get.ret.type)
                    args:pushf("${name}: ${type}")
                end
            else
                idx = idx + 1
                local name = arg.name or ("arg" .. idx)
                local type = olua.luatype(arg.type)
                name = name:gsub("%$", "")
                if olua.can_construct_from_string(arg) then
                    type = olua.format("${type}|string")
                end
                olua.use(type)
                args:pushf("${name}: ${type}")
            end
        end
    end

    local exps = olua.array("")
    exps:push("fun(")
    exps:push(tostring(args))
    exps:push(")")

    if func.ret.type.cxxcls ~= "void" then
        if func.ret.attr.unpack then
            exps:push(": ")
            local ret_cls = olua.get_class(func.ret.type.cxxcls)
            for i, var in ipairs(ret_cls.vars) do
                local type = olua.luatype(var.get.ret.type)
                exps:push(type)
                if i < #ret_cls.vars then
                    exps:push(", ")
                end
            end
        else
            exps:push(": " .. olua.luatype(func.ret.type))
        end
    end

    return tostring(exps)
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
        return gen_luafn(ti.callback)
    else
        return ti.luatype or ti.luacls or "any"
    end
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_annotation(cls, write)
    local luacls = cls.luacls:match("[^.]+$")
    local supercls = cls.supercls and olua.get_class(cls.supercls).luacls or nil
    supercls = supercls and olua.format(": ${supercls}") or ""

    olua.willdo("generate lua annotation: ${cls.cxxcls}")

    write(olua.format([[
        ---AUTO GENERATED, DO NOT MODIFY!
        ---@meta ${cls.luacls}
    ]]))
    write("")

    local cls_comment = cls.comment
    if cls_comment then
        cls_comment = cls.comment:gsub("\n", "\n---")
    else
        cls_comment = ""
    end

    if olua.is_enum_type(cls) then
        write(olua.format([[
            ---@type ${cls.luacls}
            local VALUE

            ---${cls_comment}
            ---@enum ${cls.luacls}
        ]]))
        if cls.luacats then
            write(cls.luacats)
        end
    else
        write(olua.format("---${cls_comment}"))
        if olua.is_func_type(cls.cxxcls) then
            local ti = olua.typeinfo(cls.cxxcls)
            write("---")
            olua.use(ti)
            write(olua.format("---${ti.funcdecl}"))
        end
        write(olua.format("---@class ${cls.luacls} ${supercls}"))
        if cls.luacats then
            write(cls.luacats)
        end
    end

    for _, prop in ipairs(cls.props) do
        local comment = prop.get.comment
        if comment and #comment > 0 then
            comment = comment:gsub("\n\n", " <br><br>")
            comment = comment:gsub("\n+", " ")
        else
            comment = ""
        end
        local type = prop.get.ret and olua.luatype(prop.get.ret.type) or "any"
        olua.use(type)
        write(olua.format([[
            ---@field ${prop.name} ${type} ${comment}
        ]]))
    end

    for _, var in ipairs(cls.vars) do
        local type = olua.luatype(var.get.ret.type)
        olua.use(type)
        write(olua.format([[
            ---@field ${var.name} ${type}
        ]]))
    end

    for _, const in ipairs(cls.consts) do
        local type = olua.luatype(const.type)
        olua.use(type)
        write(olua.format([[
            ---@field ${const.name} ${type}
        ]]))
    end

    if cls.options.reg_luatype then
        olua.foreach(cls.funcs, function (arr)
            olua.use(cls, luacls)
            local func = arr[1]
            if not operator[func.luafn] then
                return
            end
            local exprs = olua.array("")
            exprs:push(operator[func.luafn])
            if func.args and #func.args > 0 then
                local args = olua.slice(func.args)
                if olua.is_oluaret(func) then
                    table.remove(args, 1)
                end
                if func.is_static then
                    table.remove(args, 1)
                end
                exprs:push("(")
                for i, arg in ipairs(args) do
                    local type = olua.luatype(arg.type)
                    if olua.can_construct_from_string(arg) then
                        type = olua.format("${type}|string")
                    end
                    exprs:pushf(type)
                    if i < #args then
                        exprs:push(", ")
                    end
                end
                exprs:push(")")
            end
            if func.ret and func.ret.type.cxxcls ~= "void" and not olua.is_oluaret(func) then
                exprs:push(":" .. olua.luatype(func.ret.type))
            end
            if func.args and #func.args > 0 or func.ret then
                write(olua.format([[
                    ---@operator ${exprs}
                ]]))
            end
        end)
    end

    if olua.is_enum_type(cls) then
        local fields = olua.array("\n")
        for _, ei in ipairs(cls.enums) do
            local comment = ei.comment
            if comment and #comment > 0 then
                comment = comment:gsub("\n", "\n---")
                fields:pushf("---${comment}")
            end
            local value = ei.intvalue or "VALUE"
            olua.use(value)
            fields:pushf("${ei.name} = ${value},")
        end
        write(olua.format([[
            local ${luacls} = {
                ${fields}
            }
        ]]))
    else
        write(olua.format("local ${luacls} = {}"))
    end

    write("")

    olua.foreach(cls.funcs, function (arr)
        olua.use(cls, luacls)

        local func = arr[1]

        if not func.is_exposed or olua.is_enum_type(cls) then
            return
        end

        local func_comment = func.comment
        if func_comment and #func_comment > 0 then
            func_comment = func_comment:gsub("\n", "\n---")
            func_comment = olua.format("---${func_comment}")
        else
            func_comment = ""
        end

        local caller_args = olua.array(", ")

        if func.luacats then
            if #func_comment > 0 then
                write(func_comment)
            end
            write(func.luacats)
            for name in string.gmatch(func.luacats, "%-+@param +([^ ]+)") do
                caller_args:push(name)
            end
        else
            -- write function parameters
            local args_comment = olua.array("\n")
            if func.args and #func.args > 0 then
                local skip_first_arg = olua.is_oluaret(func)
                for _, arg in ipairs(func.args) do
                    if skip_first_arg then
                        skip_first_arg = false
                        goto continue
                    end
                    local name = arg.name or "arg${i}"
                    local type = olua.luatype(arg.type)
                    caller_args:push(name)

                    if olua.can_construct_from_string(arg) then
                        type = olua.format("${type}|string")
                    end

                    olua.use(type)

                    local arg_key = olua.format("---\\param +${name} *")
                    if func_comment:find(arg_key) then
                        func_comment = func_comment:gsub(arg_key, olua.format("---@param ${name} ${type} # "), 1)
                    else
                        args_comment:pushf("---@param ${name} ${type}")
                    end
                    ::continue::
                end
            end

            -- write return type
            local ret_key = olua.format("%-%-%-\\return *")
            if not func.ret then
                if func_comment:find(ret_key) then
                    func_comment = func_comment:gsub(ret_key, olua.format("---@return any # "), 1)
                else
                    args_comment:pushf("---@return any")
                end
            elseif func.ret.type.cxxcls ~= "void" then
                local ret_luacls = olua.luatype(func.ret.type)
                olua.use(ret_luacls)
                if func_comment:find(ret_key) then
                    func_comment = func_comment:gsub(ret_key, olua.format("---@return ${ret_luacls} # "), 1)
                else
                    args_comment:pushf("---@return ${ret_luacls}")
                end
            end
            if #func_comment > 0 then
                write(func_comment)
            end
            if #args_comment > 0 then
                write(tostring(args_comment))
            end
        end

        -- write overload
        for i, overload_func in ipairs(arr) do
            if i > 1 then
                local fn = gen_luafn(overload_func, cls)
                olua.use(fn)
                local olfi_comment = overload_func.comment
                if func.comment ~= olfi_comment and olfi_comment and #olfi_comment > 0 then
                    olfi_comment = olfi_comment:gsub("\n", "\n---")
                    write("---")
                    write(olua.format("---${olfi_comment}"))
                end
                write(olua.format("---@overload ${fn}"))
            end
        end

        -- write function prototype
        local static = func.is_static and "." or ":"
        olua.use(static)
        write(olua.format [[
            function ${luacls}${static}${func.luafn}(${caller_args}) end
        ]])
        write("")
    end)

    write(olua.format("return ${luacls}"))
end

---@param module idl.gen.module_desc
function olua.gen_annotation(module)
    if not module.api_dir then
        return
    end
    for _, cls in ipairs(module.class_types) do
        local luacls = cls.luacls:gsub("%.", "/")
        if luacls:find("<") then
            goto continue
        end
        local arr = olua.array("\n")
        local function append(value)
            if value then
                arr:push(value)
            end
        end
        local filename = cls.luacls:gsub("%.", "/")
        olua.use(filename)
        local path = olua.format("${module.api_dir}/library/${filename}.lua")
        local dir = path:match("(.*)/[^/]+$")
        olua.mkdir(dir)
        gen_class_annotation(cls, append)
        olua.write(path, tostring(arr))

        if module.entry == cls.cxxcls then
            path = olua.format("${module.api_dir}/library/${module.name}.lua")
            olua.write(path, olua.format([[
                ---AUTO GENERATED, DO NOT MODIFY!
                ---@meta ${module.name}

                return require("${cls.luacls}")
            ]]))
        end

        ::continue::
    end

    local name = module.api_dir:match("([^/]+)$")
    olua.use(name)
    olua.write(olua.format("${module.api_dir}/config.json"), olua.format([[
        {
            "$schema": "https://raw.githubusercontent.com/LuaLS/LLS-Addons/main/schemas/addon_config.schema.json",
            "words": ["%s+-${name}"],
            "files": ["${name}"],
            "settings": {}
        }
    ]]))
end
