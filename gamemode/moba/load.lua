if ( !MOBA ) then
	MOBA = {};
	MOBA.Characters = {};
	MOBA.Spells = {};
end

//Enumerations
ROUND_PREGAME 	= 0;
ROUND_ACTIVE 	= 1;
ROUND_END		= 2;

TEAM_BLUE		= 1;
TEAM_RED		= 2;

ROLE_TANK		= 0;
ROLE_DPS		= 1;
ROLE_HEAL		= 2;

//Teams
team.SetUp( TEAM_BLUE, "Blue guys", Color( 255, 127, 0, 255 ) );
team.SetUp( TEAM_RED, "Red guys", Color( 60, 60, 60, 255 ) );

if ( SERVER ) then
	util.AddNetworkString( "mb_Bot" );
	util.AddNetworkString( "mb_GoPos" );
	util.AddNetworkString( "mb_Attak" );
	util.AddNetworkString( "mb_Char" );
	util.AddNetworkString( "mb_Equip" );
	util.AddNetworkString( "mb_Spell" );
end

local function loadCoreGame( dir )
	
	for k, v in pairs( file.Find( dir .. "/sv_*.lua", "LUA" ) ) do
		 if ( SERVER ) then
			include( "base/" .. v );
		end
	end
	
	for k, v in pairs( file.Find( dir .. "/cl_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "base/" .. v );
		else
			include( "base/" .. v );
		end
	end
	
	for k, v in pairs( file.Find( dir .. "/sh_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "base/" .. v );
		end
		include( "base/" .. v );
	end
	
end

local function loadCharacters( dir )
	
	for k, v in pairs( file.Find( dir .. "/*.lua", "LUA" ) ) do
		CHARACTER = {};
		if ( SERVER ) then 
			AddCSLuaFile( "characters/" .. v ); 
		end
		include( "characters/" .. v );
		
		local class = string.gsub( v, ".lua", "" );
		
		MOBA.Characters[ class ] = CHARACTER;
		
		print( "MOBA -> Character loaded", class );
	end
	CHARACTER = nil;
end

local function loadSpells( dir )
	
	for k, v in pairs( file.Find( dir .. "/*.lua", "LUA" ) ) do
		SPELL = {};
		if ( SERVER ) then 
			AddCSLuaFile( "spells/" .. v ); 
		end
		include( "spells/" .. v );
		
		local class = string.gsub( v, ".lua", "" );
		
		MOBA.Spells[ class ] = SPELL;
		
		SPELL.OnInitalize();
		
		print( "MOBA -> Spell loaded", class );
	end
	SPELL = nil;
end

loadCoreGame( "moba/gamemode/moba/base" );
loadCharacters( "moba/gamemode/moba/characters" );
loadSpells( "moba/gamemode/moba/spells" );