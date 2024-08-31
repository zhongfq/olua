---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.LinkageKind

---@type clang.LinkageKind
local VALUE

---
---@enum clang.LinkageKind
local LinkageKind = {
    ---This is the linkage for entities with true, external linkage.
    External = 4,
    ---This is the linkage for static variables and static functions.
    Internal = 2,
    ---This value indicates that no linkage information is available
    ---for a provided CXCursor.
    Invalid = 0,
    ---This is the linkage for variables, parameters, and so on that
    ---have automatic storage.  This covers normal (non-extern) local variables.
    NoLinkage = 1,
    ---This is the linkage for entities with external linkage that live
    ---in C++ anonymous namespaces.
    UniqueExternal = 3,
}

return LinkageKind