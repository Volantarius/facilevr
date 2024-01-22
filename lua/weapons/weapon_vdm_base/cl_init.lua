include( "shared.lua" )

SWEP.Author = "Volantarius"
SWEP.Category = "Volantarius"

SWEP.Slot = 2
SWEP.SlotPos = 7

SWEP.UseHands = true

SWEP.DrawCrosshair = true

killicon.Add( "weapon_vdm_base", "killicons/csgo_aug", Color(255, 255, 255, 255) )

SWEP.WepSelectIcon = surface.GetTextureID( "killicons/csgo_aug" )
SWEP.WepSelectColor = Color( 255, 236, 12 )
SWEP.WepSelectIconSquare = false

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	local c = self.WepSelectColor
	surface.SetDrawColor( c.r, c.g, c.b, alpha )
	surface.SetTexture( self.WepSelectIcon )

	wide = wide - 40

	y = y + 25

	if (self.WepSelectIconSquare) then
		x = x + 20 + (wide * 0.25)

		surface.DrawTexturedRectUV( x, y, wide * 0.5, wide * 0.5, 1, 0, 0, 1 )
	else
		x = x + 20

		surface.DrawTexturedRectUV( x+2, y+2, wide, wide * 0.5, 1, 0, 0, 1 )
	end
end

-- Nothing for now only VCSS will have their muzzleflashes, unless otherwise
function SWEP:FireAnimationEvent( pos, ang, event, options )

end

local haptic_func = GAMEMODE.TriggerHaptic

-- For Controllers or VR
function SWEP:PrimaryHaptic()
	
	if ( haptic_func ) then
		-- Two pulses, at 7/60
		haptic_func( 0, 0.0, 0.116666, 1, 1.0 )
	end
end

--[[
	local formatViewModelFov = SWEP:FormatViewModelFov

	Create a local copy and use it for positioning effects and stuff on the weapon!
]]
local math_tan = math.tan
local pi_sixty = math.pi / 360

function SWEP:FormatViewModelFov(nFOV, vOrigin, bInverse)
	bInverse = bInverse || false

	local vEyePos = EyePos()
	local aEyesRot = EyeAngles()
	local vOffset = vOrigin - vEyePos
	local vForward = aEyesRot:Forward()

	local nViewX = math_tan(nFOV * pi_sixty)

	if (nViewX == 0) then
		vForward:Mul(vForward:Dot(vOffset))
		vEyePos:Add(vForward)

		return vEyePos
	end

	-- FIXME: LocalPlayer():GetFOV() should be replaced with EyeFOV() when it's binded
	local nWorldX = math_tan(LocalPlayer():GetFOV() * pi_sixty)

	if (nWorldX == 0) then
		vForward:Mul(vForward:Dot(vOffset))
		vEyePos:Add(vForward)

		return vEyePos
	end

	local nFactor = nWorldX / nViewX
	local vRight = aEyesRot:Right()
	local vUp = aEyesRot:Up()

	if (bInverse) then
		vRight:Mul(vRight:Dot(vOffset) / nFactor)
		vUp:Mul(vUp:Dot(vOffset) / nFactor)
	else
		vRight:Mul(vRight:Dot(vOffset) * nFactor)
		vUp:Mul(vUp:Dot(vOffset) * nFactor)
	end

	vForward:Mul(vForward:Dot(vOffset))

	vEyePos:Add(vRight)
	vEyePos:Add(vUp)
	vEyePos:Add(vForward)

	return vEyePos
end

--[[
	Alright for slides and stuff, we will have the interaction activate the interactable
	Once started to grab, the position we grab will be stored.. then the dot on the slide normal to the
	position so we can slide the magazines and slides

	If we're going to test for positions and hulls, use spheres..

	(hand_pos - interact_pos):LengthSqr -> x^2 + y^2 + z^2

	then compare squared length.. faster than a hull check in lua
	and represents the circle thing im going to do, like in horsehoes and handgrenades
]]

function SWEP:DrawVRInteraction( interact_pos, interact_ang )
	-- Draw interactable positions? or summink
end
