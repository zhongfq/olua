local olua = require "olua"

local format = olua.format

local function gen_conv_header(module)
    local HEADER = string.upper(module.NAME)
    local DECL_FUNCS = olua.newarray('\n')

    for _, cv in ipairs(module.CONVS) do
        DECL_FUNCS:pushf([[
            // ${cv.CPPCLS}
            int auto_olua_push_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value);
            void auto_olua_check_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value);
            bool auto_olua_is_${cv.CPP_SYM}(lua_State *L, int idx);
            void auto_olua_pack_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value);
            int auto_olua_unpack_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value);
            bool auto_olua_ispack_${cv.CPP_SYM}(lua_State *L, int idx);
        ]])
        DECL_FUNCS:push("")
    end

    local PATH = olua.format '${module.PATH}/lua_${module.NAME}.h'
    local INCLUDES = olua.trim(module.INCLUDES)
    olua.write(PATH, format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #ifndef __AUTO_GEN_LUA_${HEADER}_H__
        #define __AUTO_GEN_LUA_${HEADER}_H__

        ${INCLUDES}

        ${DECL_FUNCS}

        #endif
    ]]))
end

local function gen_push_func(cv, write)
    local NUM_ARGS = #cv.PROPS
    local OUT = {PUSH_ARGS = olua.newarray():push('')}

    for i, pi in ipairs(cv.PROPS) do
        local ARG_NAME = format('value->${pi.NAME}')
        OUT.PUSH_ARGS:push(i > 1 and '' or nil)
        olua.gen_push_exp(pi, ARG_NAME, OUT)
        OUT.PUSH_ARGS:pushf([[olua_setfield(L, -2, "${pi.NAME}");]])
    end

    write(format([[
        int auto_olua_push_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value)
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
        OUT.CHECK_ARGS:push('')
    end

    write(format([[
        void auto_olua_check_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value)
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
        local ARG_NAME = 'arg' .. i
        olua.gen_decl_exp(pi, ARG_NAME, OUT)
        olua.gen_check_exp(pi, ARG_NAME, 'idx + ' ..  (i - 1), OUT)
        OUT.CHECK_ARGS:pushf([[
            value->${pi.NAME} = (${pi.DECLTYPE})${ARG_NAME};
        ]])
        OUT.CHECK_ARGS:push('')
    end

    write(format([[
        void auto_olua_pack_${cv.CPP_SYM}(lua_State *L, int idx, ${cv.CPPCLS} *value)
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
        local ARG_NAME = format('value->${pi.NAME}')
        olua.gen_push_exp(pi, ARG_NAME, OUT)
    end

    write(format([[
        int auto_olua_unpack_${cv.CPP_SYM}(lua_State *L, const ${cv.CPPCLS} *value)
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
        bool auto_olua_is_${cv.CPP_SYM}(lua_State *L, int idx)
        {
            return ${EXPS};
        }
    ]]))
    write('')
end

local function gen_ispack_func(cv, write)
    local EXPS = olua.newarray(' && ')
    for i, pi in ipairs(cv.PROPS) do
        local IS_VALUE = olua.convfunc(pi.TYPE, 'is')
        local VIDX = i - 1
        if olua.ispointee(pi.TYPE) then
            EXPS:pushf('${IS_VALUE}(L, idx + ${VIDX}, "${pi.TYPE.LUACLS}")')
        else
            EXPS:pushf('${IS_VALUE}(L, idx + ${VIDX})')
        end
    end
    write(format([[
        bool auto_olua_ispack_${cv.CPP_SYM}(lua_State *L, int idx)
        {
            return ${EXPS};
        }
    ]]))
    write('')
end

local function gen_funcs(cv, write)
    gen_push_func(cv, write)
    gen_check_func(cv, write)
    gen_is_func(cv, write)
    gen_pack_func(cv, write)
    gen_unpack_func(cv, write)
    gen_ispack_func(cv, write)
end

local function gen_conv_source(module)
    local arr = olua.newarray('\n')

    local function write(value)
        if value then
            arr:push(value)
        end
    end

    local INCLUDES = olua.trim(module.INCLUDES)
    arr:pushf([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #include "lua_${module.NAME}.h"
        ${INCLUDES}
    ]])
    arr:push('')

    for _, cv in ipairs(module.CONVS) do
        gen_funcs(cv, write)
    end

    local PATH = olua.format '${module.PATH}/lua_${module.NAME}.cpp'
    olua.write(PATH, tostring(arr))
end

function olua.gen_conv(module, write)
    if write then
        for _, cv in ipairs(module.CONVS) do
            gen_funcs(cv, write)
        end
    else
        gen_conv_header(module)
        gen_conv_source(module)
    end
end