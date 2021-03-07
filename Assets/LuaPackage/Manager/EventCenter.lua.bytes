local EventCenter = {}
CSS.Bind(EventCenter, "Event")

function GAME_DISPATCH_EVENT(eventName, dispatchData)
   -- dump(dispatchData, " 分发 "..eventName, 10)
   -- printLog("GAME_DISPATCH_LISTEN", "分发 %s", eventName)
    EventCenter:DispatchEvent(eventName, dispatchData)
end

function GAME_DISPATCH_LISTEN(eventName, listener)
    -- printLog("GAME_DISPATCH_LISTEN", "监听 %s", eventName)
    if listener == nil or type(listener) ~= "function" then return end
    EventCenter:ListenEvent(eventName, dispatchData)
end

function GAME_DISPATCH_REMOVE_LISTENER(listener)
    if listener == nil then return end
    EventCenter:DispatchRemove(listener)
    listener = nil
end
---这个会remove所有使用这个eventName的事件
function GAME_REMOVE_LISTENERS_BY_EVENT(eventName)
    EventCenter:DispatchRemoveByName(eventName)
end

function GAME_HASH_EVENT(eventName)
    return EventCenter:HasEventListener(eventName)
end

function GAME_EVENT_CENTER_DISPOSE(eventName)
    EventCenter:RemoveAllEventListeners()
end