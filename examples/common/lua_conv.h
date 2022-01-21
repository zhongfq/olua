#ifndef __EXAMPLES_CONV__
#define __EXAMPLES_CONV__

#include "Object.h"

// example::vector
template <class T>
void olua_insert_array(example::vector<T> *array, T value)
{
    array->push_back(value);
}

#endif
