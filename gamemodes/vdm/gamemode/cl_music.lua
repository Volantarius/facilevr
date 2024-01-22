-- music system

--[[
	TODO:
	Alright so clients can override the music to be played..
	
	Maybe a menu to play own music... ugh
]]

local function play_sound( scriptname )
	EmitSound( scriptname, Vector(0,0,0), 1 )-- 3rd argument is local
end

-- Queues a specific song, with override
local function vmusic_queuetrack( soundname )
	
end
--net.Receive( "vdmn_queuetrack", function(len) vmusic_queuetrack( net.ReadString() ) end )

-- Gametype recieve
--[[local function vmusic_roundmusic( gametype_name )
	if ( gametype_name == "fartcops" ) then
		--play_sound( "Vdm_Music.AveMaria" )
		
		-- LOL
		play_sound( "Vdm_Music.Imperitum" )
	end
end
net.Receive( "vdmn_roundmusic", function(len) vmusic_roundmusic( net.ReadString() ) end )]]