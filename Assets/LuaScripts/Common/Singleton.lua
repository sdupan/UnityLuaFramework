---------------------------------------------------------------------------------------------------------------
-- 单例类
---------------------------------------------------------------------------------------------------------------

local Singleton = class("Singleton")

function Singleton:ctor()
	
end

function Singleton:__init()
	assert(rawget(self, "_Instance") == nil, self.__cname.." to create singleton twice!")
	rawset(self, "_Instance", self)
end

function Singleton:__delete()
	rawset(self, "_Instance", nil)
end

-- 只是用于启动模块
function Singleton:Startup()
	
end

-- 不要重写
function Singleton:GetInstance()
	if rawget(self, "_Instance") == nil then
		rawset(self, "_Instance", self.new())
	end
	assert(self._Instance ~= nil)
	return self._Instance
end

-- 不要重写
function Singleton:Delete()
	self._Instance = nil
end

return Singleton
