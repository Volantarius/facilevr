-- Total hack but works lol!
ENT.Type = "point"

--[[
origin	0 0 0
pitch	-14
angles	-14 52 0
_lightscaleHDR	1
_lightHDR	-1 -1 -1 1
_light	255 255 255 300
_AmbientScaleHDR	1
_ambientHDR	-1 -1 -1 1
_ambient	145 200 255 60
classname	light_environment
hammerid	35
]]

function ENT:KeyValue( key, value )
	--print( key, value )
	
	--self:SetKeyValue(key, value)
	
	if ( key == "_ambient" ) then
		self.ambient = value
	elseif ( key == "_light" ) then
		self.light = value
	elseif ( key == "pitch" ) then
		self.pitch = value
	else
		return false
	end
	
	return false
end