AddCSLuaFile()

if SERVER then return end

list.Set( "FacileDesktopWindows", "FacileSettings", {

	title		= "Facile Settings",
	icon		= "icon64/facile.png",
	width		= 960,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )

		window:SetTitle( "Facile Settings" )
		window:SetSize( math.min( ScrW() - 16, window:GetWide() ), math.min( ScrH() - 16, window:GetTall() ) )
		window:SetSizable( true )
		window:SetMinWidth( window:GetWide() )
		window:SetMinHeight( window:GetTall() )
		window:Center()
		
		local bg = window:Add( "DPanel" )
		bg:Dock( FILL )
		bg:DockPadding( 16, 8, 16, 8 )
		
		local settingspanel = bg:Add( "DPanelList" )
		settingspanel:EnableVerticalScrollbar( true )
		settingspanel:Dock( FILL )
		
		-- Make a table with the convars that can be edited instead
		
		local skins = vgui.Create( "DNumSlider" )
		skins:Dock( TOP )
		skins:SetText( "Deathnotice Time" )
		skins:SetTall( 50 )
		skins:SetDecimals( 0 )
		skins:SetMinMax( 5, 30 )
		skins:SetConVar( "fa_deathnotice_time" )
		skins:SetDark( true )
		settingspanel:AddItem( skins )
		
		local b_autobhop = vgui.Create( "DCheckBoxLabel" )
		b_autobhop:SetConVar( "cl_bhopauto" )
		b_autobhop:Dock( TOP )
		b_autobhop:SetText( "Auto Bunny Hop" )
		b_autobhop:SetDark( true )
		settingspanel:AddItem( b_autobhop )
		
		local b_bhoptrain = vgui.Create( "DCheckBoxLabel" )
		b_bhoptrain:SetConVar( "cl_bhoptraining" )
		b_bhoptrain:Dock( TOP )
		b_bhoptrain:SetText( "Bunny Hop Training" )
		b_bhoptrain:SetDark( true )
		settingspanel:AddItem( b_bhoptrain )
		
		local b_bhopups = vgui.Create( "DCheckBoxLabel" )
		b_bhopups:SetConVar( "cl_bhop_showups" )
		b_bhopups:Dock( TOP )
		b_bhopups:SetText( "Show units per second" )
		b_bhopups:SetDark( true )
		settingspanel:AddItem( b_bhopups )
	end
})

list.Set( "FacileDesktopWindows", "FacileSelectTeam", {

	title		= "Select Team",
	icon		= "icon64/fa_team.png",
	width		= 960,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )

		window:SetTitle( "Select Team" )
		window:SetSizable( false )
		
		local teamOptionsPnl = window:Add( "DPanel" )
		teamOptionsPnl:Dock( BOTTOM )
		--teamOptionsPnl:DockPadding( 8, 0, 8, 0 )
		teamOptionsPnl:SetDrawBackground( false )

		local spectateBtn = teamOptionsPnl:Add( "DButton" )
		spectateBtn:Dock( LEFT )
		spectateBtn:SetText( "Spectate" )
		spectateBtn:SetFont( "DermaVRDefault" )
		spectateBtn.DoClick = function()
			RunConsoleCommand( "changeteam", TEAM_SPECTATOR )
			window:Close()
		end
		spectateBtn:SizeToContents()

		local autoteamBtn = teamOptionsPnl:Add( "DButton" )
		autoteamBtn:Dock( RIGHT )
		autoteamBtn:SetText( "Auto Select" )
		autoteamBtn:SetFont( "DermaVRDefault" )
		autoteamBtn.DoClick = function()
			RunConsoleCommand( "autoteam" )
			window:Close()
		end
		autoteamBtn:SizeToContents()

		local ply = LocalPlayer()
		local pTeam = ply:Team()

		local AllTeams = team.GetAllTeams()
		local playableTeams = 0

		for teamID, teamInfo in ipairs( AllTeams ) do
			if ( teamID > TEAM_CONNECTING && teamID != TEAM_SPECTATOR && teamInfo.Joinable ) then
				playableTeams = playableTeams + 1
			end
		end

		for teamID, teamInfo in ipairs( AllTeams ) do
			if ( teamID > TEAM_CONNECTING && teamID != TEAM_SPECTATOR && teamInfo.Joinable ) then
				
				local winTall = window:GetTall()
				
				local mdlWide = window:GetWide() * (1/playableTeams)
				
				local mdlAspect = ( mdlWide / winTall )
				
				local mdlCamPos = Vector( 0, 0, 0 )
				
				-- If the panel is wide, then zoom away from model
				if ( mdlAspect >= 1 ) then
					mdlCamPos = Vector( mdlAspect * 75, 0, 0 )
				end
				
				local mdl = window:Add( "DModelPanel" )
				mdl:SetSize( mdlWide, winTall )
				mdl:Dock( LEFT )
				mdl:SetFOV( 36 )
				mdl:SetCamPos( mdlCamPos )
				mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
				mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
				mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
				mdl:SetAnimated( true )
				mdl.Angles = Angle( 0, 0, 0 )
				mdl:SetLookAt( Vector( -100, 0, -22 ) )

				local pcount = mdl:Add( "DLabel" )
				pcount:Dock( BOTTOM )
				pcount:SetText( 0 )
				pcount:SetFont( "ScoreboardDefaultTitle" )
				pcount:SetTextColor( Color( 255, 255, 255, 255 ) )
				pcount:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
				pcount:SetContentAlignment( 5 )
				pcount:SizeToContents()
				pcount:SetTall( winTall * 0.125 )

				local lbl = mdl:Add( "DLabel" )
				lbl:Dock( BOTTOM )
				lbl:SetText( teamInfo.Name )
				lbl:SetFont( "ScoreboardDefaultTitle" )
				lbl:SetTextColor( teamInfo.Color )
				lbl:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
				lbl:SetContentAlignment( 5 )
				lbl:SizeToContents()
				lbl:SetTall( winTall * 0.5 )

				mdl.Fov = 36
				mdl.FrontBright = 70
				mdl.Current = false

				if ( IsValid( ply ) && pTeam == teamID ) then
					mdl.Current = true
					mdl:SetDisabled( true )
					mdl.Fov = 28
					mdl.FrontBright = 255
				end

				mdl.DoClick = function()
					RunConsoleCommand( "changeteam", teamID )
					window:Close()
				end

				function mdl:LayoutEntity( ent )
					if ( self.bAnimated ) then self:RunAnimation() end

					if ( self.Hovered || self.Current ) then
						self.NewFov = 28
						self.NewFrontBright = 255
					else
						self.NewFov = 36
						self.NewFrontBright = 70
					end

					pcount:SetText( team.NumPlayers( teamID ) )

					self.Fov = Lerp( FrameTime() * 10, self.Fov, self.NewFov )
					self.FrontBright = Lerp( FrameTime() * 10, self.FrontBright, self.NewFrontBright )

					self:SetFOV( self.Fov )
					self:SetDirectionalLight( BOX_FRONT, Color( self.FrontBright, self.FrontBright, self.FrontBright, 255 ) )

					ent:SetAngles( self.Angles )
				end

				local teamModel = GAMEMODE.TeamSelectModels[ teamID ]

				local modelname = teamModel.model && teamModel.model || "models/player/kleiner.mdl"

				mdl:SetModel( modelname )
				mdl.Entity.GetPlayerColor = function() return teamModel.color end
				mdl.Entity:SetPos( Vector( -100, 0, -61 ) )

				local iSeq = mdl.Entity:LookupSequence( teamModel.pose && teamModel.pose || "idle_all_01" )
				if ( iSeq > 0 ) then mdl.Entity:ResetSequence( iSeq ) end

			end
		end
	end
})

local listPlayerClassStats = {
	CanUseFlashlight = "Flashlight Enabled",
	WalkSpeed = "Walk Speed",
	RunSpeed = "Run Speed",
	JumpPower = "Jump Power",
	MaxHealth = "Maximum Health",
	StartHealth = "Start Health",
	StartArmor = "Start Armor",
	DropWeaponOnDie = "Drops Weapon"
}

-- Maybe list weapons??

list.Set( "FacileDesktopWindows", "FacileSelectClass", {

	title		= "Select Class",
	icon		= "icon64/fa_class.png",
	width		= 960,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )

		--window:SetTitle( "Select Class" )
		window:SetIcon( "icon16/group.png" )
		window:SetSizable( false )
		window:Center()

		local pl = LocalPlayer()

		local pTeam = pl:Team()
		
		window:SetTitle( "Select Class ("..team.GetName(pTeam)..")" )

		if ( pTeam == TEAM_SPECTATOR ) then
			window:Close()
			return
		end

		local Classes = team.GetClass( pTeam )

		local currentClass = player_manager.GetPlayerClass( pl )
		
		local classOptionsPnl = window:Add( "DPanel" )
		classOptionsPnl:Dock( BOTTOM )
		classOptionsPnl:SetDrawBackground( false )

		local chooseBtn = classOptionsPnl:Add( "DButton" )
		chooseBtn:Dock( RIGHT )
		chooseBtn:SetText( "Choose Class" )
		chooseBtn:SetFont( "DermaVRDefault" )
		chooseBtn:SizeToContents()

		local sheet = window:Add( "DColumnSheet" )
		sheet:Dock( FILL )
		sheet:DockPadding( 0, 0, 0, 4 )
		sheet.Navigation:SetWidth( 200 )

		chooseBtn.DoClick = function()
			local activeBtn = sheet:GetActiveButton()

			if ( activeBtn && activeBtn.classId ) then
				RunConsoleCommand( "changeclass", activeBtn.classId )
			end

			window:Close()
		end

		for ID, ClassName in pairs( Classes ) do
			local playerclassTable = baseclass.Get( ClassName )

			local sameClass = IsValid( pl ) && currentClass == ClassName

			local addition = sameClass && " (Current)" || ""
			local icon = sameClass && "icon16/status_online.png" || "icon16/status_offline.png"

			local controls = window:Add( "DPanel" )
			controls:Dock( FILL )
			controls:DockPadding( 16, 8, 16, 8 )

			local lbl = controls:Add( "DLabel" )
			lbl:SetText( playerclassTable.DisplayName..addition )
			lbl:SetFont( "ScoreboardDefaultTitle" )
			lbl:SetTextColor( Color( 0, 0, 0, 255 ) )
			lbl:SetContentAlignment( 5 )
			lbl:Dock( TOP )
			lbl:SizeToContents()

			local lblInfo = controls:Add( "DLabel" )
			lblInfo:SetText( playerclassTable.Info && playerclassTable.Info || "No information" )
			lblInfo:SetTextColor( Color( 0, 0, 0, 255 ) )
			lblInfo:Dock( TOP )
			lblInfo:SetWrap( true )
			lblInfo:SetAutoStretchVertical( true )

			local statList = controls:Add( "DListStats" )
			statList:Dock( TOP )
			statList:DockMargin( 0, 10, 0, 0 )
			statList:SetTall( 200 )
			statList:SetMultiSelect( false )
			statList:SetSortable( false )
			statList:AddColumn( "Name" )
			statList:AddColumn( "Value" )

			local playerclassTableCur = nil

			if ( currentClass ) then
				playerclassTableCur = baseclass.Get( currentClass )
			end
			
			for k,v in pairs( listPlayerClassStats ) do
				local data = playerclassTable[ k ]

				if ( data == nil ) then
					continue
				end

				if ( sameClass ) then
					local pnl = statList:AddLine( v, data )
				elseif ( type( data ) == "number" && playerclassTableCur != nil ) then
					local compData = playerclassTableCur[ k ]

					if ( compData == nil ) then continue end

					local dataMod = data
					local diff = data - compData

					if ( diff < 0 || diff > 0 ) then
						dataMod = dataMod .. " (" .. diff .. ")"
					end

					local pnl = statList:AddLine( v, dataMod )

					if ( diff < 0 ) then
						pnl.SLow = true
					elseif ( diff > 0 ) then
						pnl.SHigh = true
					end
				else
					local pnl = statList:AddLine( v, data )
					pnl.SHigh = true
				end
			end

			local sheetTbl = sheet:AddSheet( playerclassTable.DisplayName, controls, icon )

			sheetTbl.Button.classId = ID

			if ( sameClass ) then
				sheet:SetActiveButton( sheetTbl.Button )
			end
		end
	end
})

list.Set( "FacileDesktopWindows", "FacileLoadoutMenu", {

	title		= "Loadout Menu",
	icon		= "icon64/fa_loadout.png",
	width		= 960,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )

		window:SetTitle( "Loadout Menu" )
		window:SetSizable( true )
		window:Center()

		local bg = window:Add( "DScrollPanel" )
		bg:Dock( FILL )
		
		local layout = bg:Add( "DTileLayout" )
		layout:SetBaseSize( 32 )
		layout:Dock( FILL )
		
		local LoadoutWeps = list.Get("FacileLoadoutWeapons")
		local LoadoutWeapons = LoadoutWeps["defaultSet"]
		local validWeapons = LoadoutWeps["defaultSetValid"]-- Super nice to have lol
		
		local weaponConVarList = {
			GetConVar( "cl_facile_loadout_weapon0" ),
			GetConVar( "cl_facile_loadout_weapon1" ),
			GetConVar( "cl_facile_loadout_weapon2" ),
			GetConVar( "cl_facile_loadout_weapon3" ),
			GetConVar( "cl_facile_loadout_weapon4" ),
			GetConVar( "cl_facile_loadout_weapon5" ),
			GetConVar( "cl_facile_loadout_weapon6" ),
			GetConVar( "cl_facile_loadout_weapon7" ),
			GetConVar( "cl_facile_loadout_weapon8" ),
			GetConVar( "cl_facile_loadout_weapon9" )
		}
		
		local selectedWeapons = {}
		
		for k,convar in ipairs(weaponConVarList) do
			local str = convar:GetString()
			
			if ( str ~= "" ) then
				
				if ( not validWeapons[ str ] ) then
					-- Remove invalid weapons to help deal with loosing convars
					
					convar:SetString("")
				else
					selectedWeapons[str] = true
				end
			end
		end
		
		local function updateWeapons( key )
			local item = layout:GetChild( key )
			
			if (not IsValid(item)) then return end
			
			if (item.Chosen) then
				item.Chosen = false
				selectedWeapons[item.SpawnName] = nil
			else
				if ( table.Count(selectedWeapons) < 10 ) then
					selectedWeapons[item.SpawnName] = true
					item.Chosen = true
				end
			end
			
			local convarIndex = 0
			
			for classname,v in pairs(selectedWeapons) do
				weaponConVarList[(convarIndex + 1)]:SetString(classname)
				
				convarIndex = convarIndex + 1
			end
			
			for i=(convarIndex+1), 10 do
				weaponConVarList[i]:SetString("")
			end
		end
		
		for k,wep in ipairs( LoadoutWeapons ) do
			local butt = layout:Add( "ContentIcon" )
			
			local classname = wep.ClassName
			
			butt.SpawnName = classname
			butt:SetName( wep.PrintName or classname )
			butt:SetMaterial( "entities/"..classname..".png" )
			
			-- quicker
			butt.Chosen = selectedWeapons[classname] || false
			
			butt.DoClick = function()
				updateWeapons( k - 1 )
			end
		end
	end
})