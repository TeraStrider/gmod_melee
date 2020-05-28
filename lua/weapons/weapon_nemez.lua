
AddCSLuaFile()

SWEP.PrintName = "Pulse Machine Gun"
SWEP.Purpose = "Nemez Test"

SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_irifle.mdl" 
SWEP.WorldModel = "models/weapons/w_irifle.mdl" 
SWEP.UseHands = true

SWEP.BobScale = 0
SWEP.SwayScale = 0

SWEP.Primary.ClipSize = 250
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
SWEP.ViewModelFOV = 50
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.AimAngle	=	Angle(0,0,0)
SWEP.AimPos	=	Vector(0, 5, 0)
SWEP.DrawAmmo = true
SWEP.FreeAimRange = 15
SWEP.FreeAimSensivity = 2
SWEP.DrawCrosshair = false
SWEP.ReloadTime = 2.4
SWEP.ShootPos = Vector(5, -3, 0)
SWEP.MouseSensitivity = 1
function SWEP:Initialize()
	self:SetHoldType( "pistol" )
	self:SetFreeAim(Angle())
	self:SetRecoilAngle(Angle())
	self:SetNextReload(CurTime())
	self:SetShotTime( CurTime() )
	self:SetShotCount( 0 )
end

function SWEP:CalcView( ply, pos, ang, fov )
	return pos, ang, fov
end
function SWEP:GetViewModelPosition(pos, ang)
	local freeaim = self:GetFreeAim() + self:GetRecoilAngle()
	freeaim = LerpAngle(self.ViewModelFOV / self.Owner:GetFOV( ),Angle(), freeaim) 
	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis( ang:Up(), freeaim.y)
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	return pos, ang
end

function SWEP:Tick()
	local cmd = self.Owner:GetCurrentCommand()
	if (CurTime() > self:GetShotTime() + 1) then
		self:SetShotCount(0)
	end
	self:SetRecoilAngle(LerpAngle( math.Clamp((CurTime() - self:GetShotTime())* 0.1,0, 1), self:GetRecoilAngle(), Angle() ))
	local x, y = cmd:GetMouseX() * engine.TickInterval() * self.FreeAimSensivity, cmd:GetMouseY() * engine.TickInterval() * self.FreeAimSensivity
	if ( x + y != 0) then
		local freeaim = self:GetFreeAim()
		x = freeaim.y - x
		y = freeaim.p + y
		if (x * x + y * y > self.FreeAimRange * self.FreeAimRange) then
			local ratio = self.FreeAimRange / math.sqrt(x * x + y * y)
			freeaim.p = y * ratio
			freeaim.y = x * ratio
		else
			freeaim.p = y
			freeaim.y = x
		end
		self:SetFreeAim( freeaim )
	end
end

function SWEP:AdjustMouseSensitivity()
	return self.MouseSensitivity
end

function SWEP:Precache()

end

function SWEP:SetupDataTables()
	self:NetworkVar( "Angle", 0, "FreeAim" )
	self:NetworkVar( "Angle", 1, "RecoilAngle" )
	self:NetworkVar( "Float", 0, "NextReload" )
	self:NetworkVar( "Float", 1, "ShotTime" )
	self:NetworkVar( "Int", 0, "ShotCount" )
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
 
end
function SWEP:Reload()
	if (CurTime() < self:GetNextReload()) then return end
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "ir_reload" ))
	self:EmitSound("weapons/ar2/ar2_reload_push.wav")
	self:SetNextReload(CurTime() + vm:SequenceDuration())
	self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
	self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
end

function SWEP:PrimaryAttack()
	self:ShootBullet(15,1,0.0)
	local vm = self.Owner:GetViewModel()
	self:EmitSound("weapons/ar2/fire1.wav")
	local recoilangle = self:GetRecoilAngle()
	local randomangle = Angle(-2, 0, 0)
	math.randomseed( 2048 + self:GetShotCount())
	randomangle:RotateAroundAxis(randomangle:Forward(), math.random(-30, 30 ))
	math.randomseed(CurTime())
	self:SetRecoilAngle(recoilangle + randomangle)
		if IsFirstTimePredicted() then
		self.Owner:ViewPunchReset( 0 )
		//self.Owner:ViewPunch(Angle(0, 0, math.random(-3, 3 ))) 
	end
	self:SetShotCount(self:GetShotCount() + 1) 
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fire3" ))
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self:SetShotTime( CurTime() )
	self:SetNextPrimaryFire(CurTime() + 0.065)

end


function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "ir_draw" ))
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
