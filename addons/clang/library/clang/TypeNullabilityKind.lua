---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.TypeNullabilityKind

---@type clang.TypeNullabilityKind
local VALUE

---
---@enum clang.TypeNullabilityKind
---@operator call(integer): clang.TypeNullabilityKind
local TypeNullabilityKind = {
    ---Nullability is not applicable to this type.
    Invalid = 3,
    ---Values of this type can never be null.
    NonNull = 0,
    ---Values of this type can be null.
    Nullable = 1,
    ---Generally behaves like Nullable, except when used in a block parameter that
    ---was imported into a swift async method. There, swift will assume that the
    ---parameter can get null even if no error occurred. _Nullable parameters are
    ---assumed to only get null on error.
    NullableResult = 4,
    ---Whether values of this type can be null is (explicitly)
    ---unspecified. This captures a (fairly rare) case where we
    ---can't conclude anything about the nullability of the type even
    ---though it has been considered.
    Unspecified = 2,
}

---@param v integer
---@return clang.TypeNullabilityKind
function TypeNullabilityKind:__call(v) end

return TypeNullabilityKind