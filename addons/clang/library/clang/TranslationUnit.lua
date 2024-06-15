---@meta clang.TranslationUnit

---A single translation unit, which resides in an index.
---@class clang.TranslationUnit : clang.IndexError
---@field cursor clang.Cursor 
---@field diagnosticSetFromTU clang.Diagnostic[] 
---@field diagnostics clang.Diagnostic[] 
---@field name string 
local TranslationUnit = {}

---@param cls string
---@return any
function TranslationUnit:as(cls) end

---@return integer
function TranslationUnit:defaultReparseOptions() end

---@return integer
function TranslationUnit:defaultSaveOptions() end

---@param path string
---@return clang.File
function TranslationUnit:getFile(path) end

---@param f clang.File
---@return string
function TranslationUnit:getFileContents(f) end

---@param f clang.File
---@return boolean
function TranslationUnit:isFileMultipleIncludeGuarded(f) end

---@param file clang.File
---@return clang.Module
function TranslationUnit:moduleForFile(file) end

---@param m clang.Module
---@return integer
function TranslationUnit:numTopLevelHeaders(m) end

---@param path string
---@param options integer
---@return integer
function TranslationUnit:saveTranslationUnit(path, options) end

---@return clang.TranslationUnit
function TranslationUnit:shared_from_this() end

---@return integer
function TranslationUnit:suspendTranslationUnit() end

---@param m clang.Module
---@param index integer
---@return clang.File
function TranslationUnit:topLevelHeader(m, index) end

return TranslationUnit