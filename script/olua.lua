olua = {}

local is_windows = package.config:find("\\")

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

---Suppress warnings.
---@param ... unknown
function olua.unuse(...)
end

function olua.print(fmt, ...)
    print(string.format(fmt, ...))
end

function olua.isdir(path)
    if not string.find(path, "[/\\]$") then
        path = path .. "/"
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
        if is_windows then
            os.execute("mkdir " .. dir:gsub("/", "\\"))
        else
            os.execute("mkdir -p " .. dir)
        end
    end
end

function olua.write(path, content)
    local f = io.open(path, "rb")
    if f then
        local flag = f:read("*a") == content
        f:close()
        if flag then
            olua.print("up-to-date: %s", path)
            return
        end
    end

    olua.print("write: %s", path)

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

function olua.ipairs(t, walk)
    for i, v in ipairs(t) do
        walk(i, v)
    end
end

function olua.pairs(t, walk)
    for k, v in pairs(t) do
        walk(k, v)
    end
end

-------------------------------------------------------------------------------
-- Error handle
-------------------------------------------------------------------------------

local willdo = ""

---Will do the job.
---@param message string
function olua.willdo(message)
    willdo = olua.format(message)
end

local function throw_error(msg)
    if #willdo > 0 then
        print(willdo)
    end
    error(msg)
end

---Throw error.
---@param message string
function olua.error(message)
    throw_error(olua.format(message))
end

---Check the value
---@generic T
---@param value T
---@param message? string
---@return T
function olua.assert(value, message)
    if not value then
        olua.error(message or "<no assert info>")
    end
    return value
end

---Clone a table.
---@param t table
---@param new? table
function olua.clone(t, new)
    new = new or {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

---Create a new array.
---@param ... any
---@return array
function olua.array(...)
    ---@class array
    local array = {}

    local joiner = {}

    ---@private
    array.__index = array

    ---Clear the array.
    function array:clear()
        for i = 1, #self do
            self[i] = nil
        end
    end

    ---@param sep string
    ---@param prefix? string
    ---@param posfix? string
    ---@return self
    function array:set_joiner(sep, prefix, posfix)
        joiner.sep = sep
        joiner.prefix = prefix
        joiner.posfix = posfix
        return self
    end

    ---Clone the array.
    ---@return array
    function array:clone()
        return self:slice()
    end

    ---Push an element at the end of the array. If `value` is `nil`, nothing is done.
    ---@param value any
    function array:push(value)
        if value ~= nil then
            table.insert(self, value)
        end
    end

    function array:pushf(value)
        self:push(olua.format(value))
    end

    ---Remove and return the last element of the array.
    ---@return any
    function array:pop()
        return table.remove(self)
    end

    ---Remove and return the first element of the array.
    function array:shift()
        return table.remove(self, 1)
    end

    ---Push an element at the beginning of the array. If `value` is `nil`, nothing is done.
    ---@param value any
    function array:unshift(value)
        if value ~= nil then
            table.insert(self, 1, value)
        end
    end

    ---Insert an element at the specified position. If `value` is `nil`, nothing is done.
    ---@param index integer
    ---@param value any
    function array:insert(index, value)
        if value ~= nil then
            table.insert(self, index, value)
        end
    end

    ---Remove an element from the array.
    ---@param value any
    function array:remove(value)
        for i = 1, #self do
            if self[i] == value then
                table.remove(self, i)
                break
            end
        end
    end

    ---Remove an element at the specified position from the array.
    ---@param index any
    ---@return unknown|nil
    function array:remove_at(index)
        if index >= 1 and index <= #self then
            return table.remove(self, index)
        end
    end

    ---Concatenate the array with another array.
    ---@param arr array
    ---@return self
    function array:concat(arr)
        for _, v in ipairs(arr) do
            self:push(v)
        end
        return self
    end

    ---
    ---Return the index of the value, or 0 if not found.
    ---
    ---@param value any
    ---@return integer
    function array:index_of(value)
        for i, v in ipairs(self) do
            if v == value then
                return i
            end
        end
        return 0
    end

    ---Sort the array.
    ---@param field? string | fun(a:any, b:any):boolean
    ---@return self
    function array:sort(field)
        if type(field) == "function" then
            table.sort(self, field)
        elseif field then
            table.sort(self, function (a, b)
                return a[field] < b[field]
            end)
        else
            table.sort(self)
        end
        return self
    end

    ---Get a slice of the array.
    ---@param from? integer
    ---@param to? integer
    ---@return array
    function array:slice(from, to)
        local arr = olua.array():set_joiner(joiner.sep, joiner.prefix, joiner.posfix)
        for i = from or 1, to or #self do
            if i > #self then
                break
            end
            arr:push(self[i])
        end
        return arr
    end

    ---Iterate over the array.
    ---@param fn fun(value:any, index:integer, array:array)
    function array:foreach(fn)
        for i, v in ipairs(self) do
            fn(v, i, self)
        end
    end

    ---Join the array with a separator.
    ---@param sep string
    ---@param prefix? string
    ---@param posfix? string
    function array:join(sep, prefix, posfix)
        prefix = prefix or ""
        posfix = posfix or ""
        return prefix .. table.concat(self, sep) .. posfix
    end

    ---@private
    function array:__tostring()
        return self:join(joiner.sep or "", joiner.prefix, joiner.posfix)
    end

    return setmetatable({ ... }, array)
end

---Create a new ordered map.
---@param overwritable? boolean Can overwrite the value with the same key, default is `true`.
---@return ordered_map
function olua.ordered_map(overwritable)
    ---@class ordered_map
    ---@field private keys array
    ---@field private map table
    local ordered_map = {
        keys = olua.array(),
        map = {}
    }

    overwritable = overwritable ~= false

    ---@private
    ---@param key string|integer
    ---@return any
    function ordered_map:__index(key)
        return self:get(key)
    end

    ---@private
    ---@param key string|integer
    ---@param value any
    function ordered_map:__newindex(key, value)
        self:set(key, value)
    end

    ---@private
    function ordered_map:__len()
        return #self.keys
    end

    ---@private
    function ordered_map:__pairs()
        return pairs(self.map)
    end

    ---@private
    function ordered_map:__ipairs()
        return ipairs(self:values())
    end

    ---Clone the ordered map.
    ---@return ordered_map
    function ordered_map:clone()
        local new_map = olua.ordered_map(overwritable)
        self:foreach(function (value, key)
            new_map:set(key, value)
        end)
        return new_map
    end

    ---Set value with the key.
    ---@param key any
    ---@param value any
    function ordered_map:set(key, value)
        if self.keys:index_of(key) == 0 then
            if value ~= nil then
                self.map[key] = value
                self.keys:push(key)
            end
        elseif overwritable then
            self.map[key] = value
            if value == nil then
                self.keys:remove(key)
            end
        else
            error(string.format("key '%s' already exists", key))
        end
    end

    ---Replace value with the key.
    ---@param key string|integer
    ---@param value any
    function ordered_map:replace(key, value)
        self.map[key] = value
        if self.keys:index_of(key) == 0 then
            self.keys:push(key)
        end
    end

    ---Get value with the key.
    ---@param key string|integer
    ---@return unknown
    function ordered_map:get(key)
        return self.map[key]
    end

    ---Check if the key exists.
    ---@param key string|integer
    ---@return boolean
    function ordered_map:has(key)
        return self.map[key] ~= nil
    end

    ---Remove value with the key.
    ---@param key string|integer
    function ordered_map:remove(key)
        self.keys:remove(key)
        self.map[key] = nil
    end

    ---Take value with the key.
    ---@param key string|integer
    ---@return any
    function ordered_map:take(key)
        local value = self.map[key]
        self.keys:remove(key)
        self.map[key] = nil
        return value
    end

    ---Iterate over the ordered map.
    ---@param fn fun(value:any, key:string|integer, map:ordered_map)
    function ordered_map:foreach(fn)
        local keys = self.keys:slice()
        for _, key in ipairs(keys) do
            fn(self.map[key], key, self)
        end
    end

    ---Clear the ordered map.
    function ordered_map:clear()
        self.keys:clear()
        self.map = {}
    end

    ---Return values of the ordered.
    ---@return array
    function ordered_map:values()
        local arr = olua.array()
        for _, key in ipairs(self.keys) do
            arr:push(self.map[key])
        end
        return arr
    end

    ---@alias insertmode
    ---|>'"front"'
    ---| '"after"'
    ---| '"before"'
    ---| '"back"'

    ---Insert an element into the ordered map.
    ---@param mode insertmode
    ---@param at_key string|number
    ---@param key string|number
    ---@param value any
    function ordered_map:insert(mode, at_key, key, value)
        local idx = 0
        if mode == "front" then
            idx = 1
        elseif mode == "after" then
            idx = self.keys:index_of(at_key)
            if idx == 0 then
                idx = #self.keys + 1
            else
                idx = idx + 1
            end
        elseif mode == "before" then
            idx = self.keys:index_of(at_key)
            if idx == 0 then
                idx = 1
            end
        elseif mode == "back" then
            idx = #self.keys + 1
        else
            olua.error("invalid insert mode: ${insertmode}")
        end
        self.keys:insert(idx, key)
        self.map[key] = value
    end

    return setmetatable(ordered_map, ordered_map)
end

-------------------------------------------------------------------------------
--- string util
-------------------------------------------------------------------------------

local FORMAT_PATTERN = "${[%w_.?#]+}"
local curr_expr = nil

function olua.is_end_with(str, substr)
    local _, e = str:find(substr, #str - #substr + 1, true)
    return e == #str
end

---@param level integer
---@param key string
---@return any
local function lookup(level, key)
    assert(key and #key > 0, key)

    local value
    local searchupvalue = true

    local info1 = debug.getinfo(level, "Snfu")
    local info2 = debug.getinfo(level + 1, "Sn")

    for i = 1, 256 do
        local k, v = debug.getlocal(level, i)
        if i <= info1.nparams and v == curr_expr then
            searchupvalue = false
        end
        if k == key then
            if type(v) ~= "string" or not v:find(FORMAT_PATTERN) then
                value = v
            end
        elseif not k then
            break
        end
    end

    if value then
        return value
    end

    if searchupvalue then
        for i = 1, 256 do
            local k, v = debug.getupvalue(info1.func, i)
            if k == key then
                return v
            end
        end
    end

    if info1.source == info2.source or
        string.find(info1.source, "olua.lua$") or
        string.find(info2.source, "olua.lua$")
    then
        return lookup(level + 1, key)
    end
end

---@param line string
local function eval(line)
    local drop = false
    local function replace(str)
        local level = 1
        while true do
            local info = debug.getinfo(level, "Sfn")
            if info then
                if string.find(info.source, "olua.lua$") and
                    info.func == olua.format
                then
                    break
                else
                    level = level + 1
                end
            else
                break
            end
        end

        -- search in the functin local value
        local indent = string.match(line, " *")
        local key = string.match(str, "[%w_]+")
        local opt = string.match(str, "%?+")
        local fix = string.match(str, "#")
        local value = lookup(level + 2, key) or _G[key]
        for field in string.gmatch(string.match(str, "[%w_.]+"), "[^.]+") do
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
        local prefix, posfix = "", ""
        if type(value) == "table" then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                value = tostring(value)
            else
                throw_error("no meta method '__tostring' for " .. str)
            end
        elseif value == nil then
            drop = opt == "??"
            value = "nil"
        elseif type(value) == "string" then
            value = value:gsub("[\n]*$", "")
            if opt then
                value = olua.trim(value)
                if value:find("[\n\r]") then
                    value = "\n" .. value
                    prefix = "[["
                    posfix = "\n" .. indent .. "]]"
                    indent = indent .. "    "
                elseif value:find('[\'"]') then
                    value = "[[" .. value .. "]]"
                else
                    value = "'" .. value .. "'"
                end
            end
        else
            value = tostring(value)
        end

        if fix then
            value = value:gsub("[^%w_]+", "_"):gsub("_+$", "")
        end

        return prefix .. value:gsub("\n", "\n" .. indent) .. posfix
    end
    line = line:gsub(FORMAT_PATTERN, replace)
    return not drop and line or nil
end

---@param expr string
local function doeval(expr)
    local arr = {}
    local idx = 1
    while idx <= #expr do
        local from, to = string.find(expr, "[\n\r]", idx)
        if not from then
            from = #expr + 1
            to = from
        end
        arr[#arr+1] = eval(string.sub(expr, idx, from - 1))
        idx = to + 1
    end
    return table.concat(arr, "\n")
end

---Trim the expression.
---@param expr string
---@param indent? integer
---@param keepspace? boolean
---@return string
function olua.trim(expr, indent, keepspace)
    if type(expr) == "string" then
        expr = expr:gsub("[\n\r]", "\n")
        if not keepspace then
            expr = expr:gsub("^[\n]*", "")  -- trim head '\n'
            expr = expr:gsub("[ \n]*$", "") -- trim tail '\n' or ' '
            local space = string.match(expr, "^[ ]*")
            local indent_space = string.rep(" ", indent or 0)
            expr = expr:gsub("^[ ]*", "") -- trim head space
            expr = expr:gsub("\n" .. space, "\n" .. indent_space)
            expr = indent_space .. expr
        end
    end
    return expr
end

---Format the expression.
---@param expr string
---@param indent? integer
---@param keepspace? boolean
---@return string
function olua.format(expr, indent, keepspace)
    curr_expr = expr
    expr = doeval(olua.trim(expr, indent, keepspace))

    while true do
        local s, n = expr:gsub("\n[ ]+\n", "\n\n")
        expr = s
        if n == 0 then
            break
        end
    end

    while true do
        local s, n = expr:gsub("\n\n\n", "\n\n")
        expr = s
        if n == 0 then
            break
        end
    end

    expr = expr:gsub("{\n\n", "{\n")
    expr = expr:gsub("\n\n}", "\n}")

    return expr
end

-- TODO: rm
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
