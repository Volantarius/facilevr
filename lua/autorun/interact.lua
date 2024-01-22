
AddCSLuaFile()

if CLIENT then
	interactmenubar = {}

	function interactmenubar.Init()

		interactmenubar.Control = vgui.Create( "DMenuBar" )
		interactmenubar.Control:Dock( TOP )
		interactmenubar.Control:SetVisible( false )
		
		hook.Run( "PopulateInteractMenuBar", interactmenubar.Control )

	end

	function interactmenubar.ParentTo( pnl )

		-- I don't like this
		if ( !IsValid( interactmenubar.Control ) ) then
			interactmenubar.Init()
		end

		interactmenubar.Control:SetParent( pnl )
		interactmenubar.Control:MoveToBack()
		interactmenubar.Control:SetHeight( 30 )
		interactmenubar.Control:SetVisible( true )
	end

	function interactmenubar.IsParent( pnl )
		return interactmenubar.Control:GetParent() == pnl
	end

	hook.Add( "OnGamemodeLoaded", "CreateMenuBar", function()
		interactmenubar.Init()
	end )
end

sound.Add({
	name = "knockImpact",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 75,
	pitch = {98,100},
	sound = "physics/wood/wood_crate_impact_hard3.wav"
})

-- The filter is clientside! So things like locked doors have to be coded to be global variables to check

local knockSound = Sound( "knockImpact" )

properties.Add( "facileKnock", {
	MenuLabel = "Knock",
	Order = 100,
	MenuIcon = "icon16/door.png",

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !gamemode.Call( "CanInteract", ply, "interact", ent ) ) then return false end--Most important difference of properties system!

		local class = ent:GetClass()

		if ( class == "prop_door_rotating" || class == "func_door_rotating" ) then
			return true
		end

		return false

	end,

	Action = function( self, ent )

		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()

	end,

	Receive = function( self, length, ply )

		local ent = net.ReadEntity()
		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end

		ent:EmitSound( knockSound )

	end

} )

-- Need to be able to own doors like in roleplay for locking / unlocking doors!
-- Door state is server-side so the thing needs to run on server and set a global lol

properties.Add( "facileTest", {
	MenuLabel = "Unknown",
	Order = 9102,
	MenuIcon = "icon16/zoom.png",
	PrependSpacer = true,

	Filter = function( self, ent, ply )

		if ( !IsValid( ent ) ) then return false end
		if ( ent:IsPlayer() ) then return false end
		if ( !gamemode.Call( "CanInteract", ply, "interact", ent ) ) then return false end--Most important difference of properties system!

		self.MenuLabel = ent:GetClass()

		return true

	end,

	Action = function( self, ent )

		--[[self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()]]

	end,

	Receive = function( self, length, ply )

		--[[local ent = net.ReadEntity()
		if ( !properties.CanBeTargeted( ent, ply ) ) then return end
		if ( !self:Filter( ent, ply ) ) then return end]]

	end

} )
