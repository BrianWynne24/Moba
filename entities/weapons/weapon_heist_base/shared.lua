
PRIMARY_SLOT		= 0;
SECONDARY_SLOT		= 1;

SWEP.Author			= "Brian Wynne & George Butler";
SWEP.PrintName		= "Sub Machine Gun";

SWEP.ViewModelFOV	= 60;
SWEP.ViewModelFlip	= false;
SWEP.ViewModel		= "models/weapons/v_smg1.mdl";
SWEP.WorldModel		= "models/weapons/w_smg1.mdl";
SWEP.HoldType		= "smg";

SWEP.WeaponSlot		= PRIMARY_SLOT;

SWEP.Primary.Damage			= 10;
SWEP.Primary.ClipSize		= 30;
SWEP.Primary.DefaultClip	= 30;
SWEP.Primary.Automatic		= true;
SWEP.Primary.Ammo			= "smg1";
SWEP.Primary.Sound			= Sound( "Weapon_SMG1.Single" );

function SWEP:Initialize()
	self:SetDeploySpeed( 1.0 );
	self:SetWeaponHoldType( self.HoldType );
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW );
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return; end
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self:EmitSound( self.Primary.Sound );
	self:MuzzleFlash();
	
	self:ShootBullet();
	
	self:SetNextPrimaryFire( CurTime() + 0.085 );
end

function SWEP:ShootBullet( pl )
	local spread = 0.02;
	local recoil = 0.3;
	
	local bullet = {};
		bullet.Num 		  = self.NumShots;
		bullet.Src 		  = self.Owner:GetShootPos();
		bullet.Dir 		  = self.Owner:GetAimVector();
		bullet.Spread 	  = Vector(spread, spread, 0);
		bullet.Tracer	  = 1;
		bullet.TracerName = TracerName;
		bullet.Force	  = self.Primary.Damage * 0.5;
		bullet.Damage	  = self.Primary.Damage;
		bullet.AmmoType   = self.Primary.Ammo;
	
	recoil = Angle( math.Rand(-recoil, 0), math.Rand(-recoil, recoil), math.Rand(-0.2, 0.2) );
	
	self.Owner:ViewPunchReset( 1 );
	self.Owner:ViewPunch( recoil );
	self.Owner:FireBullets( bullet );
	self:TakePrimaryAmmo( 1 );
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD );
	self.Owner:SetAnimation( PLAYER_RELOAD );
end