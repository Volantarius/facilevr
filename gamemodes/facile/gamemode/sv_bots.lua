function drawThePath( path, time )
	local prevArea
	for _, area in pairs( path ) do
		--[[debugoverlay.Sphere( area:GetCenter(), 8, time or 9, color_white, true  )
		
		if ( prevArea ) then
			debugoverlay.Line( area:GetCenter(), prevArea:GetCenter(), time or 9, color_white, true )
		end]]
		
		area:Draw()
		prevArea = area
	end
end

function heuristic_cost_estimate( start, goal )
	-- Perhaps play with some calculations on which corner is closest/farthest or whatever
	return start:GetCenter():DistToSqr( goal:GetCenter() )
end

-- using CNavAreas as table keys doesn't work, we use IDs
function reconstruct_path( cameFrom, current )
	local total_path = { current }

	current = current:GetID()
	while ( cameFrom[ current ] ) do
		current = cameFrom[ current ]
		table.insert( total_path, navmesh.GetNavAreaByID( current ) )
	end
	return total_path
end

function Astar( start, goal )
	if ( !IsValid( start ) || !IsValid( goal ) ) then return false end
	if ( start == goal ) then return true end

	start:ClearSearchLists()

	start:AddToOpenList()

	local cameFrom = {}

	start:SetCostSoFar( 0 )

	start:SetTotalCost( heuristic_cost_estimate( start, goal ) )
	start:UpdateOnOpenList()

	while ( !start:IsOpenListEmpty() ) do
		local current = start:PopOpenList() -- Remove the area with lowest cost in the open list and return it
		if ( current == goal ) then
			return reconstruct_path( cameFrom, current )
		end

		current:AddToClosedList()

		for k, neighbor in pairs( current:GetAdjacentAreas() ) do
			local newCostSoFar = current:GetCostSoFar() + heuristic_cost_estimate( current, neighbor )

			if ( neighbor:IsUnderwater() || neighbor:IsBlocked() || !neighbor:IsFlat() ) then -- Add your own area filters or whatever here
				continue
			end
			
			if ( ( neighbor:IsOpen() || neighbor:IsClosed() ) && neighbor:GetCostSoFar() <= newCostSoFar ) then
				continue
			else
				neighbor:SetCostSoFar( newCostSoFar )
				neighbor:SetTotalCost( newCostSoFar + heuristic_cost_estimate( neighbor, goal ) )

				if ( neighbor:IsClosed() ) then
				
					neighbor:RemoveFromClosedList()
				end

				if ( neighbor:IsOpen() ) then
					-- This area is already on the open list, update its position in the list to keep costs sorted
					neighbor:UpdateOnOpenList()
				else
					neighbor:AddToOpenList()
				end

				cameFrom[ neighbor:GetID() ] = current:GetID()
			end
		end
	end

	return false
end

local player_GetHumans = player.GetHumans

function get_nearestplayerpos( pos )
	local nearest = 67108864
	local nearest_pos = nil
	
	for k,p in ipairs( player_GetHumans() ) do
		local target_pos = p:GetPos()
		local diff = target_pos - target_pos
		local diff_length = diff:LengthSqr()
		
		if ( diff_length < nearest ) then
			nearest = diff_length
			nearest_pos = target_pos
		end
	end
	
	return nearest_pos
end

local rePathDelay = 1

function GM:AssBot( ply, cmd )
	local bot_position = ply:GetPos()
	
	local currentArea = navmesh.GetNearestNavArea( bot_position )

	-- internal variable to regenerate the path every X seconds to keep the pace with the target player
	ply.lastRePath = ply.lastRePath or 0

	-- internal variable to limit how often the path can be (re)generated
	ply.lastRePath2 = ply.lastRePath2 or 0 

	if ( ply.path && ply.lastRePath + rePathDelay < CurTime() && currentArea != ply.targetArea ) then
		ply.path = nil
		ply.lastRePath = CurTime()
	end

	if ( !ply.path && ply.lastRePath2 + rePathDelay < CurTime() ) then
		
		local pos_temp = get_nearestplayerpos( bot_position )
		
		local targetPos = bot_position
		
		if ( pos_temp ~= nil ) then
			targetPos = pos_temp
		end
		
		local targetArea = navmesh.GetNearestNavArea( targetPos )

		ply.targetArea = nil
		ply.path = Astar( currentArea, targetArea )
		if ( !istable( ply.path ) ) then -- We are in the same area as the target, or we can't navigate to the target
			ply.path = nil -- Clear the path, bail and try again next time
			ply.lastRePath2 = CurTime()
			return
		end
		--PrintTable( ply.path )

		-- TODO: Add inbetween points on area intersections
		-- TODO: On last area, move towards the target position, not center of the last area
		table.remove( ply.path ) -- Just for this example, remove the starting area, we are already in it!
	end

	-- We have no path, or its empty (we arrived at the goal), try to get a new path.
	if ( !ply.path || #ply.path < 1 ) then
		ply.path = nil
		ply.targetArea = nil
		return
	end

	-- We got a path to follow to our target!
	--drawThePath( ply.path, .1 ) -- Draw the path for debugging

	-- Select the next area we want to go into
	if ( !IsValid( ply.targetArea ) ) then
		ply.targetArea = ply.path[ #ply.path ]
	end
	
	local target_position = ply.targetArea:GetCenter()
	
	local path_vector = target_position - bot_position
	local path_length = path_vector:Length2DSqr()
	
	-- The area we selected is invalid or we are already there, remove it, bail and wait for next cycle
	if ( !IsValid( ply.targetArea ) || ( ply.targetArea == currentArea && path_length < 128 ) ) then
		table.remove( ply.path ) -- Removes last element
		ply.targetArea = nil
		return
	end
	
	-- We got the target to go to, aim there and MOVE
	local targetang = path_vector:GetNormalized():Angle()
	cmd:SetViewAngles( targetang )
	cmd:SetForwardMove( 200 )
end