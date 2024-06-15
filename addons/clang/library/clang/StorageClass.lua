---@meta clang.StorageClass

---@type clang.StorageClass
local VALUE

---@enum clang.StorageClass
local StorageClass = {
    Auto = VALUE,
    Extern = VALUE,
    Invalid = VALUE,
    None = VALUE,
    OpenCLWorkGroupLocal = VALUE,
    PrivateExtern = VALUE,
    Register = VALUE,
    Static = VALUE,
}

return StorageClass