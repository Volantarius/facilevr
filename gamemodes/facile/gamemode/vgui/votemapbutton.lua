local PANEL = {}

function PANEL:Init()

	self:SetText( "" )
	--self:SetSize( 136, 136 + 20 )
	self:SetSize( 256, 136 + 20 )
	self.Paint = function( self, w, h )

		if ( self.Winner ) then
			surface.SetDrawColor( 255, 200, 0, 200 )

		elseif ( self.Depressed ) then
			surface.SetDrawColor( 0, 200, 255, 200 )

		elseif ( self.Hovered ) then
			surface.SetDrawColor( 0, 130, 200, 200 )
			
		elseif ( self.Chosen ) then
			surface.SetDrawColor( 10, 200, 0, 200 )

		elseif ( self.OtherChosen ) then
			surface.SetDrawColor( 50, 160, 0, 170 )
			
		else
			surface.SetDrawColor( 0, 0, 0, 170 )
		end

		surface.DrawRect( 0, 0, w, h )
	end

	self.OtherChosen = false
	self.Chosen = false
	self.VoteCount = 0
	self.Winner = false

	self.thumb = self:Add( "DImage" )
	self.thumb:SetImage( "maps/thumb/noicon.png" )
	self.thumb:SetSize( 128, 128 )
	self.thumb:SetPos( 64, 4 )

	self.label = self:Add( "DLabel" )
	self.label:Dock( BOTTOM )
	self.label:SetText( "unknown" )
	self.label:SetFont( "ScoreboardDefault" )
	self.label:SetContentAlignment( 5 )
	self.label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	self.label:DockMargin( 0, 0, 0, 2 )

	--self.counter = self.thumb:Add( "DLabel" )
	--[[self.counter = self:Add( "DLabel" )
	self.counter:Dock( BOTTOM )
	self.counter:DockMargin( 8, 4, 4, 8 )
	self.counter:SetText( " " )
	self.counter:SetFont( "ScoreboardDefaultTitle" )
	self.counter:SetContentAlignment( 4 )--5
	self.counter:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.counter:SetExpensiveShadow( 2, Color( 0, 0, 0, 250 ) )]]

	--self.counter:SetVisible( false )

	--self.counter:SizeToContents()

	self.thumbGame = self:Add( "DImage" )
	self.thumbGame:SetImage( "icon16/error.png" )
	self.thumbGame:SetSize( 16, 16 )
	self.thumbGame:SetPos( 5, 5 )

	self.DoClick = function()
		if ( self.mapName ) then
			RunConsoleCommand( "votemap", self.mapName )
		end
	end
end

function PANEL:Setup( name, image, icon )
	self.thumb:SetImage( image )
	self.label:SetText( name )
	self.thumbGame:SetImage( icon )
end

--[[function PANEL:SetCount( num )
	if ( num == self.VoteCount ) then return end

	self.VoteCount = num

	--self.counter:SetVisible( !(self.VoteCount < 1) )

	if (self.VoteCount < 1) then
		self.counter:SetText( " " )
	else
		self.counter:SetText( num )
	end

	self.counter:SizeToContents()
end]]

function PANEL:SetWinner( state )
	self.Winner = state

	if ( state ) then
		self.counter:SetTextColor( Color( 255, 200, 0, 255 ) )
	else
		self.counter:SetTextColor( Color( 145, 255, 0, 255 ) )
	end
end

vgui.Register( "FacileVoteMapButton", PANEL, "DButton" )