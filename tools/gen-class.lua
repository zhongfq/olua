local olua = require "olua"

local format = olua.format
local prototypes = {}

local function has_gc_method(cls)
    for _, v in ipairs(cls.FUNCS) do
        if v[1].LUAFUNC == '__gc' then
            return true
        end
    end

    if cls.SUPERCLS then
        return has_gc_method(olua.getclass(cls.SUPERCLS))
    end
end

local function check_gc_method(cls)
    local has_constructor = false
    local has_move = false
    for _, v in ipairs(cls.FUNCS) do
        if v[1].CTOR then
            has_constructor = true
        end
        if v[1].LUAFUNC == '__move' then
            has_move = true
        end
    end
    if has_constructor then
        if not has_gc_method(cls) then
            cls.func('__gc', format([[
            {
                auto self = (${cls.CPPCLS} *)olua_toobj(L, 1, "${cls.LUACLS}");
                lua_pushstring(L, ".ownership");
                olua_getvariable(L, 1);
                if (lua_toboolean(L, -1)) {
                    olua_setrawobj(L, 1, nullptr);
                    delete self;
                }
                return 0;
            }]]))
        end
    end
    if cls.REG_LUATYPE and not has_move and not olua.isenum(cls) then
        cls.func('__move', format([[
            {
                auto self = (${cls.CPPCLS} *)olua_toobj(L, 1, "${cls.LUACLS}");
                olua_push_cppobj(L, self, "${cls.LUACLS}");
                return 1;
            }
        ]]))
    end
end

local function check_gen_class_func(cls, fis, write, exported)
    if #fis == 0 then
        return
    end
    local pts = assert(prototypes[cls.CPPCLS], cls.CPPCLS)
    if pts and getmetatable(pts) then
        local supermeta = getmetatable(pts).__index
        for _, f in ipairs(fis) do
            if not f.STATIC and f.PROTOTYPE and rawget(pts, f.PROTOTYPE)
                    and supermeta[f.PROTOTYPE] then
                print(format("super class already export: ${cls.CPPCLS}::${f.PROTOTYPE}"))
            end
        end
    end
    olua.gen_class_func(cls, fis, write, exported)
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

    local exported = {}
    table.sort(cls.FUNCS, function (a, b)
        return a[1].LUAFUNC < b[1].LUAFUNC
    end)
    for _, fi in ipairs(cls.FUNCS) do
        check_gen_class_func(cls, fi, write, exported)
    end

    olua.sort(cls.PROPS, 'NAME')
    for _, pi in ipairs(cls.PROPS) do
        check_gen_class_func(cls, {pi.GET}, write, exported)
        check_gen_class_func(cls, {pi.SET}, write, exported)
    end

    olua.sort(cls.VARS, 'NAME')
    for _, ai in ipairs(cls.VARS) do
        check_gen_class_func(cls, {ai.GET}, write, exported)
        check_gen_class_func(cls, {ai.SET}, write, exported)
    end
end

local function gen_class_open(cls, write)
    local FUNCS = olua.newarray('\n')
    local REG_LUATYPE = ''
    local SUPRECLS = "nullptr"
    local exported = {}

    if cls.SUPERCLS then
        SUPRECLS = olua.stringify(olua.toluacls(cls.SUPERCLS))
    end

    for _, fis in ipairs(cls.FUNCS) do
        local CPPFUNC = fis[1].CPPFUNC
        local LUAFUNC = fis[1].LUAFUNC
        if exported[LUAFUNC] then
            error(format([[duplicate method: ${cls.CPPCLS}:${LUAFUNC}]]))
        end
        exported[LUAFUNC] = true
        FUNCS:pushf('oluacls_func(L, "${LUAFUNC}", _${cls.CPPNAME}_${CPPFUNC});')
    end

    for _, pi in ipairs(cls.PROPS) do
        local FUNC_GET = "nullptr"
        local FUNC_SET = "nullptr"
        if pi.GET then
            FUNC_GET = format('_${cls.CPPNAME}_${pi.GET.CPPFUNC}')
        end
        if pi.SET then
            FUNC_SET = format('_${cls.CPPNAME}_${pi.SET.CPPFUNC}')
        end
        FUNCS:pushf('oluacls_prop(L, "${pi.NAME}", ${FUNC_GET}, ${FUNC_SET});')
    end

    for _, vi in ipairs(cls.VARS) do
        local FUNC_GET = format('_${cls.CPPNAME}_${vi.GET.CPPFUNC}')
        local FUNC_SET = "nullptr"
        if vi.SET and vi.SET.CPPFUNC then
           FUNC_SET = format('_${cls.CPPNAME}_${vi.SET.CPPFUNC}')
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
        static int luaopen_${cls.CPPNAME}(lua_State *L)
        {
            oluacls_class(L, "${cls.LUACLS}", ${SUPRECLS});
            ${FUNCS}

            ${REG_LUATYPE}

            return 1;
        }
    ]]))
end

local function gen_class_chunk(cls, write)
    if cls.CHUNK then
        write(format(cls.CHUNK))
        write('')
    end
end

function olua.gen_header(module)
    local HEADER = string.upper(module.NAME)
    local PATH = olua.format('${module.PATH}/lua_${module.NAME}.h')
    olua.write(PATH, format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #ifndef __AUTO_GEN_LUA_${HEADER}_H__
        #define __AUTO_GEN_LUA_${HEADER}_H__

        #include "xgame/xlua.h"

        LUALIB_API int luaopen_${module.NAME}(lua_State *L);

        #endif
    ]]))
end

local function gen_include(module, write)
    local CHUNK = module.CHUNK
    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        ${module.INCLUDES}
    ]]))
    write('')

    if CHUNK then
        write(format(CHUNK))
        write('')
    end

    if module.CONVS then
        olua.gen_conv(module, write)
    end
end

local function gen_classes(module, write)
    for _, cls in ipairs(module.CLASSES) do
        cls.LUACLS = olua.toluacls(cls.CPPCLS)
        write(cls.DEFIF)
        check_gc_method(cls)
        gen_class_chunk(cls, write)
        gen_class_funcs(cls, write)
        gen_class_open(cls, write)
        write(cls.DEFIF and '#endif' or nil)
        write('')
    end
end

local function gen_luaopen(module, write)
    local REQUIRES = olua.newarray('\n')

    for _, cls in ipairs(module.CLASSES) do
        REQUIRES:push(cls.DEFIF)
        REQUIRES:pushf('olua_require(L, "${cls.LUACLS}", luaopen_${cls.CPPNAME});')
        REQUIRES:push(cls.DEFIF and '#endif' or nil)
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