local ObjectsToMove = {
	script.Parent.Gate,
}
local PartToTouch = {
	script.Parent.Machine1.Scan,
	script.Parent.Machine2.Scan
}
local AccessKey = "Keycard"
local Speed = nil
local Interval = nil
local Direction = "Left" --Overrideable with a Vector3, results may vary.
local Offset = 3
local GateSound = script.Parent.GateSound
local AccessSound = script.Parent.KeySound
local StayOpenClosed = false --if set to true the gate will not tween back to its original position
local Tween = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local GateModule = require(workspace.GateModule)
local Gate = GateModule:New(ObjectsToMove, PartToTouch, AccessKey, Speed, Interval, Direction, Offset, GateSound, AccessSound, StayOpenClosed, Tween)
