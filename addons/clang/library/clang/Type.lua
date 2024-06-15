---@meta clang.Type

---@class clang.Type : clang.IndexError
---@field addressSpace number Returns the address space of the given type.
---@field alignOf number Return the alignment of a type in bytes as per C++[expr.alignof] standard. <br><br>If the type declaration is invalid, CXTypeLayoutError_Invalid is returned. If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete is returned. If the type declaration is a dependent type, CXTypeLayoutError_Dependent is returned. If the type declaration is not a constant size type, CXTypeLayoutError_NotConstantSize is returned.
---@field argTypes clang.Type[] Retrieve the type of a parameter of a function type. <br><br>If a non-function type is passed in or the function does not have enough parameters, an invalid type is returned.
---@field arrayElementType clang.Type Return the element type of an array type. <br><br>If a non-array type is passed in, an invalid type is returned.
---@field arraySize number Return the array size of a constant array. <br><br>If a non-array type is passed in, -1 is returned.
---@field canonicalType clang.Type Return the canonical type for a CXType. <br><br>Clang's type system explicitly models typedefs and all the ways a specific type can be represented. The canonical type is the underlying type with all the "sugar" removed. For example, if 'T' is a typedef for 'int', the canonical type for 'T' would be 'int'.
---@field classType clang.Type clang_Type_getClassType
---@field cxxRefQualifier clang.RefQualifierKind Retrieve the ref-qualifier kind of a function or method. <br><br>The ref-qualifier is returned for C++ functions or methods. For other types or non-C++ declarations, CXRefQualifier_None is returned.
---@field cxxRefQualifierSpelling string Retrieve the ref-qualifier kind of a function or method. <br><br>The ref-qualifier is returned for C++ functions or methods. For other types or non-C++ declarations, CXRefQualifier_None is returned.
---@field declaration clang.Cursor Return the cursor for the declaration of the given type.
---@field elementType clang.Type Return the element type of an array, complex, or vector type. <br><br>If a type is passed in that is not an array, complex, or vector type, an invalid type is returned.
---@field exceptionSpecificationType number Retrieve the exception specification type associated with a function type. This is a value of type CXCursor_ExceptionSpecificationKind. <br><br>If a non-function type is passed in, an error code of -1 is returned.
---@field fields clang.Cursor[] Get the fields of a record type
---@field functionTypeCallingConv clang.CallingConv Retrieve the calling convention associated with a function type. <br><br>If a non-function type is passed in, CXCallingConv_Invalid is returned.
---@field isConstQualified boolean Determine whether a CXType has the "const" qualifier set, without looking through typedefs that may have added "const" at a different level.
---@field isFunctionTypeVariadic boolean Return 1 if the CXType is a variadic function type, and 0 otherwise.
---@field isPOD boolean Return 1 if the CXType is a POD (plain old data) type, and 0 otherwise.
---@field isRestrictQualified boolean Determine whether a CXType has the "restrict" qualifier set, without looking through typedefs that may have added "restrict" at a different level.
---@field isTransparentTagTypedef boolean Determine if a typedef is 'transparent' tag. <br><br>A typedef is considered 'transparent' if it shares a name and spelling location with its underlying tag type, as is the case with the NS_ENUM macro. <br><br>\returns non-zero if transparent and zero otherwise.
---@field isVolatileQualified boolean Determine whether a CXType has the "volatile" qualifier set, without looking through typedefs that may have added "volatile" at a different level.
---@field kind clang.TypeKind The kind of type
---@field kindSpelling string Retrieve the spelling of a given CXTypeKind.
---@field modifiedType clang.Type Return the type that was modified by this attributed type. <br><br>If the type is not an attributed type, an invalid type is returned.
---@field name string Pretty-print the underlying type using the rules of the language of the translation unit from which it came. <br><br>If the type is invalid, an empty string is returned.
---@field namedType clang.Type Retrieve the type named by the qualified-id. <br><br>If a non-elaborated type is passed in, an invalid type is returned.
---@field nonReferenceType clang.Type For reference types (e.g., "const int&"), returns the type that the reference refers to (e.g "const int"). <br><br>Otherwise, returns the type itself. <br><br>A type that has kind `CXType_LValueReference` or `CXType_RValueReference` is a reference type.
---@field nullability clang.TypeNullabilityKind Retrieve the nullability kind of a pointer type.
---@field nullabilitySpelling string Retrieve the nullability kind of a pointer type.
---@field numElements number Return the number of elements of an array or vector type. <br><br>If a type is passed in that is not an array or vector type, -1 is returned.
---@field pointeeType clang.Type For pointer types, returns the type of the pointee.
---@field resultType clang.Type Retrieve the return type associated with a function type. <br><br>If a non-function type is passed in, an invalid type is returned.
---@field sizeOf number Return the size of a type in bytes as per C++[expr.sizeof] standard. <br><br>If the type declaration is invalid, CXTypeLayoutError_Invalid is returned. If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete is returned. If the type declaration is a dependent type, CXTypeLayoutError_Dependent is returned.
---@field templateArgumentTypes clang.Type[] Returns the type template argument of a template class specialization at given index. <br><br>This function only returns template type arguments and does not handle template template arguments or variadic packs.
---@field typedefName string Returns the typedef name of the given type.
---@field unqualifiedType clang.Type Retrieve the unqualified variant of the given type, removing as little sugar as possible. <br><br>For example, given the following series of typedefs: <br><br>``` typedef int Integer; typedef const Integer CInteger; typedef CInteger DifferenceType; ``` <br><br>Executing `clang_getUnqualifiedType()` on a `CXType` that represents `DifferenceType`, will desugar to a type representing `Integer`, that has no qualifiers. <br><br>And, executing `clang_getUnqualifiedType()` on the type of the first argument of the following function declaration: <br><br>``` void foo(const int); ``` <br><br>Will return a type representing `int`, removing the `const` qualifier. <br><br>Sugar over array types is not desugared. <br><br>A type can be checked for qualifiers with `clang_isConstQualifiedType()`, `clang_isVolatileQualifiedType()` and `clang_isRestrictQualifiedType()`. <br><br>A type that resulted from a call to `clang_getUnqualifiedType` will return `false` for all of the above calls.
---@field valueType clang.Type Gets the type contained by this atomic type. <br><br>If a non-atomic type is passed in, an invalid type is returned.
local Type = {}

---@param t clang.Type
---@return any
function Type:__eq(t) end

---@param cls string
---@return any
function Type:as(cls) end

---Retrieve the type of a parameter of a function type.
---
---If a non-function type is passed in or the function does not have enough
---parameters, an invalid type is returned.
---@param i number
---@return clang.Type
function Type:getArgType(i) end

---@param i number
---@return clang.Type
function Type:getTemplateArgument(i) end

---Return the offset of a field named S in a record of type T in bits
---as it would be returned by __offsetof__ as per C++11[18.2p4]
---
---If the cursor is not a record field declaration, CXTypeLayoutError_Invalid
---is returned.
---If the field's type declaration is an incomplete type,
---CXTypeLayoutError_Incomplete is returned.
---If the field's type declaration is a dependent type,
---CXTypeLayoutError_Dependent is returned.
---If the field's name S is not found,
---CXTypeLayoutError_InvalidFieldName is returned.
---@param field string
---@return number
function Type:offsetOf(field) end

---@return clang.Type
function Type:shared_from_this() end

return Type