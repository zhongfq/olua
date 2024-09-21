local tag_mode_map = {
    new = "OLUA_TAG_NEW",
    replace = "OLUA_TAG_REPLACE",
    startwith = "OLUA_TAG_STARTWITH",
    equal = "OLUA_TAG_EQUAL",
}

---@param func idl.gen.func_desc
---@return string
local function get_tag_mode(func)
    local tag_mode = tag_mode_map[func.tag_mode]
    olua.assert(tag_mode, "unknown tag mode: ${func.tag_mode}")
    return tag_mode
end

---@param func idl.gen.func_desc
---@param idx integer|nil
---@return integer
local function get_tag_store(func, idx)
    if not idx then
        idx = olua.assert(func.tag_store, "no tag store") --[[@as integer]]
    elseif idx < 0 then
        idx = idx + #func.args + 1
    end
    if idx > 0 then
        olua.assert(idx <= #func.args and idx >= 0, "store index '${idx}' out of range")
    end
    return idx
end

---@param func idl.gen.func_desc
---@param idx integer
local function check_tag_store(func, idx)
    if idx > 0 then
        local ai = func.args[idx]
        olua.assert(olua.is_pointer_type(ai.type), "arg #${idx} is not a userdata")
    end
end

---@param func idl.gen.func_desc
---@return string
local function gen_callback_tag(func)
    if not string.find(func.tag_maker, "[()]+") then
        return olua.format([["${func.tag_maker}"]]), nil
    end
    -- tag_maker: makeTag(#1) or makeTag(#-1)
    return string.gsub(func.tag_maker, "#(%-?%d+)", function (n)
        local idx = get_tag_store(func, tonumber(n))
        return idx == 0 and "self" or ("arg" .. idx)
    end)
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@return string
local function gen_callback_store(cls, func)
    local tag_store = get_tag_store(func)
    local cb_store
    if tag_store > 0 then
        check_tag_store(func, tag_store)
        cb_store = "arg" .. tag_store
    elseif func.is_static then
        olua.use(cls)
        cb_store = olua.format 'olua_pushclassobj(L, "${cls.luacls}")'
    else
        cb_store = "self"
    end
    return cb_store
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@return string
local function gen_remove_callback(cls, func)
    local tag_mode = get_tag_mode(func)
    local cb_tag = gen_callback_tag(func)
    local cb_store = gen_callback_store(cls, func)
    olua.use(tag_mode, cb_tag, cb_store)
    return olua.format([[
        std::string cb_tag = ${cb_tag};
        void *cb_store = (void *)${cb_store};
        olua_removecallback(L, cb_store, cb_tag.c_str(), ${tag_mode});
    ]]), nil
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@return string
local function gen_ret_callback(cls, func)
    local tag_mode = get_tag_mode(func)
    local cb_tag = gen_callback_tag(func)
    local cb_store = gen_callback_store(cls, func)
    olua.use(tag_mode, cb_tag, cb_store)
    return olua.format([[
        void *cb_store = (void *)${cb_store};
        std::string cb_tag = ${cb_tag};
        olua_getcallback(L, cb_store, cb_tag.c_str(), ${tag_mode});
    ]]), nil
end

---@param cls idl.gen.class_desc
---@param func idl.gen.func_desc
---@param arg idl.gen.type_desc|nil
---@param idx integer|nil
---@param codeset idl.gen.func_codeset
function olua.gen_callback(cls, func, arg, idx, codeset)
    if olua.is_func_type(func.ret.type) then
        codeset.callback = gen_ret_callback(cls, func)
        return
    elseif func.tag_mode == "equal"
        or func.tag_mode == "startwith"
    then
        codeset.callback = gen_remove_callback(cls, func)
        return
    elseif not arg then
        return
    end

    olua.assert(func.tag_mode == "replace" or func.tag_mode == "new",
        "expect 'replace' or 'new', got '${func.callback.tag_mode}'")

    local arg_name = "arg" .. idx
    local tag_mode = get_tag_mode(func)
    local tag_store = get_tag_store(func)
    local tag_scope = func.tag_scope
    local cb_tag = gen_callback_tag(func)
    local cb_store

    if not func.is_static then
        idx = idx + 1 -- 1st is userdata(self)
    end

    -- c++: using Object::addEventListener;
    if func.ret.attr.using then
        cb_tag = cb_tag .. ' + std::string(".using")'
    end

    ---@class idl.gen.cb_codeset
    local cb_codeset = {
        args = olua.array(", "),
        num_args = #arg.type.callback.args,
        push_args = olua.array("\n"),
        remove_once_callback = "",
        remove_function_callback = "",
        remove_normal_callback = "",
        pop_objpool = "",
        decl_result = "",
        return_result = "",
        check_result = "",
        insert_cbefore = func.insert_cbefore or "",
        insert_cafter = func.insert_cafter or "",

        capture = {
            main_thread = "",
            use_main_thread = "",
            get_main_thread = "",
        }
    }

    local pool_enabled = false
    if func.tag_usepool then
        for _, v in ipairs(arg.type.callback.args) do
            if not olua.is_value_type(v.type) then
                pool_enabled = true
            end
        end
    end

    if pool_enabled then
        cb_codeset.push_args:push("size_t last = olua_push_objpool(L);")
        cb_codeset.push_args:push("olua_enable_objpool(L);")
        cb_codeset.pop_objpool = olua.format([[
            //pop stack value
            olua_pop_objpool(L, last);
        ]])
    end

    for i, v in ipairs(arg.type.callback.args) do
        local cb_argname = "cb_arg" .. i
        local decltype = olua.decltype(v.type, false, true)
        olua.gen_push_exp(v, cb_argname, cb_codeset)
        olua.use(decltype)
        cb_codeset.args:pushf([[
            ${decltype}${cb_argname}
        ]])
    end

    if pool_enabled then
        cb_codeset.push_args:push("olua_disable_objpool(L);")
    end

    if tag_scope == "once" then
        cb_codeset.remove_once_callback = olua.format([[
            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);
        ]])
    elseif tag_scope == "invoker" then
        cb_codeset.remove_function_callback = olua.format([[
            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);
        ]])
    else
        olua.assert(tag_scope == "object", tag_scope)
    end

    local callback_ret = arg.type.callback.ret
    if callback_ret.type.cxxcls ~= "void" then
        local retset = {
            decl_args = olua.array(""),
            check_args = olua.array(""),
        }
        olua.gen_decl_exp(callback_ret, "ret", retset)
        olua.gen_check_exp(callback_ret, "ret", -1, retset)
        cb_codeset.decl_result = tostring(retset.decl_args)
        cb_codeset.check_result = tostring(retset.check_args)

        local func_is = olua.conv_func(callback_ret.type, "is")
        olua.use(func_is)
        if olua.is_pointer_type(callback_ret.type) then
            cb_codeset.check_result = olua.format([[
                if (${func_is}(L, -1, "${callback_ret.type.luacls}")) {
                    ${cb_codeset.check_result}
                }
            ]])
        else
            cb_codeset.check_result = olua.format([[
                if (${func_is}(L, -1)) {
                    ${cb_codeset.check_result}
                }
            ]])
        end
        cb_codeset.return_result = olua.format([[return ret;]])
    end

    if tag_store == -1 then
        local post_push = func.is_contructor and
            "olua_postnew(L, ret);" or
            "olua_postpush(L, ret, OLUA_OBJ_NEW);"
        local remove_callback = ""
        if tag_mode == "OLUA_TAG_REPLACE" then
            remove_callback = "olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_EQUAL);"
        end
        cb_store = olua.format('olua_newobjstub(L, "${func.ret.type.luacls}")')
        olua.use(post_push, remove_callback, cb_store)
        codeset.push_stub = olua.format([[
            if (olua_pushobjstub(L, ret, cb_store, "${func.ret.type.luacls}") == OLUA_OBJ_EXIST) {
                ${remove_callback}
                lua_pushstring(L, cb_name.c_str());
                lua_pushvalue(L, ${idx});
                olua_setvariable(L, -3);
            } else {
                ${post_push}
            }
        ]])
    elseif tag_store == 0 then
        cb_store = "self"
        if not func.is_static or func.luafn == "new" and func.ret.type.cxxcls == cls.cxxcls then
            cb_store = "self"
        else
            cb_store = olua.format 'olua_pushclassobj(L, "${cls.luacls}")'
        end
    elseif tag_store > 0 then
        cb_store = "arg" .. tag_store
        check_tag_store(func, tag_store)
    else
        olua.error("invalid tag store: ${tag_store}")
    end

    if #cb_codeset.insert_cbefore > 0 then
        cb_codeset.insert_cbefore = olua.format [[
            // insert code before call
            ${cb_codeset.insert_cbefore}
        ]]
    end

    if #cb_codeset.insert_cafter > 0 then
        cb_codeset.insert_cafter = olua.format [[
            // insert code after call
            ${cb_codeset.insert_cafter}
        ]]
    end

    if olua.CAPTURE_MAINTHREAD then
        cb_codeset.capture.get_main_thread = "lua_State *ML = olua_mainthread(L);"
        cb_codeset.capture.main_thread = ", ML"
        cb_codeset.capture.use_main_thread = "lua_State *L = ML;"
    else
        cb_codeset.capture.get_main_thread = "// lua_State *ML = olua_mainthread(L);"
        cb_codeset.capture.main_thread = " /*, ML */"
        cb_codeset.capture.use_main_thread = "lua_State *L = olua_mainthread(NULL);"
    end

    local callback_block = olua.format([[
        olua_Context cb_ctx = olua_context(L);
        ${cb_codeset.capture.get_main_thread}
        ${arg_name} = [cb_store, cb_name, cb_ctx${cb_codeset.capture.main_thread}](${cb_codeset.args}) {
            ${cb_codeset.capture.use_main_thread}
            olua_checkhostthread();
            ${cb_codeset.decl_result}
            if (olua_contextequal(L, cb_ctx)) {
                int top = lua_gettop(L);
                ${cb_codeset.push_args}

                ${cb_codeset.insert_cbefore}

                olua_callback(L, cb_store, cb_name.c_str(), ${cb_codeset.num_args});

                ${cb_codeset.check_result}

                ${cb_codeset.insert_cafter}

                ${cb_codeset.remove_once_callback}

                ${cb_codeset.pop_objpool}
                lua_settop(L, top);
            }
            ${cb_codeset.return_result}
        };
    ]])

    if arg.attr.optional or arg.attr.nullable then
        if tag_mode == "OLUA_TAG_REPLACE" then
            cb_codeset.remove_normal_callback = olua.format [[
                olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_EQUAL);
            ]]
        end
        callback_block = olua.format([[
            void *cb_store = (void *)${cb_store};
            std::string cb_tag = ${cb_tag};
            std::string cb_name;
            if (olua_isfunction(L, ${idx})) {
                cb_name = olua_setcallback(L, cb_store, ${idx}, cb_tag.c_str(), ${tag_mode});
                ${callback_block}
            } else {
                ${cb_codeset.remove_normal_callback}
                ${arg_name} = nullptr;
            }
        ]])
    else
        callback_block = olua.format([[
            void *cb_store = (void *)${cb_store};
            std::string cb_tag = ${cb_tag};
            std::string cb_name = olua_setcallback(L, cb_store, ${idx}, cb_tag.c_str(), ${tag_mode});
            ${callback_block}
        ]])
    end

    codeset.callback = callback_block
    codeset.remove_function_callback = cb_codeset.remove_function_callback
end
