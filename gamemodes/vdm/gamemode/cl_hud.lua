include( "cl_vdmhud.lua" )

local xhairMat = Material("vdm/crosshair")
local Xwidth = 16
local widthH = Xwidth * 0.5

local surfaceSetDrawColor, surfaceSetMaterial, surfaceDrawTexturedRectRotated = surface.SetDrawColor, surface.SetMaterial, surface.DrawTexturedRectRotated

local hitmarkerAlpha = 0
local hitmarkerSize = 10

local function HitMarkerPing( len )
	surface.PlaySound( 'volantarius/quake/qhit.wav' )
	
	hitmarkerAlpha = 100
end

net.Receive( "vdm_hitmarker", HitMarkerPing )

local function DrawHitMarker()
	if ( hitmarkerAlpha <= 0 ) then
		return
	end
	
	local ply = LocalPlayer()
	
	local MidX = ScrW() * 0.5
	local MidY = ScrH() * 0.5
	
	surfaceSetDrawColor( 0, 255, 0, 255 * (hitmarkerAlpha / 100) )
	surfaceSetMaterial( xhairMat )
	
	surfaceDrawTexturedRectRotated( MidX + widthH + hitmarkerSize, MidY - widthH - hitmarkerSize, Xwidth, 2, 45 )
	
	surfaceDrawTexturedRectRotated( MidX - widthH - hitmarkerSize, MidY + widthH + hitmarkerSize, Xwidth, 2, 225 )
	
	surfaceDrawTexturedRectRotated( MidX - widthH - hitmarkerSize, MidY - widthH - hitmarkerSize, Xwidth, 2, 135 )
	
	surfaceDrawTexturedRectRotated( MidX + widthH + hitmarkerSize, MidY + widthH + hitmarkerSize, Xwidth, 2, 315 )
	
	hitmarkerAlpha = hitmarkerAlpha * ( (1 - FrameTime()) * 0.85 )
end

-- Need to make this a client convar so yeah...
local Xsize, Xwidth = 5, 16

local function DrawCrosshair()
	local ply = LocalPlayer()

	if ( ply:IsFrozen() ) then return end
	
	local wep = ply:GetActiveWeapon()
	
	if ( not IsValid(wep) or wep.DrawCrosshair == false ) then return end
	
	local MidX = ScrW() * 0.5
	local MidY = ScrH() * 0.5
	
	-- Helper
	--surface.SetDrawColor( 255, 0, 0, 128 )
	--surface.DrawRect( MidX-Xsize, MidY-Xsize, Xsize*2, Xsize*2 )
	
	surfaceSetDrawColor( 0, 255, 0, 255 )
	surfaceSetMaterial( xhairMat )
	
	local XwidthH = Xwidth * 0.5
	
	surfaceDrawTexturedRectRotated( MidX + XwidthH + Xsize, MidY, Xwidth, 2, 0 )
	
	surfaceDrawTexturedRectRotated( MidX - XwidthH - Xsize, MidY, Xwidth, 2, 180 )
	
	--surfaceDrawTexturedRectRotated( MidX, MidY - XwidthH - Xsize, Xwidth, 2, 90 )
	
	surfaceDrawTexturedRectRotated( MidX, MidY + XwidthH + Xsize, Xwidth, 2, 270 )
end

hook.Add("HUDPaint", "VDMHUD", function()
	local ply = LocalPlayer()
	local pteam = ply:Team()
	
	DrawHitMarker()
	
	if ( ply:Alive() && pteam > 0 && pteam < 5 ) then
		DrawCrosshair()
	end
end)

-- This will hide elements for the other hud stuff
local hideElements = {
	"CHudAmmo",
	"CHudSecondaryAmmo",
	--"CHudHealth",
	--"CHudBattery",
	"CHudCrosshair",
	
	"CHudZoom",
	"CHudGeiger",
	"CHudPoisonDamageIndicator"
}

function GM:HUDShouldDraw( name )
	for k, v in pairs(hideElements) do
		if name == v then return false end
	end
	
	if ( name == "CHudDamageIndicator" && !LocalPlayer():Alive() ) then
		return false
	end
	
	return true
end

-- Weapon BOBBING
local cycle = 0

local bobtimelast = 0
local bobtime = 0

local crouchOffset = 0
local vertVelocity = 0--for jumping

local alivechecked = false
local viewOffDuck = Vector(0, 0, 28)
local viewOff = Vector(0, 0, 64)

local lastOldAng = Angle(0,0,0)
local lastDifAng = Angle(0,0,0)

local overallSwayAmnt = 7--4
local swayDampen = 0.9

function GM:CalcViewModelView( wep, vm, oldPos, oldAng, pos, ang )
	-- oldPos, oldAng -> original positions before bobbing, swaying
	local ply = LocalPlayer()

	local lalive = ply:Alive()
	
	bobtimelast = bobtime
	bobtime = UnPredictedCurTime()-- Yeah man this doesn't need prediction yo
	local delta = bobtime - bobtimelast
	
	local forward = ang:Forward()
	local up = ang:Up()
	local right = ang:Right()
	
	if (lalive ~= alivechecked) then
		alivechecked = lalive
		
		if (alivechecked) then
			viewOffDuck = ply:GetViewOffsetDucked()
			viewOff = ply:GetViewOffset()
		end
	end
	
	local currentView = ply:GetCurrentViewOffset()
	
	crouchOffset = 1 - ((currentView.z - viewOffDuck.z) / (viewOff.z - viewOffDuck.z))
	
	local speed = ply:GetAbsVelocity():Length2D()
	
	speed = math.Clamp( speed, -320, 320 )
	
	if ( speed == 0 ) then
		cycle = 0
	end
	
	local scalar = math.abs(speed) / 320
	
	cycle = cycle + (delta * 2.1 * scalar)-- 2.8
	
	local bob = 2 * math.sin( math.pi * cycle ) * scalar
	
	local bob2 = 2 * math.sin( math.pi * cycle * 2 ) * scalar
	
	local newPos = oldPos + (right * bob * 0.3) + (up * bob2 * 0.3) + (forward * bob2 * 0.1)
	
	newPos = newPos + (forward * crouchOffset * -2.0) + (up * crouchOffset * 1.0)
	
	-- Aim angle
	local newDifAng = lastDifAng + (oldAng - lastOldAng)
	newDifAng:Normalize()
	
	newDifAng.p = math.Clamp(newDifAng.p, -overallSwayAmnt, overallSwayAmnt)
	newDifAng.y = math.Clamp(newDifAng.y, -overallSwayAmnt, overallSwayAmnt)
	--newDifAng.r = math.Clamp(newDifAng.r, -overallSwayAmnt, overallSwayAmnt)
	
	-- Keep oldAng
	lastOldAng = oldAng
	lastDifAng = newDifAng * ((1.0 - delta) * swayDampen)
	
	-- 1 : Overall sway like in Serious Sam
	--local finalAng = oldAng + newDifAng
	
	--2 : weapon roll like in ARMA 3
	local finalAng = oldAng
	finalAng.r = finalAng.r - newDifAng.y
	
	finalAng:Normalize()
	
	-- Now allow the weapon's code to modify the view
	local func = wep.CalcViewModelView
	
	if ( func ) then
		local custom_pos, custom_ang = func( wep, vm, oldPos, oldAng, newPos, finalAng )
		
		newPos = custom_pos
		finalAng = custom_ang
	end
	
	return newPos, finalAng
	--return newPos, oldAng
end