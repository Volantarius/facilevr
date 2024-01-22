AddCSLuaFile()

DEFINE_BASECLASS( "drive_base" )

drive.Register( "drive_test",
{
	--
	-- Called on creation
	--
	Init = function( self )

		self.CameraDist		= 4
		self.CameraDistVel	= 0.1
		
		self.OldMoveType = self.Player:GetMoveType()
		self.OldVelocity = self.Player:GetVelocity()
		
	end,
	
	Stop = function( self )
		self.Player:SetMoveType( self.OldMoveType )
		self.Player:SetVelocity( -1 * self.OldVelocity + (-1 * self.Player:GetVelocity()) )
		
		self.StopDriving = true
	end,
	
	--
	-- A generic thirdperson view
	--
	-- > view			- the view passed into CalcView
	-- > dist			- the ideal distance from the center
	-- > hullsize		- the size of the hull to trace so we don't go through walls (0 for no trace)
	-- > entityfilter	- usually the self.Entity - so our trace doesn't hit the entity in question
	--
	CalcView_ThirdPerson = function( self, view, dist, hullsize, entityfilter )
		
		view.origin = view.origin + Vector(0,0,8)
		
		--
		-- > Get the current position (teh center of teh entity)
		-- > Move the view backwards the size of the entity
		--
		local offset = self.Player:EyeAngles():Forward()
		local neworigin = view.origin - (offset * dist)


		if ( hullsize && hullsize > 0 ) then

			--
			-- > Trace a hull (cube) from the old eye position to the new
			--
			local tr = util.TraceHull( {
				start	= view.origin - (offset * 8),
				endpos	= neworigin,
				mins	= Vector( hullsize, hullsize, hullsize ) * -1,
				maxs	= Vector( hullsize, hullsize, hullsize ),
				filter	= entityfilter
			} )

			--
			-- > If we hit something then stop there
			--		[ stops the camera going through walls ]
			--
			if ( tr.Hit ) then
				neworigin = tr.HitPos
			end

		end

		--
		-- Set our calculated origin
		--
		view.origin		= neworigin

		--
		-- Set the angles to our view angles (not the entities eye angles)
		--
		view.angles		= self.Player:EyeAngles()

	end,
	
	--
	-- Calculates the view when driving the entity
	--
	CalcView = function( self, view )

		--
		-- Use the utility method on drive_base.lua to give us a 3rd person view
		--
		local idealdist = math.max( 10, self.Entity:BoundingRadius() ) * self.CameraDist

		self:CalcView_ThirdPerson( view, idealdist, 2, { self.Entity } )

		view.angles.roll = 0

	end,

	SetupControls = function( self, cmd )

		--
		-- If we're holding the reload key down then freeze the view angles
		--
		if ( cmd:KeyDown( IN_RELOAD ) ) then

			self.CameraForceViewAngles = self.CameraForceViewAngles or cmd:GetViewAngles()

			cmd:SetViewAngles( self.CameraForceViewAngles )

		else

			self.CameraForceViewAngles = nil

		end

		--
		-- Zoom out when we use the mouse wheel (this is completely clientside, so it's ok to use a lua var!!)
		--
		self.CameraDistVel = self.CameraDistVel + cmd:GetMouseWheel() * -0.5

		self.CameraDist = self.CameraDist + self.CameraDistVel * FrameTime()
		self.CameraDist = math.Clamp( self.CameraDist, 2, 20 )
		self.CameraDistVel = math.Approach( self.CameraDistVel, 0, self.CameraDistVel * FrameTime() * 2 )

	end,
	--
	-- Called before each move. You should use your entity and cmd to
	-- fill mv with information you need for your move.
	--
	StartMove = function( self, mv, cmd )

		--
		-- Set the observer mode to chase so that the entity is drawn
		--
		self.Player:SetObserverMode( OBS_MODE_CHASE )

		--
		-- Use (E) was pressed - stop it.
		--
		if ( mv:KeyReleased( IN_USE ) ) then
			self:Stop()
		end
		
		--
		-- Update move position and velocity from our entity
		--
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )
		mv:SetMoveAngles( mv:GetAngles() )		-- Always move relative to the player's eyes

		local entity_angle		= mv:GetAngles()
		entity_angle.roll		= self.Entity:GetAngles().roll

		--
		-- Right mouse button is down, don't change the angle of the object
		--
		if ( mv:KeyDown( IN_ATTACK2 ) or mv:KeyReleased( IN_ATTACK2 ) ) then
			entity_angle = self.Entity:GetAngles()
		end

		--
		-- If reload is down then spin the object around
		--
		if ( mv:KeyDown( IN_RELOAD ) ) then

			entity_angle.roll = entity_angle.roll + cmd:GetMouseX() * 0.01

		end

		--
		-- Right mouse button was released
		--
		--[[if ( mv:KeyReleased( IN_ATTACK2 ) ) then
			self.Player:SetEyeAngles( self.Entity:GetAngles() )
		end]]

		mv:SetAngles( entity_angle )

	end,

	--
	-- Runs the actual move. On the client when there's
	-- prediction errors this can be run multiple times.
	-- You should try to only change mv.
	--
	Move = function( self, mv )

		--
		-- Set up a speed, go faster if shift is held down
		--
		--local speed = 0.0005 * FrameTime()
		--if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.005 * FrameTime() end
		local speed = 0.04 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.10 * FrameTime() end

		--
		-- Get information from the movedata
		--
		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()

		-- Cancel out the roll
		ang.roll = 0

		--
		-- Add velocities. This can seem complicated. On the first line
		-- we're basically saying get the forward vector, then multiply it
		-- by our forward speed (which will be > 0 if we're holding W, < 0 if we're
		-- holding S and 0 if we're holding neither) - and add that to velocity.
		-- We do that for right and up too, which gives us our free movement.
		--
		vel = vel + (ang:Forward()	* mv:GetForwardSpeed()	* speed)
		vel = vel + (ang:Right()	* mv:GetSideSpeed()		* speed)
		vel = vel + (ang:Up()		* mv:GetUpSpeed()		* speed)

		--
		-- We don't want our velocity to get out of hand so we apply
		-- a little bit of air resistance. If no keys are down we apply
		-- more resistance so we slow down more.
		--
		if ( math.abs( mv:GetForwardSpeed() ) + math.abs( mv:GetSideSpeed() ) + math.abs( mv:GetUpSpeed() ) < 0.1 ) then
			vel = vel * 0.02
		else
			vel = vel * 0.50
		end

		-- VOLANTARIUS
		vel.z = 0

		--
		-- Add the velocity to the position (this is the movement)
		--
		pos = pos + vel

		--
		-- We don't set the newly calculated values on the entity itself
		-- we instead store them in the movedata. These get applied in FinishMove.
		--
		mv:SetVelocity( vel )
		mv:SetOrigin( pos )

	end,

	--
	-- The move is finished. Use mv to set the new positions
	-- on your entities/players.
	--
	FinishMove = function( self, mv )

		--
		-- Update our entity!
		--
		--self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		self.Entity:SetAbsVelocity( mv:GetVelocity() )
		--self.Entity:SetAngles( mv:GetAngles() )
		
		self.Entity:SetAngles( Angle(0, 0, 0) )
		
		if ( not self.Player:Alive() ) then
			self:Stop()
		end
		
		local fwrd = mv:GetAngles():Forward()
		--local fwrd = ang
		
		local tr = util.TraceLine({
			start = mv:GetOrigin() - (fwrd * 64),
			endpos = fwrd * 1000,
			filter = {self.Player, self.Entity}
		})
		
		if ( tr.Hit ) then
			--phys:SetPos(  + mv:GetOrigin() )
			self.Entity:SetNetworkOrigin( tr.HitPos )
		--else
		--	self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		end
		
		--
		-- If we have a physics object update that too. But only on the server.
		-- If there isn't a valid physics object STOP fucking driving!
		--
		if ( SERVER ) then
			local phys = self.Entity:GetPhysicsObject()
			
			if ( not IsValid( phys ) ) then
				self:Stop()
				return
			end
			
			phys:EnableMotion( true )
			phys:SetPos( mv:GetOrigin() )
			phys:Wake()
			phys:EnableMotion( false )
		end

	end

}, "drive_base" )
