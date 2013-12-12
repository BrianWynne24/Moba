
local function ccCastSpell( ply, cmd, args )
	local spell = tostring( args[1] );
	
	if ( !MOBA.Spells[ spell ] && !ply:HasSpell( spell ) ) then return; end
	ply:CastSpell( spell );
end
concommand.Add( "mb_cast", ccCastSpell );