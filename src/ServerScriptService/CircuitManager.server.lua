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
-- CompID (string) is the ID of the component which it will use as the name
-- of the new instance of the component block
-- CompType (string) is the type of the component, which will be used to locate
-- the model of that component type in ComponentBlocks.
-- CompCFrame (CFrame) stores the location and orientation of
-- where the new component block will be placed and oriented. 
local function CreateComponentBlock(CompID,CompType,CompCFrame)
	
	-- Create a new instance of the component block by cloning the component
	-- block of CompType in ComponentBlocks.
	local NewComponentBlock = ComponentBlocks:FindFirstChild(CompType):Clone()
	
	-- Set the parent to ComponentsFolder (located in workspace)
	NewComponentBlock.Parent = ComponentsFolder
	-- Set the name of the instance to the CompID
	NewComponentBlock.Name = CompID
	-- Set the CFrame of the instance to CompCFrame
	NewComponentBlock:PivotTo(CompCFrame) 

	-- Note that a Model Object is a collection of roblox objects, 
	-- so it does not have a (Position) property.
	
end


-- NewComponentEntity adds and registers new components being
-- added into the platform.
-- Its purpose is to create a new circuit object and add
-- that component into this new circuit.

-- CompType (string) is the type of the component.
-- CompCFrame (CFrame), CFrame stores both position
-- and orientation of a world object.
local function NewComponentEntity(Player,CompType,CompCFrame)
	-- GenerateGUID Generates a random 36 letter string ID
	-- GenerateGUID(true) incldues curly brackets
	-- GenerateGUID(false) does not include curly brackets

	-- When a new component is created, we create IDs for
	-- a new component and a new circuit.
	local CompID = HttpService:GenerateGUID(false)
	local CircuitID = HttpService:GenerateGUID(false)

	-- We then create a new circuit entity object 
	-- and pass in the CircuitID
	local NewCircuit = CircuitTemplate.new(CircuitID)
	print(NewCircuit)
	-- Add this new circuit to the CircuitRepository
	AddCircuit(CircuitID,NewCircuit)

	-- Create a new component entity object and pass
	-- in the CompID and CompType
	local NewComp = ComponentTemplate.new(CompID,CompType)
	
	print(NewComp)
	-- We then add this new component entity to the
	-- new circuit entity.
	NewCircuit:AddComponent(CompID,NewComp,false)
	
	-- Then we can call CreateComponentBlock to create
	-- the physical component / component block of the
	-- new component.
	CreateComponentBlock(CompID,CompType,CompCFrame)
end

-- CreateWireBlock creates the visuals for a wire in the form of
-- a beam object (a roblox object)
-- Beams can be imagined as the line between to points, we call these
-- points "Attachments" which are also roblox objects. A beam requires
-- two Attachments otherwise it wouldn't appear properly.

-- WireID (string) stores the ID of the wire.

local function CreateWireBeam(WireID,Connector0Block,Connector1Block)

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
	
	CreateWireBeam(WireID,Connector0Block,Connector1Block)
	
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