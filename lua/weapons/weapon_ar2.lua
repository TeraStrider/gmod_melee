
AddCSLuaFile()

SWEP.PrintName = "Pulse Machine Gun"
SWEP.Purpose = "Retart"

SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/v_models/v_cweaponry_pmg.mdl" 
SWEP.UseHands = true

SWEP.Primary.ClipSize = 250
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
SWEP.ViewModelFOV = 68
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ViewModelAngle	=	Angle(180,0,90)
SWEP.ViewModelPos	=	Vector(0, 0, 0)
SWEP.DrawAmmo = true
SWEP.FreeAimRange = 5
SWEP.FreeAimSensivity = 2
SWEP.DrawCrosshair = false
SWEP.ReloadTime = 2.4
SWEP.ShootPos = Vector(3, -7, 0)
function SWEP:Initialize()
	self:SetHoldType( "pistol" )
	self:SetFreeAim(Angle())
	self:SetRecoilAngle(Angle())
	self:SetNextReload(CurTime())
end

function SWEP:CalcView( ply, pos, ang, fov )
	-- self.ViewModelFOV	= fov
	return pos, ang, fov
end
function SWEP:GetViewModelPosition(pos, ang)
	local freeaim = self:GetFreeAim() + self:GetRecoilAngle()
	local ang = self.Owner:EyeAngles()
	local prop  = self.Owner:GetFOV( ) / self.ViewModelFOV
	ang:RotateAroundAxis( ang:Up(), freeaim.y)
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	return pos, ang
end

function SWEP:Tick()
	local cmd = self.Owner:GetCurrentCommand()
	self:SetRecoilAngle(LerpAngle( engine.TickInterval() * 1, self:GetRecoilAngle(), Angle() ))
	local x, y = cmd:GetMouseX() * engine.TickInterval() * self.FreeAimSensivity, cmd:GetMouseY() * engine.TickInterval() * self.FreeAimSensivity
	if ( x != 0 or y != 0) then
		local freeaim = self:GetFreeAim()
		freeaim:Normalize()
		freeaim.p = math.Clamp(freeaim.p + y, -self.FreeAimRange, self.FreeAimRange)
		freeaim.y = math.Clamp(freeaim.y - x, -self.FreeAimRange, self.FreeAimRange)
		self:SetFreeAim( freeaim  )
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Angle", 0, "FreeAim" )
	self:NetworkVar( "Angle", 1, "RecoilAngle" )
	self:NetworkVar( "Float", 0, "NextReload" )
end

	
function SWEP:ShootBullet( damage, num_bullets, aimcone )
 	local freeaim = self:GetFreeAim() + self:GetRecoilAngle()
 	local ang = self.Owner:EyeAngles()
 	local pos = self.Owner:GetShootPos()
 	ang:RotateAroundAxis( ang:Up(), freeaim.y )
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	pos = pos + ang:Right() * self.ShootPos.x + ang:Up() * self.ShootPos.y + ang:Forward() * self.ShootPos.z
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= pos	// Source
	bullet.Dir 		= ang:Forward()// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 1	// Show a tracer on every x bullets 
    bullet.TracerName = "AR2Tracer" // what Tracer Effect should be used
	bullet.Force	= damage	// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.DamageType	= DMG_BLAST
	bullet.AmmoType = "ar2"
 	
	self.Owner:FireBullets( bullet )
 	self:TakePrimaryAmmo( 1 )
	-- self:ShootEffects()
 
end
function SWEP:Reload()
	if (CurTime() < self:GetNextReload()) then return end
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "reload" ))
	self:EmitSound("Cweaponry_PUMP1")
	self:SetNextReload(CurTime() + vm:SequenceDuration())
	self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
	self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
end

function SWEP:PrimaryAttack()
	self:ShootBullet(35,1,0)
	local vm = self.Owner:GetViewModel()
	self:EmitSound("PSR_FIRE")
	local recoilangle = AngleRand(-1,1)
	print(recoilangle)
	-- recoilangle.p = math.Clamp(recoilangle.p, -5, 5)
	-- recoilangle.y = math.Clamp(recoilangle.y, -5, 5)
	self:SetRecoilAngle(self:GetRecoilAngle() + recoilangle)
	if IsFirstTimePredicted() then
		self.Owner:ViewPunchReset( 0 )
		self.Owner:ViewPunch(recoilangle)
	end
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fire"..math.random(1,3).."" ))
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire(CurTime() + 0.065)

end


function SWEP:SecondaryAttack()

	local ent = ents.Create( "prop_combine_ball" )
	if ( !IsValid( ent ) ) then return end
	local freeaim = self:GetFreeAim() + self:GetRecoilAngle()
 	local ang = self.Owner:EyeAngles()
 	ang:RotateAroundAxis( ang:Up(), freeaim.y )
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	pos = self.Owner:GetShootPos()
	pos = pos + ang:Right() * self.ShootPos.x + ang:Up() * self.ShootPos.y + ang:Forward() * self.ShootPos.z
	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:SetOwner(self.Owner)
	ent:Spawn()
	ent:SetSaveValue("m_flRadius", GetConVar( "sk_weapon_ar2_alt_fire_radius" ):GetFloat())
	ent:SetSaveValue("m_nState",3)
	ent:SetSaveValue("m_nMaxBounces", GetConVar( "sk_weapon_ar2_alt_fire_duration" ):GetInt())
	local phys = ent:GetPhysicsObject()
	phys:SetVelocity(ang:Forward() * 1000)
	local recoilangle = AngleRand(-5,5)
	-- recoilangle.p = math.Clamp(recoilangle.p, -5, 5)
	-- recoilangle.y = math.Clamp(recoilangle.y, -5, 5)
	self:SetRecoilAngle(self:GetRecoilAngle() + recoilangle)
	if IsFirstTimePredicted() then
		self.Owner:ViewPunchReset( 0 )
		self.Owner:ViewPunch(recoilangle) 
	end
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fire3" ))
	self:EmitSound("ALT_FIRE2")
	self:SetNextSecondaryFire(CurTime() + 0.1) 
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ))
	return true

end
function SWEP:DoImpactEffect( tr, nDamageType )
	-- if (!IsFirstTimePredicted()) then return end
	if ( tr.HitSky ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "AR2Impact", effectdata )
	
end
