local PANEL = {}

local matOverlay_Normal = Material( "gui/ContentIcon-normal.png" )
local matOverlay_Hovered = Material( "gui/ContentIcon-hovered.png" )

function PANEL:Init()
	
	self:SetPaintBackground( false )
	self:SetText( "" )
	self:SetSize( 128, 128 )
	self:SetDoubleClickingEnabled( false )
	
	self.Chosen = false
	
	self.thumb = self:Add( "DImage" )
	--self.thumb:SetImage( "maps/thumb/noicon.png" )
	self.thumb:SetPos( 3, 3 )
	self.thumb:SetSize( 128 - 6, 128 - 6 )
	self.thumb:SetVisible( false )
	
	self.label = self:Add( "DLabel" )
	self.label:Dock( BOTTOM )
	self.label:SetTall( 18 )
	self.label:SetText( "unknown" )
	self.label:SetContentAlignment( 5 )
	self.label:DockMargin( 4, 0, 4, 6 )
	self.label:SetTextColor( color_white )
	self.label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	
	self.DoClick = function()
		--if ( self.mapName ) then
		--	RunConsoleCommand( "votemap", self.mapName )
		--end
		self.Chosen = not self.Chosen
	end
end

function PANEL:OnDepressionChanged( b )
end

function PANEL:Paint( w, h )
	if ( self.Depressed ) then
		self:OnDepressionChanged( true )
	else
		self:OnDepressionChanged( false )
	end
	
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	
	self.thumb:PaintAt( 4, 4, 128 - 8, 128 - 8 )
	
	render.PopFilterMin()
	render.PopFilterMag()
	
	if ( self.Chosen ) then
		surface.SetDrawColor( 110, 220, 0, 200 )
		surface.DrawRect( 4, h - 24 - 2, w - 8, 22 - 2 )
	end
	
	--if ( self:IsHovered() || self.Depressed || self:IsChildHovered() ) then
	--	surface.SetMaterial( matOverlay_Hovered )
	--end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	if ( self.Chosen ) then
		surface.SetMaterial( matOverlay_Hovered )
	else
		surface.SetMaterial( matOverlay_Normal )
	end
	
	surface.DrawTexturedRect( 0, 0, w, h )
end

function PANEL:SetName( name )
	self:SetTooltip( name )
	self.label:SetText( name )
end

function PANEL:SetMaterial( name )
	local mat = Material( name )
	
	if ( !mat || mat:IsError() ) then
		name = name:Replace( "entities/", "VGUI/entities/" )
		name = name:Replace( ".png", "" )
		mat = Material( name )
	end
	
	if ( !mat || mat:IsError() ) then
		return
	end
	
	self.thumb:SetMaterial( name )
end

vgui.Register( "ContentIcon", PANEL, "DButton" )