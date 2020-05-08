local file = select(2, ...)
local osn = package.cpath:find('?.dll') and 'windows' or
    ((io.popen('uname'):read("*l"):find('Darwin')) and 'macosx' or 'linux')
local suffix = osn == 'windows' and 'dll' or 'so'
package.path = file:gsub('olua.lua', '?.lua;') .. package.path
package.cpath = file:gsub('olua.lua', ("lib/%s/?.%s;"):format(osn, suffix)) .. package.cpath

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

local olua = {}
package.loaded['olua'] = olua

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

local function eval(expr)
    return string.gsub(expr, "([ ]*)(${[%w_.]+})", function (indent, str)
        local key = string.match(str, "[%w_]+")
        local level = 1
        local path
        -- search caller file path
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
        local value = lookup(level + 1, key) or _G[key]
        for field in string.gmatch(string.match(str, "[%w_.]+"), '[^.]+') do
            if not value then
                break
            elseif field ~= key then
                value = value[field]
            end
        end
        if value == nil then
            error("value not found for '" .. str .. "'")
        else
            -- indent the value if value has multiline
            if type(value) == 'table' then
                local mt = getmetatable(value)
                if mt and mt.__tostring then
                    value = tostring(value)
                else
                    error("no meta method '__tostring' for " .. str)
                end
            end
            value = string.gsub(value, '[\n]*$', '')
            return indent .. string.gsub(tostring(value), '\n', '\n' .. indent)
        end
    end)
end

function olua.format(expr, indent)
    expr = string.gsub(expr, '[\n\r]', '\n')
    expr = string.gsub(expr, '^[\n]*', '') -- trim head '\n'
    expr = string.gsub(expr, '[ \n]*$', '') -- trim tail '\n' or ' '

    local space = string.match(expr, '^[ ]*')
    indent = string.rep(' ', indent or 0)
    expr = string.gsub(expr, '^[ ]*', '')  -- trim head space
    expr = string.gsub(expr, '\n' .. space, '\n' .. indent)
    expr = indent .. expr

    expr = eval(expr)
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