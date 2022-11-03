local olua = {}
package.loaded['olua'] = olua

local scrpath = select(2, ...)
local osn = package.cpath:find('?.dll') and 'windows' or
    ((io.popen('uname'):read("*l"):find('Darwin')) and 'macosx' or 'linux')

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
olua.OLUA_HOME = olua.OLUA_HOME .. '/v4'

-- lua search path
package.path = scrpath:gsub('[^/.\\]+%.lua$', '?.lua;') .. package.path

-- lua c search path
local suffix = osn == 'windows' and 'dll' or 'so'
local version = string.match(_VERSION, '%d.%d'):gsub('%.', '')
package.cpath = string.format('%s/lib/lua%s/%s/?.%s;%s',
    olua.OLUA_HOME, version, osn, suffix, package.cpath)

-- unzip lib and header
if not olua.isdir(olua.OLUA_HOME)
    or not olua.isdir(olua.OLUA_HOME .. '/lib')
    or not olua.isdir(olua.OLUA_HOME .. '/include')
then
    local dir = scrpath:gsub('[^/.\\]+%.lua$', '')
    local libzip = string.format('%slib-%s.zip', dir, osn)
    local includezip = dir .. 'include.zip'
    olua.mkdir(olua.OLUA_HOME)
    if osn == 'windows' then
        local unzip = dir .. 'unzip.exe'
        os.execute(unzip .. ' -f ' .. libzip .. ' -o ' .. olua.OLUA_HOME)
        os.execute(unzip .. ' -f ' .. includezip .. ' -o ' .. olua.OLUA_HOME)
    else
        os.execute('unzip -o ' .. libzip .. ' -d ' .. olua.OLUA_HOME)
        os.execute('unzip -o ' .. includezip .. ' -d ' .. olua.OLUA_HOME)
    end
end

-- error handle
local willdo = ''
function olua.willdo(exp)
    willdo = olua.format(exp)
end

function olua.error(exp)
    print(willdo)
    error(olua.format(exp))
end

function olua.assert(cond, exp)
    if not cond then
        olua.error(exp or '<no assert info>')
    end
    return cond
end

function olua.is_end_with(str, substr)
    local _, e = str:find(substr, 1, true)
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
    local f = io.open(path, 'r')
    if f then
        local flag = f:read("*a") == content
        f:close()
        if flag then
            print("up-to-date: " .. path)
            return
        end
    end

    print("write: " .. path)

    f = io.open(path, "w")
    assert(f, path)
    f:write(content)
    f:flush()
    f:close()
end

function olua.stringify(value, quote)
    if value then
        quote = quote or '"'
        return quote .. tostring(value) .. quote
    else
        return nil
    end
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

function olua.newhash()
    local hash = {values = {}, map = {}}

    function hash:clone()
        local new = olua.newhash()
        new.values = olua.clone(hash.values, new.values)
        new.map = olua.clone(hash.map, new.map)
        return new
    end

    function hash:replace(key, value)
        local old = hash.map[key]
        if value == nil then
            error("value is nil")
        end
        hash.map[key] = value
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

    function hash:insert(where, curr, key, value)
        local idx
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
            olua.error("can't insert value: %s, because current value not found", key)
        end
    end

    function hash:take(key)
        local value = hash.map[key]
        if value then
            for i, v in ipairs(hash.values) do
                if value == v then
                    table.remove(hash.values, i)
                    hash.map[key] = nil
                    break
                end
            end
        end
        return value
    end

    local mt = {}
    function mt:__len()
        return #hash.values
    end

    function mt:__index(key)
        if type(key) == 'number' then
            return hash.values[key]
        else
            return hash.map[key]
        end
    end

    function mt:__newindex(key, value)
        assert(type(key) == 'string', 'only support string key')
        assert(not hash.map[key], 'key conflict: ' .. key)
        hash.map[key] = value
        hash.values[#hash.values + 1] = value
    end

    function mt:__pairs()
        return pairs(hash.map)
    end

    function mt:__ipairs()
        return ipairs(hash.values)
    end

    return setmetatable(hash, mt)
end

local function lookup(level, key)
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

    local info1 = debug.getinfo(level, 'Sn')
    local info2 = debug.getinfo(level + 1, 'Sn')
    if info1.source == info2.source or
        info1.short_src == info2.short_src then
        return lookup(level + 1, key)
    end
end

local function eval(line)
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
        local fix = string.match(str, '{{')
        local value = lookup(level + 1, key) or _G[key]
        for field in string.gmatch(string.match(str, "[%w_.]+"), '[^.]+') do
            if not value then
                break
            elseif field ~= key then
                value = value[field]
            end
        end

        if value == nil and not opt then
            olua.error("value not found for '" .. str .. "'")
        end

        -- indent the value if value has multiline
        local prefix, posfix = '', ''
        if type(value) == 'table' then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                value = tostring(value)
            else
                olua.error("no meta method '__tostring' for " .. str)
            end
        elseif value == nil then
            value = 'nil'
        elseif type(value) == 'string' then
            value = value:gsub('[\n]*$', '')
            if opt then
                value = olua.trim(value)
                if string.find(value, '[\n\r]') then
                    value = '\n' .. value
                    prefix = '[['
                    posfix =  '\n' .. indent .. ']]'
                    indent = indent .. '    '
                elseif string.find(value, '[\'"]') then
                    value = '[[' .. value .. ']]'
                else
                    value = "'" .. value .. "'"
                end
            end
        else
            value = tostring(value)
        end

        if fix then
            value = string.gsub(value, '[^%w_]+', '_')
        end

        return prefix .. string.gsub(value, '\n', '\n' .. indent) .. posfix
    end
    line = string.gsub(line, '${[%w_.?]+}', replace)
    line = string.gsub(line, '${{[%w_.?]+}}', replace)
    return line
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
        expr = string.gsub(expr, '[\n\r]', '\n')
        expr = string.gsub(expr, '^[\n]*', '') -- trim head '\n'
        expr = string.gsub(expr, '[ \n]*$', '') -- trim tail '\n' or ' '

        local space = string.match(expr, '^[ ]*')
        indent = string.rep(' ', indent or 0)
        expr = string.gsub(expr, '^[ ]*', '')  -- trim head space
        expr = string.gsub(expr, '\n' .. space, '\n' .. indent)
        expr = indent .. expr
    end
    return expr
end

function olua.format(expr, indent)
    expr = doeval(olua.trim(expr, indent))

    while true do
        local s, n = string.gsub(expr, '\n[ ]+\n', '\n\n')
        expr = s
        if n == 0 then
            break
        end
    end

    while true do
        local s, n = string.gsub(expr, '\n\n\n', '\n\n')
        expr = s
        if n == 0 then
            break
        end
    end

    expr = string.gsub(expr, '{\n\n', '{\n')
    expr = string.gsub(expr, '\n\n}', '\n}')

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