AddCSLuaFile()
-- This is shared!!

if (SERVER) then
hook.Add("Initialize", "FacileRecoil", function()
	util.AddNetworkString( "fr" )
end)
end

local meta = FindMetaTable("Player")
if ( !meta ) then return end

function meta:VRecoil( pitch, yaw )
	local p = pitch || 0
	local y = yaw || 0
	
	--p = p * 0.6
	--y = y * 0.6
	
	if ( SERVER ) then
		net.Start( "fr" )
		net.WriteFloat( p )
		net.WriteFloat( y )
		net.Send( self )
		return
	end
	
	self.VRecoilPitch = p
	self.VRecoilYaw = y
	
	--self.VRecoilPitch = self.VRecoilPitch + p
	--self.VRecoilYaw = self.VRecoilYaw + y
end

if ( CLIENT ) then
	net.Receive( "fr", function( ln )
		local p = net.ReadFloat()
		local y = net.ReadFloat()
		
		LocalPlayer():VRecoil( p, y )
	end )
end

local LastTime, mathApproach, mathAbs = UnPredictedCurTime(), math.Approach, math.abs

function meta:DoVRecoilThink()
	if SERVER then return end
	if self:IsBot() then return end
	
	local pitch = self.VRecoilPitch or 0
	local yaw = self.VRecoilYaw or 0
	
	local NowTime = UnPredictedCurTime()
	local delta = NowTime - LastTime
	LastTime = NowTime
	
	local pitch_d = mathApproach( pitch, 0.0, 20.0 * delta * mathAbs(pitch) )
	local yaw_d   = mathApproach( yaw,   0.0, 20.0 * delta * mathAbs(yaw) )
	
	self.VRecoilPitch = pitch_d
	self.VRecoilYaw = yaw_d
	
	local eyeAng = self:EyeAngles()
	eyeAng.pitch = eyeAng.pitch + ( pitch - pitch_d )
	eyeAng.yaw = eyeAng.yaw + ( yaw - yaw_d )
	eyeAng.roll = 0
	
	self:SetEyeAngles( eyeAng )
end

-- Finally add a hook for everyone to run recoil think
if ( CLIENT ) then
	hook.Add("Think", "VRecoilThink", function()
		LocalPlayer():DoVRecoilThink()
	end)
end