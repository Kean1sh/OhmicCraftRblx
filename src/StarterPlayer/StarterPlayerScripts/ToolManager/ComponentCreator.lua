local ComponentCreator = {}

local RunService = game:GetService("RunService")

local ContextActionService = game:GetService("ContextActionService")

local RayCastHandler = require(script.Parent:FindFirstChild("RayCastHandler"))


local RequestNewComponent = game.ReplicatedStorage.EventStorage:FindFirstChild("RequestNewComponent")
ComponentCreator.ComponentStorage = game.ReplicatedStorage:FindFirstChild("ComponentBlocks")
ComponentCreator.Mouse = game:GetService("Players").LocalPlayer:GetMouse()



--

-- InMenu stores whether or not the player is currently in the
-- ComponentSelect Menu
-- InMenu is represented by a boolean value
ComponentCreator.InMenu = false::boolean

-- CanPlace determines whether or not the player could fire
-- CreateComponent (RemoteEvent)
ComponentCreator.CanPlace = true::boolean

-- SelectedComponent stores which component's been selected 
-- by the player. At the start, the resistor is automatically
-- selected.
-- SelectedComponent is represented by a string

ComponentCreator.SelectedComponent = "Resistor":: String

ComponentCreator.EditorBlock = nil::Model?

ComponentCreator.EditorBlockCurrentRotation = 0


function ComponentCreator.OpenMenu(ActionName,State,InputObject)
	if ActionName == "MenuRequest" then
		
		if State == Enum.UserInputState.Begin then
			if ComponentCreator.InMenu ~= false then
				ComponentCreator.InMenu = true
			else
				ComponentCreator.InMenu = false
			end
		end
		
		
		if (ComponentCreator.InMenu) == true then
			ComponentCreator.DisableEditorView()
			print('aaaa')
		end
		
	end
end

function ComponentCreator.PlaceBlock()
	if (ComponentCreator.InMenu == false) and ComponentCreator.CanPlace == true then
		
		
		local MouseRay = RayCastHandler.CastRay("ComponentConstructor")
		
		if (MouseRay.Instance ~= nil) then
			
			print('Place block at', MouseRay.Position)
				
			RequestNewComponent:FireServer (ComponentCreator.SelectedComponent, (CFrame.new(MouseRay.Position) * CFrame.Angles(0, ComponentCreator.EditorBlockCurrentRotation, 0) ) )
				
		end
		
		
	end
end


function ComponentCreator.MouseListener(ActionName,State,InputObject)
	if State == Enum.UserInputState.Begin then

		if ComponentCreator.InMenu == false then
			ComponentCreator.PlaceBlock()


		elseif ComponentCreator.InMenu == true then

			print('weee')
		end

	end
end


function ComponentCreator.EditorMode(DeltaTime)
	local MouseRay = RayCastHandler.CastRay("ComponentConstructor")
	if (ComponentCreator.InMenu == false) and MouseRay ~= nil then
		
		ComponentCreator.EditorBlock:PivotTo(CFrame.new(MouseRay.Position) * CFrame.Angles( 0, ComponentCreator.EditorBlockCurrentRotation, 0)) 
		
		ComponentCreator.CanPlace = true
		
		for _,ComponentBlock in pairs (workspace.Components:GetChildren()) do

			if ( (ComponentBlock.Base.Position - MouseRay.Position).Magnitude <= 10) then

				ComponentCreator.CanPlace = false
				break


			end
		end
		
		
		if ComponentCreator.CanPlace == false then
			for _,Part in pairs (ComponentCreator.EditorBlock:GetDescendants()) do
				if (Part:IsA("BasePart")) then

					Part.Color = Color3.new(1, 0, 0)
					Part.Transparency = 0.55


				end
			end
			
		else
			for _,Part in pairs (ComponentCreator.EditorBlock:GetDescendants()) do
				if (Part:IsA("BasePart")) then

					Part.Color = Color3.new(0, 0.666667, 1)
					Part.Transparency = 0.55


				end
			end
			
		end
		
		
		
	end
	
end



function ComponentCreator.RotateEditorBlock(ActionName,State,InputObject)
	
	if State == Enum.UserInputState.Begin then
		
		ComponentCreator.EditorBlockCurrentRotation += math.pi/2
		if ComponentCreator.EditorBlockCurrentRotation >= (math.pi * 2) then
			ComponentCreator.EditorBlockCurrentRotation -= math.pi * 2
		end
		
	end
	
	
end

function ComponentCreator.EnableEditorView()
	local EditorBlockInstance = ComponentCreator.ComponentStorage:FindFirstChild(ComponentCreator.SelectedComponent):Clone()
	
	ComponentCreator.EditorBlock = EditorBlockInstance
	ComponentCreator.EditorBlock.Parent = workspace:FindFirstChild("Cosmetic")
	ComponentCreator.EditorBlock:FindFirstChild("BillboardGui"):Destroy()
	
	for _,Part in pairs (ComponentCreator.EditorBlock:GetDescendants()) do
		if (Part:IsA("BasePart")) then
			
			Part.Material = Enum.Material.Neon
			Part.Color = Color3.new(0, 0.666667, 1)
			Part.Transparency = 0.55
			Part.CanCollide = false
			
			
		end
	end
	
	
	
	RunService:BindToRenderStep("Editor",Enum.RenderPriority.Input.Value,ComponentCreator.EditorMode)
	
end

function ComponentCreator.DisableEditorView()
	if ComponentCreator.EditorBlock ~= nil then
		ComponentCreator.EditorBlock:Destroy()
	end
	
	RunService:UnbindFromRenderStep("Editor")

end


function ComponentCreator.Enable()
	ComponentCreator.InMenu = false
	ComponentCreator.EnableEditorView()
	ContextActionService:BindAction("MouseLeftClick",ComponentCreator.MouseListener,false,Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction("MenuRequest",ComponentCreator.OpenMenu,false,Enum.KeyCode.E)
	ContextActionService:BindAction("RotateRequest",ComponentCreator.RotateEditorBlock,false,Enum.KeyCode.R)
end

function ComponentCreator.Disable()
	ComponentCreator.InMenu = false
	ComponentCreator.DisableEditorView()
	ContextActionService:UnbindAction("MouseLeftClick")
	ContextActionService:UnbindAction("MenuRequest")
	ContextActionService:UnbindAction("RotateRequest")

end



return ComponentCreator
