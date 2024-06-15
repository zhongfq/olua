---@meta clang.GlobalOptFlags

---@type clang.GlobalOptFlags
local VALUE

---
---@enum clang.GlobalOptFlags
local GlobalOptFlags = {
    ---Used to indicate that no special CXIndex options are needed.
    None = 0,
    ---Used to indicate that all threads that libclang creates should use
    ---background priority.
    ThreadBackgroundPriorityForAll = 3,
    ---Used to indicate that threads that libclang creates for editing
    ---purposes should use background priority.
    ---
    ---Affects #clang_reparseTranslationUnit, #clang_codeCompleteAt,
    ---#clang_annotateTokens
    ThreadBackgroundPriorityForEditing = 2,
    ---Used to indicate that threads that libclang creates for indexing
    ---purposes should use background priority.
    ---
    ---Affects #clang_indexSourceFile, #clang_indexTranslationUnit,
    ---#clang_parseTranslationUnit, #clang_saveTranslationUnit.
    ThreadBackgroundPriorityForIndexing = 1,
}

return GlobalOptFlags