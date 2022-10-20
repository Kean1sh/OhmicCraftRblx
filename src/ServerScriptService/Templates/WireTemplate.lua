local Wire = {}
Wire.__index = Wire

function Wire.new(wireID,Connection0ID,Connection1ID)
	local self = setmetatable({},Wire)
	
	self.Connections = {["Connector0"] = Connection0ID, ["Connector1"] = Connection1ID}

	self._WireID = wireID

	return self
end




return Wire