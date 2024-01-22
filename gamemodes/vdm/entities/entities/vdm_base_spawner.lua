--Base entity for the spawners
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Editable = false
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = Model( "models/weapons/w_rif_famas.mdl" )

ENT.LowPerf = false

local PickupSize = 56

local PickupSound = Sound( "VdmPickupTS.Grab" )
local RegenSound = Sound( "VdmPickupTS.Spawn" )

if (SERVER) then
	function ENT:OnPickUp( ply )
		--DO STUFF
		self:EmitSound( PickupSound )
	end
	
	function ENT:PostPickUp()
		--DO STUFF WHILE THE SPAWNER IS DISABLED
		--self:SetColor( Color(255, 0, 0, 255) )
	end
	
	function ENT:OnRespawn()
		--DO STUFF
		self:EmitSound( RegenSound )
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Taken" ) -- Is the pickup taken?
	self:NetworkVar( "Bool", 1, "PostTaken" )
	
	self:NetworkVar( "Float", 0, "PickupTime" ) -- When was the pickup taken?
	self:NetworkVar( "Float", 1, "RespawnedTime" ) -- When was the pickup respawned?
	
	self:NetworkVar( "Angle", 0, "AngOffset" ) -- Randomize if this is blank
	
	if ( SERVER ) then
		self:SetTaken( false )
		self:SetPostTaken( false )
		
		self:SetPickupTime( 0 )
		self:SetRespawnedTime( 0 )
		
		self:SetAngOffset( Angle(0,0,0) )
	end
end

function ENT:Initialize()
	self:DrawShadow( false )
	
	if ( CLIENT ) then
		--self.LowPerf = GetConVar("cl_vdm_lowperf"):GetBool()
		return
	end
	
	self:SetModel( self.Model )
	
	self:PhysicsInitSphere( PickupSize * 2, "default_silent" )
	self:SetSolid( SOLID_BBOX )
	
	self:SetSolidFlags( bit.bor( FSOLID_NOT_SOLID, FSOLID_TRIGGER ) )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetTrigger( true )
	self:DropToFloor()
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:EnableMotion(false)
		phys:EnableGravity(false)
	end
	
	local temp_pos = self:GetPos()
	self:SetPos( Vector(temp_pos.x, temp_pos.y, temp_pos.z + 32) ) -- Drop then raise exactly 32 units
	
	self:SetCollisionBounds( PickupSize * Vector(-1.0, -1.0, -1.0), PickupSize * Vector(1.0, 1.0, 1.0) )
	
	self:SetColor(Color( 40, 192, 0 ))
end

if ( SERVER ) then
	-- Don't network this
	ENT.LastTouch = 0
	
	function ENT:Think()
		local NowTime = CurTime()
		
		if ( self:GetPostTaken() && NowTime > (self:GetPickupTime() + 1.0) ) then
			-- Wait 1 second for the spawner to fade out
			-- Then all post pick up, so that we can change everything
			self:PostPickUp()
			self:SetPostTaken( false )
		end
		
		if ( self:GetTaken() && NowTime > (self:GetPickupTime() + 5.0) && NowTime > (self.LastTouch + 5.0) ) then
			self:SetRespawnedTime( CurTime() )
			self:SetTaken( false ) -- Allow this pickup to function again
			
			self:OnRespawn()
		end
		
		self:NextThink( CurTime() + 1.0 )
	end
	
	function ENT:Touch( ent )
		if ( not self:GetTaken() ) then
			if ( IsValid(ent) and ent:IsPlayer() and ent:Alive() ) then
				self:SetPickupTime( CurTime() )
				self:SetTaken( true )
				self:SetPostTaken( true )
				
				self:OnPickUp( ent )
				
				self.LastTouch = CurTime()
			end
		else
			if ( IsValid(ent) and ent:IsPlayer() and ent:Alive() ) then
				self.LastTouch = CurTime()
			end
		end
	end
end

--[[-------------------------------------------------------------------------
	CLIENT DRAWING SHIT
---------------------------------------------------------------------------]]

if ( CLIENT ) then
	local Sprite = Material( "effects/pickup_ring" )
	local SpriteGlow = Material( "effects/pickup_glow" )
	
	function ENT:Think()
		local pos = self:GetPos()
		
		local dist = pos:DistToSqr(LocalPlayer():GetPos())
		
		local color = self:GetColor()
		
		--if ( not self.LowPerf and dist < 1024000 ) then
		--[[if ( dist < 1024000 ) then
			local haloSize = 4.5 + (math.sin( UnPredictedCurTime() * 7 ) * 3.0)
			
			halo.Add({self}, color, haloSize, haloSize, 1)
		end]]
		
		--[[local dlight = DynamicLight( self:EntIndex() )
		local size = 148
		
		if ( dlight and not self:GetTaken() ) then
			size = 148 + (math.sin( UnPredictedCurTime() * 7 ) * 16)
			
			dlight.Pos = pos
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.Brightness = 0
			dlight.Decay = size * 5
			dlight.Size = size
			dlight.DieTime = UnPredictedCurTime() + 1
			
			dlight.nomodel = true
		end]]
		
		local spinVec = 128 * math.NormalizeAngle(UnPredictedCurTime() - self:GetRespawnedTime())
		local spinAng = (Angle(0, 1, 0) * spinVec) + self:GetAngOffset()
		
		self:SetAngles( spinAng )
	end
	
	function ENT:Draw()
		if ( not self:GetTaken() ) then
			-- Don't use the color from SetColor!
			render.SetColorModulation( 1.0, 1.0, 1.0 )
			self:DrawModel()
		end
	end
	
	function ENT:DrawTranslucent( STUDIO_TWOPASS )
		local pos = self:GetPos()
		local color = self:GetColor()
		color.a = 80
		
		render.SetMaterial( Sprite )
		
		if ( self:GetTaken() ) then
			local deathTime =  CurTime() - self:GetPickupTime()
			
			local brightness = deathTime < 1 and 1 - (deathTime / 1) or 0
			
			render.DrawSprite( pos, PickupSize, PickupSize, Color( color.r, color.g, color.b, 200 * brightness ) )
			
			render.DrawSprite( pos, PickupSize - 8, PickupSize - 8, Color( color.r, color.g, color.b, 200 * brightness ) )
		else
			local spawnTime = CurTime() - self:GetRespawnedTime()
			
			local brightness = spawnTime < 3 and (spawnTime / 3) or 1
			
			render.DrawSprite( pos, PickupSize, PickupSize, Color( color.r, color.g, color.b, 200 * brightness ) )
			
			render.DrawSprite( pos, PickupSize - 8, PickupSize - 8, Color( color.r, color.g, color.b, 200 * brightness ) )

			local wobble = 96 + (math.sin( UnPredictedCurTime() * 7 ) * 64)

			render.SetMaterial( SpriteGlow )
			render.DrawSprite( pos, wobble, wobble, color )
		end
	end
end