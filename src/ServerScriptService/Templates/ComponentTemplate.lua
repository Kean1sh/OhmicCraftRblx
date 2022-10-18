local Component = {}
Component.__index = Component
print('aaaa')

-- Constructor -- 
function Component.new(compID,compType)
	local self = setmetatable({},Component)

	-- Note that in LUA, private/protected attributes do not
	-- exist to show that a variable is private/protected I
	-- decided to use one or two underscores like in python

	-- They do not have actual private/protected properties,
	-- and are simply cosmetic

	-- private example : self._Car
	-- protected example : self.__Truck

	-- = Component Data = --

	-- ComponentID is self explanatory
	self._ComponentID = compID ::string
	self._ComponentType = compType ::string

	-- Ideal is an upcoming feature
	self._Ideal = true

	self._Voltage = 1::Number
	self._Resistance = 1::Number
	self._Current = 1::Number
	return self
end

-- Setter functions -- 
function Component.SetIdeal(self,IdealVal)
	self._Ideal = IdealVal
end

function Component.SetVoltage(self,VoltageVal)
	self._Voltage = VoltageVal
end

function Component.SetResistance(self,ResistanceVal)
	self._Resistance = ResistanceVal
end

function Component.SetCurrent(self,CurrentVal)
	self._Current = CurrentVal
end

-- Getter functions -- 
function Component.GetID(self) : string
	return self._ComponentID
end

function Component.GetType(self) : string
	return self._ComponentType
end

function Component.GetIdeal(self) : boolean
	return self._Ideal
end

function Component.GetVoltage(self) : Number
	return self._Voltage
end

function Component.GetResistance(self) : Number
	return self._Resistance
end

function Component.GetCurrent(self) : Number
	return self._Current
end




return Component