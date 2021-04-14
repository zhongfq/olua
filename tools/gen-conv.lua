local olua = require "olua"

local format = olua.format

local function gen_push_func(cv, write)
    local NUM_ARGS = #cv.PROPS
    local OUT = {PUSH_ARGS = olua.newarray():push('')}

    for i, pi in ipairs(cv.PROPS) do
        OUT.PUSH_ARGS:push(i > 1 and '' or nil)
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            local SUBOUT = {PUSH_ARGS = olua.newarray()}
            olua.gen_push_exp(pi, "obj", SUBOUT)
            OUT.PUSH_ARGS:pushf([[
                lua_createtable(L, ${LENGTH}, 0);
                for (int i = 0; i < ${LENGTH}; i++) {
                    ${pi.TYPE.CPPCLS} obj = value->${pi.NAME}[i];
                    ${SUBOUT.PUSH_ARGS}
                    olua_rawseti(L, -2, i + 1);
                }
            ]])
        else
            local ARG_NAME = format('value->${pi.NAME}')
            olua.gen_push_exp(pi, ARG_NAME, OUT)
        end
        OUT.PUSH_ARGS:pushf([[olua_setfield(L, -2, "${pi.NAME}");]])
    end

    write(format([[
        int olua_push_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value)
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
    write('')
end

local function gen_check_func(cv, write)
    local OUT = {
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
    }
    for i, pi in ipairs(cv.PROPS) do
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            local SUBOUT = {DECL_ARGS = olua.newarray(), CHECK_ARGS = olua.newarray()}
            olua.gen_decl_exp(pi, "obj", SUBOUT)
            olua.gen_check_exp(pi, "obj", -1, SUBOUT)
            OUT.CHECK_ARGS:pushf([[
                if (olua_getfield(L, idx, "${pi.NAME}") != LUA_TTABLE) {
                    luaL_error(L, "field '${pi.NAME}' is not a table");
                }
                for (int i = 0; i < ${LENGTH}; i++) {
                    ${SUBOUT.DECL_ARGS}
                    olua_rawgeti(L, -1, i + 1);
                    if (!olua_isnoneornil(L, -1)) {
                        ${SUBOUT.CHECK_ARGS}
                    }
                    value->${pi.NAME}[i] = obj;
                    lua_pop(L, 1);
                }
                lua_pop(L, 1);
            ]])
        else
            local ARG_NAME = 'arg' .. i
            olua.gen_decl_exp(pi, ARG_NAME, OUT)
            OUT.CHECK_ARGS:pushf([[olua_getfield(L, idx, "${pi.NAME}");]])
            if pi.ATTR.OPTIONAL then
                local SUBOUT = {CHECK_ARGS = olua.newarray()}
                olua.gen_check_exp(pi, ARG_NAME, -1, SUBOUT)
                OUT.CHECK_ARGS:pushf([[
                    if (!olua_isnoneornil(L, -1)) {
                        ${SUBOUT.CHECK_ARGS}
                        value->${pi.NAME} = (${pi.DECLTYPE})${ARG_NAME};
                    }
                    lua_pop(L, 1);
                ]])
            else
                olua.gen_check_exp(pi, ARG_NAME, -1, OUT)
                OUT.CHECK_ARGS:pushf([[
                    value->${pi.NAME} = (${pi.DECLTYPE})${ARG_NAME};
                    lua_pop(L, 1);
                ]])
            end
        end
        OUT.CHECK_ARGS:push('')
    end

    write(format([[
        void olua_check_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value)
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
    write('')
end

local function gen_pack_func(cv, write)
    local OUT = {
        DECL_ARGS = olua.newarray(),
        CHECK_ARGS = olua.newarray(),
    }
    for i, pi in ipairs(cv.PROPS) do
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
            value->${pi.NAME} = (${pi.DECLTYPE})${ARG_NAME};
        ]])
        OUT.CHECK_ARGS:push('')
    end

    write(format([[
        void olua_pack_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value)
        {
            if (!value) {
                luaL_error(L, "value is NULL");
            }
            idx = lua_absindex(L, idx);

            ${OUT.DECL_ARGS}

            ${OUT.CHECK_ARGS}
        }
    ]]))
    write('')
end

local function gen_unpack_func(cv, write)
    local NUM_ARGS = #cv.PROPS
    local OUT = {PUSH_ARGS = olua.newarray():push('')}
    for _, pi in ipairs(cv.PROPS) do
        local LENGTH = (pi.ATTR.ARRAY or {})[1]
        if LENGTH then
            OUT.PUSH_ARGS:clear()
            OUT.PUSH_ARGS:pushf([[luaL_error(L, "${cv.CPPCLS} not support 'unpack'");]])
            break
        end

        local ARG_NAME = format('value->${pi.NAME}')
        olua.gen_push_exp(pi, ARG_NAME, OUT)
    end

    write(format([[
        int olua_unpack_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value)
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
    write('')
end

local function gen_is_func(cv, write)
    local EXPS = olua.newarray(' && ')
    EXPS:push('olua_istable(L, idx)')
    for i = #cv.PROPS, 1, -1 do
        local pi = cv.PROPS[i]
        if not pi.ATTR.OPTIONAL then
            EXPS:pushf('olua_hasfield(L, idx, "${pi.NAME}")')
        end
    end
    write(format([[
        bool olua_is_${cv.CPP_SYM}(lua_State *L, int idx)
        {
            return ${EXPS};
        }
    ]]))
    write('')
end

local function gen_ispack_func(cv, write)
    local EXPS = olua.newarray(' && ')
    for i, pi in ipairs(cv.PROPS) do
        local IS_VALUE = olua.conv_func(pi.TYPE, 'is')
        local VIDX = i - 1
        if olua.is_pointer_type(pi.TYPE) then
            EXPS:pushf('${IS_VALUE}(L, idx + ${VIDX}, "${pi.TYPE.LUACLS}")')
        else
            EXPS:pushf('${IS_VALUE}(L, idx + ${VIDX})')
        end
    end
    write(format([[
        bool olua_ispack_${cv.CPP_SYM}(lua_State *L, int idx)
        {
            return ${EXPS};
        }
    ]]))
    write('')
end

function olua.gen_conv_header(module, write)
    for _, cv in ipairs(module.CONVS) do
        write(format([[
            // ${cv.CPPCLS}
            int olua_push_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value);
            void olua_check_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value);
            bool olua_is_${cv.CPP_SYM}(lua_State *L, int idx);
            void olua_pack_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value);
            int olua_unpack_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value);
            bool olua_ispack_${cv.CPP_SYM}(lua_State *L, int idx);
        ]]))
        write("")
    end

    for _, cls in ipairs(module.CLASSES) do
        local ti = olua.typeinfo(cls.CPPCLS, nil, true)
        if olua.is_func_type(cls) then
            local IFDEF = cls.IFDEFS['*']
            write(IFDEF)
            write(format([[
                // ${cls.CPPCLS}
                bool olua_is_${cls.CPP_SYM}(lua_State *L, int idx);
                int olua_push_${cls.CPP_SYM}(lua_State *L, const ${cls.CPPCLS} *value);
                void olua_check_${cls.CPP_SYM}(lua_State *L, int idx, ${cls.CPPCLS} *value);
            ]]))
            write(IFDEF and '#endif' or nil)
            write("")
        end
    end
end

local function gen_cb_is_func(cls, write)
    local LUACLS = olua.luacls(cls.CPPCLS)
    write(format([[
        bool olua_is_${cls.CPP_SYM}(lua_State *L, int idx)
        {
            if (olua_isfunction(L, idx)) {
                return true;
            }
            if (olua_istable(L, idx)) {
                const char *cls = olua_optfieldstring(L, idx, "classname", NULL);
                return cls && strcmp(cls, "${LUACLS}") == 0;
            }
            return false;
        }
    ]]))
end

local function gen_cb_push_func(cls, write)
    local LUACLS = olua.luacls(cls.CPPCLS)
    write(format([[
        int olua_push_${cls.CPP_SYM}(lua_State *L, const ${cls.CPPCLS} *value)
        {
            if (!(olua_isfunction(L, -1) || olua_isnil(L, -1))) {
                luaL_error(L, "execpt 'function' or 'nil'");
            }
            return 1;
        }
    ]]))
end

local function gen_cb_check_func(cls, write)
    local LUACLS = olua.luacls(cls.CPPCLS)
    write(format([[
        void olua_check_${cls.CPP_SYM}(lua_State *L, int idx, ${cls.CPPCLS} *value)
        {
            if (olua_istable(L, idx)) {
                olua_rawgetf(L, idx, "callback");
                lua_replace(L, idx);
            }
        }
    ]]))
end

function olua.gen_conv_source(module, write)
    for _, cv in ipairs(module.CONVS) do
        gen_push_func(cv, write)
        gen_check_func(cv, write)
        gen_is_func(cv, write)
        gen_pack_func(cv, write)
        gen_unpack_func(cv, write)
        gen_ispack_func(cv, write)
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