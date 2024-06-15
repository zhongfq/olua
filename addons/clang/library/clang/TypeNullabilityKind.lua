---@meta clang.TypeNullabilityKind

---@type clang.TypeNullabilityKind
local VALUE

---@enum clang.TypeNullabilityKind
local TypeNullabilityKind = {
    ---Nullability is not applicable to this type.
    Invalid = VALUE,
    ---Values of this type can never be null.
    NonNull = VALUE,
    ---Values of this type can be null.
    Nullable = VALUE,
    ---Generally behaves like Nullable, except when used in a block parameter that
    ---was imported into a swift async method. There, swift will assume that the
    ---parameter can get null even if no error occurred. _Nullable parameters are
    ---assumed to only get null on error.
    NullableResult = VALUE,
    ---Whether values of this type can be null is (explicitly)
    ---unspecified. This captures a (fairly rare) case where we
    ---can't conclude anything about the nullability of the type even
    ---though it has been considered.
    Unspecified = VALUE,
}

return TypeNullabilityKind