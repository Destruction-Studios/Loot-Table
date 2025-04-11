export type Condition = (...any) -> boolean
export type Chance = number

export type Reward = {
	Chance: Chance,
	Value: any | LootTable,
	Condition: Condition?,
	Inverse: boolean?,
}

export type LootTableItems = { Reward }

export type LootTable = {
	Roll: (self: LootTable) -> any,
	Inverse: (self: LootTable) -> LootTable,
}

local UniqueKey = require(script.Parent.UniqueKey)

local LootTable = {
	IgnoreAndPass = UniqueKey("IgnoreAndPass"),
	IgnoreAndCount = UniqueKey("IgnoreAndCount"),
	Choose = UniqueKey("Choose"),
}
local LootTableMT = {}
LootTableMT.__index = LootTableMT

function LootTable.is(tbl: any): boolean
	return typeof(tbl) == "table" and getmetatable(tbl) == LootTableMT
end

function LootTable.new(lootTable: LootTableItems): LootTable
	local self = setmetatable({}, LootTableMT)

	self._random = Random.new()
	self._inverse = false
	self._lootTable = lootTable

	self._prob = {}

	return self
end

function LootTableMT:_fromValue(value: any)
	if LootTable.is(value) then
		return value:Roll()
	end
	return value
end

function LootTableMT:_getWeight()
	local result = 0
	for _, v: Reward in self._lootTable do
		result += v.Chance
	end
	return result
end

function LootTableMT:_getRandomInverse()
	local rand = self._random:NextNumber()
	local counter = 0

	local result = nil

	for _, prob in self._prob do
		if typeof(prob.Condition) == "function" then
			local conditionResult = prob.Condition()
			if conditionResult == LootTable.IgnoreAndPass then
				continue
			elseif conditionResult == LootTable.IgnoreAndCount then
				counter += prob.Chance
				continue
			elseif conditionResult == LootTable.Choose then
				result = prob.Value
				continue
			end
		end
		counter += prob.Chance
		if rand <= counter then
			result = prob.Value
		end
	end

	return if result then self:_fromValue(result) else nil
end

function LootTableMT:_getRandom()
	local totalWeight = self:_getWeight()
	local randomNum = self._random:NextNumber(0, totalWeight)
	local counter = 0

	local result = nil

	for _, v in self._lootTable do
		if typeof(v.Condition) == "function" then
			local conditionResult = v.Condition()
			if conditionResult == LootTable.IgnoreAndPass then
				continue
			elseif conditionResult == LootTable.IgnoreAndCount then
				counter += v.Chance
				continue
			elseif conditionResult == LootTable.Choose then
				result = v.Value
			end
		end
		counter += v.Chance
		if randomNum <= counter then
			result = v.Value
		end
	end

	return if result then self:_fromValue(result) else nil
end

function LootTableMT:_roll()
	if self._inverse then
		return self:_getRandomInverse()
	else
		return self:_getRandom()
	end

	return nil
end

function LootTableMT:Inverse()
	self._inverse = true

	local inverses = {}
	local totalInverses = 0

	for i, reward: Reward in self._lootTable do
		local inverse = 1 / reward.Chance
		inverses[i] = inverse
		totalInverses += inverse
	end

	for i, inverse in inverses do
		self._prob[i] = { Chance = inverse / totalInverses, Value = self._lootTable[i].Value }
	end

	return self
end

function LootTableMT:Roll(...: any)
	return self:_roll(...)
end

return table.freeze(LootTable)
