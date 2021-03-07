local MainGameView = class("MainGameView", require("View.Base.BaseView"))

function MainGameView:ctor(pkgName, uiName, rootMap)
    MainGameView.super.ctor(self, pkgName, uiName)
    self._rootMap = rootMap
end

function MainGameView:_onUILoaded()
    MainGameView.super._onUILoaded(self)
    UISystemHelper.MainBackLayer:AddChild(self._view)
end

function MainGameView:OnExit()

end

return MainGameView