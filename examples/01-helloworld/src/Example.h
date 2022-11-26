#ifndef __EXAMPLE__
#define __EXAMPLE__

#include "Object.h"

#include <string>
#include <vector>

namespace example {

class ExportParent : public Object {
public:
    void printExportParent() {
        printf("printExportParent: %s\n", typeid(*this).name());
    }
};

class Hello : public ExportParent {
public:
    Hello() {
        printf("new '%s': %p\n", typeid(*this).name(), this);
    };

    void say();

    const std::string &getName() const;
    void setName(const std::string &value);

private:
    std::string _name;
};

}

#endif
