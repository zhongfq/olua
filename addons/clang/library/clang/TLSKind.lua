---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.TLSKind

---@type clang.TLSKind
local VALUE

---
---@enum clang.TLSKind
---@operator call(integer): clang.TLSKind
local TLSKind = {
    Dynamic = 1,
    None = 0,
    Static = 2,
}

---@param v integer
---@return clang.TLSKind
function TLSKind:__call(v) end

return TLSKind