AddCSLuaFile()

local VdmSounds = {
	["Vdm_Announcer.Failure"]={
		channel=CHAN_VOICE2,
		volume=0.9,
		soundlevel=0,
		pitch=100,
		wave="#vdm/countdown22_03new.wav"
	},
	
	["Vdm_Gore.Splat"]={
		channel=CHAN_AUTO,
		volume=1.0,
		soundlevel=90,
		pitch={70, 140},
		wave=")physics/flesh/flesh_bloody_impact_hard1.wav"
	},
	["Vdm_Gore.Explode"]={
		channel=CHAN_AUTO,
		volume=1.0,
		soundlevel=100,
		pitch=100,
		wave="vdm/dm_bodysplat.wav"
	},
	["Vdm_Gore.Gore"]={
		channel=CHAN_AUTO,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			"vdm/spout.wav",
			"vdm/spout2.wav",
			"vdm/spout3.wav"
		}
	},
	
	-- [[ VIRTUAL REALITY ]]
	["VDM_VR.HighScore"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			"vrstuff/E_VO_CV_003_60.wav",
			"vrstuff/E_VO_CV_003_61.wav",
			"vrstuff/E_VO_CV_003_62.wav",
			"vrstuff/E_VO_CV_003_63.wav"
		}
	},
	
	["VDM_VR.LowScore"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			"vrstuff/E_VO_CV_003_30.wav",
			"vrstuff/E_VO_CV_003_34.wav",
			"vrstuff/E_VO_CV_003_44.wav",
			"vrstuff/E_VO_CV_003_54.wav",
			"vrstuff/E_VO_CV_003_59.wav"
		}
	},
	
	["VDM_VR.Breathing"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			"vrstuff/E_VO_CV_003_64.wav",
			"vrstuff/E_VO_CV_003_65.wav",
			"vrstuff/E_VO_CV_003_66.wav",
			"vrstuff/E_VO_CV_003_67.wav",
			"vrstuff/E_VO_CV_003_128.wav"
		}
	},
	
	["VDM_Laypipe.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave=")volantarius/pipe2.wav"
	},
	["VDM_Fart.Diseased"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=90,
		pitch=100,
		wave=")volantarius/diseased-fart.wav"
	},
	
	["VdmPickup.Spawn"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=130,
		pitch={98, 102},
		wave=")volantarius/genew/regenerate.wav"
	},
	
	["VdmPickup.Grab"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=100,
		pitch=100,
		wave=")vdm/vc_pickup.wav"
	},
	["VdmPickupGE.Grab"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=60,
		pitch=100,
		wave=")volantarius/genew/switch-general.wav"
	},
	["VdmPickupGE.Reload"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=60,
		pitch=100,
		wave=")volantarius/genew/reload.wav"
	},
	
	["VdmPickupTS.Spawn"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")vdm/ts_gun_spawn.wav"
	},
	
	["VdmPickupTS.Grab"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")vdm/ts_health_pickup.wav"
	},
	
	["VdmSpawn"]={
		channel=CHAN_VOICE,
		volume=0.4,
		soundlevel=100,
		pitch=100,
		wave="vdm/timespawn.wav"
	},
}

-- Please equalize the music!
local VdmMusic = {
	["Vdm_Music.Moonlight"] = {
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=0,
		pitch=100,
		wave = "#vdmmusic/moonlight-sonata.mp3"
	},
	
	["Vdm_Music.Imperitum"] = {
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=0,
		pitch=100,
		wave = "#vdmmusic/imperitum.mp3"
	},
	
	["Vdm_Music.AveMaria"] = {
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=0,
		pitch=100,
		wave = "#vdmmusic/ave-maria.mp3"
	}
}

local VdmSoundManifest = {
	VdmMusic,
	VdmSounds
}

for k, sndtable in pairs(VdmSoundManifest) do
	for sndName, snd in pairs(sndtable) do
		
		snd.channel = snd.channel or CHAN_AUTO
		snd.volume = snd.volume or 0.8
		snd.pitch = snd.pitch or 100
		snd.wave = snd.wave or "null.wav"
		snd.soundlevel = snd.soundlevel or SNDLVL_NORM
		
		if (snd.wave == "null.wav") then
			continue
		end
		
		sound.Add({
			name = sndName,
			channel = snd.channel,
			volume = snd.volume,
			level = snd.soundlevel,
			pitch = snd.pitch,
			sound = snd.wave
		})
	end
end

VdmSoundManifest = nil
VdmMusic = nil
VdmSounds = nil