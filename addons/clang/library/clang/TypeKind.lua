---@meta clang.TypeKind

---@type clang.TypeKind
local VALUE

---
---@enum clang.TypeKind
local TypeKind = {
    Accum = 34,
    Atomic = 177,
    Attributed = 163,
    Auto = 118,
    BFloat16 = 39,
    BTFTagAttributed = 178,
    BlockPointer = 102,
    Bool = 3,
    Char16 = 6,
    Char32 = 7,
    Char_S = 13,
    Char_U = 4,
    Complex = 100,
    ConstantArray = 112,
    Dependent = 26,
    DependentSizedArray = 116,
    Double = 22,
    ---Represents a type that was referred to using an elaborated type keyword.
    ---
    ---E.g., struct S, or via a qualified name, e.g., N::M::type, or both.
    Elaborated = 119,
    Enum = 106,
    ExtVector = 176,
    FirstBuiltin = 2,
    Float = 21,
    Float128 = 30,
    Float16 = 32,
    FunctionNoProto = 110,
    FunctionProto = 111,
    Half = 31,
    Ibm128 = 40,
    IncompleteArray = 114,
    Int = 17,
    Int128 = 20,
    ---Represents an invalid type (e.g., where no type is available).
    Invalid = 0,
    LValueReference = 103,
    LastBuiltin = 40,
    Long = 18,
    LongAccum = 35,
    LongDouble = 23,
    LongLong = 19,
    MemberPointer = 117,
    NullPtr = 24,
    OCLEvent = 158,
    OCLImage1dArrayRO = 122,
    OCLImage1dArrayRW = 146,
    OCLImage1dArrayWO = 134,
    OCLImage1dBufferRO = 123,
    OCLImage1dBufferRW = 147,
    OCLImage1dBufferWO = 135,
    OCLImage1dRO = 121,
    OCLImage1dRW = 145,
    OCLImage1dWO = 133,
    OCLImage2dArrayDepthRO = 127,
    OCLImage2dArrayDepthRW = 151,
    OCLImage2dArrayDepthWO = 139,
    OCLImage2dArrayMSAADepthRO = 131,
    OCLImage2dArrayMSAADepthRW = 155,
    OCLImage2dArrayMSAADepthWO = 143,
    OCLImage2dArrayMSAARO = 129,
    OCLImage2dArrayMSAARW = 153,
    OCLImage2dArrayMSAAWO = 141,
    OCLImage2dArrayRO = 125,
    OCLImage2dArrayRW = 149,
    OCLImage2dArrayWO = 137,
    OCLImage2dDepthRO = 126,
    OCLImage2dDepthRW = 150,
    OCLImage2dDepthWO = 138,
    OCLImage2dMSAADepthRO = 130,
    OCLImage2dMSAADepthRW = 154,
    OCLImage2dMSAADepthWO = 142,
    OCLImage2dMSAARO = 128,
    OCLImage2dMSAARW = 152,
    OCLImage2dMSAAWO = 140,
    OCLImage2dRO = 124,
    OCLImage2dRW = 148,
    OCLImage2dWO = 136,
    OCLImage3dRO = 132,
    OCLImage3dRW = 156,
    OCLImage3dWO = 144,
    OCLIntelSubgroupAVCImeDualRefStreamin = 175,
    OCLIntelSubgroupAVCImeDualReferenceStreamin = 175,
    OCLIntelSubgroupAVCImePayload = 165,
    OCLIntelSubgroupAVCImeResult = 169,
    OCLIntelSubgroupAVCImeResultDualRefStreamout = 173,
    OCLIntelSubgroupAVCImeResultDualReferenceStreamout = 173,
    OCLIntelSubgroupAVCImeResultSingleRefStreamout = 172,
    OCLIntelSubgroupAVCImeResultSingleReferenceStreamout = 172,
    OCLIntelSubgroupAVCImeSingleRefStreamin = 174,
    OCLIntelSubgroupAVCImeSingleReferenceStreamin = 174,
    OCLIntelSubgroupAVCMcePayload = 164,
    OCLIntelSubgroupAVCMceResult = 168,
    OCLIntelSubgroupAVCRefPayload = 166,
    OCLIntelSubgroupAVCRefResult = 170,
    OCLIntelSubgroupAVCSicPayload = 167,
    OCLIntelSubgroupAVCSicResult = 171,
    OCLQueue = 159,
    OCLReserveID = 160,
    OCLSampler = 157,
    ObjCClass = 28,
    ObjCId = 27,
    ObjCInterface = 108,
    ObjCObject = 161,
    ObjCObjectPointer = 109,
    ObjCSel = 29,
    ObjCTypeParam = 162,
    Overload = 25,
    Pipe = 120,
    Pointer = 101,
    RValueReference = 104,
    Record = 105,
    SChar = 14,
    Short = 16,
    ShortAccum = 33,
    Typedef = 107,
    UAccum = 37,
    UChar = 5,
    UInt = 9,
    UInt128 = 12,
    ULong = 10,
    ULongAccum = 38,
    ULongLong = 11,
    UShort = 8,
    UShortAccum = 36,
    ---A type whose specific kind is not exposed via this
    ---interface.
    Unexposed = 1,
    VariableArray = 115,
    Vector = 113,
    Void = 2,
    WChar = 15,
}

return TypeKind