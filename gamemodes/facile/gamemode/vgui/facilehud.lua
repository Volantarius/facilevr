local PANEL = {}

function PANEL:Init()
	
	self:SetPaintBackground( false )
	self:SetText( "" )
	self:SetSize( 4, 4 )
	
	self:ParentToHUD()
	
end

--[[
	7 8 9
	4 5 6
	1 2 3
]]
function PANEL:SetAlignment( alignment )
	-- Should stay within the original hud's offsets
	local wideOff = ScrW() * 0.019
	local tallOff = ScrH() * 0.025
	
	if ( alignment == 7 || alignment == 8 || alignment == 9 ) then
		--if ( IsValid( self.HUDrelative ) ) then
			--self:MoveAbove( self.HUDrelative, 8 )
		--else
			self:AlignTop( tallOff )
		--end
	end
	
	if ( alignment == 4 || alignment == 5|| alignment == 6 ) then
		--if ( IsValid( self.HUDrelative ) ) then
			--self:MoveAbove( self.HUDrelative, 8 )
		--else
			self:CenterVertical()
		--end
	end
	
	if ( alignment == 1 || alignment == 2 || alignment == 3 ) then
		--if ( IsValid( self.HUDrelative ) ) then
			--self:MoveAbove( self.HUDrelative, 8 )
		--else
			self:AlignBottom( tallOff )
		--end
	end
	
	-- BLLLLLLLLLLLLLLLLLLLLLLLLL
	
	if ( alignment == 7 || alignment == 4 || alignment == 1 ) then
		--if ( IsValid( self.HUDrelative ) ) then
			--self:MoveAbove( self.HUDrelative, 8 )
		--else
			self:AlignLeft( wideOff )
		--end
	end
	
	if ( alignment == 8 || alignment == 5 || alignment == 2 ) then
		--if ( IsValid( self.HUDrelative ) ) then
			--self:MoveAbove( self.HUDrelative, 8 )
		--else
			self:CenterHorizontal()
		--end
	end
	
	if ( alignment == 9 || alignment == 6 || alignment == 3 ) then
		--if ( IsValid( self.HUDrelative ) ) then
			--self:MoveAbove( self.HUDrelative, 8 )
		--else
			self:AlignRight( wideOff )
		--end
	end
	
	self.alignment = alignment
end

function PANEL:PerformLayout()
	
	local width = 16
	local height = 4
	
	for k, v in pairs( self:GetChildren() ) do
		
		local wide, tall = v:GetSize()
		
		v:SetPos( width, 8 )
		
		width = width + wide + 16
		height = math.max(height, tall)
		
	end
	
	width = width + 16 - 16
	height = height + 16
	
	self:SetSize( width, height )
	
	if ( self.alignment ) then
		self:SetAlignment( self.alignment )
	else
		self:AlignTop( ScrH() * 0.025 )
		self:CenterHorizontal()
	end
	
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 8, 0, 0, w, h, Color(0, 0, 0, 80) )
end

derma.DefineControl( "FaHUDPanel", "", PANEL, "DPanel" )