---AUTO GENERATED, DO NOT MODIFY!
---@meta example.Singleton_example_Hello

---
---@class example.Singleton_example_Hello 
local Singleton_example_Hello = {}

---@return any
function Singleton_example_Hello:__gc() end

---@return example.Hello
function Singleton_example_Hello.create() end

---@return example.Singleton_example_Hello
function Singleton_example_Hello.new() end

function Singleton_example_Hello:printSingleton() end

return Singleton_example_Hello