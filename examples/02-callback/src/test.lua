local olua = require "olua"
local Callback = require "example.Callback"

olua.debug(true)

local obj = Callback.new()
obj:setEvent(function (event)
    print('event', event, event.name, event.data)
end)
obj:setOnceEvent(function (event)
    print('onceEvent', event, event.name, event.data)
end)

print('----------------------------------')
obj:dispatch()
print('----------------------------------')
obj:dispatch()
print('----------------------------------')