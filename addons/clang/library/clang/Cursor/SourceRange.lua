---@meta clang.Cursor.SourceRange

---
---@class clang.Cursor.SourceRange 
---@field endColumn integer
---@field endLine integer
---@field path string
---@field startColumn integer
---@field startLine integer
local SourceRange = {}

function SourceRange:__call() end

function SourceRange:__gc() end

function SourceRange:__olua_move() end

return SourceRange