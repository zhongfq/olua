---@meta clang.AvailabilityKind

---@type clang.AvailabilityKind
local VALUE

---@enum clang.AvailabilityKind
local AvailabilityKind = {
    ---The entity is available.
    Available = VALUE,
    ---The entity is available, but has been deprecated (and its use is
    ---not recommended).
    Deprecated = VALUE,
    ---The entity is available, but not accessible; any use of it will be
    ---an error.
    NotAccessible = VALUE,
    ---The entity is not available; any use of it will be an error.
    NotAvailable = VALUE,
}

return AvailabilityKind