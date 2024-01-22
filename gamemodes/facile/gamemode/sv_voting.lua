function GM:VoteGamemode( pl, gamemode )

	if ( !gamemode ) then return end

	pl:SetNWString( "WantsGM", gamemode )

end

--concommand.Add( "votegamemode", function( pl, cmd, args ) GAMEMODE:VoteGamemode( pl, args[1] ) end )

function GM:VoteMap( pl, map )

	if ( !map ) then return end

	pl:SetNWString( "WantsMap", map )

end

--concommand.Add( "votemap", function( pl, cmd, args ) GAMEMODE:VoteMap( pl, args[1] ) end )