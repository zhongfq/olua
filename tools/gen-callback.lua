local olua = require "olua"

local format = olua.format

local function get_callback_store(fi, idx)
    if not idx and fi.CALLBACK_OPT.TAG_STORE == 'return' then
        return -1
    else
        idx = idx or fi.CALLBACK_OPT.TAG_STORE or 0
        if idx < 0 then
            idx = idx + #fi.ARGS + 1
        end
        olua.assert(idx <= #fi.ARGS and idx >= 0, "store index '%d' out of range", idx)
        return idx
    end
end

local function gen_callback_tag(cls, fi)
    if not fi.CALLBACK_OPT.TAG_MAKER then
        olua.error("no tag maker: %s.%s", cls.CPPCLS, fi.LUAFUNC)
    end

    if not string.find(fi.CALLBACK_OPT.TAG_MAKER, '[()]+') then
        return olua.stringify(fi.CALLBACK_OPT.TAG_MAKER)
    end

    return string.gsub(fi.CALLBACK_OPT.TAG_MAKER, '#(%-?%d+)', function (n)
        local idx = get_callback_store(fi, tonumber(n))
        return idx == 0 and 'self' or ('arg' .. idx)
    end)
end

local function check_callback_store(fi, idx)
    if idx > 0 then
        local ai = fi.ARGS[idx]
        olua.assert(olua.ispointee(ai.TYPE), 'arg #%d is not a userdata', idx)
    end
end

local function gen_remove_callback(cls, fi, write)
    local TAG_MODE = fi.CALLBACK_OPT.TAG_MODE
    local TAG_MAKER = gen_callback_tag(cls, fi, write)
    local CALLBACK_STORE_OBJ
    local TAG_STORE = get_callback_store(fi)

    if TAG_STORE == 0 then
        CALLBACK_STORE_OBJ = 'self'
        if fi.STATIC then
            CALLBACK_STORE_OBJ = format 'olua_pushclassobj(L, "${cls.LUACLS}")'
        end
    else
        CALLBACK_STORE_OBJ = 'arg' .. TAG_STORE
        check_callback_store(fi, TAG_STORE)
    end

    local block = format([[
        std::string tag = ${TAG_MAKER};
        void *self_obj = (void *)${CALLBACK_STORE_OBJ};
        olua_removecallback(L, self_obj, tag.c_str(), ${TAG_MODE});
    ]])
    return block
end

local function gen_ret_callback(cls, fi, write)
    local TAG_MODE = fi.CALLBACK_OPT.TAG_MODE
    local TAG_MAKER = gen_callback_tag(cls, fi, write)
    local CALLBACK_STORE_OBJ
    local TAG_STORE = get_callback_store(fi)

    if TAG_STORE == 0 then
        CALLBACK_STORE_OBJ = 'self'
    else
        CALLBACK_STORE_OBJ = 'arg' .. TAG_STORE
        check_callback_store(TAG_STORE)
    end

    local block = format([[
        void *self_obj = (void *)${CALLBACK_STORE_OBJ};
        std::string tag = ${TAG_MAKER};
        olua_getcallback(L, self_obj, tag.c_str(), ${TAG_MODE});
    ]])
    return block
end

function olua.gen_callback(cls, fi, write, out)
    if fi.RET.TYPE.CPPCLS == "std::function" then
        out.CALLBACK = gen_ret_callback(cls, fi, write)
        return
    end
    
    if fi.CALLBACK_OPT.TAG_MODE == 'OLUA_TAG_SUBEQUAL' or
            fi.CALLBACK_OPT.TAG_MODE == 'OLUA_TAG_SUBSTARTWITH' then
        out.CALLBACK = gen_remove_callback(cls, fi, write)
        return
    end

    local ai
    local IDX = not fi.STATIC and 1 or 0
    local CALLBACK_ARG_NAME = ""

    for i, v in ipairs(fi.ARGS) do
        IDX = IDX + 1
        if v.CALLBACK.ARGS then
            CALLBACK_ARG_NAME = 'arg' .. i
            ai = v
            break
        end
    end

    if not ai then
        return ''
    end

    local OLUA_CALLBACK_TAG = assert(fi.CALLBACK_OPT.TAG_MODE, 'no tag mode')
    local TAG_MAKER = gen_callback_tag(cls, fi, write)
    local CALLBACK_STORE_OBJ
    local TAG_STORE

    local enablepool = false

    local CALLBACK = {
        ARGS = olua.newarray(),
        NUM_ARGS = #ai.CALLBACK.ARGS,
        PUSH_ARGS = olua.newarray(),
        REMOVE_ONCE_CALLBACK = "",
        REMOVE_LOCAL_CALLBACK = "",
        REMOVE_NORMAL_CALLBACK = "",
        POP_OBJPOOL = "",
        DECL_RESULT = "",
        RETURN_RESULT = "",
        CHECK_RESULT = "",
        INJECT_BEFORE = olua.newarray():push(fi.INJECT.CALLBACK_BEFORE),
        INJECT_AFTER = olua.newarray():push(fi.INJECT.CALLBACK_AFTER),
    }

    local localBlock = false

    if ai.ATTR.LOCAL then
        for _, v in ipairs(ai.CALLBACK.ARGS) do
            if not olua.isvaluetype(v.TYPE) then
                localBlock = true
            end
        end
    end

    if localBlock then
        CALLBACK.PUSH_ARGS:push( "size_t last = olua_push_objpool(L);")
        CALLBACK.PUSH_ARGS:push("olua_enable_objpool(L);")
        CALLBACK.POP_OBJPOOL = format([[
            //pop stack value
            olua_pop_objpool(L, last);
        ]])
    else
        for _, v in ipairs(ai.CALLBACK.ARGS) do
            if v.ATTR.LOCAL then
                CALLBACK.PUSH_ARGS:push( "size_t last = olua_push_objpool(L);")
                CALLBACK.POP_OBJPOOL = format([[
                    //pop stack value
                    olua_pop_objpool(L, last);
                ]])
                break
            end
        end
    end

    for i, v in ipairs(ai.CALLBACK.ARGS) do
        local ARGNAME = 'arg' .. i

        if not localBlock then
            if v.ATTR.LOCAL then
                if not enablepool then
                    enablepool = true
                    CALLBACK.PUSH_ARGS:push("olua_enable_objpool(L);")
                end
            elseif enablepool then
                enablepool = false
                CALLBACK.PUSH_ARGS:push("olua_disable_objpool(L);")
            end
        end

        olua.gen_push_exp(v, ARGNAME, CALLBACK)

        local SPACE = string.find(v.RAW_DECLTYPE, '[*&]$') and '' or ' '
        CALLBACK.ARGS:push(format([[
            ${v.RAW_DECLTYPE}${SPACE}${ARGNAME}
        ]]))
    end

    if localBlock then
        CALLBACK.PUSH_ARGS:push("olua_disable_objpool(L);")
    else
        if enablepool then
            CALLBACK.PUSH_ARGS:push("olua_disable_objpool(L);")
            enablepool = false
        end
    end

    if fi.CALLBACK_OPT.TAG_SCOPE == 'once' then
        CALLBACK.REMOVE_ONCE_CALLBACK = format([[
            olua_removecallback(L, self_obj, func.c_str(), OLUA_TAG_WHOLE);
        ]])
    elseif fi.CALLBACK_OPT.TAG_SCOPE == 'function' then
        CALLBACK.REMOVE_LOCAL_CALLBACK = format([[
            olua_removecallback(L, self_obj, func.c_str(), OLUA_TAG_WHOLE);
        ]])
    end

    local RET = ai.CALLBACK.RET
    if RET.TYPE.CPPCLS ~= "void" then
        local OUT = {
            DECL_ARGS = olua.newarray(),
            CHECK_ARGS = olua.newarray(),
            PUSH_ARGS = olua.newarray(),
        }
        olua.gen_decl_exp(RET, 'ret', OUT)
        olua.gen_check_exp(RET, 'ret', -1, OUT)
        CALLBACK.DECL_RESULT = OUT.DECL_ARGS
        CALLBACK.CHECK_RESULT = OUT.CHECK_ARGS

        local OLUA_IS_VALUE = olua.convfunc(RET.TYPE, 'is')
        if olua.ispointee(RET.TYPE) then
            CALLBACK.CHECK_RESULT = format([[
                if (${OLUA_IS_VALUE}(L, -1, "${RET.TYPE.LUACLS}")) {
                    ${CALLBACK.CHECK_RESULT}
                }
            ]])
        else
            CALLBACK.CHECK_RESULT = format([[
                if (${OLUA_IS_VALUE}(L, -1)) {
                    ${CALLBACK.CHECK_RESULT}
                }
            ]])
        end

        if RET.TYPE.DECLTYPE ~= RET.TYPE.CPPCLS then
            CALLBACK.RETURN_RESULT = format([[return (${RET.TYPE.CPPCLS})ret;]])
        else
            CALLBACK.RETURN_RESULT = "return ret;"
        end

    end

    TAG_STORE = get_callback_store(fi) + 1
    if TAG_STORE == 0 then
        local POST_PUSH = fi.CONSTRUCTOR and
            'olua_postnew(L, ret);' or
            'olua_postpush(L, ret, OLUA_OBJ_NEW);'
        local REMOVE_CALLBACK = ''
        if OLUA_CALLBACK_TAG == 'OLUA_TAG_REPLACE' then
            REMOVE_CALLBACK = 'olua_removecallback(L, self_obj, tag.c_str(), OLUA_TAG_SUBEQUAL);'
        end
        CALLBACK_STORE_OBJ = format 'olua_newobjstub(L, "${fi.RET.TYPE.LUACLS}")'
        out.PUSH_STUB = format [[
            const char *cls = olua_getluatype(L, ret, "${fi.RET.TYPE.LUACLS}");
            if (olua_pushobjstub(L, ret, self_obj, cls) == OLUA_OBJ_EXIST) {
                ${REMOVE_CALLBACK}
                lua_pushstring(L, func.c_str());
                lua_pushvalue(L, ${IDX});
                olua_setvariable(L, -3);
            } else {
                ${POST_PUSH}
            }
        ]]
    elseif TAG_STORE == 1 then
        CALLBACK_STORE_OBJ = 'self'
        if fi.STATIC and fi.RET.TYPE.CPPCLS == 'void' then
            CALLBACK_STORE_OBJ = format 'olua_pushclassobj(L, "${cls.LUACLS}")'
        end
    else
        CALLBACK_STORE_OBJ = 'arg' .. (TAG_STORE - 1)
    end

    CALLBACK.ARGS = table.concat(CALLBACK.ARGS, ", ")

    if #CALLBACK.INJECT_BEFORE > 0 then
        CALLBACK.INJECT_BEFORE = format [[
            // inject code before call
            ${CALLBACK.INJECT_BEFORE}
        ]]
    end

    if #CALLBACK.INJECT_AFTER > 0 then
        CALLBACK.INJECT_AFTER = format [[
            // inject code after call
            ${CALLBACK.INJECT_AFTER}
        ]]
    end

    olua.assert(OLUA_CALLBACK_TAG == 'OLUA_TAG_REPLACE' or
        OLUA_CALLBACK_TAG == 'OLUA_TAG_NEW',
        "expect '%s' or '%s', got '%s'",
        'OLUA_TAG_REPLACE', 'OLUA_TAG_NEW',
        OLUA_CALLBACK_TAG
    )

    local CALLBACK_CHUNK = format([[
        lua_Unsigned ctx = olua_context(L);
        ${CALLBACK_ARG_NAME} = [self_obj, func, ctx](${CALLBACK.ARGS}) {
            lua_State *L = olua_mainthread(NULL);
            ${CALLBACK.DECL_RESULT}
            if (L != NULL && (olua_context(L) == ctx)) {
                int top = lua_gettop(L);
                ${CALLBACK.PUSH_ARGS}

                ${CALLBACK.INJECT_BEFORE}

                olua_callback(L, self_obj, func.c_str(), ${CALLBACK.NUM_ARGS});

                ${CALLBACK.CHECK_RESULT}

                ${CALLBACK.INJECT_AFTER}

                ${CALLBACK.REMOVE_ONCE_CALLBACK}

                ${CALLBACK.POP_OBJPOOL}
                lua_settop(L, top);
            }
            ${CALLBACK.RETURN_RESULT}
        };
    ]])

    if ai.ATTR.OPTIONAL or ai.ATTR.NULLABLE then
        local OLUA_IS_VALUE = olua.convfunc(ai.TYPE, 'is')
        CALLBACK.REMOVE_NORMAL_CALLBACK = format [[
            olua_removecallback(L, self_obj, tag.c_str(), OLUA_TAG_SUBEQUAL);
        ]]
        if OLUA_CALLBACK_TAG ~= 'OLUA_TAG_REPLACE' then
            CALLBACK.REMOVE_NORMAL_CALLBACK = ''
        end
        if TAG_STORE == 0 then
            CALLBACK_CHUNK = format([[
                void *self_obj = (void *)${CALLBACK_STORE_OBJ};
                std::string tag = ${TAG_MAKER};
                std::string func;
                if (${OLUA_IS_VALUE}(L, ${IDX})) {
                    func = olua_setcallback(L, self_obj, tag.c_str(), ${IDX}, ${OLUA_CALLBACK_TAG});
                    ${CALLBACK_CHUNK}
                } else {
                    ${CALLBACK.REMOVE_NORMAL_CALLBACK}
                    ${CALLBACK_ARG_NAME} = nullptr;
                }
            ]])
        else
            if #CALLBACK.REMOVE_NORMAL_CALLBACK > 0 then
                CALLBACK.REMOVE_NORMAL_CALLBACK = format([[
                    void *self_obj = (void *)${CALLBACK_STORE_OBJ};
                    std::string tag = ${TAG_MAKER};
                    ${CALLBACK.REMOVE_NORMAL_CALLBACK}
                ]])
            end
            CALLBACK_CHUNK = format([[
                if (${OLUA_IS_VALUE}(L, ${IDX})) {
                    void *self_obj = (void *)${CALLBACK_STORE_OBJ};
                    std::string tag = ${TAG_MAKER};
                    std::string func = olua_setcallback(L, self_obj, tag.c_str(), ${IDX}, ${OLUA_CALLBACK_TAG});
                    ${CALLBACK_CHUNK}
                } else {
                    ${CALLBACK.REMOVE_NORMAL_CALLBACK}
                    ${CALLBACK_ARG_NAME} = nullptr;
                }
            ]])
        end
    else
        CALLBACK_CHUNK = format([[
            void *self_obj = (void *)${CALLBACK_STORE_OBJ};
            std::string tag = ${TAG_MAKER};
            std::string func = olua_setcallback(L, self_obj, tag.c_str(), ${IDX}, ${OLUA_CALLBACK_TAG});
            ${CALLBACK_CHUNK}
        ]])
    end

    out.CALLBACK = CALLBACK_CHUNK
    out.REMOVE_LOCAL_CALLBACK = CALLBACK.REMOVE_LOCAL_CALLBACK
end