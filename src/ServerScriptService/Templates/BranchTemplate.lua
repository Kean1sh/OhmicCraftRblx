local Branch = {}
Branch.__index = Branch

function Branch.new(branchID)
	local self = setmetatable({},Branch)

	-- BranchComponents is a list that stores the
	-- IDs of components within this branch.
	self.BranchComponents = {}

	-- As branches are defined as a series of components
	-- between two junctions. Rather than placing these
	-- junctions in BranchComponents, I decided to
	-- have them stored individually.
	self._StartJunction = ""::String
	self._EndJunction = ""::String

	self._Voltage = 1::Number
	self._Resistance = 1::Number


	return self
end

function Branch.AddComponent(self,CompID)
	if BranchComponents[CompID] == nil then
		BranchComponents.insert(CompID)
	end
end

function Branch.RemoveComponent(self,CompID)
	

return Branch