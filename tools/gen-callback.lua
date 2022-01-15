local olua = require "olua"

local format = olua.format

local tag_mode_map = {
    new = 'OLUA_TAG_NEW',
    replace = 'OLUA_TAG_REPLACE',
    substartwith = 'OLUA_TAG_SUBSTARTWITH',
    subequal = 'OLUA_TAG_SUBEQUAL',
}

local function get_tag_mode(fi)
    local tag_mode = tag_mode_map[fi.callback.tag_mode]
    olua.assert(tag_mode, "unknown tag mode: %s", fi.callback.tag_mode)
    return tag_mode
end

local function get_tag_store(fi, idx)
    if not idx then
        idx = olua.assert(fi.callback.tag_store, 'no tag store')
    elseif idx < 0 then
        idx = idx + #fi.args + 1
    end
    if idx > 0 then
        olua.assert(idx <= #fi.args and idx >= 0, "store index '%d' out of range", idx)
    end
    return idx
end

local function check_tag_store(fi, idx)
    if idx > 0 then
        local ai = fi.args[idx]
        olua.assert(olua.is_pointer_type(ai.type), 'arg #%d is not a userdata', idx)
    end
end

local function gen_callback_tag(cls, fi)
    if not string.find(fi.callback.tag_maker, '[()]+') then
        return olua.stringify(fi.callback.tag_maker)
    end
    -- tag_maker: makeTag(#1) or makeTag(#-1)
    return string.gsub(fi.callback.tag_maker, '#(%-?%d+)', function (n)
        local idx = get_tag_store(fi, tonumber(n))
        return idx == 0 and 'self' or ('arg' .. idx)
    end)
end

local function gen_callback_store(cls, fi)
    local tag_store = get_tag_store(fi)
    local cb_store
    if tag_store > 0 then
        check_tag_store(fi, tag_store)
        cb_store = 'arg' .. tag_store
    elseif fi.static then
        cb_store = format 'olua_pushclassobj(L, "${cls.luacls}")'
    else
        cb_store = 'self'
    end
    return cb_store
end

local function gen_remove_callback(cls, fi)
    local tag_mode = get_tag_mode(fi)
    local cb_tag = gen_callback_tag(cls, fi)
    local cb_store = gen_callback_store(cls, fi)

    return format([[
        std::string cb_tag = ${cb_tag};
        void *cb_store = (void *)${cb_store};
        olua_removecallback(L, cb_store, cb_tag.c_str(), ${tag_mode});
    ]]), nil
end

local function gen_ret_callback(cls, fi)
    local tag_mode = get_tag_mode(fi)
    local cb_tag = gen_callback_tag(cls, fi)
    local cb_store = gen_callback_store(cls, fi)

    return format([[
        void *cb_store = (void *)${cb_store};
        std::string cb_tag = ${cb_tag};
        olua_getcallback(L, cb_store, cb_tag.c_str(), ${tag_mode});
    ]]), nil
end

function olua.gen_callback(cls, fi, arg, argn, codeset)
    if olua.is_func_type(fi.ret.type) then
        codeset.callback = gen_ret_callback(cls, fi)
        return
    elseif fi.callback.tag_mode == 'subequal' or
            fi.callback.tag_mode == 'substartwith' then
        codeset.callback = gen_remove_callback(cls, fi)
        return
    elseif not arg then
        return
    end

    olua.assert(fi.callback.tag_mode == 'replace' or fi.callback.tag_mode == 'new',
        "expect 'replace' or 'new', got '%s'", fi.callback.tag_mode)

    local argname = 'arg' .. argn
    local tag_mode = get_tag_mode(fi)
    local tag_store = get_tag_store(fi)
    local tag_scope = fi.callback.tag_scope
    local cb_tag = gen_callback_tag(cls, fi)
    local cb_store

    if not fi.static then
        argn = argn + 1 -- 1st is userdata(self)
    end

    -- c++: using Object::addEventListener;
    if fi.ret.attr.using then
        cb_tag = cb_tag .. ' + std::string(".using")'
    end

    local callbackset = {
        args = olua.newarray(', '),
        num_args = #arg.callback.args,
        push_args = olua.newarray(),
        remove_once_callback = "",
        remove_function_callback = "",
        remove_normal_callback = "",
        pop_objpool = "",
        decl_result = "",
        return_result = "",
        check_result = "",
        insert_cbefore = olua.newarray():push(fi.insert.cbefore),
        insert_cafter = olua.newarray():push(fi.insert.cafter),
    }

    local pool_enabled = false
    if arg.attr.localvar then
        for _, v in ipairs(arg.callback.args) do
            if not olua.is_value_type(v.type) then
                pool_enabled = true
            end
        end
    end

    if pool_enabled then
        callbackset.push_args:push( "size_t last = olua_push_objpool(L);")
        callbackset.push_args:push("olua_enable_objpool(L);")
        callbackset.pop_objpool = format([[
            //pop stack value
            olua_pop_objpool(L, last);
        ]])
    end

    for i, v in ipairs(arg.callback.args) do
        local cb_argname = 'arg' .. i
        local type_space = olua.typespace(v.rawdecl)
        olua.gen_push_exp(v, cb_argname, callbackset)
        callbackset.args:pushf([[
            ${v.rawdecl}${type_space}${cb_argname}
        ]])
    end

    if pool_enabled then
        callbackset.push_args:push("olua_disable_objpool(L);")
    end

    if tag_scope == 'once' then
        callbackset.remove_once_callback = format([[
            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);
        ]])
    elseif tag_scope == 'function' then
        callbackset.remove_function_callback = format([[
            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);
        ]])
    else
        olua.assert(tag_scope == 'object', tag_scope)
    end

    local callback_ret = arg.callback.ret
    if callback_ret.type.cppcls ~= "void" then
        local retset = {
            decl_args = olua.newarray(),
            check_args = olua.newarray(),
        }
        olua.gen_decl_exp(callback_ret, 'ret', retset)
        olua.gen_check_exp(callback_ret, 'ret', -1, retset)
        callbackset.decl_result = retset.decl_args
        callbackset.check_result = retset.check_args

        local func_is = olua.conv_func(callback_ret.type, 'is')
        if olua.is_pointer_type(callback_ret.type) then
            callbackset.check_result = format([[
                if (${func_is}(L, -1, "${callback_ret.type.luacls}")) {
                    ${callbackset.check_result}
                }
            ]])
        else
            callbackset.check_result = format([[
                if (${func_is}(L, -1)) {
                    ${callbackset.check_result}
                }
            ]])
        end
        callbackset.return_result = format([[return (${callback_ret.decltype})ret;]])
    end

    if tag_store == -1 then
        local post_push = fi.ctor and
            'olua_postnew(L, ret);' or
            'olua_postpush(L, ret, OLUA_OBJ_NEW);'
        local remove_callback = ''
        if tag_mode == 'OLUA_TAG_REPLACE' then
            remove_callback = 'olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_SUBEQUAL);'
        end
        cb_store = format 'olua_newobjstub(L, "${fi.ret.type.luacls}")'
        codeset.push_stub = format [[
            if (olua_pushobjstub(L, ret, cb_store, "${fi.ret.type.luacls}") == OLUA_OBJ_EXIST) {
                ${remove_callback}
                lua_pushstring(L, cb_name.c_str());
                lua_pushvalue(L, ${argn});
                olua_setvariable(L, -3);
            } else {
                ${post_push}
            }
        ]]
    elseif tag_store == 0 then
        cb_store = 'self'
        if (fi.static and fi.ret.type.cppcls == 'void') or tag_scope == 'function' then
            cb_store = format 'olua_pushclassobj(L, "${cls.luacls}")'
        end
    elseif tag_store > 0 then
        cb_store = 'arg' .. tag_store
        check_tag_store(fi, tag_store)
    else
        olua.error('invalid tag store: %s', tag_store)
    end

    if #callbackset.insert_cbefore > 0 then
        callbackset.insert_cbefore = format [[
            // insert code before call
            ${callbackset.insert_cbefore}
        ]]
    end

    if #callbackset.insert_cafter > 0 then
        callbackset.insert_cafter = format [[
            // insert code after call
            ${callbackset.insert_cafter}
        ]]
    end

    local callback_block = format([[
        lua_Integer cb_ctx = olua_context(L);
        ${argname} = [cb_store, cb_name, cb_ctx](${callbackset.args}) {
            lua_State *L = olua_mainthread(NULL);
            olua_checkhostthread();
            ${callbackset.decl_result}
            if (L != NULL && olua_context(L) == cb_ctx) {
                int top = lua_gettop(L);
                ${callbackset.push_args}

                ${callbackset.insert_cbefore}

                olua_callback(L, cb_store, cb_name.c_str(), ${callbackset.num_args});

                ${callbackset.check_result}

                ${callbackset.insert_cafter}

                ${callbackset.remove_once_callback}

                ${callbackset.pop_objpool}
                lua_settop(L, top);
            }
            ${callbackset.return_result}
        };
    ]])

    if arg.attr.optional or arg.attr.nullable then
        local func_is = olua.conv_func(arg.type, 'is')
        if tag_mode == 'OLUA_TAG_REPLACE' then
            callbackset.remove_normal_callback = format [[
                olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_SUBEQUAL);
            ]]
        end
        callback_block = format([[
            void *cb_store = (void *)${cb_store};
            std::string cb_tag = ${cb_tag};
            std::string cb_name;
            if (${func_is}(L, ${argn})) {
                cb_name = olua_setcallback(L, cb_store,  ${argn}, cb_tag.c_str(), ${tag_mode});
                ${callback_block}
            } else {
                ${callbackset.remove_normal_callback}
                ${argname} = nullptr;
            }
        ]])
    else
        callback_block = format([[
            void *cb_store = (void *)${cb_store};
            std::string cb_tag = ${cb_tag};
            std::string cb_name = olua_setcallback(L, cb_store,  ${argn}, cb_tag.c_str(), ${tag_mode});
            ${callback_block}
        ]])
    end

    codeset.callback = callback_block
    codeset.remove_function_callback = callbackset.remove_function_callback
end