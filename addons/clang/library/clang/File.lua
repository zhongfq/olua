---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.File

---
---@class clang.File : clang.IndexError
---@field name string Retrieve the complete file and path name of the given file.
---@field realPathName string Returns the real path name of `file`. <br><br>An empty string may be returned. Use `clang_getFileName()` in that case.
---@field time integer Retrieve the last modification time of the given file.
local File = {}

---@param f clang.File
---@return any
function File:__eq(f) end

---@param cls string
---@return any
function File:as(cls) end

---@return clang.File
function File:shared_from_this() end

return File