local UISystemHelper = {}

UISystemHelper.MainBackLayer = nil
UISystemHelper.MainUILayer = nil
UISystemHelper.MainFrontLayer = nil
UISystemHelper.MainTopLayer = nil
UISystemHelper.EffectUILayer = nil
UISystemHelper.GuideUILayer = nil
UISystemHelper.TopUILayer = nil
UISystemHelper.TopMostUILayer = nil

function UISystemHelper.CreateSceneUILayer()
    local view = UIPackage.CreateObject("Base", "UISystemHelper");
	view:MakeFullScreen();
    GRoot.inst:AddChild(view);
    
    UISystemHelper.MainBackLayer = view:GetChild("MainBackLayer")
    UISystemHelper.MainUILayer = view:GetChild("MainUILayer")
    UISystemHelper.MainFrontLayer = view:GetChild("MainFrontLayer")
    UISystemHelper.MainTopLayer = view:GetChild("MainTopLayer")
    UISystemHelper.EffectUILayer = view:GetChild("EffectUILayer")
    UISystemHelper.GuideUILayer = view:GetChild("GuideUILayer")
    UISystemHelper.TopUILayer = view:GetChild("TopUILayer")
    UISystemHelper.TopMostUILayer = view:GetChild("TopMostUILayer")

    UISystemHelper.MainBackLayer.height = UISystemHelper.MainBackLayer.height
    UISystemHelper.MainUILayer.height = UISystemHelper.MainUILayer.height
    UISystemHelper.MainFrontLayer.height = UISystemHelper.MainFrontLayer.height
    UISystemHelper.MainTopLayer.height = UISystemHelper.MainTopLayer.height
    UISystemHelper.EffectUILayer.height = UISystemHelper.EffectUILayer.height
    UISystemHelper.GuideUILayer.height = UISystemHelper.GuideUILayer.height
    UISystemHelper.TopUILayer.height = UISystemHelper.TopUILayer.height
    UISystemHelper.TopMostUILayer.height = UISystemHelper.TopMostUILayer.height
end

return UISystemHelper