---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.TranslationUnitFlags

---@type clang.TranslationUnitFlags
local VALUE

---
---@enum clang.TranslationUnitFlags
---@operator call(integer): clang.TranslationUnitFlags
local TranslationUnitFlags = {
    ---DEPRECATED: Enabled chained precompiled preambles in C++.
    ---
    ---Note: this is a *temporary* option that is available only while
    ---we are testing C++ precompiled preamble support. It is deprecated.
    CXXChainedPCH = 32,
    ---Used to indicate that the translation unit should cache some
    ---code-completion results with each reparse of the source file.
    ---
    ---Caching of code-completion results is a performance optimization that
    ---introduces some overhead to reparsing but improves the performance of
    ---code-completion operations.
    CacheCompletionResults = 8,
    ---Used to indicate that the precompiled preamble should be created on
    ---the first parse. Otherwise it will be created on the first reparse. This
    ---trades runtime on the first parse (serializing the preamble takes time) for
    ---reduced runtime on the second parse (can now reuse the preamble).
    CreatePreambleOnFirstParse = 256,
    ---Used to indicate that the parser should construct a "detailed"
    ---preprocessing record, including all macro definitions and instantiations.
    ---
    ---Constructing a detailed preprocessing record requires more memory
    ---and time to parse, since the information contained in the record
    ---is usually not retained. However, it can be useful for
    ---applications that require more detailed information about the
    ---behavior of the preprocessor.
    DetailedPreprocessingRecord = 1,
    ---Used to indicate that the translation unit will be serialized with
    ---`clang_saveTranslationUnit`.
    ---
    ---This option is typically used when parsing a header with the intent of
    ---producing a precompiled header.
    ForSerialization = 16,
    ---Used to indicate that non-errors from included files should be ignored.
    ---
    ---If set, clang_getDiagnosticSetFromTU() will not report e.g. warnings from
    ---included files anymore. This speeds up clang_getDiagnosticSetFromTU() for
    ---the case where these warnings are not of interest, as for an IDE for
    ---example, which typically shows only the diagnostics in the main file.
    IgnoreNonErrorsFromIncludedFiles = 16384,
    ---Used to indicate that attributed types should be included in CXType.
    IncludeAttributedTypes = 4096,
    ---Used to indicate that brief documentation comments should be
    ---included into the set of code completions returned from this translation
    ---unit.
    IncludeBriefCommentsInCodeCompletion = 128,
    ---Used to indicate that the translation unit is incomplete.
    ---
    ---When a translation unit is considered "incomplete", semantic
    ---analysis that is typically performed at the end of the
    ---translation unit will be suppressed. For example, this suppresses
    ---the completion of tentative declarations in C and of
    ---instantiation of implicitly-instantiation function templates in
    ---C++. This option is typically used when parsing a header with the
    ---intent of producing a precompiled header.
    Incomplete = 2,
    ---Do not stop processing when fatal errors are encountered.
    ---
    ---When fatal errors are encountered while parsing a translation unit,
    ---semantic analysis is typically stopped early when compiling code. A common
    ---source for fatal errors are unresolvable include files. For the
    ---purposes of an IDE, this is undesirable behavior and as much information
    ---as possible should be reported. Use this flag to enable this behavior.
    KeepGoing = 512,
    ---Used in combination with CXTranslationUnit_SkipFunctionBodies to
    ---constrain the skipping of function bodies to the preamble.
    ---
    ---The function bodies of the main file are not skipped.
    LimitSkipFunctionBodiesToPreamble = 2048,
    ---Used to indicate that no special translation-unit options are
    ---needed.
    None = 0,
    ---Used to indicate that the translation unit should be built with an
    ---implicit precompiled header for the preamble.
    ---
    ---An implicit precompiled header is used as an optimization when a
    ---particular translation unit is likely to be reparsed many times
    ---when the sources aren't changing that often. In this case, an
    ---implicit precompiled header will be built containing all of the
    ---initial includes at the top of the main file (what we refer to as
    ---the "preamble" of the file). In subsequent parses, if the
    ---preamble or the files in it have not changed, \c
    ---clang_reparseTranslationUnit() will re-use the implicit
    ---precompiled header to improve parsing performance.
    PrecompiledPreamble = 4,
    ---Tells the preprocessor not to skip excluded conditional blocks.
    RetainExcludedConditionalBlocks = 32768,
    ---Sets the preprocessor in a mode for parsing a single file only.
    SingleFileParse = 1024,
    ---Used to indicate that function/method bodies should be skipped while
    ---parsing.
    ---
    ---This option can be used to search for declarations/definitions while
    ---ignoring the usages.
    SkipFunctionBodies = 64,
    ---Used to indicate that implicit attributes should be visited.
    VisitImplicitAttributes = 8192,
}

---@param v integer
---@return clang.TranslationUnitFlags
function TranslationUnitFlags:__call(v) end

return TranslationUnitFlags