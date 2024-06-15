---@meta clang.TranslationUnit

---@class clang.TranslationUnit : clang.IndexError
---@field cursor clang.Cursor 
---@field diagnosticSetFromTU clang.Diagnostic[] 
---@field diagnostics clang.Diagnostic[] 
---@field name string 
local TranslationUnit = {}

---@param cls string
---@return any
function TranslationUnit:as(cls) end

---@return number
function TranslationUnit:defaultReparseOptions() end

---@return number
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
---@return number
function TranslationUnit:numTopLevelHeaders(m) end

---@param path string
---@param options number
---@return number
function TranslationUnit:saveTranslationUnit(path, options) end

---@return clang.TranslationUnit
function TranslationUnit:shared_from_this() end

---@return number
function TranslationUnit:suspendTranslationUnit() end

---@param m clang.Module
---@param index number
---@return clang.File
function TranslationUnit:topLevelHeader(m, index) end

return TranslationUnit