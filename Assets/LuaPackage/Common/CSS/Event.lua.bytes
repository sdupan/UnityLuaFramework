
local Event = class("Event")

local EXPORTED_METHODS = {
    "AddEventListener",
    "DispatchEvent",
    "RemoveEventListener",
    "RemoveEventListenersByTag",
    "RemoveEventListenersByEvent",
    "RemoveAllEventListeners",
    "HasEventListener",
    "DumpAllEventListeners",
}

function Event:Init()
    self.target_ = nil
    self.listeners_ = {}
    self.nextListenerHandleIndex_ = 0
end

function Event:Bind(target)
    self:Init()
    CSS.SetMethods(target, self, EXPORTED_METHODS)
    self.target_ = target
end

function Event:UnBind(target)
    CSS.UnSetMethods(target, EXPORTED_METHODS)
    self:Init()
end

function Event:On(eventName, listener, tag)
    assert(type(eventName) == "string" and eventName ~= "", "Event:AddEventListener() - invalid eventName")
    eventName = string.upper(eventName)
    if self.listeners_[eventName] == nil then
        self.listeners_[eventName] = {}
    end

    self.nextListenerHandleIndex_ = self.nextListenerHandleIndex_ + 1
    local handle = tostring(self.nextListenerHandleIndex_)
    tag = tag or ""
    self.listeners_[eventName][handle] = {listener, tag}

    return self.target_, handle
end

Event.AddEventListener = Event.On

function Event:DispatchEvent(event)
    event.name = string.upper(tostring(event.name))
    local eventName = event.name

    if self.listeners_[eventName] == nil then return end
    event.target = self.target_
    event.stop_ = false
    event.stop = function(self)
        self.stop_ = true
    end

    --避免dispatch时候进行add or remove 操作
    local list = self.listeners_[eventName]
    for handle, listener in pairs(list) do
        -- listener[1] = listener
        -- listener[2] = tag
        event.tag = listener[2]
        listener[1](event)
        if event.stop_ then
            break
        end
    end

    return self.target_
end

function Event:RemoveEventListener(handleToRemove)
    for eventName, listenersForEvent in pairs(self.listeners_) do
        for handle, _ in pairs(listenersForEvent) do
            if handle == handleToRemove then
                listenersForEvent[handle] = nil
                return self.target_
            end
        end
    end

    return self.target_
end

function Event:RemoveEventListenersByTag(tagToRemove)
    for eventName, listenersForEvent in pairs(self.listeners_) do
        for handle, listener in pairs(listenersForEvent) do
            -- listener[1] = listener
            -- listener[2] = tag
            if listener[2] == tagToRemove then
                listenersForEvent[handle] = nil
            end
        end
    end

    return self.target_
end

function Event:RemoveEventListenersByEvent(eventName)
    self.listeners_[string.upper(eventName)] = nil
    return self.target_
end

function Event:RemoveAllEventListeners()
    self.listeners_ = {}
    return self.target_
end

function Event:HasEventListener(eventName)
    eventName = string.upper(tostring(eventName))
    local t = self.listeners_[eventName]
    for _, __ in pairs(t) do
        return true
    end
    return false
end

function Event:DumpAllEventListeners()
    print("---- Event:DumpAllEventListeners() ----")
    for name, listeners in pairs(self.listeners_) do
        printf("-- event: %s", name)
        for handle, listener in pairs(listeners) do
            printf("--     listener: %s, handle: %s", tostring(listener[1]), tostring(handle))
        end
    end
    return self.target_
end

return Event
