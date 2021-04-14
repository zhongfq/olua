local olua = require "olua"

local format = olua.format

local function get_callback_store(fi, idx)
    if not idx and fi.CALLBACK.TAG_STORE == 'return' then
        return -1
    else
        idx = idx or fi.CALLBACK.TAG_STORE or 0
        if idx < 0 then
            idx = idx + #fi.ARGS + 1
        end
        olua.assert(idx <= #fi.ARGS and idx >= 0, "store index '%d' out of range", idx)
        return idx
    end
end

local function gen_callback_tag(cls, fi)
    if not fi.CALLBACK.TAG_MAKER then
        olua.error("no tag maker: %s.%s", cls.CPPCLS, fi.LUA_FUNC)
    end

    if not string.find(fi.CALLBACK.TAG_MAKER, '[()]+') then
        return olua.stringify(fi.CALLBACK.TAG_MAKER)
    end

    return string.gsub(fi.CALLBACK.TAG_MAKER, '#(%-?%d+)', function (n)
        local idx = get_callback_store(fi, tonumber(n))
        return idx == 0 and 'self' or ('arg' .. idx)
    end)
end

local function check_callback_store(fi, idx)
    if idx > 0 then
        local ai = fi.ARGS[idx]
        olua.assert(olua.is_pointer_type(ai.TYPE), 'arg #%d is not a userdata', idx)
    end
end

local function gen_remove_callback(cls, fi)
    local tag_store = get_callback_store(fi)
    local CB_TAG = gen_callback_tag(cls, fi)
    local CB_STORE

    if tag_store > 0 then
        CB_STORE = 'arg' .. tag_store
        check_callback_store(fi, tag_store)
    elseif fi.STATIC then
        CB_STORE = format 'olua_pushclassobj(L, "${cls.LUACLS}")'
    else
        CB_STORE = 'self'
    end

    return format([[
        std::string cb_tag = ${CB_TAG};
        void *cb_store = (void *)${CB_STORE};
        olua_removecallback(L, cb_store, cb_tag.c_str(), ${fi.CALLBACK.TAG_MODE});
    ]]), nil
end

local function gen_ret_callback(cls, fi)
    local TAG_MODE = fi.CALLBACK.TAG_MODE
    local TAG_STORE = get_callback_store(fi)
    local CB_TAG = gen_callback_tag(cls, fi)
    local CB_STORE

    if TAG_STORE == 0 then
        CB_STORE = 'self'
    else
        CB_STORE = 'arg' .. TAG_STORE
        check_callback_store(fi, TAG_STORE)
    end

    return format([[
        void *cb_store = (void *)${CB_STORE};
        std::string cb_tag = ${CB_TAG};
        olua_getcallback(L, cb_store, cb_tag.c_str(), ${TAG_MODE});
    ]]), nil
end

function olua.gen_callback(cls, fi, out)
    if olua.is_func_type(fi.RET.TYPE) then
        out.CALLBACK = gen_ret_callback(cls, fi)
        return
    end
    
    if fi.CALLBACK.TAG_MODE == 'OLUA_TAG_SUBEQUAL' or
            fi.CALLBACK.TAG_MODE == 'OLUA_TAG_SUBSTARTWITH' then
        out.CALLBACK = gen_remove_callback(cls, fi)
        return
    end

    local cbarg
    local ARGN = not fi.STATIC and 1 or 0
    local ARG_NAME = ""

    for i, arg in ipairs(fi.ARGS) do
        ARGN = ARGN + 1
        if arg.CALLBACK then
            ARG_NAME = 'arg' .. i
            cbarg = arg
            break
        end
    end

    if not cbarg then
        return ''
    end

    local TAG_MODE = assert(fi.CALLBACK.TAG_MODE, 'no tag mode')
    local TAG_SCOPE = fi.CALLBACK.TAG_SCOPE
    local CB_TAG = gen_callback_tag(cls, fi)
    local CB_STORE
    local TAG_STORE

    local enablepool = false

    local cbout = {
        ARGS = olua.newarray(),
        NUM_ARGS = #cbarg.CALLBACK.ARGS,
        PUSH_ARGS = olua.newarray(),
        REMOVE_ONCE_CALLBACK = "",
        REMOVE_LOCAL_CALLBACK = "",
        REMOVE_NORMAL_CALLBACK = "",
        POP_OBJPOOL = "",
        DECL_RESULT = "",
        RETURN_RESULT = "",
        CHECK_RESULT = "",
        INSERT_BEFORE = olua.newarray():push(fi.INSERT.CALLBACK_BEFORE),
        INSERT_AFTER = olua.newarray():push(fi.INSERT.CALLBACK_AFTER),
    }

    local localBlock = false

    if cbarg.ATTR.LOCAL then
        for _, arg in ipairs(cbarg.CALLBACK.ARGS) do
            if not olua.is_value_type(arg.TYPE) then
                localBlock = true
            end
        end
    end

    if fi.RET.ATTR.USING then
        CB_TAG = CB_TAG .. ' + std::string(".using")'
    end

    if localBlock then
        cbout.PUSH_ARGS:push( "size_t last = olua_push_objpool(L);")
        cbout.PUSH_ARGS:push("olua_enable_objpool(L);")
        cbout.POP_OBJPOOL = format([[
            //pop stack value
            olua_pop_objpool(L, last);
        ]])
    else
        for _, arg in ipairs(cbarg.CALLBACK.ARGS) do
            if arg.ATTR.LOCAL then
                cbout.PUSH_ARGS:push( "size_t last = olua_push_objpool(L);")
                cbout.POP_OBJPOOL = format([[
                    //pop stack value
                    olua_pop_objpool(L, last);
                ]])
                break
            end
        end
    end

    for i, arg in ipairs(cbarg.CALLBACK.ARGS) do
        local CB_ARG_NAME = 'arg' .. i

        if not localBlock then
            if arg.ATTR.LOCAL then
                if not enablepool then
                    enablepool = true
                    cbout.PUSH_ARGS:push("olua_enable_objpool(L);")
                end
            elseif enablepool then
                enablepool = false
                cbout.PUSH_ARGS:push("olua_disable_objpool(L);")
            end
        end

        olua.gen_push_exp(arg, CB_ARG_NAME, cbout)

        local TYPE_SPACE = olua.typespace(arg.RAWDECL)
        cbout.ARGS:pushf([[
            ${arg.RAWDECL}${TYPE_SPACE}${CB_ARG_NAME}
        ]])
    end

    if localBlock then
        cbout.PUSH_ARGS:push("olua_disable_objpool(L);")
    elseif enablepool then
        cbout.PUSH_ARGS:push("olua_disable_objpool(L);")
        enablepool = false
    end

    if TAG_SCOPE == 'once' then
        cbout.REMOVE_ONCE_CALLBACK = format([[
            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);
        ]])
    elseif TAG_SCOPE == 'function' then
        cbout.REMOVE_LOCAL_CALLBACK = format([[
            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);
        ]])
    end

    local RET = cbarg.CALLBACK.RET
    if RET.TYPE.CPPCLS ~= "void" then
        local OUT = {
            DECL_ARGS = olua.newarray(),
            CHECK_ARGS = olua.newarray(),
            PUSH_ARGS = olua.newarray(),
        }
        olua.gen_decl_exp(RET, 'ret', OUT)
        olua.gen_check_exp(RET, 'ret', -1, OUT)
        cbout.DECL_RESULT = OUT.DECL_ARGS
        cbout.CHECK_RESULT = OUT.CHECK_ARGS

        local OLUA_IS_VALUE = olua.conv_func(RET.TYPE, 'is')
        if olua.is_pointer_type(RET.TYPE) then
            cbout.CHECK_RESULT = format([[
                if (${OLUA_IS_VALUE}(L, -1, "${RET.TYPE.LUACLS}")) {
                    ${cbout.CHECK_RESULT}
                }
            ]])
        else
            cbout.CHECK_RESULT = format([[
                if (${OLUA_IS_VALUE}(L, -1)) {
                    ${cbout.CHECK_RESULT}
                }
            ]])
        end
        cbout.RETURN_RESULT = format([[return (${RET.DECLTYPE})ret;]])
    end

    TAG_STORE = get_callback_store(fi) + 1
    if TAG_STORE == 0 then
        local POST_PUSH = fi.CTOR and
            'olua_postnew(L, ret);' or
            'olua_postpush(L, ret, OLUA_OBJ_NEW);'
        local REMOVE_CALLBACK = ''
        if TAG_MODE == 'OLUA_TAG_REPLACE' then
            REMOVE_CALLBACK = 'olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_SUBEQUAL);'
        end
        CB_STORE = format 'olua_newobjstub(L, "${fi.RET.TYPE.LUACLS}")'
        out.PUSH_STUB = format [[
            const char *cls = olua_getluatype(L, ret, "${fi.RET.TYPE.LUACLS}");
            if (olua_pushobjstub(L, ret, cb_store, cls) == OLUA_OBJ_EXIST) {
                ${REMOVE_CALLBACK}
                lua_pushstring(L, cb_name.c_str());
                lua_pushvalue(L, ${ARGN});
                olua_setvariable(L, -3);
            } else {
                ${POST_PUSH}
            }
        ]]
    elseif TAG_STORE == 1 then
        CB_STORE = 'self'
        if (fi.STATIC and fi.RET.TYPE.CPPCLS == 'void') or TAG_SCOPE == 'function' then
            CB_STORE = format 'olua_pushclassobj(L, "${cls.LUACLS}")'
        end
    else
        CB_STORE = 'arg' .. (TAG_STORE - 1)
    end

    cbout.ARGS = table.concat(cbout.ARGS, ", ")

    if #cbout.INSERT_BEFORE > 0 then
        cbout.INSERT_BEFORE = format [[
            // insert code before call
            ${cbout.INSERT_BEFORE}
        ]]
    end

    if #cbout.INSERT_AFTER > 0 then
        cbout.INSERT_AFTER = format [[
            // insert code after call
            ${cbout.INSERT_AFTER}
        ]]
    end

    olua.assert(TAG_MODE == 'OLUA_TAG_REPLACE' or
        TAG_MODE == 'OLUA_TAG_NEW',
        "expect '%s' or '%s', got '%s'",
        'OLUA_TAG_REPLACE', 'OLUA_TAG_NEW',
        TAG_MODE
    )

    local CALLBACK_CHUNK = format([[
        lua_Integer cb_ctx = olua_context(L);
        ${ARG_NAME} = [cb_store, cb_name, cb_ctx](${cbout.ARGS}) {
            lua_State *L = olua_mainthread(NULL);
            olua_checkhostthread();
            ${cbout.DECL_RESULT}
            if (L != NULL && olua_context(L) == cb_ctx) {
                int top = lua_gettop(L);
                ${cbout.PUSH_ARGS}

                ${cbout.INSERT_BEFORE}

                olua_callback(L, cb_store, cb_name.c_str(), ${cbout.NUM_ARGS});

                ${cbout.CHECK_RESULT}

                ${cbout.INSERT_AFTER}

                ${cbout.REMOVE_ONCE_CALLBACK}

                ${cbout.POP_OBJPOOL}
                lua_settop(L, top);
            }
            ${cbout.RETURN_RESULT}
        };
    ]])

    if cbarg.ATTR.OPTIONAL or cbarg.ATTR.NULLABLE then
        local OLUA_IS_VALUE = olua.conv_func(cbarg.TYPE, 'is')
        if TAG_MODE == 'OLUA_TAG_REPLACE' then
            cbout.REMOVE_NORMAL_CALLBACK = format [[
                olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_SUBEQUAL);
            ]]
        end
        CALLBACK_CHUNK = format([[
            void *cb_store = (void *)${CB_STORE};
            std::string cb_tag = ${CB_TAG};
            std::string cb_name;
            if (${OLUA_IS_VALUE}(L, ${ARGN})) {
                cb_name = olua_setcallback(L, cb_store, cb_tag.c_str(), ${ARGN}, ${TAG_MODE});
                ${CALLBACK_CHUNK}
            } else {
                ${cbout.REMOVE_NORMAL_CALLBACK}
                ${ARG_NAME} = nullptr;
            }
        ]])
    else
        CALLBACK_CHUNK = format([[
            void *cb_store = (void *)${CB_STORE};
            std::string cb_tag = ${CB_TAG};
            std::string cb_name = olua_setcallback(L, cb_store, cb_tag.c_str(), ${ARGN}, ${TAG_MODE});
            ${CALLBACK_CHUNK}
        ]])
    end

    out.CALLBACK = CALLBACK_CHUNK
    out.REMOVE_LOCAL_CALLBACK = cbout.REMOVE_LOCAL_CALLBACK
end