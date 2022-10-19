local WiringTool = {}
WiringTool.__index = WiringTool

local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local RayCastHandler = require(script.Parent:FindFirstChild("RayCastHandler"))

local ConnectConnectors = game.ReplicatedStorage.EventStorage:FindFirstChild("ConnectConnectors")

WiringTool.NegativeConnector = nil
WiringTool.PositiveConnector = nil

WiringTool.CanSelect = true

function WiringTool.DeselectConnector(ActionName,State,InputObject)
	
	if State == Enum.UserInputState.Begin then
		
		if InputObject.KeyCode == "Q" then

			WiringTool.NegativeConnector = nil

		end
		
		if InputObject.KeyCode == "E" then
			
			WiringTool.PositiveConnector = nil
			
		end
		
		
	end 
	
	
end

function WiringTool.SelectConnector(ActionName,State,InputObject)
	
	if State == Enum.UserInputState.Begin then
		local MouseRay = RayCastHandler.CastRay("WiringTool")
		WiringTool.CanSelect = true
		
		if MouseRay ~= nil then
			
			for _,Wire in pairs (workspace.Wires:GetChildren()) do
				
				if Wire.Attachment0 == MouseRay.Instance.Attachment or Wire.Attachment1 == MouseRay.Instance.Attachment then
					WiringTool.CanSelect = false
					break
				end
			end
			
			
			
			if  WiringTool.CanSelect == true then
				if MouseRay.Instance.Name == 'Connector0' and MouseRay.Instance.Name ~= WiringTool.NegativeConnector then
					print(MouseRay.Instance.Parent)
					WiringTool.NegativeConnector = MouseRay.Instance
					
				elseif MouseRay.Instance.Name == 'Connector1' and MouseRay.Instance.Name ~= WiringTool.PositiveConnector then
					print(MouseRay.Instance.Parent)
					WiringTool.PositiveConnector = MouseRay.Instance
					
				end
				
				
				
			end	
				
			if (WiringTool.NegativeConnector ~= nil) and (WiringTool.PositiveConnector ~= nil) then
				
				if (WiringTool.PositiveConnector.Parent == WiringTool.NegativeConnector.Parent) then
					print ('Same Block')
				else
					print('Connecting')
					print(WiringTool.NegativeConnector,WiringTool.PositiveConnector)
					ConnectConnectors:FireServer(WiringTool.NegativeConnector,WiringTool.PositiveConnector)
				end
				
					WiringTool.NegativeConnector = nil
					WiringTool.PositiveConnector = nil
					
			
				
			end
		end
	end
end


function WiringTool.Enable()
	ContextActionService:BindAction("MouseLeftClick",WiringTool.SelectConnector,false,Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction("DeselectConnectors",WiringTool.DeselectConnector,false,Enum.KeyCode.E,Enum.KeyCode.Q)
	
end

function WiringTool.Disable()
	ContextActionService:UnbindAction("MouseLeftClick")
	ContextActionService:UnbindAction("DeselectConnectors")
end



return WiringTool