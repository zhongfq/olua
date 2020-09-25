local olua = {}
package.loaded['olua'] = olua

local scrpath = select(2, ...)
local osn = package.cpath:find('?.dll') and 'windows' or
    ((io.popen('uname'):read("*l"):find('Darwin')) and 'macosx' or 'linux')

if osn == 'windows' then
    olua.HOMEDIR = os.getenv('TMP'):gsub('\\', '/') .. '/olua'
else
    olua.HOMEDIR = os.getenv('HOME') .. '/.olua'
end

-- lua search path
package.path = scrpath:gsub('olua.lua', '?.lua;') .. package.path

-- lua c search path
local suffix = osn == 'windows' and 'dll' or 'so'
local version = string.match(_VERSION, '%d.%d'):gsub('%.', '')
package.cpath = string.format('%s/lib/lua%s/%s/?.%s;%s',
    olua.HOMEDIR, version, osn, suffix, package.cpath)

-- unzip lib and header
if not io.open(olua.HOMEDIR .. '/version') then
    local dir = scrpath:gsub('olua.lua', '')
    local libzip = dir .. 'lib.zip'
    local includezip = dir .. 'include.zip'
    if osn == 'windows' then
        local unzip = dir .. 'unzip.exe'
        os.execute('mkdir ' .. olua.HOMEDIR:gsub('/', '\\'))
        os.execute(unzip .. ' -f ' .. libzip .. ' -o ' .. olua.HOMEDIR)
        os.execute(unzip .. ' -f ' .. includezip .. ' -o ' .. olua.HOMEDIR)
    else
        os.execute('mkdir -p ' .. olua.HOMEDIR)
        os.execute('unzip -o ' .. libzip .. ' -d ' .. olua.HOMEDIR)
        os.execute('unzip -o ' .. includezip .. ' -d ' .. olua.HOMEDIR)
    end
    io.open(olua.HOMEDIR .. '/version', 'w+'):write('1'):close()
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

function olua.write(path, content, verbose)
    local f = io.open(path, 'r')
    if f then
        local flag = f:read("*a") == content
        f:close()
        if flag and verbose ~= false then
            print("up-to-date: " .. path)
            return
        end
    end

    if verbose ~= false then
        print("write: " .. path)
    end

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

function olua.copy(t)
    return setmetatable({}, {__index = t})
end

function olua.newarray(sep, prefix, posfix)
    local mt = {}
    mt.__index = mt

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

function olua.newhash()
    local t = {}
    local arr = {}
    local map = {}

    function t:__len()
        return #arr
    end

    function t:__index(key)
        if type(key) == 'number' then
            return arr[key]
        else
            return map[key]
        end
    end

    function t:__newindex(key, value)
        assert(type(key) == 'string', 'only support string key')
        assert(not map[key], 'key conflict: ' .. key)
        map[key] = value
        arr[#arr + 1] = value
    end

    function t:__pairs()
        return pairs(map)
    end

    function t:__ipairs()
        return ipairs(arr)
    end

    function t:take(key)
        local value = map[key]
        if value then
            for i, v in ipairs(arr) do
                if value == v then
                    table.remove(arr, i)
                    break
                end
            end
        end
        return value
    end

    return setmetatable(t, t)
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
    return string.gsub(line, '${[%w_.?]+}', function (str)
        -- search caller file path
        local level = 1
        local path
        while true do
            local info = debug.getinfo(level, 'Sn')
            if info then
                if info.source == "=[C]" then
                    level = level + 1
                else
                    path = path or info.source
                    if path ~= info.source then
                        break
                    else
                        level = level + 1
                    end
                end
            else
                break
            end
        end

        -- search in the functin local value
        local indent = string.match(line, ' *')
        local key = string.match(str, '[%w_]+')
        local opt = string.match(str, '%?')
        local value = lookup(level + 1, key) or _G[key]
        for field in string.gmatch(string.match(str, "[%w_.]+"), '[^.]+') do
            if not value then
                break
            elseif field ~= key then
                value = value[field]
            end
        end

        if value == nil and not opt then
            error("value not found for '" .. str .. "'")
        end

        -- indent the value if value has multiline
        local prefix, posfix = '', ''
        if type(value) == 'table' then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                value = tostring(value)
            else
                error("no meta method '__tostring' for " .. str)
            end
        elseif value == nil then
            value = 'nil'
        elseif type(value) == 'string' then
            value = tostring(value):gsub('[\n]*$', '')
            if opt then
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

        return prefix .. string.gsub(value, '\n', '\n' .. indent) .. posfix
    end)
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

function olua.export(path)
    local module = dofile(path)
    if #module.CLASSES > 0 then
        olua.gen_header(module)
        olua.gen_source(module)
    elseif #module.CONVS > 0 then
        olua.gen_conv(module)
    end
end

require "typecls"
require "basictype"
require "gen-class"
require "gen-func"
require "gen-callback"
require "gen-conv"
require "checkref"

return olua