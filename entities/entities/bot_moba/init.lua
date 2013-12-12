ENT.Base 		= "base_nextbot";

ENT.HP     		 = 100;
ENT.Model		= "models/Police.mdl";
ENT.Speed       = 160;
ENT.Damage      = 2;
ENT.ScaleSize	= 1;

MODE_IDLE		= 0;
MODE_GOTO		= 1;
MODE_CHASE		= 2;
MODE_ATTACK		= 3;

function ENT:SetSpeed( speed )
	self.loco:SetDesiredSpeed( speed );
	self.nSpeed = speed;
end

function ENT:SetMode( enum )
	if ( self.nMode == enum ) then return; end
	self.nMode = enum;
end

function ENT:Mode()
	return self.nMode;
end

function ENT:Initialize()
	self.moba = {};
		self.moba.waypoint	= nil;
		self.moba.pet		= nil;
		
	self:SetModel( self.Model );
	self:SetHealth( self.HP );
	
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	
	self:SetSpeed( self.Speed );
	self:SetMode( MODE_IDLE );
	
	local owner = self:GetOwner();
	if ( IsValid(owner) ) then
		owner:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	end
	
	if ( self.ScaleSize && self.ScaleSize != 1 ) then
		self:SetModelScale( self.ScaleSize, 0 );
	end
end

function ENT:GetEnemy()
	return self.enemy;
end

function ENT:SetEnemy( ent )
	self.enemy = ent;
end

function ENT:RunBehaviour()
	while (true) do
		if ( self:Mode() == MODE_IDLE ) then
			self:StartActivity( ACT_IDLE );
		elseif ( self:Mode() == MODE_GOTO ) then
			self:MoveWaypoint( self.moba.waypoint );
		elseif ( self:Mode() == MODE_CHASE ) then
			self:ChaseTarget();
		elseif ( self:Mode() == MODE_ATTACK ) then
			self:Attack();
		end
		coroutine.yield();
	end
end

function ENT:BehaveUpdate( fInterval )
	if ( !self.BehaveThread ) then return end
	
	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then

		self.BehaveThread = nil
		Msg( self, "error: ", message, "\n" );
	end
end

function ENT:SetWaypoint( pos )
	//if ( self.moba.waypoint == pos ) then return; end
	self.moba.waypoint = pos;
	
	if ( (self:Mode() == MODE_CHASE || self:Mode() == MODE_ATTACK) && self.path ) then
		self.path:Invalidate();
		self.path = nil;
	end
	
	self:SetMode( MODE_GOTO );
	
	local pet = self.moba.pet;
	if ( IsValid(pet) ) then
		self:SetEnemy( nil );
		pet:SetEnemy( nil );
	end
end

function ENT:MoveWaypoint( pos )
	if ( !pos || pos:Distance( self:GetPos() ) <= 24 ) then 
		self:SetMode( MODE_IDLE );
		return; 
	end
	
	local opts = { draw = true, maxage = 0.4 };
	self:MoveToPos( pos, opts );
	self:StartActivity( ACT_RUN );
	
	if ( pos:Distance( self:GetPos() ) <= 24 && self:Mode() == MODE_GOTO ) then
		self:SetMode( MODE_IDLE );
	end
end

function ENT:AttackTarget( target )
	if ( target == self ) then return; end
	
	local dist = self:GetPos():Distance( target:GetPos() );
	local char = self:GetOwner():GetCharacterDetails();
	
	self:SetEnemy( target );
	
	if ( IsValid(self.moba.pet) ) then
		local pet = self.moba.pet;
		pet:SetEnemy( target );
		pet:SetMode( MODE_ATTACK );
	end
	
	if ( dist >= char.Range ) then
		self:SetMode( MODE_CHASE );
	else
		self:SetMode( MODE_ATTACK );
	end
end

function ENT:Think()
end

function ENT:ChaseTarget()
	self.path = Path("Chase");
    self.path:SetMinLookAheadDistance(200);
    self.path:SetGoalTolerance(0);
	
	self:StartActivity( ACT_RUN );
	
	while ( self.path ) do
		local enemypos = self:GetEnemy():GetPos();
		local char = self:GetOwner():GetCharacterDetails();
		
		if ( !IsValid( self:GetEnemy() ) ) then
			self:SetMode( MODE_IDLE );
			self.path:Invalidate();
			//self.path = nil;
		else
			if ( self:GetPos():Distance( enemypos ) <= char.Range ) then
				self:SetMode( MODE_ATTACK );
				self:Attack();
				//self.path = nil;
			end
		end
		
		if ( self.path ) then
			self.path:Compute(self, self:GetEnemy():GetPos());
			self.path:Chase(self, self:GetEnemy());
		end
		coroutine.yield();
	end
	
    if self.loco:IsStuck() then
        self:HandleStuck();
        return "stuck";
    end
end

function ENT:Attack()
	print( "Attacking" );
	if ( self.path ) then
		self.path:Invalidate();
		self.path = nil;
	end
	
	self:SetMode( MODE_IDLE );
end

function ENT:DamageEnemy( pl, dmg )
end

function ENT:HasValidEnemy()
	if ( IsValid(self:GetEnemy()) && self:GetEnemy():IsPlayer() && self:GetEnemy():Alive() ) then
		return true;
	end
	//self:SetEnemy( nil );
	return false;
end

//Hooks
function ENT:OnInjured( dmginfo )
	local damage = dmginfo:GetBaseDamage();
	
	self:SetHealth( self:Health() - damage );
	if ( self:Health() <= 0 ) then
		self:Remove();
	end
end

function ENT:OnKilled( dmginfo )
end

function ENT:OnOtherKilled( dmginfo )
end

function ENT:SetFire( bool )
end