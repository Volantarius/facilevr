local PANEL = {}

function PANEL:Init()
	self:SetContentAlignment( 2 )
	
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	
	self:SetTall( 22 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	
	self:SetCursor( "hand" )
	self:SetFont( "DermaDefault" )
end

function PANEL:SetImage( img )
	
	if ( !img ) then
		if ( IsValid( self.m_Image ) ) then
			self.m_Image:Remove()
		end
		
		return
	end
	
	if ( !IsValid( self.m_Image ) ) then
		self.m_Image = vgui.Create( "DImage", self )
	end
	
	self.m_Image:SetImage( img )
	self.m_Image:SizeToContents()
	self.m_Image:SetPaintedManually( true )
	self:InvalidateLayout()
end

function PANEL:Paint( w, h )
	derma.SkinHook( "Paint", "Button", self, w, h )
	
	self.m_Image:PaintManual()
	
	return false
end

function PANEL:PerformLayout( w, h )
	
	if ( IsValid( self.m_Image ) ) then
		self.m_Image:SetSize( 128, 128 )
		self.m_Image:SetPos( (self:GetWide() - self.m_Image:GetWide()) * 0.5, (self:GetTall() - self.m_Image:GetTall()) * 0.5 )
	end
	
	DLabel.PerformLayout( self, w, h )
	
end

vgui.Register( "FacileMapButton", PANEL, "DButton" )