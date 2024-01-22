AddCSLuaFile()
DEFINE_BASECLASS( "vol_base_edit" )

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PrintName = "Browser Test"
ENT.Category = "Volantarius"

ENT.ui_html = nil

function ENT:LoadURL( name, old, new )
	
	if SERVER then return end
	
	self.ui_html:OpenURL( new )
	
end

function ENT:Initialize()
	BaseClass.Initialize( self )
	
	if ( CLIENT ) then
		local panel_html = vgui.Create( "DHTML" )
		
		panel_html:SetPaintedManually( true )
		panel_html:SetSize( 1280, 720 )
		
		panel_html:OpenURL( "https://www.google.com" )
		
		self.ui_html = panel_html
		
		return
	end
	
	local phys = self:GetPhysicsObject()
	
	if ( phys:IsValid() ) then
		phys:EnableMotion( false )
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "URL", {
		KeyName = "url", Edit = {
			title = "URL",
			type = "Generic",
			waitforenter = true,
			order = 1
	} } )
	
	self:NetworkVarNotify( "URL", self.LoadURL )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

--https://www.youtube.com/watch?v=KavDkp1YZh0

if CLIENT then
	local CircleMat = Material( "sgm/helpersafe" )
	local Sprite = Material( "effects/pickup_ring" )
	local SpriteGlow = Material( "effects/pickup_glow" )
	local SpriteCol = Color( 40, 192, 0 )
	
	function ENT:DrawTranslucent()
		local pos = self:GetPos()
		local ang = self:GetAngles()
		
		local forward = ang:Forward()
		local right = ang:Right()
		
		if ( IsValid( self.ui_html ) ) then
			cam.Start3D2D( pos + (forward * 10) + (right * 10), ang, 0.08 )
				self.ui_html:PaintManual()
			cam.End3D2D()
		end
	end
end