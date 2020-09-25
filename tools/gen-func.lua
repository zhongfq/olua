local olua = require "olua"

local format = olua.format

local function gen_func_snippet(cls, fi, write)
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
        static int _${cls.CPPNAME}_${fi.CPPFUNC}(lua_State *L)
        ${SNIPPET}
    ]]))
    write('')
end

function olua.gen_decl_exp(arg, name, out)
    local TYPE_SPACE = olua.typespace(arg.TYPE.DECLTYPE)
    local ARGNAME = name
    local VARNAME = ""
    if arg.VARNAME then
        VARNAME = format([[/** ${arg.VARNAME} */]])
    end
    if arg.TYPE.SUBTYPES then
        -- arg.DECLTYPE = std::vector<std::string>
        -- arg.TYPE.DECLTYPE = std::vector
        out.DECL_ARGS:pushf('${arg.DECLTYPE}${TYPE_SPACE}${ARGNAME};       ${VARNAME}')
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
            ${DECLTYPE}${TYPE_SPACE}${ARGNAME}${INIT_VALUE};       ${VARNAME}
        ]])
    end
end

function olua.gen_check_exp(arg, name, i, out)
    -- lua value to cpp value
    local ARGN = i
    local ARGNAME = name
    local CHECK_FUNC = olua.convfunc(arg.TYPE, arg.ATTR.PACK and 'pack' or 'check')
    if arg.ATTR.OUT then
        out.CHECK_ARGS:pushf([[// no need to check '${ARGNAME}' with mark '@out']])
        return
    elseif olua.ispointee(arg.TYPE) then
        out.CHECK_ARGS:pushf([[
            ${CHECK_FUNC}(L, ${ARGN}, (void **)&${ARGNAME}, "${arg.TYPE.LUACLS}");
        ]])
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES > 1 then
            out.CHECK_ARGS:push(arg.TYPE.CHECK_VALUE(arg, name, i))
        else
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            if olua.ispointee(SUBTYPE) then
                out.CHECK_ARGS:pushf([[
                    ${CHECK_FUNC}(L, ${ARGN}, ${ARGNAME}, "${SUBTYPE.LUACLS}");
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
    elseif not arg.CALLBACK or not arg.CALLBACK.ARGS then
        if arg.ATTR.PACK then
            out.TOTAL = arg.TYPE.NUMVARS + out.TOTAL - 1
            out.IDX = out.IDX + arg.TYPE.NUMVARS - 1
        end
        out.CHECK_ARGS:pushf('${CHECK_FUNC}(L, ${ARGN}, &${ARGNAME});')
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
            if arg.ATTR.PACK then
                local SUBTYPE = arg.TYPE.SUBTYPES[1]
                local OLUA_PUSH_FUNC = olua.convfunc(arg.TYPE, 'push')
                out.INSERT_AFTER:pushf([[
                    int ref_store = lua_absindex(L, ${WHERE});
                    ${OLUA_PUSH_FUNC}(L, arg${ARGN}, "${SUBTYPE.LUACLS}");
                    olua_addref(L, ref_store, "${REFNAME}", -1, OLUA_MODE_MULTIPLE | OLUA_FLAG_ARRAY);
                    lua_pop(L, 1);
                ]])
            else
                out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_MULTIPLE | OLUA_FLAG_ARRAY);')
            end
        else
            out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
        end
    elseif ADDREF == "^" then
        out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_SINGLE);')
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
        out.INSERT_BEFORE:pushf('olua_startcmpdelref(L, ${WHERE}, "${REFNAME}");')
        out.INSERT_AFTER:pushf('olua_endcmpdelref(L, ${WHERE}, "${REFNAME}");')
    elseif DELREF == '*' then
        out.INSERT_AFTER:pushf('olua_delallrefs(L, ${WHERE}, "${REFNAME}");')
    elseif DELREF == '|' then
        out.INSERT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
    elseif DELREF == "^" then
        out.INSERT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REFNAME}", ${ARGN}, OLUA_MODE_SINGLE);')
    else
        error('no support delref flag: ' .. DELREF)
    end

end

local function gen_func_args(cls, fi, func)
    if not fi.STATIC then
        -- first argument is cpp userdata object
        func.TOTAL = func.TOTAL + 1
        func.IDX = func.IDX + 1
        local ti = olua.typeinfo(cls.CPPCLS .. "*")
        local OLUA_TO_TYPE = olua.convfunc(ti, 'to')
        func.DECL_ARGS:pushf('${cls.CPPCLS} *self = nullptr;')
        func.CHECK_ARGS:pushf('${OLUA_TO_TYPE}(L, 1, (void **)&self, "${ti.LUACLS}");')
    end

    for i, ai in ipairs(fi.ARGS) do
        local ARGNAME = "arg" .. i
        local ARGN = func.IDX + 1
        func.IDX = ARGN

        if ai.TYPE.CPPCLS == 'std::function' then
            olua.assert(fi.CALLBACK_OPT, 'no callback option')
        end

        -- function call args
        -- see 'basictype.lua'
        if ai.ATTR.OUT == 'pointee' then
            func.CALLER_ARGS:pushf('&${ARGNAME}')
        elseif ai.TYPE.DECLTYPE ~= ai.TYPE.CPPCLS and not ai.CALLBACK.ARGS then
            func.CALLER_ARGS:pushf('(${ai.TYPE.CPPCLS})${ARGNAME}')
        elseif ai.TYPE.VARIANT then
            -- void f(T), has 'T *' conv: T *arg => f(*arg)
            -- void f(T *) has T conv: T arg => f(&arg)
            local CAST = olua.ispointee(ai.TYPE) and '*' or '&'
            func.CALLER_ARGS:pushf('${CAST}${ARGNAME}')
        else
            func.CALLER_ARGS:pushf('${ARGNAME}')
        end

        olua.gen_decl_exp(ai, ARGNAME, func)
        olua.gen_check_exp(ai, ARGNAME, ARGN, func)
        olua.gen_addref_exp(fi, ai, ARGN, func)
        olua.gen_delref_exp(fi, ai, ARGN, func)
    end
end

function olua.gen_push_exp(arg, name, out)
    local ARGNAME = name
    local OLUA_PUSH_VALUE = olua.convfunc(arg.TYPE, 'push')
    if olua.ispointee(arg.TYPE) then
        local CAST = arg.TYPE.VARIANT and '&' or ''
        out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${CAST}${ARGNAME}, "${arg.TYPE.LUACLS}");')
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES > 1 then
            out.PUSH_ARGS:push(arg.TYPE.PUSH_VALUE(arg, name))
        else
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            if olua.ispointee(SUBTYPE) then
                out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${ARGNAME}, "${SUBTYPE.LUACLS}");')
            else
                local SUBTYPE_PUSH_FUNC = olua.convfunc(SUBTYPE, 'push')
                local ARGNAME_PATH = ARGNAME:gsub('[%->.]+', '_')
                local SUBTYPE_CAST = olua.isvaluetype(SUBTYPE) and '' or '&'
                if SUBTYPE.DECLTYPE ~= SUBTYPE.CPPCLS then
                    SUBTYPE_CAST = format("${SUBTYPE_CAST}(${SUBTYPE.DECLTYPE})")
                end
                out.PUSH_ARGS:pushf(arg.TYPE.PUSH_VALUE)
            end
        end
    else
        if arg.ATTR.UNPACK then
            OLUA_PUSH_VALUE = olua.convfunc(arg.TYPE, 'unpack')
        end
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
        out.PUSH_ARGS:pushf('${OLUA_PUSH_VALUE}(L, ${CAST}${ARGNAME});')
    end
end

local function gen_func_ret(cls, fi, func)
    if fi.RET.TYPE.CPPCLS ~= 'void' then
        local TYPE_SPACE = olua.typespace(fi.RET.DECLTYPE)
        if fi.RET.TYPE.VARIANT and TYPE_SPACE == ' ' then
            func.RET_EXP = format('${fi.RET.DECLTYPE} &ret = (${fi.RET.DECLTYPE} &)')
        else
            func.RET_EXP = format('${fi.RET.DECLTYPE}${TYPE_SPACE}ret = (${fi.RET.DECLTYPE})')
        end

        local EXPS = {PUSH_ARGS = olua.newarray()}

        olua.gen_push_exp(fi.RET, 'ret', EXPS)

        if fi.RET.TYPE.SUBTYPES and not olua.ispointee(fi.RET.TYPE.SUBTYPES[1]) then
            func.PUSH_RET = format([[
                int num_ret = 1;
                ${EXPS.PUSH_ARGS}
            ]])
        elseif fi.RET.TYPE.DECLTYPE == 'const char *' and fi.RET.ATTR.LENGTH then
            local arg = fi.RET.ATTR.LENGTH[1]
            local DECLTYPE = fi.RET.TYPE.DECLTYPE
            func.PUSH_RET = format([[
                int num_ret = 1;
                lua_pushlstring(L, (${DECLTYPE})ret, ${arg});
            ]])
        else
            func.PUSH_RET = format('int num_ret = ${EXPS.PUSH_ARGS}')
        end

        if #func.PUSH_RET > 0 then
            func.NUM_RET = "num_ret"
        end
    end

    olua.gen_addref_exp(fi, fi.RET, -1, func)
    olua.gen_delref_exp(fi, fi.RET, -1, func)
end

local function gen_one_func(cls, fi, write, funcidx, exported)
    local FUNC_INDEX = funcidx or ''
    local CALLER = fi.STATIC and (cls.CPPCLS .. '::') or 'self->'
    local CPPFUNC = not fi.VARIABLE and fi.CPPFUNC or fi.VARNAME
    local BEGIN_ARGS = not fi.VARIABLE and '(' or (fi.RET.TYPE.CPPCLS ~= 'void' and '' or ' = ')
    local END_ARGS = not fi.VARIABLE and ')' or ''

    local FUNC = {
        TOTAL = #fi.ARGS,
        IDX = 0,
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
        CALLER_ARGS = olua.newarray(', '),
        INSERT_AFTER = olua.newarray():push(fi.INSERT.AFTER),
        INSERT_BEFORE = olua.newarray():push(fi.INSERT.BEFORE),
        PUSH_RET = "",
        RET_EXP = "",
        NUM_RET = "0",
        POST_NEW = "",
        CALLBACK = "",
        PUSH_STUB = "",
        REMOVE_LOCAL_CALLBACK = "",
    }

    olua.message(fi.FUNCDECL)

    local funcname = format([[_${cls.CPPNAME}_${fi.CPPFUNC}${FUNC_INDEX}]])
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

    if #FUNC.INSERT_BEFORE > 0 then
        table.insert(FUNC.INSERT_BEFORE, 1, '// insert code before call')
    end

    if #FUNC.INSERT_AFTER > 0 then
        table.insert(FUNC.INSERT_AFTER, 1, '// insert code after call')
    end

    if fi.CTOR then
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
        if not fi.CTOR then
            FUNC.POST_NEW = ''
        end
    end

    write(format([[
        static int _${cls.CPPNAME}_${fi.CPPFUNC}${FUNC_INDEX}(lua_State *L)
        {
            olua_startinvoke(L);

            ${FUNC.DECL_ARGS}

            ${FUNC.CHECK_ARGS}

            ${FUNC.INSERT_BEFORE}

            ${FUNC.CALLBACK}

            // ${fi.FUNCDECL}
            ${FUNC.RET_EXP}${CALLER}${BEGIN_ARGS}${FUNC.CALLER_ARGS}${END_ARGS};
            ${FUNC.PUSH_RET}
            ${FUNC.POST_NEW}

            ${FUNC.INSERT_AFTER}

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
                        // ${fi.FUNCDECL}
                        return _${cls.CPPNAME}_${fi.CPPFUNC}${fi.INDEX}(L);
                    // }
                ]]),
                EXP2 = format([[
                    if (${TEST_ARGS}) {
                        // ${fi.FUNCDECL}
                        return _${cls.CPPNAME}_${fi.CPPFUNC}${fi.INDEX}(L);
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
                    // ${fi.FUNCDECL}
                    return _${cls.CPPNAME}_${fi.CPPFUNC}${fi.INDEX}(L);
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
    local CPPFUNC = fis[1].CPPFUNC
    local SUBONE = fis[1].STATIC and "" or " - 1"
    local IF_CHUNK = olua.newarray('\n\n')

    local pack_fi

    for _, fi in ipairs(fis) do
        gen_one_func(cls, fi, write, fi.INDEX, exported)
        for _, arg in ipairs(fi.ARGS) do
            if arg.ATTR.PACK and not arg.TYPE.NUMVARS then
                pack_fi = fi
                break
            end
        end
    end

    local funcname = format([[_${cls.CPPNAME}_${CPPFUNC}]])
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

    if pack_fi then
        IF_CHUNK:pushf([[
            if (num_args > 0) {
                // ${pack_fi.FUNCDECL}
                return _${cls.CPPNAME}_${pack_fi.CPPFUNC}${pack_fi.INDEX}(L);
            }
        ]])
    end

    write(format([[
        static int _${cls.CPPNAME}_${CPPFUNC}(lua_State *L)
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
