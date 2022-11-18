local olua = {}
package.loaded['olua'] = olua

local scrpath = select(2, ...)
local osn = package.cpath:find('?.dll') and 'windows' or
    ((io.popen('uname'):read("*l"):find('Darwin')) and 'macos' or 'linux')

function olua.isdir(path)
    if not string.find(path, '[/\\]$') then
        path = path .. '/'
    end
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok, err
end

function olua.mkdir(dir)
    if not olua.isdir(dir) then
        if osn == 'windows' then
            os.execute('mkdir ' .. dir:gsub('/', '\\'))
        else
            os.execute('mkdir -p ' .. dir)
        end
    end
end

if osn == 'windows' then
    olua.OLUA_HOME = os.getenv('USERPROFILE')
    if not olua.OLUA_HOME then
        olua.OLUA_HOME = os.getenv('TMP'):gsub('\\', '/')
        if olua.OLUA_HOME:find('^C:/Users/') then
            olua.OLUA_HOME = olua.OLUA_HOME:match('^C:/Users/[^/]+')
        end
    end
    olua.OLUA_HOME = olua.OLUA_HOME .. '/.olua'
else
    olua.OLUA_HOME = os.getenv('HOME') .. '/.olua'
end

-- version
olua.OLUA_HOME = olua.OLUA_HOME .. '/v5'
print(' olua home: ' .. olua.OLUA_HOME)

-- lua search path
package.path = scrpath:gsub('[^/.\\]+%.lua$', '?.lua;') .. package.path

-- lua c search path
local suffix = osn == 'windows' and 'dll' or 'so'
local version = string.match(_VERSION, '%d.%d'):gsub('%.', '')
package.cpath = string.format('%s/lua%s/?.%s;%s',
    olua.OLUA_HOME, version, suffix, package.cpath)

-- unzip lib and header
if not olua.isdir(olua.OLUA_HOME)
    or not olua.isdir(olua.OLUA_HOME .. '/lua53')
    or not olua.isdir(olua.OLUA_HOME .. '/lua54')
    or not olua.isdir(olua.OLUA_HOME .. '/include')
then
    local dir = scrpath:gsub('[^/.\\]+%.lua$', 'libs')
    olua.mkdir(olua.OLUA_HOME)
    local function unzip(path)
        local cmd
        if osn == 'windows' then
            cmd = ('%s\\unzip.exe -f %s -o %s'):format(dir, path, olua.OLUA_HOME)
            cmd = cmd:gsub('/', '\\')
        else
            cmd = ('unzip -o %s -d %s'):format(path, olua.OLUA_HOME)
        end
        os.execute(cmd)
    end
    unzip(('%s/%s-lua53.zip'):format(dir, osn))
    unzip(('%s/%s-lua54.zip'):format(dir, osn))
    unzip(dir .. '/include.zip')
end

-- error handle
local willdo = ''
function olua.willdo(exp)
    willdo = olua.format(exp)
end

local function throw_error(msg)
    if #willdo > 0 then
        print(willdo)
    end
    error(msg)
end


function olua.error(exp)
    throw_error(olua.format(exp))
end

function olua.assert(cond, exp)
    if not cond then
        olua.error(exp or '<no assert info>')
    end
    return cond
end

function olua.print(exp)
    print(olua.format(exp))
end

function olua.is_end_with(str, substr)
    local _, e = str:find(substr, #str - #substr + 1, true)
    return e == #str
end

local _ipairs = ipairs
function ipairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__ipairs or _ipairs)(t)
end

local _pairs = pairs
function pairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__pairs or _pairs)(t)
end

function olua.write(path, content)
    local f = io.open(path, 'rb')
    if f then
        local flag = f:read("*a") == content
        f:close()
        if flag then
            print("up-to-date: " .. path)
            return
        end
    end

    print("write: " .. path)

    f = io.open(path, "w+b")
    assert(f, path)
    f:write(content)
    f:flush()
    f:close()
end

function olua.sort(arr, field)
    if field then
        table.sort(arr, function (a, b)
            return a[field] < b[field]
        end)
    else
        table.sort(arr)
    end
    return arr
end

function olua.newarray(sep, prefix, posfix)
    local mt = {}
    mt.__index = mt

    function mt:clear()
        for i = 1, #self do
            self[i] = nil
        end
        return self
    end

    function mt:push(v)
        self[#self + 1] = v
        return self
    end

    function mt:pushf(v)
        self[#self + 1] = olua.format(v)
        return self
    end

    function mt:insert(v)
        table.insert(self, 1, v)
    end

    function mt:insertf(v)
        table.insert(self, 1, olua.format(v))
    end

    function mt:merge(t)
        for _, v in ipairs(t) do
            self[#self + 1] = v
        end
        return self
    end

    function mt:__tostring()
        sep = sep or '\n'
        prefix = prefix or ''
        posfix = posfix or ''
        return prefix .. table.concat(self, sep) .. posfix
    end

    return setmetatable({}, mt)
end

function olua.clone(t, newt)
    newt = newt or {}
    for k, v in pairs(t) do
        newt[k] = v
    end
    return newt
end

function olua.newhash(map_only)
    local hash = {values = {}, map = {}}

    local function checkkey(key)
        if type(key) ~= 'string' then
            error(string.format('only support string key: %s(%s)', key, type(key)))
        end
    end

    function hash:clear()
        hash.values = {}
        hash.map = {}
    end

    function hash:clone()
        local new = olua.newhash(map_only)
        new.values = olua.clone(hash.values, new.values)
        new.map = olua.clone(hash.map, new.map)
        return new
    end

    function hash:get(key)
        checkkey(key)
        return hash.map[key]
    end

    function hash:has(key)
        checkkey(key)
        return hash.map[key] ~= nil
    end

    function hash:push(key, value, message)
        checkkey(key)
        if hash.map[key] then
            error(string.format('key conflict: %s %s', key, message or ''))
        end
        assert(value ~= nil, 'no value')
        hash.map[key] = value
        if not map_only then
            hash.values[#hash.values + 1] = value
        end
    end

    function hash:push_if_not_exist(key, value)
        if not hash:has(key) then
            hash:push(key, value)
        end
    end

    function hash:insert(where, curr, key, value, idx)
        checkkey(key)
        assert(not map_only, 'insert not allowed for map only')
        if where == 'front' then
            idx = 1
        elseif where == 'after' then
            for i, v in ipairs(hash.values) do
                if v == curr then
                    idx = i + 1
                    break
                end
            end
        elseif where == 'before' then
            for i, v in ipairs(hash.values) do
                if v == curr then
                    idx = i
                    break
                end
            end
        elseif where == 'back' then
            idx = #hash.values + 1
        end
        if idx then
            table.insert(hash.values, idx, value)
            hash.map[key] = value
        else
            error(string.format("can't insert value: %s, because current value not found", key))
        end
    end

    function hash:replace(key, value)
        checkkey(key)
        local old = hash.map[key]
        hash.map[key] = value
        if not map_only then
            assert(value ~= nil, "value is nil")
            if old then
                for i, v in ipairs(hash.values) do
                    if v == old then
                        hash.values[i] = value
                        break
                    end
                end
            else
                hash.values[#hash.values + 1] = value
            end
        end
    end

    function hash:take(key)
        checkkey(key)
        local value = hash.map[key]
        hash.map[key] = nil
        if value and not map_only then
            for i, v in ipairs(hash.values) do
                if value == v then
                    table.remove(hash.values, i)
                    break
                end
            end
        end
        return value
    end

    function hash:__len()
        assert(not map_only, '__leng not allowed for map only')
        return #hash.values
    end

    function hash:__index(key)
        error('use get')
    end

    function hash:__newindex(key, value)
        error('use push')
    end

    function hash:__pairs()
        return pairs(hash.map)
    end

    function hash:__ipairs()
        assert(not map_only, 'ipairs not allowed for map only')
        return ipairs(hash.values)
    end

    return setmetatable(hash, hash)
end

local function lookup(level, key, upvalue)
    assert(key and #key > 0, key)

    local value

    for i = 1, 256 do
        local k, v = debug.getlocal(level, i)
        if k == key then
            value = v
        elseif not k then
            break
        end
    end

    if value then
        return value
    end

    local info1 = debug.getinfo(level, 'Snf')
    local info2 = debug.getinfo(level + 1, 'Sn')

    if upvalue then
        for i = 1, 256 do
            local k, v = debug.getupvalue(info1.func, i)
            if k == key then
                return v
            end
        end
    end

    if info1.source == info2.source or
        info1.short_src == info2.short_src then
        return lookup(level + 1, key)
    end
end

local function eval(line)
    local drop = false
    local function replace(str)
        -- search caller file path
        local level = 1
        local path
        while true do
            local info = debug.getinfo(level, 'Sn')
            if not info then
                break
            elseif info.source == "=[C]" then
                level = level + 1
            else
                path = path or info.source
                if path ~= info.source then
                    break
                else
                    level = level + 1
                end
            end
        end

        -- search in the functin local value
        local indent = string.match(line, ' *')
        local key = string.match(str, '[%w_]+')
        local opt = string.match(str, '%?+')
        local fix = string.match(str, '#')
        local value = lookup(level + 1, key, true) or _G[key]
        for field in string.gmatch(string.match(str, "[%w_.]+"), '[^.]+') do
            if not value then
                break
            elseif field ~= key then
                value = value[field]
            end
        end

        if value == nil and not opt then
            throw_error("value not found for '" .. str .. "'")
        end

        -- indent the value if value has multiline
        local prefix, posfix = '', ''
        if type(value) == 'table' then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                value = tostring(value)
            else
                throw_error("no meta method '__tostring' for " .. str)
            end
        elseif value == nil then
            drop = opt == "??"
            value = 'nil'
        elseif type(value) == 'string' then
            value = value:gsub('[\n]*$', '')
            if opt then
                value = olua.trim(value)
                if value:find('[\n\r]') then
                    value = '\n' .. value
                    prefix = '[['
                    posfix =  '\n' .. indent .. ']]'
                    indent = indent .. '    '
                elseif value:find('[\'"]') then
                    value = '[[' .. value .. ']]'
                else
                    value = "'" .. value .. "'"
                end
            end
        else
            value = tostring(value)
        end

        if fix then
            value = value:gsub('[^%w_]+', '_'):gsub('_+$', '')
        end

        return prefix .. value:gsub('\n', '\n' .. indent) .. posfix
    end
    line = line:gsub('${[%w_.?#]+}', replace)
    return not drop and line or nil
end

local function doeval(expr)
    local arr = {}
    local idx = 1
    while idx <= #expr do
        local from, to = string.find(expr, '[\n\r]', idx)
        if not from then
            from = #expr + 1
            to = from
        end
        arr[#arr + 1] = eval(string.sub(expr, idx, from - 1))
        idx = to + 1
    end
    return table.concat(arr, '\n')
end

function olua.trim(expr, indent)
    if type(expr) == 'string' then
        expr = expr:gsub('[\n\r]', '\n')
        expr = expr:gsub('^[\n]*', '') -- trim head '\n'
        expr = expr:gsub('[ \n]*$', '') -- trim tail '\n' or ' '

        local space = string.match(expr, '^[ ]*')
        indent = string.rep(' ', indent or 0)
        expr = expr:gsub('^[ ]*', '')  -- trim head space
        expr = expr:gsub('\n' .. space, '\n' .. indent)
        expr = indent .. expr
    end
    return expr
end

function olua.format(expr, indent)
    expr = doeval(olua.trim(expr, indent))

    while true do
        local s, n = expr:gsub('\n[ ]+\n', '\n\n')
        expr = s
        if n == 0 then
            break
        end
    end

    while true do
        local s, n = expr:gsub('\n\n\n', '\n\n')
        expr = s
        if n == 0 then
            break
        end
    end

    expr = expr:gsub('{\n\n', '{\n')
    expr = expr:gsub('\n\n}', '\n}')

    return expr
end

function olua.command_proxy(cmd, parent)
    local proxy = {}
    assert(cmd.__proxy == nil, "already add command proxy")
    cmd.__proxy = proxy
    function proxy.__index(_, key)
        local f = cmd[key]
        if f then
            return function (...)
                return f(...) or proxy
            end
        elseif parent and parent.__proxy then
            return parent.__proxy[key]
        else
            error(string.format("command '%s' not found", key))
        end
    end

    function proxy.__newindex(_, key, value)
        error(string.format("create command '%s' is not allowed", key))
    end

    return setmetatable(proxy, proxy)
end

require "parser"
require "basictype"
require "gen-class"
require "gen-func"
require "gen-callback"
require "gen-conv"
require "autoconf"

_G.export = olua.export
_G.typedef = olua.typedef
_G.autoconf = olua.autoconf
_G.olua = olua

return olua
