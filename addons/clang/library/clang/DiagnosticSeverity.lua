---@meta clang.DiagnosticSeverity

---@type clang.DiagnosticSeverity
local VALUE

---@enum clang.DiagnosticSeverity
local DiagnosticSeverity = {
    ---This diagnostic indicates that the code is ill-formed.
    Error = VALUE,
    ---This diagnostic indicates that the code is ill-formed such
    ---that future parser recovery is unlikely to produce useful
    ---results.
    Fatal = VALUE,
    ---A diagnostic that has been suppressed, e.g., by a command-line
    ---option.
    Ignored = VALUE,
    ---This diagnostic is a note that should be attached to the
    ---previous (non-note) diagnostic.
    Note = VALUE,
    ---This diagnostic indicates suspicious code that may not be
    ---wrong.
    Warning = VALUE,
}

return DiagnosticSeverity