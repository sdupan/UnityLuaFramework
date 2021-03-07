local B = class("BaseView")

function B:ctor(pkgName, uiName)
    self._pkgName = pkgName;
    self._uiName = uiName;
    self._hasShowUI = false;
    local pkg = UIPackage.GetByName(self._pkgName)
    if pkg then
        self:_onUILoaded()
    else
        local _this = self
        UIManager.AddPackage(self._pkgName, self._uiName, function(name, result)
            print("BaseView AddPackage end ...", name, result)
            _this:_onUILoaded()
        end)
    end
end

-- 子类重写该方法，并将UI添加到舞台
function B:_onUILoaded()
    self._view = UIPackage.CreateObject(self._pkgName, self._uiName);
    self._hasShowUI = true;
end

-- 子类重写该方法
function B:OnExit()
end

function B:SetVisible(b)
    if self._view then
        self._view.visible = b or false
    end
end

function B:IsVisible()
    if self._view then
        return self._view.visible
    end
    return false
end

function B:IsViewExist()
    return self._view ~= nil
end

function B:RemoveChildren()
    if self._view then
        self._view:RemoveChildren()
    end
end

function B:OnShow()

end

function B:OnShow()

end

function B:DoShowAnimation()
    if not self._view then return end
end

function B:DoHideAnimation()
    if not self._view then return end
end

function B:Dispose(cleanup)
    self:OnExit()
    if self._view then
        local tween = GTween.GetTween(self._view)

        if tween then
            tween:Kill(false)
        end
        
        if cleanup then
            self._view:Dispose()
        else
            self._view:RemoveFromParent()
        end
    end

    if cleanup then
        UIManager.RemovePackage(self._pkgName)
    end

    self._view = nil
    self._pkgName = nil
    self._uiName = nil
end

return B