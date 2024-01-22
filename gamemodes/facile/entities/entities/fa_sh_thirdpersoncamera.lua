AddCSLuaFile()

--[[
	This is what tells the client where they can see stuff from, and
	works perfectly for handling third person.
	
	Do not parent this to the player.
	Do not parent this to objects.
	
	Update this in a Tick hook, where the server can properly have the position
	networked, because this is a point entity it is predicted and movement is smooth
	
	Again this is just for render origin, it seems frustrum is actually done from render angles
	which is directly tied to the screen, and cannot be changed unless you manually draw with render.DrawScene
	WHICH IS WHY!!! You have weird occlusion, frustrum issues, and area portals not being set
]]

ENT.Type = "point"

function ENT:Initialize()
	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

-- DON'T TRANSMIT THIS
-- Yes this does infact only get handled on the server, and clients DO NOT need this network including the third person player

-- TRANSMIT_NEVER
-- TRANSMIT_ALWAYS
-- TRANSMIT_PVS
function ENT:UpdateTransmitState()
	--return TRANSMIT_NEVER
	return TRANSMIT_ALWAYS
end