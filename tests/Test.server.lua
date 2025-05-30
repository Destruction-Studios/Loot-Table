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
		Value = "A",
		Weight = 2,
	},
	{
		Value = "B",
		Weight = 2,
	},
}):Inverse()

local rng = Random.new()

local results = {}
local total = 1000 -- Increase for more precision, but more computing time

for i = 1, total do
	local item = lti:Roll()
	if item then
		results[item] = (results[item] or 0) + 1
	end
	if i % 99999 == 0 then
		print("Delay", i)
		task.wait()
	end
end

warn("<<<<<<<<<< Inverse >>>>>>>>>>")
for i, v in pairs(results) do
	local chance = v / total * 100
	warn(`{i}: {math.floor(chance * 100) / 100}%`)
end
warn("<<<<<<<<<<<<<<>>>>>>>>>>>>>>")
