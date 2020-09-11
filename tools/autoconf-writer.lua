local olua = require "olua"

local format = olua.format

local function write_metadata(module, append)
    append(format([[
        M.NAME = "${module.conf.NAME}"
        M.PATH = "${module.conf.PATH}"
    ]]))

    if module.conf.HEADER_INCLUDES then
        append(format([=[
            M.HEADER_INCLUDES = [[
            ${module.conf.HEADER_INCLUDES}
            ]]
        ]=]))
    end

    append(format([=[
        M.INCLUDES = [[
        ${module.conf.INCLUDES}
        ]]
    ]=]))

    if module.conf.CHUNK then
        append(format([=[
            M.CHUNK = [[
            ${module.conf.CHUNK}
            ]]
        ]=]))
    end

    append("\nM.CONVS = {")
    for _, cls in ipairs(module.classes) do
        if cls.KIND ~= "Conv" then
            goto continue
        end

        module.ignored_type[cls.CPPCLS] = false

        local DEF = olua.newarray("\n")
        for _, v in ipairs(#cls.VARS == 0 and cls.CONF.VAR or cls.VARS) do
            DEF:pushf('${v.SNIPPET};')
        end

        append(format([=[
            typeconv {
                CPPCLS = '${cls.CPPCLS}',
                DEF = [[
                    ${DEF}
                ]],
            },
        ]=],4))

        ::continue::
    end
    append("}\n")
end

local function write_typedef(module)
    local t = olua.newarray('\n')

    local function writeLine(fmt, ...)
        t:push(string.format(fmt, ...))
    end

    writeLine("-- AUTO BUILD, DON'T MODIFY!")
    writeLine('')
    writeLine('local olua = require "olua"')
    writeLine('local typedef = olua.typedef')
    writeLine('')
    for _, td in ipairs(module.conf.TYPEDEFS) do
        local arr = {}
        module.ignored_type[td.CPPCLS] = false
        for k, v in pairs(td) do
            arr[#arr + 1] = {k, v}
        end
        table.sort(arr, function (a, b) return a[1] < b[1] end)
        writeLine("typedef {")
        for _, p in ipairs(arr) do
            if type(p[2]) == 'string' then
                if string.find(p[2], '[\n\r]') then
                    writeLine("    %s = [[\n%s]],", p[1], p[2])
                else
                    writeLine("    %s = '%s',", p[1], p[2])
                end
            else
                writeLine("    %s = %s,", p[1], p[2])
            end
        end
        writeLine("}")
        writeLine("")
    end
    for _, cls in ipairs(module.classes) do
        local CONV
        local CPPCLS = cls.CPPCLS
        local DECLTYPE, LUACLS, NUMVARS = 'nil', 'nil', 'nil'
        if cls.KIND == 'Conv' then
            local CPPCLS_PATH = olua.topath(cls.CPPCLS)
            CONV = 'auto_olua_$$_' .. CPPCLS_PATH
            NUMVARS = #cls.VARS
        elseif cls.KIND == 'Enum' then
            CONV = 'olua_$$_uint'
            LUACLS = olua.stringify(cls.LUACLS, "'")
            DECLTYPE = olua.stringify('lua_Unsigned')
        elseif cls.KIND == 'Class' then
            CPPCLS = CPPCLS .. ' *'
            LUACLS = olua.stringify(cls.LUACLS, "'")
            CONV = 'olua_$$_cppobj'
        else
            error(cls.CPPCLS .. ' ' .. cls.KIND)
        end

        t:push(format([[
            typedef {
                CPPCLS = '${CPPCLS}',
                LUACLS = ${LUACLS},
                DECLTYPE = ${DECLTYPE},
                CONV = '${CONV}',
                NUMVARS = ${NUMVARS},
            }
        ]]))
        t:push('')
    end
    t:push('')
    olua.write(module.type_file_path, tostring(t))
end

local function is_new_func(module, supercls, fn)
    if not supercls or fn.STATIC then
        return true
    end

    local super = module.visited_type[supercls]
    if not super then
        error(format("not found super class '${supercls}'"))
    elseif super.INST_FUNCS[fn.PROTOTYPE] or super.CONF.EXCLUDE[fn.NAME] then
        return false
    else
        return is_new_func(module, super.SUPERCLS, fn)
    end
end

local function try_add_prop(fn, filter, props)
    if string.find(fn.NAME, '^get') or string.find(fn.NAME, '^is') then
        -- getABCd isAbc => ABCd Abc
        local name = string.gsub(fn.NAME, '^%l+', '')
        name = string.gsub(name, '^%u+', function (str)
            if #str > 1 and #str ~= #name then
                if #str == #name - 1 then
                    -- ABCDs => abcds
                    return str:lower()
                else
                    -- ABCd => abCd
                    return str:sub(1, #str - 1):lower() .. str:sub(#str)
                end
            else
                -- AbcdEF => abcdEF
                return str:lower()
            end
        end)
        if not filter[name] then
            filter[name] = true
            if fn.ARGS == 0 then
                props[#props + 1] = name
            end
        else
            for i, v in ipairs(props) do
                if v == name then
                    table.remove(props, i)
                    break
                end
            end
        end
    end
end

local function write_conf_enum(module, cls, append)
    for _, e in ipairs(cls.CONF.ENUM) do
        append(format("cls.enum('${e.NAME}', '${e.VALUE}')"))
    end
end

local function write_conf_func(module, cls, append)
    for _, fn in ipairs(cls.CONF.FUNC) do
        append(format("cls.func('${fn.FUNC}', [[${fn.SNIPPET}]])"))
    end
end

local function write_conf_var(module, cls, append)
    for _, fn in ipairs(cls.CONF.VAR) do
        append(format("cls.var('${fn.NAME}', [[${fn.SNIPPET}]])"))
    end
end

local function write_conf_prop(module, cls, append)
    for _, p in ipairs(cls.CONF.PROP) do
        if not p.GET then
            append(format("cls.prop('${p.NAME}')"))
        elseif string.find(p.GET, '{') then
            if p.SET then
                append(format("cls.prop('${p.NAME}', [[\n${p.GET}]], [[\n${p.SET}]])"))
            else
                append(format("cls.prop('${p.NAME}', [[\n${p.GET}]])"))
            end
        else
            if p.SET then
                append(format("cls.prop('${p.NAME}', '${p.GET}', '${p.SET}')"))
            else
                append(format("cls.prop('${p.NAME}', '${p.GET}')"))
            end
        end
    end
end

local function write_conf_callback(module, cls, append)
    for _, v in ipairs(cls.CONF.CALLBACK) do
        local FUNCS = olua.newarray("',\n'", "'", "'"):merge(v.FUNCS)
        local TAG_MAKER = olua.newarray("', '", "'", "'")
        local TAG_MODE = olua.newarray("', '", "'", "'")
        local TAG_STORE = v.TAG_STORE or 'nil'
        local TAG_SCOPE = v.TAG_SCOPE or 'object'
        if type(v.TAG_STORE) == 'string' then
            TAG_STORE = olua.stringify(v.TAG_STORE)
        end
        if v.LIFECYCLE == 'once' then
            TAG_SCOPE = 'once'
            print(format [[
                [*] please use: TAG_SCOPE = 'once' in '${cls.CPPCLS}::${v.NAME}'
            ]])
        elseif v.LIFECYCLE == 'local' then
            TAG_SCOPE = 'function'
            print(format [[
                [*] please use: TAG_SCOPE = 'function' in '${cls.CPPCLS}::${v.NAME}'
            ]])
        end
        assert(v.TAG_MAKER, 'no tag maker')
        assert(v.TAG_MODE, 'no tag mode')
        if type(v.TAG_MAKER) == 'string' then
            TAG_MAKER:push(v.TAG_MAKER)
        else
            TAG_MAKER:merge(v.TAG_MAKER)
            TAG_MAKER = '{' .. tostring(TAG_MAKER) .. '}'
        end
        if type(v.TAG_MODE) == 'string' then
            TAG_MODE:push(v.TAG_MODE)
        else
            TAG_MODE:merge(v.TAG_MODE)
            TAG_MODE = '{' .. tostring(TAG_MODE) .. '}'
        end
        append(format([[
            cls.callback {
                FUNCS =  {
                    ${FUNCS}
                },
                TAG_MAKER = ${TAG_MAKER},
                TAG_MODE = ${TAG_MODE},
                TAG_STORE = ${TAG_STORE},
                TAG_SCOPE = '${TAG_SCOPE}',
        ]]))
        module.log(format([[
            FUNC => NAME = '${v.NAME}'
                    FUNCS = {
                        ${FUNCS}
                    }
                    TAG_MAKER = ${TAG_MAKER}
                    TAG_MODE = ${TAG_MODE}
                    TAG_STORE = ${TAG_STORE}
                    TAG_SCOPE = ${TAG_SCOPE}
        ]], 4))
        append('}')
    end
end

local function write_conf_block(module, cls, append)
    if cls.CONF.BLOCK then
        append(cls.CONF.BLOCK)
    end
end

local function write_conf_inject(module, cls, append)
    for _, v in ipairs(cls.CONF.INJECT) do
        append(string.format("cls.inject('%s', {", v.NAME))
        if v.CODES.BEFORE then
            append(string.format('    BEFORE = [[\n%s]],', v.CODES.BEFORE))
        end
        if v.CODES.AFTER then
            append(string.format('    AFTER = [[\n%s]],', v.CODES.AFTER))
        end
        if v.CODES.CALLBACK_BEFORE then
            append(string.format('    CALLBACK_BEFORE = [[\n%s]],', v.CODES.CALLBACK_BEFORE))
        end
        if v.CODES.CALLBACK_AFTER then
            append(string.format('    CALLBACK_AFTER = [[\n%s]],', v.CODES.CALLBACK_AFTER))
        end
        append(string.format('})'))
    end
end

local function write_conf_alias(module, cls, append)
    for _, v in ipairs(cls.CONF.ALIAS) do
        append(format("cls.alias('${v.NAME}', '${v.ALIAS}')"))
    end
end

local function write_classes(module, append)
    append('M.CLASSES = {}')
    append('')
    for _, cls in ipairs(module.classes) do
        if cls.KIND == "EnumAlias" or cls.KIND == "Conv" then
            goto continue
        end

        module.log("[%s]", cls.CPPCLS)
        append(format("cls = typecls '${cls.CPPCLS}'"))
        if cls.SUPERCLS then
            append(format('cls.SUPERCLS = "${cls.SUPERCLS}"'))
        end
        if cls.CONF.REG_LUATYPE == false or cls.REG_LUATYPE == false then
            append('cls.REG_LUATYPE = false')
        end
        if cls.CONF.DEFIF then
            append(format('cls.DEFIF = "${cls.CONF.DEFIF}"'))
        end
        if cls.CONF.CHUNK then
            append(format([=[
                cls.CHUNK = [[
                ${cls.CONF.CHUNK}
                ]]
            ]=]))
        end
        if cls.KIND == 'Enum' then
            append('cls.enums [[')
            for _, value in ipairs(cls.ENUMS) do
                append('    ' .. value)
            end
            append(']]')
        elseif cls.KIND == 'Class' then
            local props = {}
            local filter = {}
            if #cls.ENUMS > 0 then
                append('cls.enums [[')
                for _, value in ipairs(cls.ENUMS) do
                    append('    ' .. value)
                end
                append(']]')
            end
            for _, v in ipairs(cls.CONSTS) do
                append(format([[
                    cls.const('${v.NAME}', '${cls.CPPCLS}::${v.NAME}', '${v.TYPENAME}')
                ]]))
            end
            append('cls.funcs [[')
            local callbacks = {}
            for _, fn in ipairs(cls.FUNCS) do
                if is_new_func(module,cls.SUPERCLS, fn) then
                    if not fn.CALLBACK_TYPE and not cls.CONF.CALLBACK[fn.NAME] then
                        append('    ' .. fn.FUNC)
                        try_add_prop(fn, filter, props)
                    else
                        local arr = callbacks[fn.NAME]
                        if not arr then
                            arr = {}
                            callbacks[#callbacks + 1] = arr
                            callbacks[fn.NAME] = arr
                        end
                        arr[#arr + 1] = fn
                    end
                end
            end
            for _, v in ipairs(callbacks) do
                local FUNCS = {}
                for i, fn in ipairs(v) do
                    FUNCS[i] = fn.FUNC
                end
                local TAG = v[1].NAME:gsub('^set', ''):gsub('^get', '')
                local mode = v[1].CALLBACK_TYPE == 'RET' and 'OLUA_TAG_SUBEQUAL' or 'OLUA_TAG_REPLACE'
                local callback = cls.CONF.CALLBACK[v[1].NAME]
                if callback then
                    callback.FUNCS = FUNCS
                    if not callback.TAG_MAKER then
                        callback.TAG_MAKER = olua.format '${TAG}'
                    end
                    if not callback.TAG_MODE then
                        callback.TAG_MODE = mode
                    end
                else
                    cls.CONF.CALLBACK[v[1].NAME] = {
                        NAME = v[1].NAME,
                        FUNCS = FUNCS,
                        TAG_MAKER = olua.format '${TAG}',
                        TAG_MODE = mode,
                    }
                end
            end
            for _, cb in ipairs(cls.CONF.CALLBACK) do
                assert(cb.FUNCS, "callback '" .. cb.NAME .. "' not found")
                if #cb.FUNCS == 1 and (string.match(cb.FUNCS[1], '%(%) *$')
                        or (string.match(cb.FUNCS[1], '%( *void *%) *$'))) then
                    try_add_prop({
                        NAME = cb.NAME,
                        ARGS = 0,
                    }, filter, props)
                end
            end
            append(']]')
            for _, v in ipairs(cls.VARS) do
                local LUANAME = cls.CONF.MAKE_LUANAME(v.NAME)
                if v.CALLBACK_TYPE then
                    module.log(format([[
                        var => NAME = '${LUANAME}'
                               DECL = '${v.SNIPPET}'
                    ]], 4))
                end
                append(format("cls.var('${LUANAME}', [[${v.SNIPPET}]])"))
            end
            write_conf_enum(module, cls, append)
            write_conf_func(module, cls, append)
            write_conf_var(module, cls, append)
            write_conf_prop(module, cls, append)
            write_conf_callback(module, cls, append)
            write_conf_block(module, cls, append)
            write_conf_inject(module, cls, append)
            write_conf_alias(module, cls, append)
            if #props > 0 then
                append('cls.props [[')
                for _, v in ipairs(props) do
                    append('    ' .. v)
                end
                append(']]')
            end
        end
        append('M.CLASSES[#M.CLASSES + 1] = cls')
        append('')

        ::continue::
    end
end

local M = {}

function M.write_module(module)
    local t = olua.newarray('\n')

    local function append(str)
        t:push(str)
    end

    append(format([[
        -- AUTO BUILD, DON'T MODIFY!

        require "autobuild.${module.filename}-types"

        local olua = require "olua"
        local typeconv = olua.typeconv
        local typecls = olua.typecls
        local cls = nil
        local M = {}
    ]]))
    append('')

    write_metadata(module, append)
    write_classes(module, append)
    write_typedef(module, append)

    append('return M\n')

    olua.write(module.file_path, tostring(t))
end

function M.write_alias_and_log(module)
    local file = io.open('autobuild/autoconf-ignore.log', 'w')
    local arr = {}
    for cls, flag in pairs(module.ignored_type) do
        if flag then
            arr[#arr + 1] = cls
        end
    end
    table.sort(arr)
    for _, cls in pairs(arr) do
        file:write(string.format("[ignore class] %s\n", cls))
    end
    for cls in pairs(module.refed_type) do
        module.log('ref class: %s', cls)
    end

    local types = olua.newarray('\n')
    for cppcls, v in pairs(module.type_alias) do
        if module.visited_type[cppcls] then
            goto continue
        end
        if v:find('^enum ') then
            types:push({
                CPPCLS = cppcls,
                DECLTYPE = 'lua_Unsigned',
                CONV = 'olua_$$_uint',
            })
        elseif type(module.type_convs[v]) == 'string' then
            types:push({
                CPPCLS = cppcls,
                DECLTYPE = cppcls,
                CONV = module.type_convs[v],
            })
        end
        ::continue::
    end
    local TYPEDEFS = olua.newarray('\n')
    for i, v in ipairs(olua.sort(types, 'CPPCLS')) do
        TYPEDEFS:pushf([[
            typedef {
                CPPCLS = '${v.CPPCLS}',
                DECLTYPE = '${v.DECLTYPE}',
                CONV = '${v.CONV}',
            }
        ]])
        TYPEDEFS:push('')
    end

    olua.write('autobuild/alias-types.lua', format([[
        local olua = require "olua"
        local typedef = olua.typedef

        ${TYPEDEFS}
    ]]))

    local files = olua.newarray('\n')
    local type_files = olua.newarray('\n')
    type_files:push('dofile "autobuild/alias-types.lua"')
    for _, v in ipairs(module.module_files) do
        files:push(format('export "${v.file_path}"'))
        type_files:push(format('dofile "${v.type_file_path}"'))
    end
    olua.write('autobuild/make.lua', format([[
        local olua = require "olua"
        local export = olua.export
        local typedef = olua.typedef

        ${type_files}

        ${files}
    ]]))
end

return M