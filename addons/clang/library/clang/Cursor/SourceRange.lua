---@meta clang.Cursor.SourceRange

---@class clang.Cursor.SourceRange 
---@field endColumn number
---@field endLine number
---@field path string
---@field startColumn number
---@field startLine number
local SourceRange = {}

---@return nil
function SourceRange:__call() end

---@return nil
function SourceRange:__gc() end

---@return nil
function SourceRange:__olua_move() end

return SourceRange