--DListView but highlights higher/lower values in green/red
local PANEL_LINE = {}

function PANEL_LINE:Paint( w, h )
	self.BaseClass.Paint( self, w, h )

	if ( self.SHigh ) then
		surface.SetDrawColor( 0, 255, 0, 120 )
		surface.DrawRect( 0, 0, w, h )
	elseif ( self.SLow ) then
		surface.SetDrawColor( 255, 0, 0, 120 )
		surface.DrawRect( 0, 0, w, h )
	end
end

vgui.Register( "DListStats_Line", PANEL_LINE, "DListViewLine" )

local PANEL = {}

function PANEL:AddLine( ... )

	self:SetDirty( true )
	self:InvalidateLayout()

	local Line = vgui.Create( "DListStats_Line", self.pnlCanvas )
	local ID = table.insert( self.Lines, Line )

	Line:SetListView( self )
	Line:SetID( ID )

	-- This assures that there will be an entry for every column
	for k, v in pairs( self.Columns ) do
		Line:SetColumnText( k, "" )
	end

	for k, v in pairs( {...} ) do
		Line:SetColumnText( k, v )
	end

	-- Make appear at the bottom of the sorted list
	local SortID = table.insert( self.Sorted, Line )

	if ( SortID % 2 == 1 ) then
		Line:SetAltLine( true )
	end

	return Line

end

vgui.Register( "DListStats", PANEL, "DListView" )