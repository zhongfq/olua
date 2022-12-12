# olua (object lua)
olua is a lua binding library based on lua gc memory management mechanism, it design for c/c++ lua binding with code generation and providing lambda function binding support.

## Chinese Wiki
* [olua 设计与实现](https://codetypes.com/posts/5890848b/)
* [olua 导出工具使用](https://codetypes.com/posts/c505b168/)

## Use Case
* https://github.com/zhongfq/cocos-lua/tree/main/tools/lua-bindings
* https://github.com/zhongfq/lua-clang

# Usage
## Creation
Create a new directory to store the configuration and olua scripts:
```bash
tree -L 2 .
.
├── build.lua
├── conf
│   ├── clang-args.lua
│   └── lua-example.lua
└── olua -> git@github.com:zhongfq/olua.git
```

## Clang Options

`clang` options should be configured in the file `clang-args.lua`.
```lua
clang {
    '-DOLUA_DEBUG',
    '-DOLUA_AUTOCONF',
    '-Isrc',
    '-I../common',
    '-I../..',
}
```

## Type Config
In the `conf` directory, you can write configuration file per module.
```lua
module "example"

path "src"

headers [[
#include "Example.h"
#include "olua-custom.h"
]]

include "../common/lua-object.lua"

typeconf "example::Hello"

```

## Build Script
```lua build.lua
require "olua.tools"

OLUA_AUTO_EXPORT_PARENT = true

autoconf "conf/clang-args.lua"
autoconf "conf/lua-example.lua"
```

## Export
After configuring all the classes that need to be exported, you can execute the following command to export the bindings.
```bash
-- lua 5.3 or lua 5.4
lua build.lua
```