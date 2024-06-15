---@meta clang.DiagnosticSeverity

---@type clang.DiagnosticSeverity
local VALUE

---
---@enum clang.DiagnosticSeverity
local DiagnosticSeverity = {
    ---This diagnostic indicates that the code is ill-formed.
    Error = 3,
    ---This diagnostic indicates that the code is ill-formed such
    ---that future parser recovery is unlikely to produce useful
    ---results.
    Fatal = 4,
    ---A diagnostic that has been suppressed, e.g., by a command-line
    ---option.
    Ignored = 0,
    ---This diagnostic is a note that should be attached to the
    ---previous (non-note) diagnostic.
    Note = 1,
    ---This diagnostic indicates suspicious code that may not be
    ---wrong.
    Warning = 2,
}

return DiagnosticSeverity