//
// AUTO BUILD, DON'T MODIFY!
//
#ifndef __AUTO_GEN_LUA_EXAMPLE_H__
#define __AUTO_GEN_LUA_EXAMPLE_H__

#include "Example.h"
#include "olua-custom.h"

OLUA_BEGIN_DECLS
OLUA_LIB int luaopen_example(lua_State *L);
OLUA_END_DECLS

// example::Point
OLUA_LIB void olua_pack_object(lua_State *L, int idx, example::Point *value);
OLUA_LIB int olua_unpack_object(lua_State *L, const example::Point *value);
OLUA_LIB bool olua_canpack_object(lua_State *L, int idx, const example::Point *);

#endif