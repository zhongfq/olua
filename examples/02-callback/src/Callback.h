#ifndef __EXAMPLES_CALLBACK__
#define __EXAMPLES_CALLBACK__

#include "Object.h"

#include <string>
#include <functional>

namespace example {

struct Event {
    std::string name;
    std::string data;
};

class Callback : public Object {
public:
    typedef std::function<void (const Event *)> Listener;

    Callback() {};

    void dispatch();
    void setOnceEvent(const Listener &callback);
    void setEvent(const Listener &callback);
private:
    Listener _onceListener;
    Listener _listener;
};

}

#endif