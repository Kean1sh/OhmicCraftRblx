local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ComponentCreator = require(script:FindFirstChild("ComponentCreator"))
local WiringTool = require(script:FindFirstChild("WiringTool"))


-- ToolManager Data --

-- ActiveTool stores which tool is currently
-- active/being used by the player.
-- The value is represented by a string
-- Example :
-- ActiveTool = "WiringTool"
local ActiveTool = ""

-- ToolList stores the key input for each tool in a dictionary
-- each key represents the Enum keycode
-- example :
-- Enum.KeyCode.One means key 1 on the keyboard

-- each value represents the tool name stored as a string
-- Example Entry:
-- [Enum.KeyCode.One] = "ComponentCreator"

local ToolList = {
	[Enum.KeyCode.One] = "ComponentCreator",
	[Enum.KeyCode.Two] = "WiringTool",
	[Enum.KeyCode.Three] = "ComponentRemover"
}

-- As each of the tools are modulescripts,
-- they can not be activated unless called upon by
-- a localscript or a script. We use ToolActivate()
-- to enable the desired tool and disable the unused tools
-- If ComponentCreator is currently in use, we have to disable
-- the WiringTool, ComponentRemover, and ComponentModifier

-- ToolActivate() is called by ToolRequest() after a new
-- tool is equipped
function ToolActivate()
	
	-- If the ActiveTool is ComponentCreator:
	if ActiveTool == "ComponentCreator" then
		-- Disable all the other tools
		WiringTool.Disable()
		-- Enable ComponentCreator once all the other 
		-- tools are disabled.
		ComponentCreator.Enable()
		
		
	-- If the ActiveTool is WiringTool:	
	elseif ActiveTool == "WiringTool" then
		-- Disable all the other tools
		ComponentCreator.Disable()
		-- Enable WiringTool once all the other 
		-- tools are disabled.
		WiringTool.Enable()
		
	end

end

-- ToolRequest is activated once the player wants to equip
-- by pressing either 1,2,3, or 4 on the keyboard.

-- ActionName represents the string of the action being performed
-- in reference to BindAction, in ToolRequest this would be "ToolHandler"

-- State stores the Enum.UserInputState of the InputObject, this represents
-- what condition of the button press that activates this function
-- for example, Enum.UserInputState.Begin means a function would only activate
-- at the start of the button press

-- InputObject represents the user input
function ToolRequest(ActionName,State,InputObject)
	
	-- Get the keycode value of the InputObject
	local KeyInput = InputObject.KeyCode
	
	-- Check if the tool exists by checking if that Key is listed in ToolList
	-- AND also make sure that the player is not equipping the same tool that
	-- is already enabled:
	if ToolList[KeyInput] ~= nil and ToolList[KeyInput] ~= ActiveTool then
		print('Change Tool')
		-- Change the value of ActiveTool to the new tool
		ActiveTool = ToolList[KeyInput]
		-- Activate this new tool.
		ToolActivate()
	end
	
	
end



-- ContextActionService:BindAction() is used to bind an input to
-- a function. In this case we are binding the numbers 1,2,3,4 represented
-- by their Enum.KeyCode(s)

-- The first parameter represents the ActionName, it essentially acts like a 
-- terminal that connects a function to the accepted inputs.
-- In this case ToolHandler can only be activated by the numbers listed earlier

-- The second parameter represents the name of the function we are binding the
-- inputs to. Not to be confused with ActionName, this is the actual function
-- that gets called when the of the Action is valid.

-- The third parameter represents whether or not a ROBLOX OBJECT such as a GUI
-- or a BasePart is involved in this action.

-- The excess parameters are used to store the Enum.KeyCode(s) that are accepted
-- as inputs
-- In this case we only accept the keycodes of the numbers listed earlier.
ContextActionService:BindAction("ToolHandler",ToolRequest,false,Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three)


