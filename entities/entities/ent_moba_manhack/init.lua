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
		self.moba.mode	= 0;
		
	self:SetModel( "models/manhack.mdl" );
	
	self:SetMode( MODE_FOLLOW );
	self:SetMoveType( MOVETYPE_FLY );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON );
	self:SetSolid( SOLID_NONE );
	self:Activate();
	
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
	
	print( self:Mode() );
	
	if ( self:Mode() == MODE_FOLLOW ) then
		self:FollowBot();
	elseif ( self:Mode() == MODE_ATTACK ) then
		self:AttackEnemy();
	elseif ( self:Mode() == MODE_RETREAT ) then
	end
	
	self:SetAngles( Angle( 0, 0, 0 ) );
end

function ENT:OnRemove()
	local owner = self:GetOwner();
	if ( !owner ) then return; end
	
	owner.moba.pet = nil;
end

function ENT:FollowBot()
	local owner = self:GetOwner();
	local pos = self:GetPos();
	local offset = owner:GetPos() + Vector( 0, 0, 90 );

	local phys = self:GetPhysicsObject();
	local dir = (pos - offset) * -1;
	local dist = pos:Distance( owner:GetPos() );
	
	dist = math.Clamp( dist, 0, 82 );
	
	phys:ApplyForceCenter( dir * (dist/12) );
end

function ENT:AttackEnemy()
	if ( !self:Enemy() ) then
		print( "Invalid" );
		self:SetMode( MODE_FOLLOW );
		return;
	end
	
	local owner = self:GetOwner();
	local pos = self:GetPos();
	local offset = self:Enemy():GetPos() + Vector( 0, 0, 60 );
	
	local phys = self:GetPhysicsObject();
	if ( !IsValid(phys) ) then return; end

	local dir = (pos - offset) * -1;
	phys:ApplyForceCenter( dir * 2 );
	
	if ( pos:Distance( offset ) <= 30 ) then
		self:SetMode( MODE_FOLLOW );
	end
end

function ENT:PhysicsCollide()
end

function ENT:Enemy()
	if ( !IsValid( self.moba.enemy ) ) then
		local owner = self:GetOwner();
		return owner:GetEnemy();
	end
	return self.moba.enemy;
end

function ENT:SetEnemy( target )
	self.moba.enemy = target;
end

function ENT:SetMode( mode )
	self.moba.mode = mode;
end

function ENT:Mode()
	return self.moba.mode;
end