local RayCastHandler = {}

RayCastHandler.Camera = workspace.CurrentCamera
RayCastHandler.RayLength = 100

RayCastHandler.Mouse = game:GetService("Players").LocalPlayer:GetMouse()
RayCastHandler.CollectionService = game:GetService("CollectionService")

function RayCastHandler.CastRay(Tool : "ComponentConstructor"|"WiringTool") : RaycastResult
	
	local MouseRayParams = RaycastParams.new()
	MouseRayParams.FilterType = Enum.RaycastFilterType.Whitelist
	
	
	if (Tool == "ComponentConstructor") then
		MouseRayParams.FilterDescendantsInstances = {workspace.Baseplate}
			
	elseif (Tool == "WiringTool") then
		MouseRayParams.FilterDescendantsInstances = RayCastHandler.CollectionService:GetTagged("Connector")
	end

	
	
	local UnitRay = RayCastHandler.Camera:ScreenPointToRay( (RayCastHandler.Mouse).X, (RayCastHandler.Mouse).Y )

	local MouseRay = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * RayCastHandler.RayLength, MouseRayParams)
	
	return MouseRay
	
end


return RayCastHandler
