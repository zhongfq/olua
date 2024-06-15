---@meta clang.LinkageKind

---@type clang.LinkageKind
local VALUE

---@enum clang.LinkageKind
local LinkageKind = {
    ---This is the linkage for entities with true, external linkage.
    External = VALUE,
    ---This is the linkage for static variables and static functions.
    Internal = VALUE,
    ---This value indicates that no linkage information is available
    ---for a provided CXCursor.
    Invalid = VALUE,
    ---This is the linkage for variables, parameters, and so on that
    ---have automatic storage.  This covers normal (non-extern) local variables.
    NoLinkage = VALUE,
    ---This is the linkage for entities with external linkage that live
    ---in C++ anonymous namespaces.
    UniqueExternal = VALUE,
}

return LinkageKind