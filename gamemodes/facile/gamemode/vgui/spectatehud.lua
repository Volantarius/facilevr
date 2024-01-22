local PANEL = {}

function PANEL:Init()
	
	local scrW, scrH = ScrW(), ScrH()
	
	self:SetPaintBackground( false )
	self:SetText( "" )
	self:SetSize( scrW, scrH )
	self:SetZPos( -100 )
	
	--0.09
	local specBarHeight = scrH * 0.135
	
	local Top = vgui.Create( "DPanel", self )
	Top:SetPos( 0, -1 )
	Top:SetText( "" )
	Top:SetSize( scrW, specBarHeight )
	Top:SetContentAlignment( 5 )
	
	Top.Paint = function(self, w, h)
		surface.SetDrawColor( 0, 0, 0, 192 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	--[[local TopRightLabel = vgui.Create( "DLabel", Top )
	TopRightLabel:SetText( game.GetMap() )
	TopRightLabel:SetFont( "Trebuchet24" )
	TopRightLabel:SetSize( scrW * 0.5 - 8, specBarHeight - 8 )
	TopRightLabel:SetPos( scrW * 0.5, 0 )
	TopRightLabel:SetContentAlignment( 3 )]]
	
	local TopLeftLabel = vgui.Create( "DLabel", Top )
	TopLeftLabel:SetText( game.GetMap() )
	TopLeftLabel:SetFont( "CenterPrintText" )
	TopLeftLabel:SetSize( scrW * 0.5 - 8, specBarHeight - 8 )
	TopLeftLabel:SetPos( 8, 0 )
	TopLeftLabel:SetContentAlignment( 1 )
	
	local Bottom = vgui.Create( "DPanel", self )
	Bottom:SetPos( 0, scrH - specBarHeight + 1 )
	Bottom:SetText( "" )
	Bottom:SetSize( scrW, specBarHeight )
	Bottom:SetContentAlignment( 5 )
	
	Bottom.Paint = function(self, w, h)
		surface.SetDrawColor( 0, 0, 0, 192 )
		surface.DrawRect( 0, 0, w, h )
	end
	
end

function PANEL:Paint( w, h )
end

derma.DefineControl( "FaSpectateHud", "", PANEL, "DPanel" )

local function CreateSpecHUD()
	g_SpecHud = vgui.Create( "FaSpectateHud" )
	
	g_SpecHud.AllowAutoRefresh = true
	
	-- OKAY so derma control vgui needs a function in order to handle changes
	-- So we need to clear the vgui and re init this baby
	-- Also stop globally adding shit lol
	g_SpecHud.PreAutoRefresh = function()
		g_SpecHud:Clear()
	end
	
	-- IT WORKS!!! Clear and then init will keep the panel hidden and shit
	
	g_SpecHud.PostAutoRefresh = function()
		g_SpecHud:Init()
	end
	
	g_SpecHud:ParentToHUD()
end

hook.Add( "InitPostEntity", "CreateSpecHUD", CreateSpecHUD )