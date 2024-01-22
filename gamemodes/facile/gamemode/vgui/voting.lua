local PANEL = {}

function PANEL:Init()

	self:ParentToHUD()

	CloseDermaMenus()

	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( false )

	self.CountDown = SysTime() + 21

	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), ScrH() )

	self.Background = vgui.Create( "DPanel", self )
	self.Background.Paint = function( self, w, h )
		surface.SetDrawColor( 0, 0, 0, 180 )
		surface.DrawRect( 0, 0, w, h )
	end
	self.Background:SetZPos( 0 )

	self.Border = vgui.Create( "DPanel", self )
	self.Border:SetBackgroundColor( Color( 0, 0, 0, 180 ) )
	self.Border:SetZPos( 1 )

	self.Label = vgui.Create( "DLabel", self )
	self.Label:SetFont( "ScoreboardDefaultTitle" )
	self.Label:SetText( "Vote for the next map" )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SetContentAlignment( 5 )
	self.Label:SetZPos( 3 )

	self.Counter = vgui.Create( "DLabel", self )
	self.Counter:SetFont( "ScoreboardDefaultTitle" )
	self.Counter:SetText( "---" )
	self.Counter:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Counter:SetContentAlignment( 5 )
	self.Counter:SetZPos( 3 )

	self.BasePanel = vgui.Create( "DPanel", self )
	self.BasePanel:SetZPos( 2 )

	self.ScrollPanel = vgui.Create( "DScrollPanel", self.BasePanel )
	self.ScrollPanel:Dock( FILL )

	self.List = vgui.Create( "DIconLayout", self.ScrollPanel )
	self.List:Dock( FILL )
	self.List:SetBorder( 0 )
	self.List:SetSpaceX( 4 )
	self.List:SetSpaceY( 4 )

	self.Items = {}

	self.BasePanel:SetDrawBackground( false )

end

function PANEL:AddItem( panel )
	self.List:Add( panel )

	table.insert( self.Items, panel )

	self.List:Layout()
end

function PANEL:PerformLayout()

	local width, tall = self:GetSize()

	self.Background:SetSize( width, tall )
	self.Background:SetPos( 0, 0 )

	self.Label:SizeToContents()
	self.Label:SetPos( 0, (tall * 0.125) - 16 )
	self.Label:SetSize( width, 32 )

	self.Counter:SizeToContents()
	self.Counter:SetPos( 0, (tall * 0.875) + 48 )
	self.Counter:SetSize( width, 32 )

	local bsize = 136
	local count = math.floor( (width - 64) / bsize )
	local newWidth = ( bsize * count ) + ( count * 4 ) + 16.5

	self.BasePanel:SetSize( newWidth, tall * 0.75 )
	self.BasePanel:SetPos( (( width - newWidth ) * 0.5) + 10.25, tall * 0.125 + 32 )

	self.Border:SetSize( width, (tall * 0.75) + 96 + 32 )
	self.Border:SetPos( 0, (tall * 0.125) - 32 )

	self.BasePanel:InvalidateLayout()

end

function PANEL:Close()
	self:Remove()
end

function PANEL:Think()

	local counter = math.floor( self.CountDown - SysTime() )

	if ( counter < -2 ) then
		self:Remove()
		return
	end

	if ( counter < 0 ) then
		self.Counter:SetText( "0" )
		--self.Counter:SizeToContents()
	else
		self.Counter:SetText( counter )
		--self.Counter:SizeToContents()
	end

	local votes = {}
	local localVoted = nil
	local localPlayer = LocalPlayer()

	for k,v in ipairs( player.GetHumans() ) do
		local map = v:GetNWString( "WantsMap", "" )
		
		if ( localPlayer == v ) then
			localVoted = map
		end

		local voted = votes[ map ]

		if ( voted ) then
			votes[ map ] = voted + 1
		else
			votes[ map ] = 1
		end
	end

	-- Need to show the winner
	--self:SetWinner( true )

	for k,v in pairs( self.Items ) do

		local beenVoted = votes[ v.mapName ]

		if ( beenVoted ) then
			--v:SetCount( beenVoted )
			v.OtherChosen = true

			if ( localVoted && v.mapName == localVoted ) then
				v.Chosen = true
			end
		else
			--v:SetCount( 0 )
			v.OtherChosen = false
			v.Chosen = false
		end
	end

end

vgui.Register( "FacileVote", PANEL, "EditablePanel" )