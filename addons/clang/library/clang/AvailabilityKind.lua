---@meta clang.AvailabilityKind

---@type clang.AvailabilityKind
local VALUE

---
---@enum clang.AvailabilityKind
local AvailabilityKind = {
    ---The entity is available.
    Available = 0,
    ---The entity is available, but has been deprecated (and its use is
    ---not recommended).
    Deprecated = 1,
    ---The entity is available, but not accessible; any use of it will be
    ---an error.
    NotAccessible = 3,
    ---The entity is not available; any use of it will be an error.
    NotAvailable = 2,
}

return AvailabilityKind