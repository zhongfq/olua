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
    if olua.is_func_type(cls) then
        cls.funcs:push(olua.parse_func(cls, '__call', format([[
        {
            luaL_checktype(L, -1, LUA_TFUNCTION);
            olua_push_callback(L, (${cls.cppcls} *)nullptr, "${cls.luacls}");
            return 1;
        }]])))
    elseif not olua.is_enum_type(cls) and cls.options.reg_luatype then
        if not cls.options.disallow_gc and not has_method(cls, '__gc', true) then
            cls.funcs:push(olua.parse_func(cls, '__gc', format([[
            {
                auto self = (${cls.cppcls} *)olua_toobj(L, 1, "${cls.luacls}");
                olua_postgc(L, self);
                return 0;
            }]])))
        end
        if not has_method(cls, '__olua_move', true) then
            cls.funcs:push(olua.parse_func(cls, '__olua_move', format([[
            {
                auto self = (${cls.cppcls} *)olua_toobj(L, 1, "${cls.luacls}");
                olua_push_object(L, self, "${cls.luacls}");
                return 1;
            }]])))
        end
        if cls.options.packable and not cls.options.packvars then
            local codeset = {decl_args = olua.newarray(), check_args = olua.newarray()}
            olua.gen_class_fill(cls, 2, 'ret', codeset)

            cls.funcs:push(olua.parse_func(cls, '__call', format([[
            {
                ${cls.cppcls} ret;

                luaL_checktype(L, 2, LUA_TTABLE);

                ${codeset.decl_args}

                ${codeset.check_args}

                olua_pushcopy_object(L, ret, "${cls.luacls}");
                return 1;
            }]])))
        end
    end
end

local function check_gen_class_func(cls, fis, write)
    if #fis == 0 then
        return
    end

    local cppfunc = fis[1].cppfunc
    local fn = format([[_${cls.cppcls#}_${cppfunc}]])
    if symbols[fn] then
        return
    end
    symbols[fn] = true

    local pts = assert(prototypes[cls.cppcls], cls.cppcls)
    if pts and getmetatable(pts) then
        local supermeta = getmetatable(pts).__index
        for _, f in ipairs(fis) do
            if not f.static
                and f.prototype
                and f.cppfunc ~= 'as'
                and rawget(pts, f.prototype)
                and supermeta[f.prototype]
                and not f.ret.attr.using
            then
                print(format("${cls.cppcls}: super class already export ${f.funcdesc}"))
            end
        end
    end
    local macro = cls.macros[cppfunc]
    write(macro)
    olua.gen_class_func(cls, fis, write)
    write(macro and '#endif' or nil)
    write('')
end

local function gen_class_funcs(cls, write)
    local pts = cls.prototypes

    if cls.supercls then
        if not prototypes[cls.supercls] then
            error(format("super class '${cls.supercls}' must be exported before '${cls.cppcls}'"))
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
    local luaopen = cls.luaopen or ''
    local oluacls_class

    if cls.options.indexerror then
        if cls.options.indexerror:find('r') then
            funcs:pushf('oluacls_func(L, "__index", olua_indexerror);')
        end
        if cls.options.indexerror:find('w') then
            funcs:pushf('oluacls_func(L, "__newindex", olua_newindexerror);')
        end
    end

    for _, fis in ipairs(cls.funcs) do
        local cppfunc = fis[1].cppfunc
        local luafunc = fis[1].luafunc
        local macro = cls.macros[cppfunc]
        funcs:push(macro)
        funcs:pushf('oluacls_func(L, "${luafunc}", _${cls.cppcls#}_${cppfunc});')
        funcs:push(macro and '#endif' or nil)
    end

    for _, pi in ipairs(cls.props) do
        local func_get = "nullptr"
        local func_set = "nullptr"
        local macro = cls.macros[pi.get.cppfunc]
        funcs:push(macro)
        if pi.get then
            func_get = format('_${cls.cppcls#}_${pi.get.cppfunc}')
        end
        if pi.set then
            func_set = format('_${cls.cppcls#}_${pi.set.cppfunc}')
        end
        funcs:pushf('oluacls_prop(L, "${pi.name}", ${func_get}, ${func_set});')
        funcs:push(macro and '#endif' or nil)
    end

    for _, vi in ipairs(cls.vars) do
        local func_get = format('_${cls.cppcls#}_${vi.get.cppfunc}')
        local func_set = "nullptr"
        local macro = cls.macros[vi.get.varname]
        funcs:push(macro)
        if vi.set and vi.set.cppfunc then
           func_set = format('_${cls.cppcls#}_${vi.set.cppfunc}')
        end
        funcs:pushf('oluacls_prop(L, "${vi.name}", ${func_get}, ${func_set});')
        funcs:push(macro and '#endif' or nil)
    end

    olua.sort(cls.consts, 'name')
    for _, ci in ipairs(cls.consts) do
        local cast = ''
        if olua.is_pointer_type(ci.type) and not olua.has_pointer_flag(ci.type) then
            cast = '&'
        end
        funcs:pushf('oluacls_const(L, "${ci.name}", ${cast}${ci.value});')
    end

    olua.sort(cls.enums, 'name')
    for _, ei in ipairs(cls.enums) do
        funcs:pushf('oluacls_enum(L, "${ei.name}", (lua_Integer)${ei.value});')
    end

    if not cls.options.reg_luatype then
        oluacls_class = format('oluacls_class(L, "${cls.luacls}", nullptr);')
    elseif cls.supercls then
        oluacls_class = format('oluacls_class<${cls.cppcls}, ${cls.supercls}>(L, "${cls.luacls}");')
    else
        oluacls_class = format('oluacls_class<${cls.cppcls}>(L, "${cls.luacls}");')
    end

    write(format([[
        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${cls.cppcls#}(lua_State *L)
        {
            ${oluacls_class}
            ${funcs}

            ${luaopen}

            return 1;
        }
        OLUA_END_DECLS
    ]]))
end

local function gen_class_chunk(cls, write)
    if cls.chunk and #cls.chunk > 0 then
        write(format(cls.chunk))
        write('')
    end
end

local function has_packable_class(module)
    for _, cls in ipairs(module.class_types) do
        if cls.options.packable then
            return true
        end
    end
    return false
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
    local headers = module.headers
    if not has_packable_class(module) then
        headers = '#include "olua/olua.h"'
    end

    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #ifndef __AUTO_GEN_LUA_${HEADER}_H__
        #define __AUTO_GEN_LUA_${HEADER}_H__

        ${headers}

        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${module.name}(lua_State *L);
        OLUA_END_DECLS
    ]]))
    write('')

    olua.gen_pack_header(module, write)

    write('#endif')

    local path = format('${module.path}/lua_${module.name}.h')
    olua.write(path, tostring(arr))
end

local function gen_include(module, write)
    local headers = ''
    if not has_packable_class(module) then
        headers = module.headers
    end
    write(format([[
        //
        // AUTO BUILD, DON'T MODIFY!
        //
        #include "lua_${module.name}.h"
        ${headers}
    ]]))
    write('')

    if module.chunk and #module.chunk > 0 then
        write(format(module.chunk))
        write('')
    end

    olua.gen_pack_source(module, write)
end

local function gen_classes(module, write)
    for _, cls in ipairs(module.class_types) do
        cls.luacls = olua.luacls(cls.cppcls)
        local macro = cls.macros['*']
        write(macro)
        check_meta_method(cls)
        gen_class_chunk(cls, write)
        gen_class_funcs(cls, write)
        gen_class_open(cls, write)
        write(macro and '#endif' or nil)
        write('')
    end
end

local function gen_luaopen(module, write)
    local requires = olua.newarray('\n')

    local last_macro
    for _, cls in ipairs(module.class_types) do
        local macro = cls.macros['*']
        if last_macro ~= macro then
            if last_macro then
                requires:push('#endif')
            end
            if macro then
                requires:push(macro)
            end
            last_macro = macro
        end
        requires:pushf('olua_require(L, "${cls.luacls}", luaopen_${cls.cppcls#});')
    end
    requires:push(last_macro and '#endif' or nil)

    local luaopen = format(module.luaopen or '')

    write(format([[
        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${module.name}(lua_State *L)
        {
            ${requires}

            ${luaopen}

            return 0;
        }
        OLUA_END_DECLS
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