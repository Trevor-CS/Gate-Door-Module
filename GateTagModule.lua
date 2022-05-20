--[[

Made by Supadownload.

--]]

local module = {}

local CollectionService = game:GetService("CollectionService")

local ServerModule = require(game:GetService("ServerScriptService").ServerModule)
local GateTypes = require(script.GateTypes)
local Group = ServerModule.GroupID

local TagsToWatch = {
	"GateTypeOne"
}

local TagConnections = {}

-----------------------------------------------

--local SpecialCollideParts = {}

function onAdded(model, tagName)
	GateTypes[tagName]:New(model)
end

--[[function onRemoved(model)
	if SpecialCollideParts[model] then
		
		SpecialCollideParts[model] = nil
	end
end--]]

for _,v in pairs(TagsToWatch) do
	--TagConnections[i.."REMOVECONNECTION"] = CollectionService:GetInstanceRemovedSignal(i):Connect(onRemoved)
	TagConnections[v.."ADDCONNECTION"] = CollectionService:GetInstanceAddedSignal(v):Connect(onAdded)
	
	for _,p in pairs(CollectionService:GetTagged(v)) do
		onAdded(p, v)
	end
end

return module
