#ifndef __EXAMPLES_OBJECT__
#define __EXAMPLES_OBJECT__

#include <assert.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

namespace example {

#define ASSERT(e, msg) assert((e) && (msg))

class Object {
public:
    Object();
    virtual ~Object();

    void retain();
    void release();

    Object *autorelease();
    unsigned int getReferenceCount() const;

protected:
    unsigned int _referenceCount;
};

}

#endif