local olua = require "olua"
local clang = require "clang"

os.execute('mkdir -p autobuild')

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

function M:parse(path)
    assert(not self.FILE_PATH)
    assert(not self.TYPE_FILE_PATH)
    local FILENAME = self.name:gsub('_', '-')
    self.FILE_PATH = format('autobuild/${FILENAME}.lua')
    self.TYPE_FILE_PATH = format('autobuild/${FILENAME}-types.lua')

    module_files:push(self)

    for cls in pairs(self.exclude_types) do
        ignored_types[cls] = false
    end

    local function toconv(cls)
        return 'olua_$$_' .. string.gsub(cls.cppcls, '::', '_')
    end

    for _, cls in ipairs(self.typedef_types) do
        cls.conv = cls.conv or toconv(cls)
        type_convs[cls.cppcls] = cls.conv
    end

    for _, cls in pairs(self.class_types) do
        type_convs[cls.cppcls] = cls.kind == 'conv' and toconv(cls) or true
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
                cls.kind = 'class'
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
            or self:has_unexposed_attr(cur) then
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

    local cbkind

    if cur.kind ~= 'Constructor' then
        local tn = self:typename(cur.resultType, cur)
        if self:is_func_type(tn) then
            cbkind = 'RET'
            if callback.nullable then
                exps:push('@nullable ')
            end
            if callback.localvar ~= false then
                exps:push('@local ')
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
        local DISPLAY_NAME = cur.displayName
        local argn = 'arg' .. i
        exps:push(i > 1 and ', ' or nil)
        declexps:push(i > 1 and ', ' or nil)
        declexps:push(tn)
        if self:is_func_type(tn) then
            if cbkind then
                error(format('has more than one std::function: ${cls.cppcls}::${DISPLAY_NAME}'))
            end
            assert(not cbkind, cls.cppcls .. '::' .. DISPLAY_NAME)
            cbkind = 'ARG'
            if callback.nullable then
                exps:push('@nullable ')
            end
            if callback.localvar ~= false then
                exps:push('@local ')
            end
        end
        if self:has_default_value(arg) and not string.find(attr[argn] or '', '@ret') then
            exps:push('@optional ')
            optional = true
        else
            min_args = min_args + 1
            assert(not optional, cls.cppcls .. '::' .. DISPLAY_NAME)
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
        cb_kind = cbkind,
        prototype = prototype,
    }
end

function M:visit_var(cls, cur)
    if cur.type.isConst or self:is_excluded_type(cur.type, cur) then
        return
    end

    local exps = olua.newarray('')
    local attr = cls.attrs[cur.name] or cls.attrs['*'] or {}
    local tn = self:typename(cur.type, cur)
    local cbkind

    local length = string.match(tn, '%[(%d+)%]$')
    if length then
        exps:pushf('@array(${length})')
        exps:push(' ')
        tn = string.gsub(tn, ' %[%d+%]$', '')
    elseif attr.optional or (self:has_default_value(cur) and attr.optional == nil) then
        exps:push('@optional ')
    end

    if self:is_func_type(tn) then
        cbkind = 'VAR'
        exps:push('@nullable ')
        local callback = cls.callbacks:take(cur.name) or {}
        if callback.localvar ~= false then
            exps:push('@local ')
        end
    end

    exps:push(attr.ret and (attr.ret .. ' ') or nil)
    exps:push(cur.kind == 'VarDecl' and 'static ' or nil)
    exps:push(tn)
    exps:push(olua.typespace(tn))
    exps:push(cur.name)

    local decl = tostring(exps)
    local name = cls.make_luaname(cur.name, 'VAR')
    cls.vars[name] = {
        name = name,
        snippet = decl,
        cb_kind = cbkind
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
        local VALUE =  c.name
        local name = cls.make_luaname(VALUE, 'ENUM')
        cls.enums[name] = {
            name = name,
            value = format('${cls.cppcls}::${VALUE}'),
        }
    end
    cls.kind = 'enum'
    alias_types[cls.cppcls] = nil
end

function M:visit_alias_class(cppcls, super)
    local cls = self:do_visit(cppcls)
    if self:is_func_type(super) then
        cls.kind = 'classFunc'
        cls.decltype = super
        cls.luacls = self.make_luacls(cppcls)
    else
        cls.kind = cls.kind or 'classAlias'
        cls.supercls = super
        cls.luacls = self.make_luacls(super)
    end
end

function M:visit_class(cppcls, cur)
    local cls = self:do_visit(cppcls)
    cls.kind = cls.kind or 'class'

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
            if (cls.excludes['*'] or cls.excludes[c.name] or cls.excludes[c.displayName]) or
                (kind == 'Constructor' and (cls.excludes['new'] or cur.isAbstract)) then
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
    elseif kind == 'ClassDecl' or kind == 'StructDecl' then
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
    elseif kind == 'TypeAliasDecl' then
        local ut = cur.underlyingType
        local name = self:typename(ut, cur)
        local isenum = ut.declaration.kind == 'EnumDecl'
        local alias = ((isenum and 'enum ' or '') .. name)
        alias_types[cls] = alias_types[name] or alias
        if need_visit then
            self:visit_alias_class(cls, alias_types[cls])
        end
    elseif kind == 'TypedefDecl' then
        local decl = cur.underlyingType.declaration
        local utk = decl.kind
        local name
        --[[
            namespace test {
                typedef enum TAG_ {
                } TAG
            }
            cur.underlyingType.name => enum TAG_
            cur.type.canonicalType.name => test::TAG_
        ]]
        if utk == 'StructDecl' or utk == 'EnumDecl' then
            name = self:typename(decl.type, decl)
        else
            name = self:typename(cur.underlyingType, decl)
        end

        local alias = ((utk == 'EnumDecl' and 'enum ' or '') .. name)
        alias_types[cls] = alias_types[name] or alias

        if need_visit then
            if utk == 'StructDecl' then
                self:visit_class(cls, decl)
            elseif utk == 'EnumDecl' then
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
        NAME = "${module.name}"
        PATH = "${module.path}"
    ]]))

    append(format('HEADERS = ${module.headers?}'))
    append(format('CHUNK = ${module.chunk?}'))
    append('')

    for _, cls in ipairs(module.class_types) do
        if cls.kind ~= "conv" then
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
    writeLine('local olua = require "olua"')
    writeLine('local typedef = olua.typedef')
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
            key = string.upper(key)
            writeLine(format('${key} = ${value?},', 4))
        end
        writeLine("}")
        writeLine("")
    end
    for _, cls in ipairs(module.class_types) do
        local conv
        local cppcls = cls.cppcls
        local decltype, luacls, num_vars = 'nil', 'nil', 'nil'
        if cls.kind == 'conv' then
            conv = 'olua_$$_' .. string.gsub(cls.cppcls, '[.:]+', '_')
            num_vars = #cls.vars
        elseif cls.kind == 'enum' then
            conv = 'olua_$$_uint'
            luacls = olua.stringify(cls.luacls, "'")
            decltype = olua.stringify('lua_Unsigned')
        elseif cls.kind == 'class' or cls.kind == 'classAlias' then
            cppcls = cppcls .. ' *'
            luacls = olua.stringify(cls.luacls, "'")
            conv = 'olua_$$_cppobj'
        elseif cls.kind == 'classFunc' then
            luacls = olua.stringify(cls.luacls, "'")
            decltype = olua.stringify(cls.decltype, "'")
            conv = 'olua_$$_' .. string.gsub(cls.cppcls, '[.:]+', '_')
        else
            error(cls.cppcls .. ' ' .. cls.kind)
        end

        t:pushf([[
            typedef {
                CPPCLS = '${cppcls}',
                LUACLS = ${luacls},
                DECLTYPE = ${decltype},
                CONV = '${conv}',
                NUM_VARS = ${num_vars},
            }
        ]])
        t:push('')
    end
    t:push('')
    olua.write(module.TYPE_FILE_PATH, tostring(t))
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
    if (string.find(fn.name, '^get') or string.find(fn.name, '^is')) and fn.num_args == 0 then
        -- getABCd isAbc => ABCd Abc
        local name = string.gsub(fn.name, '^%l+', '')
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
            local tag = fn.name:gsub('^set', ''):gsub('^get', '')
            local mode = fn.cb_kind == 'RET' and 'OLUA_TAG_SUBEQUAL' or 'OLUA_TAG_REPLACE'
            local callback = cls.callbacks[fn.name]
            if callback then
                callback.funcs = funcs
                callback.tag_maker = callback.tag_maker or format('${tag}')
                callback.tag_mode = callback.tag_mode or mode
            else
                cls.callbacks[fn.name] = {
                    name = fn.name,
                    funcs = funcs,
                    tag_maker = olua.format '${tag}',
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
        local tag_store = v.tag_store or 'nil'
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
                FUNCS =  {
                    ${funcs}
                },
                TAG_MAKER = ${tag_maker},
                TAG_MODE = ${tag_mode},
                TAG_STORE = ${tag_store},
                TAG_SCOPE = '${tag_scope}',
            }
        ]], 4))
        writer.log(format([[
            FUNC => NAME = '${v.name}'
                    FUNCS = {
                        ${funcs}
                    }
                    TAG_MAKER = ${tag_maker}
                    TAG_MODE = ${tag_mode}
                    TAG_STORE = ${tag_store}
                    TAG_SCOPE = ${tag_scope}
        ]], 4))
    end
end

function writer.write_cls_insert(module, cls, append)
    for _, v in ipairs(cls.inserts) do
        append(format([[
            .insert('${v.name}', {
                BEFORE = ${v.codes.before?},
                AFTER = ${v.codes.after?},
                CALLBACK_BEFORE = ${v.codes.callback_before?},
                CALLBACK_AFTER = ${v.codes.callback_after?},
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
        if cls.kind ~= 'class' and cls.kind ~= 'enum' and cls.kind ~= 'classFunc' then
            goto continue
        end

        writer.log("[%s]", cls.cppcls)
        append(format([[
            typeconf '${cls.cppcls}'
                .supercls(${cls.supercls?})
                .reg_luatype(${cls.reg_luatype?})
                .chunk(${cls.chunk?})
                .require(${cls.require?})
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

        dofile "${module.TYPE_FILE_PATH}"
    ]]))
    append('')

    writer.write_metadata(module, append)
    writer.write_classes(module, append)
    writer.write_typedef(module, append)

    olua.write(module.FILE_PATH, tostring(t))
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
    local TYPEDEFS = olua.newarray('\n')
    for i, v in ipairs(olua.sort(types, 'cppcls')) do
        TYPEDEFS:pushf([[
            typedef {
                CPPCLS = '${v.cppcls}',
                DECLTYPE = '${v.decltype}',
                CONV = '${v.conv}',
            }
        ]])
        TYPEDEFS:push('')
    end

    olua.write('autobuild/alias-types.lua', format([[
        local olua = require "olua"
        local typedef = olua.typedef

        ${TYPEDEFS}
    ]]))

    local files = olua.newarray('\n')
    local type_files = olua.newarray('\n')
    type_files:push('dofile "autobuild/alias-types.lua"')
    for _, v in ipairs(module_files) do
        files:pushf('export "${v.FILE_PATH}"')
        type_files:pushf('dofile "${v.TYPE_FILE_PATH}"')
    end
    olua.write('autobuild/make.lua', format([[
        local olua = require "olua"
        local export = olua.export
        local typedef = olua.typedef

        ${type_files}

        ${files}
    ]]))
end
setmetatable(writer, writer)

-------------------------------------------------------------------------------
-- define config module
-------------------------------------------------------------------------------
local function add_typeconf_command(cls)
    local CMD = {}

    function CMD.kind(kind)
        cls.kind = kind
    end

    function CMD.chunk(chunk)
        cls.chunk = chunk
    end

    function CMD.make_luaname(func)
        cls.make_luaname = func
    end

    function CMD.supercls(supercls)
        cls.supercls = supercls
    end

    function CMD.require(codes)
        cls.require = codes
    end

    function CMD.exclude(name)
        cls.excludes[name] = true
    end

    function CMD.ifdef(name, value)
        cls.ifdefs[name] = {name = name, value = value}
    end

    function CMD.attr(name, attr)
        cls.attrs[name] = attr
    end

    function CMD.enum(name, value)
        cls.enums[name] = {name = name, value = value}
    end

    function CMD.const(name, value, typename)
        cls.consts[name] = {name = name, value = value, typename = typename}
    end
    
    function CMD.func(fn, snippet)
        cls.excludes[fn] = true
        cls.funcs[fn] = {name = fn, snippet = snippet}
    end

    function CMD.callback(cb)
        if not cb.name then
            cb.name = olua.func_name(cb.funcs[1])
            cls.excludes[cb.name] = true
        end
        assert(#cb.name > 0, 'no callback function name')
        cls.callbacks[cb.name] = cb
    end

    function CMD.prop(name, get, set)
        cls.props[name] = {name = name, get = get, set = set}
    end

    function CMD.var(name, snippet)
        local varname = olua.func_name(snippet)
        assert(#varname > 0, 'no variable name')
        cls.excludes[varname] = true
        cls.vars[name or varname] = {name = name, snippet = snippet}
    end
    
    function CMD.alias(name, alias)
        cls.aliases[name] = {name = name, alias = alias}
    end

    function CMD.insert(names, codes)
        names = type(names) == 'string' and {names} or names
        for _, n in ipairs(names) do
            cls.inserts[n] = {name = n, codes = codes}
        end
    end

    return olua.make_command(CMD)
end

local function add_typedef_command(cls)
    local CMD = {}

    local conv = {
        ['bool'] = 'olua_$$_bool',
        ['const char *'] = 'olua_$$_string',
        ['lua_Integer'] = 'olua_$$_int',
        ['lua_Number'] = 'olua_$$_number',
        ['lua_Unsigned'] = 'olua_$$_uint',
        ['std::map'] = 'olua_$$_std_map',
        ['std::set'] = 'olua_$$_std_set',
        ['std::string'] = 'olua_$$_std_string',
        ['std::unordered_map'] = 'olua_$$_std_unordered_map',
        ['std::vector'] = 'olua_$$_std_vector',
        ['void *'] = 'olua_$$_obj',
    }

    function CMD.vars(n)
        cls.num_vars = tonumber(n)
        return CMD
    end

    function CMD.decltype(dt)
        cls.decltype = dt
        cls.conv = conv[dt]
        return CMD
    end

    function CMD.conv(fn)
        cls.conv = fn
        return CMD
    end

    return CMD
end

function M.__call(_, path)
    local index = 1
    local ifdef = nil
    local m = {
        class_types = olua.newhash(),
        exclude_types = {},
        typedef_types = olua.newhash(),
        make_luacls = function (cppname)
            return string.gsub(cppname, "::", ".")
        end,
    }
    local CMD = {}

    function CMD.__index(_, k)
        return _ENV[k]
    end

    function CMD.__newindex(_, k, v)
        m[k] = v
    end

    function CMD.module(name)
        m.name = name
    end

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

    function CMD.typeconf(classname)
        local cls = {
            cppcls = assert(classname, 'not specify classname'),
            luacls = m.make_luacls(classname),
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
            index = index,
            reg_luatype = true,
            make_luaname = function (n) return n end,
        }
        index = index + 1
        assert(not m.class_types[classname], 'class conflict: ' .. classname)
        m.class_types[classname] = cls
        if ifdef then
            cls.ifdefs['*'] = {name = '*', value = ifdef}
        end
        return add_typeconf_command(cls)
    end

    function CMD.typeonly(classname)
        local cls = CMD.typeconf(classname)
        cls.exclude '*'
        return cls
    end

    function CMD.typedef(classname)
        local cls = {cppcls = classname}
        m.typedef_types[classname] = cls
        return add_typedef_command(cls)
    end

    function CMD.typeconv(classname)
        local cls = CMD.typeconf(classname)
        cls.kind 'conv'
        return cls
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
            if v.text:find(' error:') then
                error('parse header error')
            end
        end
        os.remove(HEADER_PATH)

        m = nil
    end

    setmetatable(CMD, CMD)
    assert(loadfile(path, nil, CMD))()

    if m then
        setmetatable(m, {__index = M})
        m:parse(path)
    end
end

olua.autoconf = setmetatable({}, M)
