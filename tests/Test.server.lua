local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LootTableModule = require(ReplicatedStorage.Shared.LootTable)

local lt = LootTableModule.new({
	{
		Chance = 50,
		Value = "Common",
	},
	{
		Chance = 25,
		Value = "Special",
	},
	{
		Chance = 10,
		Value = "Epic",
	},
	{
		Chance = 0.1,
		Value = "???",
	},
})

local override = false

local lti = LootTableModule.new({
	{
		Chance = 10,
		Value = "A",
		Condition = function()
			if override == true then
				return LootTableModule.Choose
			end
		end,
	},
	{
		Chance = 2,
		Value = "B",
	},
}):Inverse()

print(lti:Roll())

-- local results = {}
-- local total = 1e9 -- Increase for more precision, but more computing time

-- for i = 1, total do
-- 	local item = tli:Roll()
-- 	if item then
-- 		results[item] = (results[item] or 0) + 1
-- 	end
-- 	if i % 99999 == 0 then
-- 		task.wait()
-- 		print("Delay ", i)
-- 	end
-- end

-- warn("<<<<<<<<<< Invserse >>>>>>>>>>")
-- for i, v in pairs(results) do
-- 	local chance = v / total * 100
-- 	warn(`{i}: {math.floor(chance * 100) / 100}%`)
-- end
-- warn("<<<<<<<<<<<<<<>>>>>>>>>>>>>>")
