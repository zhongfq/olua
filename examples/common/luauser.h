#ifndef __LUAUSER_H__
#define __LUAUSER_H__

#include <stdbool.h>

#define OLUA_HAVE_MAINTHREAD
#define OLUA_HAVE_CHECKHOSTTHREAD
#define OLUA_HAVE_CMPREF
#define OLUA_HAVE_TRACEINVOKING
#define OLUA_HAVE_POSTPUSH
#define OLUA_HAVE_POSTNEW
//#define OLUA_HAVE_POSTGC
#define OLUA_HAVE_LUATYPE

#ifdef __cplusplus
extern "C" {
#endif
extern bool assert_script_compatible(const char *msg);
#ifdef __cplusplus
}
#endif

#define olua_assert(cond, msg) do {                         \
if (!(cond)) {                                              \
    if (!assert_script_compatible(msg) && strlen(msg))      \
      printf("assert failed: %s", msg);                     \
    assert((cond) && (msg));                                \
  }                                                         \
} while (0)

#ifdef __cplusplus

#include "Object.h"

template <class T>
void olua_insert_array(example::vector<T> *array, T value);

#endif // __cplusplus

#endif
