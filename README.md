> olua 是一个基于代码生成的 lua 绑定库，能够生成 c++ 类、枚举、lambda 函数、运算符函数、实例化模版等的 lua 绑定代码，你可以对生成的细节做一些定制，比如在函数调用前后插入代码，生成带异常捕获的代码块，生成迭代器，生成 [lua 注释](https://luals.github.io)等等。

### 使用示例

- [clang](https://github.com/zhongfq/lua-clang)
- [cocoslua](https://github.com/zhongfq/cocos-lua)
- [c++17 filesystem](https://github.com/zhongfq/lua-filesystem)
- [openxlsx](https://github.com/zhongfq/lua-openxlsx)
- [pugixml](https://github.com/zhongfq/lua-pugixml)
- [luacmake](https://github.com/zhongfq/luacmake)

#### 创建

新建一个目录存放配置和 olua 脚本，结构如下：

```
tree -L 2 .
.
├── build.lua
└── olua -> git@github.com:zhongfq/olua.git

```

#### clang 参数配置

```lua
clang {
    '-DOLUA_DEBUG',
    '-Isrc',
    '-I../common',
    '-I../..',
}
```

#### 构建脚本

```lua
require "olua"

OLUA_AUTO_EXPORT_PARENT = true

clang {
    'std=c++17'
}

module "example"

output_dir "src"

headers [[
#include "Example.h"
#include "xlua.h"
]]

include "../common/lua-object.lua"

typeconf "example::Hello"
```

#### 生成

当配置好所以需要导出的类之后，就可以执行以下命令导出绑定。

```bash
lua build.lua
```

### 可选配置

可以在 `build.lua` 文件中，设置变量以调整扫描行为：

- `olua.AUTO_BUILD`：默认 `true`，扫描完成后，自动导出绑定代码。
- `olua.AUTO_GEN_PROP`：默认 `true`，是否自动为 `getName`、`isVisible` 生成 `name`、`visible` 属性。
- `olua.AUTO_EXPORT_PARENT`：默认 `false`，当没有用 `typeconf` 指定父类时，是否自动导出。
- `olua.ENABLE_DEPRECATED`：默认 `false`，是否导出已丢弃方法或变量。
- `olua.ENABLE_WITH_UNDERSCORE`：默认 `false`，是否导出以 `_` 开头的变量或方法。
- `olua.MAX_VARIADIC_ARGS`：默认 16，生成重载方法时，最多支持的参数个数。
- `olua.ENABLE_EXCEPTION`：默认 `false`，是否生成异常捕获代码。
- `olua.CAPTURE_MAINTHREAD`：默认 `false`，是否捕获 `L` 线程。
- `olua.PARSE_ALL_COMMENTS`：默认 `false`，是否解析所有注释。

### 配置指令

#### module

模块名称是由 `module` 指定的，也是构建导出文件名称的一部分。

```lua
module "example"
```

导出信息：

- 导出文件名称 `lua_example.h` 和 `lua_exmaple.cpp`
- 模块函数是 `luaopen_example`

#### output_dir

导出文件的目录是由 `output_dir` 指定的，可以是绝对路径，也可以相当路径。

```lua
output_dir '../../src'
```

#### headers

导出的头文件中的 `include` 部分是由 `headers` 指定的，这是保证编译成功的前置条件。

```lua
headers [[
#include "lua-bindings/lua_conv.h"
#include "lua-bindings/lua_conv_manual.h"
#include "cclua/xlua.h"
#include "Example.h"
]]
```

#### codeblock

模块中，如果需要引入手写代码，可以由 `codeblock` 指定，此代码原封不动拷贝至导出的文件中。

```lua
codeblock [[
static const std::string makeScheduleCallbackTag(const std::string &key)
{
    return "schedule." + key;
}]]
```

#### luaopen

在 `luaopen` 函数中，插入代码。

```lua
module 'example'

luaopen 'printf("hello luaopen!");'
```

```c++
static int luaopen_example(lua_State *L)
{
    olua_require(L, "Hello", luaopen_Hello);
    ...
    printf("hello luaopen!");
    return 1;
}
```

#### api_dir

指定 lua annotation `api` 生成的目录。

```lua
api_dir '../../addons/example'
```

#### entry

指定 `luaopen` 函数返回的类。

```lua
entry 'example::Hello'
```

```c++
OLUA_LIB int luaopen_example(lua_State *L)
{
    olua_require(L, ".olua.module.example",  _olua_module_example);
    if (!olua_getclass(L, "example.Hello")) {
        luaL_error(L, "class not found: example::Hello");
    }
    return 1;
}
```

#### exclude_type

指定不需要导出的类型，一旦排除了一个类型，那么包含此类型的方法和变量都将忽略。

```lua
-- exclude example::Command and example::Command *
exclude_type 'example::Command'

-- exclude example::Command * and example::Command **
exclude_type 'example::Command *'
```

#### import

如果要包含一个配置文件，可以使用 `import` 指令，比如引入 `lua-types.lua`。

```lua
import 'olua/lua-types.lua'
```

#### luacls

`lua` 类名的定制是由 `luacls` 指令实现的。

```lua
luacls(function (cppname)
    return string.gsub(cppname, "::", ".")
end)
```

#### macro

`macro` 一般用于条件编译。

```lua
macro '#ifdef CCLUA_BUILD_EXAMPLE'
typeconf "Object"
macro '#endif'
```

`Object` 所生成的代码都被 `CCLUA_BUILD_EXAMPLE` 包裹。

```c++
#ifdef CCLUA_BUILD_EXAMPLE
// Object 生成的代码
#endif
```

#### typedef

`typedef` 定义了一个类型，一般来说，你已经手动实现该类型的转换器，只是使用 `typedef` 将其关联。

##### 语法

```
typedef 'ClassName'
    [.luacls]
    [.conv]
    [.packable]
    [.packvars]
    [.smartptr]
    [.override]
    [.default]
    [.luatype]
    [.from_string]
    [.from_table]
```

##### 指令 .luacls

指定 lua 类名。

##### 指令 .conv

指定转换器，若未指定申明类型或未指定转换器，则默认是 `olua_$$_ClassName`。

##### 指令 .packable

指定此类型支持 `@pack` 和 `@unpack`。

##### 指令 .packvars

指定此类型由多少个成员变量组成。

##### 指令 .smartptr

指定类型是否为智能指针类型，如果是，会把 `std::shared_ptr<Node *>` 当作一个整体，而不是一个模版容器。

##### 指令 .override

替换已有的类型信息。

##### 指令 .default

指定默认值。

##### 指令 .luatype

指定 lua 类型。

##### 指令 .from_string

指定此类的构造函数是否支持字符串初始化，默认为 `false`。

```c++
static int _olua_fun_std_filesystem_ls$1(lua_State *L)
{
    try {
        olua_startinvoke(L);

        std::filesystem::path *arg1;       /** dir */
        std::filesystem::path arg1_from_string;       /** dir */
        bool arg2 = false;       /** recursive */

        if (olua_isstring(L, 1)) {
            olua_check_string(L, 1, &arg1_from_string);
            arg1 = &arg1_from_string;
        } else {
            olua_check_object(L, 1, &arg1, "fs.path");
        }
        olua_check_bool(L, 2, &arg2);

        // @extend(fs::fs_extend) static olua_Return ls(lua_State *L, std::filesystem::path dir, @optional bool recursive)
        olua_Return ret = fs::fs_extend::ls(L, *arg1, arg2);

        olua_endinvoke(L);

        return (int)ret;
    } catch (std::exception &e) {
        lua_pushfstring(L, "std::filesystem::ls(): %s", e.what());
        luaL_error(L, olua_tostring(L, -1));
        return 0;
    }
}
```

##### 指令 .from_table

指定此类的实例对象是否支持使用 table 来创建，默认为 `false`。

```c++
OLUA_LIB void olua_check_table(lua_State *L, int idx, example::Point *value)
{
    float arg1 = 0;       /** x */
    float arg2 = 0;       /** y */

    olua_getfield(L, idx, "x");
    olua_check_number(L, -1, &arg1);
    value->x = arg1;
    lua_pop(L, 1);

    olua_getfield(L, idx, "y");
    olua_check_number(L, -1, &arg2);
    value->y = arg2;
    lua_pop(L, 1);
}

static int _olua_fun_example_Point___add$1(lua_State *L)
{
    olua_startinvoke(L);

    example::Point *self = nullptr;
    example::Point *arg1;       /** p */
    example::Point arg1_from_table;       /** p */

    olua_to_object(L, 1, &self, "example.Point");
    if (olua_istable(L, 2)) {
        olua_check_table(L, 2, &arg1_from_table);
        arg1 = &arg1_from_table;
    } else {
        olua_check_object(L, 2, &arg1, "example.Point");
    }

    // @operator(operator+) example::Point operator+(const example::Point &p)
    example::Point ret = (*self) + (*arg1);
    int num_ret = olua_copy_object(L, ret, "example.Point");

    olua_endinvoke(L);

    return num_ret;
}
```

##### 示例

```lua
typedef 'example::vector'
typedef 'example::Color'
    .packable 'true'
    .packvars '4'
typedef 'Uint'
    .conv 'olua_$$_integer'
typedef 'Uint *'
    .conv 'olua_$$_array'
    .luacls 'olua.uint'
```

#### typeconf

`typeconf` 用于指定类或枚举的导出，包括类的静态方法、静态变量、对象方法、对像变量，但不包括模版函数。
同时会根据已经扫描到的信息，生成 `typedef` 信息，相当于：

```lua
// c++ 对象
typedef 'Object'
    .conv 'olua_$$_object'
    .luacls 'Object'

// 枚举
typedef 'Object'
    .conv 'olua_$$_enum'
    .luacls 'Object'
```

##### 语法

```
typeconf 'ClassName'
    [.codeblock]
    [.luaname]
    [.supercls]
    [.packable]
    [.packvars]
    [.luaopen]
    [.indexerror]
    [.from_string]
    [.from_table]
    [.exclude]
    [.include]
    [.macro]
    [.iterator]
        .once
    [.extend]
    [.var]
        .attr
        .index
        .tag_scope
        .tag_store
        .tag_maker
        .tag_mode
        .tag_usepool
        .insert_before
        .insert_after
        .insert_cbefore
        .insert_cafter
    [.func]
        .body
        [.luafn]
        [.tag_scope]
        [.tag_store]
        [.tag_maker]
        [.tag_mode]
        [.tag_usepool]
        [.insert_before]
        [.insert_after]
        [.insert_cbefore]
        [.insert_cafter]
        [.ret]
        [.arg1...N]
    [.prop]
        [.get]
        [.set]
```

##### 指令 .codeblock

导出手写代码。

```lua
typeconf 'Object'
    .codeblock [[
        static std::string makeForeachTag(int value)
        {
            return "foreach" + std::to_string(value);
        }
    ]]
```

##### 指令 .luaname

自定义方法或变量的 `lua` 名称。

```lua
typeconf 'Object'
    .luaname(function (name)
        if name == 'print' then
            name = 'dump'
        end
        return name
    end)
```

```c++
static int luaopen_Object(lua_State *L)
{
    oluacls_class<Object>(L, "Object");
    oluacls_func(L, "dump", _Hello_print);
    ...
    return 1;
}
```

##### 指令 .supercls

指定此类的父类名称，默认为 `nil`，由导出工具根据扫描信息而定。

```lua
typeconf 'Hello'
    .supercls 'Object'
```

##### 指令 .packable

指定此类支持 `@pack` 和 `@unpack` 标记，同时在导出时自动生成以下几个函数：

```C++
OLUA_LIB void olua_pack_object(lua_State *L, int idx, Object *value);
OLUA_LIB int olua_unpack_object(lua_State *L, const Object *value);
OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const Object *);
```

##### 指令 .packvars

指定此类型由多少个成员变量组成，一旦设置此变量，将不会自动生成上面三个函数，必须由使用者自己提供这三个函数。

##### 指令 .luaopen

在 `luaopen_Hello` 函数中，插入代码。

```lua
typeconf 'Hello'
    .luaopen 'printf("hello luaopen!");'
```

```c++
static int luaopen_Hello(lua_State *L)
{
    oluacls_class<Hello, Object>("Hello");
    ...
    printf("hello luaopen!");
    return 1;
}
```

##### 指令 .indexerror

指定类的可访问性

```lua
typeconf 'Object'
    .indexerror 'rw'
```

- `r` 访问不存的属性时抛出错误
- `w` 写入新的属性时抛出错误

##### 指令 .from_string

指定此类的构造函数是否支持字符串初始化，默认为 `false`。

```lua
typeconf "std::filesystem::path"
    .extend "fs::path_extend"
    .from_string "true"
    .iterator "std::filesystem::path::iterator"
```

##### 指令 .from_table

指定此类的实例对象是否支持使用 table 来创建，默认为 `false`。

##### 指令 .exclude

所有方法和变量默认导出，除了指定的。

```lua
typeconf 'Object'
    .exclude 'visible'
    .exclude 'retain'
```

`.exclude` 还支持通配符形式：「`.exclude '^m_.*'`」

##### 指令 .include

所有方法和变量默认不导出，除了指定的。

```lua
typeconf 'Object'
    .include 'visible'
    .include 'retain'
```

##### 指令 .macro

指定哪些方法需要根据宏来决定要不要编译。

```lua
typeconf 'Object'
    .macro '#ifdef CCLUA_OS_ANDROID'
    .func 'pay'
    .macro '#endif'
```

```c++
#ifdef CCLUA_OS_ANDROID
static _Object_pay(lua_State *L)
{
    ...
    return 0;
}
#endif

static int luaopen_Object(lua_State *L)
{
    oluacls_class<Object>(L, "Object");
#ifdef CCLUA_OS_ANDROID
    oluacls_func("pay", _Object_pay);
#endif
    ...
    printf("hello require!");
    return 1;
}
```

##### 指令 .iterator

生成迭代器。

```lua
typeconf "std::filesystem::path"
    .iterator "std::filesystem::path::iterator"
```

```c++
static int _olua_fun_std_filesystem_path___pairs(lua_State *L)
{
    try {
        olua_startinvoke(L);
        auto self = olua_toobj<std::filesystem::path>(L, 1);
        int ret = olua_pairs<std::filesystem::path, std::filesystem::path::iterator>(L, self, false);
        olua_endinvoke(L);
        return ret;
    } catch (std::exception &e) {
        lua_pushfstring(L, "std::filesystem::path::__pairs(): %s", e.what());
        luaL_error(L, olua_tostring(L, -1));
        return 0;
    }
}
```

##### 指令 .extend

扩展指定的类。

```lua
typeconf 'Object'
    .extend 'ObjectExtend'
```

把所有 `ObjectExtend` 的静态方法合并至 `Object` 中。

##### 指令 .var

定义一个变量。

`.ret` 和 `.arg1...N` 使用说明参见 [**参数标记**](#参数标记)

`.insert_before`、`.insert_after`、`.insert_cbefore`、和 `.insert_cafter` 使用说明参见 [**插入代码**](#插入代码)

`.tag_scope`、`.tag_store`、`.tag_maker`、`.tag_mode`、`.tag_usepool` 使用说明参见 [**回调函数配置**](#回调函数配置)

##### 指令 .func

定义方法。

```lua
typeconf 'Object'
    .func 'dump'
        .body [[
            printf("call dump!");
            return 0;
        ]]
```

```c++
...
static int _Object_dump(lua_State *L)
{
    printf("call dump!");
    return 0;
}
...

static int luaopen_Object(lua_State *L)
{
    oluacls_class<Object>(L, "Object");
    oluacls_func(L, "dump", _Object_dump);
    ...
    return 1;
}
```

`.ret` 和 `.arg1...N` 使用说明参见 [**参数标记**](#参数标记)

`.insert_before`、`.insert_after`、`.insert_cbefore`、和 `.insert_cafter` 使用说明参见 [**插入代码**](#插入代码)

`.tag_scope`、`.tag_store`、`.tag_maker`、`.tag_mode`、`.tag_usepool` 使用说明参见 [**回调函数配置**](#回调函数配置)

##### 指令 .prop

定义属性。

```lua
typeconf 'Object'
    .prop 'visible'
       .get 'bool isVisible()'
    .prop 'y'
        .get 'int getY()'
        .set 'void setY(int value)'
    .prop 'z'
        .get [[
            Object *obj = olua_toobj<Object>(L, 1);
            int ret = self->getZ();
            lua_pushinteger(L, ret);
            return 1;
        ]]
        .set [[
            Object *obj = olua_toobj<Object>(L, 1);
            int arg1 = (int)olua_checkinteger(L, 2);
            self->setZ(arg1);
            return 0;
        ]]
```

```c++
...
static int _Object_get_z(lua_State *L)
{
    Object *obj = olua_toobj<Object>(L, 1);
    int ret = self->getZ();
    lua_pushinteger(L, ret);
    return 1;
}
...

static int luaopen_Object(lua_State *L)
{
    oluacls_class<Object>(L, "Object");
    oluacls_prop(L, "visible", _Object_isVisible, NULL);
    oluacls_prop(L, "y", _Object_getY, _Object_setY);
    oluacls_prop(L, "z", _Object_get_z, _Object_set_z);
    ...
    return 1;
}
```

#### typeonly

只导出类型信息，不导出任何方法和变量，等价于：

```lua
typeconf 'Object'
    .exclude '*'
```

#### 插入代码

在导出插入代码，共有 4 个可以插入：

- `insert_before` 函数调用前。
- `insert_after` 函数调用后。
- `insert_cbefore` 回调函数调用前。
- `insert_cafter` 回调函数调用后。

```lua
typeconf 'Object'
    .func 'pay'
        .insert_before [[
            printf("hello before!");
        ]]
        .insert_after [[
            printf("hello after!");
        ]]
        .insert_cbefore [[
            printf("hello callback_before!");
        ]]
        .insert_cafter [[
            printf("hello callback_after!");
        ]]
```

```c++
static int _Object_pay(lua_State *L)
{
    ...
    printf("hello before!");
    self->pay([cb_store, cb_name, cb_ctx]() {
        ...
        printf("hello callback_before!");
        olua_callback(L, cb_store, cb_name.c_str(), 0);
        printf("hello callback_after!");
        ...
    });
    printf("hello after!");
    ...
    return 0;
}
```

#### 回调函数配置

定义 `std::function` 回调细节。回调函数实现参见：[olua 回调函数设计](https://codetypes.com/posts/5890848b/#回调函数)

```
typeconf 'Object'
    .func 'onClick'
        .tag_usepool 'true'
        .tag_mode 'replace|new|startwith|equal'
        .tag_store '0'
        .tag_maker 'click'
        .tag_scope 'object|once|invoker'
```

回调函数存储细节：

```
callback functions
obj.uservalue {
    |---id----|--class--|--tag--|
    .olua.cb#1$classname@onClick = lua_func
    .olua.cb#2$classname@onClick = lua_func
    .olua.cb#3$classname@update = lua_func
    .olua.cb#4$classname@onRemoved = lua_func
    ...
}
```

- `tag_usepool` 回调函数的参数是否使用[对象池](https://codetypes.com/posts/5890848b/#临时对象池)，默认值 `true`。
- `tag_mode` 标签匹配模式，如果回调函数作为参数，默认值为 `replace`；如果回调函数作为返回值，默认值为 `equal`。
  - `replace` 如果存在指定 `tag` 的回调函数，则替换，否则创建新 `tag` 存储回调函数。
  - `new` 始终创建新 `tag` 存储回调函数。
  - `startwith` 删除开头包含 `tag` 的回调函数。
  - `equal` 删除与 `tag` 相同的回调函数。
- `tag_store` 回调函数存储位置，默认值为 `0`，合法值有：
  - `0` 如果是静态方法，存储在 `.classobj` 中；如果对象方法，则存储在 `userdata` 中。
  - `-1` 存储在返回值中。
  - `1、2...N` 从左到右数，存储在第 `N` 个参数中。
- `tag_maker` 指定存储回调函数的键值，有两种形式：
  - `string` 纯字符串。
  - `makeTag(#N)`、`makeTag(#-N)`，将第 N 个参数作为参数调用 `makeTag` 生成键值。
- `tag_scope` 回调函数的生命周期，默认为 `object`，合法值有：
  - `object` 由对象管理。
  - `once` 调用一次就移除。
  - `invoker` 调用完底层函数后就移除.

```c++
static int _Object_onClick(lua_State *L)
{
    ...
    void *cb_store = (void *)self;
    std::string cb_tag = "click";
    std::string cb_name;
    if (olua_isfunction(L, 2)) {
        cb_name = olua_setcallback(L, cb_store,  2, cb_tag.c_str(), OLUA_TAG_REPLACE);
        olua_Context cb_ctx = olua_context(L);
        arg1 = [cb_store, cb_name, cb_ctx](Object *arg1) {
            lua_State *L = olua_mainthread(NULL);
            olua_checkhostthread();
            if (olua_contextequal(L, cb_ctx)) {
                int top = lua_gettop(L);
                size_t last = olua_push_objpool(L);
                olua_enable_objpool(L);
                olua_push_obj(L, arg1, "Object");
                olua_disable_objpool(L);
                olua_callback(L, cb_store, cb_name.c_str(), 1);
                olua_pop_objpool(L, last);
                lua_settop(L, top);
            }
        };
    } else {
        olua_removecallback(L, cb_store, cb_tag.c_str(), OLUA_TAG_equal);
        arg1 = nullptr;
    }

    // void onClick(@nullable const Object::ClickCallback &callback)
    self->onClick(arg1);

    return 0;
}
```

#### 参数标记

`.ret` 和 `.arg1...N` 都支持 `@` 关键字的标记，给参数添加更多的行为。

##### @postnew

标记返回值属于新创建，要使用 `olua_postnew`。

```lua
typeconf 'Object'
    .func 'create' .ret '@postnew'
```

```c++
static int _Object_create(lua_State *L)
{
    ...
    Object ret = Object::create()
    // insert code after call
    olua_postnew(L, ret);
    ...
    return 0;
}
```

##### @nullable

标记参数是否可以为 `nil`。

```lua
-- void onClick(const ClickCallback &callback);
typeconf 'Object'
    .func 'onClick' .arg1 '@nullable'
```

```c++
static int _Object_onClick(lua_State *L)
{
    if (olua_isfunction(L, 2) {
        arg1 = ...
    } else {
        arg1 = nullptr;
    }
    // void onClick(@nullable const ClickCallback &callback);
    self->onClick(arg1);
    return 0;
}
```

##### @addref

给参数添加使用引用标记：`@addref(name mode [where])`

`name` 引用名称。

`mode` 引用存储模式，有两种：

- `^` 独立存在。

  ```lua
  -- void setScene(Object *scene);
  typeconf 'Object'
      .func 'setScene' .arg1 '@addref(scene ^) @nullable'
  ```

  ```c++
  static int _Object_setScene(lua_State *L)
  {
      ...
      self->setScene(arg1);
      ...
      olua_addref(L, 1, "scene", -1, OLUA_REF_ALONE);
      ...
  }
  ```

- `|` 共存。

  ```lua
  -- void addChild(Object *child);
  typeconf 'Object'
      .func 'addChild' .arg1 '@addref(children |)' .ret '@delref(children ~)'
  ```

  ```c++
  static int _Object_addChild(lua_State *L)
  {
      ...
      olua_startcmpref(L, 1, "children");
      ...
      self->addChild(arg1);
      ...
      olua_addref(L, 1, "children", -1, OLUA_REF_MULTI);
      olua_endcmpref(L, 1, "children");
      ...
  }
  ```

`where` 引用存储的位置，如果提供此值，同时得使用插入代码，用于获取此值。

```lua
-- void show();
typeconf 'Object'
    .func 'show' .ret '@addref(children | parent)'
        .insert_before [[
            olua_pushobj<Object>(L, Object::getRoot());
            int parent = lua_gettop(L);
        ]]
```

```c++
static int _Object_show(lua_State *L)
{
    ...
    olua_pushobj<Object>(L, Object::getRoot());
    int parent = lua_gettop(L);
    self->show();
    ...
    olua_addref(L, parent, "children", 1, OLUA_REF_MULTI);
    ...
}
```

关于引用实现参见 [olua 引用链](https://codetypes.com/posts/5890848b/#引用链)

##### @delref

给参数添加移除引用标记：`@delref(name mode [where])`

`name` 引用名称。

`mode` 引用存储模式，有四种：

- `^` 独立存在。

  ```lua
  -- void setScene(Object *scene);
  typeconf 'Object'
      .func 'setScene' .arg1 '@delref(scene ^) @nullable'
  ```

  ```c++
  static int _Object_setScene(lua_State *L)
  {
      ...
      self->setScene(arg1);
      ...
      olua_delref(L, 1, "scene", -1, OLUA_REF_ALONE);
      ...
  }
  ```

- `|` 共存。

  ```lua
  -- void removeChild(Object *child);
  typeconf 'Object'
      .func 'removeChild' .arg1 '@addref(children |)'
  ```

  ```c++
  static int _Object_removeChild(lua_State *L)
  {
      ...
      self->removeChild(arg1);
      ...
      olua_delref(L, 1, "children", -1, OLUA_REF_MULTI);
      ...
  }
  ```

- `~` 生成使用比较移除引用的代码。

  ```lua
  -- void removeChildByName(const std::string &name);
  typeconf 'Object'
      .func 'removeChildByName' .ret '@delref(children ~)'
  ```

  ```c++
  static int _Object_removeChildByName(lua_State *L)
  {
      ...
      olua_startcmpref(L, 1, "children");
      ...
      self->removeChildByName(arg1);
      ...
      olua_endcmpref(L, 1, "children");
      ...
  }
  ```

- `*` 移除所有引用。

  ```lua
  -- void removeChildren();
  typeconf 'Object'
      .func 'removeChildren' .arg1 '@delref(children *)'
  ```

  ```c++
  static int _Object_removeChildren(lua_State *L)
  {
      ...
      self->removeChildren();
      ...
      olua_delallrefs(L, 1, "children");
      ...
  }
  ```

`where` 引用存储的位置，如果提供此值，同时得使用插入代码，用于获取此值。

```lua
-- void removeSelf();
typeconf 'Object'
    .func 'removeSelf' .ret '@delref(children | parent)'
        .insert_before [[
            if (!self->getParent()) {
                return 0;
            }
            olua_pushobj<Object>(L, self->getParent()));
            int parent = lua_gettop(L);
        ]]
```

```c++
static int _Object_removeSelf(lua_State *L)
{
    ...
    if (!self->getParent()) {
        return 0;
    }
    olua_pushobj<Object>(L, self->getParent()));
    int parent = lua_gettop(L);
    self->removeSelf();
    ...
    olua_delref(L, parent, "children", 1, OLUA_REF_MULTI);
    ...
}
```

关于引用实现参见 [olua 引用链](https://codetypes.com/posts/5890848b/#引用链)

##### @optional

标记参数是否可选，一般情况下用于 `.var` 命令，函数参数的 `@optional` 标记由自动扫描添加。

- 用于 `.var` 命令：

  ```lua
  typeconv 'Object'
      .var 'x' .optional 'true'
  ```

  ```c++
  void olua_check_Object(lua_State *L, int idx, Object *value)
  {
      ...
      int arg1 = 0;       /** x */
      ...
      olua_getfield(L, idx, "x");
      if (!olua_isnoneornil(L, -1)) {
          olua_check_integer(L, -1, &arg1);
          value->x = arg1;
      }
      lua_pop(L, 1);
      ...
  }
  ```

- 用于 `.func` 命令：

  ```lua
  -- 原型
  -- void play(bool loop = true);
  -- 扫描得到
  -- void play(@optional bool loop = true);
  -- 导出时转换为两个函数
  -- void play();
  -- void play(bool loop);

  typeconf 'Object'
  ```

  ```c++
  static _Object_play1(lua_State *L)
  {
      ...
      self->play();
      ...
  }

  static _Object_play2(lua_State *L)
  {
      ...
      self->play(arg1);
      ...
  }

  static _Object_play(lua_State *L)
  {
      if (num_args == 0) {
          reutrn _Object_play1(L);
      }
      if (num_args == 1) {
          reutrn _Object_play2(L);
      }
      luaL_error(L, "method 'Object::play' not support '%d' arguments", num_args);
      return 0;
  }
  ```

##### @pack

将多个参数打包一个值对象。

```lua
-- void setPosition(const Point &p);
-- Point convert(const Point &p);
typeconf 'Object'
    .func 'setPosition' .arg1 '@pack'
    .func 'convert' .arg1 '@pack'
```

```lua
local obj = Object.new()

obj:setPosition(1, 1)
obj:setPosition({x = 1, y = 1})

local p = obj:convert({x = 1, y = 1})
local x, y = obj:convert(1, 1)
```

##### @unpack

将值对象拆解为多个值。

```lua
-- const Point &getPosition();
typeconf 'Object'
    .func 'getPosition' .ret '@unpack'
```

```lua
local obj = Object.new()
local x, y = obj:getPosition()
```

##### @readonly

只读变量标记，用于 `.var` 命令。使用此标记后，只生成 `getter` 函数。

```lua
typeconf 'Object'
    .var 'id' .readonly 'true'
```

##### @type

类型替换，提供的类型必须是原类型的其它表现形式。

```C++
void read(char *buf, size_t *len);
```

正常情况下，`buf` 会被解析为字符串，使用的转换器是 `olua_$$_string`，但是这里可能是一个可写入的变量，这时就可以使用 `@type` 进行标记，以实现准确的意图。

```lua
-- typedef char olua_char_t;
-- typedef olua::pointer<olua_char_t> olua_char;
typeconf 'Object'
    .func 'read'
        .arg1 '@type(olua_char_t *)'
```

通过此配置，可以在生成代码时，使用 `olua_char_t *` 的转换器。

##### 头文件标注

可以直接使用宏命令对参数或方法进行标注，`autoconf` 脚本会在扫描阶段解析这些信息。

宏命令：

```c++
#define OLUA_EXCLUDE        __attribute__((annotate("@exclude")))
#define OLUA_TYPE(name)     __attribute__((annotate("@type("#name")")))
#define OLUA_NAME(name)     __attribute__((annotate("@name("#name")")))
#define OLUA_ADDREF(...)    __attribute__((annotate("@addref("#__VA_ARGS__")")))
#define OLUA_DEFREF(...)    __attribute__((annotate("@delref("#__VA_ARGS__")")))
#define OLUA_PACK           __attribute__((annotate("@pack")))
#define OLUA_UNPACK         __attribute__((annotate("@unpack")))
#define OLUA_NULLABLE       __attribute__((annotate("@nullable")))
#define OLUA_POSTNEW        __attribute__((annotate("@postnew")))
#define OLUA_READONLY       __attribute__((annotate("@readonly")))
#define OLUA_OPTIONAL       __attribute__((annotate("@optional")))
#define OLUA_GETTER         __attribute__((annotate("@getter")))
#define OLUA_SETTER         __attribute__((annotate("@setter")))
```

使用示例：

```c++
class Object {
public:
    static OLUA_POSTNEW Object *create();

    void setScene(OLUA_ADDREF(^) OLUA_NULLABLE Scene *v);
    OLUA_ADDREF(^) Scene *getScene();

    OLUA_ADDREF(root ^) Scene *getRoot();

    static int pushParent(lua_State *L) OLUA_EXCLUDE;
    OLUA_DELREF(children | ::pushParent) void removeFrameParent();

    void addChild(OLUA_ADDREF(children |) Object *child);
    OLUA_ADDREF(children |) Child getChildByName(const std::string &name);
    void removeChild(OLUA_DELREF(children |) Object *child);

    OLUA_EXCLUDE void update();

    Point localToGlobal(OLUA_PACK const Point &p);

    const char read(OLUA_RET size_t *len);

    OLUA_READONLY int id;

    void read(OLUA_TYPE(olua_char_t *) char *result, size_t *len)

    OLUA_GETTER OLUA_NAME(name) std::string getName();
    OLUA_SETTER OLUA_NAME(name) void setName(const std::string *);
}
```
