---@meta clang.Cursor.SourceLocation

---
---@class clang.Cursor.SourceLocation 
---@field column integer
---@field line integer
---@field path string
local SourceLocation = {}

---@return any
function SourceLocation:__gc() end

---@return any
function SourceLocation:__olua_move() end

return SourceLocation