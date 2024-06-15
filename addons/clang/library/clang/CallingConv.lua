---@meta clang.CallingConv

---@type clang.CallingConv
local VALUE

---@enum clang.CallingConv
local CallingConv = {
    AAPCS = VALUE,
    AAPCS_VFP = VALUE,
    AArch64SVEPCS = VALUE,
    AArch64VectorCall = VALUE,
    C = VALUE,
    Default = VALUE,
    IntelOclBicc = VALUE,
    Invalid = VALUE,
    M68kRTD = VALUE,
    PreserveAll = VALUE,
    PreserveMost = VALUE,
    PreserveNone = VALUE,
    RISCVVectorCall = VALUE,
    Swift = VALUE,
    SwiftAsync = VALUE,
    Unexposed = VALUE,
    Win64 = VALUE,
    X86FastCall = VALUE,
    X86Pascal = VALUE,
    X86RegCall = VALUE,
    X86StdCall = VALUE,
    X86ThisCall = VALUE,
    X86VectorCall = VALUE,
    X86_64SysV = VALUE,
    X86_64Win64 = VALUE,
}

return CallingConv