---@meta clang.CursorKind

---@type clang.CursorKind
local VALUE

---@enum clang.CursorKind
local CursorKind = {
    ---The GNU address of label extension, representing &&label.
    AddrLabelExpr = VALUE,
    AlignedAttr = VALUE,
    AnnotateAttr = VALUE,
    ---OpenMP 5.0 [2.1.5, Array Section].
    ---OpenACC 3.3 [2.7.1, Data Specification for Data Clauses (Sub Arrays)]
    ArraySectionExpr = VALUE,
    ---[C99 6.5.2.1] Array Subscripting.
    ArraySubscriptExpr = VALUE,
    AsmLabelAttr = VALUE,
    AsmStmt = VALUE,
    ---A builtin binary operation expression such as "x + y" or
    ---"x <= y".
    BinaryOperator = VALUE,
    ---An expression that represents a block literal.
    BlockExpr = VALUE,
    ---A break statement.
    BreakStmt = VALUE,
    ---C++2a std::bit_cast expression.
    BuiltinBitCastExpr = VALUE,
    ---An explicit cast in C (C99 6.5.4) or a C-style cast in C++
    ---(C++ [expr.cast]), which uses the syntax (Type)expr.
    ---
    ---For example: (int)f.
    CStyleCastExpr = VALUE,
    CUDAConstantAttr = VALUE,
    CUDADeviceAttr = VALUE,
    CUDAGlobalAttr = VALUE,
    CUDAHostAttr = VALUE,
    CUDASharedAttr = VALUE,
    ---An access specifier.
    CXXAccessSpecifier = VALUE,
    ---OpenCL's addrspace_cast<> expression.
    CXXAddrspaceCastExpr = VALUE,
    CXXBaseSpecifier = VALUE,
    ---[C++ 2.13.5] C++ Boolean Literal.
    CXXBoolLiteralExpr = VALUE,
    ---C++'s catch statement.
    CXXCatchStmt = VALUE,
    ---C++'s const_cast<> expression.
    CXXConstCastExpr = VALUE,
    ---A delete expression for memory deallocation and destructor calls,
    ---e.g. "delete[] pArray".
    CXXDeleteExpr = VALUE,
    ---C++'s dynamic_cast<> expression.
    CXXDynamicCastExpr = VALUE,
    CXXFinalAttr = VALUE,
    ---C++'s for (* : *) statement.
    CXXForRangeStmt = VALUE,
    ---Represents an explicit C++ type conversion that uses "functional"
    ---notion (C++ [expr.type.conv]).
    ---
    ---Example:
    ---\code
    ---x = int(0.5);
    ---\endcode
    CXXFunctionalCastExpr = VALUE,
    ---A C++ class method.
    CXXMethod = VALUE,
    ---A new expression for memory allocation and constructor calls, e.g:
    ---"new CXXNewExpr(foo)".
    CXXNewExpr = VALUE,
    ---[C++0x 2.14.7] C++ Pointer Literal.
    CXXNullPtrLiteralExpr = VALUE,
    CXXOverrideAttr = VALUE,
    ---Expression that references a C++20 parenthesized list aggregate
    ---initializer.
    CXXParenListInitExpr = VALUE,
    ---C++'s reinterpret_cast<> expression.
    CXXReinterpretCastExpr = VALUE,
    ---C++'s static_cast<> expression.
    CXXStaticCastExpr = VALUE,
    ---Represents the "this" expression in C++
    CXXThisExpr = VALUE,
    ---[C++ 15] C++ Throw Expression.
    ---
    ---This handles 'throw' and 'throw' assignment-expression. When
    ---assignment-expression isn't present, Op will be null.
    CXXThrowExpr = VALUE,
    ---C++'s try statement.
    CXXTryStmt = VALUE,
    ---A C++ typeid expression (C++ [expr.typeid]).
    CXXTypeidExpr = VALUE,
    ---An expression that calls a function.
    CallExpr = VALUE,
    ---A case statement.
    CaseStmt = VALUE,
    ---A character literal.
    CharacterLiteral = VALUE,
    ---A C++ class.
    ClassDecl = VALUE,
    ---A C++ class template.
    ClassTemplate = VALUE,
    ---A C++ class template partial specialization.
    ClassTemplatePartialSpecialization = VALUE,
    ---Compound assignment such as "+=".
    CompoundAssignOperator = VALUE,
    ---[C99 6.5.2.5]
    CompoundLiteralExpr = VALUE,
    ---A group of statements like { stmt stmt }.
    ---
    ---This cursor kind is used to describe compound statements, e.g. function
    ---bodies.
    CompoundStmt = VALUE,
    ---a concept declaration.
    ConceptDecl = VALUE,
    ---Expression that references a C++20 concept.
    ConceptSpecializationExpr = VALUE,
    ---The ?: ternary operator.
    ConditionalOperator = VALUE,
    ConstAttr = VALUE,
    ---A C++ constructor.
    Constructor = VALUE,
    ---A continue statement.
    ContinueStmt = VALUE,
    ConvergentAttr = VALUE,
    ---A C++ conversion function.
    ConversionFunction = VALUE,
    DLLExport = VALUE,
    DLLImport = VALUE,
    ---An expression that refers to some value declaration, such
    ---as a function, variable, or enumerator.
    DeclRefExpr = VALUE,
    ---Adaptor class for mixing declarations with statements and
    ---expressions.
    DeclStmt = VALUE,
    ---A default statement.
    DefaultStmt = VALUE,
    ---A C++ destructor.
    Destructor = VALUE,
    ---A do statement.
    DoStmt = VALUE,
    ---An enumerator constant.
    EnumConstantDecl = VALUE,
    ---An enumeration.
    EnumDecl = VALUE,
    ---A field (in C) or non-static data member (in C++) in a
    ---struct, union, or C++ class.
    FieldDecl = VALUE,
    FirstAttr = VALUE,
    FirstDecl = VALUE,
    FirstExpr = VALUE,
    FirstExtraDecl = VALUE,
    FirstInvalid = VALUE,
    FirstPreprocessing = VALUE,
    FirstRef = VALUE,
    FirstStmt = VALUE,
    ---Fixed point literal
    FixedPointLiteral = VALUE,
    FlagEnum = VALUE,
    ---A floating point number literal.
    FloatingLiteral = VALUE,
    ---A for statement.
    ForStmt = VALUE,
    ---a friend declaration.
    FriendDecl = VALUE,
    ---A function.
    FunctionDecl = VALUE,
    ---A C++ function template.
    FunctionTemplate = VALUE,
    ---A GCC inline assembly statement extension.
    GCCAsmStmt = VALUE,
    ---Implements the GNU __null extension, which is a name for a null
    ---pointer constant that has integral type (e.g., int or long) and is the same
    ---size and alignment as a pointer.
    ---
    ---The __null extension is typically only used by system headers, which define
    ---NULL as __null in C++ rather than using 0 (which is an integer that may not
    ---match the size of a pointer).
    GNUNullExpr = VALUE,
    ---Represents a C11 generic selection.
    GenericSelectionExpr = VALUE,
    ---A goto statement.
    GotoStmt = VALUE,
    IBActionAttr = VALUE,
    IBOutletAttr = VALUE,
    IBOutletCollectionAttr = VALUE,
    ---An if statement
    IfStmt = VALUE,
    ---An imaginary number literal.
    ImaginaryLiteral = VALUE,
    InclusionDirective = VALUE,
    ---An indirect goto statement.
    IndirectGotoStmt = VALUE,
    ---Describes an C or C++ initializer list.
    InitListExpr = VALUE,
    ---An integer literal.
    IntegerLiteral = VALUE,
    InvalidCode = VALUE,
    InvalidFile = VALUE,
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
    LabelRef = VALUE,
    ---A labelled statement in a function.
    ---
    ---This cursor kind is used to describe the "start_over:" label statement in
    ---the following example:
    ---
    ---\code
    ---start_over:
    ---++counter;
    ---\endcode
    LabelStmt = VALUE,
    LambdaExpr = VALUE,
    LastAttr = VALUE,
    LastDecl = VALUE,
    LastExpr = VALUE,
    LastExtraDecl = VALUE,
    LastInvalid = VALUE,
    LastPreprocessing = VALUE,
    LastRef = VALUE,
    LastStmt = VALUE,
    ---A linkage specification, e.g. 'extern "C"'.
    LinkageSpec = VALUE,
    ---A MS inline assembly statement extension.
    MSAsmStmt = VALUE,
    MacroDefinition = VALUE,
    MacroExpansion = VALUE,
    MacroInstantiation = VALUE,
    ---A reference to a member of a struct, union, or class that occurs in
    ---some non-expression context, e.g., a designated initializer.
    MemberRef = VALUE,
    ---An expression that refers to a member of a struct, union,
    ---class, Objective-C class, etc.
    MemberRefExpr = VALUE,
    ---A module import declaration.
    ModuleImportDecl = VALUE,
    NSConsumed = VALUE,
    NSConsumesSelf = VALUE,
    NSReturnsAutoreleased = VALUE,
    NSReturnsNotRetained = VALUE,
    NSReturnsRetained = VALUE,
    ---A C++ namespace.
    Namespace = VALUE,
    ---A C++ namespace alias declaration.
    NamespaceAlias = VALUE,
    ---A reference to a namespace or namespace alias.
    NamespaceRef = VALUE,
    NoDeclFound = VALUE,
    NoDuplicateAttr = VALUE,
    ---A C++ non-type template parameter.
    NonTypeTemplateParameter = VALUE,
    NotImplemented = VALUE,
    ---The null statement ";": C99 6.8.3p3.
    ---
    ---This cursor kind is used to describe the null statement.
    NullStmt = VALUE,
    ---OpenMP 5.0 [2.1.4, Array Shaping].
    OMPArrayShapingExpr = VALUE,
    ---OpenMP atomic directive.
    OMPAtomicDirective = VALUE,
    ---OpenMP barrier directive.
    OMPBarrierDirective = VALUE,
    ---OpenMP cancel directive.
    OMPCancelDirective = VALUE,
    ---OpenMP cancellation point directive.
    OMPCancellationPointDirective = VALUE,
    ---OpenMP canonical loop.
    OMPCanonicalLoop = VALUE,
    ---OpenMP critical directive.
    OMPCriticalDirective = VALUE,
    ---OpenMP depobj directive.
    OMPDepobjDirective = VALUE,
    ---OpenMP dispatch directive.
    OMPDispatchDirective = VALUE,
    ---OpenMP distribute directive.
    OMPDistributeDirective = VALUE,
    ---OpenMP distribute parallel for directive.
    OMPDistributeParallelForDirective = VALUE,
    ---OpenMP distribute parallel for simd directive.
    OMPDistributeParallelForSimdDirective = VALUE,
    ---OpenMP distribute simd directive.
    OMPDistributeSimdDirective = VALUE,
    ---OpenMP error directive.
    OMPErrorDirective = VALUE,
    ---OpenMP flush directive.
    OMPFlushDirective = VALUE,
    ---OpenMP for directive.
    OMPForDirective = VALUE,
    ---OpenMP for SIMD directive.
    OMPForSimdDirective = VALUE,
    ---OpenMP loop directive.
    OMPGenericLoopDirective = VALUE,
    ---OpenMP interop directive.
    OMPInteropDirective = VALUE,
    ---OpenMP 5.0 [2.1.6 Iterators]
    OMPIteratorExpr = VALUE,
    ---OpenMP masked directive.
    OMPMaskedDirective = VALUE,
    ---OpenMP masked taskloop directive.
    OMPMaskedTaskLoopDirective = VALUE,
    ---OpenMP masked taskloop simd directive.
    OMPMaskedTaskLoopSimdDirective = VALUE,
    ---OpenMP master directive.
    OMPMasterDirective = VALUE,
    ---OpenMP master taskloop directive.
    OMPMasterTaskLoopDirective = VALUE,
    ---OpenMP master taskloop simd directive.
    OMPMasterTaskLoopSimdDirective = VALUE,
    ---OpenMP metadirective directive.
    OMPMetaDirective = VALUE,
    ---OpenMP ordered directive.
    OMPOrderedDirective = VALUE,
    ---OpenMP parallel directive.
    OMPParallelDirective = VALUE,
    ---OpenMP parallel for directive.
    OMPParallelForDirective = VALUE,
    ---OpenMP parallel for SIMD directive.
    OMPParallelForSimdDirective = VALUE,
    ---OpenMP parallel loop directive.
    OMPParallelGenericLoopDirective = VALUE,
    ---OpenMP parallel masked directive.
    OMPParallelMaskedDirective = VALUE,
    ---OpenMP parallel masked taskloop directive.
    OMPParallelMaskedTaskLoopDirective = VALUE,
    ---OpenMP parallel masked taskloop simd directive.
    OMPParallelMaskedTaskLoopSimdDirective = VALUE,
    ---OpenMP parallel master directive.
    OMPParallelMasterDirective = VALUE,
    ---OpenMP parallel master taskloop directive.
    OMPParallelMasterTaskLoopDirective = VALUE,
    ---OpenMP parallel master taskloop simd directive.
    OMPParallelMasterTaskLoopSimdDirective = VALUE,
    ---OpenMP parallel sections directive.
    OMPParallelSectionsDirective = VALUE,
    ---OpenMP scan directive.
    OMPScanDirective = VALUE,
    ---OpenMP scope directive.
    OMPScopeDirective = VALUE,
    ---OpenMP section directive.
    OMPSectionDirective = VALUE,
    ---OpenMP sections directive.
    OMPSectionsDirective = VALUE,
    ---OpenMP SIMD directive.
    OMPSimdDirective = VALUE,
    ---OpenMP single directive.
    OMPSingleDirective = VALUE,
    ---OpenMP target data directive.
    OMPTargetDataDirective = VALUE,
    ---OpenMP target directive.
    OMPTargetDirective = VALUE,
    ---OpenMP target enter data directive.
    OMPTargetEnterDataDirective = VALUE,
    ---OpenMP target exit data directive.
    OMPTargetExitDataDirective = VALUE,
    ---OpenMP target parallel directive.
    OMPTargetParallelDirective = VALUE,
    ---OpenMP target parallel for directive.
    OMPTargetParallelForDirective = VALUE,
    ---OpenMP target parallel for simd directive.
    OMPTargetParallelForSimdDirective = VALUE,
    ---OpenMP target parallel loop directive.
    OMPTargetParallelGenericLoopDirective = VALUE,
    ---OpenMP target simd directive.
    OMPTargetSimdDirective = VALUE,
    ---OpenMP target teams directive.
    OMPTargetTeamsDirective = VALUE,
    ---OpenMP target teams distribute directive.
    OMPTargetTeamsDistributeDirective = VALUE,
    ---OpenMP target teams distribute parallel for directive.
    OMPTargetTeamsDistributeParallelForDirective = VALUE,
    ---OpenMP target teams distribute parallel for simd directive.
    OMPTargetTeamsDistributeParallelForSimdDirective = VALUE,
    ---OpenMP target teams distribute simd directive.
    OMPTargetTeamsDistributeSimdDirective = VALUE,
    ---OpenMP target teams loop directive.
    OMPTargetTeamsGenericLoopDirective = VALUE,
    ---OpenMP target update directive.
    OMPTargetUpdateDirective = VALUE,
    ---OpenMP task directive.
    OMPTaskDirective = VALUE,
    ---OpenMP taskloop directive.
    OMPTaskLoopDirective = VALUE,
    ---OpenMP taskloop simd directive.
    OMPTaskLoopSimdDirective = VALUE,
    ---OpenMP taskgroup directive.
    OMPTaskgroupDirective = VALUE,
    ---OpenMP taskwait directive.
    OMPTaskwaitDirective = VALUE,
    ---OpenMP taskyield directive.
    OMPTaskyieldDirective = VALUE,
    ---OpenMP teams directive.
    OMPTeamsDirective = VALUE,
    ---OpenMP teams distribute directive.
    OMPTeamsDistributeDirective = VALUE,
    ---OpenMP teams distribute parallel for directive.
    OMPTeamsDistributeParallelForDirective = VALUE,
    ---OpenMP teams distribute parallel for simd directive.
    OMPTeamsDistributeParallelForSimdDirective = VALUE,
    ---OpenMP teams distribute simd directive.
    OMPTeamsDistributeSimdDirective = VALUE,
    ---OpenMP teams loop directive.
    OMPTeamsGenericLoopDirective = VALUE,
    ---OpenMP tile directive.
    OMPTileDirective = VALUE,
    ---OpenMP unroll directive.
    OMPUnrollDirective = VALUE,
    ---Objective-C's \@catch statement.
    ObjCAtCatchStmt = VALUE,
    ---Objective-C's \@finally statement.
    ObjCAtFinallyStmt = VALUE,
    ---Objective-C's \@synchronized statement.
    ObjCAtSynchronizedStmt = VALUE,
    ---Objective-C's \@throw statement.
    ObjCAtThrowStmt = VALUE,
    ---Objective-C's overall \@try-\@catch-\@finally statement.
    ObjCAtTryStmt = VALUE,
    ---Objective-C's autorelease pool statement.
    ObjCAutoreleasePoolStmt = VALUE,
    ---Represents an @available(...) check.
    ObjCAvailabilityCheckExpr = VALUE,
    ---Objective-c Boolean Literal.
    ObjCBoolLiteralExpr = VALUE,
    ObjCBoxable = VALUE,
    ---An Objective-C "bridged" cast expression, which casts between
    ---Objective-C pointers and C pointers, transferring ownership in the process.
    ---
    ---\code
    ---NSString *str = (__bridge_transfer NSString *)CFCreateString();
    ---\endcode
    ObjCBridgedCastExpr = VALUE,
    ---An Objective-C \@interface for a category.
    ObjCCategoryDecl = VALUE,
    ---An Objective-C \@implementation for a category.
    ObjCCategoryImplDecl = VALUE,
    ---An Objective-C class method.
    ObjCClassMethodDecl = VALUE,
    ObjCClassRef = VALUE,
    ObjCDesignatedInitializer = VALUE,
    ---An Objective-C \@dynamic definition.
    ObjCDynamicDecl = VALUE,
    ---An Objective-C \@encode expression.
    ObjCEncodeExpr = VALUE,
    ObjCException = VALUE,
    ObjCExplicitProtocolImpl = VALUE,
    ---Objective-C's collection statement.
    ObjCForCollectionStmt = VALUE,
    ---An Objective-C \@implementation.
    ObjCImplementationDecl = VALUE,
    ObjCIndependentClass = VALUE,
    ---An Objective-C instance method.
    ObjCInstanceMethodDecl = VALUE,
    ---An Objective-C \@interface.
    ObjCInterfaceDecl = VALUE,
    ---An Objective-C instance variable.
    ObjCIvarDecl = VALUE,
    ---An expression that sends a message to an Objective-C
    ---object or class.
    ObjCMessageExpr = VALUE,
    ObjCNSObject = VALUE,
    ObjCPreciseLifetime = VALUE,
    ---An Objective-C \@property declaration.
    ObjCPropertyDecl = VALUE,
    ---An Objective-C \@protocol declaration.
    ObjCProtocolDecl = VALUE,
    ---An Objective-C \@protocol expression.
    ObjCProtocolExpr = VALUE,
    ObjCProtocolRef = VALUE,
    ObjCRequiresSuper = VALUE,
    ObjCReturnsInnerPointer = VALUE,
    ObjCRootClass = VALUE,
    ObjCRuntimeVisible = VALUE,
    ---An Objective-C \@selector expression.
    ObjCSelectorExpr = VALUE,
    ---Represents the "self" expression in an Objective-C method.
    ObjCSelfExpr = VALUE,
    ---An Objective-C string literal i.e. @"foo".
    ObjCStringLiteral = VALUE,
    ObjCSubclassingRestricted = VALUE,
    ObjCSuperClassRef = VALUE,
    ---An Objective-C \@synthesize definition.
    ObjCSynthesizeDecl = VALUE,
    ---OpenACC Compute Construct.
    OpenACCComputeConstruct = VALUE,
    ---OpenACC Loop Construct.
    OpenACCLoopConstruct = VALUE,
    ---A code completion overload candidate.
    OverloadCandidate = VALUE,
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
    OverloadedDeclRef = VALUE,
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
    PackExpansionExpr = VALUE,
    ---Represents a C++26 pack indexing expression.
    PackIndexingExpr = VALUE,
    PackedAttr = VALUE,
    ---A parenthesized expression, e.g. "(1)".
    ---
    ---This AST node is only formed if full location information is requested.
    ParenExpr = VALUE,
    ---A function or method parameter.
    ParmDecl = VALUE,
    PreprocessingDirective = VALUE,
    PureAttr = VALUE,
    ---Expression that references a C++20 requires expression.
    RequiresExpr = VALUE,
    ---A return statement.
    ReturnStmt = VALUE,
    ---Windows Structured Exception Handling's except statement.
    SEHExceptStmt = VALUE,
    ---Windows Structured Exception Handling's finally statement.
    SEHFinallyStmt = VALUE,
    ---Windows Structured Exception Handling's leave statement.
    SEHLeaveStmt = VALUE,
    ---Windows Structured Exception Handling's try statement.
    SEHTryStmt = VALUE,
    ---Represents an expression that computes the length of a parameter
    ---pack.
    ---
    ---\code
    ---template<typename ...Types>
    ---struct count {
    ---static const unsigned value = sizeof...(Types);
    ---};
    ---\endcode
    SizeOfPackExpr = VALUE,
    ---A static_assert or _Static_assert node
    StaticAssert = VALUE,
    ---This is the GNU Statement Expression extension: ({int X=4; X;})
    StmtExpr = VALUE,
    ---A string literal.
    StringLiteral = VALUE,
    ---A C or C++ struct.
    StructDecl = VALUE,
    ---A switch statement.
    SwitchStmt = VALUE,
    ---A reference to a class template, function template, template
    ---template parameter, or class template partial specialization.
    TemplateRef = VALUE,
    ---A C++ template template parameter.
    TemplateTemplateParameter = VALUE,
    ---A C++ template type parameter.
    TemplateTypeParameter = VALUE,
    ---Cursor that represents the translation unit itself.
    ---
    ---The translation unit cursor exists primarily to act as the root
    ---cursor for traversing the contents of a translation unit.
    TranslationUnit = VALUE,
    ---A C++ alias declaration
    TypeAliasDecl = VALUE,
    TypeAliasTemplateDecl = VALUE,
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
    TypeRef = VALUE,
    ---A typedef.
    TypedefDecl = VALUE,
    ---A unary expression. (noexcept, sizeof, or other traits)
    UnaryExpr = VALUE,
    ---This represents the unary-expression's (except sizeof and
    ---alignof).
    UnaryOperator = VALUE,
    ---An attribute whose specific kind is not exposed via this
    ---interface.
    UnexposedAttr = VALUE,
    ---A declaration whose specific kind is not exposed via this
    ---interface.
    ---
    ---Unexposed declarations have the same operations as any other kind
    ---of declaration; one can extract their location information,
    ---spelling, find their definitions, etc. However, the specific kind
    ---of the declaration is not reported.
    UnexposedDecl = VALUE,
    ---An expression whose specific kind is not exposed via this
    ---interface.
    ---
    ---Unexposed expressions have the same operations as any other kind
    ---of expression; one can extract their location information,
    ---spelling, children, etc. However, the specific kind of the
    ---expression is not reported.
    UnexposedExpr = VALUE,
    ---A statement whose specific kind is not exposed via this
    ---interface.
    ---
    ---Unexposed statements have the same operations as any other kind of
    ---statement; one can extract their location information, spelling,
    ---children, etc. However, the specific kind of the statement is not
    ---reported.
    UnexposedStmt = VALUE,
    ---A C or C++ union.
    UnionDecl = VALUE,
    ---A C++ using declaration.
    UsingDeclaration = VALUE,
    ---A C++ using directive.
    UsingDirective = VALUE,
    ---A variable.
    VarDecl = VALUE,
    ---A reference to a variable that occurs in some non-expression
    ---context, e.g., a C++ lambda capture list.
    VariableRef = VALUE,
    VisibilityAttr = VALUE,
    WarnUnusedAttr = VALUE,
    WarnUnusedResultAttr = VALUE,
    ---A while statement.
    WhileStmt = VALUE,
}

return CursorKind