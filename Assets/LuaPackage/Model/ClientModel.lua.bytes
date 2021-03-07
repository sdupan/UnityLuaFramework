local ClientModel = class("ClientModel", require("Model.BaseModel"))

function ClientModel:ctor()
    ClientModel.super.ctor(self)
    self:Init()
    self.gameConfig = {}
end

function ClientModel:Init()
    self._cdesa = ""
end

function ClientModel:ClearModelData()
    self.gameConfig = nil
end

return ClientModel