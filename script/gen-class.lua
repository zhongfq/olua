local prototypes = {}
local symbols = {}

---@alias idl.gen.writer fun(str:string|nil)

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_funcs(cls, write)
    local cls_protos = {}

    for _, arr in ipairs(cls.funcs) do
        for _, fi in ipairs(arr) do
            if fi.prototype then
                cls_protos[fi.prototype] = true
            end
        end
    end

    if cls.supercls then
        if not prototypes[cls.supercls] then
            error(olua.format("super class '${cls.supercls}' must be exported before '${cls.cxxcls}'"))
        end
        cls_protos = setmetatable(cls_protos, { __index = prototypes[cls.supercls] })
    end
    prototypes[cls.cxxcls] = cls_protos

    for _, arr in ipairs(cls.funcs) do
        if #arr == 0 then
            return
        end

        local func = arr[1]

        local luafn = olua.format([[_olua_fun_${cls.cxxcls#}_${func.luafn}]])
        if symbols[luafn] then
            return
        end
        symbols[luafn] = true

        if getmetatable(cls_protos) then
            local supermeta = getmetatable(cls_protos).__index
            for _, f in ipairs(arr) do
                if not f.is_static
                    and f.prototype
                    and f.luafn ~= "as"
                    and rawget(cls_protos, f.prototype)
                    and supermeta[f.prototype]
                    and not f.ret.attr.using
                then
                    print(olua.format("${cls.cxxcls}: super class already export ${f.funcdesc}"))
                end
            end
        end
        write(func.macro)
        olua.gen_class_func(cls, arr, write)
        write(func.macro and "#endif" or nil)
        write("")
    end
end

---@param module idl.gen.module_desc
---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_open(module, cls, write)
    local reg_luatype = ""
    local luaopen = cls.luaopen or ""
    local oluacls_class
    local oluacls_func = olua.array("\n")

    if cls.options.indexerror then
        if cls.options.indexerror:find("r") then
            oluacls_func:pushf('oluacls_func(L, "__index", olua_indexerror);')
        end
        if cls.options.indexerror:find("w") then
            oluacls_func:pushf('oluacls_func(L, "__newindex", olua_newindexerror);')
        end
    end

    for _, arr in ipairs(cls.funcs) do
        local func = arr[1]
        local luafn = func.luafn
        if func.is_exposed then
            olua.use(luafn)
            oluacls_func:push(func.macro)
            oluacls_func:pushf('oluacls_func(L, "${luafn}", _olua_fun_${cls.cxxcls#}_${luafn});')
            oluacls_func:push(func.macro and "#endif" or nil)
        end
    end

    for _, pi in ipairs(cls.props) do
        local func_get = "nullptr"
        local func_set = "nullptr"
        local macro = pi.get.macro
        oluacls_func:push(macro)
        if pi.get then
            func_get = olua.format("_olua_fun_${cls.cxxcls#}_${pi.get.luafn}")
        end
        if pi.set then
            func_set = olua.format("_olua_fun_${cls.cxxcls#}_${pi.set.luafn}")
        end
        oluacls_func:pushf('oluacls_prop(L, "${pi.name}", ${func_get}, ${func_set});')
        oluacls_func:push(macro and "#endif" or nil)
    end

    for _, vi in ipairs(cls.vars) do
        local func_get = olua.format("_olua_fun_${cls.cxxcls#}_${vi.get.luafn}")
        local func_set = "nullptr"
        local macro = vi.get.macro
        oluacls_func:push(macro)
        if vi.set and vi.set.luafn then
            func_set = olua.format("_olua_fun_${cls.cxxcls#}_${vi.set.luafn}")
        end
        oluacls_func:pushf('oluacls_prop(L, "${vi.name}", ${func_get}, ${func_set});')
        oluacls_func:push(macro and "#endif" or nil)
    end

    for _, ci in ipairs(cls.consts) do
        local cast = ""
        if olua.is_pointer_type(ci.type) and not olua.has_pointer_flag(ci.type) then
            cast = "&"
        end
        oluacls_func:pushf('oluacls_const(L, "${ci.name}", ${cast}${ci.value});')
    end

    for _, ei in ipairs(cls.enums) do
        oluacls_func:pushf('oluacls_enum(L, "${ei.name}", (lua_Integer)${ei.value});')
    end

    if not cls.options.reg_luatype then
        oluacls_class = olua.format('oluacls_class(L, "${cls.luacls}", nullptr);')
    elseif cls.supercls then
        oluacls_class = olua.format('oluacls_class<${cls.cxxcls}, ${cls.supercls}>(L, "${cls.luacls}");')
    else
        oluacls_class = olua.format('oluacls_class<${cls.cxxcls}>(L, "${cls.luacls}");')
    end

    write(olua.format([[
        static int _olua_cls_${cls.luacls#}(lua_State *L)
        {
            ${oluacls_class}
            ${oluacls_func}

            ${luaopen}

            return 1;
        }
    ]]))

    write("")

    write(olua.format([[
        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${cls.luacls#}(lua_State *L)
        {
            olua_require(L, ".olua.module.${module.name}",  _olua_module_${module.name});
            if (!olua_getclass(L, "${cls.luacls}")) {
                luaL_error(L, "class not found: ${cls.cxxcls}");
            }
            return 1;
        }
        OLUA_END_DECLS
    ]]))
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_codeblock(cls, write)
    if cls.codeblock and #cls.codeblock > 0 then
        write(olua.format(cls.codeblock))
        write("")
    end
end

---@param module idl.gen.module_desc
local function has_packable_or_fromtable_class(module)
    for _, cls in ipairs(module.class_types) do
        if cls.options.packable or cls.options.from_table then
            return true
        end
    end
    return false
end

---@param module idl.gen.module_desc
function olua.gen_header(module)
    local arr = olua.array("\n")
    local function write(value)
        if value then
            -- '   #if' => '#if'
            arr:push(value:gsub("\n *#", "\n#"))
        end
    end

    local HEADER = string.upper(module.name)
    local headers = module.headers
    if not has_packable_or_fromtable_class(module) then
        headers = '#include "olua/olua.h"'
    end

    write(olua.format([[
        //
        // AUTO GENERATED, DO NOT MODIFY!
        //
        #ifndef __AUTO_GEN_LUA_${HEADER}_H__
        #define __AUTO_GEN_LUA_${HEADER}_H__

        ${headers}

        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${module.name}(lua_State *L);
        OLUA_END_DECLS
    ]]))
    write("")

    olua.gen_pack_header(module, write)

    write("#endif")

    local path = olua.format("${module.output_dir}/lua_${module.name}.h")
    olua.write(path, tostring(arr))
end

---@param module idl.gen.module_desc
---@param write idl.gen.writer
local function gen_include(module, write)
    local headers = ""
    if not has_packable_or_fromtable_class(module) then
        headers = module.headers
    end
    write(olua.format([[
        //
        // AUTO GENERATED, DO NOT MODIFY!
        //
        #include "lua_${module.name}.h"
        ${headers}

        static int _olua_module_${module.name}(lua_State *L);
    ]]))
    write("")

    if module.codeblock and #module.codeblock > 0 then
        write(olua.format(module.codeblock))
        write("")
    end

    olua.gen_pack_source(module, write)
end

---@param module idl.gen.module_desc
---@param write idl.gen.writer
local function gen_classes(module, write)
    for _, cls in ipairs(module.class_types) do
        local macro = cls.macro
        write(macro)
        gen_class_codeblock(cls, write)
        gen_class_funcs(cls, write)
        gen_class_open(module, cls, write)
        write(macro and "#endif" or nil)
        write("")
    end
end

---@param module idl.gen.module_desc
---@param write idl.gen.writer
local function gen_luaopen(module, write)
    local requires = olua.array("\n")

    local last_macro
    local has_module = false
    for _, cls in ipairs(module.class_types) do
        local macro = cls.macro
        if last_macro ~= macro then
            if last_macro then
                requires:push("#endif")
            end
            if macro then
                requires:push(macro)
            end
            last_macro = macro
        end
        if cls.luacls == module.name then
            has_module = true
        end
        requires:pushf('olua_require(L, "${cls.luacls}", _olua_cls_${cls.luacls#});')
    end
    requires:push(last_macro and "#endif" or nil)

    local luaopen = olua.format(module.luaopen or "")

    local entry = ""
    if module.entry then
        local entry_cls = olua.get_class(module.entry)
        entry = olua.format([[
            if (olua_getclass(L, "${entry_cls.luacls}")) {
                return 1;
            }
        ]])
        olua.use(entry_cls, entry)
    end

    write(olua.format([[
        int _olua_module_${module.name}(lua_State *L)
        {
            ${requires}

            ${luaopen}

            return 0;
        }
    ]]))
    write("")

    if not has_module then
        write(olua.format([[
            OLUA_BEGIN_DECLS
            OLUA_LIB int luaopen_${module.name}(lua_State *L)
            {
                olua_require(L, ".olua.module.${module.name}",  _olua_module_${module.name});

                ${entry}

                return 0;
            }
            OLUA_END_DECLS
        ]]))
        write("")
    end
end

---@param module idl.gen.module_desc
function olua.gen_source(module)
    local arr = olua.array("\n")

    ---@param value string
    local function append(value)
        if value then
            -- '   #if' => '#if'
            if not value then
                print("value is nil")
            end
            arr:push(value:gsub("\n *#", "\n#"))
        end
    end

    gen_include(module, append)
    gen_classes(module, append)
    gen_luaopen(module, append)

    local path = olua.format("${module.output_dir}/lua_${module.name}.cpp")
    olua.write(path, tostring(arr))
end
