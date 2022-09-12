local olua = require "olua"

local typeinfo_map = {}
local class_map = {}

local format = olua.format

local message = ""
local strgsub = string.gsub
local strsub = string.sub
local strmatch = string.match
local strfind = string.find
local strformat = string.format
local strgmatch = string.gmatch

function olua.get_class(cls)
    return cls == '*' and class_map or class_map[cls]
end

function olua.message(msg)
    message = msg
end

function olua.error(fmt, ...)
    print("parse => " .. message)
    error(strformat(fmt, ...))
end

function olua.assert(cond, fmt, ...)
    if not cond then
        olua.error(fmt or '', ...)
    end
    return cond
end

local function pretty_typename(tn, trimref)
    tn = strgsub(tn, '^ *', '') -- trim head space
    tn = strgsub(tn, ' *$', '') -- trim tail space
    tn = strgsub(tn, ' +', ' ') -- remove needless space

    -- const type * * => const type **
    tn = strgsub(tn, ' *%*', '*')
    tn = strgsub(tn, '%*+', " %1")

    tn = strgsub(tn, ' *&', '&')
    tn = strgsub(tn, '%&+', '%1')

    if trimref then
        tn = strgsub(tn, ' *&+$', '') -- remove '&'
    end

    return tn
end

function olua.typeinfo(tn, cls, silence, variant)
    local ti, ref, subtis, const -- for tn<T, ...>

    tn = pretty_typename(tn, true)
    const = strfind(tn, '^const ')

    -- parse template
    if strfind(tn, '<') then
        subtis = {}
        for subtn in strgmatch(strmatch(tn, '<(.*)>'), '[^,]+') do
            if subtn:find('<') then
                olua.error("unsupport template class as template args: %s", tn)
            end
            subtis[#subtis + 1] = olua.typeinfo(subtn, cls, silence)
        end
        olua.assert(next(subtis), 'not found subtype')
        tn = pretty_typename(strgsub(tn, '<.*>', ''))
    end

    ti = typeinfo_map[tn]

    if ti then
        ti = setmetatable({}, {__index = ti})
    else
        if not variant then
            -- try pointee
            if not ti and not strfind(tn, '%*$') then
                ti = olua.typeinfo(tn .. ' *', nil, true, true)
                ref = ti and tn or nil
            end

            -- try reference type
            if not ti and strfind(tn, '%*$') then
                ti = olua.typeinfo(tn:gsub('[ *]+$', ''), nil, true, true)
                ref = ti and tn or nil
            end
        end

        -- search in class namespace
        if not ti and cls and cls.cppcls then
            local nsarr = {}
            for ns in strgmatch(cls.cppcls, '[^:]+') do
                nsarr[#nsarr + 1] = ns
            end
            while #nsarr > 0 do
                -- const Object * => const ns::Object *
                local ns = table.concat(nsarr, "::")
                local nstn = pretty_typename(strgsub(tn, '[%w:_]+ *%**$', ns .. '::%1'), true)
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
        if not ti and cls and cls.supercls then
            local super = class_map[cls.supercls]
            olua.assert(super, "super class '%s' of '%s' is not found", cls.supercls, cls.cppcls)
            local sti, stn = olua.typeinfo(tn, super, true)
            if sti then
                ti = sti
                tn = stn
            end
        end
    end

    if ti then
        ti.subtypes = subtis or ti.subtypes
        ti.const = const and true or nil
        ti.variant = (ref ~= nil) or ti.variant
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
    local reference = strmatch(typename, '&+')
    local ti, tn = olua.typeinfo(typename, cls)

    if ti.subtypes then
        local arr = {}
        for i, v in ipairs(ti.subtypes) do
            arr[i] = (v.const and 'const ' or '') ..  v.cppcls
        end
        tn = strformat('%s<%s>', tn, table.concat(arr, ', '))
        if isvariable then
            tn = strgsub(tn, 'const *', '')
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
-- reutrn: {delref={cmp, children}}, void removeChild(@addref(map children) child)
--
local function parse_attr(str)
    local attr = {}
    local static
    str = strgsub(str, '^ *', '')
    while true do
        local name, value = strmatch(str, '^@(%w+)%(([^)]+)%)')
        if name then
            local arr = {}
            for v in strgmatch(value, '[^ ]+') do
                arr[#arr + 1] = v
            end
            attr[name] = arr
            str = strgsub(str, '^@(%w+)%(([^)]+)%)', '')
        else
            name = strmatch(str, '^@(%w+)')
            if name then
                attr[name] = {}
                str = strgsub(str, '^@%w+', '')
            else
                break
            end
        end
        str = strgsub(str, '^ *', '')
    end
    str, static = strgsub(str, '^ *static *', '')
    attr.static = static > 0
    return attr, str
end

local composite_types = {
    const = true,
    struct = true,
    signed = true,
    unsigned = true,
    char = true,
    short = true,
    int = true,
    long = true,
}

local function parse_type(str)
    local attr, tn
    attr, str = parse_attr(str)
    -- str = std::function <void (float int)> &arg, ...
    tn = strmatch(str, '^[%w_: ]+%b<>[ &*]*') -- parse template type
    if not tn then
        local substr = str
        while true do
            local _, to = strfind(substr, ' *[%w_:]+[ &*]*')
            if not to then
                olua.assert(tn, 'no type')
                break
            end
            local subtn = pretty_typename(strsub(substr, 1, to))
            subtn = strgsub(subtn, '[ &*]*$', '') -- rm ' *&'
            if composite_types[subtn] then
                tn = (tn and tn or '') .. strsub(substr, 1, to)
                substr = strsub(substr, to + 1)
            elseif not tn then
                tn = strsub(substr, 1, to)
                substr = strsub(substr, to + 1)
                break
            else
                local ptn = pretty_typename(tn)
                ptn = strgsub(ptn, '[ &*]*$', '') -- rm ' *&'
                if ptn == 'struct' or ptn == 'const' then
                    tn = (tn and tn or '') .. strsub(substr, 1, to)
                    substr = strsub(substr, to + 1)
                end
                break
            end
        end
    end
    str = strsub(str, #tn + 1)
    str = strgsub(str, '^ *', '')
    return pretty_typename(tn), attr, str
end

local function type_func_info(tn, cls)
    if not strfind(tn, 'std::function') then
        return olua.typeinfo(tn, cls)
    else
        return olua.typeinfo('std::function', cls)
    end
end

local parse_args

local function parse_callback(cls, tn)
    local rtn, rtattr
    local ti = type_func_info(tn, cls)
    local declstr = strmatch(ti.declfunc or tn, '<(.*)>') -- match callback function prototype
    rtn, rtattr, declstr = parse_type(declstr)
    declstr = strgsub(declstr, '^[^(]+', '') -- match callback args

    local args = parse_args(cls, declstr)
    local decltype = {}
    for _, ai in ipairs(args) do
        decltype[#decltype + 1] = ai.rawdecl
    end
    decltype = table.concat(decltype, ", ")
    decltype = strformat('std::function<%s(%s)>', todecltype(cls, rtn), decltype)

    local ret = {}
    ret.type = olua.typeinfo(rtn, cls)
    ret.decltype = todecltype(cls, rtn)
    ret.attr = rtattr

    return {
        args = args,
        ret = ret,
        decltype = ti.declfunc and ti.decltype or decltype,
    }
end

--[[
    arg struct: void func(@pack const std::vector<int> &points = value)
    {
        type             -- type info
        decltype         -- decltype: std::vector<int>
        rawdecl          -- rawdecl: const std::vector<int> &
        varname          -- var name: points
        attr             -- attr: {pack = true}
        callback = {     -- eg: std::function<void (float, const A *a)>
            args         -- callback functions args: float, A *a
            ret          -- return type info: void type info
            decltype     -- std::function<void (float, const A *)>
        }
    }
]]
function parse_args(cls, declstr)
    local args = {}
    local count = 0
    declstr = strmatch(declstr, '%((.*)%)')
    olua.assert(declstr, 'malformed args string')

    while #declstr > 0 do
        local tn, attr, varname, from, to
        tn, attr, declstr = parse_type(declstr)
        if tn == 'void' then
            return args, count
        end

        from, to, varname = strfind(declstr, '^([^ ,]+)')

        if varname then
            declstr = strsub(declstr, to + 1)
        end

        declstr = strgsub(declstr, '^[^,]*,? *', '') -- skip ','

        if attr.ret then
            if strfind(tn, '%*$') then
                attr.ret = 'pointee'
                tn = strgsub(tn, '%*$', '')
                tn = pretty_typename(tn)
            end
        end

        -- is callback
        if olua.is_func_type(tn, cls) then
            local cb = parse_callback(cls, tn)
            args[#args + 1] = {
                type = setmetatable({
                    decltype = cb.decltype,
                }, {__index = type_func_info(tn, cls)}),
                decltype = cb.decltype,
                varname = varname or '',
                attr = attr,
                callback = cb,
            }
        else
            args[#args + 1] = {
                type = olua.typeinfo(tn, cls),
                decltype = todecltype(cls, tn, true),
                rawdecl = todecltype(cls, tn),
                varname = varname or '',
                attr = attr,
            }
        end

        local num_vars = args[#args].type.num_vars or 1
        if attr.pack and num_vars > 0 then
            count = count + olua.assert(num_vars, args[#args].type.cppcls)
        else
            count = count + 1
        end
    end

    return args, count
end

function olua.func_name(declfunc)
    local _, _, str = parse_type(declfunc)
    return strmatch(str, '[^ ()]+')
end

local function gen_func_prototype(cls, fi)
    -- generate function prototype: void func(int, A *, B *)
    local decl_args = olua.newarray(', ')
    local static = fi.static and "static " or ""
    for _, v in ipairs(fi.args) do
        decl_args:push(v.decltype)
    end
    fi.prototype = format([[
        ${static}${fi.ret.decltype} ${fi.cppfunc}(${decl_args})
    ]])
    cls.prototypes[fi.prototype] = true
end

local function copy(t)
    return setmetatable({}, {__index = t})
end

local function gen_func_pack(cls, fi, funcs)
    local has_pack = false
    for i, arg in ipairs(fi.args) do
        if arg.attr.pack then
            has_pack = true
            break
        end
    end
    -- has @pack? gen one more func
    if has_pack then
        local packarg
        local newfi = copy(fi)
        newfi.ret = copy(fi.ret)
        newfi.ret.attr = copy(fi.ret.attr)
        newfi.args = {}
        newfi.funcdesc = strgsub(fi.funcdesc, '@pack *', '')
        for i in ipairs(fi.args) do
            newfi.args[i] = copy(fi.args[i])
            newfi.args[i].attr = copy(fi.args[i].attr)
            if fi.args[i].attr.pack then
                assert(not packarg, 'too many pack args')
                packarg = fi.args[i]
                newfi.args[i].attr.pack = false
                local num_vars = packarg.type.num_vars
                if num_vars and num_vars > 1 then
                    newfi.max_args = newfi.max_args + 1 - num_vars
                end
            end
        end
        if packarg.type.cppcls == fi.ret.type.cppcls then
            newfi.ret.attr.unpack = fi.ret.attr.unpack or false
            fi.ret.attr.unpack = true
        end
        gen_func_prototype(cls, newfi)
        funcs[#funcs + 1] = newfi
        newfi.index = #funcs
    end
end

local function gen_func_overload(cls, fi, funcs)
    local min_args = math.maxinteger
    for i, arg in ipairs(fi.args) do
        if arg.attr.optional then
            min_args = i - 1
            break
        end
    end
    for i = min_args, #fi.args - 1 do
        local newfi = copy(fi)
        newfi.args = {}
        newfi.insert = {}
        for k = 1, i do
            newfi.args[k] = copy(fi.args[k])
        end
        gen_func_prototype(cls, newfi)
        newfi.max_args = i
        newfi.index = #funcs + 1
        funcs[newfi.index] = newfi
    end
end

function olua.parse_func(cls, name, ...)
    local arr = {max_args = 0}
    for _, declfunc in ipairs({...}) do
        local fi = {ret = {}}
        olua.message(cls.cppcls .. ': ' .. declfunc)
        if strfind(declfunc, '{') then
            fi.luafunc = assert(name)
            fi.cppfunc = name
            fi.snippet = olua.trim(declfunc)
            fi.funcdesc = '<function snippet>'
            fi.ret.type = olua.typeinfo('void', cls)
            fi.ret.attr = {}
            fi.args = {}
            fi.insert = {}
            fi.prototype = false
            fi.max_args = #fi.args
        else
            local tn, attr, str = parse_type(declfunc)
            local ctor = strmatch(cls.cppcls, '[^:]+$')
            if tn == ctor and strfind(str, '^ *%(') then
                tn = tn .. ' *'
                str = 'new' .. str
                fi.ctor = true
                attr.static = true
            end
            fi.cppfunc = strmatch(str, '[^ ()]+')
            fi.luafunc = name or fi.cppfunc
            fi.static = attr.static
            fi.funcdesc = declfunc
            fi.insert = {}
            if olua.is_func_type(tn, cls) then
                local cb = parse_callback(cls, tn, nil)
                fi.ret = {
                    type = setmetatable({
                        decltype = cb.decltype,
                    }, {__index = type_func_info(tn, cls)}),
                    decltype = cb.decltype,
                    attr = attr,
                    callback = cb,
                }
            else
                fi.ret.type = olua.typeinfo(tn, cls)
                fi.ret.decltype = todecltype(cls, tn)
                fi.ret.attr = attr
            end
            fi.args, fi.max_args = parse_args(cls, strsub(str, #fi.cppfunc + 1))
            gen_func_prototype(cls, fi)
            gen_func_pack(cls, fi, arr)
        end
        arr[#arr + 1] = fi
        arr.max_args = math.max(arr.max_args, fi.max_args)
        fi.index = #arr
    end

    return arr
end

local function parse_prop(cls, name, declget, declset)
    local pi = {}
    pi.name = assert(name, 'no prop name')

    -- eg: name = url
    -- try getUrl and getURL
    -- try setUrl and setURL
    local name2 = strgsub(name, '^%l+', function (s)
        return string.upper(s)
    end)

    local function has_func(fi, pn, op)
        pn = strgsub(pn, '^%w', function (s)
            return string.upper(s)
        end)
        local pattern = '^' .. op .. pn .. '$'
        if fi.cppfunc:find(pattern) or fi.luafunc:find(pattern) then
            return true
        else
            -- getXXXXS => getXXXXs?
            pn = pn:sub(1, #pn - 1) .. pn:sub(#pn):lower()
            pattern = '^' .. op .. pn .. '$'
            return fi.cppfunc:find(pattern) or fi.luafunc:find(pattern)
        end
    end

    if declget then
        pi.get = declget and olua.parse_func(cls, name, declget)[1] or nil
    else
        for _, v in ipairs(cls.funcs) do
            local fi = v[1]
            if has_func(fi, name, '[gG]et') or has_func(fi, name, '[iI]s') or
                has_func(fi, name2, '[gG]et') or has_func(fi, name2, '[iI]s')
            then
                olua.message(cls.cppcls .. ': ' .. fi.funcdesc)
                olua.assert(#fi.args == 0 or fi.ret.attr.extend and #fi.args == 1,
                    "function '%s::%s' has arguments", cls.cppcls, fi.cppfunc)
                pi.get = fi
                break
            end
        end
        assert(pi.get, name)
    end

    if declset then
        pi.set = declset and olua.parse_func(cls, name, declset)[1] or nil
    else
        for _, v in ipairs(cls.funcs) do
            local fi = v[1]
            if has_func(fi, name, '[sS]et') or has_func(fi, name2, '[sS]et') then
                pi.set = fi
                break
            end
        end
    end

    if not pi.get.snippet then
        assert(pi.get.ret.type.cppcls ~= 'void', pi.get.funcdesc)
    elseif declget then
        pi.get.cppfunc = 'get_' .. pi.get.cppfunc
    end

    if pi.set and pi.set.snippet and declset then
        pi.set.cppfunc = 'set_' .. pi.set.cppfunc
    end

    return pi
end

function olua.luacls(cppcls)
    local ti = typeinfo_map[cppcls .. ' *'] or typeinfo_map[cppcls]
    assert(ti, 'type not found: ' .. cppcls)
    return ti.luacls
end

function olua.is_func_type(tn, cls)
    if type(tn) == 'table' then
        tn = tn.cppcls
    end
    if strfind(tn, 'std::function') then
        return true
    else
        local ti = olua.typeinfo(tn, cls)
        return ti and ti.declfunc
    end
end

function olua.is_pointer_type(ti)
    if type(ti) == 'string' then
        -- is 'T *'?
        return strfind(ti, '[*]$')
    else
        return ti.luacls and not olua.is_value_type(ti) and not olua.is_func_type(ti)
    end
end

function olua.is_enum_type(cls)
    local ti = typeinfo_map[cls.cppcls] or typeinfo_map[cls.cppcls .. ' *']
    return cls.reg_luatype and olua.is_value_type(ti)
end

function olua.is_oluaret(fi)
    return fi.ret.type.cppcls == 'olua_Return'
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
        ti = ti.decltype
    end
    return ti:find('[*&]$') and '' or ' '
end

function olua.initial_value(ti)
    if olua.is_pointer_type(ti) then
        return 'nullptr'
    else
        return valuetype[ti.decltype] or ''
    end
end

-- enum has cpp cls, but declared as lua_Unsigned
function olua.is_value_type(ti)
    return valuetype[ti.decltype]
end

function olua.conv_func(ti, fn)
    return strgsub(ti.conv, '[$]+', fn)
end

function olua.typedef(typeinfo)
    for tn in strgmatch(typeinfo.cppcls, '[^\n\r;]+') do
        local ti = setmetatable({}, {__index = typeinfo})
        tn = pretty_typename(tn)
        ti.cppcls = tn
        if ti.decltype and strfind(ti.decltype, 'std::function') then
            ti.declfunc = ti.decltype
            ti.decltype = tn
        else
            ti.decltype = ti.decltype or tn
        end
        typeinfo_map[tn] = ti
        typeinfo_map['const ' .. tn] = ti
    end
end

local function typeconf(cppcls)
    local CMD = {}
    local cls = {
        cppcls = cppcls,
        funcs = olua.newarray(),
        consts = olua.newarray(),
        enums = olua.newarray(),
        props = olua.newarray(),
        vars = olua.newarray(),
        macros = {},
        prototypes = {},
    }

    class_map[cls.cppcls] = cls

    function CMD.supercls(supercls)
        cls.supercls = supercls
    end

    function CMD.chunk(chunk)
        cls.chunk = chunk
    end

    function CMD.reg_luatype(reg_luatype)
        cls.reg_luatype = reg_luatype
    end

    function CMD.luaopen(luaopen)
        cls.luaopen = luaopen
    end

    function CMD.indexerror(indexerror)
        cls.indexerror = indexerror
    end

    function CMD.macro(name, value)
        cls.macros[name] = value
    end

    function CMD.func(name, ...)
        cls.funcs:push(olua.parse_func(cls, name, ...))

        local arr = cls.funcs[#cls.funcs]
        for idx = 1, #arr do
            gen_func_overload(cls, arr[idx], arr)
        end
    end

    --[[
        {
            ...
            std::function<void (float)> argN = [storeobj, func](float v) {
                ...
                ${cbefore}
                olua_callback(L, ...)
                ${cafter}
            };
            ...
            ${before}
            self->callfunc(arg1, arg2, ....);
            ${after}
            ...
        return 1;
        }
    ]]
    function CMD.insert(name, codes)
        local found
        local function trim(code)
            return code and olua.trim(code) or nil
        end
        local function apply_insert(fi)
            if fi and (fi.cppfunc == name or fi.luafunc == name) then
                found = true
                fi.insert.before = trim(codes.before)
                fi.insert.after = trim(codes.after)
                fi.insert.cbefore = trim(codes.cbefore)
                fi.insert.cafter = trim(codes.cafter)
            end
        end

        for _, arr in ipairs(cls.funcs) do
            for _, fi in ipairs(arr) do
                apply_insert(fi)
            end
        end
        for _, pi in ipairs(cls.props) do
            apply_insert(pi.get)
            apply_insert(pi.set)
        end
        for _, vi in ipairs(cls.vars) do
            apply_insert(vi.get, true)
            apply_insert(vi.set, true)
        end

        olua.assert(found, 'function not found: %s::%s', cls.cppcls, name)
    end

    function CMD.alias(luafunc, alias)
        local origin_funcs
        for _, arr in ipairs(cls.funcs) do
            if arr[1].luafunc == luafunc then
                origin_funcs = arr
            end
        end

        olua.assert(origin_funcs, 'func not found: ' .. luafunc)

        local alias_funcs = olua.newarray()
        for _, fi in ipairs(origin_funcs) do
            alias_funcs:push(setmetatable({luafunc = assert(alias)}, {__index = fi}))
        end
        cls.funcs:push(alias_funcs)
    end

    --[[
        {
            tag_maker    -- make callback key
            tag_mode     -- how to store or remove function
            tag_store    -- where to store or remove function
            tag_scope    -- once, function, object
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
            {tag_maker = "", tag_mode = "startwith", REMOVE = true}

        remove click callback:
            {tag_maker = "click", tag_mode = "equal", REMOVE = true}

        add new callback:
            {tag_maker = 'click', tag_mode = "new"}

        replace previous callback:
            {tag_maker = 'click', tag_mode = "replace"}
    ]]
    function CMD.callback(opt)
        cls.funcs:push(olua.parse_func(cls, nil, table.unpack(opt.funcs)))
        for i, fi in ipairs(cls.funcs[#cls.funcs]) do
            fi.callback = setmetatable({}, {__index = opt})
            if type(fi.callback.tag_maker) == 'table' then
                fi.callback.tag_maker = assert(fi.callback.tag_maker[i])
            end
            if type(fi.callback.tag_mode) == 'table' then
                fi.callback.tag_mode = assert(fi.callback.tag_mode[i])
            end
        end

        local arr = cls.funcs[#cls.funcs]
        for idx = 1, #arr do
            gen_func_overload(cls, arr[idx], arr)
        end
    end

    function CMD.var(name, declstr)
        local readonly, static
        local rawstr = declstr
        declstr, readonly = strgsub(declstr, '@readonly *', '')
        declstr = strgsub(declstr, '[; ]*$', '')
        declstr, static = strgsub(declstr, '^ *static *', '')

        olua.message(cls.cppcls .. ': ' .. declstr)

        local args = parse_args(cls, '(' .. declstr .. ')')
        name = name or args[1].varname

        -- variable is callback?
        local cb_get
        local cb_set
        if args[1].callback then
            cb_set = {
                tag_maker =  name,
                tag_mode = 'replace',
                tag_store = 0,
                tag_scope = 'object',
            }
            cb_get = {
                tag_maker = name,
                tag_mode = 'equal',
                tag_store = 0,
                tag_scope = 'object',
            }
        end

        -- make getter/setter function
        cls.vars[#cls.vars + 1] = {
            name = assert(name),
            get = {
                luafunc = name,
                cppfunc = 'get_' .. args[1].varname,
                varname = args[1].varname,
                insert = {},
                funcdesc = rawstr,
                ret = {
                    type = args[1].type,
                    decltype = args[1].decltype,
                    attr = {
                        addref = args[1].attr.addref,
                        delref = args[1].attr.delref,
                    },
                },
                static = static > 0,
                variable = true,
                args = {},
                index = 0,
                callback = cb_get,
            },
            set = {
                luafunc = name,
                cppfunc = 'set_' .. args[1].varname,
                varname = args[1].varname,
                insert = {},
                static = static > 0,
                funcdesc = rawstr,
                ret = {
                    type = olua.typeinfo('void', cls),
                    attr = {},
                },
                variable = true,
                args = args,
                index = 0,
                callback = cb_set,
            },
        }

        if readonly > 0 then
            cls.vars[#cls.vars].set = nil
        end
    end

    function CMD.prop(name, get, set)
        assert(not strfind(name, '[^_%w]+'), name)
        cls.props:push(parse_prop(cls, name, get, set))
    end

    function CMD.const(name, value, typename)
        cls.consts:push({
            name = assert(name),
            value = value,
            type = olua.typeinfo(typename, cls),
        })
    end

    function CMD.enum(name, value)
        cls.enums:push({
            name = name,
            value = value or (cls.cppcls .. '::' .. name),
        })
    end

    return cls, CMD
end

function olua.export(path)
    local m = {
        class_types = {},
        convs = {},
    }

    local CMD = {}

    function CMD.__index(_, k)
        return olua[k] or _ENV[k]
    end

    function CMD.__newindex(_, k, v)
        m[k] = v
    end

    function CMD.typeconv(cppcls)
        local conv, SubCMD = typeconf(cppcls)
        m.convs[#m.convs + 1] = conv
        function SubCMD.export(export)
            conv.export = export
        end
        return olua.command_proxy(SubCMD)
    end

    function CMD.typeconf(cppcls)
        local cls, SubCMD = typeconf(cppcls)
        m.class_types[#m.class_types + 1] = cls
        return olua.command_proxy(SubCMD)
    end

    setmetatable(CMD, CMD)
    assert(loadfile(path, nil, CMD))()
    olua.gen_header(m)
    olua.gen_source(m)
end

return olua