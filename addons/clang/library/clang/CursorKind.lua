---@meta clang.CursorKind

---@type clang.CursorKind
local VALUE

---
---@enum clang.CursorKind
local CursorKind = {
    ---The GNU address of label extension, representing &&label.
    AddrLabelExpr = 120,
    AlignedAttr = 441,
    AnnotateAttr = 406,
    ---OpenMP 5.0 [2.1.5, Array Section].
    ---OpenACC 3.3 [2.7.1, Data Specification for Data Clauses (Sub Arrays)]
    ArraySectionExpr = 147,
    ---[C99 6.5.2.1] Array Subscripting.
    ArraySubscriptExpr = 113,
    AsmLabelAttr = 407,
    AsmStmt = 215,
    ---A builtin binary operation expression such as "x + y" or
    ---"x <= y".
    BinaryOperator = 114,
    ---An expression that represents a block literal.
    BlockExpr = 105,
    ---A break statement.
    BreakStmt = 213,
    ---C++2a std::bit_cast expression.
    BuiltinBitCastExpr = 280,
    ---An explicit cast in C (C99 6.5.4) or a C-style cast in C++
    ---(C++ [expr.cast]), which uses the syntax (Type)expr.
    ---
    ---For example: (int)f.
    CStyleCastExpr = 117,
    CUDAConstantAttr = 412,
    CUDADeviceAttr = 413,
    CUDAGlobalAttr = 414,
    CUDAHostAttr = 415,
    CUDASharedAttr = 416,
    ---An access specifier.
    CXXAccessSpecifier = 39,
    ---OpenCL's addrspace_cast<> expression.
    CXXAddrspaceCastExpr = 152,
    CXXBaseSpecifier = 44,
    ---[C++ 2.13.5] C++ Boolean Literal.
    CXXBoolLiteralExpr = 130,
    ---C++'s catch statement.
    CXXCatchStmt = 223,
    ---C++'s const_cast<> expression.
    CXXConstCastExpr = 127,
    ---A delete expression for memory deallocation and destructor calls,
    ---e.g. "delete[] pArray".
    CXXDeleteExpr = 135,
    ---C++'s dynamic_cast<> expression.
    CXXDynamicCastExpr = 125,
    CXXFinalAttr = 404,
    ---C++'s for (* : *) statement.
    CXXForRangeStmt = 225,
    ---Represents an explicit C++ type conversion that uses "functional"
    ---notion (C++ [expr.type.conv]).
    ---
    ---Example:
    ---\code
    ---x = int(0.5);
    ---\endcode
    CXXFunctionalCastExpr = 128,
    ---A C++ class method.
    CXXMethod = 21,
    ---A new expression for memory allocation and constructor calls, e.g:
    ---"new CXXNewExpr(foo)".
    CXXNewExpr = 134,
    ---[C++0x 2.14.7] C++ Pointer Literal.
    CXXNullPtrLiteralExpr = 131,
    CXXOverrideAttr = 405,
    ---Expression that references a C++20 parenthesized list aggregate
    ---initializer.
    CXXParenListInitExpr = 155,
    ---C++'s reinterpret_cast<> expression.
    CXXReinterpretCastExpr = 126,
    ---C++'s static_cast<> expression.
    CXXStaticCastExpr = 124,
    ---Represents the "this" expression in C++
    CXXThisExpr = 132,
    ---[C++ 15] C++ Throw Expression.
    ---
    ---This handles 'throw' and 'throw' assignment-expression. When
    ---assignment-expression isn't present, Op will be null.
    CXXThrowExpr = 133,
    ---C++'s try statement.
    CXXTryStmt = 224,
    ---A C++ typeid expression (C++ [expr.typeid]).
    CXXTypeidExpr = 129,
    ---An expression that calls a function.
    CallExpr = 103,
    ---A case statement.
    CaseStmt = 203,
    ---A character literal.
    CharacterLiteral = 110,
    ---A C++ class.
    ClassDecl = 4,
    ---A C++ class template.
    ClassTemplate = 31,
    ---A C++ class template partial specialization.
    ClassTemplatePartialSpecialization = 32,
    ---Compound assignment such as "+=".
    CompoundAssignOperator = 115,
    ---[C99 6.5.2.5]
    CompoundLiteralExpr = 118,
    ---A group of statements like { stmt stmt }.
    ---
    ---This cursor kind is used to describe compound statements, e.g. function
    ---bodies.
    CompoundStmt = 202,
    ---a concept declaration.
    ConceptDecl = 604,
    ---Expression that references a C++20 concept.
    ConceptSpecializationExpr = 153,
    ---The ?: ternary operator.
    ConditionalOperator = 116,
    ConstAttr = 410,
    ---A C++ constructor.
    Constructor = 24,
    ---A continue statement.
    ContinueStmt = 212,
    ConvergentAttr = 438,
    ---A C++ conversion function.
    ConversionFunction = 26,
    DLLExport = 418,
    DLLImport = 419,
    ---An expression that refers to some value declaration, such
    ---as a function, variable, or enumerator.
    DeclRefExpr = 101,
    ---Adaptor class for mixing declarations with statements and
    ---expressions.
    DeclStmt = 231,
    ---A default statement.
    DefaultStmt = 204,
    ---A C++ destructor.
    Destructor = 25,
    ---A do statement.
    DoStmt = 208,
    ---An enumerator constant.
    EnumConstantDecl = 7,
    ---An enumeration.
    EnumDecl = 5,
    ---A field (in C) or non-static data member (in C++) in a
    ---struct, union, or C++ class.
    FieldDecl = 6,
    FirstAttr = 400,
    FirstDecl = 1,
    FirstExpr = 100,
    FirstExtraDecl = 600,
    FirstInvalid = 70,
    FirstPreprocessing = 500,
    FirstRef = 40,
    FirstStmt = 200,
    ---Fixed point literal
    FixedPointLiteral = 149,
    FlagEnum = 437,
    ---A floating point number literal.
    FloatingLiteral = 107,
    ---A for statement.
    ForStmt = 209,
    ---a friend declaration.
    FriendDecl = 603,
    ---A function.
    FunctionDecl = 8,
    ---A C++ function template.
    FunctionTemplate = 30,
    ---A GCC inline assembly statement extension.
    GCCAsmStmt = 215,
    ---Implements the GNU __null extension, which is a name for a null
    ---pointer constant that has integral type (e.g., int or long) and is the same
    ---size and alignment as a pointer.
    ---
    ---The __null extension is typically only used by system headers, which define
    ---NULL as __null in C++ rather than using 0 (which is an integer that may not
    ---match the size of a pointer).
    GNUNullExpr = 123,
    ---Represents a C11 generic selection.
    GenericSelectionExpr = 122,
    ---A goto statement.
    GotoStmt = 210,
    IBActionAttr = 401,
    IBOutletAttr = 402,
    IBOutletCollectionAttr = 403,
    ---An if statement
    IfStmt = 205,
    ---An imaginary number literal.
    ImaginaryLiteral = 108,
    InclusionDirective = 503,
    ---An indirect goto statement.
    IndirectGotoStmt = 211,
    ---Describes an C or C++ initializer list.
    InitListExpr = 119,
    ---An integer literal.
    IntegerLiteral = 106,
    InvalidCode = 73,
    InvalidFile = 70,
    ---A reference to a labeled statement.
    ---
    ---This cursor kind is used to describe the jump to "start_over" in the
    ---goto statement in the following example:
    ---
    ---\code
    ---start_over:
    ---++counter;
    ---
    ---goto start_over;
    ---\endcode
    ---
    ---A label reference cursor refers to a label statement.
    LabelRef = 48,
    ---A labelled statement in a function.
    ---
    ---This cursor kind is used to describe the "start_over:" label statement in
    ---the following example:
    ---
    ---\code
    ---start_over:
    ---++counter;
    ---\endcode
    LabelStmt = 201,
    LambdaExpr = 144,
    LastAttr = 441,
    LastDecl = 39,
    LastExpr = 156,
    LastExtraDecl = 604,
    LastInvalid = 73,
    LastPreprocessing = 503,
    LastRef = 50,
    LastStmt = 321,
    ---A linkage specification, e.g. 'extern "C"'.
    LinkageSpec = 23,
    ---A MS inline assembly statement extension.
    MSAsmStmt = 229,
    MacroDefinition = 501,
    MacroExpansion = 502,
    MacroInstantiation = 502,
    ---A reference to a member of a struct, union, or class that occurs in
    ---some non-expression context, e.g., a designated initializer.
    MemberRef = 47,
    ---An expression that refers to a member of a struct, union,
    ---class, Objective-C class, etc.
    MemberRefExpr = 102,
    ---A module import declaration.
    ModuleImportDecl = 600,
    NSConsumed = 424,
    NSConsumesSelf = 423,
    NSReturnsAutoreleased = 422,
    NSReturnsNotRetained = 421,
    NSReturnsRetained = 420,
    ---A C++ namespace.
    Namespace = 22,
    ---A C++ namespace alias declaration.
    NamespaceAlias = 33,
    ---A reference to a namespace or namespace alias.
    NamespaceRef = 46,
    NoDeclFound = 71,
    NoDuplicateAttr = 411,
    ---A C++ non-type template parameter.
    NonTypeTemplateParameter = 28,
    NotImplemented = 72,
    ---The null statement ";": C99 6.8.3p3.
    ---
    ---This cursor kind is used to describe the null statement.
    NullStmt = 230,
    ---OpenMP 5.0 [2.1.4, Array Shaping].
    OMPArrayShapingExpr = 150,
    ---OpenMP assume directive.
    OMPAssumeDirective = 309,
    ---OpenMP atomic directive.
    OMPAtomicDirective = 249,
    ---OpenMP barrier directive.
    OMPBarrierDirective = 244,
    ---OpenMP cancel directive.
    OMPCancelDirective = 256,
    ---OpenMP cancellation point directive.
    OMPCancellationPointDirective = 255,
    ---OpenMP canonical loop.
    OMPCanonicalLoop = 289,
    ---OpenMP critical directive.
    OMPCriticalDirective = 242,
    ---OpenMP depobj directive.
    OMPDepobjDirective = 286,
    ---OpenMP dispatch directive.
    OMPDispatchDirective = 291,
    ---OpenMP distribute directive.
    OMPDistributeDirective = 260,
    ---OpenMP distribute parallel for directive.
    OMPDistributeParallelForDirective = 266,
    ---OpenMP distribute parallel for simd directive.
    OMPDistributeParallelForSimdDirective = 267,
    ---OpenMP distribute simd directive.
    OMPDistributeSimdDirective = 268,
    ---OpenMP error directive.
    OMPErrorDirective = 305,
    ---OpenMP flush directive.
    OMPFlushDirective = 246,
    ---OpenMP for directive.
    OMPForDirective = 234,
    ---OpenMP for SIMD directive.
    OMPForSimdDirective = 250,
    ---OpenMP loop directive.
    OMPGenericLoopDirective = 295,
    ---OpenMP interchange directive.
    OMPInterchangeDirective = 308,
    ---OpenMP interop directive.
    OMPInteropDirective = 290,
    ---OpenMP 5.0 [2.1.6 Iterators]
    OMPIteratorExpr = 151,
    ---OpenMP masked directive.
    OMPMaskedDirective = 292,
    ---OpenMP masked taskloop directive.
    OMPMaskedTaskLoopDirective = 301,
    ---OpenMP masked taskloop simd directive.
    OMPMaskedTaskLoopSimdDirective = 302,
    ---OpenMP master directive.
    OMPMasterDirective = 241,
    ---OpenMP master taskloop directive.
    OMPMasterTaskLoopDirective = 281,
    ---OpenMP master taskloop simd directive.
    OMPMasterTaskLoopSimdDirective = 283,
    ---OpenMP metadirective directive.
    OMPMetaDirective = 294,
    ---OpenMP ordered directive.
    OMPOrderedDirective = 248,
    ---OpenMP parallel directive.
    OMPParallelDirective = 232,
    ---OpenMP parallel for directive.
    OMPParallelForDirective = 238,
    ---OpenMP parallel for SIMD directive.
    OMPParallelForSimdDirective = 251,
    ---OpenMP parallel loop directive.
    OMPParallelGenericLoopDirective = 298,
    ---OpenMP parallel masked directive.
    OMPParallelMaskedDirective = 300,
    ---OpenMP parallel masked taskloop directive.
    OMPParallelMaskedTaskLoopDirective = 303,
    ---OpenMP parallel masked taskloop simd directive.
    OMPParallelMaskedTaskLoopSimdDirective = 304,
    ---OpenMP parallel master directive.
    OMPParallelMasterDirective = 285,
    ---OpenMP parallel master taskloop directive.
    OMPParallelMasterTaskLoopDirective = 282,
    ---OpenMP parallel master taskloop simd directive.
    OMPParallelMasterTaskLoopSimdDirective = 284,
    ---OpenMP parallel sections directive.
    OMPParallelSectionsDirective = 239,
    ---OpenMP reverse directive.
    OMPReverseDirective = 307,
    ---OpenMP scan directive.
    OMPScanDirective = 287,
    ---OpenMP scope directive.
    OMPScopeDirective = 306,
    ---OpenMP section directive.
    OMPSectionDirective = 236,
    ---OpenMP sections directive.
    OMPSectionsDirective = 235,
    ---OpenMP SIMD directive.
    OMPSimdDirective = 233,
    ---OpenMP single directive.
    OMPSingleDirective = 237,
    ---OpenMP target data directive.
    OMPTargetDataDirective = 257,
    ---OpenMP target directive.
    OMPTargetDirective = 252,
    ---OpenMP target enter data directive.
    OMPTargetEnterDataDirective = 261,
    ---OpenMP target exit data directive.
    OMPTargetExitDataDirective = 262,
    ---OpenMP target parallel directive.
    OMPTargetParallelDirective = 263,
    ---OpenMP target parallel for directive.
    OMPTargetParallelForDirective = 264,
    ---OpenMP target parallel for simd directive.
    OMPTargetParallelForSimdDirective = 269,
    ---OpenMP target parallel loop directive.
    OMPTargetParallelGenericLoopDirective = 299,
    ---OpenMP target simd directive.
    OMPTargetSimdDirective = 270,
    ---OpenMP target teams directive.
    OMPTargetTeamsDirective = 275,
    ---OpenMP target teams distribute directive.
    OMPTargetTeamsDistributeDirective = 276,
    ---OpenMP target teams distribute parallel for directive.
    OMPTargetTeamsDistributeParallelForDirective = 277,
    ---OpenMP target teams distribute parallel for simd directive.
    OMPTargetTeamsDistributeParallelForSimdDirective = 278,
    ---OpenMP target teams distribute simd directive.
    OMPTargetTeamsDistributeSimdDirective = 279,
    ---OpenMP target teams loop directive.
    OMPTargetTeamsGenericLoopDirective = 297,
    ---OpenMP target update directive.
    OMPTargetUpdateDirective = 265,
    ---OpenMP task directive.
    OMPTaskDirective = 240,
    ---OpenMP taskloop directive.
    OMPTaskLoopDirective = 258,
    ---OpenMP taskloop simd directive.
    OMPTaskLoopSimdDirective = 259,
    ---OpenMP taskgroup directive.
    OMPTaskgroupDirective = 254,
    ---OpenMP taskwait directive.
    OMPTaskwaitDirective = 245,
    ---OpenMP taskyield directive.
    OMPTaskyieldDirective = 243,
    ---OpenMP teams directive.
    OMPTeamsDirective = 253,
    ---OpenMP teams distribute directive.
    OMPTeamsDistributeDirective = 271,
    ---OpenMP teams distribute parallel for directive.
    OMPTeamsDistributeParallelForDirective = 274,
    ---OpenMP teams distribute parallel for simd directive.
    OMPTeamsDistributeParallelForSimdDirective = 273,
    ---OpenMP teams distribute simd directive.
    OMPTeamsDistributeSimdDirective = 272,
    ---OpenMP teams loop directive.
    OMPTeamsGenericLoopDirective = 296,
    ---OpenMP tile directive.
    OMPTileDirective = 288,
    ---OpenMP unroll directive.
    OMPUnrollDirective = 293,
    ---Objective-C's \@catch statement.
    ObjCAtCatchStmt = 217,
    ---Objective-C's \@finally statement.
    ObjCAtFinallyStmt = 218,
    ---Objective-C's \@synchronized statement.
    ObjCAtSynchronizedStmt = 220,
    ---Objective-C's \@throw statement.
    ObjCAtThrowStmt = 219,
    ---Objective-C's overall \@try-\@catch-\@finally statement.
    ObjCAtTryStmt = 216,
    ---Objective-C's autorelease pool statement.
    ObjCAutoreleasePoolStmt = 221,
    ---Represents an @available(...) check.
    ObjCAvailabilityCheckExpr = 148,
    ---Objective-c Boolean Literal.
    ObjCBoolLiteralExpr = 145,
    ObjCBoxable = 436,
    ---An Objective-C "bridged" cast expression, which casts between
    ---Objective-C pointers and C pointers, transferring ownership in the process.
    ---
    ---\code
    ---NSString *str = (__bridge_transfer NSString *)CFCreateString();
    ---\endcode
    ObjCBridgedCastExpr = 141,
    ---An Objective-C \@interface for a category.
    ObjCCategoryDecl = 12,
    ---An Objective-C \@implementation for a category.
    ObjCCategoryImplDecl = 19,
    ---An Objective-C class method.
    ObjCClassMethodDecl = 17,
    ObjCClassRef = 42,
    ObjCDesignatedInitializer = 434,
    ---An Objective-C \@dynamic definition.
    ObjCDynamicDecl = 38,
    ---An Objective-C \@encode expression.
    ObjCEncodeExpr = 138,
    ObjCException = 425,
    ObjCExplicitProtocolImpl = 433,
    ---Objective-C's collection statement.
    ObjCForCollectionStmt = 222,
    ---An Objective-C \@implementation.
    ObjCImplementationDecl = 18,
    ObjCIndependentClass = 427,
    ---An Objective-C instance method.
    ObjCInstanceMethodDecl = 16,
    ---An Objective-C \@interface.
    ObjCInterfaceDecl = 11,
    ---An Objective-C instance variable.
    ObjCIvarDecl = 15,
    ---An expression that sends a message to an Objective-C
    ---object or class.
    ObjCMessageExpr = 104,
    ObjCNSObject = 426,
    ObjCPreciseLifetime = 428,
    ---An Objective-C \@property declaration.
    ObjCPropertyDecl = 14,
    ---An Objective-C \@protocol declaration.
    ObjCProtocolDecl = 13,
    ---An Objective-C \@protocol expression.
    ObjCProtocolExpr = 140,
    ObjCProtocolRef = 41,
    ObjCRequiresSuper = 430,
    ObjCReturnsInnerPointer = 429,
    ObjCRootClass = 431,
    ObjCRuntimeVisible = 435,
    ---An Objective-C \@selector expression.
    ObjCSelectorExpr = 139,
    ---Represents the "self" expression in an Objective-C method.
    ObjCSelfExpr = 146,
    ---An Objective-C string literal i.e. @"foo".
    ObjCStringLiteral = 137,
    ObjCSubclassingRestricted = 432,
    ObjCSuperClassRef = 40,
    ---An Objective-C \@synthesize definition.
    ObjCSynthesizeDecl = 37,
    ---OpenACC Compute Construct.
    OpenACCComputeConstruct = 320,
    ---OpenACC Loop Construct.
    OpenACCLoopConstruct = 321,
    ---A code completion overload candidate.
    OverloadCandidate = 700,
    ---A reference to a set of overloaded functions or function templates
    ---that has not yet been resolved to a specific function or function template.
    ---
    ---An overloaded declaration reference cursor occurs in C++ templates where
    ---a dependent name refers to a function. For example:
    ---
    ---\code
    ---template<typename T> void swap(T&, T&);
    ---
    ---struct X { ... };
    ---void swap(X&, X&);
    ---
    ---template<typename T>
    ---void reverse(T* first, T* last) {
    ---while (first < last - 1) {
    ---swap(*first, *--last);
    ---++first;
    ---}
    ---}
    ---
    ---struct Y { };
    ---void swap(Y&, Y&);
    ---\endcode
    ---
    ---Here, the identifier "swap" is associated with an overloaded declaration
    ---reference. In the template definition, "swap" refers to either of the two
    ---"swap" functions declared above, so both results will be available. At
    ---instantiation time, "swap" may also refer to other functions found via
    ---argument-dependent lookup (e.g., the "swap" function at the end of the
    ---example).
    ---
    ---The functions \c clang_getNumOverloadedDecls() and
    ---\c clang_getOverloadedDecl() can be used to retrieve the definitions
    ---referenced by this cursor.
    OverloadedDeclRef = 49,
    ---Represents a C++0x pack expansion that produces a sequence of
    ---expressions.
    ---
    ---A pack expansion expression contains a pattern (which itself is an
    ---expression) followed by an ellipsis. For example:
    ---
    ---\code
    ---template<typename F, typename ...Types>
    ---void forward(F f, Types &&...args) {
    ---f(static_cast<Types&&>(args)...);
    ---}
    ---\endcode
    PackExpansionExpr = 142,
    ---Represents a C++26 pack indexing expression.
    PackIndexingExpr = 156,
    PackedAttr = 408,
    ---A parenthesized expression, e.g. "(1)".
    ---
    ---This AST node is only formed if full location information is requested.
    ParenExpr = 111,
    ---A function or method parameter.
    ParmDecl = 10,
    PreprocessingDirective = 500,
    PureAttr = 409,
    ---Expression that references a C++20 requires expression.
    RequiresExpr = 154,
    ---A return statement.
    ReturnStmt = 214,
    ---Windows Structured Exception Handling's except statement.
    SEHExceptStmt = 227,
    ---Windows Structured Exception Handling's finally statement.
    SEHFinallyStmt = 228,
    ---Windows Structured Exception Handling's leave statement.
    SEHLeaveStmt = 247,
    ---Windows Structured Exception Handling's try statement.
    SEHTryStmt = 226,
    ---Represents an expression that computes the length of a parameter
    ---pack.
    ---
    ---\code
    ---template<typename ...Types>
    ---struct count {
    ---static const unsigned value = sizeof...(Types);
    ---};
    ---\endcode
    SizeOfPackExpr = 143,
    ---A static_assert or _Static_assert node
    StaticAssert = 602,
    ---This is the GNU Statement Expression extension: ({int X=4; X;})
    StmtExpr = 121,
    ---A string literal.
    StringLiteral = 109,
    ---A C or C++ struct.
    StructDecl = 2,
    ---A switch statement.
    SwitchStmt = 206,
    ---A reference to a class template, function template, template
    ---template parameter, or class template partial specialization.
    TemplateRef = 45,
    ---A C++ template template parameter.
    TemplateTemplateParameter = 29,
    ---A C++ template type parameter.
    TemplateTypeParameter = 27,
    ---Cursor that represents the translation unit itself.
    ---
    ---The translation unit cursor exists primarily to act as the root
    ---cursor for traversing the contents of a translation unit.
    TranslationUnit = 350,
    ---A C++ alias declaration
    TypeAliasDecl = 36,
    TypeAliasTemplateDecl = 601,
    ---A reference to a type declaration.
    ---
    ---A type reference occurs anywhere where a type is named but not
    ---declared. For example, given:
    ---
    ---\code
    ---typedef unsigned size_type;
    ---size_type size;
    ---\endcode
    ---
    ---The typedef is a declaration of size_type (CXCursor_TypedefDecl),
    ---while the type of the variable "size" is referenced. The cursor
    ---referenced by the type of size is the typedef for size_type.
    TypeRef = 43,
    ---A typedef.
    TypedefDecl = 20,
    ---A unary expression. (noexcept, sizeof, or other traits)
    UnaryExpr = 136,
    ---This represents the unary-expression's (except sizeof and
    ---alignof).
    UnaryOperator = 112,
    ---An attribute whose specific kind is not exposed via this
    ---interface.
    UnexposedAttr = 400,
    ---A declaration whose specific kind is not exposed via this
    ---interface.
    ---
    ---Unexposed declarations have the same operations as any other kind
    ---of declaration; one can extract their location information,
    ---spelling, find their definitions, etc. However, the specific kind
    ---of the declaration is not reported.
    UnexposedDecl = 1,
    ---An expression whose specific kind is not exposed via this
    ---interface.
    ---
    ---Unexposed expressions have the same operations as any other kind
    ---of expression; one can extract their location information,
    ---spelling, children, etc. However, the specific kind of the
    ---expression is not reported.
    UnexposedExpr = 100,
    ---A statement whose specific kind is not exposed via this
    ---interface.
    ---
    ---Unexposed statements have the same operations as any other kind of
    ---statement; one can extract their location information, spelling,
    ---children, etc. However, the specific kind of the statement is not
    ---reported.
    UnexposedStmt = 200,
    ---A C or C++ union.
    UnionDecl = 3,
    ---A C++ using declaration.
    UsingDeclaration = 35,
    ---A C++ using directive.
    UsingDirective = 34,
    ---A variable.
    VarDecl = 9,
    ---A reference to a variable that occurs in some non-expression
    ---context, e.g., a C++ lambda capture list.
    VariableRef = 50,
    VisibilityAttr = 417,
    WarnUnusedAttr = 439,
    WarnUnusedResultAttr = 440,
    ---A while statement.
    WhileStmt = 207,
}

return CursorKind