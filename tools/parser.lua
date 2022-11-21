local olua = require "olua"

local typeinfo_map = {}
local class_map = {}

local kFLAG_CONST   = 1 << 1  -- is const
local kFLAG_LVALUE  = 1 << 2  -- is left value
local kFLAG_RVALUE  = 1 << 3  -- is right value
local kFLAG_CAST    = 1 << 4  -- is type cast

local format = olua.format

function olua.get_class(cls)
    return cls == '*' and class_map or class_map[cls]
end

function olua.pretty_typename(tn)
    tn = tn:gsub('^ *', '') -- trim head space
    tn = tn:gsub(' *$', '') -- trim tail space
    tn = tn:gsub(' +', ' ') -- remove needless space
    tn = tn:gsub(' *([<>]+) *', '%1') -- remove space around '<>'
    tn = tn:gsub(' *([*&]) *', '%1')  -- remove space around '*&'
    tn = tn:gsub('[*&]+', ' %1')      -- add one space before '*&'
    return tn
end

local function lookup_typeinfo(tn)
    local ti = typeinfo_map[tn]
    if not ti then
        tn = tn:gsub('^const ', '')
        ti = typeinfo_map[tn]
    end
    return ti, tn
end

local function throw_type_error(cpptype, errors)
    print('try type:')
    print('    ' .. table.concat(errors.values, '\n    '))
    local rawtn = cpptype:gsub(' [*&]+$', '')
    olua.error([[
        type info not found: ${cpptype}
        you should do one of:
            * if has the type convertor, use typedef '${cpptype}'
            * if type is pointer or enum, use typeconf '${rawtn}'
            * if type is struct value, use typeconv '${rawtn}'
            * if type not wanted, use excludeany '${rawtn}'
    ]])
end

local function search_type_from_class(cls, cpptype, errors)
    if cls and cls.cppcls then
        local nsarr = {}
        for ns in cls.cppcls:gmatch('[^:]+') do
            nsarr[#nsarr + 1] = ns:match('[^ *&]+') -- remove * &
        end
        while #nsarr > 0 do
            -- const Object * => const ns::Object *
            local ns = table.concat(nsarr, "::")
            local tn = olua.pretty_typename(cpptype:gsub('[%w:_]+ *[*&]*$', ns .. '::%1'))
            local ti = olua.typeinfo(tn, nil, false, false, errors)
            nsarr[#nsarr] = nil
            if ti then
                return ti, tn
            end
        end
    end

    if cls and cls.supercls then
        local super = typeinfo_map[cls.supercls .. ' *']
        olua.assert(super, "super class '${cls.supercls}' of '${cls.cppcls}' is not found")
        return olua.typeinfo(cpptype, super, false, false, errors)
    end
end

local function search_type_from_cast(cpptype, typecast, errors)
    if not typecast then
        return
    elseif not cpptype:find('%*$') then
        -- try pointee
        return olua.typeinfo(cpptype .. ' *', nil, false, false, errors)
    elseif cpptype:find('%*$') then
        -- try reference type
        return olua.typeinfo(cpptype:gsub('[ *]+$', ''), nil, false, false, errors)
    end
end

local function subtype_typeinfo(cls, cpptype, throwerror)
    local subtis = {}
    for subcpptype in cpptype:match('<(.*)>'):gmatch(' *([^,]+)') do
        local subti = olua.typeinfo(subcpptype, cls, throwerror)
        if subti.smartptr then
            subti.cppcls = olua.decltype(subti, true)
            subti.decltype = subti.cppcls
            subti.rawdecl = subcpptype
            subti.luacls = subti.subtypes[1].luacls
        elseif subcpptype:find('<') then
            olua.error([[
                unsupport template class as template args:
                       type: ${cpptype}
                    subtype: ${subcpptype}
            ]])
        end
        subtis[#subtis + 1] = subti
    end
    if throwerror then
        olua.assert(next(subtis), 'not found subtype: ' .. cpptype)
    end
    return subtis
end

--[[
    func: void addChild(const std::vector<const Object *> &child)
    ti = {
        cppcls = std::vector
        rawdecl = const std::vector &
        decltype = std::vector
        flag = kFLAG_CONST | kFLAG_LVALUE
        subtis = {
            [1] = {
                cppcls = 'Object *'
                rawdecl = 'const Object *'
                decltype = 'Object *'
                flag = kFLAG_CONST
            }
        }
    }
]]
function olua.typeinfo(cpptype, cls, throwerror, typecast, errors)
    local tn, ti, subtis, rawdecl -- for tn<T, ...>
    local flag = 0

    throwerror = throwerror ~= false
    typecast = typecast ~= false
    errors = errors or olua.newhash()
    cpptype = olua.pretty_typename(cpptype)

    if cpptype:find('^const') then
        flag = flag | kFLAG_CONST
    end
    if cpptype:find('&&$') then
        flag = flag | kFLAG_RVALUE
    elseif cpptype:find('&$') then
        flag = flag | kFLAG_LVALUE
    end
    
    cpptype = cpptype:gsub('[ &]+$', '')

    -- parse template args
    if cpptype:find('<') then
        subtis = subtype_typeinfo(cls, cpptype, throwerror)
        cpptype = olua.pretty_typename(cpptype:gsub('<.*>', ''))
    end

    rawdecl = cpptype
    ti, tn = lookup_typeinfo(cpptype)
    errors:replace(cpptype, cpptype)

    if ti then
        ti = setmetatable({}, {__index = ti})
    else
        repeat
            -- try type cast
            ti = search_type_from_cast(cpptype, typecast, errors)
            if ti then
                flag = flag | kFLAG_CAST
                rawdecl = cpptype
                goto found
            end

            -- search in class namespace
            ti, tn = search_type_from_class(cls, cpptype, errors)
            if ti then
                cpptype = tn
                rawdecl = cpptype
                goto found
            end

            -- type not found
            if throwerror then
                throw_type_error(cpptype, errors)
            else
                return
            end

            ::found::
        until true
    end

    if rawdecl:find('^const ') then
        flag = flag & (~kFLAG_CONST)
    end

    ti.subtypes = subtis
    ti.rawdecl = rawdecl:gsub('<.*>', '')
    ti.flag = flag

    if ti.subtypes then
        local ttn = olua.decltype(ti, true)
        local tti = typeinfo_map[ttn]
        if tti then
            tn = ttn
            ti = setmetatable({}, {__index = tti})
            ti.flag = flag
            ti.rawdecl = olua.decltype(ti)
        elseif not ti.smartptr then
            for _, subtype in ipairs(subtis) do
                if olua.is_cast_type(subtype) then
                    errors:clear()
                    errors:push(subtype.rawdecl, subtype.rawdecl)
                    throw_type_error(subtype.rawdecl, errors)
                end
            end
        end
    end
    
    return ti, cpptype
end

--[[
    function arg variable must declared with no const type

    eg: Object::call(const std::vector<A *> arg1)

    Object *self = nullptr;
    std::vector<int> arg1;
    olua_to_obj(L, 1, &self, "Object");
    olua_check_std_vector(L, 2, arg1, "A");
    self->call(arg1);
]]
function olua.decltype(ti, checkvalue)
    local exps = olua.newarray('')
    if not checkvalue and olua.is_const_type(ti) then
        exps:push('const ')
    end
    if ti.subtypes then
        local cppcls
        if checkvalue then
            cppcls= ti.cppcls
        else
            cppcls = ti.rawdecl
        end
        local ptr = cppcls:match(' [*]+$') or ''
        exps:push(ptr and cppcls:gsub(' [*]+$', '') or cppcls)
        exps:push('<')
        for i, v in ipairs(ti.subtypes) do
            exps:push(i > 1 and ', ' or '')
            exps:push(olua.is_const_type(v) and 'const ' or '')
            exps:push(v.rawdecl)
        end
        exps:push('>')
        exps:push(ptr)
    else
        exps:push(ti.rawdecl)
    end
    if not checkvalue then
        if olua.is_lvalue_type(ti) then
            exps:push(' &')
        elseif olua.is_rvalue_type(ti) then
            exps:push(' &&')
        end
    end
    return tostring(exps)
end

--
-- parse type attribute and return the rest of string
-- eg: @delref(cmp children) void removeChild(@addref(map children) child)
-- reutrn: {delref={cmp, children}}, void removeChild(@addref(map children) child)
--
local function parse_attr(str)
    local attr = {}
    local static
    str = str:gsub('^ *', '')
    while true do
        local name, value = str:match('^@(%w+)%(([^)]+)%)')
        if name then
            local arr = {}
            for v in value:gmatch('[^ ]+') do
                arr[#arr + 1] = v
            end
            attr[name] = arr
            str = str:gsub('^@(%w+)%(([^)]+)%)', '')
        else
            name = str:match('^@(%w+)')
            if name then
                attr[name] = {}
                str = str:gsub('^@%w+', '')
            else
                break
            end
        end
        str = str:gsub('^ *', '')
    end
    str, static = str:gsub('^ *static *', '')
    attr.static = static > 0
    return attr, str
end

local composite_types = {
    const = true,
    struct = true,
    enum = true,
    union = true,
    signed = true,
    unsigned = true,
    char = true,
    short = true,
    int = true,
    long = true,
    double = true,
}

local function parse_type(str)
    local attr, tn
    attr, str = parse_attr(str)
    -- str = std::function <void (float int)> &arg, ...
    tn = str:match('^[%w_: ]+%b<>[ &*]*') -- parse template type
    if not tn then
        local substr = str
        while true do
            local _, to = substr:find(' *[%w_:]+[ &*]*')
            if not to then
                olua.assert(tn, 'no type')
                break
            end
            local subtn = olua.pretty_typename(substr:sub(1, to))
            subtn = subtn:gsub('[ &*]*$', '') -- rm ' *&'
            if composite_types[subtn] then
                tn = (tn and tn or '') .. substr:sub(1, to)
                substr = substr:sub(to + 1)
            elseif not tn then
                tn = substr:sub(1, to)
                substr = substr:sub(to + 1)
                break
            else
                local ptn = olua.pretty_typename(tn)
                ptn = ptn:gsub('[ &*]*$', '') -- rm ' *&'
                if ptn == 'struct' or ptn == 'const' then
                    tn = (tn and tn or '') .. substr:sub(1, to)
                    substr = substr:sub(to + 1)
                end
                break
            end
        end
    end
    str = str:sub(#tn + 1)
    str = str:gsub('^ *', '')
    return olua.pretty_typename(tn), attr, str
end

local function type_func_info(tn, cls)
    if not tn:find('std::function') then
        return olua.typeinfo(tn, cls)
    else
        return olua.typeinfo('std::function', cls)
    end
end

local parse_args

local function parse_callback(cls, tn)
    local rtn, rtattr
    local ti = type_func_info(tn, cls)
    local declstr = (ti.declfunc or tn):match('<(.*)>') -- match callback function prototype
    rtn, rtattr, declstr = parse_type(declstr)
    declstr = declstr:gsub('^[^(]+', '') -- match callback args

    local ret = {}
    ret.type = olua.typeinfo(rtn, cls)
    ret.decltype = olua.decltype(ret.type)
    ret.attr = rtattr

    local args = parse_args(cls, declstr)
    local decltype = {}
    for _, ai in ipairs(args) do
        decltype[#decltype + 1] = ai.declarg
    end
    decltype = table.concat(decltype, ", ")
    decltype = ('std::function<%s(%s)>'):format(olua.decltype(ret.type), decltype)

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
        declarg          -- declarg: const std::vector<int> &
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
    declstr = declstr:match('%((.*)%)')
    olua.assert(declstr, 'malformed args string')

    while #declstr > 0 do
        local tn, attr, varname, from, to
        tn, attr, declstr = parse_type(declstr)
        if tn == 'void' then
            return args, count
        end

        from, to, varname = declstr:find('^([^ ,]+)')

        if varname then
            declstr = declstr:sub(to + 1)
        end

        declstr = declstr:gsub('^[^,]*,? *', '') -- skip ','

        if attr.ret then
            if tn:find('%*$') then
                attr.ret = 'pointee'
                tn = tn:gsub('%*$', '')
                tn = olua.pretty_typename(tn)
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
            local ti = olua.typeinfo(tn, cls)
            args[#args + 1] = {
                type = ti,
                decltype = olua.decltype(ti, true),
                declarg = olua.decltype(ti),
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
    return str:match('[^ ()]+')
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
        newfi.funcdesc = fi.funcdesc:gsub('@pack *', '')
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
        olua.willdo([[
            parse func:
                class = ${cls.cppcls}
                func = ${declfunc}
        ]])
        if declfunc:find('{') then
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
            local ctor = cls.cppcls:match('[^:]+$')
            local fromcls = cls
            if attr.copyfrom then
                fromcls = olua.typeinfo(attr.copyfrom[1] .. ' *', cls)
            end
            if tn == ctor and str:find('^ *%(') then
                tn = tn .. ' *'
                str = 'new' .. str
                fi.ctor = true
                attr.static = true
            end
            fi.cppfunc = olua.assert(str:match('[^ ()]+'), 'invalid func')
            fi.luafunc = name or fi.cppfunc
            fi.static = attr.static
            fi.funcdesc = declfunc
            fi.insert = {}
            if olua.is_func_type(tn, fromcls) then
                local cb = parse_callback(fromcls, tn)
                fi.ret = {
                    type = setmetatable({
                        decltype = cb.decltype,
                    }, {__index = type_func_info(tn, fromcls)}),
                    decltype = cb.decltype,
                    attr = attr,
                    callback = cb,
                }
            else
                fi.ret.type = olua.typeinfo(tn, fromcls)
                fi.ret.decltype = olua.decltype(fi.ret.type)
                fi.ret.attr = attr
            end
            fi.args, fi.max_args = parse_args(fromcls, str:sub(#fi.cppfunc + 1))
            gen_func_prototype(cls, fi)
            gen_func_pack(cls, fi, arr)
            cls.parsed_funcs:push(declfunc, fi)
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

    if declget then
        if cls.parsed_funcs:has(declget) then
            pi.get = cls.parsed_funcs:get(declget)
        else
            pi.get = olua.parse_func(cls, name, declget)[1]
        end
    end

    if declset then
        if cls.parsed_funcs:has(declset) then
            pi.set = cls.parsed_funcs:get(declset)
        else
            pi.set = olua.parse_func(cls, name, declset)[1]
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
    if tn:find('std::function') then
        return true
    else
        local ti = olua.typeinfo(tn, cls)
        return ti and ti.declfunc
    end
end

function olua.is_cast_type(ti)
    return (ti.flag & kFLAG_CAST) ~= 0
end

function olua.is_rvalue_type(ti)
    return (ti.flag & kFLAG_RVALUE) ~= 0
end

function olua.is_lvalue_type(ti)
    return (ti.flag & kFLAG_LVALUE) ~= 0
end

function olua.is_const_type(ti)
    return (ti.flag & kFLAG_CONST) ~= 0
end

function olua.is_pointer_type(ti)
    if type(ti) == 'string' then
        -- is 'T *'?
        return ti:find('[*]$')
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
    return ti.conv:gsub('[$]+', fn)
end

function olua.typedef(typeinfo)
    for tn in typeinfo.cppcls:gmatch('[^\n\r;]+') do
        local ti = setmetatable({}, {__index = typeinfo})
        tn = olua.pretty_typename(tn)
        ti.cppcls = tn
        ti.rawdecl = tn
        if ti.decltype and ti.decltype:find('std::function') then
            ti.declfunc = ti.decltype
            ti.decltype = tn
        else
            ti.decltype = ti.decltype or tn
        end
        typeinfo_map[tn] = ti

        local rawtn = tn:gsub('<.*>', '')
        if tn:find('<') and not typeinfo_map[rawtn]  then
            typeinfo_map[rawtn] = {
                cppcls = rawtn,
                luacls = ti.luacls:gsub('<.*>', ''),
                conv = ti.conv
            }
        end
    end
end

local function typeconf(...)
    local CMD = {}
    local cls = {
        cppcls = ...,
        funcs = olua.newarray(),
        consts = olua.newarray(),
        enums = olua.newarray(),
        props = olua.newarray(),
        vars = olua.newarray(),
        macros = {},
        prototypes = {},
        parsed_funcs = olua.newhash(),
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
            apply_insert(vi.get)
            apply_insert(vi.set)
        end

        olua.assert(found, 'function not found: ${cls.cppcls}::${name}')
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
        declstr, readonly = declstr:gsub('@readonly *', '')
        declstr = declstr:gsub('[; ]*$', '')
        declstr, static = declstr:gsub('^ *static *', '')

        olua.willdo([[
            parse var:
                class = ${cls.cppcls}
                var = ${declstr}
        ]])

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