local olua = require "olua"

local format = olua.format

local function gen_func_snippet(cls, fi, write)
    local CPPCLS_PATH = olua.topath(cls.CPPCLS)
    local SNIPPET = fi.SNIPPET
    SNIPPET = string.gsub(SNIPPET, '^[\n ]*{', '{\n    olua_startinvoke(L);\n')
    SNIPPET = string.gsub(SNIPPET, '(\n)([ ]*)(return )', function (lf, indent, ret)
        local s = format([[
            ${lf}

            ${indent}olua_endinvoke(L);

            ${indent}${ret}
        ]])
        return s
    end)
    write(format([[
        static int _${CPPCLS_PATH}_${fi.CPPFUNC}(lua_State *L)
        ${SNIPPET}
    ]]))
    write('')
end

function olua.gen_decl_exp(arg, name, out)
    local SPACE = string.find(arg.TYPE.DECLTYPE, '[ *&]$') and '' or ' '
    local ARG_NAME = name
    local VARNAME = ""
    if arg.VARNAME then
        VARNAME = format([[/** ${arg.VARNAME} */]])
    end
    if arg.TYPE.SUBTYPES then
        -- arg.DECLTYPE = std::vector<std::string>
        -- arg.TYPE.DECLTYPE = std::vector
        out.DECL_ARGS:pushf('${arg.DECLTYPE}${SPACE}${ARG_NAME};       ${VARNAME}')
    else
        local DECLTYPE = arg.TYPE.DECLTYPE
        if arg.ATTR.OUT == 'pointee' then
            -- (..., @out ssize_t *size)
            -- arg.TYPE.DECLTYPE = lua_Integer
            -- arg.TYPE.CPPCLS = ssize_t
            DECLTYPE = arg.TYPE.CPPCLS
        end
        local INIT_VALUE = olua.initialvalue(arg.TYPE)
        if #INIT_VALUE > 0 then
            if DECLTYPE ~= arg.TYPE.DECLTYPE then
                INIT_VALUE = ' ' .. format('= (${DECLTYPE})${INIT_VALUE}')
            else
                INIT_VALUE = ' = ' .. INIT_VALUE
            end
        end
        out.DECL_ARGS:pushf([[
            ${DECLTYPE}${SPACE}${ARG_NAME}${INIT_VALUE};       ${VARNAME}
        ]])
    end
end

function olua.gen_check_exp(arg, name, i, out)
    -- lua value to cpp value
    local ARGN = i
    local ARG_NAME = name
    local CHECK_FUNC = olua.convfunc(arg.TYPE, 'check')
    if arg.ATTR.OUT then
        out.CHECK_ARGS:pushf([[// no need to check '${ARG_NAME}' with mark '@out']])
        return
    elseif olua.ispointee(arg.TYPE) then
        out.CHECK_ARGS:pushf([[
            ${CHECK_FUNC}(L, ${ARGN}, (void **)&${ARG_NAME}, "${arg.TYPE.LUACLS}");
        ]])
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES > 1 then
            out.CHECK_ARGS:push(arg.TYPE.CHECK_VALUE(arg, name, i))
        else
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            if olua.ispointee(SUBTYPE) then
                out.CHECK_ARGS:pushf([[
                    ${CHECK_FUNC}(L, ${ARGN}, ${ARG_NAME}, "${SUBTYPE.LUACLS}");
                ]])
            else
                local SUBTYPE_CHECK_FUNC = olua.convfunc(SUBTYPE, 'check')
                local SUBTYPE_CAST = olua.typecast(SUBTYPE, true)
                local CHECK_VALUE = format(arg.TYPE.CHECK_VALUE)
                out.CHECK_ARGS:pushf([[
                    luaL_checktype(L, ${ARGN}, LUA_TTABLE);
                    ${CHECK_VALUE}
                ]])
            end
        end
    elseif not arg.CALLBACK or not arg.CALLBACK.ARGS then
        if arg.ATTR.PACK then
            CHECK_FUNC = olua.convfunc(arg.TYPE, 'pack')
            out.TOTAL_ARGS = arg.TYPE.NUMVARS + out.TOTAL_ARGS - 1
            out.IDX = out.IDX + arg.TYPE.NUMVARS - 1
        end
        out.CHECK_ARGS:pushf('${CHECK_FUNC}(L, ${ARGN}, &${ARG_NAME});')
    end
end

function olua.gen_addref_exp(fi, arg, i, out)
    if not arg.ATTR.ADDREF then
        return
    end

    olua.assert(not fi.STATIC or fi.RET.TYPE.LUACLS)

    local ARGN = i
    local REFNAME = assert(arg.ATTR.ADDREF[1], fi.CPPFUNC .. ' no addref name')
    local ADDREF = assert(arg.ATTR.ADDREF[2], fi.CPPFUNC .. ' no addref flag')
    local WHERE = arg.ATTR.ADDREF[3] or (fi.STATIC and -1 or 1)

    if arg.TYPE.CPPCLS == 'void' then
        olua.assert(fi.RET == arg)
        olua.assert(not fi.STATIC, 'no addref object')
        olua.assert(arg.ATTR.ADDREF[3], 'must supply where to addref object')
        if arg.ATTR.ADDREF[3] then
            ARGN = 1
        end
    elseif arg.TYPE.SUBTYPES then
        local SUBTYPE = arg.TYPE.SUBTYPES[1]
        olua.assert(ADDREF == '|', "expect use like: @addref(refname |)")
        olua.assert(olua.ispointee(SUBTYPE), "'%s' not a pointer type", SUBTYPE.CPPCLS)
    else
        olua.assert(olua.ispointee(arg.TYPE), "'%s' not a pointer type", arg.TYPE.CPPCLS)
    end

    if ADDREF == '|' then
        if arg.TYPE.SUBTYPES then
            out.INJECT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_MULTIPLE | OLUA_FLAG_ARRAY);')
        else
            out.INJECT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
        end
    elseif ADDREF == "^" then
        out.INJECT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_SINGLE);')
    else
        error('no support addref flag: ' .. ADDREF)
    end

end

function olua.gen_delref_exp(fi, arg, i, out)
    if not arg.ATTR.DELREF then
        return
    end

    olua.assert(not fi.STATIC or arg.TYPE.LUACLS)

    local ARGN = i
    local REFNAME = assert(arg.ATTR.DELREF[1], fi.CPPFUNC .. ' no ref name')
    local DELREF = assert(arg.ATTR.DELREF[2], fi.CPPFUNC .. ' no delref flag')
    local WHERE = arg.ATTR.DELREF[3] or (fi.STATIC and -1 or 1)

    if DELREF == '|' or DELREF == '^' then
        if arg.TYPE.CPPCLS  == 'void' then
            olua.assert(not fi.STATIC, 'no delref object')
            olua.assert(arg.ATTR.DELREF[3], 'must supply where to delref object')
            ARGN = 1
        else
            olua.assert(olua.ispointee(arg.TYPE), "'%s' not a pointer type", arg.TYPE.CPPCLS)
        end
    end

    if DELREF == '~' then
        out.INJECT_BEFORE:pushf('olua_startcmpdelref(L, ${WHERE}, "${REFNAME}");')
        out.INJECT_AFTER:pushf('olua_endcmpdelref(L, ${WHERE}, "${REFNAME}");')
    elseif DELREF == '*' then
        out.INJECT_AFTER:pushf('olua_delallrefs(L, ${WHERE}, "${REFNAME}");')
    elseif DELREF == '|' then
        out.INJECT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
    elseif DELREF == "^" then
        out.INJECT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_SINGLE);')
    else
        error('no support delref flag: ' .. DELREF)
    end

end

local function gen_func_args(cls, fi, func)
    if not fi.STATIC then
        -- first argument is cpp userdata object
        func.TOTAL_ARGS = func.TOTAL_ARGS + 1
        func.IDX = func.IDX + 1
        local ti = olua.typeinfo(cls.CPPCLS .. "*")
        local OLUA_TO_TYPE = olua.convfunc(ti, 'to')
        func.DECL_ARGS:pushf('${cls.CPPCLS} *self = nullptr;')
        func.CHECK_ARGS:pushf('${OLUA_TO_TYPE}(L, 1, (void **)&self, "${ti.LUACLS}");')
    end

    for i, ai in ipairs(fi.ARGS) do
        local ARG_NAME = "arg" .. i
        local ARGN = func.IDX + 1
        func.IDX = ARGN

        if ai.TYPE.CPPCLS == 'std::function' then
            olua.assert(fi.CALLBACK_OPT, 'no callback option')
        end

        -- function call args
        -- see 'basictype.lua'
        if ai.ATTR.OUT == 'pointee' then
            func.CALLER_ARGS:pushf('&${ARG_NAME}')
        elseif ai.TYPE.DECLTYPE ~= ai.TYPE.CPPCLS and not ai.CALLBACK.ARGS then
            func.CALLER_ARGS:pushf('(${ai.TYPE.CPPCLS})${ARG_NAME}')
        else
            local CAST = ai.TYPE.TYPEREF and '*' or ''
            func.CALLER_ARGS:pushf('${CAST}${ARG_NAME}')
        end

        olua.gen_decl_exp(ai, ARG_NAME, func)
        olua.gen_check_exp(ai, ARG_NAME, ARGN, func)
        olua.gen_addref_exp(fi, ai, ARGN, func)
        olua.gen_delref_exp(fi, ai, ARGN, func)
    end
end

function olua.gen_push_exp(arg, name, out)
    local ARG_NAME = name
    local OLUA_PUSH_VALUE = olua.convfunc(arg.TYPE, 'push')
    if olua.ispointee(arg.TYPE) then
        local CAST = arg.TYPE.TYPEREF and '&' or ''
        out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${CAST}${ARG_NAME}, "${arg.TYPE.LUACLS}");')
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES > 1 then
            out.PUSH_ARGS:push(arg.TYPE.PUSH_VALUE(arg, name))
        else
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            if olua.ispointee(SUBTYPE) then
                out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${ARG_NAME}, "${SUBTYPE.LUACLS}");')
            else
                local SUBTYPE_CAST = olua.pointercast(SUBTYPE) .. olua.typecast(SUBTYPE)
                local SUBTYPE_PUSH_FUNC = olua.convfunc(SUBTYPE, 'push')
                local TYPE_CAST = string.gsub(arg.DECLTYPE, '^const *', '')
                local ARG_NAME_PATH = ARG_NAME:gsub('[%->.]+', '_')
                out.PUSH_ARGS:pushf(arg.TYPE.PUSH_VALUE)
            end
        end
    else
        if arg.ATTR.UNPACK then
            OLUA_PUSH_VALUE = olua.convfunc(arg.TYPE, 'unpack')
        end
        local TYPE_CAST = ""
        if olua.isvaluetype(arg.TYPE) then
            -- value type push func: olua_push_value(L, T)
            if arg.TYPE.DECLTYPE ~= arg.TYPE.CPPCLS then
                -- int => lua_Interge
                TYPE_CAST = format('(${arg.TYPE.DECLTYPE})')
            end
        else
            -- other push func: olua_push_value(L, T *)
            TYPE_CAST = '&'
        end
        out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${TYPE_CAST}${ARG_NAME});')
    end
end

local function gen_func_ret(cls, fi, func)
    if fi.RET.NUM > 0 then
        local SPACE = string.find(fi.RET.DECLTYPE, '[ *&]$') and '' or ' '
        if fi.RET.TYPE.TYPEREF and SPACE == ' ' then
            func.RET_EXP = format('${fi.RET.DECLTYPE} &ret = (${fi.RET.DECLTYPE} &)')
        else
            func.RET_EXP = format('${fi.RET.DECLTYPE}${SPACE}ret = (${fi.RET.DECLTYPE})')
        end

        local RETEXP = {PUSH_ARGS = olua.newarray()}

        olua.gen_push_exp(fi.RET, 'ret', RETEXP)

        if fi.RET.TYPE.SUBTYPES and not olua.ispointee(fi.RET.TYPE.SUBTYPES[1]) then
            func.PUSH_RET = format([[
                int num_ret = 1;
                ${RETEXP.PUSH_ARGS}
            ]])
        elseif fi.RET.TYPE.DECLTYPE == 'const char *' and fi.RET.ATTR.LENGTH then
            local arg = fi.RET.ATTR.LENGTH[1]
            local DECLTYPE = fi.RET.TYPE.DECLTYPE
            func.PUSH_RET = format([[
                int num_ret = 1;
                lua_pushlstring(L, (${DECLTYPE})ret, ${arg});
            ]])
        else
            func.PUSH_RET = format('int num_ret = ${RETEXP.PUSH_ARGS}')
        end

        if #func.PUSH_RET > 0 then
            func.NUM_RET = "num_ret"
        end

    end

    olua.gen_addref_exp(fi, fi.RET, -1, func)
    olua.gen_delref_exp(fi, fi.RET, -1, func)
end

local function gen_one_func(cls, fi, write, funcidx, exported)
    local CPPCLS_PATH = olua.topath(cls.CPPCLS)
    local FUNC_INDEX = funcidx or ''
    local CALLER = fi.STATIC and (cls.CPPCLS .. '::') or 'self->'
    local CPPFUNC = not fi.VARIABLE and fi.CPPFUNC or fi.VARNAME
    local ARGS_BEGIN = not fi.VARIABLE and '(' or (fi.RET.NUM > 0 and '' or ' = ')
    local ARGS_END = not fi.VARIABLE and ')' or ''

    local FUNC = {
        TOTAL_ARGS = #fi.ARGS,
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
        CALLER_ARGS = olua.newarray(', '),
        INJECT_AFTER = olua.newarray():push(fi.INJECT.AFTER),
        INJECT_BEFORE = olua.newarray():push(fi.INJECT.BEFORE),
        PUSH_RET = "",
        RET_EXP = "",
        NUM_RET = "0",
        POST_NEW = "",
        CALLBACK = "",
        PUSH_STUB = "",
        REMOVE_LOCAL_CALLBACK = "",
        IDX = 0,
    }

    olua.message(fi.DECLFUNC)

    local funcname = format([[_${CPPCLS_PATH}_${fi.CPPFUNC}${FUNC_INDEX}]])
    if exported[funcname] then
        return
    end
    exported[funcname] = true

    if fi.SNIPPET then
        gen_func_snippet(cls, fi, write)
        return
    end

    gen_func_args(cls, fi, FUNC)
    gen_func_ret(cls, fi, FUNC)

    for i, ai in ipairs(fi.ARGS) do
        if ai.ATTR.OUT then
            local OUT = {PUSH_ARGS = olua.newarray()}
            olua.gen_push_exp(ai, 'arg' .. i, OUT)
            FUNC.PUSH_RET = format([[
                ${FUNC.PUSH_RET}
                ${OUT.PUSH_ARGS}
            ]])
            FUNC.NUM_RET = format([[${FUNC.NUM_RET} + 1]])
        end
    end

    if fi.CALLBACK_OPT then
        olua.gen_callback(cls, fi, write, FUNC)
        if not FUNC.REMOVE_LOCAL_CALLBACK then
            FUNC.REMOVE_LOCAL_CALLBACK = ''
        end
    end

    if #FUNC.INJECT_BEFORE > 0 then
        table.insert(FUNC.INJECT_BEFORE, 1, '// inject code before call')
    end

    if #FUNC.INJECT_AFTER > 0 then
        table.insert(FUNC.INJECT_AFTER, 1, '// inject code after call')
    end

    if fi.CONSTRUCTOR then
        CALLER = 'new ' .. cls.CPPCLS
        FUNC.POST_NEW = 'olua_postnew(L, ret);'
    else
        CALLER = CALLER .. CPPFUNC
    end

    if #FUNC.PUSH_STUB > 0 then
        FUNC.NUM_RET = 1
        FUNC.PUSH_RET = format [[
            ${FUNC.PUSH_STUB};
        ]]
        if not fi.CONSTRUCTOR then
            FUNC.POST_NEW = ''
        end
    end

    write(format([[
        static int _${CPPCLS_PATH}_${fi.CPPFUNC}${FUNC_INDEX}(lua_State *L)
        {
            olua_startinvoke(L);

            ${FUNC.DECL_ARGS}

            ${FUNC.CHECK_ARGS}

            ${FUNC.INJECT_BEFORE}

            ${FUNC.CALLBACK}

            // ${fi.DECLFUNC}
            ${FUNC.RET_EXP}${CALLER}${ARGS_BEGIN}${FUNC.CALLER_ARGS}${ARGS_END};
            ${FUNC.PUSH_RET}
            ${FUNC.POST_NEW}

            ${FUNC.INJECT_AFTER}

            ${FUNC.REMOVE_LOCAL_CALLBACK}

            olua_endinvoke(L);

            return ${FUNC.NUM_RET};
        }
    ]]))
    write('')
end

local function get_func_nargs(cls, fis, n)
    local arr = {}
    for _, v in ipairs(fis) do
        if v.MAX_ARGS == n then
            arr[#arr + 1] = v
        end
    end
    return arr
end

local function gen_test_and_call(cls, fns)
    local CALL_CHUNK = {}
    for _, fi in ipairs(fns) do
        local CPPCLS_PATH = olua.topath(cls.CPPCLS)
        if #fi.ARGS > 0 then
            local TEST_ARGS = {}
            local MAX_VARS = 1
            for i, ai in ipairs(fi.ARGS) do
                local ARGN = (fi.STATIC and 0 or 1) + i
                local OLUA_IS_VALUE = olua.convfunc(ai.TYPE, 'is')
                local TEST_NULL = ""

                MAX_VARS = math.max(ai.TYPE.NUMVARS or 1, MAX_VARS)

                if ai.ATTR.PACK then
                    OLUA_IS_VALUE = olua.convfunc(ai.TYPE, 'ispack')
                end

                if ai.ATTR.NULLABLE then
                    TEST_NULL = ' ' .. format('|| olua_isnil(L, ${ARGN})')
                end

                if olua.ispointee(ai.TYPE) then
                    TEST_ARGS[#TEST_ARGS + 1] = format([[
                        (${OLUA_IS_VALUE}(L, ${ARGN}, "${ai.TYPE.LUACLS}")${TEST_NULL})
                    ]])
                else
                    TEST_ARGS[#TEST_ARGS + 1] = format([[
                        (${OLUA_IS_VALUE}(L, ${ARGN})${TEST_NULL})
                    ]])
                end
            end

            TEST_ARGS = table.concat(TEST_ARGS, " && ")
            CALL_CHUNK[#CALL_CHUNK + 1] = {
                MAX_VARS = MAX_VARS,
                EXP1 = format([[
                    // if (${TEST_ARGS}) {
                        // ${fi.DECLFUNC}
                        return _${CPPCLS_PATH}_${fi.CPPFUNC}${fi.INDEX}(L);
                    // }
                ]]),
                EXP2 = format([[
                    if (${TEST_ARGS}) {
                        // ${fi.DECLFUNC}
                        return _${CPPCLS_PATH}_${fi.CPPFUNC}${fi.INDEX}(L);
                    }
                ]]),
            }
        else
            if #fns > 1 then
                for _, v in ipairs(fns) do
                    print("same func", v, v.CPPFUNC)
                end
            end
            assert(#fns == 1, fi.CPPFUNC)
            CALL_CHUNK[#CALL_CHUNK + 1] = {
                MAX_VARS = 1,
                EXP1 = format([[
                    // ${fi.DECLFUNC}
                    return _${CPPCLS_PATH}_${fi.CPPFUNC}${fi.INDEX}(L);
                ]])
            }
        end
    end

    table.sort(CALL_CHUNK, function (a, b)
        return a.MAX_VARS > b.MAX_VARS
    end)

    if #CALL_CHUNK > 1 then
        for i, v in ipairs(CALL_CHUNK) do
            CALL_CHUNK[i] = i == #CALL_CHUNK and v.EXP1 or v.EXP2
        end
    else
        CALL_CHUNK[1] = CALL_CHUNK[1].EXP1
    end

    return table.concat(CALL_CHUNK, "\n\n")
end

local function gen_multi_func(cls, fis, write, exported)
    local CPPCLS_PATH = olua.topath(cls.CPPCLS)
    local CPPFUNC = fis[1].CPPFUNC
    local SUBONE = fis[1].STATIC and "" or " - 1"
    local IF_CHUNK = olua.newarray('\n\n')

    for _, fi in ipairs(fis) do
        gen_one_func(cls, fi, write, fi.INDEX, exported)
    end

    local funcname = format([[_${CPPCLS_PATH}_${CPPFUNC}]])
    assert(not exported[funcname], cls.CPPCLS .. ' ' .. CPPFUNC)
    exported[funcname] = true

    for i = 0, fis.MAX_ARGS do
        local fns = get_func_nargs(cls, fis, i)
        if #fns > 0 then
            local TEST_AND_CALL = gen_test_and_call(cls, fns)
            IF_CHUNK:pushf([[
                if (num_args == ${i}) {
                    ${TEST_AND_CALL}
                }
            ]])
        end
    end

    write(format([[
        static int _${CPPCLS_PATH}_${CPPFUNC}(lua_State *L)
        {
            int num_args = lua_gettop(L)${SUBONE};

            ${IF_CHUNK}

            luaL_error(L, "method '${cls.CPPCLS}::${CPPFUNC}' not support '%d' arguments", num_args);

            return 0;
        }
    ]]))
    write('')
end

function olua.gen_class_func(cls, fis, write, exported)
    if #fis == 1 then
        gen_one_func(cls, fis[1], write, nil, exported)
    else
        gen_multi_func(cls, fis, write, exported)
    end
end
