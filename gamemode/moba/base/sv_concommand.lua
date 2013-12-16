
local function ccCastSpell( ply, cmd, args )
	local slot = tonumber( args[1] );
	print( slot );
	
	if ( ply:HasSpell( slot ) ) then
		ply:CastSpell( slot );
	end
end
concommand.Add( "mb_cast", ccCastSpell );