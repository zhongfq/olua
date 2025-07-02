local operator = {
    __add = "add",
    __band = "band",
    __bnot = "bnot",
    __bor = "bor",
    __bxor = "bxor",
    __call = "call",
    __concat = "concat",
    __div = "div",
    __idiv = "idiv",
    __len = "len",
    __mod = "mod",
    __mul = "mul",
    __pow = "pow",
    __shl = "shl",
    __shr = "shr",
    __sub = "sub",
    __unm = "unm",
}

---@param func idl.gen.func_desc
---@return string
local function get_ret_luatype(func)
    local type = func.ret.type
    if func.ret.attr.unpack then
        local cls = olua.get_class(type.cxxcls) or olua.get_class(type.luacls)
        if not cls then
            print(olua.format("[WARNING]: class '${type.cxxcls}' not found"))
            return "unknown"
        end
        local exps = olua.array("")
        for i, var in ipairs(cls.vars) do
            exps:push(olua.luatype(var.get.ret.type))
            if i < #cls.vars then
                exps:push(", ")
            end
        end
        return tostring(exps)
    else
        return olua.luatype(type)
    end
end

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
                    olua.use(name, type)
                    args:pushf("${name}: ${type}")
                end
            else
                idx = idx + 1
                local name = arg.name or ("arg" .. idx)
                name = name:gsub("[^%w]", "_")
                local type = olua.luatype(arg.type)
                if olua.can_construct_from_string(arg) then
                    type = olua.format("${type}|string")
                end
                olua.use(type)
                args:pushf("${name}: ${type}")
            end
        end
    end

    local exps = olua.array("")
    exps:pushf([[fun(${args})]])

    if func.ret.type.cxxcls ~= "void" then
        exps:push(": ")
        exps:push(get_ret_luatype(func))
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
---@param annotation idl.gen.class_annotation
local function write_cls_comment(cls, annotation)
    local supercls = cls.supercls and olua.get_class(cls.supercls).luacls or nil
    supercls = supercls and olua.format(": ${supercls}") or ""

    local comment = cls.comment
    if comment then
        comment = cls.comment:gsub("\n", "\n---")
    else
        comment = ""
    end

    if olua.is_enum_type(cls) then
        annotation.comment:pushf([[
            ---@type ${cls.luacls}
            local VALUE

            ---${comment}
            ---@enum ${cls.luacls}
        ]])
        if cls.luacats then
            annotation.comment:push(cls.luacats)
        end
    else
        annotation.comment:pushf("---${comment}")
        if olua.is_func_type(cls.cxxcls) then
            local ti = olua.typeinfo(cls.cxxcls)
            olua.use(ti)
            annotation.comment:pushf([[
                ---
                ---${ti.funcdecl}
            ]])
        end
        annotation.comment:pushf("---@class ${cls.luacls} ${supercls}")
        if cls.luacats then
            annotation.comment:push(cls.luacats)
        end
    end
end

---@param cls idl.gen.class_desc
---@param annotation idl.gen.class_annotation
local function write_cls_prop(cls, annotation)
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
        annotation.fields:pushf([[
            ---@field ${prop.name} ${type} ${comment}
        ]])
    end
end

---@param cls idl.gen.class_desc
---@param annotation idl.gen.class_annotation
local function write_cls_var(cls, annotation)
    for _, var in ipairs(cls.vars) do
        local type = olua.luatype(var.get.ret.type)
        local optional = var.get.ret.attr.optional and "?" or ""
        olua.use(type, optional)
        annotation.fields:pushf([[
            ---@field ${var.name}${optional} ${type}
        ]])
    end
end

---@param cls idl.gen.class_desc
---@param annotation idl.gen.class_annotation
local function write_cls_const(cls, annotation)
    for _, const in ipairs(cls.consts) do
        local type = olua.luatype(const.type)
        olua.use(type)
        annotation.fields:pushf([[
            ---@field ${const.name} ${type}
        ]])
    end
end

---@param cls idl.gen.class_desc
---@param annotation idl.gen.class_annotation
local function write_cls_declare(cls, annotation)
    local luacls = cls.luacls:match("[^.]+$")
    olua.use(luacls)
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
        annotation.fields:pushf([[
            local ${luacls} = {
                ${fields}
            }
        ]])
    else
        annotation.fields:pushf("local ${luacls} = {}")
    end
end

local function write_cls_operator(cls, annotation)
    if not cls.options.reg_luatype then
        return
    end
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
            exprs:push(":")
            exprs:push(olua.luatype(func.ret.type))
        end
        if func.args and #func.args > 0 or func.ret then
            annotation.fields:pushf([[
                ---@operator ${exprs}
            ]])
        end
    end)
end

---@param cls idl.gen.class_desc
---@param annotation idl.gen.class_annotation
local function write_cls_func(cls, annotation)
    local luacls = cls.luacls:match("[^.]+$")
    olua.use(luacls)
    olua.foreach(cls.funcs, function (arr)
        olua.use(cls, luacls)

        local func = arr[1]

        if not func.is_exposed or olua.is_enum_type(cls) then
            return
        end

        local comment = func.comment
        if comment and #comment > 0 then
            comment = comment:gsub("\n", "\n---")
            comment = olua.format("---${comment}")
        else
            comment = ""
        end

        local caller_args = olua.array(", ")

        if func.luacats then
            if #comment > 0 then
                annotation.funcs:push(comment)
            end
            annotation.funcs:push(func.luacats)
            for name in string.gmatch(func.luacats, "%-+@param +([^ ]+)") do
                caller_args:push(name)
            end
        else
            -- write function parameters
            local args_comment = olua.array("\n")
            local args = func.args or {}
            if olua.is_oluaret(func) then
                table.remove(args, 1)
            end
            for _, arg in ipairs(args) do
                local name = arg.name or "arg${i}"
                local type = olua.luatype(arg.type)
                caller_args:push(name)

                if olua.can_construct_from_string(arg) then
                    type = olua.format("${type}|string")
                end

                olua.use(type)

                local arg_key = olua.format("---\\param +${name} *")
                if comment:find(arg_key) then
                    comment = comment:gsub(arg_key, olua.format("---@param ${name} ${type} # "), 1)
                else
                    args_comment:pushf("---@param ${name} ${type}")
                end
            end

            -- write return type
            local ret_key = olua.format("%-%-%-\\return *")
            if not func.ret then
                if comment:find(ret_key) then
                    comment = comment:gsub(ret_key, olua.format("---@return any # "), 1)
                else
                    args_comment:pushf("---@return any")
                end
            elseif func.ret.type.cxxcls ~= "void" then
                local ret_luatype = get_ret_luatype(func)
                olua.use(ret_luatype)
                if comment:find(ret_key) then
                    comment = comment:gsub(ret_key, olua.format("---@return ${ret_luatype} # "), 1)
                else
                    args_comment:pushf("---@return ${ret_luatype}")
                end
            end

            if #comment > 0 then
                annotation.funcs:push(comment)
            end

            if #args_comment > 0 then
                annotation.funcs:push(tostring(args_comment))
            end
        end

        -- write overload
        for i = 2, #arr do
            local overload_func = arr[i]
            local fn = gen_luafn(overload_func, cls)
            local overload_comment = overload_func.comment or ""
            if func.comment ~= overload_comment and #overload_comment > 0 then
                overload_comment = overload_comment:gsub("\n", "\n---")
                annotation.funcs:pushf([[
                    ---
                    ---${overload_comment}
                ]])
            end
            olua.use(fn)
            annotation.funcs:pushf("---@overload ${fn}")
        end

        -- write function prototype
        local static = func.is_static and "." or ":"
        olua.use(static)
        annotation.funcs:pushf([[
            function ${luacls}${static}${func.luafn}(${caller_args}) end
        ]])
        annotation.funcs:push("\n")
    end)
end

---@param cls idl.gen.class_desc
---@param path string
local function gen_class_annotation(cls, path)
    local luacls = cls.luacls:match("[^.]+$")

    ---@class idl.gen.class_annotation
    local annotation = {
        comment = olua.array("\n"),
        fields = olua.array("\n"),
        funcs = olua.array("\n"),
    }

    olua.willdo("generate lua annotation: ${cls.cxxcls}")

    write_cls_comment(cls, annotation)
    write_cls_prop(cls, annotation)
    write_cls_var(cls, annotation)
    write_cls_const(cls, annotation)
    write_cls_operator(cls, annotation)
    write_cls_declare(cls, annotation)
    write_cls_func(cls, annotation)

    olua.use(luacls)
    olua.write(path, olua.format([[
        ---AUTO GENERATED, DO NOT MODIFY!
        ---@meta ${cls.luacls}

        ${annotation.comment}
        ${annotation.fields}

        ${annotation.funcs}

        return ${luacls}
    ]]))
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
        local filename = cls.luacls:gsub("%.", "/")
        olua.use(filename)
        local path = olua.format("${module.api_dir}/library/${filename}.lua")
        local dir = path:match("(.*)/[^/]+$")
        olua.mkdir(dir)
        gen_class_annotation(cls, path)

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
