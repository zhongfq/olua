---@meta clang.IndexError

---
---@class clang.IndexError 
local IndexError = {}

function IndexError:__gc() end


---@return any
function IndexError:__index() end


---@return any
function IndexError:__newindex() end

function IndexError:__olua_move() end

return IndexError