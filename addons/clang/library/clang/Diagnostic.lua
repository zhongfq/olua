---@meta clang.Diagnostic

---
---@class clang.Diagnostic : clang.IndexError
---@field category integer Retrieve the category number for this diagnostic. <br><br>Diagnostics can be categorized into groups along with other, related diagnostics (e.g., diagnostics under the same warning flag). This routine retrieves the category number for the given diagnostic. <br><br>\returns The number of the category that contains this diagnostic, or zero if this diagnostic is uncategorized.
---@field categoryText string Retrieve the diagnostic category text for a given diagnostic. <br><br>\returns The text of the given diagnostic category.
---@field name string Retrieve the text of the given diagnostic.
---@field severity clang.DiagnosticSeverity Determine the severity of the given diagnostic.
---@field severitySeplling string Determine the severity of the given diagnostic.
---@field text string Retrieve the set of display options most similar to the default behavior of the clang compiler. <br><br>\returns A set of display options suitable for use with \c clang_formatDiagnostic().
local Diagnostic = {}

---@param cls string
---@return any
function Diagnostic:as(cls) end

---Format the given diagnostic in a manner that is suitable for display.
---
---This routine will format the given diagnostic to a string, rendering
---the diagnostic according to the various options given. The
---`clang_defaultDiagnosticDisplayOptions()` function returns the set of
---options that most closely mimics the behavior of the clang compiler.
---
---\param Diagnostic The diagnostic to print.
---
---\param Options A set of options that control the diagnostic display,
---created by combining `CXDiagnosticDisplayOptions` values.
---
---\returns A new string containing for formatted diagnostic.
---@param options integer
---@return string
function Diagnostic:formatDiagnostic(options) end

---@return clang.Diagnostic
function Diagnostic:shared_from_this() end

return Diagnostic