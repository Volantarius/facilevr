AddCSLuaFile()

ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = false

function ENT:UpdateRichochet( name, old, new )
	self:SetNetworkOrigin( new )
	self:SetPos( new )
	
	self.pos = new
	
	sound.Play( Sound( "FX_RicochetSound.Ricochet" ), new, 180, 100, 1 )
end

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "HitPosition")
	self:NetworkVar("Vector", 1, "HitNormal")
	self:NetworkVar("Int", 0, "Richochets")
	
	self:NetworkVarNotify("HitPosition", self.UpdateRichochet)
end

local butt_color = Color(255,255,255)
local butt_color_two = Color(255,255,0)
local butt_color_client = Color(0,255,255)

function ENT:Initialize()
	self:SetModel(Model("models/crossbow_bolt.mdl"))
	
	self:DrawShadow(false)
	
	self.RemovePlease = false
	
	if (SERVER) then
		--self.LastCurTime = CurTime() - (FrameTime() * 30)
		self.LastCurTime = CurTime() - (FrameTime() * 10)
		
		self:NextThink(CurTime())
		
		self.StopCalc = false
	else
		self.LastCurTime = CurTime()
	end
	
	self.CreatedTime = CurTime()
	
	self.DieTime = CurTime() + 3
	
	self.pos = self:GetNetworkOrigin()
	self.lastpos = self.pos
	
	self.FrameCounter = 0
	
	self.bullet_next = {
		Num = 1,
		Spread = Vector(0,0,0),
		Tracer = 0,
		Force = 1.5,
		Damage = 22,
		AmmoType = "AR2",
		Attacker = nil,
		
		--HullSize
		--TracerName
		--IgnoreEntity
		
		Distance = 12,
		Src = self.lastpos,
		Dir = Vector(0,0,0),
		
		--[[Callback = function( attacker, tr, dmg )
			if ( tr.Hit ) then
				self.RemovePlease = true
				
				if SERVER then
					debugoverlay.Sphere(tr.HitPos, 3, 4, butt_color_two, false)
					
					debugoverlay.Line(tr.HitPos, self.pos, 4, butt_color, false)
				end
				
				if CLIENT then
					debugoverlay.Sphere(tr.HitPos, 3, 4, butt_color_client, false)
					
					debugoverlay.Line(tr.HitPos, self.pos, 4, butt_color_two, false)
				end
			end
		end]]
		
		Callback = function( attacker, tr, dmg )
			if SERVER then
				debugoverlay.Sphere(tr.HitPos, 3, 2, butt_color_two, false)
			end
			
			if ( tr.HitSky ) then
				self.RemovePlease = true
				return false
			end
			
			if ( not tr.Hit ) then return false end
			
			local velocity = self.pos - self.lastpos
			local velnorm = velocity:GetNormalized()
			
			local ricoDot = velnorm:Dot( tr.HitNormal )
			
			if ( ricoDot > -0.5 && ricoDot < 0 ) then
				local ricochetVector = (-2 * ricoDot * tr.HitNormal) + velnorm
				
				local newpos = tr.HitPos
				
				--self:SetHitPosition( tr.HitPos )
				--self:SetHitNormal( ricochetVector )
				
				if CLIENT then
					self:SetNetworkOrigin( newpos )
				end
				self:SetPos( newpos )
				
				self.lastpos = newpos + ricochetVector
				self.pos = newpos
				
				self:SetRichochets( self:GetRichochets() + 1 )
				
				self:SetAngles( ricochetVector:Angle() )
			else
				self.RemovePlease = true
			end
		end
	}
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think()
	local fwrd = self:GetAngles():Forward()
	
	-- This is correctly predicted now
	local nowTime = CurTime()
	
	local delta = nowTime - self.LastCurTime
	
	self.LastCurTime = nowTime
	
	local pos = self:GetNetworkOrigin()
	
	-- Handle client seperately which still fits with the predicted movement
	if (CLIENT) then
		pos = self.pos
	end
	
	--local flightTime = nowTime - self.CreatedTime
	
	-- 330 for BB
	--local magnitude = (fwrd * (330 * 16)) + (Vector(0,0,-514.78) * flightTime * flightTime)
	
	local magnitude = (fwrd * 7600)
	
	-- Scale velocitys with our slice of time
	local newpos = pos + ( magnitude * delta )
	
	local velocity = newpos - self.lastpos
	
	--if CLIENT then
	self:SetNetworkOrigin( newpos )
	--end
	
	if (CLIENT) then
		self.FrameCounter = self.FrameCounter + delta
		
		if (self.FrameCounter >= (1/60)) then
			self.FrameCounter = 0
			
			self.lastpos = self.pos
		end
		
		self.pos = newpos
	else
		self.lastpos = self.pos
		self.pos = newpos
	end
	
	if (not self.RemovePlease) then
		-- Calc bullets
		if (SERVER) then self:SetLagCompensated( true ) end
		
		local owner = self:GetOwner()
		
		self.bullet_next.Dir = velocity:GetNormalized()
		self.bullet_next.Src = self.lastpos
		self.bullet_next.Distance = velocity:Length()
		
		if (SERVER and not game.SinglePlayer()) then
			owner:FireBullets( self.bullet_next, true )-- SUPPRESS YO, set to true!
		else
			owner:FireBullets( self.bullet_next, false )
		end
		
		if SERVER then
			debugoverlay.Sphere(self.pos, 3, 4, butt_color, false)
			
			debugoverlay.Line(self.pos, self.lastpos, 4, butt_color, false)
		end
		
		--if CLIENT then
		--	debugoverlay.Line(self.pos, self.lastpos, 4, butt_color_client, false)
		--end
		
		if (SERVER) then self:SetLagCompensated( false ) end
	end
	
	if (CLIENT) then return end
	
	if (self.RemovePlease and not self.StopCalc) then
		self.DieTime = nowTime + (FrameTime() * 1)
		self.StopCalc = true
	end
	
	if (nowTime > self.DieTime) then
		self:Remove()
	end
end

if ( CLIENT ) then
	--local MAT_LASER = Material( "effects/yellowflare" )
	--local MAT_BLUR  = Material( "vol/voltracer" )
	local MAT_LASER = Material( "vol/airsoftpellet" )
	local MAT_BLUR  = Material( "vol/projmotionblur" )
	
	-- Glow in the dark PELLET
	--[[function ENT:DrawTranslucent()
		render.SetMaterial(MAT_LASER)
		
		local lcolor = render.GetLightColor( self.pos )
		
		local glow = 1 - (math.Clamp( lcolor.x + lcolor.y + lcolor.z, 0, 3 ) / 3)
		
		glow = (glow * 150) + 50
		
		render.DrawSprite( self.pos, 0.5, 0.5, Color(10, glow, 10, 255) )
		
		render.SetMaterial(MAT_BLUR)
		
		render.DrawBeam( self.pos, self.lastpos,
					1, -- W
					0.8, -- ST
					0, -- EN
					Color(10, glow, 10, 170) )
		
		--self:DrawModel()
	end]]
	
	-- NORMAL BB PELLET
	--[[function ENT:DrawTranslucent()
		render.SetMaterial(MAT_LASER)
		
		local lcolor = render.GetLightColor( self.pos )
		
		local Re = math.Round( 255 * lcolor.x )
		local Gr = math.Round( 255 * lcolor.y )
		local Bl = math.Round( 255 * lcolor.z )
		
		render.DrawSprite( self.pos, 0.5, 0.5, Color(Re, Gr, Bl, 255) )
		
		render.SetMaterial(MAT_BLUR)
		
		render.DrawBeam( self.pos, self.lastpos,
					1, -- W
					0.8, -- ST
					0, -- EN
					Color(Re, Gr, Bl, 170) )
		
		--self:DrawModel()
	end]]
	
	--[[function ENT:DrawTranslucent()
		if (self.RemovePlease) then return end
		
		render.SetMaterial(MAT_LASER)
		
		render.DrawSprite( self.pos, 13, 13, Color(255, 0, 10, 255) )
		
		render.DrawSprite( self.pos, 8.1, 8.1, Color(400,400,400,255) )
		
		render.SetMaterial(MAT_BLUR)
		
		render.DrawBeam( self.pos, self.lastpos,
					8, -- W
					0.8, -- ST
					0, -- EN
					Color(400,400,400,255) )
		
		render.DrawBeam( self.pos, self.lastpos,
					13, -- W
					0.8, -- ST
					0, -- EN
					Color(255, 0, 10, 255) )
		
		--self:DrawModel()
	end]]
	
	function ENT:DrawTranslucent()
		if (self.RemovePlease) then return end
		
		--[[render.SetMaterial(MAT_LASER)
		
		render.DrawSprite( self.pos, 8.1, 8.1, Color(0,400,0,255) )
		
		render.SetMaterial(MAT_BLUR)
		
		render.DrawBeam( self.pos, self.lastpos,
					4, -- W
					0, -- ST
					1, -- EN
					Color(0,400,0,255) )]]
		
		self:DrawModel()
	end
end