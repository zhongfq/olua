//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"

static std::string makeForeachTag(int value)
{
    return "foreach" + std::to_string(value);
}

bool olua_is_example_Callback_Listener(lua_State *L, int idx)
{
    return olua_is_callback<example::Callback::Listener>(L, idx);
}

int olua_push_example_Callback_Listener(lua_State *L, const example::Callback::Listener *value)
{
    return olua_push_callback<example::Callback::Listener>(L, value);
}

void olua_check_example_Callback_Listener(lua_State *L, int idx, example::Callback::Listener *value)
{
    olua_check_callback<example::Callback::Listener>(L, idx, value);
}

static int _example_Object___gc(lua_State *L)
{
    olua_startinvoke(L);

    olua_endinvoke(L);

    return xlua_objgc(L);
}

static int _example_Object___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Object *)olua_toobj(L, 1, "example.Object");
    olua_push_cppobj(L, self, "example.Object");

    olua_endinvoke(L);

    return 1;
}

static int _example_Object_autorelease(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Object");

    // example::Object *autorelease()
    example::Object *ret = self->autorelease();
    int num_ret = olua_push_cppobj(L, ret, "example.Object");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_getReferenceCount(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Object");

    // unsigned int getReferenceCount()
    unsigned int ret = self->getReferenceCount();
    int num_ret = olua_push_uint(L, (lua_Unsigned)ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_new(lua_State *L)
{
    olua_startinvoke(L);

    // Object()
    example::Object *ret = new example::Object();
    int num_ret = olua_push_cppobj(L, ret, "example.Object");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int luaopen_example_Object(lua_State *L)
{
    oluacls_class(L, "example.Object", nullptr);
    oluacls_func(L, "__gc", _example_Object___gc);
    oluacls_func(L, "__olua_move", _example_Object___olua_move);
    oluacls_func(L, "autorelease", _example_Object_autorelease);
    oluacls_func(L, "getReferenceCount", _example_Object_getReferenceCount);
    oluacls_func(L, "new", _example_Object_new);
    oluacls_prop(L, "referenceCount", _example_Object_getReferenceCount, nullptr);

    olua_registerluatype<example::Object>(L, "example.Object");

    return 1;
}

static int _example_Event___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Event *)olua_toobj(L, 1, "example.Event");
    olua_push_cppobj(L, self, "example.Event");

    olua_endinvoke(L);

    return 1;
}

static int _example_Event_get_data(lua_State *L)
{
    olua_startinvoke(L);

    example::Event *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Event");

    // std::string data
    std::string ret = self->data;
    int num_ret = olua_push_std_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Event_set_data(lua_State *L)
{
    olua_startinvoke(L);

    example::Event *self = nullptr;
    std::string arg1;       /** data */

    olua_to_cppobj(L, 1, (void **)&self, "example.Event");
    olua_check_std_string(L, 2, &arg1);

    // std::string data
    self->data = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _example_Event_get_name(lua_State *L)
{
    olua_startinvoke(L);

    example::Event *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Event");

    // std::string name
    std::string ret = self->name;
    int num_ret = olua_push_std_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Event_set_name(lua_State *L)
{
    olua_startinvoke(L);

    example::Event *self = nullptr;
    std::string arg1;       /** name */

    olua_to_cppobj(L, 1, (void **)&self, "example.Event");
    olua_check_std_string(L, 2, &arg1);

    // std::string name
    self->name = arg1;

    olua_endinvoke(L);

    return 0;
}

static int luaopen_example_Event(lua_State *L)
{
    oluacls_class(L, "example.Event", nullptr);
    oluacls_func(L, "__olua_move", _example_Event___olua_move);
    oluacls_prop(L, "data", _example_Event_get_data, _example_Event_set_data);
    oluacls_prop(L, "name", _example_Event_get_name, _example_Event_set_name);

    olua_registerluatype<example::Event>(L, "example.Event");

    return 1;
}

static int _example_Callback_Listener___call(lua_State *L)
{
    olua_startinvoke(L);

    luaL_checktype(L, -1, LUA_TFUNCTION);
    olua_push_callback<example::Callback::Listener>(L, nullptr);

    olua_endinvoke(L);

    return 1;
}

static int luaopen_example_Callback_Listener(lua_State *L)
{
    oluacls_class(L, "example.Callback.Listener", nullptr);
    oluacls_func(L, "__call", _example_Callback_Listener___call);

    olua_registerluatype<example::Callback::Listener>(L, "example.Callback.Listener");

    return 1;
}

static int _example_Callback___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Callback *)olua_toobj(L, 1, "example.Callback");
    olua_push_cppobj(L, self, "example.Callback");

    olua_endinvoke(L);

    return 1;
}

static int _example_Callback_dispatch(lua_State *L)
{
    olua_startinvoke(L);

    example::Callback *self = nullptr;

    olua_to_cppobj(L, 1, (void **)&self, "example.Callback");

    // void dispatch()
    self->dispatch();

    olua_endinvoke(L);

    return 0;
}

static int _example_Callback_foreach(lua_State *L)
{
    olua_startinvoke(L);

    example::Callback *self = nullptr;
    lua_Integer arg1 = 0;       /** start */
    lua_Integer arg2 = 0;       /** to */
    std::function<void(int)> arg3;       /** callback */

    olua_to_cppobj(L, 1, (void **)&self, "example.Callback");
    olua_check_int(L, 2, &arg1);
    olua_check_int(L, 3, &arg2);
    olua_check_std_function(L, 4, &arg3);

    void *cb_store = (void *)olua_pushclassobj(L, "example.Callback");
    std::string cb_tag = makeForeachTag(arg1);
    std::string cb_name = olua_setcallback(L, cb_store,  4, cb_tag.c_str(), OLUA_TAG_NEW);
    lua_Integer cb_ctx = olua_context(L);
    arg3 = [cb_store, cb_name, cb_ctx](int arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (L != NULL && olua_context(L) == cb_ctx) {
            int top = lua_gettop(L);
            olua_push_int(L, (lua_Integer)arg1);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            lua_settop(L, top);
        }
    };

    // void foreach(int start, int to, @localvar const std::function<void (int)> &callback)
    self->foreach((int)arg1, (int)arg2, arg3);

    olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);

    olua_endinvoke(L);

    return 0;
}

static int _example_Callback_new(lua_State *L)
{
    olua_startinvoke(L);

    // Callback()
    example::Callback *ret = new example::Callback();
    int num_ret = olua_push_cppobj(L, ret, "example.Callback");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Callback_setEvent(lua_State *L)
{
    olua_startinvoke(L);

    example::Callback *self = nullptr;
    std::function<void(const example::Event *)> arg1;       /** callback */

    olua_to_cppobj(L, 1, (void **)&self, "example.Callback");
    olua_check_std_function(L, 2, &arg1);

    void *cb_store = (void *)self;
    std::string cb_tag = "Event";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    lua_Integer cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](const example::Event *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (L != NULL && olua_context(L) == cb_ctx) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_cppobj(L, arg1, "example.Event");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setEvent(@localvar const std::function<void (const Event *)> &callback)
    self->setEvent(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Callback_setOnceEvent(lua_State *L)
{
    olua_startinvoke(L);

    example::Callback *self = nullptr;
    example::Callback::Listener arg1;       /** callback */

    olua_to_cppobj(L, 1, (void **)&self, "example.Callback");
    olua_check_example_Callback_Listener(L, 2, &arg1);

    void *cb_store = (void *)self;
    std::string cb_tag = "OnceEvent";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    lua_Integer cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](const example::Event *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (L != NULL && olua_context(L) == cb_ctx) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_cppobj(L, arg1, "example.Event");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            olua_removecallback(L, cb_store, cb_name.c_str(), OLUA_TAG_WHOLE);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setOnceEvent(@localvar const example::Callback::Listener &callback)
    self->setOnceEvent(arg1);

    olua_endinvoke(L);

    return 0;
}

static int luaopen_example_Callback(lua_State *L)
{
    oluacls_class(L, "example.Callback", "example.Object");
    oluacls_func(L, "__olua_move", _example_Callback___olua_move);
    oluacls_func(L, "dispatch", _example_Callback_dispatch);
    oluacls_func(L, "foreach", _example_Callback_foreach);
    oluacls_func(L, "new", _example_Callback_new);
    oluacls_func(L, "setEvent", _example_Callback_setEvent);
    oluacls_func(L, "setOnceEvent", _example_Callback_setOnceEvent);

    olua_registerluatype<example::Callback>(L, "example.Callback");

    return 1;
}

int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.Event", luaopen_example_Event);
    olua_require(L, "example.Callback.Listener", luaopen_example_Callback_Listener);
    olua_require(L, "example.Callback", luaopen_example_Callback);
    return 0;
}
