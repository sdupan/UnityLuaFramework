require("Common.functions")
require("FairyGui.FairyGUI")
require("Common.Init")
require("Common.CSS.Init")

-------------------------------------------------------------------
--全局变量在此定义(C#侧定义、基础模块定义)
-------------------------------------------------------------------

--单例
Singleton = require("Common.Singleton")

--根游戏对象
GRootGameObject = RootScene

--主摄像机
GMainCamera = CS.UnityEngine.GameObject.Find("Main Camera")

--主灯光
GMainLight = CS.UnityEngine.GameObject.Find("Directional Light")

--FPS显示器
GFPSViewer = CS.UnityEngine.GameObject.Find("LiteFPSCounter") or 0

--Lua管理器
LuaManager = CS.IdleGame.LuaManager.Instance

--Addressable管理器
AddressableManager = CS.IdleGame.AddressableManager

--FairyGUI管理器
UIManager = CS.IdleGame.UIManager

--日志管理器
Logger = CS.IdleGame.Logger

--协程接口
CSCoroutine = require("Common.CoroutineUtil")
yield_return = CSCoroutine.yield_return

--定时器
TimerManagerInst = require("Manager.Timer.TimerManager"):GetInstance()
UpdateManagerInst = require("Manager.Timer.UpdateManager"):GetInstance()

--消息中心
require("Manager.EventCenter")

--逻辑帧管理器
LogicUpdateManagerInst = require("Manager.LogicUpdateManager"):GetInstance()