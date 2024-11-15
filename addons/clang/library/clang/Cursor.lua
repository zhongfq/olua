---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.Cursor

---A cursor representing some element in the abstract syntax tree for
---a translation unit.
---
---The cursor abstraction unifies the different kinds of entities in a
---program--declaration, statements, expressions, references to declarations,
---etc.--under a single "cursor" abstraction with a common set of operations.
---Common operation for a cursor include: getting the physical location in
---a source file where the cursor points, getting the name associated with a
---cursor, and retrieving cursors for any child nodes of a particular cursor.
---
---Cursors can be produced in two specific ways.
---clang_getTranslationUnitCursor() produces a cursor for a translation unit,
---from which one can use clang_visitChildren() to explore the rest of the
---translation unit. clang_getCursor() maps from a physical source location
---to the entity that resides at that location, allowing one to map from the
---source code into the AST.
---@class clang.Cursor : clang.IndexError
---@field arguments clang.Cursor[] Retrieve the argument cursor of a function or method. <br><br>The argument cursor can be determined for calls as well as for declarations of functions or methods. For other cursors and for invalid indices, an invalid cursor is returned.
---@field availability clang.AvailabilityKind Determine the availability of the entity that this cursor refers to, taking the current target platform into account. <br><br>\param cursor The cursor to query. <br><br>\returns The availability of the cursor.
---@field briefCommentText string Given a cursor that represents a documentable entity (e.g., declaration), return the associated \paragraph; otherwise return the first paragraph.
---@field canonical clang.Cursor Retrieve the canonical cursor corresponding to the given cursor. <br><br>In the C family of languages, many kinds of entities can be declared several times within a single translation unit. For example, a structure type can be forward-declared (possibly multiple times) and later defined: <br><br>``` struct X; struct X; struct X { int member; }; ``` <br><br>The declarations and the definition of `X` are represented by three different cursors, all of which are declarations of the same underlying entity. One of these cursor is considered the "canonical" cursor, which is effectively the representative for the underlying entity. One can determine if two cursors are declarations of the same underlying entity by comparing their canonical cursors. <br><br>\returns The canonical cursor for the entity referred to by the given cursor.
---@field children clang.Cursor[] Visit the children of a particular cursor. <br><br>This function visits all the direct children of the given cursor, invoking the given \p visitor function with the cursors of each visited child. The traversal may be recursive, if the visitor returns `CXChildVisit_Recurse`. The traversal may also be ended prematurely, if the visitor returns `CXChildVisit_Break`. <br><br>\param parent the cursor whose child may be visited. All kinds of cursors can be visited, including invalid cursors (which, by definition, have no children). <br><br>\param visitor the visitor function that will be invoked for each child of \p parent. <br><br>\param client_data pointer data supplied by the client, which will be passed to the visitor each time it is invoked. <br><br>\returns a non-zero value if the traversal was terminated prematurely by the visitor returning `CXChildVisit_Break`.
---@field commentRange clang.Cursor.SourceRange Given a cursor that represents a declaration, return the associated comment's source range.  The range may include multiple consecutive comments with whitespace in between.
---@field cxxAccessSpecifier clang.CXXAccessSpecifier Returns the access control level for the referenced object. <br><br>If the cursor refers to a C++ declaration, its access control level within its parent scope is returned. Otherwise, if the cursor refers to a base specifier or access specifier, the specifier itself is returned.
---@field cxxAccessSpecifierSpelling string Returns the access control level for the referenced object. <br><br>If the cursor refers to a C++ declaration, its access control level within its parent scope is returned. Otherwise, if the cursor refers to a base specifier or access specifier, the specifier itself is returned.
---@field cxxManglings string[] Retrieve the CXStrings representing the mangled symbols of the C++ constructor or destructor at the cursor.
---@field definition clang.Cursor For a cursor that is either a reference to or a declaration of some entity, retrieve a cursor that describes the definition of that entity. <br><br>Some entities can be declared multiple times within a translation unit, but only one of those declarations can also be a definition. For example, given: <br><br>``` int f(int, int); int g(int x, int y) { return f(x, y); } int f(int a, int b) { return a + b; } int f(int, int); ``` <br><br>there are three declarations of the function "f", but only the second one is a definition. The clang_getCursorDefinition() function will take any cursor pointing to a declaration of "f" (the first or fourth lines of the example) or a cursor referenced that uses "f" (the call to "f' inside "g") and will return a declaration cursor pointing to the definition (the second "f" declaration). <br><br>If given a cursor for which there is no corresponding definition, e.g., because there is no definition of that entity within this translation unit, returns a NULL cursor.
---@field displayName string Retrieve the display name for the entity referenced by this cursor. <br><br>The display name contains extra information that helps identify the cursor, such as the parameters of a function or template or the arguments of a class template specialization.
---@field enumConstantDeclUnsignedValue integer Retrieve the integer value of an enum constant declaration as an unsigned long long. <br><br>If the cursor does not reference an enum constant declaration, ULLONG_MAX is returned. Since this is also potentially a valid constant value, the kind of the cursor must be verified before calling this function.
---@field enumConstantDeclValue integer Retrieve the integer value of an enum constant declaration as a signed long long. <br><br>If the cursor does not reference an enum constant declaration, LLONG_MIN is returned. Since this is also potentially a valid constant value, the kind of the cursor must be verified before calling this function.
---@field enumDeclIntegerType clang.Type Retrieve the integer type of an enum declaration. <br><br>If the cursor does not reference an enum declaration, an invalid type is returned.
---@field exceptionSpecificationType integer Retrieve the exception specification type associated with a given cursor. This is a value of type CXCursor_ExceptionSpecificationKind. <br><br>This only returns a valid result if the cursor refers to a function or method.
---@field fieldDeclBitWidth integer Retrieve the bit width of a bit-field declaration as an integer. <br><br>If the cursor does not reference a bit-field, or if the bit-field's width expression cannot be evaluated, -1 is returned. <br><br>For example: ``` if (clang_Cursor_isBitField(Cursor)) { int Width = clang_getFieldDeclBitWidth(Cursor); if (Width != -1) { The bit-field width is not value-dependent. } } ```
---@field getModule clang.Module Given a CXCursor_ModuleImportDecl cursor, return the associated module.
---@field hasVarDeclExternalStorage integer If cursor refers to a variable declaration that has external storage returns 1. If cursor refers to a variable declaration that doesn't have external storage returns 0. Otherwise returns -1.
---@field hasVarDeclGlobalStorage integer If cursor refers to a variable declaration that has global storage returns 1. If cursor refers to a variable declaration that doesn't have global storage returns 0. Otherwise returns -1.
---@field hash integer Compute a hash value for the given cursor.
---@field includedFile clang.File Retrieve the file that is included by the given inclusion directive cursor.
---@field isDynamicCall integer Given a cursor pointing to a C++ method call or an Objective-C message, returns non-zero if the method/message is "dynamic", meaning: <br><br>For a C++ method: the call is virtual. For an Objective-C message: the receiver is an object instance, not 'super' or a specific class. <br><br>If the method/message is "static" or the cursor does not point to a method/message, it will return zero.
---@field kind clang.CursorKind Retrieve the kind of the given cursor.
---@field kindSpelling string \defgroup CINDEX_DEBUG Debugging facilities <br><br>These routines are used for testing and debugging, only, and should not be relied upon. <br><br>\{
---@field language clang.LanguageKind Determine the "language" of the entity referred to by a given cursor.
---@field lexicalParent clang.Cursor Determine the lexical parent of the given cursor. <br><br>The lexical parent of a cursor is the cursor in which the given \p cursor was actually written. For many declarations, the lexical and semantic parents are equivalent (the semantic parent is returned by `clang_getCursorSemanticParent())`. They diverge when declarations or definitions are provided out-of-line. For example: <br><br>``` class C { void f(); }; <br><br>void C::f() { } ``` <br><br>In the out-of-line definition of `C::f`, the semantic parent is the class `C`, of which this function is a member. The lexical parent is the place where the declaration actually occurs in the source code; in this case, the definition occurs in the translation unit. In general, the lexical parent for a given entity can change without affecting the semantics of the program, and the lexical parent of different declarations of the same entity may be different. Changing the semantic parent of a declaration, on the other hand, can have a major impact on semantics, and redeclarations of a particular entity should all have the same semantic context. <br><br>In the example above, both declarations of `C::f` have `C` as their semantic context, while the lexical context of the first `C::f` is `C and` the lexical context of the second `C::f` is the translation unit. <br><br>For declarations written in the global scope, the lexical parent is the translation unit.
---@field linkage clang.LinkageKind Determine the linkage of the entity referred to by a given cursor.
---@field mangling string Retrieve the CXString representing the mangled name of the cursor.
---@field name string Retrieve a name for the entity referenced by this cursor.
---@field offsetOfField integer Return the offset of the field represented by the Cursor. <br><br>If the cursor is not a field declaration, -1 is returned. If the cursor semantic parent is not a record field declaration, CXTypeLayoutError_Invalid is returned. If the field's type declaration is an incomplete type, CXTypeLayoutError_Incomplete is returned. If the field's type declaration is a dependent type, CXTypeLayoutError_Dependent is returned. If the field's name S is not found, CXTypeLayoutError_InvalidFieldName is returned.
---@field overloadedDecls clang.Cursor[] Retrieve a cursor for one of the overloaded declarations referenced by a `CXCursor_OverloadedDeclRef` cursor. <br><br>\param cursor The cursor whose overloaded declarations are being queried. <br><br>\param index The zero-based index into the set of overloaded declarations in the cursor. <br><br>\returns A cursor representing the declaration referenced by the given `cursor` at the specified `index`. If the cursor does not have an associated set of overloaded declarations, or if the index is out of bounds, returns `clang_getNullCursor();`
---@field parent clang.Cursor Determine the semantic parent of the given cursor. <br><br>The semantic parent of a cursor is the cursor that semantically contains the given \p cursor. For many declarations, the lexical and semantic parents are equivalent (the lexical parent is returned by `clang_getCursorLexicalParent())`. They diverge when declarations or definitions are provided out-of-line. For example: <br><br>``` class C { void f(); }; <br><br>void C::f() { } ``` <br><br>In the out-of-line definition of `C::f`, the semantic parent is the class `C`, of which this function is a member. The lexical parent is the place where the declaration actually occurs in the source code; in this case, the definition occurs in the translation unit. In general, the lexical parent for a given entity can change without affecting the semantics of the program, and the lexical parent of different declarations of the same entity may be different. Changing the semantic parent of a declaration, on the other hand, can have a major impact on semantics, and redeclarations of a particular entity should all have the same semantic context. <br><br>In the example above, both declarations of `C::f` have `C` as their semantic context, while the lexical context of the first `C::f` is `C and` the lexical context of the second `C::f` is the translation unit. <br><br>For global declarations, the semantic parent is the translation unit.
---@field prettyPrinted string Pretty print declarations. <br><br>\param Cursor The cursor representing a declaration. <br><br>\param Policy The policy to control the entities being printed. If NULL, a default policy is used. <br><br>\returns The pretty printed declaration or the empty string for other cursors.
---@field rawCommentText string Given a cursor that represents a declaration, return the associated comment text, including comment markers.
---@field receiverType clang.Type Given a cursor pointing to an Objective-C message or property reference, or C++ method call, returns the CXType of the receiver.
---@field referenced clang.Cursor For a cursor that is a reference, retrieve a cursor representing the entity that it references. <br><br>Reference cursors refer to other entities in the AST. For example, an Objective-C superclass reference cursor refers to an Objective-C class. This function produces the cursor for the Objective-C class from the cursor for the superclass reference. If the input cursor is a declaration or definition, it returns that declaration or definition unchanged. Otherwise, returns the NULL cursor.
---@field resultType clang.Type Retrieve the return type associated with a given cursor. <br><br>This only returns a valid type if the cursor refers to a function or method.
---@field semanticParent clang.Cursor Determine the semantic parent of the given cursor. <br><br>The semantic parent of a cursor is the cursor that semantically contains the given \p cursor. For many declarations, the lexical and semantic parents are equivalent (the lexical parent is returned by `clang_getCursorLexicalParent())`. They diverge when declarations or definitions are provided out-of-line. For example: <br><br>``` class C { void f(); }; <br><br>void C::f() { } ``` <br><br>In the out-of-line definition of `C::f`, the semantic parent is the class `C`, of which this function is a member. The lexical parent is the place where the declaration actually occurs in the source code; in this case, the definition occurs in the translation unit. In general, the lexical parent for a given entity can change without affecting the semantics of the program, and the lexical parent of different declarations of the same entity may be different. Changing the semantic parent of a declaration, on the other hand, can have a major impact on semantics, and redeclarations of a particular entity should all have the same semantic context. <br><br>In the example above, both declarations of `C::f` have `C` as their semantic context, while the lexical context of the first `C::f` is `C and` the lexical context of the second `C::f` is the translation unit. <br><br>For global declarations, the semantic parent is the translation unit.
---@field sourceLocation clang.Cursor.SourceLocation Retrieve the physical location of the source constructor referenced by the given cursor. <br><br>The location of a declaration is typically the location of the name of that declaration, where the name of that declaration would occur if it is unnamed, or some keyword that introduces that particular declaration. The location of a reference is where that reference occurs within the source code.
---@field sourceRange clang.Cursor.SourceRange Retrieve the physical extent of the source construct referenced by the given cursor. <br><br>The extent of a cursor starts with the file/line/column pointing at the first character within the source construct that the cursor refers to and ends with the last character within that source construct. For a declaration, the extent covers the declaration itself. For a reference, the extent covers the location of the reference (e.g., where the referenced entity was actually used).
---@field specializedTemplate clang.Cursor Given a cursor that may represent a specialization or instantiation of a template, retrieve the cursor that represents the template that it specializes or from which it was instantiated. <br><br>This routine determines the template involved both for explicit specializations of templates and for implicit instantiations of the template, both of which are referred to as "specializations". For a class template specialization (e.g., `std::vector<bool>)`, this routine will return either the primary template (`std::vector)` or, if the specialization was instantiated from a class template partial specialization, the class template partial specialization. For a class template partial specialization and a function template specialization (including instantiations), this this routine will return the specialized template. <br><br>For members of a class template (e.g., member functions, member classes, or static data members), returns the specialized or instantiated member. Although not strictly "templates" in the C++ language, members of class templates have the same notions of specializations and instantiations that templates do, so this routine treats them similarly. <br><br>\param C A cursor that may be a specialization of a template or a member of a template. <br><br>\returns If the given cursor is a specialization or instantiation of a template or a member thereof, the template or member that it specializes or from which it was instantiated. Otherwise, returns a NULL cursor.
---@field storageClass clang.StorageClass Returns the storage class for a function or variable declaration. <br><br>If the passed in Cursor is not a function or variable declaration, CX_SC_Invalid is returned else the storage class.
---@field templateArgumentTypes clang.Type[] Retrieve a CXType representing the type of a TemplateArgument of a function decl representing a template specialization. <br><br>If the argument CXCursor does not represent a FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization whose I'th template argument has a kind of CXTemplateArgKind_Integral, an invalid type is returned. <br><br>For example, for the following declaration and specialization: template <typename T, int kInt, bool kBool> void foo() { ... } <br><br>template <> void foo<float, -7, true>(); <br><br>If called with I = 0, "float", will be returned. Invalid types will be returned for I == 1 or 2.
---@field templateKind clang.CursorKind Given a cursor that represents a template, determine the cursor kind of the specializations would be generated by instantiating the template. <br><br>This routine can be used to determine what flavor of function template, class template, or class template partial specialization is stored in the cursor. For example, it can describe whether a class template cursor is declared with "struct", "class" or "union". <br><br>\param C The cursor to query. This cursor should represent a template declaration. <br><br>\returns The cursor kind of the specializations that would be generated by instantiating the template \p C. If \p C is not a template, returns `CXCursor_NoDeclFound`.
---@field templateKindSpelling string Given a cursor that represents a template, determine the cursor kind of the specializations would be generated by instantiating the template. <br><br>This routine can be used to determine what flavor of function template, class template, or class template partial specialization is stored in the cursor. For example, it can describe whether a class template cursor is declared with "struct", "class" or "union". <br><br>\param C The cursor to query. This cursor should represent a template declaration. <br><br>\returns The cursor kind of the specializations that would be generated by instantiating the template \p C. If \p C is not a template, returns `CXCursor_NoDeclFound`.
---@field tlsKind clang.TLSKind Determine the "thread-local storage (TLS) kind" of the declaration referred to by a cursor.
---@field translationUnit clang.TranslationUnit Returns the translation unit that a cursor originated from.
---@field type clang.Type Retrieve the type of a CXCursor (if any).
---@field typedefDeclUnderlyingType clang.Type Retrieve the underlying type of a typedef declaration. <br><br>If the cursor does not reference a typedef declaration, an invalid type is returned.
---@field usr string Retrieve a Unified Symbol Resolution (USR) for the entity referenced by the given cursor. <br><br>A Unified Symbol Resolution (USR) is a string that identifies a particular entity (function, class, variable, etc.) within a program. USRs can be compared across translation units to determine, e.g., when references in one translation refer to an entity defined in another translation unit.
---@field varDeclInitializer clang.Cursor If cursor refers to a variable declaration and it has initializer returns cursor referring to the initializer otherwise return null cursor.
---@field visibility clang.VisibilityKind Describe the visibility of the entity referred to by a cursor. <br><br>This returns the default visibility if not explicitly specified by a visibility attribute. The default visibility may be changed by commandline arguments. <br><br>\param cursor The cursor to query. <br><br>\returns The visibility of the cursor.
local Cursor = {}

---@param c clang.Cursor
---@return any
function Cursor:__eq(c) end

---@param cls string
---@return any
function Cursor:as(cls) end

---Retrieve a range for a piece that forms the cursors spelling name.
---Most of the times there is only one range for the complete spelling but for
---Objective-C methods and Objective-C message expressions, there are multiple
---pieces for each selector identifier.
---
---@param pieceIndex integer # the index of the spelling name piece. If this is greater
---than the actual number of pieces, it will return a NULL (invalid) range.
---
---@param options integer # Reserved.
---@return clang.Cursor.SourceRange
function Cursor:getNameRange(pieceIndex, options) end

---Given a cursor that references something else, return the source range
---covering that reference.
---
---\param C A cursor pointing to a member reference, a declaration reference, or
---an operator call.
---\param NameFlags A bitset with three independent flags:
---CXNameRange_WantQualifier, CXNameRange_WantTemplateArgs, and
---CXNameRange_WantSinglePiece.
---\param PieceIndex For contiguous names or when passing the flag
---CXNameRange_WantSinglePiece, only one piece with index 0 is
---available. When the CXNameRange_WantSinglePiece flag is not passed for a
---non-contiguous names, this index can be used to retrieve the individual
---pieces of the name. See also CXNameRange_WantSinglePiece.
---
---@return clang.Cursor.SourceRange # s The piece of the name pointed to by the given cursor. If there is no
---name, or if the PieceIndex is out-of-range, a null-cursor will be returned.
---@param pieceIndex integer
---@param options integer
function Cursor:getReferenceNameRange(pieceIndex, options) end

---Retrieve the value of an Integral TemplateArgument (of a function
---decl representing a template specialization) as a signed long long.
---
---It is undefined to call this function on a CXCursor that does not represent a
---FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization
---whose I'th template argument is not an integral value.
---
---For example, for the following declaration and specialization:
---template <typename T, int kInt, bool kBool>
---void foo() { ... }
---
---template <>
---void foo<float, -7, true>();
---
---If called with I = 1 or 2, -7 or true will be returned, respectively.
---For I == 0, this function's behavior is undefined.
---@param index integer
---@return clang.TemplateArgumentKind
function Cursor:getTemplateArgumentKind(index) end

---Retrieve the value of an Integral TemplateArgument (of a function
---decl representing a template specialization) as an unsigned long long.
---
---It is undefined to call this function on a CXCursor that does not represent a
---FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization or
---whose I'th template argument is not an integral value.
---
---For example, for the following declaration and specialization:
---template <typename T, int kInt, bool kBool>
---void foo() { ... }
---
---template <>
---void foo<float, 2147483649, true>();
---
---If called with I = 1 or 2, 2147483649 or true will be returned, respectively.
---For I == 0, this function's behavior is undefined.
---@param index integer
---@return integer
function Cursor:getTemplateArgumentUnsignedValue(index) end

---Retrieve the value of an Integral TemplateArgument (of a function
---decl representing a template specialization) as a signed long long.
---
---It is undefined to call this function on a CXCursor that does not represent a
---FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization
---whose I'th template argument is not an integral value.
---
---For example, for the following declaration and specialization:
---template <typename T, int kInt, bool kBool>
---void foo() { ... }
---
---template <>
---void foo<float, -7, true>();
---
---If called with I = 1 or 2, -7 or true will be returned, respectively.
---For I == 0, this function's behavior is undefined.
---@param index integer
---@return integer
function Cursor:getTemplateArgumentValue(index) end

---Determine whether the given cursor has any attributes.
---@return boolean
function Cursor:hasAttrs() end

---Determine whether the given cursor represents an anonymous
---tag or namespace
---@return boolean
function Cursor:isAnonymous() end

---Determine whether the given cursor represents an anonymous record
---declaration.
---@return boolean
function Cursor:isAnonymousRecordDecl() end

---Determine whether the given cursor kind represents an attribute.
---@return boolean
function Cursor:isAttribute() end

---Returns non-zero if the cursor specifies a Record member that is a bit-field.
---@return boolean
function Cursor:isBitField() end

---Determine if a C++ record is abstract, i.e. whether a class or struct
---has a pure virtual member function.
---@return boolean
function Cursor:isCXXAbstract() end

---Determine if a C++ member function or member function template is
---declared 'const'.
---@return boolean
function Cursor:isCXXConstMethod() end

---Determine if a C++ constructor is a converting constructor.
---@return boolean
function Cursor:isCXXConvertingConstructor() end

---Determine if a C++ member function is a copy-assignment operator,
---returning 1 if such is the case and 0 otherwise.
---
---> A copy-assignment operator `X::operator=` is a non-static,
---> non-template member function of _class_ `X` with exactly one
---> parameter of type `X`, `X&`, `const X&`, `volatile X&` or `const
---> volatile X&`.
---
---That is, for example, the `operator=` in:
---
---class Foo {
---bool operator=(const volatile Foo&);
---};
---
---Is a copy-assignment operator, while the `operator=` in:
---
---class Bar {
---bool operator=(const int&);
---};
---
---Is not.
---@return boolean
function Cursor:isCXXCopyAssignmentOperator() end

---Determine if a C++ constructor is a copy constructor.
---@return boolean
function Cursor:isCXXCopyConstructor() end

---Determine if a C++ constructor is the default constructor.
---@return boolean
function Cursor:isCXXDefaultConstructor() end

---Determine if a C++ method is declared '= default'.
---@return boolean
function Cursor:isCXXDefaultedMethod() end

---Determine if a C++ method is declared '= delete'.
---@return boolean
function Cursor:isCXXDeletedMethod() end

---Determines if a C++ constructor or conversion function was declared
---explicit, returning 1 if such is the case and 0 otherwise.
---
---Constructors or conversion functions are declared explicit through
---the use of the explicit specifier.
---
---For example, the following constructor and conversion function are
---not explicit as they lack the explicit specifier:
---
---class Foo {
---Foo();
---operator int();
---};
---
---While the following constructor and conversion function are
---explicit as they are declared with the explicit specifier.
---
---class Foo {
---explicit Foo();
---explicit operator int();
---};
---
---This function will return 0 when given a cursor pointing to one of
---the former declarations and it will return 1 for a cursor pointing
---to the latter declarations.
---
---The explicit specifier allows the user to specify a
---conditional compile-time expression whose value decides
---whether the marked element is explicit or not.
---
---For example:
---
---constexpr bool foo(int i) { return i % 2 == 0; }
---
---class Foo {
---explicit(foo(1)) Foo();
---explicit(foo(2)) operator int();
---}
---
---This function will return 0 for the constructor and 1 for
---the conversion function.
---@return boolean
function Cursor:isCXXExplicitMethod() end

---Determine if a C++ member function is a move-assignment operator,
---returning 1 if such is the case and 0 otherwise.
---
---> A move-assignment operator `X::operator=` is a non-static,
---> non-template member function of _class_ `X` with exactly one
---> parameter of type `X&&`, `const X&&`, `volatile X&&` or `const
---> volatile X&&`.
---
---That is, for example, the `operator=` in:
---
---class Foo {
---bool operator=(const volatile Foo&&);
---};
---
---Is a move-assignment operator, while the `operator=` in:
---
---class Bar {
---bool operator=(const int&&);
---};
---
---Is not.
---@return boolean
function Cursor:isCXXMoveAssignmentOperator() end

---Determine if a C++ constructor is a move constructor.
---@return boolean
function Cursor:isCXXMoveConstructor() end

---Determine if a C++ field is declared 'mutable'.
---@return boolean
function Cursor:isCXXMutableField() end

---Determine if a C++ member function or member function template is
---pure virtual.
---@return boolean
function Cursor:isCXXPureVirtualMethod() end

---Determine if a C++ member function or member function template is
---declared 'static'.
---@return boolean
function Cursor:isCXXStaticMethod() end

---Determine if a C++ member function or member function template is
---explicitly declared 'virtual' or if it overrides a virtual method from
---one of the base classes.
---@return boolean
function Cursor:isCXXVirtualMethod() end

---Determine whether the given cursor kind represents a declaration.
---@return boolean
function Cursor:isDeclaration() end

---Determine whether the declaration pointed to by this cursor
---is also a definition of that entity.
---@return boolean
function Cursor:isDefinition() end

---Is this a deprecated member
---@return boolean
function Cursor:isDeprecated() end

---Determine whether the given cursor kind represents an expression.
---@return boolean
function Cursor:isExpression() end

---Determine whether a  CXCursor that is a function declaration, is an
---inline declaration.
---@return boolean
function Cursor:isFunctionInlined() end

---Determine whether the given cursor represents an inline namespace
---declaration.
---@return boolean
function Cursor:isInlineNamespace() end

---Determine whether the given cursor kind represents an invalid
---cursor.
---@return boolean
function Cursor:isInvalid() end

---Determine whether the given declaration is invalid.
---
---A declaration is invalid if it could not be parsed successfully.
---
---@return boolean # s non-zero if the cursor represents a declaration and it is
---invalid, otherwise NULL.
function Cursor:isInvalidDeclaration() end

---Determine whether a  CXCursor that is a macro, is a
---builtin one.
---@return boolean
function Cursor:isMacroBuiltin() end

---Determine whether a  CXCursor that is a macro, is
---function like.
---@return boolean
function Cursor:isMacroFunctionLike() end

---Returns non-zero if \p cursor is null.
---@return boolean
function Cursor:isNull() end

---Determine whether the given cursor represents a preprocessing
---element, such as a preprocessor directive or macro instantiation.
---@return boolean
function Cursor:isPreprocessing() end

---Determine whether the given cursor kind represents a simple
---reference.
---
---Note that other kinds of cursors (such as expressions) can also refer to
---other cursors. Use clang_getCursorReferenced() to determine whether a
---particular cursor refers to another entity.
---@return boolean
function Cursor:isReference() end

---Determine if an enum declaration refers to a scoped enum.
---@return boolean
function Cursor:isScopedEnumDecl() end

---Determine whether the given cursor kind represents a statement.
---@return boolean
function Cursor:isStatement() end

---Determine whether the given cursor kind represents a translation
---unit.
---@return boolean
function Cursor:isTranslationUnit() end

---Determine whether the given cursor represents a currently
---unexposed piece of the AST (e.g., CXCursor_UnexposedStmt).
---@return boolean
function Cursor:isUnexposed() end

---Returns non-zero if the given cursor is a variadic function or method.
---@return boolean
function Cursor:isVariadic() end

---Returns 1 if the base class specified by the cursor with kind
---CX_CXXBaseSpecifier is virtual.
---@return boolean
function Cursor:isVirtualBase() end

---@return clang.Cursor
function Cursor:shared_from_this() end

return Cursor