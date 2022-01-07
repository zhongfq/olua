#ifndef __LUAUSER_H__
#define __LUAUSER_H__

#define OLUA_HAVE_MAINTHREAD
#define OLUA_HAVE_CHECKHOSTTHREAD
#define OLUA_HAVE_CMPREF
#define OLUA_HAVE_TRACEINVOKING
#define OLUA_HAVE_POSTPUSH
#define OLUA_HAVE_POSTNEW
//#define OLUA_HAVE_POSTGC
#define OLUA_HAVE_LUATYPE

#ifdef __cplusplus

#include "Object.h"

template <class T>
void olua_insert_array(example::vector<T> *array, T value);

template <class T>
void olua_foreach_array(const example::vector<T> *array, const std::function<void(T)> &callback);

#endif // __cplusplus

#endif
