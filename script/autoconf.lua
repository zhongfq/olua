local idl = require "script.idl"
local clang = require "clang"
local TypeKind = require "clang.TypeKind"
local CursorKind = require "clang.CursorKind"
local CXXAccessSpecifier = require "clang.CXXAccessSpecifier"
local DiagnosticSeverity = require "clang.DiagnosticSeverity"

local keywords = {
    ["and"] = "and_",
    ["do"] = "do_",
    ["end"] = "end_",
    ["function"] = "function_",
    ["in"] = "in_",
    ["local"] = "local_",
    ["not"] = "not_",
    ["or"] = "or_",
    ["repeat"] = "repeat_",
    ["then"] = "then_",
    ["until"] = "until_",
}

if not olua.isdir("autobuild") then
    olua.mkdir("autobuild")
end

olua.print("lua clang: v${clang.version}")

-- Auto export after config.
olua.AUTO_BUILD = true

-- Print more debug info.
olua.VERBOSE = false

-- Auto generate property.
olua.AUTO_GEN_PROP = true

-- Enable auto export parent.
olua.AUTO_EXPORT_PARENT = false

-- Enable export deprecated function.
olua.ENABLE_DEPRECATED = false

-- Enable var or method name with underscore.
olua.ENABLE_WITH_UNDERSCORE = false

-- Max args for variadic method, this will generate overload method.
olua.MAX_VARIADIC_ARGS = 16

-- Enable cxx exception
olua.ENABLE_EXCEPTION = false

--Capture main thread 'L' in callback.
olua.CAPTURE_MAINTHREAD = false

--Parse all comments, include '//' and '/*'.
olua.PARSE_ALL_COMMENTS = false


local clang_tu

local type_cursors     = olua.ordered_map(false)
local operator_cursors = olua.ordered_map(false)
local iterator_cursors = olua.ordered_map(true)
local comment_cursors  = olua.ordered_map(false)
local visited_types    = olua.ordered_map(false)
local alias_types      = olua.ordered_map(false)
local type_checker     = olua.array()
local type_packvars    = olua.ordered_map()


local metamethod = {
    __index = true,
    __newindex = true,
    __gc = true,
    __pairs = true,
    __len = true,
    __eq = true,
    __tostring = true,
    __add = true,
    __sub = true,
    __mul = true,
    __mod = true,
    __pow = true,
    __div = true,
    __idiv = true,
    __band = true,
    __bor = true,
    __bxor = true,
    __shl = true,
    __shr = true,
    __unm = true,
    __bnot = true,
    __lt = true,
    __le = true,
    __concat = true,
    __call = true,
    __close = true
}

local operator   = {
    ["operator+"] = "__add",
    ["operator-"] = "__sub",
    ["operator*"] = "__mul",
    ["operator/"] = "__div",
    ["operator%"] = "__mod",
    ["operator=="] = "__eq",
    ["operator<"] = "__lt",
    ["operator<="] = "__le",
    ["operator<<"] = "__shl",
    ["operator>>"] = "__shr",
    ["operator&"] = "__band",
    ["operator|"] = "__bor",
    ["operator^"] = "__bxor",
    ["operator<=>"] = "__cmp",
}


local kFLAG_POINTER  = 1 << 1 -- pointer type
local kFLAG_ENUM     = 1 << 2 -- enum type
local kFLAG_ALIAS    = 1 << 3 -- alias type
local kFLAG_FUNC     = 1 << 4 -- function type
local kFLAG_TEMPLATE = 1 << 5 -- template type
local kFLAG_SKIP     = 1 << 6 -- don't export

local KEEP_CONST     = 1 << 1
local KEEP_TEMPLATE  = 1 << 2
local KEEP_POINTER   = 1 << 3

---@param flag integer
---@param k integer
---@return boolean
local function has_flag(flag, k)
    return (flag & k) ~= 0
end

---@param cls idl.model.class_desc
---@param kind integer
---@return boolean
local function has_type_flag(cls, kind)
    return has_flag(cls.conf.kind or 0, kind)
end

---@param cxxcls string
---@param flag? integer
---@return string
local function raw_typename(cxxcls, flag)
    if cxxcls == "" then
        return ""
    else
        flag = flag or 0
        if not has_flag(flag, KEEP_CONST) then
            cxxcls = cxxcls:gsub("^const ", "")
        end
        if not has_flag(flag, KEEP_TEMPLATE) then
            cxxcls = cxxcls:gsub("<.*>", "")
        end
        if not has_flag(flag, KEEP_POINTER) then
            cxxcls = cxxcls:gsub("[ &*]+$", "")
        else
            cxxcls = cxxcls:gsub("[ &]+$", "")
        end
        return olua.pretty_typename(cxxcls)
    end
end

---@param tn string
---@return string
local function trim_prefix_colon(tn)
    if tn:find(" ::") then
        tn = tn:gsub(" ::", " ")
    end
    if tn:find("^::") then
        tn = tn:gsub("^::", "")
    end
    return tn
end

---@param type clang.Type | {declaration: clang.Cursor, name: string}
---@return string
local function parse_from_ast(type)
    local cur = type.declaration
    if cur.kind == CursorKind.NoDeclFound then
        return trim_prefix_colon(type.name)
    end

    local exps = olua.array("::")
    local fullexps = olua.array("::")
    while cur and cur.kind ~= CursorKind.TranslationUnit do
        local value = raw_typename(cur.name)
        if cur:isInlineNamespace() then
            cur = cur.parent
            fullexps:unshift(value)
        elseif value then
            exps:unshift(value)
            fullexps:unshift(value)
            cur = cur.parent
        else
            break
        end
    end
    return trim_prefix_colon(tostring(exps)), trim_prefix_colon(tostring(fullexps))
end

---@param cur clang.Cursor
local function is_private_member(cur)
    local access = cur.cxxAccessSpecifier
    return access == CXXAccessSpecifier.Private or access == CXXAccessSpecifier.Protected
end

local typename

---@param type clang.Type
---@param template_types? olua.ordered_map
---@param try_underlying? boolean
---@param level? integer
---@param from? string
---@return string
local function parse_from_type(type, template_types, try_underlying, level, from)
    local kind = type.kind
    local tn = trim_prefix_colon(type.name)
    local template_arg_types = type.templateArgumentTypes
    local underlying = type.declaration.typedefDeclUnderlyingType
    local pointee = type.pointeeType
    if level and level > 4 then
        return tn
    elseif type:isConstQualified() then
        pointee = type.unqualifiedType
        return "const " .. parse_from_type(pointee, template_types, try_underlying, level, from)
    elseif #template_arg_types > 0 and (not try_underlying or not underlying) then
        local exps = olua.array("")
        local astname = parse_from_ast(type)
        exps:push(astname)
        if olua.is_templdate_type(tn) then
            level = (level or 0) + 1
            exps:push("<")
            for i, v in ipairs(template_arg_types) do
                exps:push(i > 1 and ", " or nil)
                exps:push(typename(v, template_types, level, from))
            end
            exps:push(">")
        end
        tn = tostring(exps)
        return template_types and template_types:get(tn) or tn
    elseif kind == TypeKind.LValueReference then
        return parse_from_type(pointee, template_types, try_underlying, level) .. " &"
    elseif kind == TypeKind.RValueReference then
        return parse_from_type(pointee, template_types, try_underlying, level) .. " &&"
    elseif kind == TypeKind.Pointer and pointee.kind == TypeKind.Pointer then
        return parse_from_type(pointee, template_types, try_underlying, level) .. "*"
    elseif kind == TypeKind.Pointer then
        return parse_from_type(pointee, template_types, try_underlying, level) .. " *"
    elseif kind == TypeKind.FunctionProto then
        local exps = olua.array("")
        local result_type = typename(type.resultType, template_types, level, from)
        exps:push(result_type)
        exps:push(result_type:find("[*&]") and "" or " ")
        exps:push("(")
        for i, v in ipairs(type.argTypes) do
            exps:push(i > 1 and ", " or nil)
            exps:push(typename(v, template_types, level, from))
        end
        exps:push(")")
        return tostring(exps)
    elseif try_underlying and underlying then
        return parse_from_type(underlying, template_types, false, level)
    elseif template_types and template_types:has(tn) then
        return template_types:get(tn)
    elseif underlying and is_private_member(type.declaration) then
        return typename(underlying, template_types, nil, from)
    elseif kind >= TypeKind.FirstBuiltin and kind <= TypeKind.LastBuiltin then
        return tn
    elseif kind == TypeKind.Typedef or kind == TypeKind.Unexposed then
        return tn
    else
        --[[
            #1
                   tn: size_t
                rawrn: size_t
                  ast: size_t

            #2
                   tn: std::string::size_type
                rawrn: std::string::size_type
                  ast: std::basic_string::size_type

            #3
                   tn: enum EventType
                rawrn: EventType
                  ast: olua::test::EventType

            #4
                   tn: std::__ndk1::__fs::filesystem::path
                  ast: std::filesystem::path
              fullast: std::__ndk1::__fs::filesystem::path

            #5
                   tn: underlying_type<launch>::type
                rawtn: underlying_type<launch>::type
                  ast: std::__underlying_type_impl::type
        ]]

        local astname, fullastname = parse_from_ast(type)
        local type_modifier = tn:match("^struct ") or tn:match("^enum ") or tn:match("^union ")
        local rawtn
        if type_modifier then
            rawtn = tn:sub(#type_modifier + 1)
        else
            rawtn = tn
            type_modifier = ""
        end

        if tn == fullastname or              -- #4
            tn == astname or                 -- #1
            olua.is_end_with(astname, rawtn) -- #3
        then
            return type_modifier .. astname
        else
            -- #2 #5
            return tn
        end
    end
end

---@param tn string
---@param underlying string
---@return string
---@return boolean
local function check_alias_typename(tn, underlying)
    -- try pointer version
    local rawptn = raw_typename(tn, KEEP_POINTER)
    local rawp_underlying = raw_typename(underlying, KEEP_POINTER)
    if rawptn == rawp_underlying then
        return tn, false
    elseif idl.type_convs:has(rawp_underlying) then
        alias_types:replace(rawptn, rawp_underlying)
        return tn, true
    end

    if rawptn:find("%*$") then
        local rawtn = raw_typename(tn)
        local raw_underlying = raw_typename(underlying)
        if idl.type_convs:has(raw_underlying) then
            alias_types:replace(rawtn, raw_underlying)
            return tn, true
        end
    end

    local has_ti = olua.typeinfo(rawp_underlying, nil, false)
    if has_ti and not olua.is_templdate_type(underlying) then
        if underlying:find("^const ") then
            --[[
                typedef char GLchar;
                void set(const GLchar *);
                        tn: const GLchar *
                underlying: const char *

                basictype.lua has register 'const char *' and 'char *'
            ]]
            local const_raw_underlying = raw_typename(underlying, KEEP_POINTER | KEEP_CONST)
            local ti = olua.typeinfo(const_raw_underlying, nil, false)
            if not olua.has_const_flag(ti) then
                local const_rawtn = raw_typename(tn, KEEP_POINTER | KEEP_CONST)
                alias_types:replace(const_rawtn, const_raw_underlying)
            end
        end
        alias_types:replace(rawptn, rawp_underlying)
        return tn, true
    elseif has_ti then
        return underlying, true
    else
        return tn, false
    end
end

---@param type clang.Type
---@return clang.Type
local function get_pointee_type(type)
    local kind = type.kind
    if kind == TypeKind.LValueReference
        or kind == TypeKind.RValueReference
        or kind == TypeKind.Pointer
    then
        return get_pointee_type(type.pointeeType)
    else
        return type
    end
end

---@param type clang.Type
---@param template_types? olua.ordered_map
---@param level? integer
---@param from? string
---@return string
function typename(type, template_types, level, from)
    --[[
            tn: const uint32_t *
         rawtn: uint32_t
        rawptn: uint32_t *
    ]]

    local tn = parse_from_type(type, template_types, false, level, from)
    local rawtn = raw_typename(tn)
    local rawptn = raw_typename(tn, KEEP_POINTER)

    if idl.exclude_types:has(rawptn) then
        return tn
    end

    if not idl.type_convs:has(rawtn)
        and not idl.type_convs:has(rawptn)
        and not olua.typeinfo(rawptn, nil, false)
    then
        --[[
            typedef std::function<void()> ClickEvent;
              -- type: ClickEvent
              -- underlying: std::function<void()>

            typedef long __darwin_time_t
            typedef __darwin_time_t time_t
              -- type: time_t
              -- underlying: __darwin_time_t
              -- canonical: long
        ]]

        -- try underlying_type
        local valid
        local alias = parse_from_type(type, template_types, true, level, from)
        tn, valid = check_alias_typename(tn, alias)
        if not valid then
            alias = trim_prefix_colon(type.canonicalType.name)
            tn = check_alias_typename(tn, alias)
        end
    end

    if from and type.kind ~= TypeKind.FunctionProto then
        type_checker:push({
            type = tn,
            from = from,
            kind = get_pointee_type(type).declaration.kindSpelling
        })
    end

    return tn
end

---@param name string
---@return boolean
local function is_excluded_typename(name)
    local rawptn = raw_typename(name, KEEP_POINTER):match("[^ ]+ *%**$")
    return idl.exclude_types:has(rawptn) or name:find("%*%*$") ~= nil
end

---@param type clang.Type
---@return boolean
local function is_excluded_type(type)
    if type.kind == TypeKind.IncompleteArray then
        return true
    end

    local tn = typename(type)
    if olua.is_templdate_type(tn) then
        for _, subtype in ipairs(get_pointee_type(type).templateArgumentTypes) do
            if is_excluded_type(subtype) then
                return true
            end
        end
    end
    return is_excluded_typename(tn)
end

local DEFAULT_ARG_TYPES = {
    [CursorKind.IntegerLiteral] = true,
    [CursorKind.FloatingLiteral] = true,
    [CursorKind.ImaginaryLiteral] = true,
    [CursorKind.StringLiteral] = true,
    [CursorKind.CharacterLiteral] = true,
    [CursorKind.CXXBoolLiteralExpr] = true,
    [CursorKind.CXXNullPtrLiteralExpr] = true,
    [CursorKind.GNUNullExpr] = true,
    [CursorKind.DeclRefExpr] = true,
    [CursorKind.CallExpr] = true,
}

---@param cur clang.Cursor
---@return boolean
local function has_default_value(cur)
    for _, c in ipairs(cur.children) do
        if DEFAULT_ARG_TYPES[c.kind] then
            return true
        elseif has_default_value(c) then
            return true
        end
    end
    return false
end

---@param cur clang.Cursor
---@return boolean
local function has_deprecated_attr(cur)
    if olua.ENABLE_DEPRECATED then
        return false
    end
    return cur:isDeprecated()
end

---@param cur clang.Cursor
---@return boolean
local function has_exclude_attr(cur)
    for _, c in ipairs(cur.children) do
        if c.kind == CursorKind.AnnotateAttr and c.name:find("@exclude") then
            return true
        end
    end
    return false
end

---@param tn string|clang.Type
---@return boolean
local function is_func_type(tn)
    if type(tn) == "string" then
        return tn:find("std::function") ~= nil
    else
        local kind = tn.kind
        local cur = tn.declaration
        if kind == TypeKind.LValueReference
            or kind == TypeKind.RValueReference
            or kind == TypeKind.Pointer
        then
            return is_func_type(tn.pointeeType)
        elseif cur.kind == CursorKind.TypedefDecl
            or cur.kind == CursorKind.TypeAliasDecl
        then
            return is_func_type(cur.typedefDeclUnderlyingType)
        else
            return is_func_type(typename(cur.typedefDeclUnderlyingType or tn))
        end
    end
end

---@param cur clang.Cursor
local function is_static_func(cur)
    return cur:isCXXStaticMethod()
        or cur.kind == CursorKind.FunctionDecl
        or cur.kind == CursorKind.Constructor
end

---@param cls idl.model.class_desc
---@param cur clang.Cursor
---@param display_name string
---@param isvar? boolean
local function parse_attr_from_annotate(cls, cur, display_name, isvar)
    local fn = cur.name
    ---@type idl.conf.member_desc
    local member = cls.conf.members:get(display_name) or cls.conf.members:get(fn)

    if not member then
        local maincls = cls.conf.maincls
        if maincls then
            member = maincls.conf.members:get(display_name) or maincls.conf.members:get(fn)
        end
    end

    if not member then
        if isvar then
            cls.CMD.var(display_name)
        else
            cls.CMD.func(display_name)
        end
        member = cls.conf.members:get(display_name)
    end

    if not cls.conf.members:has(display_name) then
        cls.conf.members:set(display_name, member)
    end

    local attrs = member.attrs:clone()

    ---@param node clang.Cursor
    ---@param key string
    local function parse_and_merge_attr(node, key)
        local arr = attrs:get(key) ---@type olua.array
        for _, c in ipairs(node.children) do
            if c.kind == CursorKind.AnnotateAttr then
                local name = c.name
                if name:find("^@") then
                    arr:push(name)
                end
            end
        end
    end

    parse_and_merge_attr(cur, isvar and "var" or "ret")
    if isvar then
        attrs:set("ret", olua.clone(attrs:get("var") or olua.array()))
        attrs:set("arg1", olua.clone(attrs:get("var") or olua.array()))
    else
        for i, arg in ipairs(cur.arguments) do
            parse_and_merge_attr(arg, "arg" .. i)
        end
    end

    return attrs
end

---@param cls idl.model.class_desc
---@param cur clang.Cursor
---@return boolean
local function is_excluded_memeber(cls, cur)
    local mode = cls.conf.includes:size() > 0 and "include" or "exclude"
    local name = cur.name

    if not olua.ENABLE_WITH_UNDERSCORE
        and name:find("^_")
        and not metamethod[name]
    then
        return true
    end

    if (mode == "include" and not cls.conf.includes:has(name))
        or cls.conf.excludes:has("*")
        or cls.conf.excludes:has(name)
        or cls.conf.excludes:has(cur.displayName)
    then
        return true
    end

    for wc in pairs(cls.conf.wildcards) do
        if name:find(wc) then
            return true
        end
    end

    return false
end

---@param cur clang.Cursor
local function get_comment(cur)
    local comment = cur.rawCommentText
    if comment then
        local see = comment:match("@oluasee +([%w$_:]+)")
        if see then
            local see_cursor = comment_cursors:get(see)
            if see_cursor then
                local see_comment = see_cursor.rawCommentText
                if see_comment then
                    comment = see_comment
                end
            else
                print(olua.format("[WARNING]: @oluasee ${see} not found"))
            end
        end
        return olua.process_comment(comment)
    end
end

---@param cls idl.model.class_desc
---@param cur clang.Cursor
---@return boolean
local function check_included_method(cls, cur)
    local types = olua.array()
    for _, arg in ipairs(cur.arguments) do
        types:push(arg.type)
    end
    types:push(cur.resultType)
    local fn = cur.name
    for _, t in ipairs(types) do
        if is_excluded_type(t) then
            if cls.conf.includes:has(fn) then
                print(olua.format([=[
                    [WARNING]: function '${fn}' included in class '${cls.cxxcls}' will be ignored
                                   because '${c.type.name}' has been excluded
                ]=], 1))
            end
            return false
        end
    end
    return true
end

---@param cls idl.model.class_desc
---@param func idl.model.func_desc
---@return string
local function gen_display_name(cls, func)
    local exps = olua.array("")
    exps:push(func.cxxfn)
    exps:push("(")
    for i, v in ipairs(func.args) do
        exps:push(i > 1 and ", " or nil)
        exps:push(olua.decltype(v.type))
    end
    exps:push(")")
    return tostring(exps)
end

---@param cls idl.model.class_desc
---@param func idl.model.func_desc
---@return string
local function gen_prototype(cls, func)
    -- generate function prototype: void func(int, A *, B *)
    local exps = olua.array("")
    exps:push(func.is_static and "static " or nil)
    exps:push(olua.decltype(func.ret.type, nil, true))
    exps:push(gen_display_name(cls, func))
    return tostring(exps)
end

---@class Autoconf : idl.model.module_desc
local Autoconf = {}

function Autoconf:parse()
    assert(not self.class_file)
    self.filename = self.path:match("([^/\\]+).lua$") ---@type string
    self.class_file = olua.format("autobuild/${self.filename}.idl")

    -- scan method, variable, enum, const value
    for _, cls in ipairs(self.class_types:values()) do
        ---@cast cls idl.model.class_desc
        local cur = type_cursors:get(cls.cxxcls) ---@type clang.Cursor
        if cur then
            self:visit(cur, cls.cxxcls)
        elseif cls.cxxcls:find("<") then
            local tempcls, arg_cls = cls.cxxcls:match("^(.+)<(.+)>$")
            cur = type_cursors:get(tempcls) ---@type clang.Cursor
            if cur then
                if cls.conf.iterator.name then
                    iterator_cursors:set(cls.conf.iterator.name, {
                        name = cls.conf.iterator.name,
                        kind = CursorKind.CXXMethod,
                    })
                end
                self:visit_class(cls.cxxcls, cur, { arg_cls })
            end
        end
    end
end

---@param cls idl.model.class_desc
---@param cur clang.Cursor
---@param template_types olua.ordered_map
---@return idl.model.func_desc
---@return {ret: clang.Type, args: clang.Cursor[]}
local function parse_func(cls, cur, template_types)
    local typefrom = olua.format("class: ${cls.cxxcls} -> ${cur.prettyPrinted}")
    local fn = cur.name
    local op = operator[fn]
    fn = op or fn
    ---@type idl.model.func_desc
    local func = {
        cxxfn = fn,
        luafn = fn,
        is_exposed = true,
        comment = get_comment(cur),
        is_static = is_static_func(cur) and true or nil,
        is_contructor = cur.kind == CursorKind.Constructor and true or nil,
        ret = {
            type = typename(cur.resultType, template_types, nil, typefrom),
            attr = olua.array()
        },
        args = olua.array(),
    }

    local func_def = {
        ret = cur.resultType,
        args = {},
    }

    setmetatable(func, { __olua_ignore = { display_name = true } })

    for _, c in ipairs(cur.children) do
        if c.kind == CursorKind.ParmDecl and c.parent == cur then
            local i = #func.args + 1
            local name = c.name:gsub("^__", "")
            name = keywords[name] or name
            func.args:push({
                type = typename(c.type, template_types, nil, typefrom),
                name = name ~= "" and name or ("arg" .. i),
                attr = olua.array()
            })
            func_def.args[i] = c
        end
    end

    if op then
        func.ret.attr:pushf("@operator(${cur.name})")
        if cur.name == "operator-" then
            if #func.args == 0 then
                func.cxxfn = "__unm"
                func.luafn = "__unm"
            end
        end
    end

    func.prototype = gen_prototype(cls, func)
    func.display_name = gen_display_name(cls, func)

    if cls.conf.props:has(func.cxxfn) then
        func.is_exposed = false
    end

    return func, func_def
end

---@class idl.conf.template_desc
---@field cxxfn string
---@field template_types olua.ordered_map

---@param cls idl.model.class_desc
---@param cur clang.Cursor
---@param template_desc? idl.conf.template_desc
function Autoconf:visit_method(cls, cur, template_desc)
    template_desc = template_desc or {}
    local func, func_def = parse_func(cls, cur, template_desc.template_types or cls.conf.template_types)
    local fn = func.cxxfn
    local attrs = parse_attr_from_annotate(cls, cur, func.display_name)
    local member = cls.conf.members:get(func.display_name) ---@type idl.conf.member_desc
    local callback_type = nil

    func.ret.attr:concat(attrs:get("ret"))
    func.macro = member.macro
    func.insert_after = member.insert_after
    func.insert_before = member.insert_before
    func.insert_cafter = member.insert_cafter
    func.insert_cbefore = member.insert_cbefore
    func.luacats = member.luacats
    func.luafn = member.luafn

    if cur:isVariadic() then
        func.is_variadic = true
        func.ret.attr:push("@variadic")
    end

    if template_desc.cxxfn then
        local T = template_desc.template_types:values()[1]
        olua.use(T)
        func.ret.attr:pushf("@template(${func.cxxfn}<${T}>)")
        func.cxxfn = template_desc.cxxfn
        func.luafn = template_desc.cxxfn
    end

    if func.is_contructor then
        func.ret.type = cls.cxxcls .. " *"
        func.luafn = "new"
        func.cxxfn = "new"
    else
        if is_func_type(func.ret.type) or is_func_type(func_def.ret) then
            callback_type = "ret"
        end
    end

    if func.luafn == func.cxxfn then
        func.luafn = cls.conf.luaname(func.cxxfn, "func")
    end

    local name_from_attr = olua.join(func.ret.attr, " "):match("@name%(([^)]+)%)")
    if name_from_attr then
        func.luafn = name_from_attr
    end

    func.luafn = keywords[func.luafn] or func.luafn

    local has_optional = false
    local min_args = 0
    local num_args = 0
    for i, arg in ipairs(func_def.args) do
        local arg_type = func.args[i] ---@type idl.model.type_desc
        local argn = "arg" .. i
        arg_type.attr:concat(attrs:get(argn) or olua.array())
        num_args = i
        if is_func_type(arg.type) or is_func_type(arg_type.type) then
            callback_type = "arg"
        end
        if has_default_value(arg) then
            has_optional = true
            arg_type.attr:push("@optional")
        else
            min_args = min_args + 1
            assert(not has_optional, cls.cxxcls .. "::" .. func.prototype)
        end
    end

    if callback_type or (member.tag_maker or member.tag_mode) then
        if callback_type == "arg" then
            func.tag_usepool = member.tag_usepool ~= false
        end
        func.tag_maker = member.tag_maker or fn:gsub("^[sS]et", ""):gsub("^[gG]et", "")
        func.tag_mode = member.tag_mode or (callback_type == "arg" and "replace" or "equal")
        func.tag_store = member.tag_store or (func.is_contructor and -1 or 0)
        func.tag_scope = member.tag_scope or "object"
    end

    cls.conf.excludes:replace(func.display_name, true)
    cls.conf.excludes:replace(cur.displayName, true)

    if cur.name:find("operator<=>") then
        local v = func.ret.attr:find(function (v) return v:find("^@operator") end)
        func.ret.attr:remove(v)
        for _, op in ipairs({ "operator==", "operator<", "operator<=" }) do
            local op_func = olua.clone(func)
            local op_name = operator[op]
            op_func.cxxfn = op_name
            op_func.luafn = op_name
            op_func.ret.type = "bool"
            op_func.ret.attr:pushf("@operator(${op})")
            op_func.macro = "#if __cplusplus >= 202002L"
            op_func.prototype = gen_prototype(cls, op_func)
            op_func.display_name = gen_display_name(cls, op_func)
            local funcs = cls.funcs:get(op_func.cxxfn)
            if not funcs then
                funcs = olua.array()
                cls.funcs:set(op_func.cxxfn, funcs)
            end
            funcs:push(op_func)
        end
    else
        local funcs = cls.funcs:get(func.cxxfn)
        if not funcs then
            funcs = olua.array()
            cls.funcs:set(func.cxxfn, funcs)
        end

        funcs:push(func)

        local ret_attr = func.ret.attr:find(function (value)
            return value:find("@getter") or value:find("@setter")
        end)
        if ret_attr then
            local what = ret_attr:find("@getter") and "get" or "set"
            olua.assert((what == "get" and num_args == 0) or num_args == 1, [[
            ${what}ter function has wrong argument:
                prototype: ${decl}
        ]])
            local prop = cls.props:get(func.luafn)
            if not prop then
                prop = { name = func.luafn, get = "" } ---@type idl.model.prop_desc
                cls.props:set(func.luafn, prop)
            end
            prop[what] = func.prototype
            func.is_exposed = false
        elseif cur:isVariadic() then
            for n = 1, olua.MAX_VARIADIC_ARGS do
                local variadic_func = olua.clone(func)
                for i = 1, n do
                    local arg = olua.clone(variadic_func.args[num_args]) ---@type idl.model.type_desc
                    olua.use(i)
                    arg.name = olua.format("${arg.name}_$${i}")
                    variadic_func.args:push(arg)
                end
                variadic_func.prototype = gen_prototype(cls, variadic_func)
                variadic_func.display_name = gen_display_name(cls, variadic_func)
                funcs:push(variadic_func)
                cls.CMD.func(variadic_func.display_name)
            end
        elseif has_optional then
            for n = min_args, #func.args - 1 do
                local overload_func = olua.clone(func)
                overload_func.args = overload_func.args:slice(1, n)
                overload_func.prototype = gen_prototype(cls, overload_func)
                overload_func.display_name = gen_display_name(cls, overload_func)
                funcs:push(overload_func)
                cls.CMD.func(overload_func.display_name)
            end
        end
    end
end

---@param cls idl.model.class_desc
---@param cur clang.Cursor
function Autoconf:visit_var(cls, cur)
    if is_excluded_type(cur.type)
        or has_exclude_attr(cur)
        or has_deprecated_attr(cur)
        or cur.type.name:find("%[")
    then
        return
    end

    local typefrom = olua.format("${cls.cxxcls} -> ${cur.prettyPrinted}")
    local tn = typename(cur.type, cls.conf.template_types, nil, typefrom)
    local ret_tn = olua.decltype(tn, nil, true)
    local arg_tn = olua.decltype(tn, nil, false)

    local fn = cur.name
    local attrs = parse_attr_from_annotate(cls, cur, cur.name, true)
    local luafn = cls.conf.luaname(fn, "var")

    local member = cls.conf.members:get(cur.name) ---@type idl.conf.member_desc

    olua.use(ret_tn, arg_tn)

    ---@type idl.model.func_desc
    local getter = {
        cxxfn = fn,
        luafn = luafn,
        prototype = olua.format("${ret_tn}${fn}()"),
        display_name = olua.format("${fn}()"),
        ret = { type = tn, attr = attrs:get("ret") },
        args = olua.array(),
        is_variable = true,
        is_exposed = false,
    }

    ---@type idl.model.func_desc
    local setter = {
        cxxfn = fn,
        luafn = luafn,
        prototype = olua.format("void ${fn}(${arg_tn})"),
        display_name = olua.format("${fn}(${arg_tn})"),
        ret = { type = "void", attr = olua.array() },
        args = olua.array(),
        is_variable = true,
        is_exposed = false,
    }

    ---@type idl.model.type_desc
    local arg1 = setter.args:push({
        type = tn,
        name = fn,
        attr = attrs:get("arg1"),
    })

    if is_func_type(cur.type) then
        getter.tag_maker = getter.tag_maker or fn
        getter.tag_mode = getter.tag_mode or "equal"
        getter.tag_store = 0
        getter.tag_scope = "object"
        getter.tag_usepool = getter.tag_usepool ~= false
        setter.tag_maker = setter.tag_maker or fn
        setter.tag_mode = setter.tag_mode or "replace"
        setter.tag_store = 0
        setter.tag_scope = "object"
        setter.tag_usepool = setter.tag_usepool ~= false
        arg1.attr:push("@nullable")
    end

    if cur.kind == CursorKind.VarDecl then
        getter.is_static = true
        setter.is_static = true
    end

    local funcs = cls.funcs:get(fn)
    if not funcs then
        funcs = olua.array()
        cls.funcs:set(fn, funcs)
    end

    local index = member.index or cls.vars:size()

    local has_readonly = getter.ret.attr:find(function (value)
        return value:find("@readonly")
    end)

    if cur.type:isConstQualified() or has_readonly then
        if not has_readonly then
            getter.ret.attr:push("@readonly")
        end
        funcs:push(getter)
        cls.vars:set(fn, {
            name = getter.luafn or fn,
            get = getter.prototype,
            index = index,
        })
    else
        funcs:push(getter)
        funcs:push(setter)
        cls.vars:set(fn, {
            name = getter.luafn or fn,
            get = getter.prototype,
            set = setter.prototype,
            index = index,
        })
    end

    -- if attr.optional or (has_default_value(cur) and attr.optional == nil) then
    --     exps:push("@optional ")
    -- end
end

---@param cxxcls string
---@return idl.model.class_desc
function Autoconf:will_visit(cxxcls)
    local cls = self.class_types:get(cxxcls)
    if visited_types:has(cxxcls) then
        olua.error([[
            ${cxxcls} already visited
            you should do one of:
                * if you set olua.AUTO_EXPORT_PARENT = true, remove "typeconf '${cxxcls}'"
                    or move "typeconf '${cxxcls}'" before subclass
                * check whether "typeconf '${cxxcls}'" in multi config file
        ]])
    end
    visited_types:replace(cxxcls, cls)
    return cls
end

---@param cxxcls string
---@param cur clang.Cursor
function Autoconf:visit_enum(cxxcls, cur)
    local cls = self:will_visit(cxxcls)
    local filter = {}
    for _, c in ipairs(cur.children) do
        if c.kind ~= CursorKind.EnumConstantDecl or is_excluded_memeber(cls, c) then
            goto skip_enum
        end

        local value = c.name ---@type string
        local intvalue
        local name = cls.conf.luaname(value --[[@as string]], "enum")
        local range = c.commentRange
        local comment = get_comment(c)
        if not filter[range.startLine] then
            filter[range.startLine] = true
        else
            comment = ""
        end
        value = olua.format("${cls.cxxcls}::${value}")
        if c.kind == CursorKind.EnumConstantDecl then
            intvalue = c.enumConstantDeclValue
        end
        cls.enums:set(name, {
            name = name,
            value = value,
            intvalue = intvalue,
            comment = comment ~= "" and comment or nil
        })

        ::skip_enum::
    end
    idl.type_convs:get(cxxcls).conv = "olua_$$_enum"
    if not cls.options.indexerror then
        cls.options.indexerror = "rw"
    end
    cls.conf.kind = cls.conf.kind or kFLAG_ENUM
end

---@param alias string
---@param cxxcls string
function Autoconf:visit_alias_class(alias, cxxcls)
    local cls = self:will_visit(alias)
    cls.conf.kind = cls.conf.kind or kFLAG_POINTER
    if is_func_type(cxxcls) then
        cls.conf.kind = cls.conf.kind | kFLAG_FUNC
        cls.conf.funcdecl = cxxcls
        cls.conf.luacls = self.luacls(alias)
        idl.type_convs:get(alias).conv = "olua_$$_callback"
    else
        cls.conf.kind = cls.conf.kind | kFLAG_ALIAS
        cls.supercls = cxxcls
        cls.conf.luacls = self.luacls(cxxcls)
    end
end

---@param cls idl.model.class_desc
---@param cur clang.Cursor
---@param is_cxx_abstract boolean
---@return boolean
local function can_visit_method(cls, cur, is_cxx_abstract)
    local kind = cur.kind
    local is_constructor = kind == CursorKind.Constructor
    local is_operator = cur.name:find("operator[^%w]+")
    if is_excluded_memeber(cls, cur)
        or cur:isCXXDeletedMethod()
        or cur:isCXXCopyConstructor()
        or cur:isCXXMoveConstructor()
        or (is_constructor and (cls.conf.excludes:has("new")))
        or (is_constructor and is_cxx_abstract)
        or has_deprecated_attr(cur)
        or has_exclude_attr(cur)
        or is_operator and (not operator[cur.name] or not cls.options.reg_luatype)
        or cur.name == "as" -- 'as used to cast object'
        or not check_included_method(cls, cur)
    then
        return false
    else
        return true
    end
end

---@param cxxcls string
---@param cur clang.Cursor
---@param template_types? string[]
---@param specializedcls? string
function Autoconf:visit_class(cxxcls, cur, template_types, specializedcls)
    local cls = self:will_visit(cxxcls)
    local skipsuper = false

    cls.conf.kind = cls.conf.kind or kFLAG_POINTER

    local comment = get_comment(cur)
    if comment then
        cls.comment = comment
    end

    if cur.kind == CursorKind.ClassTemplate then
        local tn = raw_typename(cxxcls)
        if not idl.type_convs:has(tn) then
            idl.type_convs:replace(raw_typename(cxxcls), true)
        end
        olua.assert(template_types, [[
            don't config template class:
                you should remove: typeconf '${cls.cxxcls}'
        ]])
        cls.conf.kind = cls.conf.kind | kFLAG_TEMPLATE
        if specializedcls then
            cls.conf.template_types:set(specializedcls, cxxcls)
        end
    elseif cur.kind == CursorKind.Namespace then
        cls.options.reg_luatype = false
    end

    for _, c in ipairs(cur.children) do
        local kind = c.kind
        if is_private_member(c) then
            if kind == CursorKind.FunctionDecl or kind == CursorKind.CXXMethod then
                cls.conf.excludes:replace(c.displayName, true)
            end
            if kind == CursorKind.Destructor then
                cls.options.disallow_gc = true
            end
            goto continue
        elseif kind == CursorKind.TemplateTypeParameter then
            local tn = table.remove(assert(template_types), 1)
            if not tn and c.type.kind ~= TypeKind.Unexposed then
                olua.error([[
                    template type not found:
                          cxxcls: ${cls.cxxcls}
                        typename: ${c.name}
                ]])
            end
            cls.conf.template_types:set(c.name, tn)
        elseif kind == CursorKind.CXXBaseSpecifier then
            local supercls = parse_from_type(c.type)
            local rawsupercls = raw_typename(supercls)
            local supercursor = type_cursors:get(rawsupercls)

            if is_excluded_typename(rawsupercls) then
                skipsuper = true
                goto continue
            end

            if olua.is_templdate_type(supercls) then
                skipsuper = true
                local arg_types = {}
                for i, v in ipairs(c.type.templateArgumentTypes) do
                    arg_types[i] = parse_from_type(v)
                end
                typeconf(supercls)
                self:visit_class(supercls, supercursor, arg_types)
            elseif olua.AUTO_EXPORT_PARENT then
                local super = visited_types:get(rawsupercls)
                if not super then
                    assert(supercursor, "no cursor for " .. rawsupercls)
                    if not self.class_types:has(rawsupercls) then
                        typeconf(rawsupercls)
                    end
                    self:visit_class(rawsupercls, supercursor)
                    super = self.class_types:take(rawsupercls) ---@type idl.model.class_desc
                    if super.supercls then
                        self.class_types:insert("after", super.supercls, rawsupercls, super)
                    else
                        self.class_types:insert("front", nil, rawsupercls, super)
                    end
                end
            end

            if not cls.supercls and not skipsuper then
                skipsuper = true
                cls.supercls = supercls
            end
            cls.conf.supers:set(supercls, supercls)
        elseif kind == CursorKind.UsingDeclaration then
            for _, cc in ipairs(c.children) do
                if cc.kind == CursorKind.TypeRef then
                    cls.conf.usings:set(c.name, cc.name:match("([^ ]+)$"))
                    break
                end
            end
        elseif kind == CursorKind.FieldDecl or kind == CursorKind.VarDecl then
            local varname = c.name
            local vartype = c.type
            if is_excluded_memeber(cls, c) then
                goto continue
            end
            if vartype:isConstQualified() and kind == CursorKind.VarDecl then
                if not is_excluded_type(vartype) then
                    cls.consts:set(varname, {
                        name = varname,
                        type = typename(vartype),
                        comment = get_comment(c),
                        value = olua.format("${cls.cxxcls}::${varname}")
                    })
                end
            else
                self:visit_var(cls, c)
            end
        elseif kind == CursorKind.Constructor
            or kind == CursorKind.FunctionDecl
            or kind == CursorKind.CXXMethod
        then
            if can_visit_method(cls, c, cur:isCXXAbstract()) then
                self:visit_method(cls, c)
            end
        elseif kind == CursorKind.FunctionTemplate then
            local member = cls.conf.members:get(c.name) ---@type idl.conf.member_desc
            if not member and cls.conf.maincls then
                member = cls.conf.maincls.conf.members:get(c.name)
            end
            if member then
                local T = c.children[1].name
                for _, v in ipairs(member.insts) do
                    local func_template_types = olua.ordered_map()
                    ---@cast v idl.conf.inst_desc
                    func_template_types:set(T, v.type)
                    self:visit_method(cls, c, {
                        cxxfn = v.cxxfn,
                        template_types = func_template_types
                    })
                end
            end
        elseif kind == CursorKind.FriendDecl then
            for _, cc in ipairs(c.children) do
                if cc.kind == CursorKind.FunctionDecl and can_visit_method(cls, cc, false) then
                    self:visit_method(cls, cc)
                end
            end
        end

        ::continue::
    end

    if operator_cursors:has(cxxcls) then
        for _, c in ipairs(operator_cursors:get(cxxcls)) do
            if can_visit_method(cls, c, false) then
                self:visit_method(cls, c)
            end
        end
    end
end

---@param cur clang.Cursor
---@param cxxcls string
function Autoconf:visit(cur, cxxcls)
    local kind = cur.kind
    local astcls = parse_from_ast({ declaration = cur, name = cur.name })
    cxxcls = cxxcls or astcls
    if kind == CursorKind.Namespace then
        self:visit_class(cxxcls, cur)
    elseif kind == CursorKind.ClassTemplate
        or kind == CursorKind.ClassDecl
        or kind == CursorKind.StructDecl
        or kind == CursorKind.UnionDecl
    then
        if astcls ~= cxxcls and idl.type_convs:has(astcls) then
            self:visit_alias_class(cxxcls, astcls)
        else
            self:visit_class(cxxcls, cur)
        end
    elseif kind == CursorKind.EnumDecl then
        self:visit_enum(cxxcls, cur)
    elseif kind == CursorKind.TypeAliasDecl then
        self:visit(cur.typedefDeclUnderlyingType.declaration, cxxcls)
    elseif kind == CursorKind.TypedefDecl then
        local underlying = typename(cur.typedefDeclUnderlyingType)
        if is_func_type(underlying) then
            self:visit_alias_class(cxxcls, underlying)
        else
            local decl = cur.typedefDeclUnderlyingType.declaration
            local specialized = decl.specializedTemplate
            if specialized then
                --[[
                    typedef olua::pointer<int> olua_int;

                    specialized: olua::pointer<int>
                         cxxcls: olua_int
                      packedcls: int
                ]]
                local arg_types = {}
                for i, v in ipairs(cur.type.templateArgumentTypes) do
                    arg_types[i] = parse_from_type(v)
                end
                local specializedcls = parse_from_type(cur.typedefDeclUnderlyingType)
                self:visit_class(cxxcls, specialized, arg_types, specializedcls)

                if specializedcls:find("^olua::pointer") then
                    local packedcls = specializedcls:match("<(.*)>") .. " *"
                    typedef(packedcls)
                        .luacls(self.luacls(cxxcls))
                        .conv("olua_$$_pointer")
                end
            else
                self:visit(decl, cxxcls)
            end
        end
    end
end

local function try_add_wildcard_type(cxxcls, cur)
    if cur.name:find("[.(/]") then
        -- (unnamed enum at src/protobuf.pb.h:1015:3)
        return
    end
    for _, m in ipairs(idl.modules) do
        if m.class_types:has(cxxcls) or idl.type_convs:has(cxxcls) then
            goto continue
        end
        for type, conf in pairs(m.wildcard_types) do
            if cxxcls:find(type) then
                if idl.exclude_types:has(cxxcls) then
                    print(olua.format([=[
                        [WARNING]: '${cxxcls}' matched by '${type}' will be ignored
                                       because '${cxxcls}' has been excluded
                    ]=], 1))
                else
                    idl.current_module = m
                    idl.typecopy(cxxcls, conf)
                    idl.current_module = nil
                end
            end
        end
        ::continue::
    end
end

---@param cur clang.Cursor
local function prepare_cursor(cur)
    local kind = cur.kind
    local cxxcls = parse_from_ast({ declaration = cur, name = cur.name })
    if cur.kind == CursorKind.FunctionDecl and operator[cur.name] then
        for _, c in ipairs(cur.children) do
            if c.kind == CursorKind.ParmDecl and c.parent == cur then
                local type = raw_typename(typename(c.type))
                local arr = operator_cursors:get(type) ---@type olua.array|nil
                if not arr then
                    arr = olua.array()
                    operator_cursors:set(type, arr)
                end
                arr:push(cur)
                break
            end
        end
    elseif cur.name == "begin" then
        if kind == CursorKind.FunctionDecl then
            local i = 0
            local tn
            for _, c in ipairs(cur.children) do
                if c.kind == CursorKind.ParmDecl and c.parent == cur then
                    tn = raw_typename(typename(c.type))
                    i = i + 1
                end
            end
            if i == 1 and tn then
                iterator_cursors:set(tn, cur)
            end
        elseif kind == CursorKind.CXXMethod then
            local i = 0
            for _, c in ipairs(cur.children) do
                if c.kind == CursorKind.ParmDecl and c.parent == cur then
                    i = i + 1
                end
            end
            if i == 0 then
                local tn = raw_typename(typename(cur.resultType))
                iterator_cursors:set(tn, cur)
            end
        end
    end
    if kind == CursorKind.ClassDecl
        or kind == CursorKind.EnumDecl
        or kind == CursorKind.ClassTemplate
        or kind == CursorKind.StructDecl
        or kind == CursorKind.UnionDecl
        or kind == CursorKind.Namespace
        or kind == CursorKind.TranslationUnit
    then
        local children = cur.children
        if #children > 0 then
            type_cursors:replace(cxxcls, cur)
            try_add_wildcard_type(cxxcls, cur)
            for _, v in ipairs(children) do
                prepare_cursor(v)
            end
        end
    elseif kind == CursorKind.TypeAliasDecl
        or kind == CursorKind.TypedefDecl
    then
        local children = cur.children
        if #children > 0 then
            type_cursors:replace(cxxcls, cur)
            type_cursors:replace(typename(cur.type), cur)
            try_add_wildcard_type(cxxcls, cur)
        end
    elseif kind == CursorKind.UnexposedDecl or kind == CursorKind.LinkageSpec then
        for _, v in ipairs(cur.children) do
            prepare_cursor(v)
        end
    end
    if cur.rawCommentText then
        comment_cursors:replace(cxxcls, cur)
    end
    if kind == CursorKind.TranslationUnit then
        alias_types:clear()
    end
end

-------------------------------------------------------------------------------
-- output config
-------------------------------------------------------------------------------

local function parse_headers()
    local headers = olua.array("\n")
    for _, m in ipairs(idl.modules) do
        headers:push(m.headers)
    end

    local HEADER_PATH = "autobuild/.autoconf.h"
    local header = assert(io.open(HEADER_PATH, "w"))
    header:write(olua.format [[
        #ifndef __AUTOCONF_H__
        #define __AUTOCONF_H__

        ${headers}

        #endif
    ]])
    header:close()
    local has_target = false
    local has_stdv = false
    local flags = olua.array("")
    flags:push("-DOLUA_AUTOCONF")
    for i, v in ipairs(idl.clang_args) do
        flags[#flags + 1] = v
        if v:find("^-target") then
            has_target = true
        end
        if v:find("^-std") then
            has_stdv = true
        end
    end
    if not has_stdv then
        flags:push("-std=c++11")
    end
    if not has_target then
        flags:concat({
            "-x", "c++", "-nostdinc",
            "-U__SSE__",
            "-DANDROID",
            "-target", "armv7-none-linux-androideabi",
            "-idirafter", "${OLUA_HOME}/include/c++",
            "-idirafter", "${OLUA_HOME}/include/c",
            "-idirafter", "${OLUA_HOME}/include/android-sysroot/x86_64-linux-android",
            "-idirafter", "${OLUA_HOME}/include/android-sysroot",
        })
    end
    if olua.PARSE_ALL_COMMENTS then
        flags:push("-fparse-all-comments")
    end
    for i, v in ipairs(flags) do
        local OLUA_HOME = olua.OLUA_HOME
        olua.use(OLUA_HOME)
        flags[i] = olua.format(v)
    end
    olua.print("clang: start parse translation unit")
    clang_tu = clang.createIndex(false, true):parse(HEADER_PATH, flags)
    for _, v in ipairs(clang_tu.diagnostics) do
        if v.severity == DiagnosticSeverity.Error
            or v.severity == DiagnosticSeverity.Fatal
        then
            error("parse header error")
        end
    end
    olua.print("clang: start prepare cursor")
    prepare_cursor(clang_tu.cursor)
    olua.print("clang: complete prepare cursor")
    os.remove(HEADER_PATH)
end

local function init_conv_func(cls)
    local function convertor(cxxcls)
        return "olua_$$_" .. cxxcls:gsub("::", "_"):gsub("[ *]", "")
    end
    if not cls.includes then
        -- typedef type
        if not cls.conv then
            cls.conv = convertor(cls.cxxcls)
        end
    end
end

local function parse_types()
    for _, m in ipairs(idl.modules) do
        for _, cls in ipairs(m.typedef_types) do
            init_conv_func(cls)
        end
        for _, cls in ipairs(m.class_types) do
            init_conv_func(cls)
        end
    end

    for _, m in ipairs(idl.modules) do
        for _, cls in ipairs(m.class_types) do
            ---@cast cls idl.model.class_desc
            for fn, func in pairs(cls.conf.members) do
                ---@cast func idl.conf.member_desc
                if func.body then
                    cls.conf.excludes:set(fn, true)
                end
            end
        end
        if not m.path then
            m.path = olua.format("lua-${m.name}.lua")
        end
        setmetatable(m, { __index = Autoconf })
        olua.print("parsing: ${m.path}")
        idl.current_module = m
        m:parse()
        idl.current_module = nil
    end
end

local function check_errors()
    local class_not_found = olua.array("\n")
    local supercls_not_found = olua.array("\n")
    local type_not_found = olua.array("\n")

    -- check class and super class
    for _, m in ipairs(idl.modules) do
        for _, cls in ipairs(m.class_types) do
            ---@cast cls idl.model.class_desc
            if not visited_types:has(cls.cxxcls) then
                class_not_found:pushf([[
                    => ${cls.cxxcls}
                ]])
            end
            for _, supercls in ipairs(cls.conf.supers) do
                if not visited_types:has(supercls) then
                    supercls_not_found:pushf([[
                        => ${cls.cxxcls} -> ${supercls}
                    ]])
                end
            end
        end
    end

    -- check type info
    table.sort(type_checker, function (e1, e2) return e1.type < e2.type end)
    local filter = {}
    olua.foreach(type_checker, function (entry)
        if is_func_type(entry.type) then
            if not olua.is_pointer_type(entry.type) then
                return
            end
        elseif not olua.is_templdate_type(entry.type)
            or not olua.is_pointer_type(entry.type)
        then
            local rawtn = raw_typename(entry.type)
            local rawptn = raw_typename(entry.type, KEEP_POINTER)
            if idl.type_convs:has(rawtn)
                or idl.type_convs:has(rawptn)
                or alias_types:has(rawtn)
                or alias_types:has(rawptn)
                or olua.typeinfo(rawptn, nil, false)
            then
                return
            end
        else
            -- template type with pointer
            local rawtn = raw_typename(entry.type, KEEP_TEMPLATE)
            local rawptn = raw_typename(entry.type, KEEP_TEMPLATE | KEEP_POINTER)
            if idl.type_convs:has(rawtn) or idl.type_convs:has(rawptn) then
                return
            end
        end

        if olua.VERBOSE then
            type_not_found:pushf([[
                => ${entry.type} (${entry.kind})
                      from: ${entry.from}
            ]])
        elseif not filter[entry.type] then
            filter[entry.type] = true
            type_not_found:pushf([[
                => ${entry.type} (${entry.kind})
                      from: ${entry.from}
            ]])
        end
    end)

    if #class_not_found > 0 then
        print("")
        print(olua.format([[
            class not configured:
                ${class_not_found}
            you should do:
                * add include header file in your config file or check the class name
        ]]))
    end

    if #supercls_not_found > 0 then
        print("")
        print(olua.format([[
            super class not configured:
                ${supercls_not_found}
            you should do one of:
                * add in config file: typeconf 'MissedSuperClass'
                * set in build file: olua.AUTO_EXPORT_PARENT = true
        ]]))
    end

    if #type_not_found > 0 then
        print("")
        print(olua.format([[
            type info not found:
                ${type_not_found}
            you should do one of:
                * if has the type convertor, use typedef 'NotFoundType'
                * if type is pointer or enum, use typeconf 'NotFoundType'
                * if type not wanted, use exclude_type 'NotFoundType' or .exclude 'MethodName'
            more debug info set 'olua.VERBOSE = true'
        ]]))
    end

    if #class_not_found > 0
        or #supercls_not_found > 0
        or #type_not_found > 0
    then
        print("")
        error("You should fix above errors!")
    end
end

local function copy_super_funcs()
    ---@param cls idl.model.class_desc
    ---@param super idl.model.class_desc
    local function copy_funcs(cls, super)
        local rawsuper = raw_typename(super.cxxcls)
        super.funcs:foreach(function (arr)
            ---@cast arr olua.array
            arr:foreach(function (func)
                ---@cast func idl.model.func_desc
                if func.is_contructor
                    or func.cxxfn == "__gc"
                    or cls.conf.excludes:has(func.cxxfn)
                    or cls.conf.excludes:has(func.display_name)
                then
                    return
                end
                func = olua.clone(func)
                cls.conf.excludes:set(func.display_name, true)
                local funcs = cls.funcs:get(func.cxxfn)
                if not funcs then
                    funcs = olua.array()
                    cls.funcs:set(func.cxxfn, funcs)
                end
                olua.use(rawsuper)
                func.ret.attr:pushf("@copyfrom(${rawsuper})")
                cls.CMD.func(func.display_name)
                funcs:push(func)
            end)
        end)
    end

    ---@param cls idl.model.class_desc
    ---@param super idl.model.class_desc
    local function copy_super(cls, super)
        copy_funcs(cls, super)
        for _, sc in ipairs(super.conf.supers) do
            copy_super(cls, visited_types:get(sc))
        end
    end

    for _, m in ipairs(idl.modules) do
        ---@cast m idl.model.module_desc
        for _, cls in ipairs(m.class_types) do
            ---@cast cls idl.model.class_desc
            for _, supercls in ipairs(cls.conf.supers) do
                if cls.supercls == supercls then
                    goto continue
                end
                local super = visited_types:get(supercls) ---@type idl.model.class_desc
                copy_super(cls, super)
                if cls.conf.supers:size() == 1 and olua.is_templdate_type(super.cxxcls) then
                    -- see find 'find_as_cls'
                    -- no 'as' func, no need to export
                    super.conf.kind = super.conf.kind | kFLAG_SKIP
                end
                ::continue::
            end
        end
    end
end

local function find_as()
    ---@param c idl.model.class_desc
    ---@param ascls_map olua.ordered_map
    local function find_ascls(c, ascls_map)
        for supercls in pairs(c.conf.supers) do
            ascls_map:replace(supercls, supercls)
            find_ascls(visited_types:get(supercls), ascls_map)
        end
    end

    ---remove first super class
    ---@param c idl.model.class_desc
    ---@param ascls_map olua.ordered_map
    local function remove_first_ascls(c, ascls_map)
        local supercls = c.supercls
        if supercls then
            local rawsuper = raw_typename(supercls, KEEP_POINTER)
            ascls_map:take(rawsuper)
            remove_first_ascls(visited_types:get(supercls), ascls_map)
        end
    end

    for _, m in ipairs(idl.modules) do
        ---@cast m idl.model.module_desc
        for _, cls in ipairs(m.class_types) do
            -- find as
            local ascls_map = olua.ordered_map()
            ---@cast cls idl.model.class_desc
            if cls.conf.supers:size() > 1 then
                find_ascls(cls, ascls_map)
                remove_first_ascls(cls, ascls_map)
            end
            local ascls_arr = ascls_map:values()
            if #ascls_arr > 0 then
                ascls_arr:sort()
                ---@type idl.model.func_desc
                local as_func = {
                    cxxfn = "as",
                    luafn = "as",
                    is_exposed = true,
                    prototype = "void *as(const char *cls)",
                    ret = {
                        type = "void *",
                        attr = olua.array(),
                    },
                    args = olua.array(),
                }
                local ascls_str = ascls_arr:join(" ")
                as_func.ret.attr:pushf("@as(${ascls_str})")
                as_func.args:push({
                    type = "const char *",
                    name = "cls",
                    attr = olua.array(),
                })
                local funcs = olua.array()
                funcs:push(as_func)
                cls.funcs:replace("as", funcs)
            end
        end
    end
end

---@param cls idl.model.class_desc
local function cls_merge_extends(cls)
    cls.conf.extends:foreach(function (_, cxxcls)
        ---@type idl.model.class_desc
        local extcls = visited_types:get(cxxcls)
        extcls.funcs:foreach(function (extfuncs, cxxfn)
            local funcs = cls.funcs:get(cxxfn)
            if not funcs then
                funcs = olua.array()
                cls.funcs:set(cxxfn, funcs)
            end
            ---@cast extfuncs olua.array
            for _, func in ipairs(extfuncs) do
                olua.use(extcls)
                ---@cast func idl.model.func_desc
                if not func.is_static then
                    olua.error([[
                        extend only support static function:
                            class: ${extcls.cxxcls}
                                func: ${func.prototype}
                    ]])
                end
                func.is_extended = true
                func.ret.attr:pushf("@extend(${extcls.cxxcls})")
                cls.CMD.func(func.display_name)
                funcs:push(func)
            end
        end)
    end)
end

---@param cls idl.model.class_desc
local function cls_merge_snippet(cls)
    cls.conf.members:foreach(function (value, key)
        if value.body then
            cls.funcs:set(key, {
                {
                    cxxfn = key,
                    luafn = value.luafn,
                    body = value.body,
                    luacats = value.luacats,
                    is_exposed = true,
                }
            })
        end
    end)
    cls.conf.props:foreach(function (value, key)
        ---@cast value idl.conf.prop_desc
        if value.get:find("{") then
            local cxxfn = olua.format("get_${key}")
            local prototype = olua.format("unknown ${cxxfn}()")
            cls.funcs:set(cxxfn, {
                {
                    cxxfn = cxxfn,
                    luafn = cxxfn,
                    prototype = prototype,
                    body = value.get,
                    is_exposed = false,
                }
            })
            value.get = prototype
        end
        if value.set and value.set:find("{") then
            local cxxfn = olua.format("set_${key}")
            local prototype = olua.format("void ${cxxfn}(unknown)")
            cls.funcs:set(cxxfn, {
                {
                    cxxfn = cxxfn,
                    luafn = cxxfn,
                    prototype = prototype,
                    body = value.set,
                    is_exposed = false,
                }
            })
            value.set = prototype
        end
        cls.props:set(key, value)
    end)
end

---@param cls idl.model.class_desc
local function cls_search_using(cls)
    ---@param arr olua.array
    ---@param name string
    ---@param supercls string
    local function search_parent(arr, name, supercls)
        ---@type idl.model.class_desc
        local super = visited_types:get(supercls)
        if super and super.funcs:has(name) then
            arr:concat(super.funcs:get(name))
            if #arr == 0 and super.supercls then
                search_parent(arr, name, super.supercls)
            end
        end
    end
    for name, where in pairs(cls.conf.usings) do
        local supercls = cls.supercls
        while supercls and supercls ~= where do
            ---@type idl.model.class_desc
            local super = visited_types:get(supercls)
            if super then
                supercls = super.supercls
            end
        end
        if supercls then
            local arr = olua.array()
            local filter = {}
            search_parent(arr, name, supercls)
            for _, func in ipairs(arr) do
                ---@cast func idl.model.func_desc
                if not cls.conf.members:has(func.display_name) then
                    local funcs = cls.funcs:get(func.cxxfn)
                    if not funcs then
                        funcs = olua.array()
                        cls.funcs:set(func.cxxfn, funcs)
                    end
                    func = olua.clone(func)
                    func.ret.attr:push_unique("@using")
                    funcs:push(func)
                    cls.CMD.func(func.display_name)
                end
                filter[func.display_name] = true
            end
            for _, func in ipairs(cls.funcs:get(name)) do
                ---@cast func idl.model.func_desc
                if filter[func.display_name] then
                    func.ret.attr:push_unique("@using")
                end
            end
        elseif not cls.conf.supers:has(where) then
            olua.error([[unexpect copy using error: using ${where}:${name}]])
        end
    end
end

---@param cls idl.model.class_desc
local function has_method(cls, fn)
    if cls.funcs:get(fn) or cls.conf.members:has(fn) then
        return true
    end
    if cls.supercls then
        return has_method(visited_types:get(cls.supercls), fn)
    end
end

---@param cls idl.model.class_desc
local function cls_gen_metamethod(cls)
    if has_type_flag(cls, kFLAG_FUNC) then
        cls.CMD.func "__call"
            .body(olua.format([[
                luaL_checktype(L, -1, LUA_TFUNCTION);
                olua_push_callback(L, (${cls.cxxcls} *)nullptr, "${cls.conf.luacls}");
                return 1;
            ]]))
            .luacats(olua.format([[
                ---@return ${cls.conf.luacls}
            ]]))
    elseif cls.options.reg_luatype and not has_type_flag(cls, kFLAG_ENUM) then
        if not cls.options.disallow_gc and not has_method(cls, "__gc") then
            cls.CMD.func "__gc"
                .body(olua.format([[
                    auto self = (${cls.cxxcls} *)olua_toobj(L, 1, "${cls.conf.luacls}");
                    olua_postgc(L, self);
                    return 0;
                ]]))
        end
    end
end

---@param cls idl.model.class_desc
local function cls_gen_pack_overload(cls)
    ---@param arr olua.array
    ---@param func idl.model.func_desc
    local function gen_pack_overload(arr, func)
        if func.body then
            return
        end
        local pack_arg
        for _, arg in ipairs(func.args) do
            ---@cast arg idl.model.type_desc
            if arg.attr:contains("@pack") then
                if pack_arg then
                    olua.error("${cls.cxxcls}.${func.cxxfn}: only support one pack arg")
                end
                pack_arg = arg
            end
        end
        if not pack_arg then
            return
        end

        local arg_tn = raw_typename(pack_arg.type)
        local packvars = type_packvars:get(arg_tn)
        if not packvars then
            olua.error("${arg_tn} is not packable type")
        end

        local func_pack = olua.clone(func)
        if raw_typename(func_pack.ret.type) == arg_tn then
            if not func_pack.ret.attr:contains("@unpack") then
                func_pack.ret.attr:push("@unpack")
            end
        end
        arr:push(func_pack)

        pack_arg.attr:remove("@pack")
    end
    cls.funcs:foreach(function (arr)
        ---@cast arr olua.array
        for i = 1, #arr do
            gen_pack_overload(arr, arr[i])
        end
    end)
end

---@param cls idl.model.class_desc
local function cls_gen_props(cls)
    ---@param func idl.model.func_desc
    ---@return string | nil
    local function parse_prop_name(func)
        if (func.cxxfn:find("^[gG]et") or func.cxxfn:find("^[iI]s"))
            and func.args
            and (#func.args == 0 or (func.is_extended and #func.args == 1))
            and func.is_exposed
        then
            -- getABCd isAbc => ABCd Abc
            local name
            if func.cxxfn:find("^[gG]et") then
                name = func.cxxfn:gsub("^[gG]et_*", "")
            else
                name = func.cxxfn:gsub("^[iI]s_*", "")
            end
            return string.gsub(name, "^%u+", function (str)
                if #str > 1 and #str ~= #name then
                    if #str == #name - 1 then
                        -- ABCDs => abcds
                        return str:lower()
                    else
                        -- ABCd => abCd
                        return str:sub(1, #str - 1):lower() .. str:sub(#str)
                    end
                else
                    -- AbcdEF => abcdEF
                    return str:lower()
                end
            end)
        end
    end

    for _, arr in pairs(cls.funcs) do
        if not (#arr == 1 and olua.AUTO_GEN_PROP) then
            goto no_prop
        end

        local name = parse_prop_name(arr[1])
        if name and #name > 0 and not name:find("^%d") then
            local setfunc
            ---@type idl.model.func_desc
            local getfunc = arr[1]
            local setname = "^set_*" .. name:lower() .. "$"
            local lessone, moreone
            for set_k, set_arr in pairs(cls.funcs) do
                if #set_arr == 1 and set_k:lower():find(setname) then
                    ---@type idl.model.func_desc
                    setfunc = set_arr[1]
                    --[[
                        void setName(n)
                        void setName(n, i)
                    ]]
                    if #setfunc.args <= (setfunc.is_extended and 2 or 1) then
                        lessone = true
                    end
                    if #setfunc.args > (setfunc.is_extended and 2 or 1) then
                        moreone = true
                    end
                end
            end
            if (lessone or not moreone) and not cls.funcs:has(name) then
                cls.props:set(name, {
                    name = name,
                    get = getfunc.prototype,
                    set = setfunc and setfunc.prototype or nil
                })
            end
        end

        ::no_prop::
    end
end

---@param cls idl.model.class_desc
local function cls_trim_func(cls)
    ---@param supercls string
    ---@param func idl.model.func_desc
    local function is_new_func(supercls, func)
        if not supercls or func.is_static then
            return true
        end
        local super = visited_types:get(supercls) ---@type idl.model.class_desc
        if not super then
            olua.error("not found super class '${supercls}'")
        elseif super.conf.members:has(func.display_name)
            or super.conf.excludes:has(func.cxxfn)
        then
            return false
        else
            return is_new_func(super.supercls, func)
        end
    end

    cls.funcs:foreach(function (arr, cxxfn)
        local has_new_func = false
        local super_funcs = olua.array()
        for _, func in ipairs(arr) do
            ---@cast func idl.model.func_desc
            if func.body or func.cxxfn == "as" then
                has_new_func = true
            elseif is_new_func(cls.supercls, func) then
                has_new_func = true
            else
                super_funcs:push(func)
            end
        end
        if not has_new_func then
            cls.funcs:remove(cxxfn)
        else
            for _, func in ipairs(super_funcs) do
                ---@cast func idl.model.func_desc
                func.ret.attr:push_unique("@using")
            end
        end
    end)
end

---@param cls idl.model.class_desc
local function cls_gen_iterator(cls)
    if not cls.conf.iterator.name then
        return
    end
    local iterator = cls.conf.iterator
    local cur = iterator_cursors:get(iterator.name) ---@type clang.Cursor
    if not cur then
        olua.error("iterator '${iterator.name}' not found")
    end

    local once = iterator.once and "true" or "false"
    cls.CMD.func "__pairs"
        .body(olua.format([[
            auto self = olua_toobj<${cls.cxxcls}>(L, 1);
            int ret = olua_pairs<${cls.cxxcls}, ${iterator.name}>(L, self, ${once});
            return ret;
        ]]))
    if cur.kind == CursorKind.CXXMethod then
        cls.funcs:remove("begin")
        cls.funcs:remove("end")
    elseif cur.kind == CursorKind.FunctionDecl then
        local begin_fn = parse_from_ast({ declaration = cur, name = cur.name })
        local end_fn = begin_fn:gsub("begin$", "end")
        local codeblock = cls.codeblock or ""
        olua.use(once, end_fn, codeblock)
        cls.codeblock = olua.format([[
            ${codeblock}

            template <> inline
            ${iterator.name} olua_iterator_begin<${cls.cxxcls}, ${iterator.name}>(${cls.cxxcls} *obj) {
                return ${begin_fn}(*obj);
            }

            template <> inline
            ${iterator.name} olua_iterator_end<${cls.cxxcls}, ${iterator.name}>(${cls.cxxcls} *obj) {
                return ${end_fn}(*obj);
            }
        ]])
    end
end

---@param module idl.model.module_desc
local function write_module(module)
    local m = {
        name = module.name,
        api_dir = module.api_dir,
        output_dir = module.output_dir,
        entry = module.entry,
        headers = module.headers,
        codeblock = module.codeblock,
        luaopen = module.luaopen,
        class_types = olua.array(),
    }
    for _, cls in ipairs(module.class_types) do
        ---@cast cls idl.model.class_desc
        if has_type_flag(cls, kFLAG_ALIAS) or
            has_type_flag(cls, kFLAG_SKIP) or
            cls.conf.maincls
        then
            goto skip_alias_or_template
        end

        m.class_types:push(cls)

        cls_search_using(cls)
        cls_merge_extends(cls)
        cls_gen_metamethod(cls)
        cls_gen_pack_overload(cls)
        cls_gen_iterator(cls)
        cls_merge_snippet(cls)
        cls_trim_func(cls)
        cls_gen_props(cls)

        ::skip_alias_or_template::
    end

    for _, cls in ipairs(module.class_types) do
        local funcs = olua.ordered_map()
        ---@cast cls idl.model.class_desc
        cls.funcs:foreach(function (arr)
            olua.use(cls)
            olua.willdo("${cls.cxxcls} regroup function by lua function name")
            for _, func in ipairs(arr) do
                ---@cast func idl.model.func_desc
                olua.assert(func.luafn, "function ${func.cxxfn} has no lua function name")
                local luafn_arr = funcs:get(func.luafn)
                if not luafn_arr then
                    luafn_arr = olua.array()
                    funcs:set(func.luafn, luafn_arr)
                end
                luafn_arr:push(func)
            end
        end)
        cls.funcs = funcs
    end

    olua.write("${module.class_file}", olua.lua_stringify(m, {
        marshal = "return",
        indent = 2,
        oluatype = true,
    }))
end

local function parse_modules()
    parse_headers()
    parse_types()
    check_errors()
    copy_super_funcs()
    find_as()
end

local function write_ignored_types()
    local file = assert(io.open("autobuild/ignore-types.log", "w"))
    local ignored_types = {}
    for cxxcls, cur in pairs(type_cursors) do
        ---@cast cur clang.Cursor
        local kind = cur.kind
        if not cxxcls:find("^std::")
            and (kind == CursorKind.ClassDecl
                or kind == CursorKind.EnumDecl
                or kind == CursorKind.ClassTemplate
                or kind == CursorKind.StructDecl)
            and not (visited_types:has(cxxcls)
                or idl.exclude_types:has(cxxcls)
                or alias_types:has(cxxcls)
                or idl.type_convs:has(cxxcls))
        then
            ignored_types[#ignored_types + 1] = cxxcls
        end
    end
    table.sort(ignored_types)
    for _, cls in pairs(ignored_types) do
        file:write(string.format("[ignore class] %s\n", cls))
    end
end

local function write_typedefs()
    local typdefs = olua.array()

    for _, m in ipairs(idl.modules) do
        ---@cast m idl.model.module_desc
        m.typedef_types:foreach(function (td)
            ---@cast td idl.model.typedef_desc
            if td.packable then
                olua.assert(td.packvars, [[
                    no 'packvars' for packable type '${td.cxxcls}'
                ]])
            end
            local cls = visited_types:get(raw_typename(td.cxxcls))
            if cls and has_type_flag(cls, kFLAG_POINTER) then
                return
            end
            olua.use(m)
            ---@type idl.model.typedef_desc
            local typedef = {
                from = olua.format([[module: ${m.path} -> typedef "${td.cxxcls}"]]),
                cxxcls = td.cxxcls,
                luacls = td.luacls,
                luatype = td.luatype,
                conv = td.conv,
                packable = td.packable,
                packvars = td.packvars,
                smartptr = td.smartptr,
                override = td.override,
            }
            typdefs:push(typedef)
            if td.packable then
                type_packvars[td.cxxcls] = td.packvars
            end
        end)

        m.class_types:foreach(function (cls)
            ---@cast cls idl.model.class_desc
            if cls.conf.maincls then
                return
            end
            local packvars
            if has_type_flag(cls, kFLAG_POINTER) and cls.options.packable then
                packvars = cls.options.packvars or #cls.vars:keys()
                type_packvars:set(cls.cxxcls, packvars)
            end
            olua.use(m)

            ---@type idl.model.typedef_desc
            local typedef = {
                from = olua.format([[module: ${m.path} -> typedef "${cls.cxxcls}"]]),
                cxxcls = cls.cxxcls,
                luacls = cls.conf.luacls,
                template_luacls = cls.conf.template_luacls,
                supercls = cls.supercls,
                funcdecl = cls.conf.funcdecl,
                conv = idl.type_convs:get(cls.cxxcls).conv,
                packable = cls.options.packable,
                packvars = packvars,
                from_string = cls.options.from_string,
                from_table = cls.options.from_table,
                default = cls.conf.default,
            }
            typdefs:push(typedef)
        end)
    end

    alias_types:foreach(function (cxxcls, alias)
        ---@cast alias string
        if visited_types:get(raw_typename(alias)) then
            return
        end
        local cls = visited_types:get(raw_typename(cxxcls)) ---@type idl.model.class_desc
        local from = olua.format("alias: ${alias} -> ${cxxcls}")
        if not cls then
            local ti = assert(idl.type_convs:get(cxxcls) or olua.typeinfo(cxxcls))
            ---@type idl.model.typedef_desc
            local typedef = {
                from = from,
                cxxcls = alias,
                conv = ti.conv,
                luacls = ti.luacls,
                luatype = ti.luatype,
            }
            typdefs:push(typedef)
        elseif has_type_flag(cls, kFLAG_FUNC) then
            ---@type idl.model.typedef_desc
            local typedef = {
                from = from,
                cxxcls = alias,
                luacls = cls.conf.luacls,
                funcdecl = cls.conf.funcdecl,
                conv = "olua_$$_callback",
            }
            typdefs:push(typedef)
        elseif has_type_flag(cls, kFLAG_ENUM) then
            ---@type idl.model.typedef_desc
            local typedef = {
                from = from,
                cxxcls = alias,
                conv = "olua_$$_enum",
            }
            typdefs:push(typedef)
        else
            olua.assert(has_type_flag(cls, kFLAG_POINTER), [[
                '${cls.cxxcls}' not a pointee type
            ]])
            local packvars
            local packable = cls.options.packable
            if packable then
                packvars = cls.options.packvars or #cls.vars:keys()
            end
            ---@type idl.model.typedef_desc
            local typedef = {
                from = from,
                cxxcls = alias,
                luacls = cls.conf.luacls,
                packvars = packvars,
                packable = packable,
                conv = "olua_$$_object"
            }
            typdefs:push(typedef)
        end
    end)

    local out = olua.array("\n")
    out:push("---AUTO BUILD, DON'T MODIFY!\n")
    out:push("local typedef = olua.typedef")
    out:push("")
    for _, v in ipairs(typdefs:sort("cxxcls")) do
        out:push(olua.lua_stringify(v, { marshal = "typedef" }))
        out:push("")
    end
    olua.write("autobuild/typedefs.idl", tostring(out))
end

local function write_modules()
    for _, m in ipairs(idl.modules) do
        write_module(m)
    end
end

local function write_makefile()
    local class_files = olua.array("\n")
    for _, v in ipairs(idl.modules) do
        class_files:pushf('olua.load_idl("${v.class_file}")')
    end
    olua.write("autobuild/make.lua", olua.format([[
        require "init"

        dofile "autobuild/typedefs.idl"

        ${class_files}

        olua.export()
    ]]))
end

local function deferred_autoconf()
    parse_modules()
    write_ignored_types()
    write_typedefs()
    write_modules()
    write_makefile()

    if olua.AUTO_BUILD ~= false then
        dofile("autobuild/make.lua")
    end
end

function autoconf(path)
    dofile(path)
    if idl.current_module then
        idl.current_module.path = path
    end
    idl.current_module = nil
    idl.macros:clear()
end

package.loaded["script.autoconf"] = true

local has_hook = false

if not has_hook then
    has_hook = true

    local build_func

    for i = 1, 20 do
        local v = debug.getinfo(i, "fS")
        if v and v.what == "main" then
            build_func = v.func
        end
    end

    assert(build_func, "cannot find build function")

    if debug.gethook() then
        build_func()
        deferred_autoconf()
        autoconf = function () end
        idl.modules:clear()
        idl.macros:clear()
        idl.type_convs:clear()
        idl.current_module = nil
        return
    else
        debug.sethook(function ()
            if debug.getinfo(2, "f").func == build_func then
                debug.sethook(nil)
                deferred_autoconf()
            end
        end, "r")
    end
end
