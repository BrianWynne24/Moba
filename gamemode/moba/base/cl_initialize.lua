
function GM:Initialize()
	moba = {};
		moba.character = "";
		moba.target	= nil;
		moba.viewoffset = Vector( 0, 0, 0 );
		moba.campos = Vector( 0, 0, 0 );
		moba.camIncriment = FrameTime() * 8;
		moba.camZoom = 400;
		moba.bot = nil;
		moba.waypoint = nil;
		moba.waypointDelay = CurTime();
		moba.spells = {};
		moba.equipment = {};
		
	gui.EnableScreenClicker( true );
end

function GM:HUDPaint()
	local x, y = ScrW() / 2, ScrH() / 2;
	local mx, my = gui.MouseX(), gui.MouseY();
	
	if ( mx > (x * 1.90) ) then
		moba.viewoffset = moba.viewoffset - Vector( 0, moba.camIncriment, 0 );
	elseif ( mx < (x * 0.10) ) then
		moba.viewoffset = moba.viewoffset + Vector( 0, moba.camIncriment, 0 );
	end
	
	if ( my > (y * 1.90) ) then
		moba.viewoffset = moba.viewoffset - Vector( moba.camIncriment, 0, 0 );
	elseif ( my < (y * 0.10) ) then
		moba.viewoffset = moba.viewoffset + Vector( moba.camIncriment, 0, 0 );
	end
	
	for i = 1, 4 do
		local dist = i * 100;
		dist = dist + (x * 0.60);
		draw.RoundedBox( 0, dist, y * 1.79, x * 0.12, y * 0.20, Color( 60, 60, 60, 120 ) );
		
		local txt = MOBA.Characters[ moba.character ].Spells[i] or i;
		local col = Color( 255, 255, 255, 255 );
		
		if ( moba.spells[ i ].cooldown > CurTime() ) then
			col = Color( 60, 60, 60, 255 );
		end
		
		draw.DrawText( txt, "Default", dist + (x * 0.06), y * 1.88, col, TEXT_ALIGN_CENTER );
	end
end

function GM:CalcView( ply, pos, ang, fov )
	local bot = moba.bot;
	if ( !bot ) then return; end
	
	local view = { origin = pos, angles = ang, fov = fov };
	
	view.origin = Vector( 0, 0, moba.camZoom );
	view.angles = Angle( 50, 0, 0 );
	
	view.origin = view.origin + moba.viewoffset;
	moba.campos = view.origin;
	
	return view;
end

//Mouse Movements
function GM:Think()
	if ( CurTime() > moba.waypointDelay ) then
		if ( input.IsMouseDown( MOUSE_RIGHT ) ) then //Moving
			local vector = gui.ScreenToVector( gui.MouseX(), gui.MouseY() ) * 99;
			local tr = util.QuickTrace( moba.campos, moba.campos + (vector * 10000), LocalPlayer() );
			
			net.Start( "mb_GoPos" );
				net.WriteVector( tr.HitPos );
			net.SendToServer();
			
			moba.waypointDelay = CurTime() + 0.4; //Stops them from spamming, also max age of bot path
		elseif ( input.IsMouseDown( MOUSE_LEFT ) ) then //Attacking
			local vector = gui.ScreenToVector( gui.MouseX(), gui.MouseY() ) * 99;
			local tr = util.QuickTrace( moba.campos, moba.campos + (vector * 10000), LocalPlayer() );
	
			if ( tr.Hit && IsValid(tr.Entity) && tr.Entity != moba.bot ) then
				net.Start( "mb_Attak" );
					net.WriteEntity( tr.Entity );
				net.SendToServer();
				
				moba.target = tr.Entity;
			end
			
			moba.waypointDelay = CurTime() + 0.4; //Stops them from spamming, also max age of bot path
		end
	end
	
	if ( input.IsKeyDown( KEY_W ) ) then
		moba.viewoffset = moba.viewoffset + Vector( moba.camIncriment, 0, 0 );
	elseif ( input.IsKeyDown( KEY_S ) ) then
		moba.viewoffset = moba.viewoffset - Vector( moba.camIncriment, 0, 0 );
	end
	
	if ( input.IsKeyDown( KEY_A ) ) then
		moba.viewoffset = moba.viewoffset + Vector( 0, moba.camIncriment, 0 );
	elseif ( input.IsKeyDown( KEY_D ) ) then
		moba.viewoffset = moba.viewoffset - Vector( 0, moba.camIncriment, 0 );
	end
	
	if ( input.IsKeyDown( KEY_PAD_MINUS ) ) then
		if ( moba.camZoom >= 600 ) then return; end
		moba.camZoom = moba.camZoom + moba.camIncriment;
	elseif ( input.IsKeyDown( KEY_PAD_PLUS ) ) then
		if ( moba.camZoom <= 300 ) then return; end
		moba.camZoom = moba.camZoom - moba.camIncriment;
	end
	
	if ( input.IsKeyDown( KEY_1 ) ) then
		RunConsoleCommand( "mb_cast", "manhack" );
		moba.spells[ 1 ].cooldown = CurTime() + MOBA.Spells[ moba.spells[ 1 ].spell ].Cooldown;
	end
end

function GM:PlayerBindPress( ply, bind )
end

local function HideHUD( name )
	local Tbl = { 
	[ "CHudHealth" ] = true, 
	[ "CHudAmmo" ]   = true, 
	[ "CHudAmmoSecondary" ] = true, 
	[ "CHudBattery" ] = true,
	[ "CHudWeaponSelection" ] = true
	}; 
	
	if ( Tbl[ name ] ) then
		return false;
	end
end
hook.Add( "HUDShouldDraw", "HeistHidHUD", HideHUD );

function GM:ShouldDrawLocalPlayer( ply )
	return true;
end