local olua = require "olua"

local format = olua.format

local function gen_push_func(cv, write)
    local NUM_ARGS = #cv.VARS
    local OUT = {PUSH_ARGS = olua.newarray():push('')}

    for i, var in ipairs(cv.VARS) do
        local pi = var.SET.ARGS[1]
        OUT.PUSH_ARGS:push(i > 1 and '' or nil)
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            local SUBOUT = {PUSH_ARGS = olua.newarray()}
            olua.gen_push_exp(pi, "obj", SUBOUT)
            OUT.PUSH_ARGS:pushf([[
                lua_createtable(L, ${LENGTH}, 0);
                for (int i = 0; i < ${LENGTH}; i++) {
                    ${pi.TYPE.CPPCLS} obj = value->${pi.VAR_NAME}[i];
                    ${SUBOUT.PUSH_ARGS}
                    olua_rawseti(L, -2, i + 1);
                }
            ]])
        else
            local ARG_NAME = format('value->${pi.VAR_NAME}')
            olua.gen_push_exp(pi, ARG_NAME, OUT)
        end
        OUT.PUSH_ARGS:pushf([[olua_setfield(L, -2, "${pi.VAR_NAME}");]])
    end

    write(format([[
        int olua_push_${{cv.CPPCLS}}(lua_State *L, const ${cv.CPPCLS} *value)
        {
            if (value) {
                lua_createtable(L, 0, ${NUM_ARGS});
                ${OUT.PUSH_ARGS}
            } else {
                lua_pushnil(L);
            }

            return 1;
        }
    ]]))
end

local function gen_check_func(cv, write)
    local OUT = {
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
    }
    for i, var in ipairs(cv.VARS) do
        local pi = var.SET.ARGS[1]
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            local SUBOUT = {DECL_ARGS = olua.newarray(), CHECK_ARGS = olua.newarray()}
            olua.gen_decl_exp(pi, "obj", SUBOUT)
            olua.gen_check_exp(pi, "obj", -1, SUBOUT)
            OUT.CHECK_ARGS:pushf([[
                if (olua_getfield(L, idx, "${pi.VAR_NAME}") != LUA_TTABLE) {
                    luaL_error(L, "field '${pi.VAR_NAME}' is not a table");
                }
                for (int i = 0; i < ${LENGTH}; i++) {
                    ${SUBOUT.DECL_ARGS}
                    olua_rawgeti(L, -1, i + 1);
                    if (!olua_isnoneornil(L, -1)) {
                        ${SUBOUT.CHECK_ARGS}
                    }
                    value->${pi.VAR_NAME}[i] = obj;
                    lua_pop(L, 1);
                }
                lua_pop(L, 1);
            ]])
        else
            local ARG_NAME = 'arg' .. i
            olua.gen_decl_exp(pi, ARG_NAME, OUT)
            OUT.CHECK_ARGS:pushf([[olua_getfield(L, idx, "${pi.VAR_NAME}");]])
            if pi.ATTR.OPTIONAL then
                local SUBOUT = {CHECK_ARGS = olua.newarray()}
                olua.gen_check_exp(pi, ARG_NAME, -1, SUBOUT)
                OUT.CHECK_ARGS:pushf([[
                    if (!olua_isnoneornil(L, -1)) {
                        ${SUBOUT.CHECK_ARGS}
                        value->${pi.VAR_NAME} = (${pi.DECLTYPE})${ARG_NAME};
                    }
                    lua_pop(L, 1);
                ]])
            else
                olua.gen_check_exp(pi, ARG_NAME, -1, OUT)
                OUT.CHECK_ARGS:pushf([[
                    value->${pi.VAR_NAME} = (${pi.DECLTYPE})${ARG_NAME};
                    lua_pop(L, 1);
                ]])
            end
        end
        OUT.CHECK_ARGS:push('')
    end

    write(format([[
        void olua_check_${{cv.CPPCLS}}(lua_State *L, int idx, ${cv.CPPCLS} *value)
        {
            if (!value) {
                luaL_error(L, "value is NULL");
            }
            idx = lua_absindex(L, idx);
            luaL_checktype(L, idx, LUA_TTABLE);

            ${OUT.DECL_ARGS}

            ${OUT.CHECK_ARGS}
        }
    ]]))
end

local function gen_pack_func(cv, write)
    local OUT = {
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
    }
    for i, var in ipairs(cv.VARS) do
        local pi = var.SET.ARGS[1]
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            OUT.DECL_ARGS:clear()
            OUT.CHECK_ARGS:clear()
            OUT.CHECK_ARGS:pushf([[luaL_error(L, "${cv.CPPCLS} not support 'pack'");]])
            break
        end

        local ARG_NAME = 'arg' .. i
        olua.gen_decl_exp(pi, ARG_NAME, OUT)
        olua.gen_check_exp(pi, ARG_NAME, 'idx + ' ..  (i - 1), OUT)
        OUT.CHECK_ARGS:pushf([[
            value->${pi.VAR_NAME} = (${pi.DECLTYPE})${ARG_NAME};
        ]])
        OUT.CHECK_ARGS:push('')
    end

    write(format([[
        void olua_pack_${{cv.CPPCLS}}(lua_State *L, int idx, ${cv.CPPCLS} *value)
        {
            if (!value) {
                luaL_error(L, "value is NULL");
            }
            idx = lua_absindex(L, idx);

            ${OUT.DECL_ARGS}

            ${OUT.CHECK_ARGS}
        }
    ]]))
end

local function gen_unpack_func(cv, write)
    local NUM_ARGS = #cv.VARS
    local OUT = {PUSH_ARGS = olua.newarray():push('')}
    for _, var in ipairs(cv.VARS) do
        local pi = var.SET.ARGS[1]
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            OUT.PUSH_ARGS:clear()
            OUT.PUSH_ARGS:pushf([[luaL_error(L, "${cv.CPPCLS} not support 'unpack'");]])
            break
        end

        local ARG_NAME = format('value->${pi.VAR_NAME}')
        olua.gen_push_exp(pi, ARG_NAME, OUT)
    end

    write(format([[
        int olua_unpack_${{cv.CPPCLS}}(lua_State *L, const ${cv.CPPCLS} *value)
        {
            if (value) {
                ${OUT.PUSH_ARGS}
            } else {
                for (int i = 0; i < ${NUM_ARGS}; i++) {
                    lua_pushnil(L);
                }
            }
            
            return ${NUM_ARGS};
        }
    ]]))
end

local function gen_is_func(cv, write)
    local EXPS = olua.newarray(' && ')
    EXPS:push('olua_istable(L, idx)')
    for i = #cv.VARS, 1, -1 do
        local var = cv.VARS[i]
        local pi = var.SET.ARGS[1]
        if not pi.ATTR.OPTIONAL then
            EXPS:pushf('olua_hasfield(L, idx, "${pi.VAR_NAME}")')
        end
    end
    write(format([[
        bool olua_is_${{cv.CPPCLS}}(lua_State *L, int idx)
        {
            return ${EXPS};
        }
    ]]))
end

local function gen_canpack_func(cv, write)
    local EXPS = olua.newarray(' && ')
    for i, var in ipairs(cv.VARS) do
        local pi = var.SET.ARGS[1]
        local ISFUNC = olua.conv_func(pi.TYPE, 'is')
        local N = i - 1
        if olua.is_pointer_type(pi.TYPE) then
            EXPS:pushf('${ISFUNC}(L, idx + ${N}, "${pi.TYPE.LUACLS}")')
        else
            EXPS:pushf('${ISFUNC}(L, idx + ${N})')
        end
    end
    write(format([[
        bool olua_canpack_${{cv.CPPCLS}}(lua_State *L, int idx)
        {
            return ${EXPS};
        }
    ]]))
end

function olua.gen_conv_header(module, write)
    for _, cv in ipairs(module.CONVS) do
        local IFDEF = cv.IFDEF
        write(IFDEF)
        write(format([[
            // ${cv.CPPCLS}
            int olua_push_${{cv.CPPCLS}}(lua_State *L, const ${cv.CPPCLS} *value);
            void olua_check_${{cv.CPPCLS}}(lua_State *L, int idx, ${cv.CPPCLS} *value);
            bool olua_is_${{cv.CPPCLS}}(lua_State *L, int idx);
            void olua_pack_${{cv.CPPCLS}}(lua_State *L, int idx, ${cv.CPPCLS} *value);
            int olua_unpack_${{cv.CPPCLS}}(lua_State *L, const ${cv.CPPCLS} *value);
            bool olua_canpack_${{cv.CPPCLS}}(lua_State *L, int idx);
        ]]))
        write(IFDEF and '#endif' or nil)
        write("")
    end

    for _, cls in ipairs(module.CLASSES) do
        local ti = olua.typeinfo(cls.CPPCLS, nil, true)
        if olua.is_func_type(cls) then
            local IFDEF = cls.IFDEFS['*']
            write(IFDEF)
            write(format([[
                // ${cls.CPPCLS}
                bool olua_is_${{cls.CPPCLS}}(lua_State *L, int idx);
                int olua_push_${{cls.CPPCLS}}(lua_State *L, const ${cls.CPPCLS} *value);
                void olua_check_${{cls.CPPCLS}}(lua_State *L, int idx, ${cls.CPPCLS} *value);
            ]]))
            write(IFDEF and '#endif' or nil)
            write("")
        end
    end
end

local function gen_cb_is_func(cls, write)
    write(format([[
        bool olua_is_${{cls.CPPCLS}}(lua_State *L, int idx)
        {
            return olua_is_callback<${cls.CPPCLS}>(L, idx);
        }
    ]]))
end

local function gen_cb_push_func(cls, write)
    write(format([[
        int olua_push_${{cls.CPPCLS}}(lua_State *L, const ${cls.CPPCLS} *value)
        {
            return olua_push_callback<${cls.CPPCLS}>(L, value);
        }
    ]]))
end

local function gen_cb_check_func(cls, write)
    write(format([[
        void olua_check_${{cls.CPPCLS}}(lua_State *L, int idx, ${cls.CPPCLS} *value)
        {
            olua_check_callback<${cls.CPPCLS}>(L, idx, value);
        }
    ]]))
end

function olua.gen_conv_source(module, write)
    for _, cv in ipairs(module.CONVS) do
        local IFDEF = cv.IFDEF
        write(IFDEF)
        gen_push_func(cv, write)
        write('')
        gen_check_func(cv, write)
        write('')
        gen_is_func(cv, write)
        write('')
        gen_pack_func(cv, write)
        write('')
        gen_unpack_func(cv, write)
        write('')
        gen_canpack_func(cv, write)
        write(IFDEF and '#endif' or nil)
        write('')
    end

    for _, cls in ipairs(module.CLASSES) do
        local ti = olua.typeinfo(cls.CPPCLS, nil, true)
        if olua.is_func_type(cls) then
            local IFDEF = cls.IFDEFS['*']
            write(IFDEF)
            gen_cb_is_func(cls, write)
            write('')
            gen_cb_push_func(cls, write)
            write('')
            gen_cb_check_func(cls, write)
            write(IFDEF and '#endif' or nil)
            write('')
        end
    end
end