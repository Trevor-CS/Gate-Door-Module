--[[

Made by Supadownload.

--]]

local TweenService  = game:GetService("TweenService")
local Debris        = game:GetService("Debris")

local Gate = {}
Gate.__index = Gate
    
function Gate:New(Gates, TouchObjects, AccessObject, Speed, Interval, Direction, Offset, GateSound, AccessSound, StayOpenClosed, Tween)
	assert(type(Gates)=="table", "Gate objects must be passed as a table")
	assert(type(TouchObjects)=="table", "Touch objects must be passed as a table")
	
	local newGate 		= setmetatable({}, Gate)
	
	newGate.Gates 		= Gates
	newGate.Speed 		= type(Speed)=="number" and Speed or 3
	newGate.Interval 	= type(Interval)=="number" and Interval or 5
	newGate.Offset 		= type(Offset)=="number" and Offset or 0
	newGate.AccessSound = ((AccessSound) and AccessSound:IsA("Sound")) and AccessSound or nil
	newGate.GateSound 	= ((GateSound) and GateSound:IsA("Sound")) and GateSound or nil
	newGate.Stay		= type(StayOpenClosed)=="boolean" and StayOpenClosed or false
	newGate.TweenInfo 	= typeof(Tween)=="TweenInfo" and (Tween) or TweenInfo.new(newGate.Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	newGate.Speed 		= newGate.TweenInfo.Time
	
	newGate.OriginalCF	= {}
	newGate.Active 		= false
	newGate.Touched 	= false
	
	for _,v in pairs(Gates) do
		newGate.OriginalCF[v] = v:GetPivot()
	end
	
	if typeof(Direction) == "Vector3" then
		newGate.Direction = Direction
	else
		if Direction == "Forward" then
			newGate.Direction = 1
		elseif Direction == "Backward" then
			newGate.Direction = -1
		elseif Direction == "Right" then
			newGate.Direction = 2
		elseif Direction == "Left" then
			newGate.Direction = -2
		elseif Direction == "Up" then
			newGate.Direction = 3
		elseif Direction == "Down" then
			newGate.Direction = -3
		else
			newGate.Direction = 2
		end
	end
	
	for _,v in pairs(TouchObjects) do
		local ProxPrompt = v:FindFirstChildWhichIsA("ProximityPrompt")
		if ProxPrompt then
			ProxPrompt.PromptButtonHoldBegan:Connect(function(plr)
				local connection
				local pTime = os.clock()
				connection = ProxPrompt.Triggered:Connect(function(plrr)
					if plrr ~= plr then return end
					if (os.clock() - pTime >= (ProxPrompt.HoldDuration-0.2)) then
						if newGate.Touched == true then return end
						newGate.Touched = true
						newGate:Use(v)
						newGate.Touched = false
					end
				end)
				delay(ProxPrompt.HoldDuration+0.2, function()
					connection:Disconnect()
					connection = nil
				end)
			end)
		elseif type(AccessObject) ~= "string" then
			ProxPrompt = nil
			v.Touched:Connect(function(TouchPart)
				if newGate.Touched == true then return end
				newGate.Touched = true
				newGate:Use(v)
				newGate.Touched = false
			end)
		else
			ProxPrompt = nil
			v.Touched:Connect(function(TouchPart)
				if newGate.Touched == true or TouchPart.Parent.ClassName ~= "Tool" or TouchPart.Parent.Name ~= AccessObject then return end
				newGate.Touched = true
				newGate:Use(v)
				newGate.Touched = false
			end)
		end
	end
	--return newGate
end

function TweenModel(Sound, TInfo, info)
	local BE = Instance.new("BindableEvent")
	local BE2 = Instance.new("BindableEvent")
	local Counter = 0
	for _,v in pairs(info) do
		local sound
		if Sound then
			sound = Sound:Clone()
			sound.Parent = v[1].PrimaryPart
			sound:Play()
		end
		local CFrameValue = Instance.new("CFrameValue")
		CFrameValue.Value = v[1]:GetPivot()
		
		local CFrameChange = CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			v[1]:PivotTo(CFrameValue.Value)
		end)
		
		local Tween = TweenService:Create(CFrameValue, TInfo, {Value = v[2]})
		Tween:Play()
		
		Tween.Completed:Connect(function()
			if sound then sound:Stop() sound:Destroy() end
			CFrameValue:Destroy()
			CFrameChange:Disconnect()
			Tween:Destroy()
			Counter += 1
			BE:Fire()
		end)
	end
	
	if Counter == #info then
		BE2:Fire()
	else
		BE.Event:Connect(function()
			if Counter == #info then
				BE2:Fire()
			end
		end)
	end
	BE2.Event:Wait()
	BE:Destroy()
	BE2:Destroy()
	return
end

function GetDestinationVector3(Direction, CF, Size, Offset)
	if typeof(Direction) == "Vector3" then
		return ((Direction * Size) + (Direction*Offset))
	else
		if Direction == 1 then
			return ((CF.LookVector.Unit * Size.Z) + (CF.LookVector.Unit*Offset))
		elseif Direction == -1 then
			return -((CF.LookVector.Unit * Size.Z) + (CF.LookVector.Unit*Offset))
		elseif Direction == -2 then
			return -((CF.RightVector.Unit * Size.X) + (CF.RightVector.Unit*Offset))
		elseif Direction == 3 then
			return ((CF.UpVector.Unit * Size.Y) + (CF.UpVector.Unit*Offset))
		elseif Direction == -3 then
			return -((CF.UpVector.Unit * Size.Y) + (CF.UpVector.Unit*Offset))
		end
	end
	return ((CF.RightVector.Unit * Size.X) + (CF.RightVector.Unit*Offset)) --Default is Direction == 2
end

function PrepareTweenObjects(ObjectTable, CF, Direction, Offset)
	local GatesAndCF = {}
	local InternalCounter = 1
	if Direction then
		for _,v in pairs(ObjectTable) do
			table.insert(GatesAndCF,
				{
					v,
					(CF[v] + GetDestinationVector3(Direction, CF[v], (v.PrimaryPart and v.PrimaryPart.Size or v:GetExtentsSize()), Offset))
				}
			)
			
			if InternalCounter%2 ~= 0 then
				Direction *= -1
			end
			InternalCounter += 1
		end
	else
		for _,v in pairs(ObjectTable) do
			table.insert(GatesAndCF,
				{
					v,
					CF[v]
				}
			)
		end
	end
	return GatesAndCF
end

function Gate:Use(TouchPart)
	if self.AccessSound then
		local AccessSound = self.AccessSound:Clone()
		AccessSound.Parent = TouchPart
		AccessSound:Play()
		Debris:AddItem(AccessSound, AccessSound.TimeLength+0.3)
		AccessSound = nil
	end
	-----------------------------------------------------------------------------------------------------
	local GatesAndCF = {}
	if self.Active == false then
		self.Active = true
		GatesAndCF = PrepareTweenObjects(self.Gates, self.OriginalCF, self.Direction, self.Offset)
		TweenModel(self.GateSound, self.TweenInfo, GatesAndCF)

		if self.Stay == false then
			wait(self.Interval)
			GatesAndCF = PrepareTweenObjects(self.Gates, self.OriginalCF)

			TweenModel(self.GateSound, self.TweenInfo, GatesAndCF)
			self.Active = false
		end
	else
		--stay open
		GatesAndCF = PrepareTweenObjects(self.Gates, self.OriginalCF)

		TweenModel(self.GateSound, self.TweenInfo, GatesAndCF)
		self.Active = false
	end

	GatesAndCF = nil
end

return Gate
