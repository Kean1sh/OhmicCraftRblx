-- CircuitManager -- 

local HttpService = game:getService("HttpService")
local ServerScriptService = game.ServerScriptService

local CircuitTemplate = require(ServerScriptService.Templates:FindFirstChild("CircuitTemplate"))
local ComponentTemplate = require(ServerScriptService.Templates:FindFirstChild("ComponentTemplate"))


local ReplicatedStorage = game.ReplicatedStorage

local EventStorage = ReplicatedStorage.EventStorage
local WireBeam = ReplicatedStorage:FindFirstChild('Wire')
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
	
	-- Set the parent of the instance to ComponentsFolder (located in workspace)
	NewComponentBlock.Parent = ComponentsFolder
	-- Set the name of the instance to the CompID
	NewComponentBlock.Name = CompID
	-- Set the CFrame of the instance to CompCFrame
	NewComponentBlock:PivotTo(CompCFrame) 

	-- Note that a Model Object is a collection of roblox objects, 
	-- so it does not have a (Position) property.
	
end


-- NewComponentEntity adds and registers new components entities
-- being added into the platform.
-- Its purpose is to create a new circuit object and add
-- that component into this new circuit.

-- As this function is activated when a remote event is sent
-- by a localscript, the Player Object becomes automatically
-- passed in by the system. This parameter is useful when server
-- scripts want to identify which client fired the remote event.
-- Player (Player) stores the player object of the client
-- that sent this remote event

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

-- CreateWireBeam creates the visuals for a wire in the form of
-- a beam object (a roblox object)
-- Beams can be imagined as the line between to points, we call these
-- points "Attachments" which are also roblox objects. In this system
-- we put an attachment within a connnector object.

-- WireID (string) stores the ID of the wire.
-- Connector0Block (BasePart) stores the Connector0 block
-- Connector1Block (BasePart) stores the Connector1 block
local function CreateWireBeam(WireID,Connector0Block,Connector1Block)

	-- This creates a new wire beam instance by cloning
	-- the original wire beam stored within ReplicatedStorage
	local NewWireBeam = WireBeam:Clone()

	-- Set the parent of the new wire beam to WireFolder (in workspace)
	NewWireBeam.Parent = WireFolder
	-- Set the name of the new wire beam to the WireID
	NewWireBeam.Name = WireID
	-- We set the Attachment0 property of the new wire beam to the 
	-- Attachment object of Connector0Block.
	NewWireBeam.Attachment0 = Connector0Block.Attachment
	-- We set the Attachment1 property of the new wire beam to the 
	-- Attachment object of Connector1Block.
	NewWireBeam.Attachment1 = Connector1Block.Attachment


end

-- NewComponentEntity adds and registers new wire entities being
-- added into the platform.
-- It could also merge the circuits of the components that this wire
-- connects. 

-- As this function is activated when a remote event is sent
-- by a localscript, the Player Object becomes automatically
-- passed in by the system. This parameter is useful when server
-- scripts want to identify which client fired the remote event.
-- Player (Player) stores the player object of the client
-- that sent this remote event

-- Connector0Block(BasePart) stores the Connector0's block object
-- Connector1Block(BasePart) stores the Connector1's block object

local function NewWireEntity(Player,NegativeConnector,PositiveConnector)
	
	-- Get the ID of the component block that contains Connector0Block
	local Component1ID = NegativeConnector.Parent.Name
	-- Get the ID of the component block that contains Connector1Block
	local Component2ID = PositiveConnector.Parent.Name
	
	local NegativeConnectorName = NegativeConnector.Name
	local PositiveConnectorName = PositiveConnector.Name
	
	
	-- Get the circuit of component0, identified as Circuit0
	local Circuit1ID = FindCircuitWithComponent(Component1ID)
	-- Get the circuit of component1, identified as Circuit1
	local Circuit2ID = FindCircuitWithComponent(Component2ID)
	
	
	
	-- If the two circuits aren't the same, we merge them. Circuit0 will
	-- integrate Circuit1
	if Circuit1ID ~= Circuit2ID then
		MergeCircuits( CircuitRepository[Circuit1ID], CircuitRepository[Circuit2ID] )
	end

	-- Set the connections of both components to each other.
	--CircuitRepository[Circuit1ID]:GetComponent(Component1ID):SetConnection(NegativeConnectorName,Component2ID)
	--CircuitRepository[Circuit1ID]:GetComponent(Component2ID):SetConnection(PositiveConnectorName,Component1ID)

	

	print(Circuit2ID,Circuit1ID)
	-- Generate a new ID for the wire entity
	local WireID = HttpService:GenerateGUID(false)
	-- Create a new component entity by passing WireID and set the type as
	-- "Wire". This will be the wire entity.
	local WireComp = ComponentTemplate.new(WireID,"Wire")

	-- Set the connections of both components to the wire.
	CircuitRepository[Circuit1ID]:GetComponent(Component1ID):SetConnection(NegativeConnectorName,WireID)
	CircuitRepository[Circuit1ID]:GetComponent(Component2ID):SetConnection(PositiveConnectorName,WireID)

	-- Set the connections of the wire to the two components
	WireComp:SetConnection("Connector0",Component1ID)
	WireComp:SetConnection("Connector1",Component2ID)
	-- Add this wire entity into Circuit0
	CircuitRepository[Circuit1ID]:AddComponent(WireID,WireComp,false)
	-- If Circuit0 does not already contain the wire component
	--if CircuitRepository[Circuit0ID]:GetComponent(WireID) == nil then
		--CircuitRepository[Circuit0ID]:AddComponent(WireID,WireComp,false)
	--end
	
	-- Then we can call CreateWireBeam to create
	-- the physical wire beam of this wire entity.
	CreateWireBeam(WireID,NegativeConnector,PositiveConnector)
	
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


EventStorage.RequestNewComponent.OnServerEvent:Connect(NewComponentEntity)
EventStorage.ConnectConnectors.OnServerEvent:Connect(NewWireEntity)