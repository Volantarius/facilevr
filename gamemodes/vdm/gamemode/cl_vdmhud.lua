surface.CreateFont( "VdmHudDefault", {
	font	= "Saira ExtraCondensed SemiBold",
	size	= 54,
	weight	= 400
} )

local BLIT_BAR = {
	Init = function( self )
		--
	end,
	
	Setup = function( self, color, boxHeight, y, time, timeAdj )
		self.DieTime = time
		self.timeAdj = timeAdj
		self.BoxCol = color
		
		self:SetPos( 0, y )
		self:SetTall( boxHeight )
	end,
	
	Paint = function( self, w, h )
		local NowTime = UnPredictedCurTime()
		local boxColor = self.BoxCol
		local dieTime = self.DieTime
		
		if ( NowTime <= dieTime ) then
			local delta = math.Clamp( (dieTime - NowTime) * (1/self.timeAdj), 0, 1 )
			
			surface.SetDrawColor( boxColor.r, boxColor.g, boxColor.b, 255 * delta )
			surface.DrawRect( 0, 0, w, h )
		end
	end,
	
	Think = function( self, w, h )
		if ( UnPredictedCurTime() > self.DieTime ) then
			self:Remove()
			return
		end
	end
}

derma.DefineControl( "vdmBlitBar", "", BLIT_BAR, "DPanel" )

local pBarHeight, pBarHeightLast = 1, 1
local pBarTime = 0.500-- pBarTime for the timeAdj in BLIT_BAR

local PRIMARY_MAGAZINE = {
	Init = function( self )
		self:Dock( RIGHT )
		self.MaxClip = 1
		self.Ammo = 1
	end,
	
	Paint = function( self, w, h )
		if ( self.Ammo == -1 || self.MaxClip == -1 ) then return end
		
		surface.SetDrawColor( 0, 50, 0, 120 )
		surface.DrawRect( 0, 0, w, h )
		
		pBarHeightLast = pBarHeight
		pBarHeight = math.ceil(h * (self.Ammo / self.MaxClip))
		
		surface.SetDrawColor( 0, 200, 0, 120 )
		surface.DrawRect( 0, h - pBarHeight, w, pBarHeight )
		
		if ( (pBarHeight - pBarHeightLast) ~= 0 ) then
			local BlastTime = UnPredictedCurTime() + pBarTime
			
			local blitFired = vgui.Create( "vdmBlitBar" )
			
			local blitHeight = pBarHeightLast - pBarHeight
			
			local yaxis = h - pBarHeight - blitHeight
			
			local color = Color(20,255,20)
			--local color = Color(255,20,20)
			
			if (blitHeight < 0) then
				yaxis = h - pBarHeight
				color = Color(255,255,255)
			end
			
			blitFired:Setup( 
				color,
				math.abs(blitHeight),--BOX HEIGHT
				yaxis,--Y AXIS
				BlastTime,
				pBarTime )
			
			self:Add( blitFired )--Push a rectangle to the bar and make it flash
		end
	end,
	
	SetMaxClip = function( self, num )
		self.MaxClip = num
	end,
	
	SetAmmo = function( self, num )
		self.Ammo = num
	end,
	
	Think = function( self, w, h ) end
}

derma.DefineControl( "vdmPrimaryMag", "", PRIMARY_MAGAZINE, "DPanel" )

local PRIMARY_AMMO = {
	Init = function( self )
		self:Dock( RIGHT )
		
		self.MaxAmmo = GetConVar("gmod_maxammo"):GetInt()
		self.PriAmmoNum = 0
	end,
	
	SetAmmo = function( self, num, full )
		if ( full ) then
			self.PriAmmoNum = self.MaxAmmo
		else
			self.PriAmmoNum = num
		end
	end,
	
	Paint = function( self, w, h )
		surface.SetDrawColor( 0, 50, 45, 120 )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 0, 200, 190, 120 )
		surface.DrawRect( 0, 0, w, h * (self.PriAmmoNum / self.MaxAmmo) )
	end,
	
	Think = function( self, w, h ) end
}

derma.DefineControl( "vdmPrimaryAmmo", "", PRIMARY_AMMO, "DPanel" )

local ALT_FIRE = {
	Init = function( self )
		self.Col = Color( 200, 200, 0 )
	end,
	
	Paint = function( self, w, h )
		local col = self.Col
		surface.SetDrawColor( col.r, col.g, col.b, 240 )
		surface.DrawRect( 0, 0, w, h )
	end,
	
	Think = function( self, w, h ) end
}

derma.DefineControl( "vdmAltFire", "", ALT_FIRE, "DPanel" )

local Header, Footer, PrimaryMag, PrimaryAmmo, ClipCounter, AmmoCounter, Foot2, AlternateFire, AltName, WepName

local HUD_CONTAINER = {
	Init = function( self )
		ply = LocalPlayer()

		Header = self:Add( "Panel" )
		Header:DockPadding( 8, 8, 8, 8 )
		Header:Dock( TOP )
		
		Footer = self:Add( "Panel" )
		Footer:DockPadding( 8, 0, 8, 8 )
		Footer:Dock( BOTTOM )
		
		PrimaryMag = vgui.Create( "vdmPrimaryMag" )
		Header:Add( PrimaryMag )
		
		PrimaryAmmo = vgui.Create( "vdmPrimaryAmmo" )
		Footer:Add( PrimaryAmmo )
		
		ClipCounter = Header:Add( "DLabel" )
		ClipCounter:Dock( BOTTOM )
		ClipCounter:SetFont( "VdmHudDefault" )
		ClipCounter:SetTextColor( Color( 0, 200, 0, 255 ) )
		ClipCounter:SetContentAlignment( 3 )
		ClipCounter:SizeToContents()
		ClipCounter:DockMargin( 0, 0, 8, 0 )
		ClipCounter:SetExpensiveShadow( 2, Color( 0, 0, 0, 255 ) )
		
		AmmoCounter = Footer:Add( "DLabel" )
		AmmoCounter:Dock( TOP )
		AmmoCounter:SetFont( "VdmHudDefault" )
		AmmoCounter:SetTextColor( Color( 0, 200, 190, 255 ) )
		AmmoCounter:SetContentAlignment( 9 )
		AmmoCounter:SizeToContents()
		AmmoCounter:DockMargin( 0, 0, 8, 0 )
		AmmoCounter:SetExpensiveShadow( 2, Color( 0, 0, 0, 255 ) )
		
		Foot2 = Footer:Add( "Panel" )
		Foot2:Dock( BOTTOM )
		Foot2:SetHeight( 32 )
		
		AlternateFire = vgui.Create( "vdmAltFire" )
		AlternateFire:SetSize( 32, 32 )
		AlternateFire:Dock( RIGHT )
		AlternateFire:DockMargin( 0, 0, 8, 0 )
		Foot2:Add( AlternateFire )
		
		AltName = Foot2:Add( "DLabel" )
		AltName:Dock( RIGHT )
		AltName:SetFont( "VdmHudDefault" )
		AltName:SetTextColor( Color( 200, 200, 0, 255 ) )
		AltName:SetContentAlignment( 6 )
		AltName:SizeToContents()
		AltName:DockMargin( 0, 0, 8, 0 )
		AltName:SetExpensiveShadow( 2, Color( 0, 0, 0, 255 ) )
		
		WepName = Footer:Add( "DLabel" )
		WepName:Dock( BOTTOM )
		WepName:SetFont( "VdmHudDefault" )
		WepName:SetTextColor( Color( 200, 200, 200, 255 ) )
		WepName:SetContentAlignment( 3 )
		WepName:SizeToContents()
		WepName:DockMargin( 0, 0, 8, 0 )
		WepName:SetExpensiveShadow( 2, Color( 0, 0, 0, 255 ) )
		
		ClipCounter:SetText("")
		AmmoCounter:SetText("")
		AltName:SetText("")
		WepName:SetText("")
	end,
	
	SetWeaponName = function( self, name )
		WepName:SetText( name )
		--WepName:SizeToContents()
	end,
	
	SetAmmoCounter = function( self, ammoCount )
		AmmoCounter:SetText( ammoCount .. " " )
	end,
	
	-- Blue bar
	SetAmmoBar = function( self, ammoCount, full )
		PrimaryAmmo:SetAmmo( ammoCount, full )
	end,
	
	-- Green bar
	SetMagMaxBar = function( self, maxClip )
		PrimaryMag:SetMaxClip( maxClip )
	end,
	
	SetMagBar = function( self, ammoCount )
		PrimaryMag:SetAmmo( ammoCount )
		
		if ( ammoCount < 0 ) then
			ClipCounter:SetText( "" )
		else
			ClipCounter:SetText( ammoCount .. " " )
		end
	end,
	
	SetAltCounterType = function( self, type, ammoCount )
		if ( type == 1 ) then
			AltName:SetText( "FIRE " )
			AltName:SetTextColor( Color( 200, 200, 0, 255 ) )
			AlternateFire.Col = Color( 200, 200, 0, 255 )
		elseif ( type == 2 ) then
			AltName:SetText( "IDK " )
			AltName:SetTextColor( Color( 200, 100, 0, 255 ) )
			AlternateFire.Col = Color( 200, 100, 0, 255 )
		elseif ( type == 3 ) then
			AltName:SetText( ammoCount .. " " )
			AltName:SetTextColor( Color( 200, 100, 0, 255 ) )
			AlternateFire.Col = Color( 200, 100, 0, 255 )
		else
			AltName:SetText( ammoCount .. " " )
			AltName:SetTextColor( Color( 200, 0, 0, 255 ) )
			AlternateFire.Col = Color( 200, 0, 0, 255 )
		end
		
		AltName:SizeToContents()
	end,
	
	SetAltCounter = function( self, ammoCount )
		AltName:SetText( ammoCount .. " " )
	end,
	
	PerformLayout = function( self )
		self:SetSize( 400, (ScrH() * 0.5) - 50 )
		self:SetPos( (ScrW() * 0.9) - 400 - 64, ScrH() * 0.5 ) -- Maybe move the hud more to the center?????????????????
		
		Header:SetHeight( self:GetTall() * 0.6666 )
		Footer:SetHeight( self:GetTall() - Header:GetTall() )
	end,
	
	Paint = function( self, w, h )
		--surface.SetDrawColor( 0, 0, 0, 120 )
		--surface.DrawRect( 0, 0, w, h )
	end,
	
	Think = function( self, w, h ) end
}

derma.DefineControl( "vdmHudContainer", "", HUD_CONTAINER, "DPanel" )

-- Automatically create the hud during every startup
hook.Add( "InitPostEntity", "VDMHudCreate", function()
	g_vdmHud = vgui.Create( "vdmHudContainer" )
	
	g_vdmHud.AllowAutoRefresh = true
	
	g_vdmHud.PreAutoRefresh = function()
		g_vdmHud:Clear()
	end
	
	g_vdmHud.PostAutoRefresh = function()
		g_vdmHud:Init()
	end
	
	g_vdmHud:ParentToHUD()
	
	g_vdmHud:Hide()
end )

local Alive = false
local CurrentWeapon = NULL

hook.Add( "HUDNeedsUpdate", "VDMUpdateHUD", function( value )
	local pl = LocalPlayer()
	
	if ( not IsValid(g_vdmHud) ) then return end
	
	if ( not IsValid(pl) ) then return end
	
	-- 1 for alive, 0 for dead
	if (value == 1 || value == 0) then
		Alive = value == 1
		
		if (Alive) then
			g_vdmHud:Show()
		else
			g_vdmHud:Hide()
		end
	end
end )

local AmmoCounterType = -1
local AmmoAltType = -1
local Clip1Valid = false

local function UpdateWeapon( pl, newWeapon )
	CurrentWeapon = newWeapon
	
	local tempName = CurrentWeapon:GetPrintName()
	local WeaponNamePrint = "UNKNOWN"
	
	if ( tempName ~= nil ) then
		if ( tempName[1] == "#" ) then
			WeaponNamePrint = language.GetPhrase( tempName )
		else
			WeaponNamePrint = tempName
		end
	end
	
	g_vdmHud:SetWeaponName( string.upper(WeaponNamePrint) .. " " )
	
	local PriAmmoType = CurrentWeapon:GetPrimaryAmmoType()
	local SecAmmoType = CurrentWeapon:GetSecondaryAmmoType()
	
	if ( PriAmmoType > 0 ) then
		AmmoCounterType = PriAmmoType
	else
		if ( SecAmmoType > 0 ) then
			AmmoCounterType = SecAmmoType
		else
			g_vdmHud:SetAmmoCounter( "--" )
			g_vdmHud:SetAmmoBar( 1, true )
			AmmoCounterType = -1
		end
	end
	
	local IsScripted = CurrentWeapon:IsScripted()
	
	if ( IsScripted && CurrentWeapon.VdmSecondaryName ~= nil ) then
		g_vdmHud:SetAltCounterType( 3, CurrentWeapon.VdmSecondaryName )
		AmmoAltType = -1
	elseif ( SecAmmoType < 1 ) then
		g_vdmHud:SetAltCounterType( 1 )
		AmmoAltType = -1
	elseif ( PriAmmoType < 1 && SecAmmoType > 0 ) then
		g_vdmHud:SetAltCounterType( 2 )
		AmmoAltType = -1
	else
		g_vdmHud:SetAltCounterType( 4, "--" )
		AmmoAltType = SecAmmoType
	end
	
	local MaxClip1 = CurrentWeapon:GetMaxClip1()
	local Clip1 = CurrentWeapon:Clip1()
	
	--local CustomAmmoDisplay = IsScripted && sCurrentWeapon.CustomAmmoDisplay ~= nil && sCurrentWeapon:CustomAmmoDisplay() ~= nil
	-- At some point support custom ammo display
	
	if ( Clip1 > -1 and MaxClip1 > -1 ) then
		g_vdmHud:SetMagBar( Clip1 )
		g_vdmHud:SetMagMaxBar( MaxClip1 )
		Clip1Valid = true
	else
		g_vdmHud:SetMagBar( -1 )
		g_vdmHud:SetMagMaxBar( -1 )
		Clip1Valid = false
	end
end

hook.Add( "HUDPaint", "VDMHudPaint", function()
	local pl = LocalPlayer()
	
	if ( not IsValid(pl) || not IsValid(g_vdmHud) || not Alive ) then return end
	
	local checkNewWeap = pl:GetActiveWeapon()
	
	if ( not IsValid(checkNewWeap) ) then return end
	
	if ( CurrentWeapon ~= checkNewWeap ) then
		UpdateWeapon( pl, checkNewWeap )
	end
	
	if ( AmmoCounterType > 0 ) then
		local blah = pl:GetAmmoCount(AmmoCounterType)
		g_vdmHud:SetAmmoCounter( blah )
		
		g_vdmHud:SetAmmoBar( blah )
	end
	
	if ( AmmoAltType > 0 ) then
		g_vdmHud:SetAltCounter( pl:GetAmmoCount(AmmoAltType) )
	end
	
	if ( Clip1Valid ) then
		g_vdmHud:SetMagBar( CurrentWeapon:Clip1() )
	end
end )