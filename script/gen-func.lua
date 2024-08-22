---@param cls idl.gen.class_desc
---@param fi idl.gen.func_desc
---@param write idl.gen.writer
local function gen_func_body(cls, fi, write)
    local body = assert(fi.body)
    body = string.gsub(body, "^[\n ]*{", "{\n    olua_startinvoke(L);\n")
    body = string.gsub(body, "(\n)([ ]*)(return )", function (lf, indent, ret)
        olua.use(lf, indent, ret)
        return olua.format([[
            ${lf}

            ${indent}olua_endinvoke(L);

            ${indent}${ret}
        ]]), nil
    end)
    olua.use(cls)
    write(olua.format([[
        static int _${cls.cppcls#}_${fi.cppfunc}(lua_State *L)
        ${body}
    ]]))
end

---@param arg idl.gen.type_desc
---@param name string
---@param codeset idl.gen.func_codeset
function olua.gen_decl_exp(arg, name, codeset)
    local decltype = olua.decltype(arg.type, true, true)
    local initial_value = olua.initial_value(arg.type)
    local var_name = arg.name or name
    olua.use(decltype, initial_value, var_name)
    codeset.decl_args:pushf([[
        ${decltype}${name}${initial_value};       /** ${var_name} */
    ]])
end

---@param arg idl.gen.type_desc
---@param name string
---@param idx integer|string
---@param codeset idl.gen.func_codeset
function olua.gen_check_exp(arg, name, idx, codeset)
    -- lua value to cpp value
    local func_check = olua.conv_func(arg.type, arg.attr.pack and "pack" or "check")
    local check_args = codeset.check_args
    codeset.check_args = olua.array("\n")
    olua.use(name, idx)
    if arg.attr.pack then
        olua.assert(arg.type.packable, [[
            '${arg.type.cppcls}' is not a packable type
            you should do one of:
                * remove '@pack' or '@unpack'
                * typeconf '${arg.type.cppcls}'
                      .packable 'true'
        ]])
        codeset.check_args:pushf([[
            ${func_check}(L, ${idx}, &${name});
        ]])
    elseif olua.is_pointer_type(arg.type)
        or olua.is_func_type(arg.type)
        or arg.type.smartptr
    then
        codeset.check_args:pushf([[
            ${func_check}(L, ${idx}, &${name}, "${arg.type.luacls}");
        ]])
    elseif arg.type.subtypes then
        olua.assert(#arg.type.subtypes <= 2, "unsupport template arg types > 2 ")
        local subtype_decl_args = olua.array(", ")
        local subtype_template_args = olua.array(", ")
        local subtype_check_exp = olua.array("\n")
        local subtype_idx = -1
        for i, subtype in ipairs(arg.type.subtypes) do
            local subtype_func_check = olua.conv_func(subtype, "check")
            local subtype_name = "arg" .. i
            local decltype = olua.decltype(subtype)
            local declarg = olua.decltype(subtype, nil, true)
            olua.use(subtype_func_check, subtype_name, decltype, declarg)
            subtype_decl_args:pushf("${declarg}*${subtype_name}")
            subtype_template_args:pushf("${decltype}")
            if subtype.smartptr or olua.is_pointer_type(subtype) then
                subtype_check_exp:pushf([[
                    ${subtype_func_check}(L, ${subtype_idx}, ${subtype_name}, "${subtype.luacls}");
                ]])
            else
                subtype_check_exp:pushf([[
                    ${subtype_func_check}(L, ${subtype_idx}, ${subtype_name});
                ]])
            end
            subtype_idx = subtype_idx - 1
        end
        codeset.check_args:pushf([[
            ${func_check}<${subtype_template_args}>(L, ${idx}, ${name}, [L](${subtype_decl_args}) {
                ${subtype_check_exp}
            });
        ]])
    else
        codeset.check_args:pushf("${func_check}(L, ${idx}, &${name});")
    end

    if arg.attr.nullable then
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
    local func_copy = olua.conv_func(arg.type, "pushcopy")
    olua.use(arg_name, func_push, func_copy)
    if arg.attr.unpack then
        olua.assert(arg.type.packable, [[
            '${arg.type.cppcls}' is not a packable type
            you should do one of:
                * remove '@pack' or '@unpack'
                * typeconf '${arg.type.cppcls}'
                      .packable 'true'
        ]])
        codeset.push_args:pushf("${func_push}(L, &${arg_name});")
    elseif olua.is_pointer_type(arg.type) or olua.is_func_type(arg.type) then
        if olua.has_cast_flag(arg.type)
            or arg.type.smartptr
            or olua.is_func_type(arg.type)
        then
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
            local subtype_func_copy = olua.conv_func(subtype, "pushcopy")
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
        local ref_name = func.cppfunc:gsub("^[Ss]et", ""):gsub("^[Gg]et", "")
        table.insert(arg.attr.addref, 1, string.lower(ref_name))
    end

    olua.assert(not func.is_static or func.ret.type.luacls or arg.attr.addref[3])

    local ref_name = assert(arg.attr.addref[1], func.cppfunc .. " no addref name")
    local ref_mode = assert(arg.attr.addref[2], func.cppfunc .. " no addref flag")
    local ref_store = arg.attr.addref[3] or (func.is_static and "-1" or "1")

    if ref_store:find("^::") then
        if not codeset.has_ref_store then
            codeset.has_ref_store = true
            codeset.insert_before:pushf([[
                int ref_store = ${cls.cppcls}${ref_store}(L);
            ]])
        end
        ref_store = "ref_store"
    end

    if arg.type.cppcls == "void" then
        olua.assert(func.ret == arg)
        olua.assert(not func.is_static, "no addref object")
        olua.assert(arg.attr.addref[3], "must supply where to addref object")
        idx = 1
    elseif arg.type.subtypes then
        olua.assert(ref_mode == "|", "expect use like: @addref(ref_name |)")
        if #arg.type.subtypes == 1 then
            local subtype = arg.type.subtypes[1]
            olua.assert(olua.is_pointer_type(subtype), "'${subtype.cppcls}' not a pointer type")
        else
            olua.assert(#arg.type.subtypes == 2)
            olua.assert(olua.is_pointer_type(arg.type.subtypes[1])
                or olua.is_pointer_type(arg.type.subtypes[2]))
        end
    else
        olua.assert(olua.is_pointer_type(arg.type), "'${arg.type.cppcls}' not a pointer type")
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
                    ${func_push}<${subtype.cppcls}>(L, &${name}, [L](${subtype.cppcls}value) {
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
        elseif arg.type.cppcls:find("<") then
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
        local ref_name = func.cppfunc:gsub("^[Ss]et", ""):gsub("^[Gg]et", "")
        table.insert(arg.attr.delref, 1, string.lower(ref_name))
    end

    olua.assert(not func.is_static or arg.type.luacls or arg.attr.delref[3])

    local ref_name = assert(arg.attr.delref[1], func.cppfunc .. " no ref name")
    local ref_mode = assert(arg.attr.delref[2], func.cppfunc .. " no delref flag")
    local ref_store = arg.attr.delref[3] or (func.is_static and "-1" or "1")

    if ref_store:find("^::") then
        if not codeset.has_ref_store then
            codeset.has_ref_store = true
            codeset.insert_before:pushf([[
                int ref_store = ${cls.cppcls}${ref_store}(L);
            ]])
        end
        ref_store = "ref_store"
    end

    if ref_mode == "|" or ref_mode == "^" then
        if arg.type.cppcls == "void" then
            olua.assert(not func.is_static, "no delref object")
            olua.assert(arg.attr.delref[3], "must supply where to delref object")
            idx = 1
        else
            olua.assert(olua.is_pointer_type(arg.type), "'${arg.type.cppcls}' not a pointer type")
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
        -- first argument is cpp userdata object
        codeset.idx = codeset.idx + 1
        local ti = olua.typeinfo(cls.cppcls)
        local func_to = olua.conv_func(ti, "to")
        codeset.decl_args:pushf("${cls.cppcls} *self = nullptr;")
        codeset.check_args:pushf('${func_to}(L, 1, &self, "${ti.luacls}");')
    end

    local skip_first_arg = false

    if olua.is_oluaret(func) then
        local arg = func.args[1]
        olua.assert(arg and arg.type.cppcls == "lua_State", "first arg type must be 'lua_State *'")
        codeset.caller_args:push("L")
        skip_first_arg = true
    end

    for i, arg in ipairs(func.args) do
        if skip_first_arg then
            skip_first_arg = false
            goto continue
        end

        local name = "arg" .. i
        local idx = codeset.idx + 1
        codeset.idx = idx

        if olua.has_cast_flag(arg.type) then
            codeset.caller_args:pushf("*${name}")
        else
            codeset.caller_args:pushf("${name}")
        end

        olua.gen_decl_exp(arg, name, codeset)
        olua.gen_check_exp(arg, name, idx, codeset)
        olua.gen_addref_exp(cls, func, arg, idx, name, codeset)
        olua.gen_delref_exp(cls, func, arg, idx, name, codeset)

        ::continue::
    end

    if func.is_variadic then
        codeset.caller_args:push("nullptr")
    end
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param codeset idl.gen.func_codeset
local function gen_func_ret(cls, func, codeset)
    if func.ret.type.cppcls ~= "void" then
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
    local caller = func.is_static and (cls.cppcls .. "::") or "self->"
    local cppfunc = func.cppfunc
    local args_begin = not func.is_variable and "(" or (func.ret.type.cppcls ~= "void" and "" or " = ")
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
            class = ${cls.cppcls}
            func = ${func.funcdesc}
    ]])

    if func.body then
        gen_func_body(cls, func, write)
        return
    end

    local extend = func.ret.attr.extend
    if extend then
        caller = extend[1] .. "::"
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

    if func.is_contructor then
        caller = "new " .. cls.cppcls
        codeset.post_new = "olua_postnew(L, ret);"
    else
        caller = caller .. cppfunc
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

    if func.cppfunc == "as" then
        local asexp = olua.array("\n")
        for _, ascls in ipairs(func.ret.attr.as) do
            local asti = olua.typeinfo(ascls .. "*")
            local asluacls = asti.luacls:match("^[^< ]+")
            asexp:pushf([[
                if (olua_strequal(arg1, "${asluacls}")) {
                    olua_pushobj_as<${ascls}>(L, 1, self, "as.${asluacls}");
                    break;
                }
            ]])
        end
        write(olua.format([[
            static int _${cls.cppcls#}_${func.cppfunc}${fidx}(lua_State *L)
            {
                olua_startinvoke(L);

                ${codeset.decl_args}

                ${codeset.check_args}

                do {
                    if (olua_isa(L, 1, arg1)) {
                        lua_pushvalue(L, 1);
                        break;
                    }
                    ${asexp}

                    luaL_error(L, "'${cls.cppcls}' can't cast to '%s'", arg1);
                } while (0);

                olua_endinvoke(L);

                return 1;
            }
        ]]))
    else
        write(olua.format([[
            static int _${cls.cppcls#}_${func.cppfunc}${fidx}(lua_State *L)
            {
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
            }
        ]]))
    end
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
    return count
end

---@param funcs idl.gen.func_desc[]
---@param num_args integer
---@return idl.gen.func_desc[]
local function get_func_with_num_args(funcs, num_args)
    local arr = {}
    for _, func in ipairs(funcs) do
        local n = olua.is_oluaret(func) and (num_args + 1) or num_args
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
    ---@type {max_vars: integer, exp1: string, exp2: string?}
    local callblock = {}
    for _, fi in ipairs(fns) do
        if #fi.args > 0 then
            local test_exps = olua.array(" && ")
            local max_vars = 1
            local argn = (fi.is_static and 0 or 1)
            for i, ai in ipairs(fi.args) do
                if olua.is_oluaret(fi) and i == 1 then
                    goto continue
                end

                local func_is = olua.conv_func(ai.type, ai.attr.pack and "canpack" or "is")
                local test_nil = ""

                argn = argn + 1

                max_vars = math.max(ai.type.packvars or 1, max_vars)

                if ai.attr.nullable then
                    test_nil = " " .. olua.format("|| olua_isnil(L, ${argn})")
                end

                if olua.is_pointer_type(ai.type) or olua.is_func_type(ai.type) then
                    if ai.attr.pack then
                        test_exps:pushf([[
                            (${func_is}(L, ${argn}, (${ai.type.cppcls} *)nullptr)${test_nil})
                        ]])
                    else
                        test_exps:pushf([[
                            (${func_is}(L, ${argn}, "${ai.type.luacls}")${test_nil})
                        ]])
                    end
                else
                    test_exps:pushf([[
                        (${func_is}(L, ${argn})${test_nil})
                    ]])
                end

                if ai.attr.pack then
                    argn = argn + ai.type.packvars - 1
                end

                ::continue::
            end

            callblock[#callblock + 1] = {
                max_vars = max_vars,
                exp1 = olua.format([[
                    // if (${test_exps}) {
                        // ${fi.funcdesc}
                        return _${cls.cppcls#}_${fi.cppfunc}$${fi.index}(L);
                    // }
                ]]),
                exp2 = olua.format([[
                    if (${test_exps}) {
                        // ${fi.funcdesc}
                        return _${cls.cppcls#}_${fi.cppfunc}$${fi.index}(L);
                    }
                ]]),
            }
        else
            if #fns > 1 then
                for _, v in ipairs(fns) do
                    olua.print("same func ${cls.cppcls}::${v.cppfunc}")
                end
            end
            assert(#fns == 1, fi.cppfunc)
            callblock[#callblock + 1] = {
                max_vars = 1,
                exp1 = olua.format([[
                    // ${fi.funcdesc}
                    return _${cls.cppcls#}_${fi.cppfunc}$${fi.index}(L);
                ]])
            }
        end
    end

    table.sort(callblock, function (a, b)
        return a.max_vars > b.max_vars
    end)

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
    local cppfunc = funcs[1].cppfunc
    local subone = funcs[1].is_static and "" or " - 1"
    local ifblock = olua.array("\n\n")

    local max_args = 0

    for i, fi in ipairs(funcs) do
        max_args = math.max(max_args, get_num_args(fi))
        gen_one_func(cls, fi, write, "$" .. fi.index)
        write("")
    end

    for i = 0, max_args do
        local arr = get_func_with_num_args(funcs, i)
        if #arr > 0 then
            local test_and_call = gen_test_and_call(cls, arr)
            ifblock:pushf([[
                if (num_args == ${i}) {
                    ${test_and_call}
                }
            ]])
        end
    end

    write(olua.format([[
        static int _${cls.cppcls#}_${cppfunc}(lua_State *L)
        {
            int num_args = lua_gettop(L)${subone};

            ${ifblock}

            luaL_error(L, "method '${cls.cppcls}::${cppfunc}' not support '%d' arguments", num_args);

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
---@param idx integer
---@param name string
---@param codeset idl.gen.func_codeset
function olua.gen_class_fill(cls, idx, name, codeset)
    local vars = olua.ordered_map()

    ---@param c idl.gen.class_desc
    local function copy_var(c)
        if c.supercls then
            copy_var(olua.get_class(c.supercls))
        end
        for _, v in ipairs(c.vars) do
            vars:replace(v.name, {
                name = v.name,
                varname = v.get.varname,
                attr = v.get.ret.attr,
                type = v.get.ret.type,
            })
        end
    end
    copy_var(cls)
    for i, var in ipairs(vars) do
        local argname = "arg" .. i
        olua.gen_decl_exp(var, argname, codeset)
        codeset.check_args:pushf([[olua_getfield(L, ${idx}, "${var.varname}");]])
        if var.attr.optional then
            local subset = { check_args = olua.array("\n") }
            olua.gen_check_exp(var, argname, -1, subset)
            codeset.check_args:pushf([[
                if (!olua_isnoneornil(L, -1)) {
                    ${subset.check_args}
                    ${name}.${var.varname} = ${argname};
                }
                lua_pop(L, 1);
            ]])
        else
            olua.gen_check_exp(var, argname, -1, codeset)
            codeset.check_args:pushf([[
                ${name}.${var.varname} = ${argname};
                lua_pop(L, 1);
            ]])
        end
        codeset.check_args:push("")
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
        olua.gen_decl_exp(pi, name, codeset)
        olua.gen_check_exp(pi, name, "idx + " .. (i - 1), codeset)
        codeset.check_args:pushf([[
            value->${var.set.cppfunc} = ${name};
        ]])
        codeset.check_args:push("")
    end

    write(olua.format([[
        OLUA_LIB void olua_pack_object(lua_State *L, int idx, ${cls.cppcls} *value)
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
        local name = olua.format("value->${var.set.cppfunc}")
        olua.gen_push_exp(pi, name, codeset)
    end

    write(olua.format([[
        OLUA_LIB int olua_unpack_object(lua_State *L, const ${cls.cppcls} *value)
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
        OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const ${cls.cppcls} *)
        {
            return ${exps};
        }
    ]]))
end

---@param module idl.gen.module_desc
---@param write idl.gen.writer
function olua.gen_pack_header(module, write)
    for _, cls in ipairs(module.class_types) do
        ---@cast cls idl.gen.class_desc
        if cls.options.packable and not cls.options.packvars then
            write(cls.macro)
            write(olua.format([[
                // ${cls.cppcls}
                OLUA_LIB void olua_pack_object(lua_State *L, int idx, ${cls.cppcls} *value);
                OLUA_LIB int olua_unpack_object(lua_State *L, const ${cls.cppcls} *value);
                OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const ${cls.cppcls} *);
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
        ---@cast cls idl.gen.class_desc
        if cls.options.packable and not cls.options.packvars then
            write(cls.macro)
            cls.vars:sort(function (_, _, a, b)
                return a.index < b.index
            end)
            gen_pack_func(cls, write)
            gen_unpack_func(cls, write)
            gen_canpack_func(cls, write)
            write(cls.macro and "#endif" or nil)
            write("")
        end
    end
end
