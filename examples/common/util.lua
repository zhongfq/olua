local util = {}

function util.dump(root, ...)
    local tbl = {}
    local filter = {[root] = tostring(root)}
    for _, v in ipairs({...}) do
        filter[v] = tostring(v)
    end
    local function _dump(t, name, space)
        space = space .. "  "
        for k, v in pairs(t) do
            if filter[v] then
                table.insert(tbl, space .. tostring(k) .. " = " .. filter[v])
            elseif filter[v] or type(v) ~= "table" then
                table.insert(tbl, space .. tostring(k) .. " = " .. tostring(v))
            else
                filter[v] = name .. "." .. tostring(k)
                if next(v) then
                    table.insert(tbl, space .. tostring(k) .. " = {")
                    _dump(v, name .. "." .. tostring(k),  space)
                    table.insert(tbl, space .. "}")
                else
                    table.insert(tbl, space .. tostring(k) .. " = {}")
                end
            end
        end
    end

    table.insert(tbl, "{")
    _dump(root, "", "")
    table.insert(tbl, "}")

    print(table.concat(tbl, "\n"))
end

function util.dumpUserValue(obj)
    print("uservalue(" .. tostring(obj) .. ') ')
    util.dump(debug.getuservalue(obj) or {})
end

function util.hasRef(obj, ref, value)
    local t = debug.getuservalue(obj)
    ref = '.olua.ref.' .. ref
    if not t then
        return false
    end
    if not t[ref] then
        return false
    end
    if (type(t[ref]) == 'table') then
        return t[ref][value] ~= nil
    else
        return t[ref] ~= nil
    end
end

function util.hasNoRef(obj, ref, value)
    return not util.hasRef(obj, ref, value)
end

return util