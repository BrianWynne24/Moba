AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

MODE_FOLLOW = 0;
MODE_ATTACK = 1;
MODE_RETREAT = 2;

function ENT:Initialize()
	self.moba = {};
		self.moba.lifetime = CurTime() + 30;
		self.moba.enemy   = nil;
		self.moba.nextattack = CurTime() + 1;
		self.moba.sequence = "";
		self.moba.mode	= 0;
		
	self:SetModel( "models/manhack.mdl" );
	
	self:SetMode( MODE_FOLLOW );
	self:SetMoveType( MOVETYPE_FLY );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	self:SetSolid( SOLID_NONE );
	self:Activate();
	//self:SetModelScale( 0.95, 0 );
	
	self:PlaySequence( "Deploy" );
	
	local phys = self:GetPhysicsObject();
	if ( IsValid(phys) ) then
		phys:EnableGravity( false );
		phys:Wake();
	end
end

function ENT:Think()
	if ( !IsValid( self:GetOwner() ) || CurTime() > self.moba.lifetime ) then
		self:Remove();
		return;
	end
	
	if ( self:Mode() == MODE_FOLLOW ) then
		self:FollowBot();
	elseif ( self:Mode() == MODE_ATTACK ) then
		if ( CurTime() > self.moba.nextattack ) then
			self:AttackEnemy();
		else
			self:FollowBot();
		end
	end
	
	local ang = Angle( 0, 0, 0 );
	local enemy = self:Enemy();
	local owner = self:GetOwner();
	if ( enemy ) then
		ang = (self:GetPos() - enemy:GetPos()):Angle();
		ang = Angle( 0, ang.y, 0 );
	else
		ang = owner:GetAngles();
	end
	self:SetAngles( ang );
end

function ENT:OnRemove()
	local owner = self:GetOwner();
	if ( !owner ) then return; end
	
	self:EmitSound( "npc/manhack/gib.wav" );
	owner.moba.pet = nil;
end

function ENT:FollowBot()
	self:PlaySequence( "idle" );
	
	local owner = self:GetOwner();
	local pos = self:GetPos();
	local offset = owner:GetPos() + (owner:GetRight() * -10) + (owner:GetForward() * -12) + Vector( 0, 0, 70 );

	local phys = self:GetPhysicsObject();
	local dir = (pos - offset) * -1;
	local dist = pos:Distance( owner:GetPos() );
	
	dist = math.Clamp( dist, 0, 82 );
	
	phys:ApplyForceCenter( dir * (dist/12) );
end

function ENT:AttackEnemy()
	if ( !self:Enemy() ) then
		self:SetMode( MODE_FOLLOW );
		return;
	end
	
	local owner = self:GetOwner();
	local pos = self:GetPos();
	local offset = self:Enemy():GetPos() + Vector( 0, 0, 60 );
	
	if ( pos:Distance( offset ) >= 400 ) then
		//self:SetMode( MODE_FOLLOW );
		self:FollowBot();
		return;
	end
	
	self:PlaySequence( "fly" );
	
	local phys = self:GetPhysicsObject();
	if ( !IsValid(phys) ) then return; end

	local dir = (pos - offset) * -1;
	local dist = pos:Distance( offset );
	
	if ( dist < 200 ) then
		dir = dir * 2;
	elseif ( dist > 400 ) then
		dir = dir * 0.8;
	end
	
	phys:ApplyForceCenter( dir * 4 );
	
	if ( pos:Distance( offset ) <= 30 ) then
		//do damage to enemy here
		self:EmitSound( "npc/manhack/grind1.wav" );
		
		/*local enemy = self:Enemy();
		enemy:SetHealth( enemy:Health() - 5 );
		if ( enemy:Health() <= 0 ) then
			enemy:Remove();
			owner:SetEnemy( nil );
		end*/
		
		self.moba.nextattack = CurTime() + 1.2;
		//self:SetMode( MODE_FOLLOW );
	end
end

function ENT:PhysicsCollide()
end

function ENT:Enemy()
	if ( !IsValid( self.moba.enemy ) ) then
		local owner = self:GetOwner();
		return owner:GetEnemy();
	end
	return nil;
end

function ENT:SetMode( mode )
	self.moba.mode = mode;
end

function ENT:Mode()
	return self.moba.mode;
end

function ENT:PlaySequence( seq )
	//if ( self.moba.sequence ) then return; end
	self:ResetSequence( self:LookupSequence( seq ) );
	self:SetPlaybackRate( 1.0 );
	self:SetCycle( 0 );
end