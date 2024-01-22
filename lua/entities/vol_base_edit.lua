
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = true

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	if ( CLIENT ) then return end

	self:SetModel( "models/maxofs2d/cube_tool.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:EnableForwardArrow()
	self:SetBodygroup( 1, 1 )
end

-- ////////////////////////////////////////////

if ( CLIENT ) then
	ENT.MaxWorldTipDistance = 512
	
	function ENT:BeingLookedAtByLocalPlayer()
		local ply = LocalPlayer()
		if ( !IsValid( ply ) ) then return false end
		
		local view = ply:GetViewEntity()
		local dist = self.MaxWorldTipDistance
		dist = dist * dist
		
		-- If we're spectating a player, perform an eye trace
		if ( view:IsPlayer() ) then
			return view:EyePos():DistToSqr( self:GetPos() ) <= dist && view:GetEyeTrace().Entity == self
		end
		
		-- If we're not spectating a player, perform a manual trace from the entity's position
		local pos = view:GetPos()
		
		if ( pos:DistToSqr( self:GetPos() ) <= dist ) then
			return util.TraceLine( {
				start = pos,
				endpos = pos + ( view:GetAngles():Forward() * dist ),
				filter = view
			} ).Entity == self
		end
		
		return false
	end
	
	function ENT:Think()
		local text = self:GetOverlayText()
		
		if ( text != "" && self:BeingLookedAtByLocalPlayer() ) then
			AddWorldTip( self:EntIndex(), text, 0.5, self:GetPos(), self )
			
			halo.Add( { self }, color_white, 1, 1, 1, true, true )
		end
	end
	
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:SetOverlayText( text )
	self:SetNWString( "GModOverlayText", text )
end

function ENT:GetOverlayText()
	local txt = self:GetNWString( "GModOverlayText" )
	
	if ( txt == "" ) then
		return ""
	end
	
	return txt
end
