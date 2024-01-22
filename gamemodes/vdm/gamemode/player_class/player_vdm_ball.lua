AddCSLuaFile()

DEFINE_BASECLASS( "player_vdm" )

local PLAYER = {}

PLAYER.DisplayName			= "Ball"

PLAYER.Info					= [[Monkeyball test!]]

PLAYER.WalkSpeed			= 300		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= 0.34		-- Multiply move speed by this when crouching

PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking

PLAYER.JumpPower			= 268.4		-- How powerful our jump should be

PLAYER.MaxHealth			= 100
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.MaxArmor				= 100

PLAYER.DropWeaponOnDie		= false
PLAYER.TeammateNoCollide	= true
PLAYER.AvoidPlayers			= false

function PLAYER:DriveEntityChanged( name, old, new )
	
	if ( CLIENT ) then
		
		if ( IsValid( new ) ) then
			if ( new != old ) then
				new:setPredictable( true )
			end
		end
		
		if ( IsValid( old ) ) then
			old:setPredictable( false )
		end
		
	end
	
end

function PLAYER:SetupDataTables()
	local pl = self.Player
	
	pl:NetworkVar( "Float", 0, "OnGroundTime" )
	
	pl:NetworkVar( "Entity", 0, "DriveEntity" )
	
	pl:NetworkVarNotify( "DriveEntity", self.DriveEntityChanged )
end

function PLAYER:Spawn()
	BaseClass.Spawn( self )
	
	local pl = self.Player
	
	if ( SERVER ) then
		local ball = ents.Create( "sent_vdm_monkeyball" )
		
		ball:SetPos( pl:GetPos() + Vector(0, 0, 32) )
		
		ball:SetOwner( pl )
		
		ball:Spawn()
		
		local cock = pl:GetPlayerColor()
		
		ball:SetColor( Color( 255 * cock.x, 255 * cock.y, 255 * cock.z, 255 ) )
		
		pl:SetDriveEntity( ball )
		
		pl:SetMoveType( MOVETYPE_NONE )
		
		pl:SetViewEntity( ball )-- TEST
		
		pl:SetObserverMode( OBS_MODE_CHASE )
	end
end

function PLAYER:Death( inflictor, attacker )
	local pl = self.Player
	local ball = pl:GetDriveEntity()
	
	pl:SetViewEntity( nil )
	
	pl:SetDriveEntity( nil )
	
	if ( IsValid( ball ) ) then
		ball:Remove()
	end
end

function PLAYER:Loadout()
	local pl = self.Player
	pl:RemoveAllAmmo()
	
end

-- Horray! This will now boost when on the very next jump!
function PLAYER:StartMove( mv, cmd )
	
	local pl = self.Player
	local player_movetype = pl:GetMoveType()
	
	local ball = pl:GetDriveEntity()
	
	if ( !IsValid( ball ) ) then return end
	
	-- Yes! Allow debugging by noclipping ourselfs correctly
	if ( player_movetype == MOVETYPE_NOCLIP ) then
		
		ball:SetNetworkOrigin( mv:GetOrigin() )
		ball:SetAngles( mv:GetAngles() )
		ball:SetVelocity( Vector(0, 0, 0) )
		
		return
	else
		pl:SetMoveType( MOVETYPE_NONE )
	end
	
	local move_angles = mv:GetAngles()
	
	mv:SetOrigin( ball:GetNetworkOrigin() + Vector(0, 0, -32) )
	--mv:SetOrigin( ball:GetPos() + Vector(0, 0, -32) )
	mv:SetVelocity( ball:GetAbsVelocity() )
	--mv:SetMoveAngles( move_angles )
	
	--pl:SetNetworkOrigin( mv:GetOrigin() )
	
	local entity_angle		= move_angles
	entity_angle.roll		= ball:GetAngles().roll
	
	-- Theres suppose to be some hooks here to change the entity's angle
	
	--mv:SetAngles( entity_angle )
	
end

function PLAYER:Move( mv )
	
	local pl = self.Player
	local player_movetype = pl:GetMoveType()
	local ball = self.Player:GetDriveEntity()
	
	if ( !IsValid( ball ) ) then return end
	
	if ( player_movetype == MOVETYPE_NOCLIP ) then
		ball:SetNetworkOrigin( mv:GetOrigin() )
		ball:SetAngles( mv:GetAngles() )
		ball:SetVelocity( Vector(0, 0, 0) )
		
		return
	end
	
	local speed = 0.04 * FrameTime()
	
	--if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.10 * FrameTime() end
	
	--local ang = mv:GetMoveAngles()
	local ang = pl:EyeAngles()
	local pos = mv:GetOrigin()
	local vel = mv:GetVelocity()
	
	ang.roll = 0
	
	local forward_clamped = ang:Forward()
	forward_clamped.z = 0
	
	local right_clamped = ang:Right()
	right_clamped.z = 0
	
	local normal_forwad = 0
	local normal_side = 0
	
	if ( mv:KeyDown( IN_FORWARD ) ) then
		normal_forwad = 1
	elseif ( mv:KeyDown( IN_BACK ) ) then
		normal_forwad = -1
	end
	
	if ( mv:KeyDown( IN_MOVERIGHT ) ) then
		normal_side = 1
	elseif ( mv:KeyDown( IN_MOVELEFT ) ) then
		normal_side = -1
	end
	
	local fixed_velocity = ( forward_clamped * normal_forwad ) + ( right_clamped * normal_side )
	fixed_velocity:Normalize()
	fixed_velocity = fixed_velocity * 15000
	
	vel = vel + ( fixed_velocity * speed )
	
	if ( ( math.abs( normal_side ) + math.abs( normal_forwad ) ) < 0.1 ) then
		vel = vel * 0.02
	else
		vel = vel * 0.50
	end
	
	--if ( mv:KeyPressed( IN_JUMP ) ) then
	--	vel = vel + Vector(0,0,230)
	--end
	
	mv:SetVelocity( vel )
	mv:SetOrigin( pos )
	
end

function PLAYER:FinishMove( mv )
	
	local pl = self.Player
	local player_movetype = pl:GetMoveType()
	local ball = pl:GetDriveEntity()
	
	if ( !IsValid( ball ) ) then return end
	
	if ( player_movetype == MOVETYPE_NOCLIP ) then
		
		ball:SetNetworkOrigin( mv:GetOrigin() )
		ball:SetAngles( mv:GetAngles() )
		
		if ( SERVER ) then
			local physics_object = ball:GetPhysicsObject()
			
			physics_object:EnableMotion( false )
			physics_object:SetPos( mv:GetOrigin() )
		end
		
		return
	end
	
	--ball:SetNetworkOrigin( mv:GetOrigin() )
	ball:SetAbsVelocity( mv:GetVelocity() )
	--ball:SetAngles( mv:GetAngles() )
	
	if ( pl:Alive() ) then
		pl:SetNetworkOrigin( mv:GetOrigin() )
		--pl:SetPos( ball:GetPos() )
		
		--pl:SetAbsVelocity( -1 * mv:GetVelocity() )
	end
	
	if ( SERVER ) then
		local physics_object = ball:GetPhysicsObject()
		
		--[[if ( not IsValid( physics_object ) ) then
			self:Stop()
			return
		end]]
		
		ball:SetPhysicsAttacker( pl, 5 )
		
		physics_object:EnableMotion( true )
		physics_object:Wake()
		physics_object:AddVelocity( mv:GetVelocity() )
		
	end
	
	--[[if ( pl:Alive() ) then
		mv:SetVelocity( -1 * mv:GetVelocity() )
		mv:SetForwardSpeed( 0 )
	end]]
end

if ( CLIENT ) then
	local CameraDist = 4
	local CameraDistVel = 0.1
	
	function PLAYER:CalcView_ThirdPerson( view, dist, hullsize, ball )
		local pl = self.Player
		
		view.origin = view.origin + Vector(0,0,8)
		
		local offset = pl:EyeAngles():Forward()
		local neworigin = view.origin - (offset * dist)
		
		if ( hullsize && hullsize > 0 ) then
			
			local tr = util.TraceHull( {
				start	= view.origin - (offset * 8),
				endpos	= neworigin,
				mins	= Vector( hullsize, hullsize, hullsize ) * -1,
				maxs	= Vector( hullsize, hullsize, hullsize ),
				filter	= { pl, ball }
			} )
			
			if ( tr.Hit ) then
				neworigin = tr.HitPos
			end

		end
		
		view.origin		= neworigin
		
		view.angles		= pl:EyeAngles()
	end
	
	function PLAYER:CreateMove( cmd )
		local time_frame = RealFrameTime()
		
		CameraDistVel = CameraDistVel + cmd:GetMouseWheel() * -0.5
		
		CameraDist = CameraDist + CameraDistVel * time_frame
		CameraDist = math.Clamp( CameraDist, 2, 20 )
		CameraDistVel = math.Approach( CameraDistVel, 0, CameraDistVel * time_frame * 2 )
	end
	
	function PLAYER:CalcView( view )
		local ball = self.Player:GetDriveEntity()
		
		if ( !IsValid( ball ) ) then return end
		
		local idealdist = math.max( 10, ball:BoundingRadius() ) * CameraDist
		
		self:CalcView_ThirdPerson( view, idealdist, 2, ball )
		
		view.angles.roll = 0
	end
	
	function PLAYER:ShouldDrawLocal()
		--return false
		return true
	end
end

player_manager.RegisterClass( "player_vdm_ball", PLAYER, "player_vdm" )