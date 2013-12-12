
function GM:Initialize()
end

function GM:PlayerInitialSpawn( ply )
	//ply:SetTeam( TEAM_BLUE );
	ply:Initialize();
end

function GM:PlayerSpawn( ply )
	ply:AssignBot();
end

function GM:PlayerDeath( ply )
	ply:SetParent( nil );
	
	local char = ply:GetCharacterDetails();
	if ( char ) then
		char.OnDeath( ply, ply:GetBot() );
	end
	
	if ( ply:GetBot() ) then
		ply:GetBot():Remove();
		ply.moba.bot = nil;
	end
end

function GM:PlayerShouldTakeDamage()
	return false;
end

function GM:ShouldCollide( ply, bot )
	return false;
end