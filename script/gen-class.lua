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
            error(olua.format("super class '${cls.supercls}' must be exported before '${cls.cppcls}'"))
        end
        cls_protos = setmetatable(cls_protos, { __index = prototypes[cls.supercls] })
    end
    prototypes[cls.cppcls] = cls_protos

    cls.funcs:foreach(function (arr)
        if #arr == 0 then
            return
        end

        ---@type idl.gen.func_desc
        local func = arr[1]

        local cppfunc = olua.format([[_${cls.cppcls#}_${func.cppfunc}]])
        if symbols[cppfunc] then
            return
        end
        symbols[cppfunc] = true

        if getmetatable(cls_protos) then
            local supermeta = getmetatable(cls_protos).__index
            for _, f in ipairs(arr) do
                if not f.is_static
                    and f.prototype
                    and f.cppfunc ~= "as"
                    and rawget(cls_protos, f.prototype)
                    and supermeta[f.prototype]
                    and not f.ret.attr.using
                then
                    print(olua.format("${cls.cppcls}: super class already export ${f.funcdesc}"))
                end
            end
        end
        write(func.macro)
        olua.gen_class_func(cls, arr, write)
        write(func.macro and "#endif" or nil)
        write("")
    end)
end

---@param cls idl.gen.class_desc
---@param write idl.gen.writer
local function gen_class_open(cls, write)
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
        local cppfunc = func.cppfunc
        local luafunc = func.luafunc or cppfunc
        if func.is_exposed then
            olua.use(luafunc)
            oluacls_func:push(func.macro)
            oluacls_func:pushf('oluacls_func(L, "${luafunc}", _${cls.cppcls#}_${cppfunc});')
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
            func_get = olua.format("_${cls.cppcls#}_${pi.get.cppfunc}")
        end
        if pi.set then
            func_set = olua.format("_${cls.cppcls#}_${pi.set.cppfunc}")
        end
        oluacls_func:pushf('oluacls_prop(L, "${pi.name}", ${func_get}, ${func_set});')
        oluacls_func:push(macro and "#endif" or nil)
    end

    for _, vi in ipairs(cls.vars) do
        local func_get = olua.format("_${cls.cppcls#}_${vi.get.cppfunc}")
        local func_set = "nullptr"
        ---@cast vi idl.gen.var_desc
        local macro = vi.get.macro
        oluacls_func:push(macro)
        if vi.set and vi.set.cppfunc then
            func_set = olua.format("_${cls.cppcls#}_${vi.set.cppfunc}")
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
        oluacls_class = olua.format('oluacls_class<${cls.cppcls}, ${cls.supercls}>(L, "${cls.luacls}");')
    else
        oluacls_class = olua.format('oluacls_class<${cls.cppcls}>(L, "${cls.luacls}");')
    end

    write(olua.format([[
        OLUA_BEGIN_DECLS
        OLUA_LIB int luaopen_${cls.cppcls#}(lua_State *L)
        {
            ${oluacls_class}
            ${oluacls_func}

            ${luaopen}

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
        // AUTO BUILD, DON'T MODIFY!
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
        // AUTO BUILD, DON'T MODIFY!
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
        local macro = cls.macro
        write(macro)

        cls.funcs:sort(function (_, _, arr1, arr2)
            local func1 = arr1[1] ---@type idl.gen.func_desc
            local func2 = arr2[1] ---@type idl.gen.func_desc
            local luafunc1 = func1.luafunc or func1.cppfunc
            local luafunc2 = func2.luafunc or func2.cppfunc
            return tostring(luafunc1) < tostring(luafunc2)
        end)
        cls.props:sort(function (a, b) return tostring(a) < tostring(b) end)
        cls.vars:sort(function (a, b) return tostring(a) < tostring(b) end)
        cls.enums:sort(function (a, b) return tostring(a) < tostring(b) end)
        cls.consts:sort(function (a, b) return tostring(a) < tostring(b) end)

        gen_class_codeblock(cls, write)
        gen_class_funcs(cls, write)
        gen_class_open(cls, write)
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
        requires:pushf('olua_require(L, "${cls.luacls}", luaopen_${cls.cppcls#});')
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

    olua.willdo("generate lua annotation: ${cls.cppcls}")

    if module.entry == cls.cppcls then
        write(olua.format("---@meta ${module.name}"))
    else
        write(olua.format("---@meta ${cls.luacls}"))
    end
    write("")

    local cls_comment = cls.comment
    if cls_comment then
        cls_comment = cls_comment:gsub("^[/* \n\r]+", "")
        cls_comment = cls_comment:gsub("[\n\r]+[/* ]+", "\n")
        cls_comment = cls_comment:gsub("[/* \n\r]+$", "")
        cls_comment = cls_comment:gsub("\n", "\n---")
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
    else
        write(olua.format([[
            ---${cls_comment}
            ---@class ${cls.luacls} ${supercls}
        ]]))
    end

    for _, pi in ipairs(cls.props) do
        ---@cast pi idl.gen.prop_desc
        local comment = pi.get.comment
        if comment and #comment > 0 then
            comment = comment:gsub("^[/* \n\r]+", "")
            comment = comment:gsub("[\n\r ]+[/* ]+", "\n")
            comment = comment:gsub("[\n\r]", "\n")
            comment = comment:gsub("[/* \n\r]+$", "")
            comment = comment:gsub("\n\n", " <br><br>")
            comment = comment:gsub("\n+", " ")
            comment = comment:gsub("\\code", "```")
            comment = comment:gsub("\\endcode", "```")
            comment = comment:gsub("\\c ([^ ,.]+)", "`%1`")
        else
            comment = ""
        end
        local type = olua.luatype(pi.get.ret.type)
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
                comment = comment:gsub("^[/* \n\r]+", "")
                comment = comment:gsub("[\n\r]+[/* ]+", "\n")
                comment = comment:gsub("[/* \n\r]+$", "")
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

        if not func.is_exposed or func.body then
            return
        end

        local comment = func.comment
        if comment and #comment > 0 then
            comment = comment:gsub("^[/* \n\r]+", "---")
            comment = comment:gsub("[\n\r]+[/* ]+", "\n")
            comment = comment:gsub("[/* \n\r]+$", "")
            comment = comment:gsub("\n", "\n---")
            comment = comment:gsub("@param", "\\param")
            comment = comment:gsub("@return", "\\return")
            comment = comment:gsub("\\code", "```")
            comment = comment:gsub("\\endcode", "```")
            comment = comment:gsub("\\c ([^ ,.]+)", "`%1`")
            write(comment)
        else
            comment = ""
        end

        -- write function parameters
        local caller_args = olua.array(", ")
        if #func.args > 0 then
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
        if func.ret.type.cppcls ~= "void" then
            local ret_luacls = olua.luatype(func.ret.type)
            write(olua.format([[
                ---@return ${ret_luacls}
            ]]))
        end

        -- write overload
        for i, olfi in ipairs(arr) do
            if i == 1 then
                goto skip_first_fn
            end

            local olfi_args = olua.array(", ")

            local ret_luacls
            if olfi.ret.type.cppcls ~= "void" then
                ret_luacls = ": " .. olua.luatype(olfi.ret.type)
            else
                ret_luacls = ""
            end

            if not olfi.is_static then
                olfi_args:pushf("self: ${cls.luacls}")
            end

            for idx, arg in ipairs(olfi.args) do
                local name = arg.name or ("arg" .. idx)
                local type = olua.luatype(arg.type)
                olua.use(name, type)
                olfi_args:pushf("${name}: ${type}")
            end

            olua.use(ret_luacls)
            write(olua.format("---@overload fun(${olfi_args})${ret_luacls}"))

            ::skip_first_fn::
        end

        -- write function prototype
        local static = func.is_static and "." or ":"
        write(olua.format [[
            function ${luacls}${static}${func.luafunc}(${caller_args}) end
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
        local filename = module.entry == cls.cppcls and module.name or luacls
        filename = filename:gsub("::", "/")
        local path = olua.format("${module.api_dir}/library/${filename}.lua")
        local dir = path:match("(.*)/[^/]+$")
        olua.mkdir(dir)
        gen_class_meta(module, cls, append)
        olua.write(path, tostring(arr))

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
