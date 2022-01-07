#include "Example.h"

using namespace example;

void Hello::say()
{
    printf("hello %s\n", _name.c_str());
};

const std::string &Hello::getName() const
{
    return _name;
}

void Hello::setName(const std::string &value)
{
    _name = value;
}