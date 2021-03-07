local util = require 'Xlua.util'

local gameobject = RootScene
local cs_coroutine_runner = gameobject:GetComponent(typeof(CS.IdleGame.Coroutine_Runner))
if not cs_coroutine_runner then
	CS.UnityEngine.Object.DontDestroyOnLoad(gameobject)
	cs_coroutine_runner = gameobject:AddComponent(typeof(CS.IdleGame.Coroutine_Runner))
end

local function async_yield_return(to_yield, cb)
    cs_coroutine_runner:YieldAndCallback(to_yield, cb)
end

return {
    start = function(...)
	    return cs_coroutine_runner:StartCoroutine(util.cs_generator(...))
	end,

	stop = function(coroutine)
	    cs_coroutine_runner:StopCoroutine(coroutine)
	end,

	yield_return = util.async_to_sync(async_yield_return)
}
