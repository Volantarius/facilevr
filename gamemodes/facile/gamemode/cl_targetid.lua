--local font = "TargetID"
local font = "GModNotify"

--[[
	Determine if another player's id should be visable
	return anything to disable drawing
]]
function GM:ShouldDrawTargetID( target, localTeam )

end

--[[---------------------------------------------------------
   Name: gamemode:HUDDrawTargetID( )
   Desc: Draw the target id (the name of the player you're currently looking at)
-----------------------------------------------------------]]
function GM:HUDDrawTargetID()

	local pl = LocalPlayer()
	local observeMode = pl:GetObserverMode()
	
	if ( observeMode > 0 && observeMode < 6 ) then return end

	local tr = util.GetPlayerTrace( pl )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end
	
	local text = "ERROR"
	
	local pTeam = pl:Team()
	
	if ( trace.Entity:IsPlayer() ) then
		if ( pTeam != TEAM_SPECTATOR ) then
			self:ShouldDrawTargetID( trace.Entity, pTeam )
		end

		text = trace.Entity:Nick()
	else
		return
	end
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	x = x - w / 2
	y = y + 96

	local tColor = self:GetTeamColor( trace.Entity )
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, tColor )
end
