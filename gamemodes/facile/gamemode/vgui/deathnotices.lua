surface.CreateFont( "FacileDeathNotice", {
	font	= "Rajdhani SemiBold",
	size	= 28,
	weight	= 600,
} )

local PANEL = {}

function PANEL:Init()
	
	self:DockPadding( 3, 3, 3, 3 )

	self.Label = vgui.Create( "DLabel", self )
	self.Label:Dock( FILL )
	self.Label:SetText("")
	self.Label:SetContentAlignment( 5 )

	self:SetBackgroundColor( Color( 45, 45, 45, 255 * 0.8 ) )

	self.Items = {}

end

function PANEL:SetLocalVictim()
	self.LocalVictim = true
	self:SetBackgroundColor( Color( 128, 0, 0, 255 * 0.8 ) )
end

function PANEL:SizeToContents()

	self.Label:SizeToContents()

	local width, tall = self.Label:GetSize()

	tall = 32 + 8
	width = width + 20

	local x = 10

	for k,v in ipairs( self.Items ) do

		v:SizeToContents()

		local vWide, vTall = v:GetSize()

		local itemName = v:GetName()

		if ( itemName != "DLabel" ) then

			local nextItem = self.Items[k + 1]

			if ( nextItem && nextItem:GetName() != "DLabel" ) then
				--vWide = vWide - 4
			else
				vWide = vWide + 4
			end

			local kW, kH = killicon.GetSize( itemName )

			v:SetPos( x, ( kH - tall ) * 0.5 )
		else

			v:SetPos( x, 0 )
		end

		v:SetTall( tall )

		width = width + vWide + 8

		x = x + vWide + 8

	end

	width = width - 8

	self:SetSize( width, tall )

	self:InvalidateLayout()

end

function PANEL:AddItem( panel )

	table.insert( self.Items, panel )
	self:InvalidateLayout()

end

function PANEL:ParseEntityText( txt )

	local txtType = type( txt )

	if ( txtType == "string" ) then return false end

	if ( txtType == "Player" ) then
		self:AddText( txt:Nick(), GAMEMODE:GetTeamColor( txt ) )

		if ( txt == LocalPlayer() ) then
			self.LocalAttack = true
		end

		return true
	end

	if ( txt ) then
		self:AddText( txt:GetClass(), color_white )
	else
		return false
	end

end

function PANEL:AddText( txt, color )

	if ( self:ParseEntityText( txt ) ) then return end

	local txt = tostring( txt )

	local lbl = vgui.Create( "DLabel", self )
	lbl:SetText( txt )
	lbl:SetFont( "FacileDeathNotice" )
	lbl:SetContentAlignment( 5 )

	if ( !color && txt[1] == "#" ) then color = GAMEMODE.DeathNoticeDefaultColor end
	if ( !color && GAMEMODE.DeathNoticeTextColor ) then color = GAMEMODE.DeathNoticeTextColor end
	if ( !color ) then color = color_white end

	lbl:SetTextColor( color )
	
	self:AddItem( lbl )

end

function PANEL:AddIcon( txt, color )

	if ( killicon.Exists( txt ) ) then
		local icn = vgui.Create( "DKillIcon", self.Label )
		icn:SetName( txt )

		self:AddItem( icn )
	else
		self:AddText( "#"..txt, color )
	end

end

function PANEL:Paint( w, h )

	self.BaseClass.Paint( self, w, h )

	if ( self.LocalAttack && !self.LocalVictim ) then
		surface.SetDrawColor( 255, 0, 0, 225 )
		surface.DrawOutlinedRect( 2, 2, w-4, h-4 )
	end

end

vgui.Register( "DeathnoticePanel", PANEL, "DPanel" )