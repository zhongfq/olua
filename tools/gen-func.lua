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
        static int _${{cls.cppcls}}_${fi.cppfunc}(lua_State *L)
        ${snippet}
    ]]))
end

function olua.gen_decl_exp(arg, name, codeset)
    local type_space = olua.typespace(arg.type.decltype)
    local argname = name
    local varname = ""
    if arg.varname then
        varname = format([[/** ${arg.varname} */]])
    end
    if arg.type.subtypes then
        -- arg.decltype = std::vector<std::string>
        -- arg.type.decltype = std::vector
        codeset.decl_args:pushf('${arg.decltype}${type_space}${argname};       ${varname}')
    else
        local decltype = arg.type.decltype
        if arg.attr.ret then
            -- (..., @ret ssize_t *size) (.... @ret ssize_t &value)
            -- arg.type.decltype = lua_Integer
            -- arg.type.cppcls = ssize_t
            decltype = arg.type.cppcls
        end
        local initial_value = olua.initial_value(arg.type)
        if #initial_value > 0 then
            if decltype ~= arg.type.decltype then
                initial_value = ' ' .. format('= (${decltype})${initial_value}')
            else
                initial_value = ' = ' .. initial_value
            end
        end
        codeset.decl_args:pushf([[
            ${decltype}${type_space}${argname}${initial_value};       ${varname}
        ]])
    end
end

function olua.gen_check_exp(arg, name, i, codeset)
    -- lua value to cpp value
    local argn = i
    local argname = name
    local func_check = olua.conv_func(arg.type, arg.attr.pack and 'pack' or 'check')
    if arg.attr.ret then
        local attr_ret = arg.attr.ret
        local check_args = codeset.check_args
        arg.attr.ret = nil
        codeset.check_args = olua.newarray()
        if not arg.type.subtypes and arg.type.decltype ~= arg.type.cppcls then
            codeset.check_args:pushf([[${arg.type.decltype} value;]])
            olua.gen_check_exp(arg, 'value', i, codeset)
            codeset.check_args:pushf([[${argname} = (${arg.type.cppcls})value;]])
        else
            olua.gen_check_exp(arg, name, i, codeset)
        end

        check_args:pushf([[
            //'${argname}' with mark '@ret'
            if (!olua_isnoneornil(L, ${argn})) {
                ${codeset.check_args}
            }
        ]])
        codeset.check_args = check_args
        arg.attr.ret = attr_ret
        return
    elseif olua.is_pointer_type(arg.type) then
        if arg.attr.nullable then
            codeset.check_args:pushf([[
                if (!olua_isnoneornil(L, ${argn})) {
                    ${func_check}(L, ${argn}, (void **)&${argname}, "${arg.type.luacls}");
                }
            ]])
        else
            codeset.check_args:pushf([[
                ${func_check}(L, ${argn}, (void **)&${argname}, "${arg.type.luacls}");
            ]])
        end
    elseif arg.type.subtypes then
        if #arg.type.subtypes == 1 then
            local subtype = arg.type.subtypes[1]
            local type_space = olua.typespace(subtype.decltype)
            local subtype_func_check = olua.conv_func(subtype, 'check')
            if olua.is_pointer_type(subtype) then
                codeset.check_args:pushf([[
                    ${func_check}<${subtype.cppcls}>(L, ${argn}, &${argname}, [L](${subtype.cppcls}*value) {
                        ${subtype_func_check}(L, -1, (void **)value, "${subtype.luacls}");
                    });
                ]])
            else
                if subtype.cppcls == subtype.decltype then
                    codeset.check_args:pushf([[
                        ${func_check}<${subtype.cppcls}>(L, ${argn}, &${argname}, [L](${subtype.cppcls} *value) {
                            ${subtype_func_check}(L, -1, value);
                        });
                    ]])
                else
                    codeset.check_args:pushf([[
                        ${func_check}<${subtype.cppcls}>(L, ${argn}, &${argname}, [L](${subtype.cppcls} *value) {
                            ${subtype.decltype}${type_space}obj;
                            ${subtype_func_check}(L, -1, &obj);
                            *value = (${subtype.cppcls})obj;
                        });
                    ]])
                end
            end
        else
            olua.assert(#arg.type.subtypes == 2)
            local subtype_decl_args = olua.newarray(', ')
            local subtype_template_args = olua.newarray(', ')
            local subtype_check_exp = olua.newarray()
            local idx = -1
            for ii, subtype in ipairs(arg.type.subtypes) do
                local subtype_func_check = olua.conv_func(subtype, 'check')
                local type_space = olua.typespace(subtype.decltype)
                local subtype_name = 'arg' .. ii
                local const = subtype.const and 'const ' or ''
                if olua.is_pointer_type(subtype) then
                    subtype_decl_args:pushf('${const}${subtype.cppcls}*${subtype_name}')
                    subtype_template_args:pushf('${const}${subtype.cppcls}')
                    subtype_check_exp:pushf([[
                        ${subtype_func_check}(L, ${idx}, (void **)${subtype_name}, "${subtype.luacls}");
                    ]])
                else
                    subtype_decl_args:pushf('${const}${subtype.cppcls} *${subtype_name}')
                    subtype_template_args:pushf('${const}${subtype.cppcls}')
                    if subtype.cppcls == subtype.decltype then
                        subtype_check_exp:pushf([[
                            ${subtype_func_check}(L, ${idx}, ${subtype_name});
                        ]])
                    else
                        subtype_check_exp:pushf([[
                            ${subtype.decltype}${type_space}${subtype_name}obj;
                            ${subtype_func_check}(L, ${idx}, &${subtype_name}obj);
                            *${subtype_name} = (${subtype.cppcls})${subtype_name}obj;
                        ]])
                    end
                end
                idx = idx - 1
            end
            codeset.check_args:pushf([[
                ${func_check}<${subtype_template_args}>(L, ${argn}, &${argname}, [L](${subtype_decl_args}) {
                    ${subtype_check_exp}
                });
            ]])
        end
    else
        codeset.check_args:pushf('${func_check}(L, ${argn}, &${argname});')
    end

    if arg.attr.pack and arg.type.num_vars then
        codeset.idx = codeset.idx + arg.type.num_vars - 1
    end
end

function olua.gen_addref_exp(fi, arg, i, name, codeset)
    if not arg.attr.addref then
        return
    end

    olua.assert(not fi.static or fi.ret.type.luacls or arg.attr.addref[3])

    local argn = i
    local argname = name
    local ref_name = assert(arg.attr.addref[1], fi.cppfunc .. ' no addref name')
    local ref_mode = assert(arg.attr.addref[2], fi.cppfunc .. ' no addref flag')
    local ref_store = arg.attr.addref[3] or (fi.static and -1 or 1)

    if arg.type.cppcls == 'void' then
        olua.assert(fi.ret == arg)
        olua.assert(not fi.static, 'no addref object')
        olua.assert(arg.attr.addref[3], 'must supply where to addref object')
        argn = 1
    elseif arg.type.subtypes then
        olua.assert(ref_mode == '|', "expect use like: @addref(ref_name |)")
        if #arg.type.subtypes == 1 then
            local subtype = arg.type.subtypes[1]
            olua.assert(olua.is_pointer_type(subtype), "'%s' not a pointer type", subtype.cppcls)
        else
            olua.assert(#arg.type.subtypes == 2)
            olua.assert(olua.is_pointer_type(arg.type.subtypes[1])
                or olua.is_pointer_type(arg.type.subtypes[2]))
        end
    else
        olua.assert(olua.is_pointer_type(arg.type), "'%s' not a pointer type", arg.type.cppcls)
    end

    if ref_mode == '|' then
        if arg.type.subtypes then
            if arg.attr.pack or arg.attr.ret then
                local subtype = arg.type.subtypes[1]
                local func_push = olua.conv_func(arg.type, 'push')
                local subtype_func_push = olua.conv_func(subtype, 'push')
                codeset.insert_after:pushf([[
                    int ref_store = lua_absindex(L, ${ref_store});
                    ${func_push}<${subtype.cppcls}>(L, &${argname}, [L](${subtype.cppcls}value) {
                        ${subtype_func_push}(L, value, "${subtype.luacls}");
                    });
                    olua_addref(L, ref_store, "${ref_name}", -1, OLUA_MODE_MULTIPLE | OLUA_FLAG_TABLE);
                    lua_pop(L, 1);
                ]])
            else
                if fi.variable then
                    codeset.insert_after:pushf('olua_delallrefs(L, ${ref_store}, "${ref_name}");')
                end
                codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_MODE_MULTIPLE | OLUA_FLAG_TABLE);')
            end
        else
            codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_MODE_MULTIPLE);')
        end
    elseif ref_mode == "^" then
        codeset.insert_after:pushf('olua_addref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_MODE_SINGLE);')
    else
        error('no support addref flag: ' .. ref_mode)
    end

end

function olua.gen_delref_exp(fi, arg, i, name, codeset)
    if not arg.attr.delref then
        return
    end

    olua.assert(not fi.static or arg.type.luacls or arg.attr.delref[3])

    local argn = i
    local argname = name
    local ref_name = assert(arg.attr.delref[1], fi.cppfunc .. ' no ref name')
    local ref_mode = assert(arg.attr.delref[2], fi.cppfunc .. ' no delref flag')
    local ref_store = arg.attr.delref[3] or (fi.static and -1 or 1)

    if ref_mode == '|' or ref_mode == '^' then
        if arg.type.cppcls  == 'void' then
            olua.assert(not fi.static, 'no delref object')
            olua.assert(arg.attr.delref[3], 'must supply where to delref object')
            argn = 1
        else
            olua.assert(olua.is_pointer_type(arg.type), "'%s' not a pointer type", arg.type.cppcls)
        end
    end

    if ref_mode == '~' then
        codeset.insert_before:pushf('olua_startcmpref(L, ${ref_store}, "${ref_name}");')
        codeset.insert_after:pushf('olua_endcmpref(L, ${ref_store}, "${ref_name}");')
    elseif ref_mode == '*' then
        codeset.insert_after:pushf('olua_delallrefs(L, ${ref_store}, "${ref_name}");')
    elseif ref_mode == '|' then
        if arg.type.subtypes then
            codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_MODE_MULTIPLE | OLUA_FLAG_TABLE);')
        else
            codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_MODE_MULTIPLE);')
        end
    elseif ref_mode == "^" then
        codeset.insert_after:pushf('olua_delref(L, ${ref_store}, "${ref_name}", ${argn}, OLUA_MODE_SINGLE);')
    else
        error('no support delref flag: ' .. ref_mode)
    end

end

local function gen_func_args(cls, fi, codeset)
    if not fi.static then
        -- first argument is cpp userdata object
        codeset.idx = codeset.idx + 1
        local ti = olua.typeinfo(cls.cppcls .. "*")
        local func_to = olua.conv_func(ti, 'to')
        codeset.decl_args:pushf('${cls.cppcls} *self = nullptr;')
        codeset.check_args:pushf('${func_to}(L, 1, (void **)&self, "${ti.luacls}");')
    end

    for i, ai in ipairs(fi.args) do
        local argname = "arg" .. i
        local argn = codeset.idx + 1
        codeset.idx = argn

        if olua.is_func_type(ai.type) then
            olua.assert(fi.callback, 'no callback option')
        end

        -- function call args
        -- see 'basictype.lua'
        if ai.attr.ret then
            local type_cast = ai.attr.ret == 'pointee' and '&' or ''
            codeset.caller_args:pushf('${type_cast}${argname}')
        elseif ai.type.decltype ~= ai.type.cppcls and not ai.callback then
            codeset.caller_args:pushf('(${ai.type.cppcls})${argname}')
        elseif ai.type.variant then
            -- void f(T), has 'T *' conv: T *arg => f(*arg)
            -- void f(T *) has T conv: T arg => f(&arg)
            local type_cast = olua.is_pointer_type(ai.type) and '*' or '&'
            codeset.caller_args:pushf('${type_cast}${argname}')
        else
            codeset.caller_args:pushf('${argname}')
        end

        olua.gen_decl_exp(ai, argname, codeset)
        olua.gen_check_exp(ai, argname, argn, codeset)
        olua.gen_addref_exp(fi, ai, argn, argname, codeset)
        olua.gen_delref_exp(fi, ai, argn, argname, codeset)
    end
end

function olua.gen_push_exp(arg, name, codeset)
    local argname = name
    local func_push = olua.conv_func(arg.type, arg.attr.unpack and 'unpack' or 'push')
    if olua.is_pointer_type(arg.type) then
        local type_cast = arg.type.variant and '&' or ''
        codeset.push_args:pushf('${func_push}(L, ${type_cast}${argname}, "${arg.type.luacls}");')
    elseif arg.type.subtypes then
        if #arg.type.subtypes == 1 then
            local subtype = arg.type.subtypes[1]
            local subtype_func_push = olua.conv_func(subtype, 'push')
            local subtype_cast = olua.is_value_type(subtype) and format('(${subtype.decltype})') or '&'
            if olua.is_pointer_type(subtype) then
                codeset.push_args:pushf([[
                    ${func_push}<${subtype.cppcls}>(L, &${argname}, [L](${subtype.cppcls}value) {
                        ${subtype_func_push}(L, value, "${subtype.luacls}");
                    });
                ]])
            else
                codeset.push_args:pushf([[
                    ${func_push}<${subtype.cppcls}>(L, &${argname}, [L](${subtype.cppcls} value) {
                        ${subtype_func_push}(L, ${subtype_cast}value);
                    });
                ]])
            end
        else
            olua.assert(#arg.type.subtypes == 2)
            local subtype_decl_args = olua.newarray(', ')
            local subtype_template_args = olua.newarray(', ')
            local subtype_push_exp = olua.newarray()
            for i, subtype in ipairs(arg.type.subtypes) do
                local subtype_func_push = olua.conv_func(subtype, 'push')
                local subtype_cast = olua.is_value_type(subtype) and format('(${subtype.decltype})') or '&'
                local subtype_name = 'arg' .. i
                local const = subtype.const and 'const ' or ''
                if olua.is_pointer_type(subtype) then
                    subtype_decl_args:pushf('${const}${subtype.cppcls}${subtype_name}')
                    subtype_template_args:pushf('${const}${subtype.cppcls}')
                    subtype_push_exp:pushf('${subtype_func_push}(L, ${subtype_name}, "${subtype.luacls}");')
                else
                    subtype_decl_args:pushf('${const}${subtype.cppcls} ${subtype_name}')
                    subtype_template_args:pushf('${const}${subtype.cppcls}')
                    subtype_push_exp:pushf('${subtype_func_push}(L, ${subtype_cast}${subtype_name});')
                end
            end
            codeset.push_args:pushf([[
                ${func_push}<${subtype_template_args}>(L, &${argname}, [L](${subtype_decl_args}) {
                    ${subtype_push_exp}
                });
            ]])
        end
    else
        local type_cast = ""
        if not olua.is_value_type(arg.type) then
            -- push func: olua_push_value(L, T *)
            -- T *f(), has T conv
            type_cast = not arg.type.variant and '&' or ''
        elseif arg.type.decltype ~= arg.type.cppcls then
            -- int => lua_Interge
            type_cast = format('(${arg.type.decltype})')
        end
        codeset.push_args:pushf('${func_push}(L, ${type_cast}${argname});')
    end
end

local function gen_func_ret(cls, fi, codeset)
    if fi.ret.type.cppcls ~= 'void' then
        local type_space = olua.typespace(fi.ret.decltype)
        if fi.ret.type.variant and type_space == ' ' then
            codeset.decl_ret = format('${fi.ret.decltype} &ret = (${fi.ret.decltype} &)')
        else
            olua.assert(fi.ret.decltype:find(fi.ret.type.cppcls))
            codeset.decl_ret = format('${fi.ret.decltype}${type_space}ret = ') .. ' '
        end

        local retblock = {push_args = olua.newarray()}

        olua.gen_push_exp(fi.ret, 'ret', retblock)
        codeset.push_ret = format('int num_ret = ${retblock.push_args}')

        if #codeset.push_ret > 0 then
            codeset.num_ret = "num_ret"
        end
    end

    olua.gen_addref_exp(fi, fi.ret, -1, 'ret', codeset)
    olua.gen_delref_exp(fi, fi.ret, -1, 'ret', codeset)
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
        push_ret = "",
        decl_ret = "",
        num_ret = "0",
        post_new = "",
        callback = "",
        push_stub = "",
        remove_function_callback = "",
    }

    olua.message(cls.cppcls .. ': ' .. fi.funcdesc)

    if fi.snippet then
        gen_func_snippet(cls, fi, write)
        return
    end

    gen_func_args(cls, fi, codeset)
    gen_func_ret(cls, fi, codeset)

    for i, arg in ipairs(fi.args) do
        if arg.attr.ret then
            local ret = {push_args = olua.newarray()}
            olua.gen_push_exp(arg, 'arg' .. i, ret)
            codeset.push_ret = format([[
                ${codeset.push_ret}
                ${ret.push_args}
            ]])
            codeset.num_ret = format([[${codeset.num_ret} + 1]])
        end
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

    write(format([[
        static int _${{cls.cppcls}}_${fi.cppfunc}${funcidx}(lua_State *L)
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

local function get_func_nargs(cls, fis, n)
    local arr = {}
    for _, v in ipairs(fis) do
        if v.max_args == n then
            arr[#arr + 1] = v
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
                local func_is = olua.conv_func(ai.type, ai.attr.pack and 'canpack' or 'is')
                local test_nil = ""

                argn = argn + 1

                max_vars = math.max(ai.type.num_vars or 1, max_vars)

                if ai.attr.nullable then
                    test_nil = ' ' .. format('|| olua_isnil(L, ${argn})')
                end

                if olua.is_pointer_type(ai.type) then
                    test_exps[#test_exps + 1] = format([[
                        (${func_is}(L, ${argn}, "${ai.type.luacls}")${test_nil})
                    ]])
                else
                    test_exps[#test_exps + 1] = format([[
                        (${func_is}(L, ${argn})${test_nil})
                    ]])
                end

                if ai.attr.pack and ai.type.num_vars then
                    argn = argn + ai.type.num_vars - 1
                end
            end

            test_exps = table.concat(test_exps, " && ")
            callblock[#callblock + 1] = {
                max_vars = max_vars,
                exp1 = format([[
                    // if (${test_exps}) {
                        // ${fi.funcdesc}
                        return _${{cls.cppcls}}_${fi.cppfunc}${fi.index}(L);
                    // }
                ]]),
                exp2 = format([[
                    if (${test_exps}) {
                        // ${fi.funcdesc}
                        return _${{cls.cppcls}}_${fi.cppfunc}${fi.index}(L);
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
                    return _${{cls.cppcls}}_${fi.cppfunc}${fi.index}(L);
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

local function gen_multi_func(cls, fis, write)
    local cppfunc = fis[1].cppfunc
    local subone = fis[1].static and "" or " - 1"
    local ifblock = olua.newarray('\n\n')

    local pack_fi

    for i, fi in ipairs(fis) do
        gen_one_func(cls, fi, write, fi.index)
        write('')
        for _, arg in ipairs(fi.args) do
            if arg.attr.pack and not arg.type.num_vars then
                pack_fi = fi
                break
            end
        end
    end

    for i = 0, fis.max_args do
        local fns = get_func_nargs(cls, fis, i)
        if #fns > 0 then
            local test_and_call = gen_test_and_call(cls, fns)
            ifblock:pushf([[
                if (num_args == ${i}) {
                    ${test_and_call}
                }
            ]])
        end
    end

    if pack_fi then
        ifblock:pushf([[
            if (num_args > 0) {
                // ${pack_fi.funcdesc}
                return _${{cls.cppcls}}_${pack_fi.cppfunc}${pack_fi.index}(L);
            }
        ]])
    end

    write(format([[
        static int _${{cls.cppcls}}_${cppfunc}(lua_State *L)
        {
            int num_args = lua_gettop(L)${subone};

            ${ifblock}

            luaL_error(L, "method '${cls.cppcls}::${cppfunc}' not support '%d' arguments", num_args);

            return 0;
        }
    ]]))
end

function olua.gen_class_func(cls, fis, write)
    if #fis == 1 then
        gen_one_func(cls, fis[1], write)
    else
        gen_multi_func(cls, fis, write)
    end
end
