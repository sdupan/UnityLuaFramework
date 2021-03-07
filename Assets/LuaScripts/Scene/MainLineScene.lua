local MainLineScene = class("MainLineScene", require("Scene.BaseScene"))

function MainLineScene:ctor()
    MainLineScene.super.ctor(self)

    --创建主界面
    require("View.Main.MainGameView").new("Base", "Main", self)
end

function MainLineScene:Dispose()

end

return MainLineScene