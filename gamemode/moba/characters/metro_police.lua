CHARACTER.Name		= "Metro Police";
CHARACTER.Icon		= "";
CHARACTER.Role		= ROLE_DPS;
CHARACTER.Range		= 64;
CHARACTER.Model		= "models/Police.mdl";
CHARACTER.Speed		= 240;

CHARACTER.Equipment = { 
	["head"] = "",
	["chest"] = "",
	["legs"] = "",
	["feet"] = ""
};

CHARACTER.Spells	= {
	[1] = "manhack",
	[2] = "",
	[3] = "",
	[4] = ""
};

CHARACTER.OnDeath	= function( ply, bot )
end

CHARACTER.OnInitialize 	= function( ply, bot )
end