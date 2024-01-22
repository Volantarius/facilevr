AddCSLuaFile()

--[[
	TODO lol
	
	We need a specific gametype round check so that we can have counter-strike
	rules attached for bomb defusal or hostage rescue.
]]

function GM:SetupHiddenRules()
	if ( SERVER ) then
		
		-- Fuck the original death sound call..
		
	else
		
		
		
	end
end

--[[----	----	----	----	----	----	----	----]]

function GM:ShutdownHiddenRules()
	if ( SERVER ) then
		
		
		
	else
		
		
		
	end
end

-- The Hidden Stuff
--[[hook.Add("AcceptInput", "Ballsy", function( ent, name, activator, caller, data )
	--if ( name == "StartShake" and ent:GetClass() == "env_shake" ) then
	--	GAMEMODE:FreakEveryone( ent:GetInternalVariable("duration") + 0.7 )
	--end
	
	--print( "ASSS", ent, name, activator, caller )
	
	-- Makes STALKERS avoid calling triggers like in scary maps
	if ( activator:IsPlayer() ) then
		local pId = activator:GetClassID()
		local pClass = nwidtostr(pId)
		
		if ( pClass == "player_vdm_hidden" and IsValid(caller) ) then
			local entClass = caller:GetClass()
			
			if ( entClass == "trigger_once" or entClass == "trigger_multiple" ) then
				return true
			end
		end
	end
end)]]

--[[
local fall_fatal = 1100
local fall_maxsafe = 580
local fall_damage = 100 / ( fall_fatal - fall_maxsafe )

function GM:GetFallDamage( pl, flFallSpeed )
	--local pId = pl:GetClassID()
	--local pClass = nwidtostr(pId)
	
	--if ( pClass == "player_vdm_hidden" ) then
	--	return 0
	--end
	
	return math.max( (flFallSpeed - fall_maxsafe) * fall_damage * 1.25, 0 )
end

function GM:PlayerCanPickupWeapon( ply, ent )
	local salvage = cvSalvageWeapons:GetBool()
	
	if ( not salvage ) then
		return not ( ply:GetWeapon(ent:GetClass()):IsValid() )
	end
	
	return true
end
]]

--[[local matNoise = Material( "volantarius/noise" )

local function DrawFilmGrain( r, g, b, a )
	cam.Start2D()
	
	surface.SetMaterial( matNoise )
	surface.SetDrawColor( r, g, b, a )
	
	surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, ScrW()/256, ScrH()/256 )
	
	cam.End2D()
end

local function DrawLight( ent, pos, r, g, b, bright, size, decay, life )
	local the_light = DynamicLight( ent:EntIndex() )
	if ( the_light ) then
		the_light.Pos = pos
		the_light.r = r
		the_light.g = g
		the_light.b = b
		the_light.Brightness = bright
		the_light.Size = size
		the_light.Decay = decay
		the_light.DieTime = CurTime() + life
		--the_light.minlight = 0.1
	end
end

local nwidtostr = util.NetworkIDToString]]

-- TODO: What about just like a nightvision, or halloween mode via console

--[[hook.Add( "RenderScreenspaceEffects", "RenderPostProcessing", function()
	local ply = LocalPlayer()
	local alive = ply:Alive()
	
	if ( not alive ) then
		DrawFilmGrain( 25, 32, 255, 255 )
		return
	end
	
	local pTeam = ply:Team()
	local pHealth = ply:Health()
	local pId = ply:GetClassID()
	local pClass = nwidtostr(pId)
	
	if ( pHealth <= 25 ) then
		DrawFilmGrain( 255, 25, 25, (1 - math.Clamp(pHealth, 0, 25) / 25) * 255 )
	end
	
	--if ( pClass == "player_vdm_hidden" ) then
		local eyePos = ply:EyePos()
		local aimVec = ply:GetAimVector()
		
		--local tr = util.QuickTrace(eyePos, aimVec * 192, {ply})
		local tr = util.TraceHull({
			start = eyePos,
			endpos = eyePos + (aimVec * 192),
			maxs = Vector(4, 4, 4),
			mins = Vector(-4, -4, -4),
			filter = ply
		})
		
		--local fart = render.GetLightColor( ply:EyePos() )
		local fart = render.GetLightColor( tr.HitPos - aimVec )
		local value = 1 - math.Clamp( (fart.x + fart.y + fart.z)/0.2, 0, 1 )
		
		--DrawFilmGrain( 30, 255, 30, math.Clamp(70 * value, 0, 70) )
		DrawFilmGrain( 30, 255, 30, math.Clamp(150 * value, 0, 150) )
		
		DrawLight( ply, tr.HitPos - aimVec, 0, 128 * value, 0, 1, 512 * value, 1024, 0.1 )
	--end
end )]]

-- TEST SHIT might not work for multiplayer
--[[
hook.Add("Think", "CalcStalkerCamo", function()
	
	for k,ply in ipairs( team.GetPlayers( TEAM_STALKER ) ) do
		if ( ply:Alive() ) then
			local fart = render.GetLightColor( ply:GetShootPos() )--Gets fucking entity drive position wtf
			
			local value = math.Clamp( (fart.x + fart.y + fart.z)/1, 0, 1 )
			
			ply:SetPlayerColor( Vector( value, 0, 0 ) )--Material is designed to use x
		end
	end
	
end)
]]