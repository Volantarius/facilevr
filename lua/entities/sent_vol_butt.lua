AddCSLuaFile()

ENT.Type = "anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = false

function ENT:SetupDataTables()
	--self:NetworkVar("Vector", 0, "BulletDirection")
	--self:NetworkVar("Vector", 1, "HitPosition")
	--self:NetworkVar("Vector", 2, "HitNormal")
	
	--self:NetworkVar("Float", 0, "HitFraction")
end

local butt_color = Color(255,255,255)
local butt_color_two = Color(255,255,0)
local butt_color_client = Color(0,255,255)

function ENT:Initialize()
	self:SetModel(Model("models/crossbow_bolt.mdl"))
	
	self:DrawShadow(false)
	
	self.RemovePlease = false
	
	self.LocalHitFraction = 0
	
	local now = CurTime()
	
	if (SERVER) then
		--self.LastCurTime = now - (FrameTime() * 30)
		self.LastCurTime = now - (FrameTime() * 10)
		
		self:NextThink(now)
		
		self.StopCalc = false
	else
		self.LastCurTime = now
	end
	
	self.CreatedTime = now
	
	self.DieTime = now + 3
	
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
		Ricos = 0,
		
		Callback = function( attacker, tr, dmg )
			local ricos = self.bullet_next.Ricos
			
			if ( tr.Hit ) then
				local HitPosition = tr.HitPos
				local HitNormal = tr.HitNormal
				local HitFraction = tr.Fraction
				
				if ( SERVER ) then
					debugoverlay.Sphere(HitPosition, 3, 5, butt_color_two, false)
					
					--debugoverlay.Line(HitPosition, self.pos, 5, butt_color, false)
				end
				
				if ( CLIENT ) then
					debugoverlay.Sphere(HitPosition, 3, 3, butt_color_client, false)
					
					--debugoverlay.Line(HitPosition, self.pos, 3, butt_color_client, false)
				end
				
				if (ricos > 1) then return end
				
				--print("ass", ricos)
				
				local forward = self.BulletDirection
				
				local rico_dot = forward:Dot( HitNormal )
				
				if ( rico_dot > -0.5 && rico_dot < 0 ) then
					local owner = self:GetOwner()
					
					local ricochetVector = (-2 * rico_dot * HitNormal) + forward
					ricochetVector:Normalize()
					
					local overall_fraction = HitFraction + self.LocalHitFraction
					
					--print("cunt face", overall_fraction, HitFraction, self.LocalHitFraction)
					
					if (overall_fraction >= 1) then return end
					
					overall_fraction = math.Clamp(overall_fraction, 0, 1)
					
					local dist = self.BulletDistance * (1 - overall_fraction)
					
					self.bullet_next.Dir = ricochetVector
					self.bullet_next.Src = HitPosition
					self.bullet_next.Distance = dist
					self.bullet_next.Ricos = ricos + 1
					
					self.LocalHitFraction = overall_fraction
					
					local final_position = HitPosition + (ricochetVector * dist)
					
					self.lastpos = HitPosition
					self.pos = final_position
					
					self:SetAngles( ricochetVector:Angle() )-- Seperate to locals
					
					self.BulletDirection = ricochetVector
					
					if (SERVER and not game.SinglePlayer()) then
						owner:FireBullets( self.bullet_next, true )
					else
						owner:FireBullets( self.bullet_next, true )-- TEST???
					end
				else
					self.RemovePlease = true
				end
			end
		end
	}
	
	self.BulletDirection = self:GetAngles():Forward()
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Think()
	local fwrd = self.BulletDirection
	
	-- This is correctly predicted now
	local nowTime = CurTime()
	
	local delta = nowTime - self.LastCurTime
	
	self.LastCurTime = nowTime
	
	local pos = self.pos
	
	self.BulletDistance = 7600 * delta
	--self.BulletDistance = 2048 * delta
	
	local BLAH_DIST = self.BulletDistance
	
	local magnitude = (fwrd * BLAH_DIST)
	
	-- Scale velocitys with our slice of time
	local newpos = pos + magnitude
	
	--[[if (CLIENT) then
		self.FrameCounter = self.FrameCounter + delta
		
		if (self.FrameCounter >= (1/60)) then
			self.FrameCounter = 0
			
			self.lastpos = self.pos
		end
		
		self.pos = newpos
	else]]
		self.lastpos = self.pos
		self.pos = newpos
	--end
	
	if SERVER then
		debugoverlay.Sphere(self.pos, 3, 4, butt_color, false)
		
		--debugoverlay.Line(self.pos, self.lastpos, 4, butt_color, false)
	end
	
	--[[if CLIENT then
		debugoverlay.Line(self.pos, self.lastpos, 4, butt_color_client, false)
	end]]
	
	if (not self.RemovePlease) then
		self.LocalHitFraction = 0-- Reset for the bullet's callback ricochets
		
		-- Calc bullets
		if (SERVER) then self:SetLagCompensated( true ) end
		
		local owner = self:GetOwner()
		
		self.bullet_next.Dir = fwrd
		self.bullet_next.Src = self.lastpos
		self.bullet_next.Distance = BLAH_DIST
		
		if (SERVER and not game.SinglePlayer()) then
			owner:FireBullets( self.bullet_next, true )-- SUPPRESS YO, set to true!
		else
			owner:FireBullets( self.bullet_next, true )
		end
		
		if (SERVER) then self:SetLagCompensated( false ) end
	end
	
	self:SetNetworkOrigin( self.pos )-- This is only just to visually look right lol
	
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
	
	function ENT:DrawTranslucent()
		if (self.RemovePlease) then return end
		
		render.SetMaterial(MAT_LASER)
		
		render.DrawSprite( self.pos, 6, 6, Color(0,400,0,255) )
		
		render.SetMaterial(MAT_BLUR)
		
		render.DrawBeam( self.pos, self.lastpos,
					12, -- W
					0.5, -- ST
					1, -- EN
					Color(0,400,0,255) )
		
		--self:DrawModel()
	end
end