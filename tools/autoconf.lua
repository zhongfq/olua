local olua = require "olua"
local clang = require "clang"

if not olua.isdir('autobuild') then
    olua.mkdir('autobuild')
end

local format = olua.format
local clang_tu

local ignored_types = {}
local visited_types = {}
local alias_types = {}
local type_convs = {}
local module_files = olua.newarray()
local logfile = io.open('autobuild/autoconf.log', 'w')

local writer = {}
local M = {}

local kFLAG_POINTEE = 1 << 1     -- pointee type
local kFLAG_ENUM = 1 << 2        -- enum type
local kFLAG_ALIAS = 1 << 3       -- alias type
local kFLAG_CONV = 1 << 4        -- conv type
local kFLAG_FUNC = 1 << 5        -- function type
local kFLAG_STRUCT = 1 << 6      -- struct type

local function has_kflag(cls, kind)
    return ((cls.kind or 0) & kind) ~= 0
end

local function conv_func(cls)
    return 'olua_$$_' .. string.gsub(cls.cppcls, '::', '_')
end

function M:parse(path)
    assert(not self.class_file)
    assert(not self.type_file)
    local filename = self.name:gsub('_', '-')
    self.class_file = format('autobuild/${filename}.lua')
    self.type_file = format('autobuild/${filename}-types.lua')

    module_files:push(self)

    for cls in pairs(self.exclude_types) do
        ignored_types[cls] = false
    end

    for _, cls in ipairs(self.typedef_types) do
        if not cls.conv then
            if cls.decltype then
                local ti = olua.typeinfo(cls.decltype, nil, true)
                if not ti then
                    error(string.format("decltype '%s' for '%s' is not found", cls.decltype, cls.cppcls))
                end
                cls.conv = ti.conv
            else
                cls.conv = conv_func(cls)
            end
        end
        type_convs[cls.cppcls] = cls.conv
    end

    for _, cls in pairs(self.class_types) do
        if has_kflag(cls, kFLAG_CONV) then
            type_convs[cls.cppcls] = conv_func(cls)
        else
            type_convs[cls.cppcls] = true
        end
    end

    self:visit(clang_tu:cursor())
    self:check_class()

    writer.write_module(self)
end

function M:has_define_class(cls)
    local name = string.match(cls.cppcls, '[^:]+$')
    return string.find(cls.chunk or '', 'class +' .. name) ~= nil
end

function M:check_class()
    for _, cls in ipairs(self.class_types) do
        if not visited_types[cls.cppcls] then
            if #cls.funcs > 0 or #cls.props > 0 then
                cls.kind = cls.kind or kFLAG_POINTEE
                cls.reg_luatype = self:has_define_class(cls)
                self:do_visit(cls)
            else
                error(format([[
                    class not found: ${cls.cppcls}
                      *** add include header file in 'conf/clang-args.lua' or check the class name
                ]]))
            end
        end
    end
    for _, cls in ipairs(self.class_types) do
        if cls.supercls and not visited_types[cls.supercls]then
            error(format('super class not found: ${cls.cppcls} -> ${cls.supercls}'))
        end
    end
end

function M:is_excluded_typeanme(name)
    if self.exclude_types[name] then
        return true
    elseif string.find(name, '<') then
        name = string.gsub(name, '<.*>', '')
        return self:is_excluded_typeanme(name)
    end
end

function M:is_excluded_type(type, cur)
    if type.kind == 'IncompleteArray' then
        return true
    end

    local tn = cur and self:typename(type, cur) or type.name
    -- remove const and &
    -- const T * => T *
    -- const T & => T
    local rawtn = tn:gsub('^const *', ''):gsub(' *&$', '')
    if self:is_excluded_typeanme(rawtn) then
        return true
    elseif tn ~= type.canonicalType.name then
        return self:is_excluded_type(type.canonicalType)
    end
end

function M:fullname(cur)
    if cur.kind == 'Namespace' then
        local ns = olua.newarray('::')
        while cur and cur.kind ~= 'TranslationUnit' do
            ns:insert(cur.name)
            cur = cur.parent
        end
        return tostring(ns)
    else
        return (cur.type or cur).name
    end
end

function M:typename(type, cur)
    local tn = type.name
    -- remove const, & and *: const T * => T
    local rawtn = tn:match('([%w:_]+) ?[&*]?$')
    if not rawtn then
        local ftype = type.templateArgTypes[1]
        if ftype and ftype.kind == 'FunctionProto' then
            local exps = olua.newarray('')
            exps:push(tn:find('^const') and 'const ' or nil)
            exps:push('std::function<')
            exps:push(ftype.resultType.name)
            exps:push(' (')
            for i, v in ipairs(ftype.argTypes) do
                exps:push(i > 1 and ', ' or nil)
                exps:push(v.name)
            end
            exps:push(')>')
            exps:push(tn:find('&$') and ' &' or nil)
            return tostring(exps)
        else
            return tn
        end
    end

    -- typedef std::function<void (Object *)> ClickListener
    -- const ClickListener & => const olua::ClickListener &
    for _, cu in ipairs(cur.children) do
        if cu.kind == 'TypeRef' then
            local typeref = cu.name:match('([^ ]+)$')
            if rawtn ~= typeref and string.find(typeref, rawtn .. '$') then
                tn = tn:gsub(rawtn, typeref)
                rawtn = typeref
                break
            end
        end
    end

    local alias = alias_types[rawtn]
    if alias and not type_convs[rawtn] then
        -- namespace::alias<K, V> => namespace::alias
        if olua.typeinfo(alias:gsub('<.+>', ''), nil, true) then
            -- rawtn: olua::ClickListener
            -- alias: std::function<void (Object *)>
            -- const olua::ClickListener & => const std::function<void (Object *)> &
            return string.gsub(tn, rawtn, alias)
        end
    end

    return tn
end

local DEFAULT_ARG_TYPES = {
    IntegerLiteral = true,
    FloatingLiteral = true,
    ImaginaryLiteral = true,
    StringLiteral = true,
    CharacterLiteral = true,
    CXXBoolLiteralExpr = true,
    CXXNullPtrLiteralExpr = true,
    GNUNullExpr = true,
    DeclRefExpr = true,
    CallExpr = true,
}

function M:has_default_value(cur)
    for _, c in ipairs(cur.children) do
        if DEFAULT_ARG_TYPES[c.kind] then
            return true
        elseif self:has_default_value(c) then
            return true
        end
    end
end

function M:has_unexposed_attr(cur)
    for _, c in ipairs(cur.children) do
        -- attribute(deprecated) ?
        if c.kind == 'UnexposedAttr' then
            return true
        end
    end
end

function M:is_func_type(tn)
    local rawtn = tn:match('([%w:_]+) ?[&*]?$')
    local decl = alias_types[rawtn] or ''
    return tn:find('std::function') or decl:find('std::function')
end

function M:visit_method(cls, cur)
    if cur.isVariadic
        or cur.name:find('^_')
        or cur.isCopyConstructor
        or cur.isMoveConstructor
        or cur.name:find('operator *[%-=+/*><!()]?')
        or self:is_excluded_type(cur.resultType, cur)
        or self:has_unexposed_attr(cur)
    then
        return
    end

    local fn = cur.name
    local attr = cls.attrs[fn] or cls.attrs['*'] or {}
    local callback = cls.callbacks[fn] or {}
    local exps = olua.newarray('')
    local declexps = olua.newarray('')

    for i, arg in ipairs(cur.arguments) do
        local attrn = (attr['arg' .. i]) or ''
        if not attrn:find('@ret') and self:is_excluded_type(arg.type, arg) then
            return
        end
    end

    exps:push(attr.ret and (attr.ret .. ' ') or nil)
    exps:push(cur.isStatic and 'static ' or nil)

    local cb_kind

    if cur.kind ~= 'Constructor' then
        local tn = self:typename(cur.resultType, cur)
        if self:is_func_type(tn) then
            cb_kind = 'ret'
            if callback.localvar ~= false then
                exps:push('@localvar ')
            end
        end
        exps:push(tn)
        exps:push(olua.typespace(tn))
    end

    local optional = false
    local min_args = 0
    exps:push(fn .. '(')
    declexps:push(fn .. '(')
    for i, arg in ipairs(cur.arguments) do
        local tn = self:typename(arg.type, arg)
        local displayName = cur.displayName
        local argn = 'arg' .. i
        exps:push(i > 1 and ', ' or nil)
        declexps:push(i > 1 and ', ' or nil)
        declexps:push(tn)
        if self:is_func_type(tn) then
            if cb_kind then
                error(format('has more than one std::function: ${cls.cppcls}::${displayName}'))
            end
            assert(not cb_kind, cls.cppcls .. '::' .. displayName)
            cb_kind = 'arg'
            if callback.localvar ~= false then
                exps:push('@localvar ')
            end
        end
        if self:has_default_value(arg) and not string.find(attr[argn] or '', '@ret') then
            exps:push('@optional ')
            optional = true
        else
            min_args = min_args + 1
            assert(not optional, cls.cppcls .. '::' .. displayName)
        end
        exps:push(attr[argn] and (attr[argn] .. ' ') or nil)
        exps:push(tn)
        exps:push(olua.typespace(tn))
        exps:push(arg.name)
    end
    exps:push(')')
    declexps:push(')')

    local func = tostring(exps)
    local prototype =  tostring(declexps)
    cls.excludes:replace(cur.displayName, true)
    cls.excludes:replace(prototype, true)
    local static = cur.isStatic
    if cur.kind == 'FunctionDecl' then
        func = 'static ' .. func
        static = true
    end
    cls.funcs[prototype] = {
        func = func,
        name = fn,
        static = static,
        num_args = #cur.arguments,
        min_args = min_args,
        cb_kind = cb_kind,
        prototype = prototype,
    }
end

function M:visit_var(cls, cur)
    if cur.type.isConst or self:is_excluded_type(cur.type, cur) then
        return
    end

    local exps = olua.newarray('')
    local attr = cls.attrs[cur.name] or cls.attrs['var*'] or {}
    local tn = self:typename(cur.type, cur)
    local cb_kind

    if tn:find('%[') then
        return
    end

    if attr.readonly then
        exps:push('@readonly ')
    end

    local length = string.match(tn, '%[(%d+)%]$')
    if length then
        exps:pushf('@array(${length})')
        exps:push(' ')
        tn = string.gsub(tn, ' %[%d+%]$', '')
    elseif attr.optional or (self:has_default_value(cur) and attr.optional == nil) then
        exps:push('@optional ')
    end

    if self:is_func_type(tn) then
        cb_kind = 'var'
        exps:push('@nullable ')
        local callback = cls.callbacks:take(cur.name) or {}
        if callback.localvar ~= false then
            exps:push('@localvar ')
        end
    end

    exps:push(attr.ret and (attr.ret .. ' ') or nil)
    exps:push(cur.kind == 'VarDecl' and 'static ' or nil)
    exps:push(tn)
    exps:push(olua.typespace(tn))
    exps:push(cur.name)

    local decl = tostring(exps)
    local name = cls.luaname(cur.name, 'var')
    cls.vars[name] = {
        name = name,
        snippet = decl,
        cb_kind = cb_kind
    }
end

function M:do_visit(cppcls)
    local cls = self.class_types[cppcls]
    visited_types[cppcls] = cls
    ignored_types[cppcls] = false
    return cls
end

function M:visit_enum(cppcls, cur)
    local cls = self:do_visit(cppcls)
    for _, c in ipairs(cur.children) do
        local value =  c.name
        local name = cls.luaname(value, 'enum')
        cls.enums[name] = {
            name = name,
            value = format('${cls.cppcls}::${value}'),
        }
    end
    cls.kind = cls.kind or kFLAG_ENUM
    alias_types[cls.cppcls] = nil
end

function M:visit_alias_class(alias, cppcls)
    local cls = self:do_visit(alias)
    cls.kind = cls.kind or kFLAG_POINTEE
    if self:is_func_type(cppcls) then
        cls.kind = cls.kind | kFLAG_FUNC
        cls.decltype = cppcls
        cls.luacls = self.luacls(alias)
    else
        cls.kind = cls.kind | kFLAG_ALIAS
        cls.supercls = cppcls
        cls.luacls = self.luacls(cppcls)
    end
end

function M:visit_class(cppcls, cur)
    local cls = self:do_visit(cppcls)

    cls.kind = cls.kind or kFLAG_POINTEE

    if cur.kind == 'StructDecl' then
        cls.kind = cls.kind | kFLAG_STRUCT
    end

    if cur.kind == 'Namespace' then
        cls.reg_luatype = false
    end

    for _, c in ipairs(cur.children) do
        local kind = c.kind
        local access = c.access
        if access == 'private' or access == 'protected' then
            goto continue
        elseif kind == 'CXXBaseSpecifier' then
            if not cls.supercls then
                cls.supercls = c.type.name
            end
        elseif kind == 'UsingDeclaration' then
            for _, cc in ipairs(c.children) do
                if cc.kind == 'TypeRef' then
                    cls.usings[c.name] = cc.name:match('([^ ]+)$')
                    break
                end
            end
        elseif kind == 'FieldDecl' or kind == 'VarDecl' then
            local vn = c.name
            local ct = c.type
            if cls.excludes['*'] or cls.excludes[vn] or vn:find('^_') then
                goto continue
            end
            if ct.isConst and kind == 'VarDecl' then
                if not self:is_excluded_type(ct, c) then
                    cls.consts[vn] = {name = vn, typename = ct.name}
                end
            else
                self:visit_var(cls, c)
            end
        elseif kind == 'Constructor' or kind == 'FunctionDecl' or kind == 'CXXMethod' then
            if (cls.excludes['*'] or cls.excludes[c.name] or cls.excludes[c.displayName])
                or (kind == 'Constructor' and (cls.excludes['new'] or cur.isAbstract))
            then
                goto continue
            end
            self:visit_method(cls, c)
        else
            self:visit(c)
        end

        ::continue::
    end
end

function M:visit(cur)
    local kind = cur.kind
    local children = cur.children
    local cls = self:fullname(cur)
    local need_visit = self.class_types[cls] and not visited_types[cls]
    if self:has_unexposed_attr(cur) then
        return
    elseif #children == 0 or string.find(cls, "^std::") then
        return
    elseif kind == 'Namespace' then
        if need_visit then
            self:visit_class(cls, cur)
        else
            for _, c in ipairs(children) do
                self:visit(c)
            end
        end
    elseif kind == 'ClassDecl' or kind == 'StructDecl' or kind == 'UnionDecl' then
        if need_visit then
            self:visit_class(cls, cur)
        else
            if not self.exclude_types[cls] and ignored_types[cls] == nil then
                ignored_types[cls] = true
            end
            for _, c in ipairs(cur.children) do
                self:visit(c)
            end
        end
    elseif kind == 'EnumDecl' then
        if need_visit then
            self:visit_enum(cls, cur)
        end
    elseif kind == 'TypeAliasDecl' or kind == 'TypedefDecl' then
        local decl = cur.underlyingType.declaration
        local decl_kind = decl.kind
        if decl.kind == 'NoDeclFound' then
            return
        end
        local name = self:typename(cur.underlyingType, cur)
        if name:find('^enum ') or name:find('^struct ')  then
            name = self:typename(decl.type, decl)
        end
        local alias = ((decl_kind == 'EnumDecl' and 'enum ' or '') .. name)
        alias_types[cls] = alias_types[name] or alias
        if need_visit then
            if decl_kind == 'StructDecl' then
                self:visit_class(cls, decl)
            elseif decl_kind == 'EnumDecl' then
                self:visit_enum(cls, decl)
            else
                self:visit_alias_class(cls, alias_types[cls])
            end
        end
    else
        for _, c in ipairs(children) do
            self:visit(c)
        end
    end
end

-------------------------------------------------------------------------------
-- output config
-------------------------------------------------------------------------------
function writer.write_metadata(module, append)
    append(format([[
        name = "${module.name}"
        path = "${module.path}"
    ]]))

    append(format('headers = ${module.headers?}'))
    append(format('chunk = ${module.chunk?}'))
    append(format('luaopen = ${module.luaopen?}'))
    append('')

    for _, cls in ipairs(module.class_types) do
        if not has_kflag(cls, kFLAG_CONV) then
            goto continue
        end

        ignored_types[cls.cppcls] = false

        local ifdef = (cls.ifdefs['*'] or {}).value
        append(format([[typeconv '${cls.cppcls}']]))
        for _, v in ipairs(cls.ifdefs) do
            append(format([[.ifdef('${v.name}', '${v.value}')]], 4))
        end
        for _, v in ipairs(cls.vars) do
            append(format('.var(${v.name?}, ${v.snippet?})', 4))
        end
        append('')

        ::continue::
    end
end

function writer.write_typedef(module)
    local t = olua.newarray('\n')

    local function writeLine(fmt, ...)
        t:push(string.format(fmt, ...))
    end

    writeLine("-- AUTO BUILD, DON'T MODIFY!")
    writeLine('')
    for _, td in ipairs(module.typedef_types) do
        local arr = {}
        ignored_types[td.cppcls] = false
        for k, v in pairs(td) do
            arr[#arr + 1] = {k, v}
        end
        table.sort(arr, function (a, b) return a[1] < b[1] end)
        writeLine("typedef {")
        for _, p in ipairs(arr) do
            local key, value = p[1], p[2]
            writeLine(format('${key} = ${value?},', 4))
        end
        writeLine("}")
        writeLine("")
    end

    local function write_class_typedef(cppcls, luacls, decltype, conv, num_vars)
        t:pushf([[
            typedef {
                cppcls = '${cppcls}',
                luacls = ${luacls},
                decltype = ${decltype},
                conv = '${conv}',
                num_vars = ${num_vars},
            }
        ]])
        t:push('')
    end

    for _, cls in ipairs(module.class_types) do
        local conv
        local cppcls = cls.cppcls
        local decltype, luacls, num_vars = 'nil', 'nil', 'nil'

        if has_kflag(cls, kFLAG_FUNC) then
            luacls = olua.stringify(cls.luacls, "'")
            decltype = olua.stringify(cls.decltype, "'")
            conv = 'olua_$$_callback'
        elseif has_kflag(cls, kFLAG_ENUM) then
            conv = 'olua_$$_uint'
            luacls = olua.stringify(cls.luacls, "'")
            decltype = olua.stringify('lua_Unsigned')
        elseif has_kflag(cls, kFLAG_POINTEE) then
            if has_kflag(cls, kFLAG_STRUCT) then
                cppcls = format('${cppcls} *; struct ${cppcls} *')
            else
                cppcls = cppcls .. ' *'
            end
            luacls = olua.stringify(cls.luacls, "'")
            conv = 'olua_$$_cppobj'
        elseif has_kflag(cls, kFLAG_CONV) then
            conv = 'olua_$$_' .. string.gsub(cls.cppcls, '[.:]+', '_')
            num_vars = #cls.vars
        else
            error(cls.cppcls .. ' ' .. cls.kind)
        end

        write_class_typedef(cppcls, luacls, decltype, conv, num_vars)

        if has_kflag(cls, kFLAG_POINTEE) and has_kflag(cls, kFLAG_CONV) then
            conv = 'olua_$$_' .. string.gsub(cls.cppcls, '[.:]+', '_')
            num_vars = #cls.vars
            luacls = 'nil'
            cppcls = cppcls:gsub('[ *]+', '')
            write_class_typedef(cppcls, luacls, decltype, conv, num_vars)
        end
    end
    t:push('')
    olua.write(module.type_file, tostring(t))
end

function writer.is_new_func(module, supercls, fn)
    if not supercls or fn.static then
        return true
    end

    local super = visited_types[supercls]
    if not super then
        error(format("not found super class '${supercls}'"))
    elseif super.funcs[fn.prototype] or super.excludes[fn.name] then
        return false
    else
        return writer.is_new_func(module, super.supercls, fn)
    end
end

function writer.to_prop_name(fn, filter, props)
    if (fn.name:find('^[gG]et') or fn.name:find('^[iI]s')) and fn.num_args == 0
    then
        -- getABCd isAbc => ABCd Abc
        local name = fn.name:gsub('^[gG]et', '')
        name = name:gsub('^[iI]s', '')
        return string.gsub(name, '^%u+', function (str)
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

function writer.search_using_func(module, cls)
    local function search_parent(arr, name, supercls)
        local super = visited_types[supercls]
        if super then
            for _, fn in ipairs(super.funcs) do
                if fn.name == name then
                    arr[#arr + 1] = fn
                end
            end
            if #arr == 0 then
                search_parent(arr, name, super.supercls)
            end
        end
    end
    for name, where in pairs(cls.usings) do
        local arr = {}
        local supercls = cls.supercls
        while supercls and supercls ~= where do
            local super = visited_types[supercls]
            if super then
                supercls = super.supercls
            end
        end
        search_parent(arr, name, supercls)
        for _, fn in ipairs(arr) do
            if not cls.funcs[fn.prototype] then
                cls.funcs[fn.prototype] = fn
            end
        end
    end
end

function writer.write_cls_func(module, cls, append)
    writer.search_using_func(module, cls)

    local func_group = olua.newhash()
    for _, fn in ipairs(cls.funcs) do
        local arr = func_group[fn.name]
        if not arr then
            arr = {}
            func_group[fn.name] = arr
        end
        if writer.is_new_func(module, cls.supercls, fn) then
            arr.has_new = true
        else
            fn = setmetatable({
                func = '@using ' .. fn.func
            }, {__index = fn})
        end
        arr[#arr + 1] = fn
    end

    for _, arr in ipairs(func_group) do
        if not arr.has_new then
            goto continue
        end
        local funcs = olua.newarray("', '", "'", "'")
        local has_callback = false
        local fn = arr[1]
        for _, v in ipairs(arr) do
            if v.cb_kind or cls.callbacks[v.name] then
                has_callback = true
            end
            funcs[#funcs + 1] = v.func
        end

        if #arr == 1 then
            local name = writer.to_prop_name(fn)
            if name then
                local setname = 'set' .. name:lower()
                local lessone, moreone
                for _, f in ipairs(cls.funcs) do
                    if f.name:lower() == setname then
                        if f.min_args <= 1 then
                            lessone = true
                        end
                        if f.min_args > 1 then
                            moreone = true
                        end
                    end
                end
                if lessone or not moreone then
                    cls.props[name] = {name = name}
                end
            end
        end
        if not has_callback then
            if #funcs > 0 then
                append(format(".func(nil, ${funcs})", 4))
            else
                append(format(".func('${fn.name}', ${fn.snippet?})", 4))
            end
        else
            local tag_maker = fn.name:gsub('^set', ''):gsub('^get', '')
            local mode = fn.cb_kind == 'ret' and 'subequal' or 'replace'
            local callback = cls.callbacks[fn.name]
            if callback then
                callback.funcs = funcs
                callback.tag_maker = callback.tag_maker or format('${tag_maker}')
                callback.tag_mode = callback.tag_mode or mode
            else
                cls.callbacks[fn.name] = {
                    name = fn.name,
                    funcs = funcs,
                    tag_maker = olua.format '${tag_maker}',
                    tag_mode = mode,
                }
            end
        end

        ::continue::
    end
end

function writer.write_cls_ifdef(module, cls, append)
    for _, v in ipairs(cls.ifdefs) do
        append(format([[.ifdef('${v.name}', '${v.value}')]], 4))
    end
end

function writer.write_cls_const(module, cls, append)
    for _, v in ipairs(cls.consts) do
        append(format([[.const('${v.name}', '${cls.cppcls}::${v.name}', '${v.typename}')]], 4))
    end
end

function writer.write_cls_enum(module, cls, append)
    for _, e in ipairs(cls.enums) do
        append(format(".enum('${e.name}', '${e.value}')", 4))
    end
end

function writer.write_cls_var(module, cls, append)
    for _, fn in ipairs(cls.vars) do
        append(format(".var('${fn.name}', ${fn.snippet?})", 4))
    end
end

function writer.write_cls_prop(module, cls, append)
    for _, p in ipairs(cls.props) do
        append(format([[.prop('${p.name}', ${p.get?}, ${p.set?})]], 4))
    end
end

function writer.write_cls_callback(module, cls, append)
    for i, v in ipairs(cls.callbacks) do
        assert(v.funcs, cls.cppcls .. '::' .. v.name)
        local funcs = olua.newarray("',\n'", "'", "'"):merge(v.funcs)
        local tag_maker = olua.newarray("', '", "'", "'")
        local tag_mode = olua.newarray("', '", "'", "'")
        local tag_store = v.tag_store or '0'
        local tag_scope = v.tag_scope or 'object'
        if type(v.tag_store) == 'string' then
            tag_store = olua.stringify(v.tag_store)
        end
        assert(v.tag_maker, 'no tag maker')
        assert(v.tag_mode, 'no tag mode')
        if type(v.tag_maker) == 'string' then
            tag_maker:push(v.tag_maker)
        else
            tag_maker:merge(v.tag_maker)
            tag_maker = format('{${tag_maker}}')
        end
        if type(v.tag_mode) == 'string' then
            tag_mode:push(v.tag_mode)
        else
            tag_mode:merge(v.tag_mode)
            tag_mode = format('{${tag_mode}}')
        end
        append(format([[
            .callback {
                funcs =  {
                    ${funcs}
                },
                tag_maker = ${tag_maker},
                tag_mode = ${tag_mode},
                tag_store = ${tag_store},
                tag_scope = '${tag_scope}',
            }
        ]], 4))
        writer.log(format([[
            funcs => name = '${v.name}'
                    funcs = {
                        ${funcs}
                    }
                    tag_maker = ${tag_maker}
                    tag_mode = ${tag_mode}
                    tag_store = ${tag_store}
                    tag_scope = ${tag_scope}
        ]], 4))
    end
end

function writer.write_cls_insert(module, cls, append)
    for _, v in ipairs(cls.inserts) do
        append(format([[
            .insert('${v.name}', {
                before = ${v.before?},
                after = ${v.after?},
                cbefore = ${v.cbefore?},
                cafter = ${v.cafter?},
            })
        ]], 4))
    end
end

function writer.write_cls_alias(module, cls, append)
    for _, v in ipairs(cls.aliases) do
        append(format(".alias('${v.name}', '${v.alias}')", 4))
    end
end

function writer.write_classes(module, append)
    append('')
    for _, cls in ipairs(module.class_types) do
        if (has_kflag(cls, kFLAG_CONV) and not has_kflag(cls, kFLAG_POINTEE))
            or has_kflag(cls, kFLAG_ALIAS)
        then
            goto continue
        end

        writer.log("[%s]", cls.cppcls)
        append(format([[
            typeconf '${cls.cppcls}'
                .supercls(${cls.supercls?})
                .reg_luatype(${cls.reg_luatype?})
                .chunk(${cls.chunk?})
                .luaopen(${cls.luaopen?})
        ]]))

        writer.write_cls_ifdef(module, cls, append)
        writer.write_cls_const(module, cls, append)
        writer.write_cls_func(module, cls, append)
        writer.write_cls_enum(module, cls, append)
        writer.write_cls_var(module, cls, append)
        writer.write_cls_callback(module, cls, append)
        writer.write_cls_prop(module, cls, append)
        writer.write_cls_insert(module, cls, append)
        writer.write_cls_alias(module, cls, append)

        append('')

        ::continue::
    end
end

function writer.log(fmt, ...)
    logfile:write(string.format(fmt, ...))
    logfile:write('\n')
end

function writer.write_module(module)
    local t = olua.newarray('\n')

    local function append(str)
        t:push(str)
    end

    append(format([[
        -- AUTO BUILD, DON'T MODIFY!

        dofile "${module.type_file}"
    ]]))
    append('')

    writer.write_metadata(module, append)
    writer.write_classes(module, append)
    writer.write_typedef(module, append)

    olua.write(module.class_file, tostring(t))
end

function writer.__gc()
    if not next(module_files) then
        return
    end
    local file = io.open('autobuild/autoconf-ignore.log', 'w')
    local arr = {}
    for cls, flag in pairs(ignored_types) do
        if flag then
            arr[#arr + 1] = cls
        end
    end
    table.sort(arr)
    for _, cls in pairs(arr) do
        file:write(string.format("[ignore class] %s\n", cls))
    end

    local types = olua.newarray('\n')
    for cppcls, v in pairs(alias_types) do
        if visited_types[cppcls] then
            goto continue
        end
        if v:find('^enum ') then
            types:push({
                cppcls = cppcls,
                decltype = 'lua_Unsigned',
                conv = 'olua_$$_uint',
            })
        elseif type(type_convs[v]) == 'string' then
            types:push({
                cppcls = cppcls,
                decltype = cppcls,
                conv = type_convs[v],
            })
        end
        ::continue::
    end
    local typedefs = olua.newarray('\n')
    for i, v in ipairs(olua.sort(types, 'cppcls')) do
        typedefs:pushf([[
            typedef {
                cppcls = '${v.cppcls}',
                decltype = '${v.decltype}',
                conv = '${v.conv}',
            }
        ]])
        typedefs:push('')
    end

    olua.write('autobuild/alias-types.lua', format([[
        ${typedefs}
    ]]))

    local files = olua.newarray('\n')
    local type_files = olua.newarray('\n')
    type_files:push('dofile "autobuild/alias-types.lua"')
    for _, v in ipairs(module_files) do
        files:pushf('export "${v.class_file}"')
        type_files:pushf('dofile "${v.type_file}"')
    end
    olua.write('autobuild/make.lua', format([[
        ${type_files}
        ${files}
    ]]))
end
setmetatable(writer, writer)

-------------------------------------------------------------------------------
-- define config module
-------------------------------------------------------------------------------
local function checkstr(key, v)
    if type(v) ~= 'string' then
        error(string.format("command '%s' expect 'string', got '%s'", key, type(v)))
    end
    return v
end

local function tonum(key, v)
    return tonumber(v)
end

local function checkfunc(key, v)
    if type(v) ~= 'function' then
        error(string.format("command '%s' expect 'function', got '%s'", key, type(v)))
    end
    return v
end

local function totable(key, v)
    return type(v) == 'table' and v or nil
end

local function tobool(key, v)
    if v == 'true' then
        return true
    elseif v == 'false' then
        return false
    end
end

local function toany(...)
    local funcs = {...}
    return function (key, ...)
        for _, f in ipairs(funcs) do
            local v = f(key, ...)
            if v ~= nil then
                return v
            end
        end
        return checkstr(key, ...)
    end
end

local function add_value_command(CMD, key, store, field, tofunc)
    tofunc = tofunc or checkstr
    field = field or key
    CMD[key] = function (v)
        store[field] = tofunc(key, v)
    end
end

local function make_typeconf_command(cls)
    local CMD = {}
    local ifdef = nil

    local function add_attr_command(cmd, name)
        local entry = {}
        cls.attrs[name] = entry
        add_value_command(cmd, 'optional', entry, nil, tobool)
        add_value_command(cmd, 'readonly', entry, nil, tobool)
        add_value_command(cmd, 'ret', entry)
        for i = 1, 25 do
            add_value_command(cmd, 'arg' .. i, entry)
        end
    end

    add_value_command(CMD, 'chunk', cls)
    add_value_command(CMD, 'luaname', cls, nil, checkfunc)
    add_value_command(CMD, 'supercls', cls)
    add_value_command(CMD, 'luaopen', cls)

    function CMD.exclude(name)
        name = checkstr('exclude', name)
        cls.excludes[name] = true
    end

    function CMD.ifdef(cond)
        cond = checkstr('ifdef', cond)
         if string.find(cond, '^defined%(') then
            ifdef = '#if ' .. cond
        elseif string.find(cond, '^#if') then
            ifdef = cond
        else
            ifdef = '#ifdef ' .. cond
        end
    end

    function CMD.endif()
        ifdef = nil
    end

    function CMD.enum(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('enum', name)
        cls.enums[name] = entry
        add_value_command(SubCMD, 'value', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.const(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('const', name)
        cls.consts[name] = entry
        add_value_command(SubCMD, 'value', entry)
        add_value_command(SubCMD, 'typename', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.func(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('func', name)
        cls.excludes[name] = true
        if ifdef then
            cls.ifdefs[name] = {name = name, value = ifdef}
        end
        cls.funcs[name] = entry
        add_value_command(SubCMD, 'snippet', entry)
        add_attr_command(SubCMD, name)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.callback(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('callback', name)
        cls.callbacks[name] = entry
        add_value_command(SubCMD, 'localvar', entry, nil, tobool)
        add_value_command(SubCMD, 'tag_maker', entry, nil, toany(totable))
        add_value_command(SubCMD, 'tag_mode', entry, nil, toany(totable))
        add_value_command(SubCMD, 'tag_store', entry, nil, tonum)
        add_value_command(SubCMD, 'tag_scope', entry, nil)
        add_attr_command(SubCMD, name)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.prop(name)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('prop', name)
        cls.props[name] = entry
        add_value_command(SubCMD, 'get', entry)
        add_value_command(SubCMD, 'set', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.var(name, snippet)
        local entry = {name = name}
        local SubCMD = {}
        name = checkstr('var', name)
        if name ~= '*' then
            cls.excludes[name] = true
            cls.vars[name] = entry
            add_value_command(SubCMD, 'snippet', entry)
        else
            name = 'var*'
        end
        add_attr_command(SubCMD, name)
        return olua.command_proxy(SubCMD, CMD)
    end

    function CMD.alias(value)
        local name, alias = string.match(value, '([^ ]+) *-> *([^ ]+)')
        assert(name, value)
        cls.aliases[name] = {name = name, alias = alias}
    end

    function CMD.insert(names)
        local entry = {}
        local SubCMD = {}
        names = type(names) == 'string' and {names} or names
        for _, n in ipairs(names) do
            n = checkstr('insert', n)
            cls.inserts[n] = setmetatable({name = n}, {__index = entry})
        end
        add_value_command(SubCMD, 'before', entry)
        add_value_command(SubCMD, 'after', entry)
        add_value_command(SubCMD, 'cbefore', entry)
        add_value_command(SubCMD, 'cafter', entry)
        return olua.command_proxy(SubCMD, CMD)
    end

    return olua.command_proxy(CMD)
end

local function make_typedef_command(cls)
    local CMD = {}
    add_value_command(CMD, 'vars', cls, 'num_vars', tonum)
    add_value_command(CMD, 'decltype', cls)
    add_value_command(CMD, 'conv', cls)
    return olua.command_proxy(CMD)
end

--
-- module conf
-- autoconf 'conf/lua-exmpale.lua'
--
function M.__call(_, path)
    local ifdef = nil
    local m = {
        class_types = olua.newhash(),
        exclude_types = {},
        typedef_types = olua.newhash(),
        luacls = function (cppname)
            return string.gsub(cppname, "::", ".")
        end,
    }
    local CMD = {}

    add_value_command(CMD, 'module', m, 'name')
    add_value_command(CMD, 'path', m)
    add_value_command(CMD, 'luaopen', m)
    add_value_command(CMD, 'headers', m)
    add_value_command(CMD, 'chunk', m)
    add_value_command(CMD, 'luacls', m, nil, checkfunc)

    function CMD.exclude(tn)
        m.exclude_types[tn] = true
    end

    function CMD.include(filepath)
        assert(loadfile(filepath, nil, CMD))()
    end

    function CMD.ifdef(cond)
        if string.find(cond, '^defined%(') then
            ifdef = '#if ' .. cond
        elseif string.find(cond, '^#if') then
            ifdef = cond
        else
            ifdef = '#ifdef ' .. cond
        end
    end

    function CMD.endif(cond)
        ifdef = nil
    end

    function CMD.typeconf(classname, kind)
        local cls = {
            cppcls = assert(classname, 'not specify classname'),
            luacls = m.luacls(classname),
            excludes = olua.newhash(),
            usings = olua.newhash(),
            attrs = olua.newhash(),
            enums = olua.newhash(),
            consts = olua.newhash(),
            funcs = olua.newhash(),
            callbacks = olua.newhash(),
            props = olua.newhash(),
            vars = olua.newhash(),
            aliases = olua.newhash(),
            inserts = olua.newhash(),
            ifdefs = olua.newhash(),
            index = #m.class_types + 1,
            kind = kind,
            reg_luatype = true,
            luaname = function (n) return n end,
        }
        local last = m.class_types[classname]
        if last then
            if last.kind == kind then
                assert(not m.class_types[classname], 'class conflict: ' .. classname)
            else
                if kind == kFLAG_CONV then
                    cls = last
                end
                if not cls.kind then
                    cls.kind = kFLAG_POINTEE
                end
                cls.kind = cls.kind | kFLAG_CONV
                m.class_types:take(classname)
            end
        end
        m.class_types[classname] = cls
        if ifdef then
            cls.ifdefs['*'] = {name = '*', value = ifdef}
        end
        return make_typeconf_command(cls)
    end

    function CMD.typeonly(classname)
        local cls = CMD.typeconf(classname)
        cls.exclude '*'
        return cls
    end

    function CMD.typedef(classname)
        local cls = {cppcls = classname}
        m.typedef_types[classname] = cls
        return make_typedef_command(cls)
    end

    function CMD.typeconv(classname)
        return CMD.typeconf(classname, kFLAG_CONV)
    end

    function CMD.clang(clang_args)
        local HEADER_PATH = 'autobuild/.autoconf.h'
        local header = io.open(HEADER_PATH, 'w')
        header:write(format [[
            #ifndef __AUTOCONF_H__
            #define __AUTOCONF_H__

            ${clang_args.headers}

            #endif
        ]])
        header:close()
        local has_target = false
        local flags = olua.newarray()
        for i, v in ipairs(clang_args.flags) do
            flags[#flags + 1] = v
            if v:find('^-target') then
                has_target = true
            end
        end
        if not has_target then
            flags:merge({
                '-x', 'c++', '-nostdinc', '-std=c++11',
                '-U__SSE__',
                '-DANDROID',
                '-target', 'armv7-none-linux-androideabi',
                '-idirafter', '${HOMEDIR}/include/c++',
                '-idirafter', '${HOMEDIR}/include/c',
                '-idirafter', '${HOMEDIR}/include/android-sysroot/x86_64-linux-android',
                '-idirafter', '${HOMEDIR}/include/android-sysroot',
            })
        end
        for i, v in ipairs(flags) do
            local HOMEDIR = olua.HOMEDIR
            flags[i] = format(v)
        end
        clang_tu = clang.createIndex(false, true):parse(HEADER_PATH, flags)
        for _, v in ipairs(clang_tu:diagnostics()) do
            if v.severity == 'error' or v.severity == 'fatal' then
                error('parse header error')
            end
        end
        os.remove(HEADER_PATH)

        m = nil
    end

    assert(loadfile(path, nil, setmetatable({}, {
        __index = function (_, k)
            return CMD[k] or _ENV[k]
        end,
        __newindex = function (_, k)
            error(string.format("create command '%s' is not available", k))
        end
    })))()

    if m then
        for _, cls in ipairs(m.class_types) do
            for fn, fi in pairs(cls.funcs) do
                if not fi.snippet then
                    cls.funcs:take(fn)
                    cls.excludes:take(fn)
                end
            end
        end
        for _, cls in ipairs(m.class_types) do
            for vn, vi in pairs(cls.vars) do
                if not vi.snippet then
                    cls.vars:take(vn)
                    cls.excludes:take(vn)
                end
            end
        end
        setmetatable(m, {__index = M})
        m:parse(path)
    end
end

local _dofile = dofile

function dofile(path, ...)
    if string.find(path, 'autobuild/make.lua$') then
        writer.__gc()
        module_files = {}
    end
    _dofile(path, ...)
end

olua.autoconf = setmetatable({}, M)
