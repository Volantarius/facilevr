local hud_deathnotice_time = CreateClientConVar( "fa_deathnotice_time", "15", true, false )
--local hud_deathnotice_limit = CreateClientConVar( "fa_deathnotice_limit", "5", true, false )

local killiconAdd, killiconAddAlias = killicon.Add, killicon.AddAlias

killiconAdd( "default", "killicons/death", color_white )

killiconAdd( "wallbang", "killicons/penetrate", color_white )

killiconAdd( "headshot", "killicons/headshotnew", color_white )
killiconAdd( "csdefault", "killicons/death", color_white )

killiconAdd( "env_explosion", "killicons/explosive", color_white )
killiconAddAlias( "explosive", "env_explosion" )
killiconAddAlias( "concussiveblast", "env_explosion" )

killiconAdd( "prop_physics", "killicons/phys", color_white )
killiconAddAlias( "prop_physics_multiplayer", "prop_physics" )
killiconAddAlias( "prop_physics_respawnable", "prop_physics" )
killiconAddAlias( "func_physbox", "prop_physics" )
killiconAddAlias( "prop_ragdoll", "prop_physics" )

killiconAdd( "weapon_smg1", 		"killicons/smg1", color_white )
killiconAdd( "weapon_357", 		"killicons/357", color_white )
killiconAdd( "weapon_ar2", 		"killicons/ar2", color_white )
killiconAdd( "crossbow_bolt", 		"killicons/crossbow", color_white )
killiconAdd( "weapon_shotgun", 	"killicons/spas12", color_white )
killiconAdd( "npc_grenade_frag", 	"killicons/grenade_hl", color_white )
killiconAdd( "weapon_pistol", 		"killicons/hkmatch", color_white )
killiconAdd( "prop_combine_ball", 	"killicons/combineball", color_white )
killiconAdd( "grenade_ar2", 		"killicons/smg1alt", color_white )
killiconAdd( "weapon_stunstick", 	"killicons/stunstick", color_white )
killiconAdd( "npc_satchel", 		"killicons/slamtrip", color_white )
killiconAdd( "weapon_crowbar", 	"killicons/crowbar", color_white )
killiconAdd( "weapon_physcannon", 	"killicons/gravitygun", color_white )
killiconAdd( "rpg_missile", 		"killicons/rpg", color_white )

killiconAddAlias( "npc_tripmine", "npc_satchel" )

killiconAdd( "worldspawn", 		"killicons/ff_gravity", color_white )
killiconAdd( "trigger_hurt", 		"killicons/trigger", color_white )

local DeathNoticeEnabled = false

local function CreateDeathNotifyPanel()

	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end

	local x, y = ScrW(), ScrH()

	g_DeathNotify = vgui.Create( "DNotify", parent )

	g_DeathNotify:SetPos( 0, 6 )
	g_DeathNotify:SetSize( x - 6, y - 6 )
	g_DeathNotify:SetAlignment( 9 )
	g_DeathNotify:SetLife( hud_deathnotice_time:GetInt() )
	
	DeathNoticeEnabled = true
	
end

-- @Note: For vr but will probably setup another vgui thing to just stray away from `Think`
-- There is loads of cpu killers in lua, and I wanna see how much can be free'd
function GM:DisableDeathNotices()
	
	if ( !IsValid( g_DeathNotify ) ) then return end
	
	g_DeathNotify:Remove()
	
	g_DeathNotify = nil
	
	DeathNoticeEnabled = false
end

function GM:EnableDeathNotices()
	CreateDeathNotifyPanel()
end

hook.Add( "InitPostEntity", "CreateDeathNotify", CreateDeathNotifyPanel )

function GM:AddDeathNotice( victim, inflictor, attacker, customdmg )
	
	if (!DeathNoticeEnabled) then return end
	
	local Notice = vgui.Create( "DeathnoticePanel", g_DeathNotify )
	
	if ( victim == LocalPlayer() ) then
		Notice:SetLocalVictim()
	end

	Notice:AddText( attacker )

	Notice:AddIcon( inflictor, color_white )

	if ( customdmg && customdmg > 0 ) then
		GAMEMODE:ParseExtendedDeathIcons( Notice, customdmg, victim, inflictor, attacker )
	end

	Notice:AddText( victim )

	Notice:SizeToContents()

	g_DeathNotify:SetLife( hud_deathnotice_time:GetInt() )
	g_DeathNotify:AddItem( Notice )

end

function GM:AddSuicideDeathNotice( victim, inflictor, customdmg, newMsg )
	
	if (!DeathNoticeEnabled) then return end
	
	local Notice = vgui.Create( "DeathnoticePanel", g_DeathNotify )
	
	if ( victim == LocalPlayer() ) then
		Notice:SetLocalVictim()
	end

	if ( inflictor != "player" ) then
		Notice:AddIcon( inflictor, color_white )
	else
		Notice:AddIcon( "csdefault" )
	end

	if ( customdmg && customdmg > 0 ) then
		GAMEMODE:ParseExtendedDeathIcons( Notice, customdmg, victim, inflictor, attacker )
	end

	Notice:AddText( victim )

	Notice:AddText( newMsg || GAMEMODE.SuicideString )

	Notice:SizeToContents()

	g_DeathNotify:SetLife( hud_deathnotice_time:GetInt() )
	g_DeathNotify:AddItem( Notice )

end

local bit_band = bit.band

function GM:ParseExtendedDeathIcons( pnl, customdmg, victim, inflictor, attacker )

	--256 possible

	if ( bit_band( customdmg, 8 ) ~= 0 ) then
		pnl:AddIcon( "wallbang" )
	end

	if ( bit_band( customdmg, 2 ) ~= 0 ) then
		pnl:AddIcon( "ricochet" )
	end

	if ( bit_band( customdmg, 1 ) ~= 0 ) then
		pnl:AddIcon( "headshot" )
	end

	--[[if ( bit.band( customdmg, 4 ) ~= 0 ) then
		pnl:AddIcon( "instagib" )
	end]]

end

--[[	////////////////////////////////////////	]]

local function RecvPlayerKilledByPlayer( length )

	local victim 	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker 	= net.ReadEntity()
	local dmgCust 	= net.ReadUInt(16)

	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end
	
	GAMEMODE:AddDeathNotice( victim, inflictor, attacker, dmgCust )
end

net.Receive( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )

local function RecvPlayerKilledSelf( length )

	local victim 	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local dmgCust 	= net.ReadUInt(16)

	if ( !IsValid( victim ) ) then return end

	GAMEMODE:AddSuicideDeathNotice( victim, inflictor, dmgCust )

end

net.Receive( "PlayerKilledSelf", RecvPlayerKilledSelf )

local function RecvPlayerKilled( length )

	local victim 	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker 	= net.ReadString()
	local dmgCust 	= net.ReadUInt(16)
	
	if ( !IsValid( victim ) ) then return end
	
	if ( attacker == inflictor && attacker == "worldspawn" ) then
		GAMEMODE:AddSuicideDeathNotice( victim, inflictor, dmgCust, "hit the ground to hard" )
		return
	end
	
	-- FOR NPCS..
	if ( inflictor == attacker ) then
		inflictor = "default"
	end
	
	GAMEMODE:AddDeathNotice( victim, inflictor, "#" .. attacker, dmgCust )

end

net.Receive( "PlayerKilled", RecvPlayerKilled )

local function RecvPlayerKilledNPC( length )

	local victim 	= net.ReadString()
	local inflictor	= net.ReadString()
	local attacker 	= net.ReadEntity()
	
	if ( !IsValid( attacker ) ) then return end
	
	if ( inflictor == victim ) then
		inflictor = "default"
	end
	
	GAMEMODE:AddDeathNotice( "#" .. victim, inflictor, attacker )

end

net.Receive( "PlayerKilledNPC", RecvPlayerKilledNPC )

local function RecvNPCKilledNPC( length )

	local victim 	= "#" .. net.ReadString()
	local inflictor	= net.ReadString()
	local attacker 	= "#" .. net.ReadString()
	
	--print("farts ", attacker, inflictor)
	
	--print("blah", victim, inflictor, attacker)
	
	-- It seems NPCs have no infliction type set
	if (inflictor == "worldspawn") then
		inflictor = "default"
	end
	
	GAMEMODE:AddDeathNotice( victim, inflictor, attacker )

end

net.Receive( "NPCKilledNPC", RecvNPCKilledNPC )
