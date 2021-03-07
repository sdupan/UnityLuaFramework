--逻辑帧定时器
local LogicUpdateManager = class("LogicUpdateManager", Singleton)

--带有FrameUpdate(deltaTime, unscaledDeltaTime)方法的对象列表
--FrameUpdate返回true表示该方法对应的对象需要从逻辑帧定时器中移除
local logicObjects = {}
local tmpRemoveTb = {}
local deltaTime = 0
local unscaledDeltaTime = 0
local shouldRemoved = false

local function LogicFrameUpdate()
    deltaTime = Time.deltaTime
    unscaledDeltaTime = Time.unscaledDeltaTime
    tmpRemoveTb = {}
    for i=1, #logicObjects do
        if not logicObjects[i] or not logicObjects[i].FrameUpdate then
            table.insert(tmpRemoveTb, i)
        else
            shouldRemoved = logicObjects[i]:FrameUpdate(deltaTime, unscaledDeltaTime)
            if shouldRemoved then
                table.insert(tmpRemoveTb, i)
            end
        end
    end

    --删除无效的对象
    for i=#tmpRemoveTb, 1, -1 do
        table.remove(logicObjects, tmpRemoveTb[i])
    end
end

function LogicUpdateManager:ctor()
    logicObjects = {}
    tmpRemoveTb = {}
    deltaTime = 0
    unscaledDeltaTime = 0
    shouldRemoved = false
end

function LogicUpdateManager:AddObject(obj)
    if type(obj) ~= "table" then
        return
    end

    if not obj.FrameUpdate then
        return
    end
    
    table.insert(logicObjects, obj)
end

function LogicUpdateManager:RemoveObject(obj)
    for i=#logicObjects, 1, -1 do
        if logicObjects[i] == obj then
            table.remove(logicObjects, i)
            return
        end
    end
end

function LogicUpdateManager:Startup()
    UpdateManagerInst:AddUpdate(LogicFrameUpdate)
end

function LogicUpdateManager:Dispose()
    logicObjects = {}
    tmpRemoveTb = {}
    deltaTime = 0
    unscaledDeltaTime = 0
    shouldRemoved = false
    UpdateManagerInst:RemoveUpdate(LogicFrameUpdate)
end

return LogicUpdateManager