#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"
#include "olua-custom.h"

#include <string>
#include <vector>

using namespace std;

namespace example {


class Hello : public std::enable_shared_from_this<Hello> {
public:
    Hello() {
        printf("new '%s': %p\n", typeid(*this).name(), this);
    };
    
    ~Hello() {
        printf("del '%s': %p\n", typeid(*this).name(), this);
    }

    void say();

    const std::string &getName() const;
    void setName(const std::string &value);
    
    std::shared_ptr<Hello> getThis() {
        return std::shared_ptr<Hello>(this);
    }
    
    void setThis(const std::shared_ptr<Hello> &sp)
    {
        printf("set this: %p %p\n", this, sp.get());
    }
private:
    std::string _name;
};

}

#endif
