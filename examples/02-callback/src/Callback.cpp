#include "Callback.h"

using namespace example;

void Callback::dispatch()
{
    Event event;
    event.name = "hello";
    event.data = "codetypes";
    printf("dispatch: %s\n", event.name.c_str());
    if (_onceListener) {
        _onceListener(&event);
    }
    if (_listener) {
        _listener(&event);
    }
}

void Callback::setOnceEvent(const Callback::Listener &callback)
{
    _onceListener = callback;
}

void Callback::setEvent(const Callback::Listener &callback)
{
    _listener = callback;
}