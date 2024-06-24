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
        if not has_method(cls, '__call') and cls.options.fromtable then
            local codeset = { decl_args = olua.array():set_joiner('\n'), check_args = olua.array():set_joiner('\n') }
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
                print(format('${cls.cppcls}: super class already export ${f.funcdesc}'))
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
        pts = setmetatable(pts, { __index = prototypes[cls.supercls] })
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
        check_gen_class_func(cls, { pi.get }, write)
        check_gen_class_func(cls, { pi.set }, write)
    end

    olua.sort(cls.vars, 'name')
    for _, ai in ipairs(cls.vars) do
        check_gen_class_func(cls, { ai.get }, write)
        check_gen_class_func(cls, { ai.set }, write)
    end
end

local function gen_class_open(cls, write)
    local funcs = olua.array():set_joiner('\n')
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
        local func_get = 'nullptr'
        local func_set = 'nullptr'
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
        local func_set = 'nullptr'
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
    local arr = olua.array():set_joiner('\n')
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
    local requires = olua.array():set_joiner('\n')

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

    local entry = ''
    if module.entry then
        entry = format([[
            if (olua_getclass(L, olua_getluatype<${module.entry}>(L))) {
                return 1;
            }
        ]])
    end

    write(format([[
        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${module.name}(lua_State *L)
        {
            ${requires}

            ${luaopen}

            ${entry}

            return 0;
        }
        OLUA_END_DECLS
    ]]))
    write('')
end

function olua.gen_source(module)
    local arr = olua.array():set_joiner('\n')
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

local function gen_class_meta(module, cls, write)
    local luacls = cls.luacls:match('[^.]+$')
    local supercls = cls.supercls and olua.luacls(cls.supercls) or nil
    supercls = supercls and format(': ${supercls}') or ''

    if module.entry == cls.cppcls then
        write(format('---@meta ${module.name}'))
    else
        write(format('---@meta ${cls.luacls}'))
    end
    write('')

    local comment = cls.comment
    if comment then
        comment = olua.base64_decode(comment)
        comment = comment:gsub('^[/* \n\r]+', '')
        comment = comment:gsub('[\n\r]+[/* ]+', '\n')
        comment = comment:gsub('[/* \n\r]+$', '')
        comment = comment:gsub('\n', '\n---')
    else
        comment = ''
    end

    if olua.is_enum_type(cls) then
        write(format([[
            ---@type ${cls.luacls}
            local VALUE

            ---${comment}
            ---@enum ${cls.luacls}
        ]]))
    else
        write(format([[
            ---${comment}
            ---@class ${cls.luacls} ${supercls}
        ]]))
    end

    for _, pi in ipairs(cls.props) do
        local field_luacls = olua.luatype(pi.get.ret.type)
        local comment = pi.get.ret.attr.comment
        if comment and #comment > 0 then
            comment = olua.base64_decode(comment[1])
            comment = comment:gsub('^[/* \n\r]+', '')
            comment = comment:gsub('[\n\r ]+[/* ]+', '\n')
            comment = comment:gsub('[\n\r]', '\n')
            comment = comment:gsub('[/* \n\r]+$', '')
            comment = comment:gsub('\n\n', ' <br><br>')
            comment = comment:gsub('\n+', ' ')
            comment = comment:gsub('\\code', '```')
            comment = comment:gsub('\\endcode', '```')
            comment = comment:gsub('\\c ([^ ,.]+)', '`%1`')
        else
            comment = ''
        end
        write(format([[
            ---@field ${pi.name} ${field_luacls} ${comment}
        ]]))
    end

    for _, vi in ipairs(cls.vars) do
        local field_luacls = olua.luatype(vi.get.ret.type)
        write(format([[
            ---@field ${vi.name} ${field_luacls}
        ]]))
    end

    if olua.is_enum_type(cls) then
        local fields = olua.array():set_joiner('\n')
        for _, ei in ipairs(cls.enums) do
            local comment = ei.comment
            if #comment > 0 then
                comment = comment:gsub('^[/* \n\r]+', '')
                comment = comment:gsub('[\n\r]+[/* ]+', '\n')
                comment = comment:gsub('[/* \n\r]+$', '')
                comment = comment:gsub('\n', '\n---')
                fields:pushf('---${comment}')
            end
            local value = ei.intvalue or 'VALUE'
            fields:pushf('${ei.name} = ${value},')
        end
        write(format([[
            local ${luacls} = {
                ${fields}
            }
        ]]))
    else
        write(format('local ${luacls} = {}'))
    end

    write('')

    for _, fis in ipairs(cls.funcs) do
        local fi = fis[1]

        local comment = fi.ret.attr.comment
        if comment and #comment > 0 then
            comment = olua.base64_decode(comment[1])
            comment = comment:gsub('^[/* \n\r]+', '---')
            comment = comment:gsub('[\n\r]+[/* ]+', '\n')
            comment = comment:gsub('[/* \n\r]+$', '')
            comment = comment:gsub('\n', '\n---')
            comment = comment:gsub('@param', '\\param')
            comment = comment:gsub('@return', '\\return')
            comment = comment:gsub('\\code', '```')
            comment = comment:gsub('\\endcode', '```')
            comment = comment:gsub('\\c ([^ ,.]+)', '`%1`')
            write(comment)
        else
            comment = ''
        end

        -- write function parameters
        local caller_args = olua.array():set_joiner(', ')
        if #fi.args > 0 then
            local params = olua.array():set_joiner('\n')
            local skip_first_arg = olua.is_oluaret(fi)
            for _, arg in ipairs(fi.args) do
                if skip_first_arg then
                    skip_first_arg = false
                    goto continue
                end
                local varname = arg.varname or ''
                local arg_luacls = olua.luatype(arg.type)
                caller_args:push(varname)
                params:pushf([[
                    ---@param ${varname} ${arg_luacls}
                ]])
                ::continue::
            end
            write(format([[
                ${params}
            ]]))
        end

        -- write return type
        if fi.ret.type.cppcls ~= 'void' then
            local ret_luacls = olua.luatype(fi.ret.type)
            write(format([[
                ---@return ${ret_luacls}
            ]]))
        end

        -- write overload
        for i, olfi in ipairs(fis) do
            if i == 1 then
                goto skip_first_fn
            end

            local caller_args = olua.array():set_joiner(', ')

            local ret_luacls
            if olfi.ret.type.cppcls ~= 'void' then
                ret_luacls = ': ' .. olua.luatype(olfi.ret.type)
            else
                ret_luacls = ''
            end

            if not olfi.static then
                caller_args:pushf('self: ${cls.luacls}')
            end

            for idx, arg in ipairs(olfi.args) do
                local varname = arg.varname or ('arg' .. idx)
                local arg_luacls = olua.luatype(arg.type)
                caller_args:pushf('${varname}: ${arg_luacls}')
            end

            write(format('---@overload fun(${caller_args})${ret_luacls}'))

            ::skip_first_fn::
        end

        -- write function prototype
        local static = fi.static and '.' or ':'
        write(format [[
            function ${luacls}${static}${fi.luafunc}(${caller_args}) end
        ]])
        write('')
    end

    write(format('return ${luacls}'))
end

function olua.gen_metafile(module)
    if not module.metapath then
        return
    end
    for _, cls in ipairs(module.class_types) do
        local luacls = cls.luacls:gsub('%.', '/')
        if luacls:find('<') then
            goto continue
        end
        local arr = olua.array():set_joiner('\n')
        local function append(value)
            if value then
                arr:push(value)
            end
        end
        local filename = module.entry == cls.cppcls and module.name or luacls
        local path = format('${module.metapath}/library/${filename}.lua')
        local dir = path:match('(.*)/[^/]+$')
        olua.mkdir(dir)
        gen_class_meta(module, cls, append)
        olua.write(path, tostring(arr))

        ::continue::
    end

    local name = module.metapath:match('([^/]+)$')
    olua.write(format('${module.metapath}/config.json'), format([[
        {
            "$schema": "https://raw.githubusercontent.com/LuaLS/LLS-Addons/main/schemas/addon_config.schema.json",
            "words": ["%s+-${name}"],
            "files": ["${name}"],
            "settings": {}
        }
    ]]))
end
