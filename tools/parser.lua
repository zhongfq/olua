local olua = require "olua"

local typeinfo_map = {}
local class_map = {}

local format = olua.format

local message = ""

function olua.get_class(cls)
    return cls == '*' and class_map or class_map[cls]
end

function olua.message(msg)
    message = msg
end

function olua.error(fmt, ...)
    print("parse => " .. message)
    error(string.format(fmt, ...))
end

function olua.assert(cond, fmt, ...)
    if not cond then
        olua.error(fmt or '', ...)
    end
    return cond
end

local function pretty_typename(tn, trimref)
    tn = string.gsub(tn, '^ *', '') -- trim head space
    tn = string.gsub(tn, ' *$', '') -- trim tail space
    tn = string.gsub(tn, ' +', ' ') -- remove needless space

    -- const type * * => const type **
    tn = string.gsub(tn, ' *%*', '*')
    tn = string.gsub(tn, '%*+', " %1")

    tn = string.gsub(tn, ' *&', '&')
    tn = string.gsub(tn, '%&+', '%1')

    if trimref then
        tn = string.gsub(tn, ' *&+$', '') -- remove '&'
    end

    return tn
end

function olua.typeinfo(tn, cls, silence, variant)
    local ti, ref, subtis, const -- for tn<T, ...>

    tn = pretty_typename(tn, true)
    const = string.find(tn, '^const ')

    -- parse template
    if string.find(tn, '<') then
        subtis = {}
        for subtn in string.gmatch(string.match(tn, '<(.*)>'), '[^,]+') do
            subtis[#subtis + 1] = olua.typeinfo(subtn, cls, silence)
        end
        olua.assert(next(subtis), 'not found subtype')
        tn = pretty_typename(string.gsub(tn, '<.*>', ''))
    end

    ti = typeinfo_map[tn]

    if ti then
        ti = setmetatable({}, {__index = ti})
    else
        if not variant then
            -- try pointee
            if not ti and not string.find(tn, '%*$') then
                ti = olua.typeinfo(tn .. ' *', nil, true, true)
                ref = ti and tn or nil
            end

            -- try reference type
            if not ti and string.find(tn, '%*$') then
                ti = olua.typeinfo(tn:gsub('[ *]+$', ''), nil, true, true)
                ref = ti and tn or nil
            end
        end

        -- search in class namespace
        if not ti and cls and cls.CPPCLS then
            local nsarr = {}
            for ns in string.gmatch(cls.CPPCLS, '[^:]+') do
                nsarr[#nsarr + 1] = ns
            end
            while #nsarr > 0 do
                -- const Object * => const ns::Object *
                local ns = table.concat(nsarr, "::")
                local nstn = pretty_typename(string.gsub(tn, '[%w:_]+ *%**$', ns .. '::%1'), true)
                local nsti = olua.typeinfo(nstn, nil, true)
                nsarr[#nsarr] = nil
                if nsti then
                    ti = nsti
                    tn = nstn
                    break
                end
            end
        end

        -- search in super class namespace
        if not ti and cls and cls.SUPERCLS then
            local super = class_map[cls.SUPERCLS]
            olua.assert(super, "super class '%s' of '%s' is not found", cls.SUPERCLS, cls.CPPCLS)
            local sti, stn = olua.typeinfo(tn, super, true)
            if sti then
                ti = sti
                tn = stn
            end
        end
    end

    if ti then
        ti.SUBTYPES = subtis or ti.SUBTYPES
        ti.CONST = const and true or nil
        ti.VARIANT = (ref ~= nil) or ti.VARIANT
        return ti, tn
    elseif not silence then
        olua.error("type info not found: %s", tn)
    end
end

--[[
    function arg variable must declared with no const type

    eg: Object::call(const std::vector<A *> arg1)

    Object *self = nullptr;
    std::vector<int> arg1;
    olua_to_cppobj(L, 1, (void **)&self, "Object");
    olua_check_std_vector(L, 2, arg1, "A");
    self->call(arg1);
]]
local function todecltype(cls, typename, isvariable)
    local reference = string.match(typename, '&+')
    local ti, tn = olua.typeinfo(typename, cls)

    if ti.SUBTYPES then
        local arr = {}
        for i, v in ipairs(ti.SUBTYPES) do
            arr[i] = (v.CONST and 'const ' or '') ..  v.CPPCLS
        end
        tn = string.format('%s<%s>', tn, table.concat(arr, ', '))
        if isvariable then
            tn = string.gsub(tn, 'const *', '')
        end
    end

    if not isvariable and reference then
        tn = tn .. ' ' .. reference
    end

    return tn
end

--
-- parse type attribute and return the rest of string
-- eg: @delref(cmp children) void removeChild(@addref(map children) child)
-- reutrn: {DELREF={cmp, children}}, void removeChild(@addref(map children) child)
--
local function parse_attr(str)
    local attr = {}
    local static
    str = string.gsub(str, '^ *', '')
    while true do
        local name, value = string.match(str, '^@(%w+)%(([^)]+)%)')
        if name then
            local arr = {}
            for v in string.gmatch(value, '[^ ]+') do
                arr[#arr + 1] = v
            end
            attr[string.upper(name)] = arr
            str = string.gsub(str, '^@(%w+)%(([^)]+)%)', '')
        else
            name = string.match(str, '^@(%w+)')
            if name then
                attr[string.upper(name)] = {}
                str = string.gsub(str, '^@%w+', '')
            else
                break
            end
        end
        str = string.gsub(str, '^ *', '')
    end
    str, static = string.gsub(str, '^ *static *', '')
    attr.STATIC = static > 0
    return attr, str
end

local function parse_type(str)
    local attr, tn
    attr, str = parse_attr(str)
    -- str = std::function <void (float int)> &arg, ...
    tn = string.match(str, '^[%w_: ]+%b<>[ &*]*') -- parse template type
    if not tn then
        local from, to
        while true do
            from, to = string.find(str, ' *[%w_:]+[ &*]*', to)
            if not from then
                break
            end
            tn = pretty_typename(string.sub(str, from, to))
            if tn == 'signed' or tn == 'unsigned' then
                local substr = string.sub(str, to + 1)
                -- str = unsigned count = 1, ... ?
                if not (substr:find('^ *int *')
                    or substr:find('^ *short *')
                    or substr:find('^ *long *')
                    or substr:find('^ *char *')) then
                    tn = string.sub(str, 1, to) .. ' int'
                    str = string.sub(str, to + 1)
                    return pretty_typename(tn), attr, str
                end
            end
            if tn ~= 'const' and tn ~= 'signed' and tn ~= 'unsigned' then
                if tn == 'struct' then
                    str = string.sub(str, to + 1)
                else
                    tn = string.sub(str, 1, to)
                    break
                end
            end
        end
    end
    str = string.sub(str, #tn + 1)
    str = string.gsub(str, '^ *', '')
    return pretty_typename(tn), attr, str
end

local function type_func_info(tn, cls)
    if not string.find(tn, 'std::function') then
        return olua.typeinfo(tn, cls)
    else
        return olua.typeinfo('std::function', cls)
    end
end

local parse_args

local function parse_callback(cls, tn)
    local rtn, rtattr
    local ti = type_func_info(tn, cls)
    local declstr = string.match(ti.FUNC_DEF or tn, '<(.*)>') -- match callback function prototype
    rtn, rtattr, declstr = parse_type(declstr)
    declstr = string.gsub(declstr, '^[^(]+', '') -- match callback args

    local args = parse_args(cls, declstr)
    local decltype = {}
    for _, ai in ipairs(args) do
        decltype[#decltype + 1] = ai.RAWDECL
    end
    decltype = table.concat(decltype, ", ")
    decltype = string.format('std::function<%s(%s)>', todecltype(cls, rtn), decltype)

    local RET = {}
    RET.TYPE = olua.typeinfo(rtn, cls)
    RET.DECLTYPE = todecltype(cls, rtn)
    RET.ATTR = rtattr

    return {
        ARGS = args,
        RET = RET,
        DECLTYPE = ti.FUNC_DEF and ti.DECLTYPE or decltype,
    }
end

--[[
    arg struct: void func(@pack const std::vector<int> &points = value)
    {
        TYPE             -- type info
        DECLTYPE         -- decltype: std::vector<int>
        RAWDECL          -- rawdecl: const std::vector<int> &
        VAR_NAME         -- var name: points
        ATTR             -- attr: {PACK = true}
        CALLBACK = {     -- eg: std::function<void (float, const A *a)>
            ARGS         -- callback functions args: float, A *a
            RET          -- return type info: void type info
            DECLTYPE     -- std::function<void (float, const A *)>
        }
    }
]]
function parse_args(cls, declstr)
    local args = {}
    local count = 0
    declstr = string.match(declstr, '%((.*)%)')
    olua.assert(declstr, 'malformed args string')

    while #declstr > 0 do
        local tn, attr, varname, from, to
        tn, attr, declstr = parse_type(declstr)
        if tn == 'void' then
            return args, count
        end

        from, to, varname = string.find(declstr, '^([^ ,]+)')

        if varname then
            declstr = string.sub(declstr, to + 1)
        end

        declstr = string.gsub(declstr, '^[^,]*,? *', '') -- skip ','

        if attr.RET then
            if string.find(tn, '%*$') then
                attr.RET = 'pointee'
                tn = string.gsub(tn, '%*$', '')
                tn = pretty_typename(tn)
            end
        end

        -- is callback
        if olua.is_func_type(tn, cls) then
            local cb = parse_callback(cls, tn)
            args[#args + 1] = {
                TYPE = setmetatable({
                    DECLTYPE = cb.DECLTYPE,
                }, {__index = type_func_info(tn, cls)}),
                DECLTYPE = cb.DECLTYPE,
                VAR_NAME = varname or '',
                ATTR = attr,
                CALLBACK = cb,
            }
        else
            args[#args + 1] = {
                TYPE = olua.typeinfo(tn, cls),
                DECLTYPE = todecltype(cls, tn, true),
                RAWDECL = todecltype(cls, tn),
                VAR_NAME = varname or '',
                ATTR = attr,
            }
        end

        local num_vars = args[#args].TYPE.NUM_VARS or 1
        if attr.PACK and num_vars > 0 then
            count = count + olua.assert(num_vars, args[#args].TYPE.CPPCLS)
        else
            count = count + 1
        end
    end

    return args, count
end

function olua.func_name(declfunc)
    local _, _, str = parse_type(declfunc)
    return string.match(str, '[^ ()]+')
end

local function gen_func_prototype(cls, fi)
    -- generate function prototype: void func(int, A *, B *)
    local DECL_ARGS = olua.newarray(', ')
    local STATIC = fi.STATIC and "static " or ""
    for _, v in ipairs(fi.ARGS) do
        DECL_ARGS:push(v.DECLTYPE)
    end
    fi.PROTOTYPE = format([[
        ${STATIC}${fi.RET.DECLTYPE} ${fi.CPP_FUNC}(${DECL_ARGS})
    ]])
    cls.PROTOTYPES[fi.PROTOTYPE] = true
end

local function copy(t)
    return setmetatable({}, {__index = t})
end

local function gen_func_pack(cls, fi, funcs)
    local has_pack = false
    for i, arg in ipairs(fi.ARGS) do
        if arg.ATTR.PACK then
            has_pack = true
            break
        end
    end
    -- has @pack? gen one more func
    if has_pack then
        local packarg
        local newfi = copy(fi)
        newfi.RET = copy(fi.RET)
        newfi.RET.ATTR = copy(fi.RET.ATTR)
        newfi.ARGS = {}
        newfi.FUNC_DESC = string.gsub(fi.FUNC_DESC, '@pack *', '')
        for i in ipairs(fi.ARGS) do
            newfi.ARGS[i] = copy(fi.ARGS[i])
            newfi.ARGS[i].ATTR = copy(fi.ARGS[i].ATTR)
            if fi.ARGS[i].ATTR.PACK then
                assert(not packarg, 'too many pack args')
                packarg = fi.ARGS[i]
                newfi.ARGS[i].ATTR.PACK = false
                local num_vars = packarg.TYPE.NUM_VARS
                if num_vars and num_vars > 1 then
                    newfi.MAX_ARGS = newfi.MAX_ARGS + 1 - num_vars
                end
            end
        end
        if packarg.TYPE.CPPCLS == fi.RET.TYPE.CPPCLS then
            newfi.RET.ATTR.UNPACK = fi.RET.ATTR.UNPACK or false
            fi.RET.ATTR.UNPACK = true
        end
        gen_func_prototype(cls, newfi)
        funcs[#funcs + 1] = newfi
        newfi.INDEX = #funcs
    end
end

local function gen_func_overload(cls, fi, funcs)
    local min_args = math.maxinteger
    for i, arg in ipairs(fi.ARGS) do
        if arg.ATTR.OPTIONAL then
            min_args = i - 1
            break
        end
    end
    for i = min_args, #fi.ARGS - 1 do
        local newfi = copy(fi)
        newfi.ARGS = {}
        newfi.INSERT = {}
        for k = 1, i do
            newfi.ARGS[k] = copy(fi.ARGS[k])
        end
        gen_func_prototype(cls, newfi)
        newfi.MAX_ARGS = i
        newfi.INDEX = #funcs + 1
        funcs[newfi.INDEX] = newfi
    end
end

local function parse_func(cls, name, ...)
    local arr = {MAX_ARGS = 0}
    for _, declfunc in ipairs({...}) do
        local fi = {RET = {}}
        olua.message(declfunc)
        if string.find(declfunc, '{') then
            fi.LUA_FUNC = assert(name)
            fi.CPP_FUNC = name
            fi.SNIPPET = olua.trim(declfunc)
            fi.FUNC_DESC = '<function snippet>'
            fi.RET.TYPE = olua.typeinfo('void', cls)
            fi.RET.ATTR = {}
            fi.ARGS = {}
            fi.INSERT = {}
            fi.PROTOTYPE = false
            fi.MAX_ARGS = #fi.ARGS
        else
            local tn, attr, str = parse_type(declfunc)
            local ctor = string.match(cls.CPPCLS, '[^:]+$')
            if tn == ctor and string.find(str, '^%(') then
                tn = tn .. ' *'
                str = 'new' .. str
                fi.CTOR = true
                attr.STATIC = true
            end
            fi.CPP_FUNC = string.match(str, '[^ ()]+')
            fi.LUA_FUNC = name or fi.CPP_FUNC
            fi.STATIC = attr.STATIC
            fi.FUNC_DESC = declfunc
            fi.INSERT = {}
            if olua.is_func_type(tn, cls) then
                local cb = parse_callback(cls, tn, nil)
                fi.RET = {
                    TYPE = setmetatable({
                        DECLTYPE = cb.DECLTYPE,
                    }, {__index = type_func_info(tn, cls)}),
                    DECLTYPE = cb.DECLTYPE,
                    ATTR = attr,
                    CALLBACK = cb,
                }
            else
                fi.RET.TYPE = olua.typeinfo(tn, cls)
                fi.RET.DECLTYPE = todecltype(cls, tn)
                fi.RET.ATTR = attr
            end
            fi.ARGS, fi.MAX_ARGS = parse_args(cls, string.sub(str, #fi.CPP_FUNC + 1))
            gen_func_prototype(cls, fi)
            gen_func_pack(cls, fi, arr)
        end
        arr[#arr + 1] = fi
        arr.MAX_ARGS = math.max(arr.MAX_ARGS, fi.MAX_ARGS)
        fi.INDEX = #arr
    end

    return arr
end

local function parse_prop(cls, name, declget, declset)
    local pi = {}
    pi.NAME = assert(name, 'no prop name')

    -- eg: name = url
    -- try getUrl and getURL
    -- try setUrl and setURL
    local name2 = string.gsub(name, '^%l+', function (s)
        return string.upper(s)
    end)

    local function test(fi, n, op)
        n = op .. string.gsub(n, '^%w', function (s)
            return string.upper(s)
        end)
        if n == fi.CPP_FUNC or n == fi.LUA_FUNC then
            return true
        else
            -- getXXXXS => getXXXXs?
            n = n:sub(1, #n - 1) .. n:sub(#n):lower()
            return n == fi.CPP_FUNC or n == fi.LUA_FUNC
        end
    end

    if declget then
        pi.GET = declget and parse_func(cls, name, declget)[1] or nil
    else
        for _, v in ipairs(cls.FUNCS) do
            local fi = v[1]
            if test(fi, name, 'get') or test(fi, name, 'is') or
                test(fi, name2, 'get') or test(fi, name2, 'is') then
                olua.message(fi.FUNC_DESC)
                olua.assert(#fi.ARGS == 0, "function '%s::%s' has arguments", cls.CPPCLS, fi.CPP_FUNC)
                pi.GET = fi
                break
            end
        end
        assert(pi.GET, name)
    end

    if declset then
        pi.SET = declset and parse_func(cls, name, declset)[1] or nil
    else
        for _, v in ipairs(cls.FUNCS) do
            local fi = v[1]
            if test(fi, name, 'set') or test(fi, name2, 'set') then
                pi.SET = fi
                break
            end
        end
    end

    if not pi.GET.SNIPPET then
        assert(pi.GET.RET.TYPE.CPPCLS ~= 'void', pi.GET.FUNC_DESC)
    elseif declget then
        pi.GET.CPP_FUNC = 'get_' .. pi.GET.CPP_FUNC
    end

    if pi.SET and pi.SET.SNIPPET and declset then
        pi.SET.CPP_FUNC = 'set_' .. pi.SET.CPP_FUNC
    end

    return pi
end

function olua.luacls(cppcls)
    local ti = typeinfo_map[cppcls .. ' *'] or typeinfo_map[cppcls]
    assert(ti, 'type not found: ' .. cppcls)
    return ti.LUACLS
end

function olua.is_func_type(tn, cls)
    if type(tn) == 'table' then
        tn = tn.CPPCLS
    end
    if string.find(tn, 'std::function') then
        return true
    else
        local ti = olua.typeinfo(tn, cls)
        return ti and ti.FUNC_DEF
    end
end

function olua.is_pointer_type(ti)
    if type(ti) == 'string' then
        -- is 'T *'?
        return string.find(ti, '[*]$')
    else
        return not ti.FUNC_DEF and ti.LUACLS and not olua.is_value_type(ti)
    end
end

function olua.is_enum_type(cls)
    local ti = typeinfo_map[cls.CPPCLS] or typeinfo_map[cls.CPPCLS .. ' *']
    return cls.REG_LUATYPE and olua.is_value_type(ti)
end

local valuetype = {
    ['bool'] = 'false',
    ['const char *'] = 'nullptr',
    ['std::string'] = '',
    ['std::function'] = 'nullptr',
    ['lua_Number'] = '0',
    ['lua_Integer'] = '0',
    ['lua_Unsigned'] = '0',
}

function olua.typespace(ti)
    if type(ti) ~= 'string' then
        ti = ti.DECLTYPE
    end
    return ti:find('[*&]$') and '' or ' '
end

function olua.initial_value(ti)
    if olua.is_pointer_type(ti) then
        return 'nullptr'
    else
        return valuetype[ti.DECLTYPE] or ''
    end
end

-- enum has cpp cls, but declared as lua_Unsigned
function olua.is_value_type(ti)
    return valuetype[ti.DECLTYPE]
end

function olua.conv_func(ti, fn)
    return string.gsub(ti.CONV, '[$]+', fn)
end

function olua.typedef(typeinfo)
    for tn in string.gmatch(typeinfo.CPPCLS, '[^\n\r]+') do
        local ti = setmetatable({}, {__index = typeinfo})
        tn = pretty_typename(tn)
        ti.CPPCLS = tn
        if ti.DECLTYPE and string.find(ti.DECLTYPE, 'std::function') then
            ti.FUNC_DEF = ti.DECLTYPE
            ti.DECLTYPE = tn
        else
            ti.DECLTYPE = ti.DECLTYPE or tn
        end
        typeinfo_map[tn] = ti
        typeinfo_map['const ' .. tn] = ti
    end
end

local function typeconf(cppcls)
    local cls = {
        CPPCLS = cppcls,
        FUNCS = {},
        CONSTS = {},
        ENUMS = {},
        PROPS = {},
        VARS = {},
        IFDEFS = {},
        PROTOTYPES = {},
    }

    class_map[cls.CPPCLS] = cls

    function cls.supercls(supercls)
        cls.SUPERCLS = supercls
    end

    function cls.chunk(chunk)
        cls.CHUNK = chunk
    end

    function cls.reg_luatype(reg_luatype)
        cls.REG_LUATYPE = reg_luatype
    end

    function cls.require(require)
        cls.REQUIRE = require
    end

    function cls.ifdef(name, value)
        cls.IFDEFS[name] = value
    end

    function cls.func(name, ...)
        cls.FUNCS[#cls.FUNCS + 1] = parse_func(cls, name, ...)

        local arr = cls.FUNCS[#cls.FUNCS]
        for idx = 1, #arr do
            gen_func_overload(cls, arr[idx], arr)
        end
    end

    --[[
        {
            ...
            std::function<void (float)> argN = [storeobj, func](float v) {
                ...
                ${CALLBACK_BEFORE}
                olua_callback(L, ...)
                ${CALLBACK_AFTER}
            };
            ...
            ${BEFORE}
            self->callfunc(arg1, arg2, ....);
            ${AFTER}
            ...
        return 1;
        }
    ]]
    function cls.insert(name, codes)
        local found
        local function trim(code)
            return code and olua.trim(code) or nil
        end
        local function apply_insert(fi)
            if fi and (fi.CPP_FUNC == name or fi.LUA_FUNC == name) then
                found = true
                fi.INSERT.BEFORE = trim(codes.BEFORE)
                fi.INSERT.AFTER = trim(codes.AFTER)
                fi.INSERT.CALLBACK_BEFORE = trim(codes.CALLBACK_BEFORE)
                fi.INSERT.CALLBACK_AFTER = trim(codes.CALLBACK_AFTER)
            end
        end

        for _, arr in ipairs(cls.FUNCS) do
            for _, fi in ipairs(arr) do
                apply_insert(fi)
            end
        end
        for _, pi in ipairs(cls.PROPS) do
            apply_insert(pi.GET)
            apply_insert(pi.SET)
        end
        for _, vi in ipairs(cls.VARS) do
            apply_insert(vi.GET, true)
            apply_insert(vi.SET, true)
        end

        olua.assert(found, 'function not found: %s::%s', cls.CPPCLS, name)
    end

    function cls.alias(func, aliasname)
        local funcs = {}
        for _, arr in ipairs(cls.FUNCS) do
            for _, fi in ipairs(arr) do
                if fi.LUA_FUNC == func then
                    funcs[#funcs + 1] = setmetatable({LUA_FUNC = assert(aliasname)}, {__index = fi})
                end
            end
            if #funcs > 0 then
                cls.FUNCS[#cls.FUNCS + 1] = funcs
                return
            end
        end

        error('func not found: ' .. func)
    end

    --[[
        {
            TAG_MAKER    -- make callback key
            TAG_MODE     -- how to store or remove function
            TAG_STORE    -- where to store or remove function
            TAG_SCOPE    -- once, function, object
                            * once      remove after callback invoked
                            * function  remove after function invoked
                            * object    callback will exist until object die
        }

        TAG: .callback#[id++]@tag

        userdata.uservalue {
            .callback#0@click = clickfunc1,
            .callback#1@click = clickfunc2,
            .callback#2@remove = removefunc,
        }

        remove all callback:
            {TAG_MAKER = "", TAG_MODE = "substartwith", REMOVE = true}

        remove click callback:
            {TAG_MAKER = "click", TAG_MODE = "subequal", REMOVE = true}

        add new callback:
            {TAG_MAKER = 'click', TAG_MODE = "new"}

        replace previous callback:
            {TAG_MAKER = 'click', TAG_MODE = "replace"}
    ]]
    function cls.callback(opt)
        cls.FUNCS[#cls.FUNCS + 1] = parse_func(cls, nil, table.unpack(opt.FUNCS))
        for i, fi in ipairs(cls.FUNCS[#cls.FUNCS]) do
            fi.CALLBACK = setmetatable({}, {__index = opt})
            if type(fi.CALLBACK.TAG_MAKER) == 'table' then
                fi.CALLBACK.TAG_MAKER = assert(fi.CALLBACK.TAG_MAKER[i])
            end
            if type(fi.CALLBACK.TAG_MODE) == 'table' then
                fi.CALLBACK.TAG_MODE = assert(fi.CALLBACK.TAG_MODE[i])
            end
        end

        local arr = cls.FUNCS[#cls.FUNCS]
        for idx = 1, #arr do
            gen_func_overload(cls, arr[idx], arr)
        end
    end

    function cls.var(name, declstr)
        local readonly, static
        local rawstr = declstr
        declstr, readonly = string.gsub(declstr, '@readonly *', '')
        declstr = string.gsub(declstr, '[; ]*$', '')
        declstr, static = string.gsub(declstr, '^ *static *', '')

        olua.message(declstr)

        local ARGS = parse_args(cls, '(' .. declstr .. ')')
        name = name or ARGS[1].VAR_NAME

        -- variable is callback?
        local CALLBACK_GET
        local CALLBACK_SET
        if ARGS[1].CALLBACK then
            CALLBACK_SET = {
                TAG_MAKER =  name,
                TAG_MODE = 'replace',
            }
            CALLBACK_GET = {
                TAG_MAKER = name,
                TAG_MODE = 'subequal',
            }
        end

        -- make getter/setter function
        cls.VARS[#cls.VARS + 1] = {
            NAME = assert(name),
            GET = {
                LUA_FUNC = name,
                CPP_FUNC = 'get_' .. ARGS[1].VAR_NAME,
                VAR_NAME = ARGS[1].VAR_NAME,
                INSERT = {},
                FUNC_DESC = rawstr,
                RET = {
                    TYPE = ARGS[1].TYPE,
                    DECLTYPE = ARGS[1].DECLTYPE,
                    ATTR = {
                        ADDREF = ARGS[1].ATTR.ADDREF,
                        DELREF = ARGS[1].ATTR.DELREF,
                    },
                },
                STATIC = static > 0,
                VARIABLE = true,
                ARGS = {},
                INDEX = 0,
                CALLBACK = CALLBACK_GET,
            },
            SET = {
                LUA_FUNC = name,
                CPP_FUNC = 'set_' .. ARGS[1].VAR_NAME,
                VAR_NAME = ARGS[1].VAR_NAME,
                INSERT = {},
                STATIC = static > 0,
                FUNC_DESC = rawstr,
                RET = {
                    TYPE = olua.typeinfo('void', cls),
                    ATTR = {},
                },
                VARIABLE = true,
                ARGS = ARGS,
                INDEX = 0,
                CALLBACK = CALLBACK_SET,
            },
        }

        if readonly > 0 then
            cls.VARS[#cls.VARS].SET = nil
        end
    end

    function cls.prop(name, get, set)
        assert(not string.find(name, '[^_%w]+'), name)
        cls.PROPS[#cls.PROPS + 1] = parse_prop(cls, name, get, set)
    end

    function cls.const(name, value, typename)
        cls.CONSTS[#cls.CONSTS + 1] = {
            NAME = assert(name),
            VALUE = value,
            TYPE = olua.typeinfo(typename, cls),
        }
    end

    function cls.enum(name, value)
        cls.ENUMS[#cls.ENUMS + 1] = {
            NAME = name,
            VALUE = value or (cls.CPPCLS .. '::' .. name),
        }
    end

    return cls
end

function olua.export(path)
    local m = {
        CLASSES = {},
        CONVS = {},
    }

    local CMD = {}

    function CMD.__index(_, k)
        return olua[k] or _ENV[k]
    end

    function CMD.__newindex(_, k, v)
        m[k] = v
    end

    function CMD.typeconv(cppcls)
        local conv = typeconf(cppcls)
        m.CONVS[#m.CONVS + 1] = conv
        return olua.command_proxy(conv)
    end

    function CMD.typeconf(cppcls)
        local cls = typeconf(cppcls)
        m.CLASSES[#m.CLASSES + 1] = cls
        return olua.command_proxy(cls)
    end

    setmetatable(CMD, CMD)
    assert(loadfile(path, nil, CMD))()
    olua.gen_header(m)
    olua.gen_source(m)
end

return olua