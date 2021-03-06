local olua = require "olua"

local format = olua.format

local function write_metadata(module, append)
    append(format([[
        M.NAME = "${module.NAME}"
        M.PATH = "${module.PATH}"
    ]]))

    append(format('M.INCLUDES = ${module.INCLUDES?}'))
    append(format('M.CHUNK = ${module.CHUNK?}'))

    append("\nM.CONVS = {")
    for _, cls in ipairs(module.CLASSES) do
        if cls.KIND ~= "conv" then
            goto continue
        end

        module.ignored_type[cls.CPPCLS] = false

        local EXPS = olua.newarray("\n")
        for _, v in ipairs(cls.VAR) do
            EXPS:pushf('${v.SNIPPET};')
        end

        append(format([=[
            typeconv {
                CPPCLS = '${cls.CPPCLS}',
                DEF = [[
                    ${EXPS}
                ]],
            },
        ]=], 4))

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
    for _, td in ipairs(module.TYPEDEFS) do
        local arr = {}
        module.ignored_type[td.CPPCLS] = false
        for k, v in pairs(td) do
            arr[#arr + 1] = {k, v}
        end
        table.sort(arr, function (a, b) return a[1] < b[1] end)
        writeLine("typedef {")
        for _, p in ipairs(arr) do
            local KEY, VALUE = p[1], p[2]
            writeLine(format('${KEY} = ${VALUE?},', 4))
        end
        writeLine("}")
        writeLine("")
    end
    for _, cls in ipairs(module.CLASSES) do
        local CONV
        local CPPCLS = cls.CPPCLS
        local DECLTYPE, LUACLS, NUM_VARS = 'nil', 'nil', 'nil'
        if cls.KIND == 'conv' then
            CONV = 'auto_olua_$$_' .. string.gsub(cls.CPPCLS, '[.:]+', '_')
            NUM_VARS = #cls.VAR
        elseif cls.KIND == 'enum' then
            CONV = 'olua_$$_uint'
            LUACLS = olua.stringify(cls.LUACLS, "'")
            DECLTYPE = olua.stringify('lua_Unsigned')
        elseif cls.KIND == 'class' then
            CPPCLS = CPPCLS .. ' *'
            LUACLS = olua.stringify(cls.LUACLS, "'")
            CONV = 'olua_$$_cppobj'
        else
            error(cls.CPPCLS .. ' ' .. cls.KIND)
        end

        t:pushf([[
            typedef {
                CPPCLS = '${CPPCLS}',
                LUACLS = ${LUACLS},
                DECLTYPE = ${DECLTYPE},
                CONV = '${CONV}',
                NUM_VARS = ${NUM_VARS},
            }
        ]])
        t:push('')
    end
    t:push('')
    olua.write(module.TYPE_FILE_PATH, tostring(t))
end

local function is_new_func(module, supercls, fn)
    if not supercls or fn.STATIC then
        return true
    end

    local super = module.visited_type[supercls]
    if not super then
        error(format("not found super class '${supercls}'"))
    elseif super.FUNC[fn.PROTOTYPE] or super.EXCLUDE_FUNC[fn.NAME] then
        return false
    else
        return is_new_func(module, super.SUPERCLS, fn)
    end
end

local function to_prop_name(fn, filter, props)
    if (string.find(fn.NAME, '^get') or string.find(fn.NAME, '^is')) and fn.NUM_ARGS == 0 then
        -- getABCd isAbc => ABCd Abc
        local name = string.gsub(fn.NAME, '^%l+', '')
        return string.gsub(name, '^%u+', function (str)
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
    end
end

local function write_cls_func(module, cls, append)
    local dict = {}
    local func_group = {}
    for _, fn in ipairs(cls.FUNC) do
        if is_new_func(module, cls.SUPERCLS, fn) then
            local arr = dict[fn.NAME]
            if not arr then
                arr = {}
                dict[fn.NAME] = arr
                func_group[#func_group + 1] = arr
            end
            arr[#arr + 1] = fn
        end
    end

    for _, arr in ipairs(func_group) do
        local FUNCS = olua.newarray("', '", "'", "'")
        local has_callback = false
        local fn = arr[1]
        for _, v in ipairs(arr) do
            if v.CALLBACK_KIND or cls.CALLBACK[v.NAME] then
                has_callback = true
            end
            FUNCS[#FUNCS + 1] = v.FUNC
        end
        
        if #arr == 1 then
            local name = to_prop_name(fn)
            if name then
                cls.PROP[name] = {NAME = name}
            end
        end
        if not has_callback then
            if #FUNCS > 0 then
                append(format("cls.func(nil, ${FUNCS})"))
            else
                append(format("cls.func('${fn.NAME}', ${fn.SNIPPET?})"))
            end
        else
            local TAG = fn.NAME:gsub('^set', ''):gsub('^get', '')
            local mode = fn.CALLBACK_KIND == 'RET' and 'OLUA_TAG_SUBEQUAL' or 'OLUA_TAG_REPLACE'
            local callback = cls.CALLBACK[fn.NAME]
            if callback then
                callback.FUNCS = FUNCS
                callback.TAG_MAKER = callback.TAG_MAKER or format('${TAG}')
                callback.TAG_MODE = callback.TAG_MODE or mode
            else
                cls.CALLBACK[fn.NAME] = {
                    NAME = fn.NAME,
                    FUNCS = FUNCS,
                    TAG_MAKER = olua.format '${TAG}',
                    TAG_MODE = mode,
                }
            end
        end
    end
end

local function write_cls_ifdef(module, cls, append)
    for _, v in pairs(cls.IFDEF) do
        append(format([[cls.ifdef('${v.NAME}', '${v.VALUE}')]]))
    end
end

local function write_cls_const(module, cls, append)
    for _, v in ipairs(cls.CONST) do
        append(format([[cls.const('${v.NAME}', '${cls.CPPCLS}::${v.NAME}', '${v.TYPENAME}')]]))
    end
end

local function write_cls_enum(module, cls, append)
    for _, e in ipairs(cls.ENUM) do
        append(format("cls.enum('${e.NAME}', '${e.VALUE}')"))
    end
end

local function write_cls_var(module, cls, append)
    for _, fn in ipairs(cls.VAR) do
        append(format("cls.var('${fn.NAME}', ${fn.SNIPPET?})"))
    end
end

local function write_cls_prop(module, cls, append)
    for _, p in ipairs(cls.PROP) do
        append(format([[cls.prop('${p.NAME}', ${p.GET?}, ${p.SET?})]]))
    end
end

local function write_cls_callback(module, cls, append)
    for i, v in ipairs(cls.CALLBACK) do
        assert(v.FUNCS, cls.CPPCLS .. '::' .. v.NAME)
        local FUNCS = olua.newarray("',\n'", "'", "'"):merge(v.FUNCS)
        local TAG_MAKER = olua.newarray("', '", "'", "'")
        local TAG_MODE = olua.newarray("', '", "'", "'")
        local TAG_STORE = v.TAG_STORE or 'nil'
        local TAG_SCOPE = v.TAG_SCOPE or 'object'
        if type(v.TAG_STORE) == 'string' then
            TAG_STORE = olua.stringify(v.TAG_STORE)
        end
        assert(v.TAG_MAKER, 'no tag maker')
        assert(v.TAG_MODE, 'no tag mode')
        if type(v.TAG_MAKER) == 'string' then
            TAG_MAKER:push(v.TAG_MAKER)
        else
            TAG_MAKER:merge(v.TAG_MAKER)
            TAG_MAKER = format('{${TAG_MAKER}}')
        end
        if type(v.TAG_MODE) == 'string' then
            TAG_MODE:push(v.TAG_MODE)
        else
            TAG_MODE:merge(v.TAG_MODE)
            TAG_MODE = format('{${TAG_MODE}}')
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
            }
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
    end
end

local function write_cls_insert(module, cls, append)
    for _, v in ipairs(cls.INSERT) do
        append(format([[
            cls.insert('${v.NAME}', {
                BEFORE = ${v.CODES.BEFORE?},
                AFTER = ${v.CODES.AFTER?},
                CALLBACK_BEFORE = ${v.CODES.CALLBACK_BEFORE?},
                CALLBACK_AFTER = ${v.CODES.CALLBACK_AFTER?},
            })
        ]]))
    end
end

local function write_cls_alias(module, cls, append)
    for _, v in ipairs(cls.ALIAS) do
        append(format("cls.alias('${v.NAME}', '${v.ALIAS}')"))
    end
end

local function write_classes(module, append)
    append('M.CLASSES = {}')
    append('')
    for _, cls in ipairs(module.CLASSES) do
        if cls.KIND == "enumAlias" or cls.KIND == "conv" then
            goto continue
        end

        module.log("[%s]", cls.CPPCLS)

        append(format("cls = typecls '${cls.CPPCLS}'"))
        append(format('cls.SUPERCLS = ${cls.SUPERCLS?}'))
        append(format('cls.REG_LUATYPE = ${cls.REG_LUATYPE?}'))
        append(format('cls.CHUNK = ${cls.CHUNK?}'))
        append(format('cls.REQUIRE = ${cls.REQUIRE?}'))
        
        write_cls_ifdef(module, cls, append)
        write_cls_const(module, cls, append)
        write_cls_func(module, cls, append)
        write_cls_enum(module, cls, append)
        write_cls_var(module, cls, append)
        write_cls_callback(module, cls, append)
        write_cls_prop(module, cls, append)
        write_cls_insert(module, cls, append)
        write_cls_alias(module, cls, append)

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

        dofile "${module.TYPE_FILE_PATH}"

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

    olua.write(module.FILE_PATH, tostring(t))
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
        files:pushf('export "${v.FILE_PATH}"')
        type_files:pushf('dofile "${v.TYPE_FILE_PATH}"')
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