---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.TranslationUnit

---A single translation unit, which resides in an index.
---@class clang.TranslationUnit : clang.IndexError
---@field cursor clang.Cursor Retrieve the cursor that represents the given translation unit. <br><br>The translation unit cursor can be used to start traversing the various declarations within the given translation unit.
---@field defaultReparseOptions integer Returns the set of flags that is suitable for reparsing a translation unit. <br><br>The set of flags returned provide options for `clang_reparseTranslationUnit()` by default. The returned flag set contains an unspecified set of optimizations geared toward common uses of reparsing. The set of optimizations enabled may change from one version to the next.
---@field defaultSaveOptions integer Returns the set of flags that is suitable for saving a translation unit. <br><br>The set of flags returned provide options for `clang_saveTranslationUnit()` by default. The returned flag set contains an unspecified set of options that save translation units with the most commonly-requested data.
---@field diagnosticSetFromTU clang.Diagnostic[] Retrieve a diagnostic associated with the given CXDiagnosticSet. <br><br>\param Diags the CXDiagnosticSet to query. \param Index the zero-based diagnostic number to retrieve. <br><br>\returns the requested diagnostic. This diagnostic must be freed via a call to `clang_disposeDiagnostic()`.
---@field diagnostics clang.Diagnostic[] Retrieve the unique ID for the given `file`. <br><br>\param file the file to get the ID for. \param outID stores the returned CXFileUniqueID. \returns If there was a failure getting the unique ID, returns non-zero, otherwise returns 0.
---@field name string Get the original translation unit source file name.
---@field suspendTranslationUnit integer Suspend a translation unit in order to free memory associated with it. <br><br>A suspended translation unit uses significantly less memory but on the other side does not support any other calls than `clang_reparseTranslationUnit to` resume it or `clang_disposeTranslationUnit` to dispose it completely.
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

---Given a CXFile header file, return the module that contains it, if one
---exists.
---@param file clang.File
---@return clang.Module
function TranslationUnit:moduleForFile(file) end

---\param Module a module object.
---
---@return integer # s the number of top level headers associated with this module.
---@param m clang.Module
function TranslationUnit:numTopLevelHeaders(m) end

---Saves a translation unit into a serialized representation of
---that translation unit on disk.
---
---Any translation unit that was parsed without error can be saved
---into a file. The translation unit can then be deserialized into a
---new `CXTranslationUnit` with `clang_createTranslationUnit()` or,
---if it is an incomplete translation unit that corresponds to a
---header, used as a precompiled header when parsing other translation
---units.
---
---\param TU The translation unit to save.
---
---\param FileName The file to which the translation unit will be saved.
---
---@param options integer # A bitmask of options that affects how the translation unit
---is saved. This should be a bitwise OR of the
---CXSaveTranslationUnit_XXX flags.
---
---@return integer # s A value that will match one of the enumerators of the CXSaveError
---enumeration. Zero (CXSaveError_None) indicates that the translation unit was
---saved successfully, while a non-zero value indicates that a problem occurred.
---@param path string
function TranslationUnit:saveTranslationUnit(path, options) end

---@return clang.TranslationUnit
function TranslationUnit:shared_from_this() end

---\param Module a module object.
---
---\param Index top level header index (zero-based).
---
---@return clang.File # s the specified top level header associated with the module.
---@param m clang.Module
---@param index integer
function TranslationUnit:topLevelHeader(m, index) end

return TranslationUnit