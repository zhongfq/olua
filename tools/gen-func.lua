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
        static int _${{cls.CPPCLS}}_${fi.CPP_FUNC}(lua_State *L)
        ${SNIPPET}
    ]]))
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
        if arg.ATTR.RET then
            -- (..., @ret ssize_t *size) (.... @ret ssize_t &value)
            -- arg.TYPE.DECLTYPE = lua_Integer
            -- arg.TYPE.CPPCLS = ssize_t
            DECLTYPE = arg.TYPE.CPPCLS
        end
        local INIT_VALUE = olua.initial_value(arg.TYPE)
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
    local CHECK_FUNC = olua.conv_func(arg.TYPE, arg.ATTR.PACK and 'pack' or 'check')
    if arg.ATTR.RET then
        local RET = arg.ATTR.RET
        local CHECK_ARGS = out.CHECK_ARGS
        arg.ATTR.RET = nil
        out.CHECK_ARGS = olua.newarray()
        if not arg.TYPE.SUBTYPES and arg.TYPE.DECLTYPE ~= arg.TYPE.CPPCLS then
            out.CHECK_ARGS:pushf([[${arg.TYPE.DECLTYPE} value;]])
            olua.gen_check_exp(arg, 'value', i, out)
            out.CHECK_ARGS:pushf([[${ARG_NAME} = (${arg.TYPE.CPPCLS})value;]])
        else
            olua.gen_check_exp(arg, name, i, out)
        end

        CHECK_ARGS:pushf([[
            //'${ARG_NAME}' with mark '@ret'
            if (!olua_isnoneornil(L, ${ARGN})) {
                ${out.CHECK_ARGS}
            }
        ]])
        out.CHECK_ARGS = CHECK_ARGS
        arg.ATTR.RET = RET
        return
    elseif olua.is_pointer_type(arg.TYPE) then
        if arg.ATTR.NULLABLE then
            out.CHECK_ARGS:pushf([[
                if (!olua_isnoneornil(L, ${ARGN})) {
                    ${CHECK_FUNC}(L, ${ARGN}, (void **)&${ARG_NAME}, "${arg.TYPE.LUACLS}");
                }
            ]])
        else
            out.CHECK_ARGS:pushf([[
                ${CHECK_FUNC}(L, ${ARGN}, (void **)&${ARG_NAME}, "${arg.TYPE.LUACLS}");
            ]])
        end
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES == 1 then
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            local TYPE_SPACE = olua.typespace(SUBTYPE.DECLTYPE)
            local SUBTYPE_CHECK_FUNC = olua.conv_func(SUBTYPE, 'check')
            if olua.is_pointer_type(SUBTYPE) then
                out.CHECK_ARGS:pushf([[
                    ${CHECK_FUNC}<${SUBTYPE.CPPCLS}>(L, ${ARGN}, &${ARG_NAME}, [L](${SUBTYPE.CPPCLS}*value) {
                        ${SUBTYPE_CHECK_FUNC}(L, -1, (void **)value, "${SUBTYPE.LUACLS}");
                    });
                ]])
            else
                if SUBTYPE.CPPCLS == SUBTYPE.DECLTYPE then
                    out.CHECK_ARGS:pushf([[
                        ${CHECK_FUNC}<${SUBTYPE.CPPCLS}>(L, ${ARGN}, &${ARG_NAME}, [L](${SUBTYPE.CPPCLS} *value) {
                            ${SUBTYPE_CHECK_FUNC}(L, -1, value);
                        });
                    ]])
                else
                    out.CHECK_ARGS:pushf([[
                        ${CHECK_FUNC}<${SUBTYPE.CPPCLS}>(L, ${ARGN}, &${ARG_NAME}, [L](${SUBTYPE.CPPCLS} *value) {
                            ${SUBTYPE.DECLTYPE}${TYPE_SPACE}obj;
                            ${SUBTYPE_CHECK_FUNC}(L, -1, &obj);
                            *value = (${SUBTYPE.CPPCLS})obj;
                        });
                    ]])
                end
            end
        else
            olua.assert(#arg.TYPE.SUBTYPES == 2)
            local SUBTYPE_DECL_ARGS = olua.newarray(', ')
            local SUBTYPE_TEMPLATE_ARGS = olua.newarray(', ')
            local SUBTYPE_CHECK_EXP = olua.newarray()
            local idx = -1
            for ii, SUBTYPE in ipairs(arg.TYPE.SUBTYPES) do
                local SUBTYPE_CHECK_FUNC = olua.conv_func(SUBTYPE, 'check')
                local TYPE_SPACE = olua.typespace(SUBTYPE.DECLTYPE)
                local SUBTYPE_NAME = 'arg' .. ii
                local CONST = SUBTYPE.CONST and 'const ' or ''
                if olua.is_pointer_type(SUBTYPE) then
                    SUBTYPE_DECL_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS}*${SUBTYPE_NAME}')
                    SUBTYPE_TEMPLATE_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS}')
                    SUBTYPE_CHECK_EXP:pushf([[
                        ${SUBTYPE_CHECK_FUNC}(L, ${idx}, (void **)${SUBTYPE_NAME}, "${SUBTYPE.LUACLS}");
                    ]])
                else
                    SUBTYPE_DECL_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS} *${SUBTYPE_NAME}')
                    SUBTYPE_TEMPLATE_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS}')
                    if SUBTYPE.CPPCLS == SUBTYPE.DECLTYPE then
                        SUBTYPE_CHECK_EXP:pushf([[
                            ${SUBTYPE_CHECK_FUNC}(L, ${idx}, ${SUBTYPE_NAME});
                        ]])
                    else
                        SUBTYPE_CHECK_EXP:pushf([[
                            ${SUBTYPE.DECLTYPE}${TYPE_SPACE}${SUBTYPE_NAME}obj;
                            ${SUBTYPE_CHECK_FUNC}(L, ${idx}, &${SUBTYPE_NAME}obj);
                            *${SUBTYPE_NAME} = (${SUBTYPE.CPPCLS})${SUBTYPE_NAME}obj;
                        ]])
                    end
                end
                idx = idx - 1
            end
            out.CHECK_ARGS:pushf([[
                ${CHECK_FUNC}<${SUBTYPE_TEMPLATE_ARGS}>(L, ${ARGN}, &${ARG_NAME}, [L](${SUBTYPE_DECL_ARGS}) {
                    ${SUBTYPE_CHECK_EXP}
                });
            ]])
        end
    else
        if arg.ATTR.PACK then
            out.IDX = out.IDX + arg.TYPE.NUM_VARS - 1
        end
        out.CHECK_ARGS:pushf('${CHECK_FUNC}(L, ${ARGN}, &${ARG_NAME});')
    end
end

function olua.gen_addref_exp(fi, arg, i, name, out)
    if not arg.ATTR.ADDREF then
        return
    end

    olua.assert(not fi.STATIC or fi.RET.TYPE.LUACLS or arg.ATTR.ADDREF[3])

    local ARGN = i
    local ARG_NAME = name
    local REF_NAME = assert(arg.ATTR.ADDREF[1], fi.CPP_FUNC .. ' no addref name')
    local ADDREF = assert(arg.ATTR.ADDREF[2], fi.CPP_FUNC .. ' no addref flag')
    local WHERE = arg.ATTR.ADDREF[3] or (fi.STATIC and -1 or 1)

    if arg.TYPE.CPPCLS == 'void' then
        olua.assert(fi.RET == arg)
        olua.assert(not fi.STATIC, 'no addref object')
        olua.assert(arg.ATTR.ADDREF[3], 'must supply where to addref object')
        ARGN = 1
    elseif arg.TYPE.SUBTYPES then
        olua.assert(ADDREF == '|', "expect use like: @addref(ref_name |)")
        if #arg.TYPE.SUBTYPES == 1 then
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            olua.assert(olua.is_pointer_type(SUBTYPE), "'%s' not a pointer type", SUBTYPE.CPPCLS)
        else
            olua.assert(#arg.TYPE.SUBTYPES == 2)
            local SUBTYPE1 = arg.TYPE.SUBTYPES[1]
            local SUBTYPE2 = arg.TYPE.SUBTYPES[2]
            olua.assert(olua.is_pointer_type(SUBTYPE1) or olua.is_pointer_type(SUBTYPE2))
        end
    else
        olua.assert(olua.is_pointer_type(arg.TYPE), "'%s' not a pointer type", arg.TYPE.CPPCLS)
    end

    if ADDREF == '|' then
        if arg.TYPE.SUBTYPES then
            if arg.ATTR.PACK or arg.ATTR.RET then
                local SUBTYPE = arg.TYPE.SUBTYPES[1]
                local PUSH_FUNC = olua.conv_func(arg.TYPE, 'push')
                local SUBTYPE_PUSH_FUNC = olua.conv_func(SUBTYPE, 'push')
                out.INSERT_AFTER:pushf([[
                    int ref_store = lua_absindex(L, ${WHERE});
                    ${PUSH_FUNC}<${SUBTYPE.CPPCLS}>(L, &${ARG_NAME}, [L](${SUBTYPE.CPPCLS}value) {
                        ${SUBTYPE_PUSH_FUNC}(L, value, "${SUBTYPE.LUACLS}");
                    });
                    olua_addref(L, ref_store, "${REF_NAME}", -1, OLUA_MODE_MULTIPLE | OLUA_FLAG_TABLE);
                    lua_pop(L, 1);
                ]])
            else
                if fi.VARIABLE then
                    out.INSERT_AFTER:pushf('olua_delallrefs(L, ${WHERE}, "${REF_NAME}");')
                end
                out.INSERT_AFTER:pushf('olua_addref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_MULTIPLE | OLUA_FLAG_TABLE);')
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

function olua.gen_delref_exp(fi, arg, i, name, out)
    if not arg.ATTR.DELREF then
        return
    end

    olua.assert(not fi.STATIC or arg.TYPE.LUACLS or arg.ATTR.DELREF[3])

    local ARGN = i
    local ARG_NAME = name
    local REF_NAME = assert(arg.ATTR.DELREF[1], fi.CPP_FUNC .. ' no ref name')
    local DELREF = assert(arg.ATTR.DELREF[2], fi.CPP_FUNC .. ' no delref flag')
    local WHERE = arg.ATTR.DELREF[3] or (fi.STATIC and -1 or 1)

    if DELREF == '|' or DELREF == '^' then
        if arg.TYPE.CPPCLS  == 'void' then
            olua.assert(not fi.STATIC, 'no delref object')
            olua.assert(arg.ATTR.DELREF[3], 'must supply where to delref object')
            ARGN = 1
        else
            olua.assert(olua.is_pointer_type(arg.TYPE), "'%s' not a pointer type", arg.TYPE.CPPCLS)
        end
    end

    if DELREF == '~' then
        out.INSERT_BEFORE:pushf('olua_startcmpref(L, ${WHERE}, "${REF_NAME}");')
        out.INSERT_AFTER:pushf('olua_endcmpref(L, ${WHERE}, "${REF_NAME}");')
    elseif DELREF == '*' then
        out.INSERT_AFTER:pushf('olua_delallrefs(L, ${WHERE}, "${REF_NAME}");')
    elseif DELREF == '|' then
        if arg.TYPE.SUBTYPES then
            out.INSERT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_MULTIPLE | OLUA_FLAG_TABLE);')
        else
            out.INSERT_AFTER:pushf('olua_delref(L, ${WHERE}, "${REF_NAME}", ${ARGN}, OLUA_MODE_MULTIPLE);')
        end
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
        local TO_FUNC = olua.conv_func(ti, 'to')
        out.DECL_ARGS:pushf('${cls.CPPCLS} *self = nullptr;')
        out.CHECK_ARGS:pushf('${TO_FUNC}(L, 1, (void **)&self, "${ti.LUACLS}");')
    end

    for i, ai in ipairs(fi.ARGS) do
        local ARG_NAME = "arg" .. i
        local ARGN = out.IDX + 1
        out.IDX = ARGN

        if olua.is_func_type(ai.TYPE) then
            olua.assert(fi.CALLBACK, 'no callback option')
        end

        -- function call args
        -- see 'basictype.lua'
        if ai.ATTR.RET then
            local CAST = ai.ATTR.RET == 'pointee' and '&' or ''
            out.CALLER_ARGS:pushf('${CAST}${ARG_NAME}')
        elseif ai.TYPE.DECLTYPE ~= ai.TYPE.CPPCLS and not ai.CALLBACK then
            out.CALLER_ARGS:pushf('(${ai.TYPE.CPPCLS})${ARG_NAME}')
        elseif ai.TYPE.VARIANT then
            -- void f(T), has 'T *' conv: T *arg => f(*arg)
            -- void f(T *) has T conv: T arg => f(&arg)
            local CAST = olua.is_pointer_type(ai.TYPE) and '*' or '&'
            out.CALLER_ARGS:pushf('${CAST}${ARG_NAME}')
        else
            out.CALLER_ARGS:pushf('${ARG_NAME}')
        end

        olua.gen_decl_exp(ai, ARG_NAME, out)
        olua.gen_check_exp(ai, ARG_NAME, ARGN, out)
        olua.gen_addref_exp(fi, ai, ARGN, ARG_NAME, out)
        olua.gen_delref_exp(fi, ai, ARGN, ARG_NAME, out)
    end
end

function olua.gen_push_exp(arg, name, out)
    local ARG_NAME = name
    local PUSH_FUNC = olua.conv_func(arg.TYPE, arg.ATTR.UNPACK and 'unpack' or 'push')
    if olua.is_pointer_type(arg.TYPE) then
        local CAST = arg.TYPE.VARIANT and '&' or ''
        out.PUSH_ARGS:pushf('${PUSH_FUNC}(L, ${CAST}${ARG_NAME}, "${arg.TYPE.LUACLS}");')
    elseif arg.TYPE.SUBTYPES then
        if #arg.TYPE.SUBTYPES == 1 then
            local SUBTYPE = arg.TYPE.SUBTYPES[1]
            local SUBTYPE_PUSH_FUNC = olua.conv_func(SUBTYPE, 'push')
            local SUBTYPE_CAST = olua.is_value_type(SUBTYPE) and format('(${SUBTYPE.DECLTYPE})') or '&'
            if olua.is_pointer_type(SUBTYPE) then
                out.PUSH_ARGS:pushf([[
                    ${PUSH_FUNC}<${SUBTYPE.CPPCLS}>(L, &${ARG_NAME}, [L](${SUBTYPE.CPPCLS}value) {
                        ${SUBTYPE_PUSH_FUNC}(L, value, "${SUBTYPE.LUACLS}");
                    });
                ]])
            else
                out.PUSH_ARGS:pushf([[
                    ${PUSH_FUNC}<${SUBTYPE.CPPCLS}>(L, &${ARG_NAME}, [L](${SUBTYPE.CPPCLS} value) {
                        ${SUBTYPE_PUSH_FUNC}(L, ${SUBTYPE_CAST}value);
                    });
                ]])
            end
        else
            olua.assert(#arg.TYPE.SUBTYPES == 2)
            local SUBTYPE_DECL_ARGS = olua.newarray(', ')
            local SUBTYPE_TEMPLATE_ARGS = olua.newarray(', ')
            local SUBTYPE_PUSH_EXP = olua.newarray()
            for i, SUBTYPE in ipairs(arg.TYPE.SUBTYPES) do
                local SUBTYPE_PUSH_FUNC = olua.conv_func(SUBTYPE, 'push')
                local SUBTYPE_CAST = olua.is_value_type(SUBTYPE) and format('(${SUBTYPE.DECLTYPE})') or '&'
                local SUBTYPE_NAME = 'arg' .. i
                local CONST = SUBTYPE.CONST and 'const ' or ''
                if olua.is_pointer_type(SUBTYPE) then
                    SUBTYPE_DECL_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS}${SUBTYPE_NAME}')
                    SUBTYPE_TEMPLATE_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS}')
                    SUBTYPE_PUSH_EXP:pushf('${SUBTYPE_PUSH_FUNC}(L, ${SUBTYPE_NAME}, "${SUBTYPE.LUACLS}");')
                else
                    SUBTYPE_DECL_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS} ${SUBTYPE_NAME}')
                    SUBTYPE_TEMPLATE_ARGS:pushf('${CONST}${SUBTYPE.CPPCLS}')
                    SUBTYPE_PUSH_EXP:pushf('${SUBTYPE_PUSH_FUNC}(L, ${SUBTYPE_CAST}${SUBTYPE_NAME});')
                end
            end
            out.PUSH_ARGS:pushf([[
                ${PUSH_FUNC}<${SUBTYPE_TEMPLATE_ARGS}>(L, &${ARG_NAME}, [L](${SUBTYPE_DECL_ARGS}) {
                    ${SUBTYPE_PUSH_EXP}
                });
            ]])
        end
    else
        local CAST = ""
        if not olua.is_value_type(arg.TYPE) then
            -- push func: olua_push_value(L, T *)
            -- T *f(), has T conv
            CAST = not arg.TYPE.VARIANT and '&' or ''
        elseif arg.TYPE.DECLTYPE ~= arg.TYPE.CPPCLS then
            -- int => lua_Interge
            CAST = format('(${arg.TYPE.DECLTYPE})')
        end
        out.PUSH_ARGS:pushf('${PUSH_FUNC}(L, ${CAST}${ARG_NAME});')
    end
end

local function gen_func_ret(cls, fi, out)
    if fi.RET.TYPE.CPPCLS ~= 'void' then
        local TYPE_SPACE = olua.typespace(fi.RET.DECLTYPE)
        if fi.RET.TYPE.VARIANT and TYPE_SPACE == ' ' then
            out.DECL_RET = format('${fi.RET.DECLTYPE} &ret = (${fi.RET.DECLTYPE} &)')
        else
            olua.assert(fi.RET.DECLTYPE:find(fi.RET.TYPE.CPPCLS))
            out.DECL_RET = format('${fi.RET.DECLTYPE}${TYPE_SPACE}ret = ') .. ' '
        end

        local EXPS = {PUSH_ARGS = olua.newarray()}

        olua.gen_push_exp(fi.RET, 'ret', EXPS)
        out.PUSH_RET = format('int num_ret = ${EXPS.PUSH_ARGS}')

        if #out.PUSH_RET > 0 then
            out.NUM_RET = "num_ret"
        end
    end

    olua.gen_addref_exp(fi, fi.RET, -1, 'ret', out)
    olua.gen_delref_exp(fi, fi.RET, -1, 'ret', out)
end

local function gen_one_func(cls, fi, write, funcidx)
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

    olua.message(fi.FUNC_DESC)

    if fi.SNIPPET then
        gen_func_snippet(cls, fi, write)
        return
    end

    gen_func_args(cls, fi, out)
    gen_func_ret(cls, fi, out)

    for i, ai in ipairs(fi.ARGS) do
        if ai.ATTR.RET then
            local RET = {PUSH_ARGS = olua.newarray()}
            olua.gen_push_exp(ai, 'arg' .. i, RET)
            out.PUSH_RET = format([[
                ${out.PUSH_RET}
                ${RET.PUSH_ARGS}
            ]])
            out.NUM_RET = format([[${out.NUM_RET} + 1]])
        end
    end

    if fi.CALLBACK then
        olua.gen_callback(cls, fi, out)
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
        static int _${{cls.CPPCLS}}_${fi.CPP_FUNC}${FUNC_IDX}(lua_State *L)
        {
            olua_startinvoke(L);

            ${out.DECL_ARGS}

            ${out.CHECK_ARGS}

            ${out.INSERT_BEFORE}

            ${out.CALLBACK}

            // ${fi.FUNC_DESC}
            ${out.DECL_RET}${CALLER}${BEGIN_ARGS}${out.CALLER_ARGS}${END_ARGS};
            ${out.PUSH_RET}
            ${out.POST_NEW}

            ${out.INSERT_AFTER}

            ${out.REMOVE_LOCAL_CALLBACK}

            olua_endinvoke(L);

            return ${out.NUM_RET};
        }
    ]]))
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
            local ARGN = (fi.STATIC and 0 or 1)
            for i, ai in ipairs(fi.ARGS) do
                local IS_FUNC = olua.conv_func(ai.TYPE, ai.ATTR.PACK and 'ispack' or 'is')
                local TEST_NULL = ""

                ARGN = ARGN + 1

                MAX_VARS = math.max(ai.TYPE.NUM_VARS or 1, MAX_VARS)

                if ai.ATTR.NULLABLE then
                    TEST_NULL = ' ' .. format('|| olua_isnil(L, ${ARGN})')
                end

                if olua.is_pointer_type(ai.TYPE) then
                    TEST_EXPS[#TEST_EXPS + 1] = format([[
                        (${IS_FUNC}(L, ${ARGN}, "${ai.TYPE.LUACLS}")${TEST_NULL})
                    ]])
                else
                    TEST_EXPS[#TEST_EXPS + 1] = format([[
                        (${IS_FUNC}(L, ${ARGN})${TEST_NULL})
                    ]])
                end

                if ai.ATTR.PACK and ai.TYPE.NUM_VARS then
                    ARGN = ARGN + ai.TYPE.NUM_VARS - 1
                end
            end

            TEST_EXPS = table.concat(TEST_EXPS, " && ")
            CALL_CHUNK[#CALL_CHUNK + 1] = {
                MAX_VARS = MAX_VARS,
                EXP1 = format([[
                    // if (${TEST_EXPS}) {
                        // ${fi.FUNC_DESC}
                        return _${{cls.CPPCLS}}_${fi.CPP_FUNC}${fi.INDEX}(L);
                    // }
                ]]),
                EXP2 = format([[
                    if (${TEST_EXPS}) {
                        // ${fi.FUNC_DESC}
                        return _${{cls.CPPCLS}}_${fi.CPP_FUNC}${fi.INDEX}(L);
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
                    // ${fi.FUNC_DESC}
                    return _${{cls.CPPCLS}}_${fi.CPP_FUNC}${fi.INDEX}(L);
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

local function gen_multi_func(cls, fis, write)
    local CPP_FUNC = fis[1].CPP_FUNC
    local SUBONE = fis[1].STATIC and "" or " - 1"
    local IF_CHUNK = olua.newarray('\n\n')

    local pack_fi

    for i, fi in ipairs(fis) do
        gen_one_func(cls, fi, write, fi.INDEX)
        write('')
        for _, arg in ipairs(fi.ARGS) do
            if arg.ATTR.PACK and not arg.TYPE.NUM_VARS then
                pack_fi = fi
                break
            end
        end
    end

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
                // ${pack_fi.FUNC_DESC}
                return _${{cls.CPPCLS}}_${pack_fi.CPP_FUNC}${pack_fi.INDEX}(L);
            }
        ]])
    end

    write(format([[
        static int _${{cls.CPPCLS}}_${CPP_FUNC}(lua_State *L)
        {
            int num_args = lua_gettop(L)${SUBONE};

            ${IF_CHUNK}

            luaL_error(L, "method '${cls.CPPCLS}::${CPP_FUNC}' not support '%d' arguments", num_args);

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
