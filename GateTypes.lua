--This file goes under the GateTagModule

--[[

Made by Supadownload

--]]

local module = {}

local GateModule = require(workspace.GateModule)
local GateSounds = game:GetService("ServerStorage").GateSounds
module.GateTypeOne = {}

function module.GateTypeOne:GetNewValues(model)
	local Values = {
		ObjectsToMove = {
			model.Gate,
		},
		PartToTouch = {
			model.Machine1.Scan,
			model.Machine2.Scan
		},
		AccessKey = "Keycard",
		Speed = nil,
		Interval = nil,
		Direction = "Left", --Overrideable with a Vector3, results may vary.
		Offset = 0,
		GateSound = GateSounds.GateSound,
		AccessSound = GateSounds.KeySound,
		StayOpenClosed = false, --if set to true the gate will not tween back to its original position
		Tween = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	}
	return Values
end
	
function module.GateTypeOne:New(model)
	local Values = module.GateTypeOne:GetNewValues(model)
	
	GateModule:New(Values.ObjectsToMove, Values.PartToTouch, Values.AccessKey, Values.Speed, Values.Interval, Values.Direction, Values.Offset, Values.GateSound, Values.AccessSound, Values.StayOpenClosed, Values.Tween)
	Values = nil
end

return module
