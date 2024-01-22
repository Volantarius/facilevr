AddCSLuaFile()

-- Right now this is just a debug setup
-- @Volantarius: (2022/8) HOLY FUCK THIS WORKS!
-- Hooking works, since they are named we can shut them down manually and correctly!

-- All setup functions are ran after global, so that we can override the defaults

function GM:SetupHalfLifeRules()
	if ( SERVER ) then
		
		-- Fuck the original death sound call..
		
	else
		
		
		
	end
end

--[[----	----	----	----	----	----	----	----]]

function GM:ShutdownHalfLifeRules()
	if ( SERVER ) then
		
		
		
	else
		
		
		
	end
end