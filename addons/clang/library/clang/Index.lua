---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.Index

---An "index" that consists of a set of translation units that would
---typically be linked together into an executable or library.
---@class clang.Index : clang.IndexError
---@field globalOptions integer Gets the general options associated with a CXIndex. <br><br>This function allows to obtain the final option values used by libclang after specifying the option policies via CXChoice enumerators. <br><br>\returns A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags that are associated with the given CXIndex object.
local Index = {}

---@param cls string
---@return any
function Index:as(cls) end

---Create a translation unit from a source file 
---@param path string # The path to the source file
---@return clang.TranslationUnit
function Index:create(path) end

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

---Sets the invocation emission path option in a CXIndex.
---
---This function is DEPRECATED. Set CXIndexOptions::InvocationEmissionPath and
---call clang_createIndexWithOptions() instead.
---
---The invocation emission path specifies a path which will contain log
---files for certain libclang invocations. A null value (default) implies that
---libclang invocations are not logged..
---@param path string
function Index:setInvocationEmissionPathOption(path) end

---@return clang.Index
function Index:shared_from_this() end

return Index