local olua = require "olua"

local format = olua.format
local prototypes = {}
local symbols = {}

local function has_gc_method(cls)
    for _, v in ipairs(cls.FUNCS) do
        if v[1].LUA_FUNC == '__gc' then
            return true
        end
    end

    if cls.SUPERCLS then
        return has_gc_method(olua.get_class(cls.SUPERCLS))
    end
end

local function check_meta_method(cls)
    local has_ctor = false
    local has_move = false
    local ti = olua.typeinfo(cls.CPPCLS, cls, true)
    for _, v in ipairs(cls.FUNCS) do
        if v[1].CTOR then
            has_ctor = true
        end
        if v[1].LUA_FUNC == '__move' then
            has_move = true
        end
    end
    if has_ctor then
        if not has_gc_method(cls) then
            cls.func('__gc', format([[
            {
                olua_postgc<${cls.CPPCLS}>(L, 1);
                return 0;
            }]]))
        end
    end
    if olua.is_func_type(cls) then
        cls.func('__call', format([[
            {
                luaL_checktype(L, -1, LUA_TFUNCTION);
                olua_push_callback<${cls.CPPCLS}>(L, nullptr);
                return 1;
            }]]
        ))
    elseif not olua.is_enum_type(cls) and cls.REG_LUATYPE and not has_move then
        cls.func('__move', format([[
            {
                auto self = (${cls.CPPCLS} *)olua_toobj(L, 1, "${cls.LUACLS}");
                olua_push_cppobj(L, self, "${cls.LUACLS}");
                return 1;
            }
        ]]))
    end
end

local function check_gen_class_func(cls, fis, write)
    if #fis == 0 then
        return
    end

    local CPP_FUNC = fis[1].CPP_FUNC
    local fn = format([[_${cls.CPP_SYM}_${CPP_FUNC}]])
    if symbols[fn] then
        return
    end
    symbols[fn] = true

    local pts = assert(prototypes[cls.CPPCLS], cls.CPPCLS)
    if pts and getmetatable(pts) then
        local supermeta = getmetatable(pts).__index
        for _, f in ipairs(fis) do
            if not f.STATIC and f.PROTOTYPE and rawget(pts, f.PROTOTYPE)
                    and supermeta[f.PROTOTYPE]
                    and not f.RET.ATTR.USING then
                print(format("${cls.CPPCLS}: super class already export ${f.FUNC_DESC}"))
            end
        end
    end
    local IFDEF = cls.IFDEFS[CPP_FUNC]
    write(IFDEF)
    olua.gen_class_func(cls, fis, write)
    write(IFDEF and '#endif' or nil)
    write('')
end

local function gen_class_funcs(cls, write)
    local pts = cls.PROTOTYPES

    if cls.SUPERCLS then
        if not prototypes[cls.SUPERCLS] then
            error(format("super class '${cls.SUPERCLS}' must be exported befor '${cls.CPPCLS}'"))
        end
        pts = setmetatable(pts, {__index = prototypes[cls.SUPERCLS]})
    end
    prototypes[cls.CPPCLS] = pts

    table.sort(cls.FUNCS, function (a, b)
        return a[1].LUA_FUNC < b[1].LUA_FUNC
    end)
    for _, fi in ipairs(cls.FUNCS) do
        check_gen_class_func(cls, fi, write)
    end

    olua.sort(cls.PROPS, 'NAME')
    for _, pi in ipairs(cls.PROPS) do
        check_gen_class_func(cls, {pi.GET}, write)
        check_gen_class_func(cls, {pi.SET}, write)
    end

    olua.sort(cls.VARS, 'NAME')
    for _, ai in ipairs(cls.VARS) do
        check_gen_class_func(cls, {ai.GET}, write)
        check_gen_class_func(cls, {ai.SET}, write)
    end
end

local function gen_class_open(cls, write)
    local FUNCS = olua.newarray('\n')
    local REG_LUATYPE = ''
    local SUPRECLS = "nullptr"
    local REQUIRE = cls.REQUIRE or ''

    if cls.SUPERCLS then
        SUPRECLS = olua.stringify(olua.luacls(cls.SUPERCLS))
    end

    for _, fis in ipairs(cls.FUNCS) do
        local CPP_FUNC = fis[1].CPP_FUNC
        local LUA_FUNC = fis[1].LUA_FUNC
        local IFDEF = cls.IFDEFS[CPP_FUNC]
        FUNCS:push(IFDEF)
        FUNCS:pushf('oluacls_func(L, "${LUA_FUNC}", _${cls.CPP_SYM}_${CPP_FUNC});')
        FUNCS:push(IFDEF and '#endif' or nil)
    end

    for _, pi in ipairs(cls.PROPS) do
        local FUNC_GET = "nullptr"
        local FUNC_SET = "nullptr"
        if pi.GET then
            FUNC_GET = format('_${cls.CPP_SYM}_${pi.GET.CPP_FUNC}')
        end
        if pi.SET then
            FUNC_SET = format('_${cls.CPP_SYM}_${pi.SET.CPP_FUNC}')
        end
        FUNCS:pushf('oluacls_prop(L, "${pi.NAME}", ${FUNC_GET}, ${FUNC_SET});')
    end

    for _, vi in ipairs(cls.VARS) do
        local FUNC_GET = format('_${cls.CPP_SYM}_${vi.GET.CPP_FUNC}')
        local FUNC_SET = "nullptr"
        if vi.SET and vi.SET.CPP_FUNC then
           FUNC_SET = format('_${cls.CPP_SYM}_${vi.SET.CPP_FUNC}')
        end
        FUNCS:pushf('oluacls_prop(L, "${vi.NAME}", ${FUNC_GET}, ${FUNC_SET});')
    end

    olua.sort(cls.CONSTS, 'NAME')
    for _, ci in ipairs(cls.CONSTS) do
        local DECLTYPE = ci.TYPE.DECLTYPE
        local VALUE = ci.VALUE
        local FUNC
        if DECLTYPE == 'bool' then
            FUNC = 'oluacls_const_bool'
        elseif DECLTYPE == 'lua_Integer' then
            FUNC = 'oluacls_const_integer'
        elseif DECLTYPE == 'lua_Number' then
            FUNC = 'oluacls_const_number'
        elseif DECLTYPE == 'const char *' then
            FUNC = 'oluacls_const_string'
        elseif DECLTYPE == 'std::string' then
            FUNC = 'oluacls_const_string'
            DECLTYPE = 'const char *'
            VALUE = VALUE .. '.c_str()'
        else
            error(ci.TYPE.DECLTYPE)
        end
        FUNCS:pushf('${FUNC}(L, "${ci.NAME}", (${DECLTYPE})${VALUE});')
    end

    olua.sort(cls.ENUMS, 'NAME')
    for _, ei in ipairs(cls.ENUMS) do
        FUNCS:pushf('oluacls_const_integer(L, "${ei.NAME}", (lua_Integer)${ei.VALUE});')
    end

    if cls.REG_LUATYPE then
        REG_LUATYPE = format('olua_registerluatype<${cls.CPPCLS}>(L, "${cls.LUACLS}");')
    end

    write(format([[
        static int luaopen_${cls.CPP_SYM}(lua_State *L)
        {
            oluacls_class(L, "${cls.LUACLS}", ${SUPRECLS});
            ${FUNCS}

            ${REG_LUATYPE}
            ${REQUIRE}

            return 1;
        }
    ]]))
end

local function gen_class_chunk(cls, write)
    if cls.CHUNK and #cls.CHUNK > 0 then
        write(format(cls.CHUNK))
        write('')
    end
end

function olua.gen_header(module)
    local arr = olua.newarray('\n')
    local function write(value)
        if value then
            -- '   #if' => '#if'
            arr:push(value:gsub('\n *#', '\n#'))
        end
    end

    local HEADER = string.upper(module.NAME)

    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #ifndef __AUTO_GEN_LUA_${HEADER}_H__
        #define __AUTO_GEN_LUA_${HEADER}_H__

        ${module.INCLUDES}

        int luaopen_${module.NAME}(lua_State *L);
    ]]))
    write('')

    olua.gen_conv_header(module, write)

    write('#endif')

    local PATH = format('${module.PATH}/lua_${module.NAME}.h')
    olua.write(PATH, tostring(arr))
end

local function gen_include(module, write)
    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #include "lua_${module.NAME}.h"
    ]]))
    write('')

    if module.CHUNK and #module.CHUNK > 0 then
        write(format(module.CHUNK))
        write('')
    end

    olua.gen_conv_source(module, write)
end

local function gen_classes(module, write)
    for _, cls in ipairs(module.CLASSES) do
        cls.LUACLS = olua.luacls(cls.CPPCLS)
        local IFDEF = cls.IFDEFS['*']
        write(IFDEF)
        check_meta_method(cls)
        gen_class_chunk(cls, write)
        gen_class_funcs(cls, write)
        gen_class_open(cls, write)
        write(IFDEF and '#endif' or nil)
        write('')
    end
end

local function gen_luaopen(module, write)
    local REQUIRES = olua.newarray('\n')

    for _, cls in ipairs(module.CLASSES) do
        local IFDEF = cls.IFDEFS['*']
        REQUIRES:push(IFDEF)
        REQUIRES:pushf('olua_require(L, "${cls.LUACLS}", luaopen_${cls.CPP_SYM});')
        REQUIRES:push(IFDEF and '#endif' or nil)
    end

    write(format([[
        int luaopen_${module.NAME}(lua_State *L)
        {
            ${REQUIRES}
            return 0;
        }
    ]]))
    write('')
end

function olua.gen_source(module)
    local arr = olua.newarray('\n')
    local function append(value)
        if value then
            -- '   #if' => '#if'
            arr:push(value:gsub('\n *#', '\n#'))
        end
    end

    gen_include(module, append)
    gen_classes(module, append)
    gen_luaopen(module, append)

    local PATH = format('${module.PATH}/lua_${module.NAME}.cpp')
    olua.write(PATH, tostring(arr))
end