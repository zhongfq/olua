---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.TranslationUnit

---A single translation unit, which resides in an index.
---@class clang.TranslationUnit : clang.IndexError
---@field cursor clang.Cursor 
---@field defaultReparseOptions integer 
---@field defaultSaveOptions integer 
---@field diagnosticSetFromTU clang.Diagnostic[] 
---@field diagnostics clang.Diagnostic[] 
---@field name string 
---@field suspendTranslationUnit integer 
local TranslationUnit = {}

---@param cls string
---@return any
function TranslationUnit:as(cls) end

---Retrieve a file handle within the given translation unit.
---
---\param tu the translation unit
---
---\param file_name the name of the file.
---
---@return clang.File # s the file handle for the named file in the translation unit \p tu,
---or a NULL file handle if the file was not a part of this translation unit.
---@param path string
function TranslationUnit:getFile(path) end

---Retrieve the buffer associated with the given file.
---
---\param tu the translation unit
---
---@param f clang.File # ile the file for which to retrieve the buffer.
---
---\param size [out] if non-NULL, will be set to the size of the buffer.
---
---@return string # s a pointer to the buffer in memory that holds the contents of
---\p file, or a NULL pointer when the file is not loaded.
function TranslationUnit:getFileContents(f) end

---Determine whether the given header is guarded against
---multiple inclusions, either with the conventional
---\#ifndef/\#define/\#endif macro guards or with \#pragma once.
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

---@param m clang.Module
---@param index integer
---@return clang.File
function TranslationUnit:topLevelHeader(m, index) end

return TranslationUnit