#include "AutoreleasePool.h"

using namespace example;

std::vector<Object *> AutoreleasePool::_objects;

void AutoreleasePool::addObject(Object *object)
{
    _objects.push_back(object);
}

void AutoreleasePool::clear()
{
    std::vector<Object *> arr;
    arr.swap(_objects);
    for (const auto &obj : arr)
    {
        obj->release();
    }
}