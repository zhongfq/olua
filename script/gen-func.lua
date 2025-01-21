---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param body string
local function wrap_func_with_try(cls, func, body)
    if olua.ENABLE_EXCEPTION then
        body = olua.format([[
            try {
                ${body}
            } catch (std::exception &e) {
                lua_pushfstring(L, "${cls.cxxcls}::${func.cxxfn}(): %s", e.what());
                luaL_error(L, olua_tostring(L, -1));
                return 0;
            }
        ]])
    end
    return body
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param write idl.gen.writer
local function gen_func_body(cls, func, write)
    local exprs = olua.array("\n")
    exprs:push("olua_startinvoke(L);")
    for line in string.gmatch(func.body, "[^\n]+") do
        local space = line:match("^([ ]*)return ")
        if space then
            exprs:push("olua_endinvoke(L);")
        end
        exprs:push(line)
    end
    local body = wrap_func_with_try(cls, func, tostring(exprs))
    olua.use(body)
    write(olua.format([[
        static int _olua_fun_${cls.cxxcls#}_${func.luafn}(lua_State *L)
        {
            ${body}
        }
    ]]))
end

---@param arg idl.gen.type_desc
---@return boolean
local function can_declare_as_pointer(arg)
    return not arg.attr.pack
        and not arg.type.subtypes
        and not arg.type.smartptr
        and not olua.has_pointer_flag(arg.type)
        and olua.is_pointer_type(arg.type)
end

---@param arg idl.gen.type_desc
---@return boolean?
function olua.can_construct_from_string(arg)
    return arg.type.from_string and not olua.has_pointer_flag(arg.type)
end

---@param arg idl.gen.type_desc|idl.gen.typeinfo
---@return boolean?
function olua.can_construct_from_table(arg)
    if arg.attr then
        local ti = arg.type
        return ti.from_table and not olua.has_pointer_flag(ti) and not arg.attr.pack
    else
        local ti = arg --[[@as idl.gen.typeinfo]]
        return ti.from_table and not olua.has_pointer_flag(ti)
    end
end

---@param arg idl.gen.type_desc
---@param name string
---@param codeset idl.gen.func_codeset
function olua.gen_decl_exp(arg, name, codeset)
    local decltype = olua.decltype(arg.type, true, true)
    local initial_value = olua.initial_value(arg.type)
    local var_name = arg.name or name
    local cast_to_pointer = can_declare_as_pointer(arg) and "*" or ""
    olua.use(decltype, initial_value, var_name, cast_to_pointer)
    codeset.decl_args:pushf([[
        ${decltype}${cast_to_pointer}${name}${initial_value};       /** ${var_name} */
    ]])
    if olua.can_construct_from_string(arg) then
        local default = arg.type.default and olua.format(" = ${arg.type.default}") or ""
        olua.use(default)
        codeset.decl_args:pushf([[
            ${decltype}${name}_from_string${default};       /** ${var_name} */
        ]])
    elseif olua.can_construct_from_table(arg) then
        local default = arg.type.default and olua.format(" = ${arg.type.default}") or ""
        olua.use(default)
        codeset.decl_args:pushf([[
            ${decltype}${name}_from_table${default};       /** ${var_name} */
        ]])
    end
end

---@param arg idl.gen.type_desc
---@param name string
---@param idx integer|string
---@param codeset idl.gen.func_codeset
function olua.gen_check_exp(arg, name, idx, codeset)
    -- lua value to cxx value
    local func_check = olua.conv_func(arg.type, arg.attr.pack and "pack" or "check")
    local check_args = codeset.check_args
    codeset.check_args = olua.array("\n")
    olua.use(name, idx, func_check)
    if arg.attr.pack then
        olua.assert(arg.type.packable, [[
            '${arg.type.cxxcls}' is not a packable type
            you should do one of:
                * remove '@pack' or '@unpack'
                * typeconf '${arg.type.cxxcls}'
                      .packable 'true'
        ]])
        codeset.check_args:pushf([[
            ${func_check}(L, ${idx}, &${name});
        ]])
    elseif olua.is_pointer_type(arg.type) or olua.is_func_type(arg.type) then
        codeset.check_args:pushf([[
            ${func_check}(L, ${idx}, &${name}, "${arg.type.luacls}");
        ]])
    elseif arg.type.subtypes then
        olua.assert(#arg.type.subtypes <= 2, "unsupport template arg types > 2 ")
        local subtype_decl_args = olua.array(", ")
        local subtype_template_args = olua.array(", ")
        local subtype_check_exp = olua.array("\n")
        local subtype_idx = 1
        local top = name .. "_top"
        codeset.decl_args:pushf("int ${top};")
        for i, subtype in ipairs(arg.type.subtypes) do
            local subtype_func_check = olua.conv_func(subtype, "check")
            local subtype_name = "arg" .. i
            local decltype = olua.decltype(subtype)
            local declarg = olua.decltype(subtype, nil, true)
            olua.use(subtype_func_check, subtype_name, decltype, declarg, top)
            subtype_decl_args:pushf("${declarg}*${subtype_name}")
            subtype_template_args:pushf("${decltype}")
            if olua.can_construct_from_table(subtype) then
                subtype_check_exp:pushf([[
                    if (olua_istable(L, ${top} + ${subtype_idx})) {
                        olua_check_table(L, ${top} + ${subtype_idx}, ${subtype_name});
                    } else {
                        ${subtype_func_check}(L, ${top} + ${subtype_idx}, ${subtype_name}, "${subtype.luacls}");
                    }
                ]])
            elseif olua.is_pointer_type(subtype) then
                subtype_check_exp:pushf([[
                    ${subtype_func_check}(L, ${top} + ${subtype_idx}, ${subtype_name}, "${subtype.luacls}");
                ]])
            else
                subtype_check_exp:pushf([[
                    ${subtype_func_check}(L, ${top} + ${subtype_idx}, ${subtype_name});
                ]])
            end
            subtype_idx = subtype_idx + 1
        end
        codeset.check_args:pushf([[
            ${top} = lua_gettop(L);
            ${func_check}<${subtype_template_args}>(L, ${idx}, ${name}, [L, ${top}](${subtype_decl_args}) {
                ${subtype_check_exp}
            });
        ]])
    else
        codeset.check_args:pushf("${func_check}(L, ${idx}, &${name});")
    end

    if olua.can_construct_from_string(arg) then
        check_args:pushf([[
            if (olua_isstring(L, ${idx})) {
                olua_check_string(L, ${idx}, &${name}_from_string);
                ${name} = &${name}_from_string;
            } else {
                ${codeset.check_args}
            }
        ]])
    elseif olua.can_construct_from_table(arg) then
        check_args:pushf([[
            if (olua_istable(L, ${idx})) {
                olua_check_table(L, ${idx}, &${name}_from_table);
                ${name} = &${name}_from_table;
            } else {
                ${codeset.check_args}
            }
        ]])
    elseif arg.attr.nullable then
        check_args:pushf([[
            if (!olua_isnoneornil(L, ${idx})) {
                ${codeset.check_args}
            }
        ]])
    else
        check_args:pushf([[${codeset.check_args}]])
    end

    codeset.check_args = check_args

    if arg.attr.pack then
        codeset.idx = codeset.idx + arg.type.packvars - 1
    end
end

---@param arg idl.gen.type_desc
---@param name string
---@param codeset {push_args:olua.array}
function olua.gen_push_exp(arg, name, codeset)
    local arg_name = name
    local func_push = olua.conv_func(arg.type, arg.attr.unpack and "unpack" or "push")
    local func_copy = olua.conv_func(arg.type, "copy")
    olua.use(arg_name, func_push, func_copy)
    if arg.attr.unpack then
        olua.assert(arg.type.packable, [[
            '${arg.type.cxxcls}' is not a packable type
            you should do one of:
                * remove '@pack' or '@unpack'
                * typeconf '${arg.type.cxxcls}'
                      .packable 'true'
        ]])
        codeset.push_args:pushf("${func_push}(L, &${arg_name});")
    elseif olua.is_pointer_type(arg.type) or olua.is_func_type(arg.type) then
        if olua.has_cast_flag(arg.type) or arg.type.smartptr or olua.is_func_type(arg.type) then
            codeset.push_args:pushf('${func_push}(L, &${arg_name}, "${arg.type.luacls}");')
        elseif olua.has_pointee_flag(arg.type) then
            codeset.push_args:pushf('${func_push}(L, ${arg_name}, "${arg.type.luacls}");')
        else
            codeset.push_args:pushf('${func_copy}(L, ${arg_name}, "${arg.type.luacls}");')
        end
    elseif arg.type.subtypes then
        olua.assert(#arg.type.subtypes <= 2, "unsupport template arg types > 2 ")
        local subtype_decl_args = olua.array(", ")
        local subtype_template_args = olua.array(", ")
        local subtype_push_exp = olua.array("\n")
        for i, subtype in ipairs(arg.type.subtypes) do
            local subtype_func_push = olua.conv_func(subtype, "push")
            local subtype_func_copy = olua.conv_func(subtype, "copy")
            local subtype_name = "arg" .. i
            local decltype = olua.decltype(subtype)
            local declarg = olua.decltype(subtype, nil, true)
            subtype_template_args:pushf("${decltype}")
            olua.use(subtype_func_push, subtype_func_copy, subtype_name, decltype, declarg)
            if subtype.smartptr then
                subtype_decl_args:pushf("${declarg}&${subtype_name}")
                subtype_push_exp:pushf('${subtype_func_push}(L, &${subtype_name}, "${subtype.luacls}");')
            elseif subtype.luacls and olua.is_pointer_type(decltype) then
                subtype_decl_args:pushf("${declarg}${subtype_name}")
                subtype_push_exp:pushf('${subtype_func_push}(L, ${subtype_name}, "${subtype.luacls}");')
            elseif olua.is_pointer_type(subtype) then
                subtype_decl_args:pushf("${declarg}&${subtype_name}")
                subtype_push_exp:pushf('${subtype_func_copy}(L, ${subtype_name}, "${subtype.luacls}");')
            else
                local subtype_cast = olua.is_pointer_type(decltype) and "" or "&"
                olua.use(subtype_cast)
                subtype_decl_args:pushf("${declarg}${subtype_cast}${subtype_name}")
                subtype_push_exp:pushf("${subtype_func_push}(L, ${subtype_name});")
            end
        end
        codeset.push_args:pushf([[
            ${func_push}<${subtype_template_args}>(L, ${arg_name}, [L](${subtype_decl_args}) {
                ${subtype_push_exp}
            });
        ]])
    else
        codeset.push_args:pushf("${func_push}(L, ${arg_name});")
    end
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param arg idl.gen.type_desc
---@param idx integer
---@param name string
---@param codeset idl.gen.func_codeset
function olua.gen_addref_exp(cls, func, arg, idx, name, codeset)
    if not arg.attr.addref then
        return
    end

    olua.assert(#arg.attr.addref > 0, "no ref args")

    -- ^|*~
    if arg.attr.addref[1]:find("[%^%|%*%~]") then
        local ref_name = func.cxxfn:gsub("^[Ss]et", ""):gsub("^[Gg]et", "")
        table.insert(arg.attr.addref, 1, string.lower(ref_name))
    end

    olua.assert(not func.is_static or func.ret.type.luacls or arg.attr.addref[3])

    local ref_name = assert(arg.attr.addref[1], func.cxxfn .. " no addref name")
    local ref_mode = assert(arg.attr.addref[2], func.cxxfn .. " no addref flag")
    local ref_store = arg.attr.addref[3] or (func.is_static and "-1" or "1")

    if ref_store:find("^::") then
        if not codeset.has_ref_store then
            codeset.has_ref_store = true
            codeset.insert_before:pushf([[
                int ref_store = ${cls.cxxcls}${ref_store}(L);
            ]])
        end
        ref_store = "ref_store"
    end

    if arg.type.cxxcls == "void" then
        olua.assert(func.ret == arg)
        olua.assert(not func.is_static, "no addref object")
        olua.assert(arg.attr.addref[3], "must supply where to addref object")
        idx = 1
    elseif arg.type.subtypes then
        olua.assert(ref_mode == "|", "expect use like: @addref(ref_name |)")
        if #arg.type.subtypes == 1 then
            local subtype = arg.type.subtypes[1]
            olua.assert(olua.is_pointer_type(subtype), "'${subtype.cxxcls}' not a pointer type")
        else
            olua.assert(#arg.type.subtypes == 2)
            olua.assert(olua.is_pointer_type(arg.type.subtypes[1])
                or olua.is_pointer_type(arg.type.subtypes[2]))
        end
    else
        olua.assert(olua.is_pointer_type(arg.type), "'${arg.type.cxxcls}' not a pointer type")
    end

    if ref_mode == "|" then
        if arg.type.subtypes then
            if arg.attr.pack then
                local subtype = arg.type.subtypes[1]
                local func_push = olua.conv_func(arg.type, "push")
                local subtype_func_push = olua.conv_func(subtype, "push")
                local ref_store2 = ref_store == "ref_store" and "ref_store2" or "ref_store"
                codeset.insert_after:pushf([[
                    int ${ref_store2} = lua_absindex(L, ${ref_store});
                    ${func_push}<${subtype.cxxcls}>(L, &${name}, [L](${subtype.cxxcls}value) {
                        ${subtype_func_push}(L, value, "${subtype.luacls}");
                    });
                    olua_addref(L, ${ref_store2}, "${ref_name}", -1, OLUA_REF_MULTI | OLUA_REF_TABLE);
                    lua_pop(L, 1);
                ]])
            else
                if func.is_variable then
                    codeset.insert_after:pushf('olua_delallrefs(L, ${ref_store}, "${ref_name}");')
                end
                codeset.insert_after:pushf(
                    'olua_addref(L, ${ref_store}, "${ref_name}", ${idx}, OLUA_REF_MULTI | OLUA_REF_TABLE);')
            end
        elseif arg.type.cxxcls:find("<") then
            codeset.insert_after:pushf([[
                for (auto obj : *${name}) {
                    olua_pushobj(L, obj);
                    olua_addref(L, 1, "${ref_name}", -1, OLUA_REF_MULTI);
                    lua_pop(L, 1);
                }
            ]])
        else
            codeset.insert_after:pushf(
                'olua_addref(L, ${ref_store}, "${ref_name}", ${idx}, OLUA_REF_MULTI);')
        end
    elseif ref_mode == "^" then
        codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${idx}, OLUA_REF_ALONE);')
    else
        error("no support addref flag: " .. ref_mode)
    end
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param arg idl.gen.type_desc
---@param idx integer
---@param name string
---@param codeset idl.gen.func_codeset
function olua.gen_delref_exp(cls, func, arg, idx, name, codeset)
    if not arg.attr.delref then
        return
    end

    olua.assert(#arg.attr.delref > 0, "no ref args")

    -- ^|*~
    if arg.attr.delref[1]:find("[%^%|%*%~]") then
        local ref_name = func.cxxfn:gsub("^[Ss]et", ""):gsub("^[Gg]et", "")
        table.insert(arg.attr.delref, 1, string.lower(ref_name))
    end

    olua.assert(not func.is_static or arg.type.luacls or arg.attr.delref[3])

    local ref_name = assert(arg.attr.delref[1], func.cxxfn .. " no ref name")
    local ref_mode = assert(arg.attr.delref[2], func.cxxfn .. " no delref flag")
    local ref_store = arg.attr.delref[3] or (func.is_static and "-1" or "1")

    if ref_store:find("^::") then
        if not codeset.has_ref_store then
            codeset.has_ref_store = true
            codeset.insert_before:pushf([[
                int ref_store = ${cls.cxxcls}${ref_store}(L);
            ]])
        end
        ref_store = "ref_store"
    end

    if ref_mode == "|" or ref_mode == "^" then
        if arg.type.cxxcls == "void" then
            olua.assert(not func.is_static, "no delref object")
            olua.assert(arg.attr.delref[3], "must supply where to delref object")
            idx = 1
        else
            olua.assert(olua.is_pointer_type(arg.type), "'${arg.type.cxxcls}' not a pointer type")
        end
    end

    if ref_mode == "~" then
        codeset.insert_before:pushf('olua_startcmpref(L, ${ref_store}, "${ref_name}");')
        codeset.insert_after:pushf('olua_endcmpref(L, ${ref_store}, "${ref_name}");')
    elseif ref_mode == "*" then
        codeset.insert_after:pushf('olua_delallrefs(L, ${ref_store}, "${ref_name}");')
    elseif ref_mode == "|" then
        if arg.type.subtypes then
            codeset.insert_after:pushf(
                'olua_delref(L, ${ref_store}, "${ref_name}", ${idx}, OLUA_REF_MULTI | OLUA_REF_TABLE);')
        else
            codeset.insert_after:pushf(
                'olua_delref(L, ${ref_store}, "${ref_name}", ${idx}, OLUA_REF_MULTI);')
        end
    elseif ref_mode == "^" then
        codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${idx}, OLUA_REF_ALONE);')
    else
        error("no support delref flag: " .. ref_mode)
    end
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param codeset idl.gen.func_codeset
local function gen_func_args(cls, func, codeset)
    if not func.is_static then
        -- first argument is cxx userdata object
        codeset.idx = codeset.idx + 1
        local ti = olua.typeinfo(cls.cxxcls)
        local func_to = olua.conv_func(ti, "to")
        codeset.decl_args:pushf("${cls.cxxcls} *self = nullptr;")
        codeset.check_args:pushf('${func_to}(L, 1, &self, "${ti.luacls}");')
    end

    local args = olua.slice(func.args)

    if olua.is_oluaret(func) then
        local arg = args[1]
        olua.assert(arg and arg.type.cxxcls == "lua_State", "first arg type must be 'lua_State *'")
        codeset.caller_args:push("L")
        table.remove(args, 1)
    end

    for i, arg in ipairs(args) do
        local name = "arg" .. i
        local idx = codeset.idx + 1
        codeset.idx = idx

        if olua.has_cast_flag(arg.type) or can_declare_as_pointer(arg) then
            codeset.caller_args:pushf("*${name}")
        else
            codeset.caller_args:pushf("${name}")
        end

        olua.gen_decl_exp(arg, name, codeset)
        olua.gen_check_exp(arg, name, idx, codeset)
        olua.gen_addref_exp(cls, func, arg, idx, name, codeset)
        olua.gen_delref_exp(cls, func, arg, idx, name, codeset)
    end

    if func.is_variadic then
        codeset.caller_args:push("nullptr")
    end
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param codeset idl.gen.func_codeset
local function gen_func_ret(cls, func, codeset)
    if func.ret.type.cxxcls ~= "void" then
        local decltype = olua.decltype(func.ret.type, nil, true)
        if olua.has_cast_flag(func.ret.type) then
            decltype = decltype:gsub(" %*$", " &")
        end
        if func.is_variable
            and not olua.has_pointee_flag(func.ret.type)
            and not olua.is_value_type(func.ret.type)
        then
            codeset.decl_ret = olua.format("${decltype}&ret = ")
        else
            codeset.decl_ret = olua.format("${decltype}ret = ")
        end

        local retblock = { push_args = olua.array("\n") }

        if olua.is_oluaret(func) then
            codeset.num_ret = "(int)ret"
        else
            olua.gen_push_exp(func.ret, "ret", retblock)
            codeset.push_ret = olua.format("int num_ret = ${retblock.push_args}")
        end

        if #codeset.push_ret > 0 then
            codeset.num_ret = "num_ret"
        end
    end

    olua.gen_addref_exp(cls, func, func.ret, -1, "ret", codeset)
    olua.gen_delref_exp(cls, func, func.ret, -1, "ret", codeset)
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param write fun(s: string)
---@param fidx? string
local function gen_one_func(cls, func, write, fidx)
    local caller = func.is_static and (cls.cxxcls .. "::") or "self->"
    local cxxfn = func.cxxfn
    local args_begin = not func.is_variable and "(" or (func.ret.type.cxxcls ~= "void" and "" or " = ")
    local args_end = not func.is_variable and ")" or ""
    local cb_arg, cb_argn
    fidx = fidx or ""

    ---@class idl.gen.func_codeset
    ---@field num_ret string|integer
    local codeset = {
        idx = 0,
        decl_args = olua.array("\n"),
        check_args = olua.array("\n"),
        caller_args = olua.array(", "),
        insert_after = olua.array("\n"),
        insert_before = olua.array("\n"),
        has_ref_store = false,
        push_ret = "",
        decl_ret = "",
        num_ret = "0",
        post_new = "",
        callback = "",
        push_stub = "",
        remove_function_callback = "",
    }

    codeset.insert_after:push(func.insert_after)
    codeset.insert_before:push(func.insert_before)

    olua.willdo([[
        gen one func:
            class = ${cls.cxxcls}
            func = ${func.funcdesc}
    ]])

    if func.body then
        gen_func_body(cls, func, write)
        return
    end

    if func.ret.attr.postnew then
        codeset.insert_after:push("olua_postnew(L, ret);")
    end

    gen_func_args(cls, func, codeset)
    gen_func_ret(cls, func, codeset)

    for i, arg in ipairs(func.args) do
        if olua.is_func_type(arg.type, cls) then
            olua.assert(not cb_arg, "not support multi callback")
            cb_arg = arg
            cb_argn = i
        end
    end

    if func.tag_mode then
        olua.gen_callback(cls, func, cb_arg, cb_argn, codeset)
    end

    if #codeset.insert_before > 0 then
        table.insert(codeset.insert_before, 1, "// insert code before call")
    end

    if #codeset.insert_after > 0 then
        table.insert(codeset.insert_after, 1, "// insert code after call")
    end

    if func.ret.attr.extend then
        caller = func.ret.attr.extend[1] .. "::"
    end

    if func.ret.attr.template then
        cxxfn = func.ret.attr.template:join(" ")
    end

    if func.ret.attr.operator then
        local caller_args = codeset.caller_args:slice()
        if not func.is_static then
            caller_args:unshift("*self")
        end
        cxxfn = func.ret.attr.operator:join(" ")
        local op = cxxfn:gsub("operator", "")
        local arg1 = caller_args[1]
        local arg2 = caller_args[2]
        if arg1 and arg2 then
            caller = olua.format("(${arg1}) ${op} (${arg2})");
        else
            caller = olua.format("${op}(${arg1})");
        end
        args_begin = "";
        args_end = "";
        codeset.caller_args:clear()
    elseif func.is_contructor then
        caller = "new " .. cls.cxxcls
        codeset.post_new = "olua_postnew(L, ret);"
    else
        caller = caller .. cxxfn
    end

    if #codeset.push_stub > 0 then
        codeset.num_ret = 1
        codeset.push_ret = olua.format([[
            ${codeset.push_stub};
        ]])
        if not func.is_contructor then
            codeset.post_new = ""
        end
    end

    local func_body = ""

    if func.cxxfn == "as" then
        local asexp = olua.array("\n")
        for _, ascls in ipairs(func.ret.attr.as) do
            local asti = olua.typeinfo(ascls .. "*")
            local asluacls = asti.template_luacls or asti.luacls
            asexp:pushf([[
                if (olua_strequal(arg1, "${asluacls}")) {
                    olua_pushobj_as<${ascls}>(L, 1, self, "as.${asluacls}");
                    break;
                }
            ]])
        end
        func_body = olua.format([[
            olua_startinvoke(L);

            ${codeset.decl_args}

            ${codeset.check_args}

            do {
                if (olua_isa(L, 1, arg1)) {
                    lua_pushvalue(L, 1);
                    break;
                }
                ${asexp}

                luaL_error(L, "'${cls.cxxcls}' can't cast to '%s'", arg1);
            } while (0);

            olua_endinvoke(L);

            return 1;
        ]])
    else
        olua.use(args_begin, args_end)
        func_body = olua.format([[
            olua_startinvoke(L);

            ${codeset.decl_args}

            ${codeset.check_args}

            ${codeset.insert_before}

            ${codeset.callback}

            // ${func.funcdesc}
            ${codeset.decl_ret}${caller}${args_begin}${codeset.caller_args}${args_end};
            ${codeset.push_ret}
            ${codeset.post_new}

            ${codeset.insert_after}

            ${codeset.remove_function_callback}

            olua_endinvoke(L);

            return ${codeset.num_ret};
        ]])
    end

    func_body = wrap_func_with_try(cls, func, func_body)

    write(olua.format([[
        static int _olua_fun_${cls.cxxcls#}_${func.luafn}${fidx}(lua_State *L)
        {
            ${func_body}
        }
    ]]))
end

---@param func idl.gen.func_desc
---@return integer
local function get_num_args(func)
    local count = 0
    for _, arg in ipairs(func.args) do
        if arg.attr.pack then
            count = count + arg.type.packvars
        else
            count = count + 1
        end
    end
    if not func.is_static then
        count = count + 1
    end
    return count
end

---@param funcs idl.gen.func_desc[]
---@param num_args integer
---@return idl.gen.func_desc[]
local function get_func_with_num_args(funcs, num_args)
    local arr = {}
    for _, func in ipairs(funcs) do
        local n = num_args
        if olua.is_oluaret(func) then
            n = n + 1
        end
        if get_num_args(func) == n then
            arr[#arr + 1] = func
        end
    end
    return arr
end

---@param cls idl.gen.class_desc
---@param fns idl.gen.func_desc[]
---@return string
local function gen_test_and_call(cls, fns)
    ---@type {max_vars: integer, exp1: string, exp2: string?}[]
    local callblock = {}
    for _, func in ipairs(fns) do
        if #func.args > 0 then
            local test_exps = olua.array(" && ")
            local max_vars = 1
            local argn = 0
            local args = olua.clone(func.args)
            if olua.is_oluaret(func) then
                table.remove(args, 1)
            end
            if not func.is_static then
                table.insert(args, 1, olua.parse_type({
                    type = olua.format("${cls.cxxcls} *"),
                    attr = olua.array(),
                }, cls))
            end
            for _, arg in ipairs(args) do
                local func_is = olua.conv_func(arg.type, arg.attr.pack and "canpack" or "is")
                local test_another = ""
                argn = argn + 1
                max_vars = math.max(arg.type.packvars or 1, max_vars)

                if olua.can_construct_from_table(arg) then
                    test_another = " " .. olua.format("|| olua_is_table(L, ${argn}, (${arg.type.cxxcls} *)nullptr)")
                elseif olua.can_construct_from_string(arg) then
                    test_another = " " .. olua.format("|| olua_is_string(L, ${argn})")
                elseif arg.attr.nullable then
                    test_another = " " .. olua.format("|| olua_isnil(L, ${argn})")
                end

                olua.use(func_is, test_another, cls)
                if olua.is_pointer_type(arg.type) or olua.is_func_type(arg.type) then
                    if arg.attr.pack then
                        test_exps:pushf([[
                            (${func_is}(L, ${argn}, (${arg.type.cxxcls} *)nullptr)${test_another})
                        ]])
                    else
                        test_exps:pushf([[
                            (${func_is}(L, ${argn}, "${arg.type.luacls}")${test_another})
                        ]])
                    end
                else
                    test_exps:pushf([[
                        (${func_is}(L, ${argn})${test_another})
                    ]])
                end

                if arg.attr.pack then
                    argn = argn + arg.type.packvars - 1
                end
            end

            callblock[#callblock + 1] = {
                max_vars = max_vars,
                exp1 = olua.format([[
                    // if (${test_exps}) {
                        // ${func.funcdesc}
                        return _olua_fun_${cls.cxxcls#}_${func.luafn}$${func.index}(L);
                    // }
                ]]),
                exp2 = olua.format([[
                    if (${test_exps}) {
                        // ${func.funcdesc}
                        return _olua_fun_${cls.cxxcls#}_${func.luafn}$${func.index}(L);
                    }
                ]]),
            }
        else
            if #fns ~= 1 then
                olua.error("${cls.cxxcls} has multi functions with same prototype: ${func.prototype}")
            end
            callblock[#callblock + 1] = {
                max_vars = 1,
                exp1 = olua.format([[
                    // ${func.funcdesc}
                    return _olua_fun_${cls.cxxcls#}_${func.luafn}$${func.index}(L);
                ]])
            }
        end
    end

    table.sort(callblock, function (a, b) return a.max_vars > b.max_vars end)

    local exprs = olua.array("\n\n")

    for i, v in ipairs(callblock) do
        exprs:push(i == #callblock and v.exp1 or v.exp2)
    end

    return tostring(exprs)
end

---@param cls idl.gen.class_desc
---@param funcs idl.gen.func_desc[]
---@param write idl.gen.writer
local function gen_multi_func(cls, funcs, write)
    local exprs = olua.array("\n\n")
    local max_args = 0

    for _, func in ipairs(funcs) do
        max_args = math.max(max_args, get_num_args(func))
        gen_one_func(cls, func, write, "$" .. func.index)
        write("")
    end

    for i = 0, max_args do
        local arr = get_func_with_num_args(funcs, i)
        if #arr > 0 then
            local test_and_call = gen_test_and_call(cls, arr)
            olua.use(test_and_call)
            exprs:pushf([[
                if (num_args == ${i}) {
                    ${test_and_call}
                }
            ]])
        end
    end

    local luafn = funcs[1].luafn
    olua.use(luafn)
    write(olua.format([[
        static int _olua_fun_${cls.cxxcls#}_${luafn}(lua_State *L)
        {
            int num_args = lua_gettop(L);

            ${exprs}

            luaL_error(L, "method '${cls.cxxcls}::${luafn}' not support '%d' arguments", num_args);

            return 0;
        }
    ]]))
end

---@param cls idl.gen.class_desc
---@param funcs idl.gen.func_desc[]
---@param write idl.gen.writer
function olua.gen_class_func(cls, funcs, write)
    if #funcs == 1 then
        gen_one_func(cls, funcs[1], write)
    else
        gen_multi_func(cls, funcs, write)
    end
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_pack_func(cls, write)
    local codeset = {
        decl_args = olua.array("\n"),
        check_args = olua.array("\n"),
    }
    for i, var in ipairs(cls.vars) do
        local pi = var.set.args[1]
        local name = "arg" .. i
        local pack = pi.attr.pack
        pi.attr.pack = {}
        olua.gen_decl_exp(pi, name, codeset)
        pi.attr.pack = pack
        olua.gen_check_exp(pi, name, "idx + " .. (i - 1), codeset)
        codeset.check_args:pushf([[
            value->${var.set.cxxfn} = ${name};
        ]])
        codeset.check_args:push("")
    end

    write(olua.format([[
        OLUA_LIB void olua_pack_object(lua_State *L, int idx, ${cls.cxxcls} *value)
        {
            idx = lua_absindex(L, idx);

            ${codeset.decl_args}

            ${codeset.check_args}
        }
    ]]))
    write("")
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_unpack_func(cls, write)
    local num_args = #cls.vars
    local codeset = { push_args = olua.array("\n") }
    for _, var in ipairs(cls.vars) do
        local pi = var.set.args[1]
        local name = olua.format("value->${var.set.cxxfn}")
        olua.gen_push_exp(pi, name, codeset)
    end

    olua.use(num_args)
    write(olua.format([[
        OLUA_LIB int olua_unpack_object(lua_State *L, const ${cls.cxxcls} *value)
        {
            ${codeset.push_args}

            return ${num_args};
        }
    ]]))
    write("")
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_canpack_func(cls, write)
    local exps = olua.array(" && ")
    for i, var in ipairs(cls.vars) do
        local arg = var.set.args[1]
        local func_is = olua.conv_func(arg.type, "is")
        local N = i - 1
        olua.use(func_is, N)
        if olua.is_pointer_type(arg.type) then
            exps:pushf('${func_is}(L, idx + ${N}, "${arg.type.luacls}")')
        else
            exps:pushf("${func_is}(L, idx + ${N})")
        end
    end
    write(olua.format([[
        OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const ${cls.cxxcls} *)
        {
            return ${exps};
        }
    ]]))
    write("")
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_checktable_func(cls, write)
    local codeset = { check_args = olua.array("\n"), decl_args = olua.array("\n") }
    local vars = olua.ordered_map()

    ---@param c idl.gen.class_desc
    local function copy_var(c)
        if c.supercls then
            copy_var(olua.get_class(c.supercls))
        end
        for _, v in ipairs(c.vars) do
            vars:replace(v.name, {
                name = v.name,
                attr = v.get.ret.attr,
                type = v.get.ret.type,
            })
        end
    end
    copy_var(cls)
    for i, var in ipairs(vars) do
        local argname = "arg" .. i
        olua.gen_decl_exp(var, argname, codeset)
        codeset.check_args:pushf([[olua_getfield(L, idx, "${var.name}");]])
        if var.attr.optional then
            local subset = { check_args = olua.array("\n") }
            olua.gen_check_exp(var, argname, -1, subset)
            codeset.check_args:pushf([[
                if (!olua_isnoneornil(L, -1)) {
                    ${subset.check_args}
                    value->${var.name} = ${argname};
                }
                lua_pop(L, 1);
            ]])
        else
            olua.gen_check_exp(var, argname, -1, codeset)
            codeset.check_args:pushf([[
                value->${var.name} = ${argname};
                lua_pop(L, 1);
            ]])
        end
        codeset.check_args:push("")
    end
    write(olua.format([[
        OLUA_LIB void olua_check_table(lua_State *L, int idx, ${cls.cxxcls} *value)
        {
            ${codeset.decl_args}

            ${codeset.check_args}
        }
    ]]))
    write("")
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_istable_func(cls, write)
    local exps = olua.array(" && ")
    for i = #cls.vars, 1, -1 do
        local var = cls.vars[i]
        olua.use(var)
        exps:pushf([[olua_hasfield(L, idx, "${var.name}")]])
    end
    write(olua.format([[
        OLUA_LIB bool olua_is_table(lua_State *L, int idx, ${cls.cxxcls} *)
        {
            return ${exps};
        }
    ]]))
    write("")
end

---@param module idl.gen.module_desc
---@param write idl.gen.writer
function olua.gen_pack_header(module, write)
    for _, cls in ipairs(module.class_types) do
        local exps = olua.array("\n")
        if cls.options.packable and not cls.options.packvars then
            exps:pushf([[
                OLUA_LIB void olua_pack_object(lua_State *L, int idx, ${cls.cxxcls} *value);
                OLUA_LIB int olua_unpack_object(lua_State *L, const ${cls.cxxcls} *value);
                OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const ${cls.cxxcls} *);
            ]])
        end
        if cls.options.from_table then
            exps:pushf([[
                OLUA_LIB bool olua_is_table(lua_State *L, int idx, ${cls.cxxcls} *);
                OLUA_LIB void olua_check_table(lua_State *L, int idx, ${cls.cxxcls} *value);
            ]])
        end
        if #exps > 0 then
            write(cls.macro)
            write(olua.format([[
                // ${cls.cxxcls}
                ${exps}
            ]]))
            write(cls.macro and "#endif" or nil)
            write("")
        end
    end
end

---@param module idl.gen.module_desc
---@param write idl.gen.writer
function olua.gen_pack_source(module, write)
    for _, cls in ipairs(module.class_types) do
        local exps = olua.array("\n")
        local function write_func(str)
            exps:push(str)
        end
        if cls.options.packable and not cls.options.packvars then
            gen_pack_func(cls, write_func)
            gen_unpack_func(cls, write_func)
            gen_canpack_func(cls, write_func)
        end
        if cls.options.from_table then
            gen_checktable_func(cls, write_func)
            gen_istable_func(cls, write_func)
        end
        if #exps > 0 then
            write(cls.macro)
            write(tostring(exps))
            write(cls.macro and "#endif" or nil)
            write("")
        end
    end
end
