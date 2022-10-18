-- CircuitManager -- 

local HttpService = game:getService("HttpService")
local ServerScriptService = game.ServerScriptService

local CircuitTemplate = require(ServerScriptService.Templates:FindFirstChild("CircuitTemplate"))
local ComponentTemplate = require(ServerScriptService.Templates:FindFirstChild("ComponentTemplate"))


local ReplicatedStorage = game.ReplicatedStorage

local EventStorage = ReplicatedStorage.EventStorage
local WireBlock = ReplicatedStorage:FindFirstChild('Wire')
local ComponentBlocks = ReplicatedStorage:FindFirstChild('ComponentBlocks')
local WireFolder = workspace.Wires
local ComponentsFolder = workspace.Components

-- Stores all existing circuits in a dictionary
-- A key represents the Circuit ID stored as a string
-- A value represents the Circuit Object
-- Example entry :
-- {["Circuit1"] = Circuit1}
local CircuitRepository = {}

-- CreateComponentBlock creates the visuals of the physical object in the place
-- CompID is the ID of the component which it will use as the name of the
-- physical object
-- 
local function CreateComponentBlock(CompID,CompType,CompCFrame)
	
	local NewComponentBlock = ComponentBlocks:FindFirstChild(CompType):Clone()
	
	NewComponentBlock.Parent = ComponentsFolder
	NewComponentBlock.Name = CompID
	NewComponentBlock:PivotTo(CompCFrame) 
	
end


-- NewComponentEntity adds and registers new components being
-- added into the platform.
-- Its purpose is to create a new circuit object and add
-- that component into this new circuit.

-- CompPos is a CFrame value, CFrame stores both position
-- and orientation of a world object.
local function NewComponentEntity(Player,CompType,CompCFrame)
	-- GenerateGUID Generates a random 36 letter string ID
	-- GenerateGUID(true) incldues curly brackets
	-- GenerateGUID(false) does not include curly brackets

	-- When a new component is created, we create IDs for
	-- a new component and a new circuit.
	local CompID = HttpService:GenerateGUID(false)
	local CircuitID = HttpService:GenerateGUID(false)

	-- We then create a new circuit object and pass the 
	-- circuit ID
	local NewCircuit = CircuitTemplate.new(CircuitID)
	print(NewCircuit)
	-- Add this new circuit to the CircuitRepository
	AddCircuit(CircuitID,NewCircuit)

	local NewComp = ComponentTemplate.new(CompID,CompType)
	
	print(NewComp)
	NewCircuit:AddComponent(CompID,NewComp,true)
	
	CreateComponentBlock(CompID,CompType,CompCFrame)
end

local function CreateWireBlock(WireID,Connector0Block,Connector1Block)

	local NewWireBlock = WireBlock:Clone()

	NewWireBlock.Parent = WireFolder
	NewWireBlock.Name = WireID
	NewWireBlock.Attachment0 = Connector0Block.Attachment
	NewWireBlock.Attachment1 = Connector1Block.Attachment


end

local function NewWireEntity(Player,Connector0Block,Connector1Block)
	
	local Component0ID = Connector0Block.Parent.Name
	local Component1ID = Connector1Block.Parent.Name
	
	local Circuit0ID = FindCircuitWithComponent(Component0ID)
	local Circuit1ID = FindCircuitWithComponent(Component1ID)
	
	local WireID = HttpService:GenerateGUID(false)
	local WireComp = ComponentTemplate.new(WireID,"Wire")
	
	print(Circuit0ID,Circuit1ID)
	
	if CircuitRepository[Circuit0ID]:GetComponent(WireID) == nil then
		CircuitRepository[Circuit0ID]:AddComponent(WireID,WireComp,false)
	end
	
	if Circuit0ID ~= Circuit1ID then
		
		MergeCircuits( CircuitRepository[Circuit0ID], CircuitRepository[Circuit1ID] )
		
	end
	
	CreateWireBlock(WireID,Connector0Block,Connector1Block)
	
end



function MergeCircuits(HostCircuit,TargetCircuit)
	-- Get the Components of the TargetCircuit
	local TargetCircuitComponents = TargetCircuit:GetAllComponents()

	-- Loop through all entries within the TargetCircuitComponents (dictionary)
	-- CompID represents the key (string)
	-- CompObj represents the value (Component Object)
	for CompID,CompObj in pairs(TargetCircuitComponents) do
		-- Add the current component to HostCircuit
		HostCircuit:AddComponent(CompID,CompObj)

		-- As there are no index values within a dictionary, the only way we
		-- can get the final value is by reducing the dictionary.
		-- Remove the current component from TargetCircuitComponents
		TargetCircuitComponents[CompID] = nil

		-- once we removed the last component/TargetCircuitComponents is
		-- and its now empty:
		if (#TargetCircuitComponents == 0) then
			-- We can update the graph
			--HostCircuit:UpdateGraph()
			print(HostCircuit:GetAllComponents())
		end
	end
	-- Once we've transferred all of the TargetCircuit's components,
	-- delete TargetCircuit from existance.
	RemoveCircuit(TargetCircuit:GetID())
end



function RemoveCircuit(CircuitID)
	CircuitRepository[CircuitID] = nil
end   

function AddCircuit(CircuitID,CircuitObj)
	CircuitRepository[CircuitID] = CircuitObj
end

function FindCircuitWithComponent(CompID)
	for circID,Circuit in pairs (CircuitRepository) do
		
		if Circuit:GetComponent(CompID) ~= nil then
			
			return circID
			
		end
		
		
	end
end


EventStorage.RequestNewComponent.OnServerEvent:Connect(NewComponent)
EventStorage.ConnectConnectors.OnServerEvent:Connect(NewWire)