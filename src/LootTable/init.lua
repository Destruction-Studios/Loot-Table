export type Condition = (...any) -> boolean
export type Weight = number
export type Value = any | LootTable

export type Reward = {
	Weight: Weight,
	Value: Value,
}

export type Probability = {
	Value: Value,
	Weight: number,
}

export type LootTableItems = { [any]: Reward }

export type LootTable = {
	Roll: (self: LootTable) -> any,
	Inverse: (self: LootTable) -> LootTable,
}

local LootTable = {}
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
	self._probabilities = {}

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
		result += v.Weight
	end
	return result
end

function LootTableMT:_getRandomInverse()
	print(self._probabilities)

	local rand = math.random()
	local totalProb = 0
	for _, prob: Probability in pairs(self._probabilities) do
		totalProb = totalProb + prob.Weight
		if rand <= totalProb then
			return self:_fromValue(prob.Value)
		end
	end

	error(`Could not get item`)
end

function LootTableMT:_getRandom()
	local weight = 0
	for _, v: Reward in self._lootTable do
		weight += v.Weight
	end

	local randomNumber = self._random:NextNumber(0, weight)
	weight = 0

	for _, v: Reward in self._lootTable do
		weight += v.Weight
		if weight >= randomNumber then
			return self:_fromValue(v.Value)
		end
	end

	error(`Could not get item`)
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

	local items = self._lootTable
	local totalInverse = 0
	local inverses = {}

	for i, item: Reward in pairs(items) do
		inverses[i] = 1 / item.Weight
		totalInverse = totalInverse + inverses[i]
	end

	for i, inverse in pairs(inverses) do
		self._probabilities[i] = { Weight = inverse / totalInverse, Value = items[i].Value }
	end

	return self
end

function LootTableMT:Roll(...: any)
	return self:_roll(...)
end

return table.freeze(LootTable)
