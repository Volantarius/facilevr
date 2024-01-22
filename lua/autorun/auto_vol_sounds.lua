AddCSLuaFile()

-- Idk why I did it like this but w/e

local VolSounds = {
	["Vol_Wep_GLauncher.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")volantarius/ts/gun_grenade_launcher01c_22.wav"
	},
	["Vol_Wep_MachGun.Single"]={
		channel=CHAN_WEAPON,
		volume=0.45,
		soundlevel=120,
		pitch=100,
		wave=")volantarius/ts/gun_fixedgun22_07e.wav"
	},
	["Vol_Wep_MachGun2.Single"]={
		channel=CHAN_WEAPON,
		volume=0.75,
		soundlevel=120,
		pitch={95, 100},
		wave=")volantarius/ts/gun_scifi_sniper44_01.wav"
	},
	
	["Vol_MaxPayne_PumpShot.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")volantarius/mxp/Shoot_PumpShotgun.wav"
	},
	["Vol_MaxPayne_SSG.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")volantarius/mxp/Shoot_SteyrSSG.wav"
	},
	["Vol_MaxPayne_Deagle.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")volantarius/mxp/Shoot_DesertEagle.wav"
	},
	
	["Vol_TFC_Sniper.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=140,
		pitch=160,
		wave=")volantarius/gldsrc/sniper.wav"
	},
	["Vol_TFC_Nailgun.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=120,
		pitch=100,
		wave=")volantarius/gldsrc/airgun_1.wav"
	},
	
	["Vol_Butt.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=120,
		pitch=100,
		wave="^volantarius/arma/sp5_fire_2.wav"
	},
	
	["Vol_Conker_BigRico.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=130,
		pitch=130,
		wave={
			")volantarius/cbfd/bigrico1.wav",
			")volantarius/cbfd/bigrico2.wav",
			")volantarius/cbfd/bigrico3.wav",
			")volantarius/cbfd/bigrico4.wav"
		}
	},
	["Vol_Conker_Fart.Single"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=88,
		pitch={40, 180},
		wave={
			")volantarius/cbfd/fart01.wav",
			")volantarius/cbfd/fart02.wav",
			")volantarius/cbfd/fart03.wav",
			")volantarius/cbfd/fart04.wav",
			")volantarius/cbfd/fart05.wav",
			")volantarius/cbfd/fart06.wav",
			")volantarius/cbfd/fart07.wav",
			")volantarius/cbfd/fart08.wav",
			")volantarius/cbfd/fart09.wav",
			")volantarius/cbfd/fart10.wav",
			")volantarius/cbfd/fart11.wav",
			")volantarius/cbfd/fart12.wav",
			")volantarius/cbfd/fart13.wav",
			")volantarius/cbfd/fart14.wav",
			")volantarius/cbfd/fart15.wav",
			")volantarius/cbfd/fart16.wav"
		}
	},
	
	["Vol_BouncyBall.Cute"]={
		channel=CHAN_BODY,
		volume=0.1,
		soundlevel=100,
		pitch=100,
		wave=")garrysmod/balloon_pop_cute.wav"
	},
	["Vol_BouncyBall.Explode"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch={80, 130},
		wave=")volantarius/cbfd/fart13.wav"
	},
	["Vol_Stinky.Explode"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/cbfd/fart06.wav"
	},
	
	--[[ GOLDENEYE /////////////////// ]]
	
	["Vol_GE_Empty.Single"]={
		channel=CHAN_ITEM,
		volume=0.4,
		soundlevel=80,
		pitch=100,
		wave=")volantarius/genew/dryfire.wav"
	},
	["Vol_GE_Magnum.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-magnum.wav"
	},
	["Vol_GE_Moonraker.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-moonraker.wav"
	},
	["Vol_GE_D5K.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-d5k.wav"
	},
	["Vol_GE_KF7.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-kf7.wav"
	},
	["Vol_GE_Silencer.Single"]={
		channel=CHAN_WEAPON,
		volume=0.6,
		soundlevel=90,
		pitch=100,
		wave=")volantarius/genew/gun-silencer.wav"
	},
	-- This is just the 357 magnum gunfire, which we probably should just use the ge one
	["Vol_GE_Uzi.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/ge/gun-uzi.wav"
	},
	["Vol_GE_AR33.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-ar33.wav"
	},
	["Vol_GE_Shotgun.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-shotgun.wav"
	},
	["Vol_GE_AutoShotgun.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-autoshotgun.wav"
	},
	["Vol_GE_Klobb.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-klobb.wav"
	},
	-- Unused sounds
	["Vol_GE_Unused1.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-unused1.wav"
	},
	["Vol_GE_Unused2.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-unused2.wav"
	},
	["Vol_GE_Unused3.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/genew/gun-unused3.wav"
	},
	["Vol_GE_DD44.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")volantarius/genew/gun-dd44.wav"
	},
	
	["Vol_GE_Mine.Attach"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave=")volantarius/genew/attach-mine.wav"
	},
	["Vol_GoldenEye.Reload"]={
		channel=CHAN_VOICE,
		volume=0.7,
		soundlevel=80,
		pitch=100,
		wave="volantarius/genew/reload.wav"
	},
	["Vol_GoldenEye_Weapon.Switch"]={
		channel=CHAN_VOICE,
		volume=0.7,
		soundlevel=80,
		pitch=100,
		wave="volantarius/genew/switch-general.wav"
	},
	["Vol_GoldenEye_Mine.Switch"]={
		channel=CHAN_VOICE,
		volume=0.7,
		soundlevel=80,
		pitch=100,
		wave="volantarius/genew/switch-mine.wav"
	},
	["Vol_GE_Ricochet.Single"]={
		channel=CHAN_STATIC,
		volume=0.5,
		soundlevel=90,
		pitch={97,100},
		wave={
			"volantarius/genew/ricochet1.wav",
			"volantarius/genew/ricochet2.wav",
			"volantarius/genew/ricochet3.wav",
			"volantarius/genew/ricochet4.wav",
			"volantarius/genew/ricochet5.wav",
			"volantarius/genew/ricochet6.wav",
			"volantarius/genew/ricochet7.wav",
			"volantarius/genew/ricochet8.wav",
			"volantarius/genew/ricochet2.wav",
			"volantarius/genew/ricochet3.wav",
			"volantarius/genew/ricochet4.wav",
			"volantarius/genew/ricochet5.wav",
			"volantarius/genew/ricochet6.wav",
			"volantarius/genew/ricochet7.wav",
			"volantarius/genew/ricochet8.wav"
		}
	},
	["Vol_GE_Silly.Single"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=90,
		pitch={90,110},
		wave={
			--")volantarius/genew/silly_yell1.wav",
			--")volantarius/genew/silly_yell2.wav",
			--")volantarius/genew/silly_yell3.wav"
			")volantarius/genew/silly_yell1_l.wav",
			")volantarius/genew/silly_yell2_l.wav",
			")volantarius/genew/silly_yell3_l.wav"
		}
	},
	["Vol_GE_Reaction.Single"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=90,
		pitch={90,110},
		wave={
			")volantarius/genew/reaction3.wav",
			")volantarius/genew/reaction6.wav",
			")volantarius/genew/reaction7.wav",
			")volantarius/genew/reaction8.wav",
			")volantarius/genew/reaction9.wav",
			")volantarius/genew/reaction10.wav",
			")volantarius/genew/reaction11.wav",
			")volantarius/genew/reaction12.wav",
			")volantarius/genew/reaction13.wav",
			")volantarius/genew/reaction14.wav",
			")volantarius/genew/reaction15.wav",
			")volantarius/genew/reaction16.wav",
			")volantarius/genew/reaction17.wav",
			")volantarius/genew/reaction18.wav",
			")volantarius/genew/reaction19.wav",
			")volantarius/genew/reaction20.wav",
			")volantarius/genew/reaction21.wav",
			")volantarius/genew/reaction22.wav",
			")volantarius/genew/reaction23.wav",
			")volantarius/genew/reaction25.wav",
			")volantarius/genew/reaction26.wav"
		}
	},
	
	--[[TEST]]
	
	["Vol_FC_test.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave="volantarius/farcry/FINAL_MP5_STEREO_SINGLE.wav"
	},
	
	["Vol_Bullettime.Start"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=100,
		pitch=100,
		wave=")volantarius/bullettimeon.wav"
	},
	["Vol_Bullettime.End"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=100,
		pitch=100,
		wave={
			")volantarius/bullettimeoff.wav",
			")volantarius/bullettimeoff_wtf.wav"
		}
	},
	
	["Vol_Quake_Grenade.Hit"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=85,
		pitch=100,
		wave={
			"volantarius/quake/HGRENB1A.wav",
			"volantarius/quake/HGRENB2A.wav"
		}
	},
	
	["Vol_Quake_EArc.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=140,
		pitch=100,
		wave={
			"volantarius/quake/arcimpact01.wav",
			"volantarius/quake/arcimpact02.wav",
			"volantarius/quake/arcimpact03.wav",
			"volantarius/quake/arcimpact04.wav"
		}
	},
	
	["Vol_TS_Ricochet.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=90,
		pitch=100,
		wave={
			"volantarius/gldsrc/ric01.wav",
			"volantarius/gldsrc/ric02.wav",
			"volantarius/gldsrc/ric03.wav",
			"volantarius/gldsrc/ric04.wav",
			"volantarius/gldsrc/ric05.wav",
			"volantarius/gldsrc/ric06.wav",
			"volantarius/gldsrc/ric07.wav",
			"volantarius/gldsrc/ric08.wav",
			"volantarius/gldsrc/ric09.wav",
			"volantarius/gldsrc/ric10.wav",
			"volantarius/gldsrc/ric11.wav"
		}
	},
	["Vol_TS_RicochetNew.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=90,
		pitch=100,
		wave={
			"volantarius/ricochet16_c.wav",
			"volantarius/ricochet16_d.wav",
			"volantarius/ricochet16_e.wav",
			"volantarius/ricochet16_f.wav",
			"volantarius/ricochet16_g.wav",
			"volantarius/ricochet16_i.wav"
		}
	},
	
	["Vol_New_Ricochet.Single"]={
		channel=CHAN_AUTO,
		volume=1.0,
		soundlevel=85,
		pitch={90,110},
		wave={
			"weapons/fx/rics/ric1.wav",
			"weapons/fx/rics/ric2.wav",
			"weapons/fx/rics/ric3.wav",
			"weapons/fx/rics/ric4.wav",
			"weapons/fx/rics/ric5.wav"
		}
		--[[wave={
			"volantarius/genew/ricochet2.wav",
			"volantarius/genew/ricochet3.wav",
			"volantarius/genew/ricochet4.wav",
			"volantarius/genew/ricochet5.wav",
			"volantarius/genew/ricochet8.wav"
		}]]
	},
	
	["Vol_TS_Magnum.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=150,
		pitch=100,
		wave=")volantarius/ts/gun_dr08c_22.wav"
	},
	["Vol_TS_Dry.Single"]={
		channel=CHAN_ITEM,
		volume=1.0,
		soundlevel=40,
		pitch=100,
		wave=")volantarius/ts/gun_dryfire01_22.wav"
	},
	
	["Vol_CSS_Dry"]={
		channel=CHAN_ITEM,
		volume=1.0,
		soundlevel=40,
		pitch=100,
		wave=")weapons/clipempty_rifle.wav"
	},
	
	["Vol_Laser3.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")volantarius/ts/gun_laser3way22_06b.wav"
	},
	["Vol_MineTest.Explode"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=140,
		pitch={100,110},
		wave="^volantarius/explosives/mine_3.wav"
	},
	
	["Vol_Dick.Spin"]={
		channel=CHAN_WEAPON,
		volume=0.4,
		soundlevel=80,
		pitch=80,
		wave="vehicles/tank_turret_start1.wav"
	},
	["Vol_Dick.Grind"]={
		channel=CHAN_BODY,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			"physics/flesh/flesh_squishy_impact_hard1.wav",
			"physics/flesh/flesh_squishy_impact_hard2.wav",
			"physics/flesh/flesh_squishy_impact_hard3.wav",
			"physics/flesh/flesh_squishy_impact_hard4.wav"
		}
	},
	["Vol_Dick.Reload"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			"volantarius/spike/spike01.wav",
			"volantarius/spike/spike02.wav"
		}
	},
	
	["Vol_Sword.Miss"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave={
			")smod/knife/knife_slash1.wav",
			")smod/knife/knife_slash2.wav"
		}
	},
	["Vol_Sword.Hit"]={
		channel=CHAN_BODY,
		volume=1.0,
		soundlevel=80,
		pitch={95, 100},
		wave={
			")smod/knife/knife_hitwall1.wav",
			")smod/knife/knife_hit1.wav",
			")smod/knife/knife_hit2.wav"
		}
	},
	["Vol_Shovel.Miss"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch={95, 100},
		wave=")smod/shovel/shovel_fire.wav"
	},
	["Vol_Shovel.HitMed"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch={95, 100},
		wave={
			")smod/shovel/shovel_hit1.wav",
			")smod/shovel/shovel_hit3.wav"
		}
	},
	["Vol_Shovel.HitHard"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=90,
		pitch={95, 100},
		wave=")smod/shovel/shovel_hit2.wav"
	},
	
	["Vol_ByMySelf.Single"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=100,
		pitch=100,
		wave="volantarius/bymyself.mp3"
	},

	["Vol_JB_Hand.Single"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave="weapons/handgun/handgun.wav"
	},
	["Vol_JB_Hand.Reload"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave="weapons/handgun/reload.wav"
	},
	["Vol_JB_Hand.Empty"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=80,
		pitch=100,
		wave="weapons/handgun/empty.wav"
	},
	
	["Vol_Mine.Attach"]={
		channel=CHAN_ITEM,
		volume=0.4,
		soundlevel=60,
		pitch=100,
		wave="volantarius/ts/mine_attach22_01.wav"
	},
	["Vol_Mine.Ding"]={
		channel=CHAN_ITEM,
		volume=1.0,
		soundlevel=70,
		pitch=100,
		wave="volantarius/ts/mine_remote_trigger22_01.wav"--Make this a table with strings for random sounds
	}
}

local HLOFSounds = {
	["OF_Displacer.Fire"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave="hlof/weapons/displacer_fire.wav"
	},
	["OF_Displacer.TeleSelf"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave="hlof/weapons/displacer_self.wav"
	},
	["OF_Displacer.Spin"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=90,
		pitch=100,
		wave="hlof/weapons/displacer_spin.wav"
	},
	["OF_Displacer.Spin2"]={
		channel=CHAN_VOICE,
		volume=1.0,
		soundlevel=90,
		pitch=100,
		wave="hlof/weapons/displacer_spin2.wav"
	},
	["OF_Displacer.Impact"]={
		channel=CHAN_STATIC,
		volume=1.0,
		soundlevel=100,
		pitch=100,
		wave="hlof/weapons/displacer_impact.wav"
	},
	["OF_Displacer.Loop"]={
		channel=CHAN_STATIC,
		volume=0.2,
		soundlevel=70,
		pitch=150,
		wave="npc/roller/mine/rmine_moveslow_loop1.wav"
	}
}

local SModSounds = {
	["Weapon_Sawedoff.close"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/sawedoff/close.wav"
	},
	["Weapon_Sawedoff.open"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/sawedoff/open.wav"
	},
	["Weapon_Sawedoff.load"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/sawedoff/load.wav"
	},
	
	["Weapon_Grease.Clipout"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/grease/tommy_reload_clipout.wav"
	},
	["Weapon_Grease.Clipin"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/grease/tommy_reload_clipin.wav"
	},
	["Weapon_Grease.Slideback"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/grease/tommy_draw_slideback.wav"
	},
	
	["Weapon_Garand.Fire"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")smod/garand/garand_shoot.wav"
	},
	["Weapon_Garand.ClipDing"]={
		channel=CHAN_ITEM,
		volume=0.6,
		soundlevel=100,
		pitch=100,
		wave=")smod/garand/garand_reload_clipding.wav"
	},
	["Weapon_Garand.Clipin"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=70,
		pitch=100,
		wave="smod/garand/garand_reload_clipin.wav"
	},
	
	["Weapon_A35.InsertShell"]={
		channel=CHAN_ITEM,
		volume=0.15,
		soundlevel=70,
		pitch=100,
		wave="smod/a35/a35_insert.wav"
	},
	["Weapon_A35.Deploy"]={
		channel=CHAN_ITEM,
		volume=0.3,
		soundlevel=60,
		pitch=100,
		wave="smod/a35/a35_deploy.wav"
	},
	
	--[[ AK47 ]]
	["Weapon_CoD4_AK47.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/ak47/weap_ak47_slst_3.wav"
	},
	["Weapon_CoD4_AK47.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/ak47/weap_m4_silencer_slst_1x.wav"
	},
	["Weapon_CoD4_AK47.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak47/wpfoly_ak47_reload_chamber_v4.wav"
	},
	["Weapon_CoD4_AK47.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak47/wpfoly_ak47_reload_clipin_v4.wav"
	},
	["Weapon_CoD4_AK47.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak47/wpfoly_ak47_reload_clipout_v5.wav"
	},
	["Weapon_CoD4_AK47.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak47/wpfoly_ak47_reload_lift_v4.wav"
	},
	["Weapon_CoD4_AK47.GP25Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/ak47/weap_m203_sl_1b.wav"
	},
	["Weapon_CoD4_AK47.GP25Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak47/wpfoly_ak47gp25_grnd_chamber_v1.wav"
	},
	["Weapon_CoD4_AK47.GP25Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak47/wpfoly_ak47gp25_grnd_lift_v1.wav"
	},
	
	--[[ AK74u ]]
	["Weapon_CoD4_AK74u.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/ak74u/weap_ak74_slst_1.wav"
	},
	["Weapon_CoD4_AK74u.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/ak74u/weap_mp5_silencer_slst_2d.wav"
	},
	["Weapon_CoD4_AK74u.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak74u/wpfoly_ak74u_reload_chamber_v4.wav"
	},
	["Weapon_CoD4_AK74u.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak74u/wpfoly_ak74u_reload_clipin_v4.wav"
	},
	["Weapon_CoD4_AK74u.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak74u/wpfoly_ak74u_reload_clipout_v5.wav"
	},
	["Weapon_CoD4_AK74u.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/ak74u/wpfoly_ak74u_reload_lift_v4.wav"
	},
	
	--[[ M16 ]]
	["Weapon_CoD4_M4.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/m4/weap_m4_slst_1c4.wav"
	},
	["Weapon_CoD4_M4.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/m4/weap_m4_silencer_slst_1x.wav"
	},
	["Weapon_CoD4_M4.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_ak47_reload_chamber_v4.wav"
	},
	["Weapon_CoD4_M4.ReloadChamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m4_reload_chamber.wav"
	},
	["Weapon_CoD4_M4.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m4_reload_clipin.wav"
	},
	["Weapon_CoD4_M4.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m4_reload_clipout.wav"
	},
	["Weapon_CoD4_M4.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m4_reload_lift.wav"
	},
	["Weapon_CoD4_M4.M203Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/m4/weap_m203_sl_1b.wav"
	},
	["Weapon_CoD4_M4.M203Close"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m203_chamber_close_v12.wav"
	},
	["Weapon_CoD4_M4.M203Load"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m203_load_v12.wav"
	},
	["Weapon_CoD4_M4.M203Open"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m4/wpfoly_m203_chamber_open_v12.wav"
	},
	
	--[[ G3 ]]
	["Weapon_CoD4_G3.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/g3/weap_g3_slst_2.wav"
	},
	["Weapon_CoD4_G3.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/g3/weap_m4_silencer_slst_1x.wav"
	},
	["Weapon_CoD4_G3.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g3/wpfoly_g3_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_G3.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g3/wpfoly_g3_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_G3.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g3/wpfoly_g3_reload_clipout_v2.wav"
	},
	["Weapon_CoD4_G3.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g3/wpfoly_g3_reload_lift_v1.wav"
	},
	
	--[[ Dragunov ]]
	["Weapon_CoD4_Dragunov.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 140,
		wave = "^cod4/weapons/dragunov/weap_dragunov_slst_1.wav"
	},
	["Weapon_CoD4_Dragunov.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/dragunov/wpfoly_dragunov_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_Dragunov.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/dragunov/wpfoly_dragunov_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_Dragunov.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/dragunov/wpfoly_dragunov_reload_clipout_v2.wav"
	},
	["Weapon_CoD4_Dragunov.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/dragunov/wpfoly_dragunov_reload_lift_v1.wav"
	},
	
	--[[ Skorpion ]]
	["Weapon_CoD4_Skorpion.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/skorpion/weap_skorpion_slst_2.wav"
	},
	["Weapon_CoD4_Skorpion.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/skorpion/weap_usp45sd_slst_y1.wav"
	},
	["Weapon_CoD4_Skorpion.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/skorpion/wpfoly_skorpion_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_Skorpion.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/skorpion/wpfoly_skorpion_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_Skorpion.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/skorpion/wpfoly_skorpion_reload_clipout_v1.wav"
	},
	["Weapon_CoD4_Skorpion.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/skorpion/wpfoly_skorpion_reload_lift_v1.wav"
	},
	
	--[[ G36c ]]
	["Weapon_CoD4_G36C.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/g36c/weap_g36_slst_1.wav"
	},
	["Weapon_CoD4_G36C.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/g36c/weap_m4_silencer_slst_1x.wav"
	},
	["Weapon_CoD4_G36C.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g36c/wpfoly_g36_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_G36C.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g36c/wpfoly_g36_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_G36C.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g36c/wpfoly_g36_reload_clipout_v1.wav"
	},
	["Weapon_CoD4_G36C.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/g36c/wpfoly_g36_reload_lift_v1.wav"
	},
	
	--[[ M14 ]]
	["Weapon_CoD4_M14.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/m14/weap_m14_slst_5.wav"
	},
	["Weapon_CoD4_M14.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/m14/weap_m4_silencer_slst_1x.wav"
	},
	["Weapon_CoD4_M14.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m14/wpfoly_m14_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_M14.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m14/wpfoly_m14_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_M14.ClipInTac"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m14/wpfoly_m14_reload_clipin_tac_v1.wav"
	},
	["Weapon_CoD4_M14.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m14/wpfoly_m14_reload_clipout_v1.wav"
	},
	["Weapon_CoD4_M14.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m14/wpfoly_m14_reload_lift_v1.wav"
	},
	
	--[[ M1014 ]]
	["Weapon_CoD4_M1014.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/m1014/weap_m1014_slst_y1b.wav"
	},
	["Weapon_CoD4_M1014.End"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m1014/wpfoly_m4ben_reload_end_v1.wav"
	},
	["Weapon_CoD4_M1014.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m1014/wpfoly_m4ben_reload_lift_v1.wav"
	},
	["Weapon_CoD4_M1014.Loop"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m1014/wpfoly_m4ben_reload_loop_v1.wav"
	},
	
	--[[ WINCHESTER ]]
	["Weapon_CoD4_Winchester1200.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/winchester1200/weap_win1200_slst_2.wav"
	},
	["Weapon_CoD4_Winchester1200.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/winchester1200/wpfoly_winchester_reload_lift_v1.wav"
	},
	["Weapon_CoD4_Winchester1200.Loop"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/winchester1200/wpfoly_winchester_reload_loop_v1.wav"
	},
	["Weapon_CoD4_Winchester1200.Pump"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/winchester1200/wpfoly_winchester_reload_pump_v1.wav"
	},
	
	--[[ REMINGTON 700 ]]
	["Weapon_CoD4_Remington700.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/remington700/weap_762mm_sniper_slst_4.wav"
	},
	["Weapon_CoD4_Remington700.End"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/remington700/wpfoly_m40a3_end_v1.wav"
	},
	["Weapon_CoD4_Remington700.Loop"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = { "cod4/weapons/remington700/wpfoly_m40a3_loop_v1.wav","cod4/weapons/remington700/wpfoly_m40a3_loop_v2.wav" }
	},
	["Weapon_CoD4_Remington700.Rechamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/remington700/wpfoly_m40a3_rechamber_v1.wav"
	},
	["Weapon_CoD4_Remington700.Start"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/remington700/wpfoly_m40a3_start_v2.wav"
	},
	
	--[[ MP5 ]]
	["Weapon_CoD4_MP5.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/mp5/weap_mp5_slst_4.wav"
	},
	["Weapon_CoD4_MP5.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		wave = "^cod4/weapons/mp5/weap_mp5_silencer_slst_2d.wav"
	},
	["Weapon_CoD4_MP5.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/mp5/wpfoly_mp5_reload_chamber_v3.wav"
	},
	["Weapon_CoD4_MP5.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/mp5/wpfoly_mp5_reload_clipin_v4.wav"
	},
	["Weapon_CoD4_MP5.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/mp5/wpfoly_mp5_reload_clipout_v4.wav"
	},
	
	--[[ P90 ]]
	["Weapon_CoD4_P90.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/p90/weap_p90_slst_1.wav"
	},
	["Weapon_CoD4_P90.Silenced"]={
		channel = CHAN_WEAPON,
		soundlevel = 90,
		volume = 0.5,
		wave = "^cod4/weapons/p90/weap_p90_silencer_slst_1.wav"
	},
	["Weapon_CoD4_P90.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/p90/wpfoly_p90_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_P90.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/p90/wpfoly_p90_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_P90.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/p90/wpfoly_p90_reload_clipout_v1.wav"
	},
	["Weapon_CoD4_P90.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/p90/wpfoly_p90_reload_lift_v1.wav"
	},
	["Weapon_CoD4_P90.Hit"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/p90/wpfoly_p90_reload_hit_v1.wav"
	},
	["Weapon_CoD4_P90.PickUp"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/p90/wpfoly_p90_pickup_lift_v1.wav"
	},
	
	--[[ USP ]]
	["Weapon_CoD4_USP.Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/usp/weap_usp45_slst_y1b.wav"
	},
	["Weapon_CoD4_USP.Silenced"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 80,
		wave = "^cod4/weapons/usp/weap_usp45sd_slst_y1.wav"
	},
	["Weapon_CoD4_USP.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/usp/wpfoly_usp_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_USP.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/usp/wpfoly_usp_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_USP.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/usp/wpfoly_usp_reload_clipout_v2.wav"
	},
	["Weapon_CoD4_USP.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/usp/wpfoly_usp_reload_lift_v1.wav"
	},
	
	--[[ BERETTA ]]
	["Weapon_CoD4_Beretta.Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/beretta/weap_beretta_slst_3c.wav"
	},
	["Weapon_CoD4_Beretta.Silenced"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 80,
		wave = "^cod4/weapons/beretta/weap_usp45sd_slst_y1.wav"
	},
	["Weapon_CoD4_Beretta.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/beretta/wpfoly_beretta9mm_reload_chamber_v2.wav"
	},
	["Weapon_CoD4_Beretta.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/beretta/wpfoly_beretta9mm_reload_clipin_v2.wav"
	},
	["Weapon_CoD4_Beretta.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/beretta/wpfoly_beretta9mm_reload_clipout_v2.wav"
	},
	
	--[[COLT 45]]
	["Weapon_CoD4_Colt45.Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/colt45/weap_usp45_slst_y1b.wav"
	},
	["Weapon_CoD4_Colt45.Silenced"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 80,
		wave = "^cod4/weapons/colt45/weap_usp45sd_slst_y1.wav"
	},
	["Weapon_CoD4_Colt45.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/colt45/wpfoly_colt1911_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_Colt45.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/colt45/wpfoly_colt1911_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_Colt45.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/colt45/wpfoly_colt1911_reload_clipout_v1.wav"
	},
	["Weapon_CoD4_Colt45.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/colt45/wpfoly_colt1911_reload_lift_v1.wav"
	},
	
	--[[DESERT EAGLE]]
	["Weapon_CoD4_DesertEagle.Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/deserteagle/weap_deserteagle_slst_2.wav"
	},
	["Weapon_CoD4_DesertEagle.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/deserteagle/wpfoly_de50_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_DesertEagle.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/deserteagle/wpfoly_de50_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_DesertEagle.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/deserteagle/wpfoly_de50_reload_clipout_v1.wav"
	},
	
	--[[UZI]]
	["Weapon_CoD4_Uzi.Single"]={
		channel = CHAN_WEAPON,
		volume=1.0,
		soundlevel = 130,
		wave = "^cod4/weapons/uzi/weap_miniuzi_slst_2b.wav"
	},
	["Weapon_CoD4_Uzi.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/uzi/wpfoly_miniuzi_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_Uzi.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/uzi/wpfoly_miniuzi_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_Uzi.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/uzi/wpfoly_miniuzi_reload_clipout_v2.wav"
	},
	["Weapon_CoD4_Uzi.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/uzi/wpfoly_miniuzi_reload_lift_v1.wav"
	},
	
	--[[ m60e4 ]]
	["Weapon_CoD4_M60E4.Single"]={
		channel = CHAN_WEAPON,
		soundlevel = 130,
		wave = "^cod4/weapons/m60e4/weap_m60_slst_1.wav"
	},
	["Weapon_CoD4_M60E4.Chamber"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_chamber_v1.wav"
	},
	["Weapon_CoD4_M60E4.ClipIn"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_clipin_v1.wav"
	},
	["Weapon_CoD4_M60E4.ClipOut"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_clipout_v1.wav"
	},
	["Weapon_CoD4_M60E4.Close"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_close_v1.wav"
	},
	["Weapon_CoD4_M60E4.Drop"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_drop_v1.wav"
	},
	["Weapon_CoD4_M60E4.Hit"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_hit_v1.wav"
	},
	["Weapon_CoD4_M60E4.Lift"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_lift_v1.wav"
	},
	["Weapon_CoD4_M60E4.Open"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_open_v1.wav"
	},
	["Weapon_CoD4_M60E4.Raise"]={
		channel = CHAN_ITEM,
		volume=0.5,
		soundlevel = 60,
		wave = "cod4/weapons/m60e4/wpfoly_m60_reload_raise_v1.wav"
	},
	
	["weapon_svencoop_pistol.fire"]={
		channel=CHAN_WEAPON,
		volume=1.0,
		soundlevel=130,
		pitch=100,
		wave=")weapons/svencoop/svencoop_pistol/pl_gun3.wav"
	}
}

local VolSoundManifest = {
	SModSounds,
	HLOFSounds,
	VolSounds
}

for k, sndtable in pairs(VolSoundManifest) do
	for sndName, snd in pairs(sndtable) do
		
		--[[snd.channel = snd.channel or CHAN_AUTO
		snd.volume = snd.volume or 0.8
		snd.pitch = snd.pitch or 100
		snd.wave = snd.wave or "null.wav"
		snd.soundlevel = snd.soundlevel or SNDLVL_NORM]]
		
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

VolSoundManifest = nil
SModSounds = nil
HLOFSounds = nil
VolSounds = nil