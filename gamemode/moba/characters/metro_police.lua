CHARACTER.Name			= "Metro Police";
CHARACTER.Icon			= "";
CHARACTER.Role			= ROLE_DPS;
CHARACTER.Range			= 48;
CHARACTER.Model			= "models/Police.mdl";
CHARACTER.Weapon		= "weapon_stunstick";

CHARACTER.AttackAnim	= "swing";
CHARACTER.AttackTime	= 0.6;
CHARACTER.AttackDmg		= 3;

CHARACTER.Speed			= 180;

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

CHARACTER.OnAttack	= function( ply, bot, enemy )
end