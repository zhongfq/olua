---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.ErrorCode

---@type clang.ErrorCode
local VALUE

---
---@enum clang.ErrorCode
---@operator call(integer): clang.ErrorCode
local ErrorCode = {
    ---An AST deserialization error has occurred.
    ASTReadError = 4,
    ---libclang crashed while performing the requested operation.
    Crashed = 2,
    ---A generic error code, no further details are available.
    ---
    ---Errors of this kind can get their own specific error codes in future
    ---libclang versions.
    Failure = 1,
    ---The function detected that the arguments violate the function
    ---contract.
    InvalidArguments = 3,
    ---No error.
    Success = 0,
}

---@param v integer
---@return clang.ErrorCode
function ErrorCode:__call(v) end

return ErrorCode