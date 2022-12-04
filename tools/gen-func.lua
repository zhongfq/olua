local olua = require "olua"

local format = olua.format

local function gen_func_snippet(cls, fi, write)
    local snippet = fi.snippet
    snippet = string.gsub(snippet, '^[\n ]*{', '{\n    olua_startinvoke(L);\n')
    snippet = string.gsub(snippet, '(\n)([ ]*)(return )', function (lf, indent, ret)
        return format([[
            ${lf}

            ${indent}olua_endinvoke(L);

            ${indent}${ret}
        ]]), nil
    end)
    write(format([[
        static int _${cls.cppcls#}_${fi.cppfunc}(lua_State *L)
        ${snippet}
    ]]))
end

function olua.gen_decl_exp(arg, argname, codeset)
    local decltype = olua.decltype(arg.type, true, true)
    local initial_value = olua.initial_value(arg.type)
    local varname = arg.varname or argname
    codeset.decl_args:pushf([[
        ${decltype}${argname}${initial_value};       /** ${varname} */
    ]])
end

function olua.gen_check_exp(arg, name, i, codeset)
    -- lua value to cpp value
    local argn = i
    local argname = name
    local func_check = olua.conv_func(arg.type, arg.attr.pack and 'pack' or 'check')
    local check_args = codeset.check_args
    codeset.check_args = olua.newarray()
    if arg.attr.pack then
        olua.assert(arg.type.packable, [[
            '${arg.type.cppcls}' is not a packable type
            you should do one of:
                * remove '@pack' or '@unpack'
                * typeconf '${arg.type.cppcls}'
                      .packable 'true'
        ]])
        codeset.check_args:pushf([[
            ${func_check}(L, ${argn}, &${argname});
        ]])
    elseif olua.is_pointer_type(arg.type)
        or olua.is_func_type(arg.type)
        or arg.type.smartptr
    then
        codeset.check_args:pushf([[
            ${func_check}(L, ${argn}, &${argname}, "${arg.type.luacls}");
        ]])
    elseif arg.type.subtypes then
        olua.assert(#arg.type.subtypes <= 2, 'unsupport template arg types > 2 ')
        local subtype_decl_args = olua.newarray(', ')
        local subtype_template_args = olua.newarray(', ')
        local subtype_check_exp = olua.newarray()
        local idx = -1
        for ii, subtype in ipairs(arg.type.subtypes) do
            local subtype_func_check = olua.conv_func(subtype, 'check')
            local subtype_name = 'arg' .. ii
            local decltype = olua.decltype(subtype)
            local declarg = olua.decltype(subtype, nil, true)
            subtype_decl_args:pushf('${declarg}*${subtype_name}')
            subtype_template_args:pushf('${decltype}')
            if subtype.smartptr or olua.is_pointer_type(subtype) then
                subtype_check_exp:pushf([[
                    ${subtype_func_check}(L, ${idx}, ${subtype_name}, "${subtype.luacls}");
                ]])
            else
                subtype_check_exp:pushf([[
                    ${subtype_func_check}(L, ${idx}, ${subtype_name});
                ]])
            end
            idx = idx - 1
        end
        codeset.check_args:pushf([[
            ${func_check}<${subtype_template_args}>(L, ${argn}, ${argname}, [L](${subtype_decl_args}) {
                ${subtype_check_exp}
            });
        ]])
    else
        codeset.check_args:pushf('${func_check}(L, ${argn}, &${argname});')
    end

    if arg.attr.nullable then
        check_args:pushf([[
            if (!olua_isnoneornil(L, ${argn})) {
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

function olua.gen_push_exp(arg, name, codeset)
    local argname = name
    local func_push = olua.conv_func(arg.type, arg.attr.unpack and 'unpack' or 'push')
    local func_copy = olua.conv_func(arg.type, 'pushcopy')

    if arg.attr.unpack then
        olua.assert(arg.type.packable, [[
            '${arg.type.cppcls}' is not a packable type
            you should do one of:
                * remove '@pack' or '@unpack'
                * typeconf '${arg.type.cppcls}'
                      .packable 'true'
        ]])
        codeset.push_args:pushf('${func_push}(L, &${argname});')
    elseif olua.is_pointer_type(arg.type) or olua.is_func_type(arg.type) then
        if olua.has_cast_flag(arg.type)
            or arg.type.smartptr
            or olua.is_func_type(arg.type)
        then
            codeset.push_args:pushf('${func_push}(L, &${argname}, "${arg.type.luacls}");')
        elseif olua.has_pointee_flag(arg.type) then
            codeset.push_args:pushf('${func_push}(L, ${argname}, "${arg.type.luacls}");')
        else
            codeset.push_args:pushf('${func_copy}(L, ${argname}, "${arg.type.luacls}");')
        end
    elseif arg.type.subtypes then
        olua.assert(#arg.type.subtypes <= 2, 'unsupport template arg types > 2 ')
        local subtype_decl_args = olua.newarray(', ')
        local subtype_template_args = olua.newarray(', ')
        local subtype_push_exp = olua.newarray()
        for i, subtype in ipairs(arg.type.subtypes) do
            local subtype_func_push = olua.conv_func(subtype, 'push')
            local subtype_func_copy = olua.conv_func(subtype, 'pushcopy')
            local subtype_name = 'arg' .. i
            local decltype = olua.decltype(subtype)
            local declarg = olua.decltype(subtype, nil, true)
            subtype_template_args:pushf('${decltype}')
            if subtype.smartptr then
                subtype_decl_args:pushf('${declarg}&${subtype_name}')
                subtype_push_exp:pushf('${subtype_func_push}(L, &${subtype_name}, "${subtype.luacls}");')
            elseif subtype.luacls and olua.is_pointer_type(decltype) then
                subtype_decl_args:pushf('${declarg}${subtype_name}')
                subtype_push_exp:pushf('${subtype_func_push}(L, ${subtype_name}, "${subtype.luacls}");')
            elseif olua.is_pointer_type(subtype) then
                subtype_decl_args:pushf('${declarg}&${subtype_name}')
                subtype_push_exp:pushf('${subtype_func_copy}(L, ${subtype_name}, "${subtype.luacls}");')
            else
                local subtype_cast = olua.is_pointer_type(decltype) and '' or '&'
                subtype_decl_args:pushf('${declarg}${subtype_cast}${subtype_name}')
                subtype_push_exp:pushf('${subtype_func_push}(L, ${subtype_name});')
            end
        end
        codeset.push_args:pushf([[
            ${func_push}<${subtype_template_args}>(L, ${argname}, [L](${subtype_decl_args}) {
                ${subtype_push_exp}
            });
        ]])
    else
        codeset.push_args:pushf('${func_push}(L, ${argname});')
    end
end

function olua.gen_addref_exp(cls, fi, arg, i, name, codeset)
    if not arg.attr.addref then
        return
    end

    olua.assert(#arg.attr.addref > 0, 'no ref args')

    -- ^|*~
    if arg.attr.addref[1]:find('[%^%|%*%~]') then
        local ref_name = fi.cppfunc:gsub('^[Ss]et', ''):gsub('^[Gg]et', '')
        table.insert(arg.attr.addref, 1, string.lower(ref_name))
    end

    olua.assert(not fi.static or fi.ret.type.luacls or arg.attr.addref[3])

    local argn = i
    local argname = name
    local ref_name = assert(arg.attr.addref[1], fi.cppfunc .. ' no addref name')
    local ref_mode = assert(arg.attr.addref[2], fi.cppfunc .. ' no addref flag')
    local ref_store = arg.attr.addref[3] or (fi.static and '-1' or '1')

    if ref_store:find('^::') then
        if not codeset.has_ref_store then
            codeset.has_ref_store = true
            codeset.insert_before:pushf([[
                int ref_store = ${cls.cppcls}${ref_store}(L);
            ]])
        end
        ref_store = 'ref_store'
    end

    if arg.type.cppcls == 'void' then
        olua.assert(fi.ret == arg)
        olua.assert(not fi.static, 'no addref object')
        olua.assert(arg.attr.addref[3], 'must supply where to addref object')
        argn = 1
    elseif arg.type.subtypes then
        olua.assert(ref_mode == '|', "expect use like: @addref(ref_name |)")
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

    if ref_mode == '|' then
        if arg.type.subtypes then
            if arg.attr.pack then
                local subtype = arg.type.subtypes[1]
                local func_push = olua.conv_func(arg.type, 'push')
                local subtype_func_push = olua.conv_func(subtype, 'push')
                local ref_store2 = ref_store == 'ref_store' and 'ref_store2' or 'ref_store'
                codeset.insert_after:pushf([[
                    int ${ref_store2} = lua_absindex(L, ${ref_store});
                    ${func_push}<${subtype.cppcls}>(L, &${argname}, [L](${subtype.cppcls}value) {
                        ${subtype_func_push}(L, value, "${subtype.luacls}");
                    });
                    olua_addref(L, ${ref_store2}, "${ref_name}", -1, OLUA_FLAG_MULTIPLE | OLUA_FLAG_TABLE);
                    lua_pop(L, 1);
                ]])
            else
                if fi.variable then
                    codeset.insert_after:pushf('olua_delallrefs(L, ${ref_store}, "${ref_name}");')
                end
                codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_FLAG_MULTIPLE | OLUA_FLAG_TABLE);')
            end
        elseif arg.type.cppcls:find('<') then
            codeset.insert_after:pushf([[
                for (auto obj : *${argname}) {
                    olua_pushobj(L, obj);
                    olua_addref(L, 1, "${ref_name}", -1, OLUA_FLAG_MULTIPLE);
                    lua_pop(L, 1);
                }
            ]])
        else
            codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_FLAG_MULTIPLE);')
        end
    elseif ref_mode == "^" then
        codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_FLAG_SINGLE);')
    else
        error('no support addref flag: ' .. ref_mode)
    end
end

function olua.gen_delref_exp(cls, fi, arg, i, name, codeset)
    if not arg.attr.delref then
        return
    end

    olua.assert(#arg.attr.delref > 0, 'no ref args')

    -- ^|*~
    if arg.attr.delref[1]:find('[%^%|%*%~]') then
        local ref_name = fi.cppfunc:gsub('^[Ss]et', ''):gsub('^[Gg]et', '')
        table.insert(arg.attr.delref, 1, string.lower(ref_name))
    end

    olua.assert(not fi.static or arg.type.luacls or arg.attr.delref[3])

    local argn = i
    local argname = name
    local ref_name = assert(arg.attr.delref[1], fi.cppfunc .. ' no ref name')
    local ref_mode = assert(arg.attr.delref[2], fi.cppfunc .. ' no delref flag')
    local ref_store = arg.attr.delref[3] or (fi.static and '-1' or '1')

    if ref_store:find('^::') then
        if not codeset.has_ref_store then
            codeset.has_ref_store = true
            codeset.insert_before:pushf([[
                int ref_store = ${cls.cppcls}${ref_store}(L);
            ]])
        end
        ref_store = 'ref_store'
    end

    if ref_mode == '|' or ref_mode == '^' then
        if arg.type.cppcls  == 'void' then
            olua.assert(not fi.static, 'no delref object')
            olua.assert(arg.attr.delref[3], 'must supply where to delref object')
            argn = 1
        else
            olua.assert(olua.is_pointer_type(arg.type), "'${arg.type.cppcls}' not a pointer type")
        end
    end

    if ref_mode == '~' then
        codeset.insert_before:pushf('olua_startcmpref(L, ${ref_store}, "${ref_name}");')
        codeset.insert_after:pushf('olua_endcmpref(L, ${ref_store}, "${ref_name}");')
    elseif ref_mode == '*' then
        codeset.insert_after:pushf('olua_delallrefs(L, ${ref_store}, "${ref_name}");')
    elseif ref_mode == '|' then
        if arg.type.subtypes then
            codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_FLAG_MULTIPLE | OLUA_FLAG_TABLE);')
        else
            codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_FLAG_MULTIPLE);')
        end
    elseif ref_mode == "^" then
        codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_FLAG_SINGLE);')
    else
        error('no support delref flag: ' .. ref_mode)
    end

end

local function gen_func_args(cls, fi, codeset)
    if not fi.static then
        -- first argument is cpp userdata object
        codeset.idx = codeset.idx + 1
        local ti = olua.typeinfo(cls.cppcls)
        local func_to = olua.conv_func(ti, 'to')
        codeset.decl_args:pushf('${cls.cppcls} *self = nullptr;')
        codeset.check_args:pushf('${func_to}(L, 1, &self, "${ti.luacls}");')
    end

    local skip_first_arg = false

    if olua.is_oluaret(fi) then
        local ai = fi.args[1]
        olua.assert(ai and ai.type.cppcls == 'lua_State', "first arg type must be 'lua_State *'")
        codeset.caller_args:pushf('L')
        skip_first_arg = true
    end

    for i, ai in ipairs(fi.args) do
        if skip_first_arg then
            skip_first_arg = false
            goto continue
        end

        local argname = "arg" .. i
        local argn = codeset.idx + 1
        codeset.idx = argn

        if olua.is_func_type(ai.type) then
            olua.assert(fi.callback, 'no callback option')
        end

        if olua.has_cast_flag(ai.type) then
            codeset.caller_args:pushf('*${argname}')
        else
            codeset.caller_args:pushf('${argname}')
        end

        olua.gen_decl_exp(ai, argname, codeset)
        olua.gen_check_exp(ai, argname, argn, codeset)
        olua.gen_addref_exp(cls, fi, ai, argn, argname, codeset)
        olua.gen_delref_exp(cls, fi, ai, argn, argname, codeset)

        ::continue::
    end

    if fi.ret.attr.variadic then
        codeset.caller_args:pushf('nullptr')
    end
end

local function gen_func_ret(cls, fi, codeset)
    if fi.ret.type.cppcls ~= 'void' then
        local decltype = olua.decltype(fi.ret.type, nil, true)
        if olua.has_cast_flag(fi.ret.type) then
            decltype = decltype:gsub(' %*$', ' &')
        end
        if fi.variable
            and not olua.has_pointee_flag(fi.ret.type)
            and not olua.is_value_type(fi.ret.type)
        then
            codeset.decl_ret = format('${decltype}&ret = ', nil, true)
        else
            codeset.decl_ret = format('${decltype}ret = ', nil, true)
        end

        local retblock = {push_args = olua.newarray()}

        if olua.is_oluaret(fi) then
            codeset.num_ret = "(int)ret"
        else
            olua.gen_push_exp(fi.ret, 'ret', retblock)
            codeset.push_ret = format('int num_ret = ${retblock.push_args}')
        end

        if #codeset.push_ret > 0 then
            codeset.num_ret = "num_ret"
        end
    end

    olua.gen_addref_exp(cls, fi, fi.ret, -1, 'ret', codeset)
    olua.gen_delref_exp(cls, fi, fi.ret, -1, 'ret', codeset)
end

local function gen_one_func(cls, fi, write, funcidx)
    local caller = fi.static and (cls.cppcls .. '::') or 'self->'
    local cppfunc = not fi.variable and fi.cppfunc or fi.varname
    local args_begin = not fi.variable and '(' or (fi.ret.type.cppcls ~= 'void' and '' or ' = ')
    local args_end = not fi.variable and ')' or ''
    local cb_arg, cb_argn
    funcidx = funcidx or ''

    local codeset = {
        idx = 0,
        decl_args = olua.newarray(),
        check_args = olua.newarray(),
        caller_args = olua.newarray(', '),
        insert_after = olua.newarray():push(fi.insert.after),
        insert_before = olua.newarray():push(fi.insert.before),
        has_ref_store = false,
        push_ret = "",
        decl_ret = "",
        num_ret = "0",
        post_new = "",
        callback = "",
        push_stub = "",
        remove_function_callback = "",
    }

    olua.willdo([[
        gen one func:
            class = ${cls.cppcls}
            func = ${fi.funcdesc}
    ]])

    if fi.snippet then
        gen_func_snippet(cls, fi, write)
        return
    end

    local extend = fi.ret.attr.extend
    if extend then
        caller = extend[1] .. '::'
    end

    if fi.ret.attr.postnew then
        codeset.insert_after:push('olua_postnew(L, ret);')
    end

    gen_func_args(cls, fi, codeset)
    gen_func_ret(cls, fi, codeset)

    for i, arg in ipairs(fi.args) do
        if arg.callback then
            olua.assert(not cb_arg, 'not support multi callback')
            cb_arg = arg
            cb_argn = i
        end
    end

    if fi.callback then
        olua.gen_callback(cls, fi, cb_arg, cb_argn, codeset)
    end

    if #codeset.insert_before > 0 then
        table.insert(codeset.insert_before, 1, '// insert code before call')
    end

    if #codeset.insert_after > 0 then
        table.insert(codeset.insert_after, 1, '// insert code after call')
    end

    if fi.ctor then
        caller = 'new ' .. cls.cppcls
        codeset.post_new = 'olua_postnew(L, ret);'
    else
        caller = caller .. cppfunc
    end

    if #codeset.push_stub > 0 then
        codeset.num_ret = 1
        codeset.push_ret = format [[
            ${codeset.push_stub};
        ]]
        if not fi.ctor then
            codeset.post_new = ''
        end
    end

    if fi.cppfunc == 'as' then
        local asexp = olua.newarray()
        for _, ascls in ipairs(fi.ret.attr.as) do
            local asti = olua.typeinfo(ascls .. '*')
            local asluacls = asti.luacls:match('^[^< ]+')
            asexp:pushf([[
                if (olua_strequal(arg1, "${asluacls}")) {
                    olua_pushobj_as<${ascls}>(L, 1, self, "as.${asluacls}");
                    break;
                }
            ]])
        end
        write(format([[
            static int _${cls.cppcls#}_${fi.cppfunc}${funcidx}(lua_State *L)
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
        write(format([[
            static int _${cls.cppcls#}_${fi.cppfunc}${funcidx}(lua_State *L)
            {
                olua_startinvoke(L);

                ${codeset.decl_args}

                ${codeset.check_args}

                ${codeset.insert_before}

                ${codeset.callback}

                // ${fi.funcdesc}
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

local function get_func_with_num_args(cls, funcs, num_args)
    local arr = {}
    for _, fi in ipairs(funcs) do
        local n = olua.is_oluaret(fi) and (num_args + 1) or num_args
        if fi.max_args == n then
            arr[#arr + 1] = fi
        end
    end
    return arr
end

local function gen_test_and_call(cls, fns)
    local callblock = {}
    for _, fi in ipairs(fns) do
        if #fi.args > 0 then
            local test_exps = {}
            local max_vars = 1
            local argn = (fi.static and 0 or 1)
            for i, ai in ipairs(fi.args) do
                if olua.is_oluaret(fi) and i == 1 then
                    goto continue
                end

                local func_is = olua.conv_func(ai.type, ai.attr.pack and 'canpack' or 'is')
                local test_nil = ""

                argn = argn + 1

                max_vars = math.max(ai.type.packvars or 1, max_vars)

                if ai.attr.nullable then
                    test_nil = ' ' .. format('|| olua_isnil(L, ${argn})')
                end

                if olua.is_pointer_type(ai.type) or olua.is_func_type(ai.type) then
                    if ai.attr.pack then
                        test_exps[#test_exps + 1] = format([[
                            (${func_is}(L, ${argn}, (${ai.type.cppcls} *)nullptr)${test_nil})
                        ]])
                    else
                        test_exps[#test_exps + 1] = format([[
                            (${func_is}(L, ${argn}, "${ai.type.luacls}")${test_nil})
                        ]])
                    end
                else
                    test_exps[#test_exps + 1] = format([[
                        (${func_is}(L, ${argn})${test_nil})
                    ]])
                end

                if ai.attr.pack then
                    argn = argn + ai.type.packvars - 1
                end

                ::continue::
            end

            test_exps = table.concat(test_exps, " && ")
            callblock[#callblock + 1] = {
                max_vars = max_vars,
                exp1 = format([[
                    // if (${test_exps}) {
                        // ${fi.funcdesc}
                        return _${cls.cppcls#}_${fi.cppfunc}$${fi.index}(L);
                    // }
                ]]),
                exp2 = format([[
                    if (${test_exps}) {
                        // ${fi.funcdesc}
                        return _${cls.cppcls#}_${fi.cppfunc}$${fi.index}(L);
                    }
                ]]),
            }
        else
            if #fns > 1 then
                for _, v in ipairs(fns) do
                    print("same func", v, v.cppfunc)
                end
            end
            assert(#fns == 1, fi.cppfunc)
            callblock[#callblock + 1] = {
                max_vars = 1,
                exp1 = format([[
                    // ${fi.funcdesc}
                    return _${cls.cppcls#}_${fi.cppfunc}$${fi.index}(L);
                ]])
            }
        end
    end

    table.sort(callblock, function (a, b)
        return a.max_vars > b.max_vars
    end)

    for i, v in ipairs(callblock) do
        callblock[i] = i == #callblock and v.exp1 or v.exp2
    end

    return table.concat(callblock, "\n\n")
end

local function gen_multi_func(cls, funcs, write)
    local cppfunc = funcs[1].cppfunc
    local subone = funcs[1].static and "" or " - 1"
    local ifblock = olua.newarray('\n\n')

    for i, fi in ipairs(funcs) do
        gen_one_func(cls, fi, write, '$' .. fi.index)
        write('')
    end

    for i = 0, funcs.max_args do
        local arr = get_func_with_num_args(cls, funcs, i)
        if #arr > 0 then
            local test_and_call = gen_test_and_call(cls, arr)
            ifblock:pushf([[
                if (num_args == ${i}) {
                    ${test_and_call}
                }
            ]])
        end
    end

    write(format([[
        static int _${cls.cppcls#}_${cppfunc}(lua_State *L)
        {
            int num_args = lua_gettop(L)${subone};

            ${ifblock}

            luaL_error(L, "method '${cls.cppcls}::${cppfunc}' not support '%d' arguments", num_args);

            return 0;
        }
    ]]))
end

function olua.gen_class_func(cls, funcs, write)
    if #funcs == 1 then
        gen_one_func(cls, funcs[1], write)
    else
        gen_multi_func(cls, funcs, write)
    end
end

function olua.gen_class_fill(cls, idx, name, codeset)
    local vars = olua.newhash()
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
        local argname = 'arg' .. i
        olua.gen_decl_exp(var, argname, codeset)
        codeset.check_args:pushf([[olua_getfield(L, ${idx}, "${var.varname}");]])
        if var.attr.optional then
            local subset = {check_args = olua.newarray()}
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
        codeset.check_args:push('')
    end

end

-- packable object
local function gen_pack_func(cls, write)
    local codeset = {
        decl_args = olua.newarray(),
        check_args = olua.newarray(),
    }
    for i, var in ipairs(cls.vars) do
        local pi = var.set.args[1]
        local argname = 'arg' .. i
        olua.gen_decl_exp(pi, argname, codeset)
        olua.gen_check_exp(pi, argname, 'idx + ' ..  (i - 1), codeset)
        codeset.check_args:pushf([[
            value->${pi.varname} = ${argname};
        ]])
        codeset.check_args:push('')
    end

    write(format([[
        OLUA_LIB void olua_pack_object(lua_State *L, int idx, ${cls.cppcls} *value)
        {
            idx = lua_absindex(L, idx);

            ${codeset.decl_args}

            ${codeset.check_args}
        }
    ]]))
    write('')
end

local function gen_unpack_func(cls, write)
    local num_args = #cls.vars
    local codeset = {push_args = olua.newarray():push('')}
    for _, var in ipairs(cls.vars) do
        local pi = var.set.args[1]
        local argname = format('value->${pi.varname}')
        olua.gen_push_exp(pi, argname, codeset)
    end

    write(format([[
        OLUA_LIB int olua_unpack_object(lua_State *L, const ${cls.cppcls} *value)
        {
            ${codeset.push_args}

            return ${num_args};
        }
    ]]))
    write('')
end

local function gen_canpack_func(cls, write)
    local exps = olua.newarray(' && ')
    for i, var in ipairs(cls.vars) do
        local pi = var.set.args[1]
        local func_is = olua.conv_func(pi.type, 'is')
        local N = i - 1
        if olua.is_pointer_type(pi.type) then
            exps:pushf('${func_is}(L, idx + ${N}, "${pi.type.luacls}")')
        else
            exps:pushf('${func_is}(L, idx + ${N})')
        end
    end
    write(format([[
        OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const ${cls.cppcls} *)
        {
            return ${exps};
        }
    ]]))
end

function olua.gen_pack_header(module, write)
    for _, cls in ipairs(module.class_types) do
        if cls.options.packable and not cls.options.packvars then
            local macro = cls.macros['*']
            write(macro)
            write(format([[
                // ${cls.cppcls}
                OLUA_LIB void olua_pack_object(lua_State *L, int idx, ${cls.cppcls} *value);
                OLUA_LIB int olua_unpack_object(lua_State *L, const ${cls.cppcls} *value);
                OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const ${cls.cppcls} *);
            ]]))
            write(macro and '#endif' or nil)
            write("")
        end
    end
end

function olua.gen_pack_source(module, write)
    for _, cls in ipairs(module.class_types) do
        if cls.options.packable and not cls.options.packvars then
            local macro = cls.macros['*']
            write(macro)
            gen_pack_func(cls, write)
            gen_unpack_func(cls, write)
            gen_canpack_func(cls, write)
            write(macro and '#endif' or nil)
            write('')
        end
    end
end