---@meta clang.Index

---An "index" that consists of a set of translation units that would
---typically be linked together into an executable or library.
---@class clang.Index : clang.IndexError
---@field globalOptions integer 
local Index = {}

---@param cls string
---@return any
function Index:as(cls) end

---Create a translation unit from a source file 
---\param path The path to the source file
---@param path string
---@return clang.TranslationUnit
function Index:create(path) end

---@return integer
function Index:getGlobalOptions() end

---Same as `clang_parseTranslationUnit2`, but returns
---the `CXTranslationUnit` instead of an error code.  In case of an error this
---routine returns a `NULL` `CXTranslationUnit`, without further detailed
---error codes.
---@param path string
---@param args string[]
---@param options integer
---@return clang.TranslationUnit
---@overload fun(self: clang.Index, path: string, args: string[]): clang.TranslationUnit
function Index:parse(path, args, options) end

---@param options integer
---@return nil
function Index:setGlobalOptions(options) end

---@param path string
---@return nil
function Index:setInvocationEmissionPathOption(path) end

---@return clang.Index
function Index:shared_from_this() end

return Index