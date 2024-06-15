---@meta clang.Cursor.SourceLocation

---@class clang.Cursor.SourceLocation 
---@field column number
---@field line number
---@field path string
local SourceLocation = {}

---@return nil
function SourceLocation:__call() end

---@return nil
function SourceLocation:__gc() end

---@return nil
function SourceLocation:__olua_move() end

return SourceLocation