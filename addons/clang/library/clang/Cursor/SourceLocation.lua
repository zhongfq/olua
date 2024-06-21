---@meta clang.Cursor.SourceLocation

---
---@class clang.Cursor.SourceLocation 
---@field column integer
---@field line integer
---@field path string
local SourceLocation = {}

function SourceLocation:__call() end

function SourceLocation:__gc() end

function SourceLocation:__olua_move() end

return SourceLocation