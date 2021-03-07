--初始化框架及全局变量
require("Common.Global")
require("Constant.Other")

--游戏数据表
local ConfigDataIniter = require("Config.Hardcode.ConfigDataIniter")
ConfigDataIniter.Init()
ConfigDataIniter.Link()

--Http
HttpClient = require("Network.HttpClient")

--Socket
Network = require("Network.Network")
SocketClient = require("Network.SocketClient")
NetCtl = require("Network.NetCtl")

--初始化定时器
LuaManager:onInit()

--创建UI分层
UISystemHelper = require("View.Base.UISystemHelper")
UISystemHelper.CreateSceneUILayer()

--工具模块
TimerManagerInst:Startup()
UpdateManagerInst:Startup()
LogicUpdateManagerInst:Startup()

--游戏文字管理器
LanguageManager = require("Manager.LanguageManager")

--游戏数据模型
BaseModel = require("Model.BaseModel")
ClientModel = require("Model.ClientModel").new()
PlayerModel = require("Model.PlayerModel").new()

--全局变量保护
require("Utils.Strict")

local M = {}

--进入游戏
function M.StartGame(allProtos)
    require("Network.ProtoMgr").Register(allProtos)
    require("Scene.MainLineScene").new()
end

return M