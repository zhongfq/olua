---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.LanguageKind

---@type clang.LanguageKind
local VALUE

---
---@enum clang.LanguageKind
---@operator call(integer): clang.LanguageKind
local LanguageKind = {
    C = 1,
    CPlusPlus = 3,
    Invalid = 0,
    ObjC = 2,
}

---@param v integer
---@return clang.LanguageKind
function LanguageKind:__call(v) end

return LanguageKind