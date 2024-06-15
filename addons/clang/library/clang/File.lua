---@meta clang.File

---@class clang.File : clang.IndexError
---@field fileName string Retrieve the complete file and path name of the given file.
---@field fileTime number Retrieve the last modification time of the given file.
local File = {}

---@param f clang.File
---@return any
function File:__eq(f) end

---@param cls string
---@return any
function File:as(cls) end

---@return clang.File
function File:shared_from_this() end

---Returns the real path name of `file`.
---
---An empty string may be returned. Use `clang_getFileName()` in that case.
---@return string
function File:tryGetRealPathName() end

return File