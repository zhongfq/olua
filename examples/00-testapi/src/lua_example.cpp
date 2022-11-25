//
// AUTO BUILD, DON'T MODIFY!
//
#include "lua_example.h"
#include "Example.h"
#include "olua-custom.h"

static int _example_Object___gc(lua_State *L)
{
    olua_startinvoke(L);

    olua_endinvoke(L);

    return olua_objgc(L);
}

static int _example_Object___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Object *)olua_toobj(L, 1, "example.Object");
    olua_push_object(L, self, "example.Object");

    olua_endinvoke(L);

    return 1;
}

static int _example_Object_autorelease(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_object(L, 1, &self, "example.Object");

    // example::Object *autorelease()
    example::Object *ret = self->autorelease();
    int num_ret = olua_push_object(L, ret, "example.Object");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_getReferenceCount(lua_State *L)
{
    olua_startinvoke(L);

    example::Object *self = nullptr;

    olua_to_object(L, 1, &self, "example.Object");

    // unsigned int getReferenceCount()
    unsigned int ret = self->getReferenceCount();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Object_new(lua_State *L)
{
    olua_startinvoke(L);

    // Object()
    example::Object *ret = new example::Object();
    int num_ret = olua_push_object(L, ret, "example.Object");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Object(lua_State *L)
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
OLUA_END_DECLS

static int _example_ExportParent_printExportParent(lua_State *L)
{
    olua_startinvoke(L);

    example::ExportParent *self = nullptr;

    olua_to_object(L, 1, &self, "example.ExportParent");

    // void printExportParent()
    self->printExportParent();

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ExportParent(lua_State *L)
{
    oluacls_class(L, "example.ExportParent", "example.Object");
    oluacls_func(L, "printExportParent", _example_ExportParent_printExportParent);

    olua_registerluatype<example::ExportParent>(L, "example.ExportParent");

    return 1;
}
OLUA_END_DECLS

static int _example_ClickCallback___call(lua_State *L)
{
    olua_startinvoke(L);

    luaL_checktype(L, -1, LUA_TFUNCTION);
    olua_push_callback(L, (example::ClickCallback *)nullptr, "example.ClickCallback");

    olua_endinvoke(L);

    return 1;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_ClickCallback(lua_State *L)
{
    oluacls_class(L, "example.ClickCallback", nullptr);
    oluacls_func(L, "__call", _example_ClickCallback___call);

    olua_registerluatype<example::ClickCallback>(L, "example.ClickCallback");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Type(lua_State *L)
{
    oluacls_class(L, "example.Type", nullptr);
    oluacls_func(L, "__index", olua_indexerror);
    oluacls_func(L, "__newindex", olua_newindexerror);
    oluacls_const_integer(L, "POINTEE", (lua_Integer)example::Type::POINTEE);
    oluacls_const_integer(L, "VALUE", (lua_Integer)example::Type::VALUE);

    olua_registerluatype<example::Type>(L, "example.Type");

    return 1;
}
OLUA_END_DECLS

static int _example_Point___gc(lua_State *L)
{
    olua_startinvoke(L);

    olua_postgc<example::Point>(L, 1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Point___olua_move(lua_State *L)
{
    olua_startinvoke(L);

    auto self = (example::Point *)olua_toobj(L, 1, "example.Point");
    olua_push_object(L, self, "example.Point");

    olua_endinvoke(L);

    return 1;
}

static int _example_Point_length(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // float length()
    float ret = self->length();
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new$1(lua_State *L)
{
    olua_startinvoke(L);

    // Point()
    example::Point *ret = new example::Point();
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new$2(lua_State *L)
{
    olua_startinvoke(L);

    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_check_number(L, 1, &arg1);
    olua_check_number(L, 2, &arg2);

    // Point(float x, float y)
    example::Point *ret = new example::Point(arg1, arg2);
    int num_ret = olua_push_object(L, ret, "example.Point");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_new(lua_State *L)
{
    int num_args = lua_gettop(L);

    if (num_args == 0) {
        // Point()
        return _example_Point_new$1(L);
    }

    if (num_args == 2) {
        // if ((olua_is_number(L, 1)) && (olua_is_number(L, 2))) {
            // Point(float x, float y)
            return _example_Point_new$2(L);
        // }
    }

    luaL_error(L, "method 'example::Point::new' not support '%d' arguments", num_args);

    return 0;
}

static int _example_Point_get_x(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // @optional float x
    float ret = self->x;
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_set_x(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** x */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // @optional float x
    self->x = arg1;

    olua_endinvoke(L);

    return 0;
}

static int _example_Point_get_y(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;

    olua_to_object(L, 1, &self, "example.Point");

    // @optional float y
    float ret = self->y;
    int num_ret = olua_push_number(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Point_set_y(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    float arg1 = 0;       /** y */

    olua_to_object(L, 1, &self, "example.Point");
    olua_check_number(L, 2, &arg1);

    // @optional float y
    self->y = arg1;

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Point(lua_State *L)
{
    oluacls_class(L, "example.Point", nullptr);
    oluacls_func(L, "__gc", _example_Point___gc);
    oluacls_func(L, "__olua_move", _example_Point___olua_move);
    oluacls_func(L, "length", _example_Point_length);
    oluacls_func(L, "new", _example_Point_new);
    oluacls_prop(L, "x", _example_Point_get_x, _example_Point_set_x);
    oluacls_prop(L, "y", _example_Point_get_y, _example_Point_set_y);

    olua_registerluatype<example::Point>(L, "example.Point");

    return 1;
}
OLUA_END_DECLS

static int _example_Hello_getCGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // const GLchar *getCGLchar()
    const GLchar *ret = self->getCGLchar();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getCName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // const char *getCName()
    const char *ret = self->getCName();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getCStrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<const char *> getCStrs()
    std::vector<const char *> ret = self->getCStrs();
    int num_ret = olua_push_array<const char *>(L, &ret, [L](const char *arg1) {
        olua_push_string(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // GLchar *getGLchar()
    GLchar *ret = self->getGLchar();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getGLvoid(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // GLvoid *getGLvoid()
    GLvoid *ret = self->getGLvoid();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getID(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // int getID()
    int ret = self->getID();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getIntPtrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<short *> getIntPtrs()
    std::vector<short *> ret = self->getIntPtrs();
    int num_ret = olua_push_array<short *>(L, &ret, [L](short *arg1) {
        olua_push_pointer(L, arg1, "olua.short");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getInts(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<int64_t> getInts()
    std::vector<int64_t> ret = self->getInts();
    int num_ret = olua_push_array<int64_t>(L, &ret, [L](int64_t &arg1) {
        olua_push_integer(L, arg1);
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // const std::string &getName()
    const std::string &ret = self->getName();
    int num_ret = olua_push_string(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getPointers(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<example::Point *> getPointers()
    std::vector<example::Point *> ret = self->getPointers();
    int num_ret = olua_push_array<example::Point *>(L, &ret, [L](example::Point *arg1) {
        olua_push_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getPoints(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<example::Point> getPoints()
    std::vector<example::Point> ret = self->getPoints();
    int num_ret = olua_push_array<example::Point>(L, &ret, [L](example::Point &arg1) {
        olua_pushcopy_object(L, arg1, "example.Point");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // void *getPtr()
    void *ret = self->getPtr();
    int num_ret = olua_push_object(L, ret, "void *");

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getType(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // example::Type getType()
    example::Type ret = self->getType();
    int num_ret = olua_push_integer(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_getVoids(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;

    olua_to_object(L, 1, &self, "example.Hello");

    // std::vector<GLvoid *> getVoids()
    std::vector<GLvoid *> ret = self->getVoids();
    int num_ret = olua_push_array<GLvoid *>(L, &ret, [L](GLvoid *arg1) {
        olua_push_object(L, arg1, "void *");
    });

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_new(lua_State *L)
{
    olua_startinvoke(L);

    // Hello()
    example::Hello *ret = new example::Hello();
    int num_ret = olua_push_object(L, ret, "example.Hello");
    olua_postnew(L, ret);

    olua_endinvoke(L);

    return num_ret;
}

static int _example_Hello_setCGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const GLchar *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setCGLchar(const GLchar *)
    self->setCGLchar(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setCName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    const char *arg1 = nullptr;       /** value */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setCName(const char *value)
    self->setCName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setCStrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<const char *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<const char *>(L, 2, &arg1, [L](const char **arg1) {
        olua_check_string(L, -1, arg1);
    });

    // void setCStrs(const std::vector<const char *> &v)
    self->setCStrs(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setCallback(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<int (example::Hello *)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "Callback";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        int ret = 0;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            if (olua_is_integer(L, -1)) {
                olua_check_integer(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // void setCallback(@localvar const std::function<int (example::Hello *)> &callback)
    self->setCallback(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setClick(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::ClickCallback arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "example.ClickCallback");

    void *cb_store = (void *)self;
    std::string cb_tag = "Click";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();

        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 1);

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
    };

    // void setClick(@localvar const example::ClickCallback &callback)
    self->setClick(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setGLchar(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLchar *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setGLchar(GLchar *)
    self->setGLchar(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setGLvoid(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    GLvoid *arg1 = nullptr;       /**  */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "void *");

    // void setGLvoid(GLvoid *)
    self->setGLvoid(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setID(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    int arg1 = 0;       /** id */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_integer(L, 2, &arg1);

    // void setID(int id)
    self->setID(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setIntPtrs(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<short *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<short *>(L, 2, &arg1, [L](short **arg1) {
        olua_check_pointer(L, -1, arg1, "olua.short");
    });

    // void setIntPtrs(const std::vector<short *> &v)
    self->setIntPtrs(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setInts(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<int64_t> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<int64_t>(L, 2, &arg1, [L](int64_t *arg1) {
        olua_check_integer(L, -1, arg1);
    });

    // void setInts(const std::vector<int64_t> &v)
    self->setInts(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setName(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::string arg1;       /** value */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_string(L, 2, &arg1);

    // void setName(const std::string &value)
    self->setName(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setNotify(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::function<std::string (example::Hello *, int)> arg1;       /** callback */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_callback(L, 2, &arg1, "std.function");

    void *cb_store = (void *)self;
    std::string cb_tag = "Notify";
    std::string cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
    olua_Context cb_ctx = olua_context(L);
    arg1 = [cb_store, cb_name, cb_ctx](example::Hello *arg1, int arg2) {
        lua_State *L = olua_mainthread(NULL);
        olua_checkhostthread();
        std::string ret;       /** ret */
        if (olua_contextequal(L, cb_ctx)) {
            int top = lua_gettop(L);
            size_t last = olua_push_objpool(L);
            olua_enable_objpool(L);
            olua_push_object(L, arg1, "example.Hello");
            olua_push_integer(L, arg2);
            olua_disable_objpool(L);

            olua_callback(L, cb_store, cb_name.c_str(), 2);

            if (olua_is_string(L, -1)) {
                olua_check_string(L, -1, &ret);
            }

            //pop stack value
            olua_pop_objpool(L, last);
            lua_settop(L, top);
        }
        return ret;
    };

    // void setNotify(@localvar const std::function<std::string (example::Hello *, int)> &callback)
    self->setNotify(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setPointers(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<example::Point *>(L, 2, &arg1, [L](example::Point **arg1) {
        olua_check_object(L, -1, arg1, "example.Point");
    });

    // void setPointers(const std::vector<example::Point *> &v)
    self->setPointers(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setPoints(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<example::Point> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<example::Point>(L, 2, &arg1, [L](example::Point *arg1) {
        olua_check_object(L, -1, arg1, "example.Point");
    });

    // void setPoints(const std::vector<example::Point> &v)
    self->setPoints(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setPtr(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    void *arg1 = nullptr;       /** p */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_object(L, 2, &arg1, "void *");

    // void setPtr(void *p)
    self->setPtr(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setType(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    example::Type arg1 = (example::Type)0;       /** t */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_integer(L, 2, &arg1);

    // void setType(example::Type t)
    self->setType(arg1);

    olua_endinvoke(L);

    return 0;
}

static int _example_Hello_setVoids(lua_State *L)
{
    olua_startinvoke(L);

    example::Hello *self = nullptr;
    std::vector<GLvoid *> arg1;       /** v */

    olua_to_object(L, 1, &self, "example.Hello");
    olua_check_array<GLvoid *>(L, 2, &arg1, [L](GLvoid **arg1) {
        olua_check_object(L, -1, arg1, "void *");
    });

    // void setVoids(const std::vector<GLvoid *> &v)
    self->setVoids(arg1);

    olua_endinvoke(L);

    return 0;
}

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example_Hello(lua_State *L)
{
    oluacls_class(L, "example.Hello", "example.ExportParent");
    oluacls_func(L, "getCGLchar", _example_Hello_getCGLchar);
    oluacls_func(L, "getCName", _example_Hello_getCName);
    oluacls_func(L, "getCStrs", _example_Hello_getCStrs);
    oluacls_func(L, "getGLchar", _example_Hello_getGLchar);
    oluacls_func(L, "getGLvoid", _example_Hello_getGLvoid);
    oluacls_func(L, "getID", _example_Hello_getID);
    oluacls_func(L, "getIntPtrs", _example_Hello_getIntPtrs);
    oluacls_func(L, "getInts", _example_Hello_getInts);
    oluacls_func(L, "getName", _example_Hello_getName);
    oluacls_func(L, "getPointers", _example_Hello_getPointers);
    oluacls_func(L, "getPoints", _example_Hello_getPoints);
    oluacls_func(L, "getPtr", _example_Hello_getPtr);
    oluacls_func(L, "getType", _example_Hello_getType);
    oluacls_func(L, "getVoids", _example_Hello_getVoids);
    oluacls_func(L, "new", _example_Hello_new);
    oluacls_func(L, "setCGLchar", _example_Hello_setCGLchar);
    oluacls_func(L, "setCName", _example_Hello_setCName);
    oluacls_func(L, "setCStrs", _example_Hello_setCStrs);
    oluacls_func(L, "setCallback", _example_Hello_setCallback);
    oluacls_func(L, "setClick", _example_Hello_setClick);
    oluacls_func(L, "setGLchar", _example_Hello_setGLchar);
    oluacls_func(L, "setGLvoid", _example_Hello_setGLvoid);
    oluacls_func(L, "setID", _example_Hello_setID);
    oluacls_func(L, "setIntPtrs", _example_Hello_setIntPtrs);
    oluacls_func(L, "setInts", _example_Hello_setInts);
    oluacls_func(L, "setName", _example_Hello_setName);
    oluacls_func(L, "setNotify", _example_Hello_setNotify);
    oluacls_func(L, "setPointers", _example_Hello_setPointers);
    oluacls_func(L, "setPoints", _example_Hello_setPoints);
    oluacls_func(L, "setPtr", _example_Hello_setPtr);
    oluacls_func(L, "setType", _example_Hello_setType);
    oluacls_func(L, "setVoids", _example_Hello_setVoids);
    oluacls_prop(L, "cName", _example_Hello_getCName, _example_Hello_setCName);
    oluacls_prop(L, "cStrs", _example_Hello_getCStrs, _example_Hello_setCStrs);
    oluacls_prop(L, "cgLchar", _example_Hello_getCGLchar, _example_Hello_setCGLchar);
    oluacls_prop(L, "gLchar", _example_Hello_getGLchar, _example_Hello_setGLchar);
    oluacls_prop(L, "gLvoid", _example_Hello_getGLvoid, _example_Hello_setGLvoid);
    oluacls_prop(L, "id", _example_Hello_getID, _example_Hello_setID);
    oluacls_prop(L, "intPtrs", _example_Hello_getIntPtrs, _example_Hello_setIntPtrs);
    oluacls_prop(L, "ints", _example_Hello_getInts, _example_Hello_setInts);
    oluacls_prop(L, "name", _example_Hello_getName, _example_Hello_setName);
    oluacls_prop(L, "pointers", _example_Hello_getPointers, _example_Hello_setPointers);
    oluacls_prop(L, "points", _example_Hello_getPoints, _example_Hello_setPoints);
    oluacls_prop(L, "ptr", _example_Hello_getPtr, _example_Hello_setPtr);
    oluacls_prop(L, "type", _example_Hello_getType, _example_Hello_setType);
    oluacls_prop(L, "voids", _example_Hello_getVoids, _example_Hello_setVoids);

    olua_registerluatype<example::Hello>(L, "example.Hello");

    return 1;
}
OLUA_END_DECLS

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, "example.Object", luaopen_example_Object);
    olua_require(L, "example.ExportParent", luaopen_example_ExportParent);
    olua_require(L, "example.ClickCallback", luaopen_example_ClickCallback);
    olua_require(L, "example.Type", luaopen_example_Type);
    olua_require(L, "example.Point", luaopen_example_Point);
    olua_require(L, "example.Hello", luaopen_example_Hello);

    return 0;
}
OLUA_END_DECLS
