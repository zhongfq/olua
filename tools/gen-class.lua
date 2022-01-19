local olua = require "olua"

local format = olua.format
local prototypes = {}
local symbols = {}

local function has_method(cls, fn, check_super)
    for _, v in ipairs(cls.funcs) do
        if v[1].luafunc == fn then
            return true
        end
    end

    if cls.supercls and check_super then
        return has_method(olua.get_class(cls.supercls), fn, check_super)
    end
end

local function check_meta_method(cls)
    local has_ctor = false
    local ti = olua.typeinfo(cls.cppcls, cls, true)
    for _, v in ipairs(cls.funcs) do
        if v[1].ctor then
            has_ctor = true
        end
    end
    if has_ctor then
        if not has_method(cls, '__gc', true) then
            cls.funcs:push(olua.parse_func(cls, '__gc', format([[
            {
                olua_postgc<${cls.cppcls}>(L, 1);
                return 0;
            }]])))
        end
    end
    if olua.is_func_type(cls) then
        cls.funcs:push(olua.parse_func(cls, '__call', format([[
        {
            luaL_checktype(L, -1, LUA_TFUNCTION);
            olua_push_callback<${cls.cppcls}>(L, nullptr);
            return 1;
        }]])))
    elseif not olua.is_enum_type(cls) and cls.reg_luatype
        and not has_method(cls, '__olua_move', false)
    then
        cls.funcs:push(olua.parse_func(cls, '__olua_move', format([[
        {
            auto self = (${cls.cppcls} *)olua_toobj(L, 1, "${cls.luacls}");
            olua_push_cppobj(L, self, "${cls.luacls}");
            return 1;
        }]])))
    end
    if olua.is_enum_type(cls) and not has_method(cls, '__index', true) then
        cls.funcs:push(olua.parse_func(cls, '__index', format([[
        {
            const char *cls = olua_checkfieldstring(L, 1, "classname");
            const char *key = olua_tostring(L, 2);
            luaL_error(L, "enum '%s.%s' not found", cls, key);
            return 0;
        }]])))
    end
end

local function check_gen_class_func(cls, fis, write)
    if #fis == 0 then
        return
    end

    local cppfunc = fis[1].cppfunc
    local fn = format([[_${{cls.cppcls}}_${cppfunc}]])
    if symbols[fn] then
        return
    end
    symbols[fn] = true

    local pts = assert(prototypes[cls.cppcls], cls.cppcls)
    if pts and getmetatable(pts) then
        local supermeta = getmetatable(pts).__index
        for _, f in ipairs(fis) do
            if not f.static and f.prototype and rawget(pts, f.prototype)
                    and supermeta[f.prototype]
                    and not f.ret.attr.using then
                print(format("${cls.cppcls}: super class already export ${f.funcdesc}"))
            end
        end
    end
    local ifdef = cls.ifdefs[cppfunc]
    write(ifdef)
    olua.gen_class_func(cls, fis, write)
    write(ifdef and '#endif' or nil)
    write('')
end

local function gen_class_funcs(cls, write)
    local pts = cls.prototypes

    if cls.supercls then
        if not prototypes[cls.supercls] then
            error(format("super class '${cls.supercls}' must be exported befor '${cls.cppcls}'"))
        end
        pts = setmetatable(pts, {__index = prototypes[cls.supercls]})
    end
    prototypes[cls.cppcls] = pts

    table.sort(cls.funcs, function (a, b)
        return a[1].luafunc < b[1].luafunc
    end)
    for _, fi in ipairs(cls.funcs) do
        check_gen_class_func(cls, fi, write)
    end

    olua.sort(cls.props, 'name')
    for _, pi in ipairs(cls.props) do
        check_gen_class_func(cls, {pi.get}, write)
        check_gen_class_func(cls, {pi.set}, write)
    end

    olua.sort(cls.vars, 'name')
    for _, ai in ipairs(cls.vars) do
        check_gen_class_func(cls, {ai.get}, write)
        check_gen_class_func(cls, {ai.set}, write)
    end
end

local function gen_class_open(cls, write)
    local funcs = olua.newarray('\n')
    local reg_luatype = ''
    local supercls = "nullptr"
    local luaopen = cls.luaopen or ''

    if cls.supercls then
        supercls = olua.stringify(olua.luacls(cls.supercls))
    end

    for _, fis in ipairs(cls.funcs) do
        local cppfunc = fis[1].cppfunc
        local luafunc = fis[1].luafunc
        local ifdef = cls.ifdefs[cppfunc]
        funcs:push(ifdef)
        funcs:pushf('oluacls_func(L, "${luafunc}", _${{cls.cppcls}}_${cppfunc});')
        funcs:push(ifdef and '#endif' or nil)
    end

    for _, pi in ipairs(cls.props) do
        local func_get = "nullptr"
        local func_set = "nullptr"
        if pi.get then
            func_get = format('_${{cls.cppcls}}_${pi.get.cppfunc}')
        end
        if pi.set then
            func_set = format('_${{cls.cppcls}}_${pi.set.cppfunc}')
        end
        funcs:pushf('oluacls_prop(L, "${pi.name}", ${func_get}, ${func_set});')
    end

    for _, vi in ipairs(cls.vars) do
        local func_get = format('_${{cls.cppcls}}_${vi.get.cppfunc}')
        local func_set = "nullptr"
        if vi.set and vi.set.cppfunc then
           func_set = format('_${{cls.cppcls}}_${vi.set.cppfunc}')
        end
        funcs:pushf('oluacls_prop(L, "${vi.name}", ${func_get}, ${func_set});')
    end

    olua.sort(cls.consts, 'name')
    for _, ci in ipairs(cls.consts) do
        local decltype = ci.type.decltype
        local value = ci.value
        local const_func
        if decltype == 'bool' then
            const_func = 'oluacls_const_bool'
        elseif decltype == 'lua_Integer' then
            const_func = 'oluacls_const_integer'
        elseif decltype == 'lua_Number' then
            const_func = 'oluacls_const_number'
        elseif decltype == 'const char *' then
            const_func = 'oluacls_const_string'
        elseif decltype == 'std::string' then
            const_func = 'oluacls_const_string'
            decltype = 'const char *'
            value = value .. '.c_str()'
        else
            error(ci.type.decltype)
        end
        funcs:pushf('${const_func}(L, "${ci.name}", (${decltype})${value});')
    end

    olua.sort(cls.enums, 'name')
    for _, ei in ipairs(cls.enums) do
        funcs:pushf('oluacls_const_integer(L, "${ei.name}", (lua_Integer)${ei.value});')
    end

    if cls.reg_luatype then
        reg_luatype = format('olua_registerluatype<${cls.cppcls}>(L, "${cls.luacls}");')
    end

    write(format([[
        static int luaopen_${{cls.cppcls}}(lua_State *L)
        {
            oluacls_class(L, "${cls.luacls}", ${supercls});
            ${funcs}

            ${reg_luatype}
            ${luaopen}

            return 1;
        }
    ]]))
end

local function gen_class_chunk(cls, write)
    if cls.chunk and #cls.chunk > 0 then
        write(format(cls.chunk))
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

    local HEADER = string.upper(module.name)

    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #ifndef __AUTO_GEN_LUA_${HEADER}_H__
        #define __AUTO_GEN_LUA_${HEADER}_H__

        ${module.headers}

        int luaopen_${module.name}(lua_State *L);
    ]]))
    write('')

    olua.gen_conv_header(module, write)

    write('#endif')

    local path = format('${module.path}/lua_${module.name}.h')
    olua.write(path, tostring(arr))
end

local function gen_include(module, write)
    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #include "lua_${module.name}.h"
    ]]))
    write('')

    if module.chunk and #module.chunk > 0 then
        write(format(module.chunk))
        write('')
    end

    olua.gen_conv_source(module, write)
end

local function gen_classes(module, write)
    for _, cls in ipairs(module.class_types) do
        cls.luacls = olua.luacls(cls.cppcls)
        local ifdef = cls.ifdefs['*']
        write(ifdef)
        check_meta_method(cls)
        gen_class_chunk(cls, write)
        gen_class_funcs(cls, write)
        gen_class_open(cls, write)
        write(ifdef and '#endif' or nil)
        write('')
    end
end

local function gen_luaopen(module, write)
    local requires = olua.newarray('\n')

    for _, cls in ipairs(module.class_types) do
        local ifdef = cls.ifdefs['*']
        requires:push(ifdef)
        requires:pushf('olua_require(L, "${cls.luacls}", luaopen_${{cls.cppcls}});')
        requires:push(ifdef and '#endif' or nil)
    end

    write(format([[
        int luaopen_${module.name}(lua_State *L)
        {
            ${requires}
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

    local path = format('${module.path}/lua_${module.name}.cpp')
    olua.write(path, tostring(arr))
end