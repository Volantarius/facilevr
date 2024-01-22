AddCSLuaFile()

DEFINE_BASECLASS( "player_facile" )

local PLAYER = {}

PLAYER.DisplayName			= "Nutter's Tools"

PLAYER.Info					= [[Lots of weapons! Primarily for debugging.]]

-- So if we wanna play bunnyhop/deathrun using vdm, just set the walk, run, speed to 250
--[[
	Move speeds from CS:S
	couching: walk -> 85, slow -> 3.31
	walking: 250, slow -> 130
	
	Jump speed: no forward -> 283.99
	Jump speed: walking -> 128.35
	Jump speed: crouching -> 289.99 or 277.99
]]

PLAYER.WalkSpeed			= 300		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.CrouchedWalkSpeed	= 0.34		-- Multiply move speed by this when crouching

--0.15
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
--CSS
--PLAYER.DuckSpeed			= 0.45
--PLAYER.UnDuckSpeed		= 0.216

PLAYER.JumpPower			= 268.4		-- How powerful our jump should be

PLAYER.MaxHealth			= 100
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.MaxArmor				= 100

PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide	= false		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players

PLAYER.UseVMHands			= true		-- Uses viewmodel hands

PLAYER.CanUseFlashlight		= true		-- Can we use the flashlight

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Float", 0, "OnGroundTime")
end

function PLAYER:Spawn()
	BaseClass.Spawn( self )
	
	-- This makes crouch slow walk also 3.31 YAY
	self.Player:SetSlowWalkSpeed( 130 )
	
	-- No zoom for you!
	self.Player:SetCanZoom( false )
	
	--self.Player:EmitSound( Sound( "VdmSpawn" ) )
	
	self.Player:VDMSetupPlayer()
	
	--[[local ed = EffectData()
	ed:SetOrigin( self.Player:GetPos() )
	ed:SetEntity( self.Player )
	util.Effect( "vdmspawn", ed, true, true )
	util.Effect( "propspawn", ed, true, true )
	
	-- Might accidentally appear on other machines
	ed:SetEntity( self.Player:GetViewModel( 0 ) )
	util.Effect( "propspawnviewmodel", ed, true, true )
	ed:SetEntity( self.Player:GetViewModel( 1 ) )
	util.Effect( "propspawnviewmodel", ed, true, true )
	ed:SetEntity( self.Player:GetViewModel( 2 ) )
	util.Effect( "propspawnviewmodel", ed, true, true )]]
end

function PLAYER:Loadout()
	local ply = self.Player
	ply:RemoveAllAmmo()
	
	ply:GiveAmmo( 800,	"Pistol",		true )
	ply:GiveAmmo( 800,	"SMG1",			true )
	ply:GiveAmmo( 200,	"grenade",		true )
	ply:GiveAmmo( 800,	"357",			true )
	ply:GiveAmmo( 800,	"Buckshot",		true )
	ply:GiveAmmo( 800,	"AR2",			true )
	ply:GiveAmmo( 800,	"XBowBolt",		true )
	ply:GiveAmmo( 100,	"slam",			true )
	
	ply:GiveAmmo( 800,	"vdm_556mm",	true )
	ply:GiveAmmo( 800,	"vdm_762mm",	true )
	ply:GiveAmmo( 800,	"vdm_9mm",		true )
	ply:GiveAmmo( 200,	"vdm_50ae",		true )
	
	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_physgun" )
	
	ply:Give( "weapon_m4a1" )
	ply:Give( "weapon_scout" )
	ply:Give( "weapon_famas" )
	ply:Give( "weapon_glock" )
	ply:Give( "weapon_p228" )
	ply:Give( "weapon_deagle" )
	ply:Give( "weapon_mp5navy" )
	ply:Give( "weapon_xm1014" )
	
	ply:Give( "weapon_vdm_displacer" )
	ply:Give( "weapon_vdm_fartgun" )
	ply:Give( "weapon_vdm_fingergun" )
	ply:Give( "weapon_vdm_garand" )
	ply:Give( "weapon_vdm_grenadelauncher" )
	ply:Give( "weapon_vdm_lazer" )
	ply:Give( "weapon_vdm_minigun" )
	ply:Give( "weapon_vdm_nailgun" )
	ply:Give( "weapon_vdm_proxmine" )
	ply:Give( "weapon_vdm_turtles" )
	ply:Give( "weapon_vdm_shotty" )
	ply:Give( "weapon_vdm_shovel" )
	ply:Give( "weapon_vdm_slowmo" )
	
	ply:Give( "weapon_vcod_p90" )
	
	ply:Give( "weapon_vdm_tool_destroy" )
end

local JUMPING
local lastOnGround = true
local lastGroundTime = 0

-- Horray! This will now boost when on the very next jump!
function PLAYER:StartMove( move )
	local ply = self.Player
	local onGround = ply:OnGround()
	local nowTime = CurTime()
	
	if ( onGround ~= lastOnGround and onGround ) then
		ply:SetOnGroundTime( nowTime )
	end
	
	if ( bit.band( move:GetButtons(), IN_JUMP ) ~= 0 and bit.band( move:GetOldButtons(), IN_JUMP ) == 0 ) then
		local groundTime = ply:GetOnGroundTime()
		
		-- Boost only if they have been on the ground for 0.3 seconds
		-- Set to be lower since this is now predicted
		if ( onGround and (nowTime - groundTime) < 0.15 ) then
			JUMPING = true
			ply:SetJumpPower(280)
			
			--ply:ChatPrint("BOOST "..(nowTime - groundTime))
		else
			ply:SetJumpPower(268.4)
		end
	end
	
	lastOnGround = onGround
end

-- SASS Deathrun rip, because its fun to easy bhop
function PLAYER:Move( move )
	if ( not self.Player:Alive() ) then return end
	if ( self.Player:OnGround() or self.Player:WaterLevel() > 0 ) then return end --Add water level checks
	
	local aim = move:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fSpeed = move:GetForwardSpeed()
	local sSpeed = move:GetSideSpeed()
	
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()
	
	local wishvel = (forward * fSpeed) + (right * sSpeed)
	wishvel.z = 0
	
	local wishspeed = wishvel:Length()
	local maxSpeed = move:GetMaxSpeed()
	
	if ( wishspeed > maxSpeed ) then
		wishvel = wishvel * ( maxSpeed / wishspeed )
		wishspeed = maxSpeed
	end
	
	local clampWishSpeed = math.Clamp(wishspeed, 0, 35)
	
	local wishdir = wishvel:GetNormal()
	local current = move:GetVelocity():Dot(wishdir)
	
	local addspeed = clampWishSpeed - current
	
	if ( addspeed <= 0 ) then return end
	
	local accelspeed = (150) * wishspeed * FrameTime()
	
	if ( accelspeed > addspeed ) then
		accelspeed = addspeed
	end
	
	local vel = move:GetVelocity()
	vel = vel + ( wishdir * accelspeed )
	
	move:SetVelocity( vel )
end

function PLAYER:FinishMove( move )
	if ( JUMPING ) then
		self.Player:SetJumpPower(280)
	else
		self.Player:SetJumpPower(268.4)
	end
	
	JUMPING = nil
end

player_manager.RegisterClass( "player_vdm", PLAYER, "player_facile" )