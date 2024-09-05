---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.StorageClass

---@type clang.StorageClass
local VALUE

---
---@enum clang.StorageClass
---@operator call(integer): clang.StorageClass
local StorageClass = {
    Auto = 6,
    Extern = 2,
    Invalid = 0,
    None = 1,
    OpenCLWorkGroupLocal = 5,
    PrivateExtern = 4,
    Register = 7,
    Static = 3,
}

---@param v integer
---@return clang.StorageClass
function StorageClass:__call(v) end

return StorageClass