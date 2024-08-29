local prototypes = {}
local symbols = {}

---@alias idl.gen.writer fun(str:string|nil)

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_funcs(cls, write)
    local cls_protos = {}

    cls.funcs:foreach(function (arr)
        for _, fi in ipairs(arr) do
            if fi.prototype then
                cls_protos[fi.prototype] = true
            end
        end
    end)

    if cls.supercls then
        if not prototypes[cls.supercls] then
            error(olua.format("super class '${cls.supercls}' must be exported before '${cls.cxxcls}'"))
        end
        cls_protos = setmetatable(cls_protos, { __index = prototypes[cls.supercls] })
    end
    prototypes[cls.cxxcls] = cls_protos

    cls.funcs:foreach(function (arr)
        if #arr == 0 then
            return
        end

        ---@type idl.gen.func_desc
        local func = arr[1]

        local cxxfn = olua.format([[_${cls.cxxcls#}_${func.cxxfn}]])
        if symbols[cxxfn] then
            return
        end
        symbols[cxxfn] = true

        if getmetatable(cls_protos) then
            local supermeta = getmetatable(cls_protos).__index
            for _, f in ipairs(arr) do
                if not f.is_static
                    and f.prototype
                    and f.cxxfn ~= "as"
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
    end)
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
        ---@type idl.gen.func_desc
        local func = arr[1]
        local cxxfn = func.cxxfn
        local luafn = func.luafn or cxxfn
        if func.is_exposed then
            olua.use(luafn)
            oluacls_func:push(func.macro)
            oluacls_func:pushf('oluacls_func(L, "${luafn}", _${cls.cxxcls#}_${cxxfn});')
            oluacls_func:push(func.macro and "#endif" or nil)
        end
    end

    for _, pi in ipairs(cls.props) do
        local func_get = "nullptr"
        local func_set = "nullptr"
        ---@cast pi idl.gen.prop_desc
        local macro = pi.get.macro
        oluacls_func:push(macro)
        if pi.get then
            func_get = olua.format("_${cls.cxxcls#}_${pi.get.cxxfn}")
        end
        if pi.set then
            func_set = olua.format("_${cls.cxxcls#}_${pi.set.cxxfn}")
        end
        oluacls_func:pushf('oluacls_prop(L, "${pi.name}", ${func_get}, ${func_set});')
        oluacls_func:push(macro and "#endif" or nil)
    end

    for _, vi in ipairs(cls.vars) do
        local func_get = olua.format("_${cls.cxxcls#}_${vi.get.cxxfn}")
        local func_set = "nullptr"
        ---@cast vi idl.gen.var_desc
        local macro = vi.get.macro
        oluacls_func:push(macro)
        if vi.set and vi.set.cxxfn then
            func_set = olua.format("_${cls.cxxcls#}_${vi.set.cxxfn}")
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
        static int _${cls.luacls#}(lua_State *L)
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
            olua_require(L, "${module.name}",  luaopen_${module.name});
            if (!olua_getclass(L, olua_getluatype<${cls.cxxcls}>(L))) {
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
local function has_packable_class(module)
    for _, cls in ipairs(module.class_types) do
        if cls.options.packable then
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
    if not has_packable_class(module) then
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
    if not has_packable_class(module) then
        headers = module.headers
    end
    write(olua.format([[
        //
        // AUTO GENERATED, DO NOT MODIFY!
        //
        #include "lua_${module.name}.h"
        ${headers}
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
        cls.funcs:sort(function (_, _, arr1, arr2)
            local func1 = arr1[1] ---@type idl.gen.func_desc
            local func2 = arr2[1] ---@type idl.gen.func_desc
            local luafunc1 = func1.luafn or func1.cxxfn
            local luafunc2 = func2.luafn or func2.cxxfn
            return tostring(luafunc1) < tostring(luafunc2)
        end)
        cls.props:sort(function (a, b) return tostring(a) < tostring(b) end)
        cls.vars:sort(function (a, b) return tostring(a) < tostring(b) end)
        cls.enums:sort(function (a, b) return tostring(a) < tostring(b) end)
        cls.consts:sort(function (a, b) return tostring(a) < tostring(b) end)

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
        requires:pushf('olua_require(L, "${cls.luacls}", _${cls.luacls#});')
    end
    requires:push(last_macro and "#endif" or nil)

    local luaopen = olua.format(module.luaopen or "")

    local entry = ""
    if module.entry then
        entry = olua.format([[
            if (olua_getclass(L, olua_getluatype<${module.entry}>(L))) {
                return 1;
            }
        ]])
    end

    write(olua.format([[
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
    write("")
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

---@param module idl.gen.module_desc
---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_meta(module, cls, write)
    local luacls = cls.luacls:match("[^.]+$")
    local supercls = cls.supercls and olua.luacls(cls.supercls) or nil
    supercls = supercls and olua.format(": ${supercls}") or ""

    olua.willdo("generate lua annotation: ${cls.cxxcls}")

    write(olua.format("---@meta ${cls.luacls}"))
    write("")

    local cls_comment = cls.comment
    if cls_comment then
        cls_comment = cls.comment:gsub("\n", "\n---")
    else
        cls_comment = ""
    end

    if olua.is_enum_type(cls) then
        write(olua.format([[
            ---@type ${cls.luacls}
            local VALUE

            ---${cls_comment}
            ---@enum ${cls.luacls}
        ]]))
        if cls.luacats then
            write(cls.luacats)
        end
    else
        write(olua.format("---${cls_comment}"))
        if olua.is_func_type(cls.cxxcls) then
            local ti = olua.typeinfo(cls.cxxcls)
            write("---")
            olua.use(ti)
            write(olua.format("---${ti.funcdecl}"))
        end
        write(olua.format("---@class ${cls.luacls} ${supercls}"))
        if cls.luacats then
            write(cls.luacats)
        end
    end

    for _, pi in ipairs(cls.props) do
        ---@cast pi idl.gen.prop_desc
        local comment = pi.get.comment
        if comment and #comment > 0 then
            comment = comment:gsub("\n\n", " <br><br>")
            comment = comment:gsub("\n+", " ")
        else
            comment = ""
        end
        local type = pi.get.ret and olua.luatype(pi.get.ret.type) or "any"
        olua.use(type)
        write(olua.format([[
            ---@field ${pi.name} ${type} ${comment}
        ]]))
    end

    for _, vi in ipairs(cls.vars) do
        ---@cast vi idl.gen.var_desc
        local type = olua.luatype(vi.get.ret.type)
        olua.use(type)
        write(olua.format([[
            ---@field ${vi.name} ${type}
        ]]))
    end

    for _, ci in ipairs(cls.consts) do
        ---@cast ci idl.gen.const_desc
        local type = olua.luatype(ci.type)
        olua.use(type)
        write(olua.format([[
            ---@field ${ci.name} ${type}
        ]]))
    end

    if olua.is_enum_type(cls) then
        local fields = olua.array("\n")
        for _, ei in ipairs(cls.enums) do
            local comment = ei.comment
            if comment and #comment > 0 then
                comment = comment:gsub("\n", "\n---")
                fields:pushf("---${comment}")
            end
            local value = ei.intvalue or "VALUE"
            olua.use(value)
            fields:pushf("${ei.name} = ${value},")
        end
        write(olua.format([[
            local ${luacls} = {
                ${fields}
            }
        ]]))
    else
        write(olua.format("local ${luacls} = {}"))
    end

    write("")

    cls.funcs:foreach(function (arr)
        olua.use(cls, luacls)

        ---@type idl.gen.func_desc
        local func = arr[1]

        if not func.is_exposed then
            return
        end

        local comment = func.comment
        if comment and #comment > 0 then
            comment = comment:gsub("\n", "\n---")
            write(olua.format("---${comment}"))
        end

        local caller_args = olua.array(", ")

        if func.luacats then
            write(func.luacats)
            for name in string.gmatch(func.luacats, "%-+@param +([^ ]+)") do
                caller_args:push(name)
            end
        else
            -- write function parameters
            if func.args and #func.args > 0 then
                local params = olua.array("\n")
                local skip_first_arg = olua.is_oluaret(func)
                for i, arg in ipairs(func.args) do
                    if skip_first_arg then
                        skip_first_arg = false
                        goto continue
                    end
                    ---@cast arg idl.gen.type_desc
                    local name = arg.name or "arg${i}"
                    local type = olua.luatype(arg.type)
                    olua.use(type)
                    caller_args:push(name)
                    params:pushf([[
                        ---@param ${name} ${type}
                    ]])
                    ::continue::
                end
                write(olua.format([[${params}]]))
            end

            -- write return type
            if not func.ret then
                write(olua.format([[---@return any]]))
            elseif func.ret.type.cxxcls ~= "void" then
                local ret_luacls = olua.luatype(func.ret.type)
                write(olua.format([[
                    ---@return ${ret_luacls}
                ]]))
            end
        end

        -- write overload
        for i, olfi in ipairs(arr) do
            if i > 1 then
                local fn = olua.gen_luafn(olfi, cls)
                olua.use(fn)
                write(olua.format("---@overload ${fn}"))
            end
        end

        -- write function prototype
        local static = func.is_static and "." or ":"
        olua.use(static)
        write(olua.format [[
            function ${luacls}${static}${func.luafn}(${caller_args}) end
        ]])
        write("")
    end)

    write(olua.format("return ${luacls}"))
end

---@param module idl.gen.module_desc
function olua.gen_annotation(module)
    if not module.api_dir then
        return
    end
    for _, cls in ipairs(module.class_types) do
        ---@cast cls idl.gen.class_desc
        local luacls = cls.luacls:gsub("%.", "/")
        if luacls:find("<") then
            goto continue
        end
        local arr = olua.array("\n")
        local function append(value)
            if value then
                arr:push(value)
            end
        end
        local filename = cls.luacls:gsub("%.", "/")
        olua.use(filename)
        local path = olua.format("${module.api_dir}/library/${filename}.lua")
        local dir = path:match("(.*)/[^/]+$")
        olua.mkdir(dir)
        gen_class_meta(module, cls, append)
        olua.write(path, tostring(arr))

        if module.entry == cls.cxxcls then
            path = olua.format("${module.api_dir}/library/${module.name}.lua")
            olua.write(path, olua.format([[
                -- AUTO GENERATED, DO NOT MODIFY!
                ---@meta ${module.name}

                return require("${cls.luacls}")
            ]]))
        end

        ::continue::
    end

    local name = module.api_dir:match("([^/]+)$")
    olua.write(olua.format("${module.api_dir}/config.json"), olua.format([[
        {
            "$schema": "https://raw.githubusercontent.com/LuaLS/LLS-Addons/main/schemas/addon_config.schema.json",
            "words": ["%s+-${name}"],
            "files": ["${name}"],
            "settings": {}
        }
    ]]))
end
