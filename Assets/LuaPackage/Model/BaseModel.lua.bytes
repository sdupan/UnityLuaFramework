local BaseModelMsg = "BaseModelMsg"

local BaseModel = class("BaseModel")

function BaseModel:ctor()
    self.message_center = {}
    CSS.Bind(self.message_center, "Event")
end

function BaseModel:ServerPushInit(initData)

end

function BaseModel:ServerPushUpdate(updateData)

end

function BaseModel:ClearModelData()

end

function BaseModel:AddModelUpdateListener(listener)
    self.message_center:AddEventListener(BaseModelMsg, listener)
end

function BaseModel:RemoveModelUpdateListener(listener)
    self.message_center:RemoveEventListener(listener)
end

function BaseModel:RemoveAllListener()
    self.message_center:RemoveEventListenersByEvent(BaseModelMsg)
end

function BaseModel:NotifyModelUpdate(eventData)
    self.message_center:DispatchEvent({name = BaseModelMsg, data = eventData})
end

function BaseModel:Dispose()
    self:clearModelData()
    if self.message_center then
        self.message_center:Cleanup()
        self.message_center = nil
    end
end

return BaseModel