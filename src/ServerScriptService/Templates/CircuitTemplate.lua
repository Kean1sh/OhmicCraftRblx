local Circuit = {}
Circuit.__index = Circuit

function Circuit.new(circuitID)
	local self = setmetatable({},Circuit)

	self._Updated = false::boolean

	-- A Branch is a collection of components between two
	-- intersection components
	-- CircuitBranch store the Branch within the circuit
	-- CircuitBranch is a list.
	self.CircuitBranch = {} :: {branch}

	-- CircuitComponents store all components within this
	-- Circuit
	-- CircuitComponents is a dictionary
	-- A key represents the ComponentID which is a string
	-- A value represents the ComponentObject which is a
	-- ComponentTemplate
	self.CircuitComponents = {} 
	--:: {[string]:component}


	-- CircuitGraph stores all the nodes within the circuit
	-- as a dictionary, with the nodeID as the key and its
	-- connectionIDs stored in a table as the value
	-- CircuitGraph is a dictionary.
	-- A key in CircuitGraph stores nodeID, which is a string
	-- A value in CircuitGraph stores the connectionIDs, which is
	-- a table that only stores strings.
	self.CircuitGraph = {} :: {[string]:{string}}


	-- CircuitWires store all the visited wire components when
	-- creating the graph.
	-- CircuitWires is a list
	self.CircuitWires = {} :: {string}


	-- Cycles are collections of branches that all lead back to
	-- the same starting branch.
	-- CircuitCyles store all the cycles within this Circuit.
	-- In CircuitCycles stores the CycleID as a key and a
	-- table with BranchIDs as the value.
	-- CircuitCycles is a dictionary
	-- A key in CircuitCyles stores nodeID, which is a string
	-- A value in CircuitCyles stores the BranchIDs, which is
	-- a table that only store strings
	self.CircuitCycles = {} :: {[string]:{string}}


	-- = Circuit Data = --

	-- Note that in LUA, private/protected attributes do not
	-- exist to show that a variable is private/protected I
	-- decided to use one or two underscores like in python

	-- private example : self._Car
	-- protected example : self.__Truck

	-- CircuitID is self explanatory
	self._CircuitID = circuitID::string

	-- Complete determines whether this circuit is ready
	-- to run
	self._Complete = false::boolean

	return self
end


-- SplitCircuit is made to remove any disconnected components from this circuit,
-- and move them to a new circuit.

-- This function returns a table containing component otherwise
-- returns nil in the event that there is no disconnected component
function Circuit.SplitCircuit(self) : {string}?

	-- Disconnected components are different from Circuit Outliers
	-- Disconnected components are physically not connected to the
	-- components within the graph.

	-- This will store all disconnected components' IDs in a table
	local DisconnectedComponents = {} :: {string}

	-- Loop through the CircuitComponents.
	for CompID,CompObject in pairs (self.CircuitComponents) do
		
		-- If the component does not belong to CircuitWires and CircuitGraph:
		if (self.CircuitGraph[CompID] == nil) and 
			(self.CircuitWires[CompID] == nil) then
			
			-- this component is disconnected, add it to the disconnectedComponents List
			DisconnectedComponents.insert(CompID)
		end

	end

	-- If there are no Disconnected Components, return nothing.
	if (#DisconnectedComponents == 0) then
		return nil
	end
	
	-- Otherwise return the list of disconnected components.
	return DisconnectedComponents

end


-- This function creates a new entry for the CircuitGraph
function Circuit.NewGraphEntry(self,NewNodeID,LastNodeID)
	
	-- Create a new entry in the CircuitGraph with this new Node
	-- and its new connection, the last Node.
	self.CircuitGraph[NewNodeID] = {LastNodeID}
	
	--
	self.CircuitGraph[LastNodeID].insert(NewNodeID)
	
end

function Circuit.UpdateCircuit(self)
	

end	


-- Setter Functions --

function Circuit.RemoveComponent(self,CompID,UpdateState)
	self.CircuitComponents[CompID] = nil

	if UpdateState == true then
		print('True')
	end
end

function Circuit.AddComponent(self,CompID,CompObject,UpdateState)
	
	self.CircuitComponents[CompID] = CompObject
	
	if UpdateState == true then
		print('True')
	end
	
end

-- Getter Functions --

function Circuit.GetComponent(self,CompID)
	
	return self.CircuitComponents[CompID]
	
end

function Circuit.GetAllComponents(self)

	return self.CircuitComponents

end

function Circuit.GetID(self)

	return self._CircuitID

end





return Circuit
