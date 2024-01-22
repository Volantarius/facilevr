
AddCSLuaFile()
DEFINE_BASECLASS( "vol_base_edit" )

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PrintName = "Player Spawn Helper"
ENT.Category = "Volantarius"

function ENT:Initialize()
	
	self:SetMaterial("models/shiny")
	
	if ( CLIENT ) then return end
	
	self:SetModel( "models/editor/playerstart.mdl" )
	self:PhysicsInitBox(Vector(-16.000000, -16.000000, 0.000000), Vector(16.000000, 16.000000, 72.000000))
	self:SetUseType( ONOFF_USE )
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	
end

function ENT:UpdateHintText( name, old, new )
	self:SetOverlayText( new )
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "SpawnType", {
		KeyName = "spawnclass", Edit = {
			title = "Class",
			type = "Generic",
			waitforenter = true,
			order = 1
	} } )
	
	self:NetworkVar( "Bool", 0, "UseInVdm", {
		KeyName = "vdmuse",
		Edit = {
			title = "Use in VDM",
			type = "Boolean",
			order = 2
	} } )
	
	if ( SERVER ) then
		self:NetworkVarNotify( "SpawnType", self.UpdateHintText )
		
		self:SetSpawnType( "info_player_deathmatch" )
		self:SetUseInVdm( true )
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if CLIENT then
	local CircleMat = Material( "sgm/helpersafe" )
	
	function ENT:DrawTranslucent()
		local trace = {}
		trace.start 	= self:GetPos() + Vector(0,0,50)
		trace.endpos 	= trace.start + Vector(0,0,-300)
		trace.filter 	= self
		
		local tr = util.TraceLine( trace )
		
		if not tr.HitWorld then
			tr.HitPos = self:GetPos()
		end
		
		local color = table.Copy( self:GetColor() )
		color.a = 80--40
		
		render.SetMaterial( CircleMat )
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, 32, 32, color )
	end
end