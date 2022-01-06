#include "Object.h"
#include "AutoreleasePool.h"

using namespace example;

Object::Object()
:_referenceCount(1)
{
    printf("new '%s': %p\n", typeid(*this).name(), this);
}

Object::~Object()
{
    printf("del '%s': %p\n", typeid(*this).name(), this);
}

void Object::retain()
{
    ASSERT(_referenceCount > 0, "reference count should be greater than 0");
    ++_referenceCount;
}

void Object::release()
{
    ASSERT(_referenceCount > 0, "reference count should be greater than 0");
    --_referenceCount;
    if (_referenceCount == 0)
    {
        delete this;
    }
}

Object* Object::autorelease()
{
    AutoreleasePool::addObject(this);
    return this;
}

unsigned int Object::getReferenceCount() const
{
    return _referenceCount;
}