#ifndef __EXAMPLES_AUTORELEASE_POOL__
#define __EXAMPLES_AUTORELEASE_POOL__

#include "Object.h"

#include <vector>

namespace example {

class AutoreleasePool
{
public:
    static void addObject(Object *object);
    static void clear();
private:
    static std::vector<Object *> _objects;
};

}

#endif