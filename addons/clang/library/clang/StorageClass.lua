---@meta clang.StorageClass

---@type clang.StorageClass
local VALUE

---
---@enum clang.StorageClass
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

return StorageClass