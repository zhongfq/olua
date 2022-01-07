#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"

#include <string>

namespace example {

class Hello : public Object {
public:
    Hello() {};

    void say();

    const std::string &getName() const;
    void setName(const std::string &value);

private:
    std::string _name;
};

}

#endif