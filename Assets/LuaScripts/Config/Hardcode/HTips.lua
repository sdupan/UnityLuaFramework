------------------------------------------------------------------------
-- Tips数据表
------------------------------------------------------------------------

--------------------------------------------------------------------------
----类的声明
--------------------------------------------------------------------------

local HTips = class("HTips")

-- 数据表数据
HTips.s_datas = {}

-- 数据表类
function HTips:ctor(dataObj)
	self._dataObj = dataObj

	-----DECLARE_MEMBERS BEGIN---
	self.id = self._dataObj.id
	self.content = self._dataObj.content
	-----DECLARE_MEMBERS END---
end

--------------------------------------------------------------------------
----静态成员函数
--------------------------------------------------------------------------

-- 初始化数据
function HTips.InitDatas()
	local datas = require("Config.Data.TipsRef")
	if datas then
		for k, v in pairs(datas) do
			HTips.s_datas[k] = HTips.new(v)
		end
	end
end

-- 取得表格所有数据
-- return [HTips,...]
function HTips.GetDatas()
	return HTips.s_datas
end

-- 根据ID取得数据
-- return HTips
function HTips.GetDataById(id)
	return HTips.s_datas[id]
end

-- 关联其它表
function HTips.LinkTable()
	
end

return HTips