local olua = require "olua"

local format = olua.format

local function gen_func_snippet(cls, fi, write)
    local SNIPPET = fi.SNIPPET
    SNIPPET = string.gsub(SNIPPET, '^[\n ]*{', '{\n    olua_startinvoke(L);\n')
    SNIPPET = string.gsub(SNIPPET, '(\n)([ ]*)(return )', function (lf, indent, ret)
        return format([[
            ${lf}

            ${indent}olua_endinvoke(L);

            ${indent}${ret}
        ]]), nil
    end)
    write(format([[
        static int _${cls.CPP_SYM}_${fi.CPP_FUNC}(lua_State *L)
        ${SNIPPET}
    ]]))
    write('')
end

function olua.gen_decl_exp(arg, name, out)
    local TYPE_SPACE = olua.typespace(arg.TYPE.DECLTYPE)
    local ARG_NAME = name
    local VAR_NAME = ""
    if arg.VAR_NAME then
        VAR_NAME = format([[/** ${arg.VAR_NAME} */]])
    end
    if arg.TYPE.SUBTYPES then
        -- arg.DECLTYPE = std::vector<std::string>
        -- arg.TYPE.DECLTYPE = std::vector
        out.DECL_ARGS:pushf('${arg.DECLTYPE}${TYPE_SPACE}${ARG_NAME};       ${VAR_NAME}')
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
            ${DECLTYPE}${TYPE_SPACE}${ARG_NAME}${INIT_VALUE};       ${VAR_NAME}
        ]])
    end
end

function olua.gen_check_exp(arg, name, i, out)
    -- lua value to cpp value
    local ARGN = i
    local ARG_NAME = name
    local CHECK_FUNC = olua.convfunc(arg.TYPE, arg.ATTR.PACK and 'pack' or 'check')
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
                local SUBTYPE_CAST = format('(${SUBTYPE.CPPCLS})')
                local CHECK_VALUE = format(arg.TYPE.CHECK_VALUE)
                out.CHECK_ARGS:pushf([[
                    luaL_checktype(L, ${ARGN}, LUA_TTABLE);
                    ${CHECK_VALUE}
                ]])
            end
        end
    elseif not arg.CBTYPE then
        if arg.ATTR.PACK then
            out.IDX = out.IDX + arg.TYPE.NUM_VARS - 1
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
    local REF_NAME = assert(arg.ATTR.ADDREF[1], fi.CPP_FUNC .. ' no addref name')
    local ADDREF = assert(arg.ATTR.ADDREF[2], fi.CPP_FUNC .. ' no addref flag')
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
        olua.assert(ADDREF == '|', "expect use like: @addref(ref_name |)")
        olua.assert(olua.ispointee(SUBTYPE), "'%s' not a pointer type", SUBTYPE.CPPCLS)
    else
        olua.assert(olua.ispointee(arg.TYPE), "'%s' not a pointer type", arg.TYPE.CPPCLS)
    end

    if ADDREF == '|' then
        if arg.TYPE.SUBTYPES then
            if arg.ATTR.PACK then
                local SUBTYPE = arg.TYPE.SUBTYPES[1]
                local OLUA_PUSH_FUNC = olua.convfunc(arg.TYPE, 'push')
                out.INSERT_AFTER:pushf([[
                    int ref_store = lua_absindex(L, ${WHERE});
                    ${OLUA_PUSH_FUNC}(L, arg${ARGN}, "${SUBTYPE.LUACLS}");
                    olua_addref(L, ref_store, "${REF_NAME}", -1, OLUA_MODE_MULTIPLE | OLUA_FLAG_ARRAY);
                    lua_pop(L, 1);
                ]])
            else
                out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_MULTIPLE | OLUA_FLAG_ARRAY);')
            end
        else
            out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
        end
    elseif ADDREF == "^" then
        out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_SINGLE);')
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
    local REF_NAME = assert(arg.ATTR.DELREF[1], fi.CPP_FUNC .. ' no ref name')
    local DELREF = assert(arg.ATTR.DELREF[2], fi.CPP_FUNC .. ' no delref flag')
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
        out.INSERT_BEFORE:pushf('olua_startcmpdelref(L, ${WHERE}, "${REF_NAME}");')
        out.INSERT_AFTER:pushf('olua_endcmpdelref(L, ${WHERE}, "${REF_NAME}");')
    elseif DELREF == '*' then
        out.INSERT_AFTER:pushf('olua_delallrefs(L, ${WHERE}, "${REF_NAME}");')
    elseif DELREF == '|' then
        out.INSERT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
    elseif DELREF == "^" then
        out.INSERT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_SINGLE);')
    else
        error('no support delref flag: ' .. DELREF)
    end

end

local function gen_func_args(cls, fi, out)
    if not fi.STATIC then
        -- first argument is cpp userdata object
        out.IDX = out.IDX + 1
        local ti = olua.typeinfo(cls.CPPCLS .. "*")
        local OLUA_TO_TYPE = olua.convfunc(ti, 'to')
        out.DECL_ARGS:pushf('${cls.CPPCLS} *self = nullptr;')
        out.CHECK_ARGS:pushf('${OLUA_TO_TYPE}(L, 1, (void **)&self, "${ti.LUACLS}");')
    end

    for i, ai in ipairs(fi.ARGS) do
        local ARG_NAME = "arg" .. i
        local ARGN = out.IDX + 1
        out.IDX = ARGN

        if ai.TYPE.CPPCLS == 'std::function' then
            olua.assert(fi.CALLBACK, 'no callback option')
        end

        -- function call args
        -- see 'basictype.lua'
        if ai.ATTR.OUT == 'pointee' then
            out.CALLER_ARGS:pushf('&${ARG_NAME}')
        elseif ai.TYPE.DECLTYPE ~= ai.TYPE.CPPCLS and not ai.CBTYPE then
            out.CALLER_ARGS:pushf('(${ai.TYPE.CPPCLS})${ARG_NAME}')
        elseif ai.TYPE.VARIANT then
            -- void f(T), has 'T *' conv: T *arg => f(*arg)
            -- void f(T *) has T conv: T arg => f(&arg)
            local CAST = olua.ispointee(ai.TYPE) and '*' or '&'
            out.CALLER_ARGS:pushf('${CAST}${ARG_NAME}')
        else
            out.CALLER_ARGS:pushf('${ARG_NAME}')
        end

        olua.gen_decl_exp(ai, ARG_NAME, out)
        olua.gen_check_exp(ai, ARG_NAME, ARGN, out)
        olua.gen_addref_exp(fi, ai, ARGN, out)
        olua.gen_delref_exp(fi, ai, ARGN, out)
    end
end

function olua.gen_push_exp(arg, name, out)
    local ARG_NAME = name
    local OLUA_PUSH_VALUE = olua.convfunc(arg.TYPE, arg.ATTR.UNPACK and 'unpack' or 'push')
    if olua.ispointee(arg.TYPE) then
        local CAST = arg.TYPE.VARIANT and '&' or ''
        out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${CAST}${ARG_NAME}, "${arg.TYPE.LUACLS}");')
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES > 1 then
            out.PUSH_ARGS:push(arg.TYPE.PUSH_VALUE(arg, name))
        else
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            if olua.ispointee(SUBTYPE) then
                out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${ARG_NAME}, "${SUBTYPE.LUACLS}");')
            else
                local SUBTYPE_PUSH_FUNC = olua.convfunc(SUBTYPE, 'push')
                local ARG_PREFIX = ARG_NAME:gsub('[%->.]+', '_')
                local SUBTYPE_CAST = olua.isvaluetype(SUBTYPE) and '' or '&'
                if SUBTYPE.DECLTYPE ~= SUBTYPE.CPPCLS then
                    SUBTYPE_CAST = format("${SUBTYPE_CAST}(${SUBTYPE.DECLTYPE})")
                end
                out.PUSH_ARGS:pushf(arg.TYPE.PUSH_VALUE)
            end
        end
    else
        local CAST = ""
        if not olua.isvaluetype(arg.TYPE) then
            -- push func: olua_push_value(L, T *)
            -- T *f(), has T conv
            CAST = not arg.TYPE.VARIANT and '&' or ''
        elseif arg.TYPE.DECLTYPE ~= arg.TYPE.CPPCLS then
            -- value type push func: olua_push_value(L, T)
            -- int => lua_Interge
            CAST = format('(${arg.TYPE.DECLTYPE})')
        end
        out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${CAST}${ARG_NAME});')
    end
end

local function gen_func_ret(cls, fi, out)
    if fi.RET.TYPE.CPPCLS ~= 'void' then
        local TYPE_SPACE = olua.typespace(fi.RET.DECLTYPE)
        if fi.RET.TYPE.VARIANT and TYPE_SPACE == ' ' then
            out.DECL_RET = format('${fi.RET.DECLTYPE} &ret = (${fi.RET.DECLTYPE} &)')
        else
            out.DECL_RET = format('${fi.RET.DECLTYPE}${TYPE_SPACE}ret = (${fi.RET.DECLTYPE})')
        end

        local EXPS = {PUSH_ARGS = olua.newarray()}

        olua.gen_push_exp(fi.RET, 'ret', EXPS)

        if fi.RET.TYPE.SUBTYPES and not olua.ispointee(fi.RET.TYPE.SUBTYPES[1]) then
            out.PUSH_RET = format([[
                int num_ret = 1;
                ${EXPS.PUSH_ARGS}
            ]])
        elseif fi.RET.TYPE.DECLTYPE == 'const char *' and fi.RET.ATTR.LENGTH then
            local arg = fi.RET.ATTR.LENGTH[1]
            local DECLTYPE = fi.RET.TYPE.DECLTYPE
            out.PUSH_RET = format([[
                int num_ret = 1;
                lua_pushlstring(L, (${DECLTYPE})ret, ${arg});
            ]])
        else
            out.PUSH_RET = format('int num_ret = ${EXPS.PUSH_ARGS}')
        end

        if #out.PUSH_RET > 0 then
            out.NUM_RET = "num_ret"
        end
    end

    olua.gen_addref_exp(fi, fi.RET, -1, out)
    olua.gen_delref_exp(fi, fi.RET, -1, out)
end

local function gen_one_func(cls, fi, write, funcidx, exported)
    local FUNC_IDX = funcidx or ''
    local CALLER = fi.STATIC and (cls.CPPCLS .. '::') or 'self->'
    local CPP_FUNC = not fi.VARIABLE and fi.CPP_FUNC or fi.VAR_NAME
    local BEGIN_ARGS = not fi.VARIABLE and '(' or (fi.RET.TYPE.CPPCLS ~= 'void' and '' or ' = ')
    local END_ARGS = not fi.VARIABLE and ')' or ''

    local out = {
        IDX = 0,
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
        CALLER_ARGS = olua.newarray(', '),
        INSERT_AFTER = olua.newarray():push(fi.INSERT.AFTER),
        INSERT_BEFORE = olua.newarray():push(fi.INSERT.BEFORE),
        PUSH_RET = "",
        DECL_RET = "",
        NUM_RET = "0",
        POST_NEW = "",
        CALLBACK = "",
        PUSH_STUB = "",
        REMOVE_LOCAL_CALLBACK = "",
    }

    olua.message(fi.FUNC_DECL)

    local funcname = format([[_${cls.CPP_SYM}_${fi.CPP_FUNC}${FUNC_IDX}]])
    if exported[funcname] then
        return
    end
    exported[funcname] = true

    if fi.SNIPPET then
        gen_func_snippet(cls, fi, write)
        return
    end

    gen_func_args(cls, fi, out)
    gen_func_ret(cls, fi, out)

    for i, ai in ipairs(fi.ARGS) do
        if ai.ATTR.OUT then
            local OUT = {PUSH_ARGS = olua.newarray()}
            olua.gen_push_exp(ai, 'arg' .. i, OUT)
            out.PUSH_RET = format([[
                ${out.PUSH_RET}
                ${OUT.PUSH_ARGS}
            ]])
            out.NUM_RET = format([[${out.NUM_RET} + 1]])
        end
    end

    if fi.CALLBACK then
        olua.gen_callback(cls, fi, out)
        if not out.REMOVE_LOCAL_CALLBACK then
            out.REMOVE_LOCAL_CALLBACK = ''
        end
    end

    if #out.INSERT_BEFORE > 0 then
        table.insert(out.INSERT_BEFORE, 1, '// insert code before call')
    end

    if #out.INSERT_AFTER > 0 then
        table.insert(out.INSERT_AFTER, 1, '// insert code after call')
    end

    if fi.CTOR then
        CALLER = 'new ' .. cls.CPPCLS
        out.POST_NEW = 'olua_postnew(L, ret);'
    else
        CALLER = CALLER .. CPP_FUNC
    end

    if #out.PUSH_STUB > 0 then
        out.NUM_RET = 1
        out.PUSH_RET = format [[
            ${out.PUSH_STUB};
        ]]
        if not fi.CTOR then
            out.POST_NEW = ''
        end
    end

    write(format([[
        static int _${cls.CPP_SYM}_${fi.CPP_FUNC}${FUNC_IDX}(lua_State *L)
        {
            olua_startinvoke(L);

            ${out.DECL_ARGS}

            ${out.CHECK_ARGS}

            ${out.INSERT_BEFORE}

            ${out.CALLBACK}

            // ${fi.FUNC_DECL}
            ${out.DECL_RET}${CALLER}${BEGIN_ARGS}${out.CALLER_ARGS}${END_ARGS};
            ${out.PUSH_RET}
            ${out.POST_NEW}

            ${out.INSERT_AFTER}

            ${out.REMOVE_LOCAL_CALLBACK}

            olua_endinvoke(L);

            return ${out.NUM_RET};
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
        if #fi.ARGS > 0 then
            local TEST_EXPS = {}
            local MAX_VARS = 1
            for i, ai in ipairs(fi.ARGS) do
                local ARGN = (fi.STATIC and 0 or 1) + i
                local OLUA_IS_VALUE = olua.convfunc(ai.TYPE, ai.ATTR.PACK and 'ispack' or 'is')
                local TEST_NULL = ""

                MAX_VARS = math.max(ai.TYPE.NUM_VARS or 1, MAX_VARS)

                if ai.ATTR.NULLABLE then
                    TEST_NULL = ' ' .. format('|| olua_isnil(L, ${ARGN})')
                end

                if olua.ispointee(ai.TYPE) then
                    TEST_EXPS[#TEST_EXPS + 1] = format([[
                        (${OLUA_IS_VALUE}(L, ${ARGN}, "${ai.TYPE.LUACLS}")${TEST_NULL})
                    ]])
                else
                    TEST_EXPS[#TEST_EXPS + 1] = format([[
                        (${OLUA_IS_VALUE}(L, ${ARGN})${TEST_NULL})
                    ]])
                end
            end

            TEST_EXPS = table.concat(TEST_EXPS, " && ")
            CALL_CHUNK[#CALL_CHUNK + 1] = {
                MAX_VARS = MAX_VARS,
                EXP1 = format([[
                    // if (${TEST_EXPS}) {
                        // ${fi.FUNC_DECL}
                        return _${cls.CPP_SYM}_${fi.CPP_FUNC}${fi.INDEX}(L);
                    // }
                ]]),
                EXP2 = format([[
                    if (${TEST_EXPS}) {
                        // ${fi.FUNC_DECL}
                        return _${cls.CPP_SYM}_${fi.CPP_FUNC}${fi.INDEX}(L);
                    }
                ]]),
            }
        else
            if #fns > 1 then
                for _, v in ipairs(fns) do
                    print("same func", v, v.CPP_FUNC)
                end
            end
            assert(#fns == 1, fi.CPP_FUNC)
            CALL_CHUNK[#CALL_CHUNK + 1] = {
                MAX_VARS = 1,
                EXP1 = format([[
                    // ${fi.FUNC_DECL}
                    return _${cls.CPP_SYM}_${fi.CPP_FUNC}${fi.INDEX}(L);
                ]])
            }
        end
    end

    table.sort(CALL_CHUNK, function (a, b)
        return a.MAX_VARS > b.MAX_VARS
    end)

    for i, v in ipairs(CALL_CHUNK) do
        CALL_CHUNK[i] = i == #CALL_CHUNK and v.EXP1 or v.EXP2
    end

    return table.concat(CALL_CHUNK, "\n\n")
end

local function gen_multi_func(cls, fis, write, exported)
    local CPP_FUNC = fis[1].CPP_FUNC
    local SUBONE = fis[1].STATIC and "" or " - 1"
    local IF_CHUNK = olua.newarray('\n\n')

    local pack_fi

    for _, fi in ipairs(fis) do
        gen_one_func(cls, fi, write, fi.INDEX, exported)
        for _, arg in ipairs(fi.ARGS) do
            if arg.ATTR.PACK and not arg.TYPE.NUM_VARS then
                pack_fi = fi
                break
            end
        end
    end

    local funcname = format([[_${cls.CPP_SYM}_${CPP_FUNC}]])
    assert(not exported[funcname], cls.CPPCLS .. ' ' .. CPP_FUNC)
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

    if pack_fi then
        IF_CHUNK:pushf([[
            if (num_args > 0) {
                // ${pack_fi.FUNC_DECL}
                return _${cls.CPP_SYM}_${pack_fi.CPP_FUNC}${pack_fi.INDEX}(L);
            }
        ]])
    end

    write(format([[
        static int _${cls.CPP_SYM}_${CPP_FUNC}(lua_State *L)
        {
            int num_args = lua_gettop(L)${SUBONE};

            ${IF_CHUNK}

            luaL_error(L, "method '${cls.CPPCLS}::${CPP_FUNC}' not support '%d' arguments", num_args);

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
