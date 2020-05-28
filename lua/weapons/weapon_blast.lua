
AddCSLuaFile()

SWEP.PrintName = "Shotgan"
SWEP.Purpose = "Nemez Test"

SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_shotgun.mdl" 
SWEP.WorldModel = "models/weapons/w_shotgun.mdl" 
SWEP.UseHands = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "shotgun"
SWEP.ViewModelFOV = 50
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.AimAngle	=	Angle(0,0,0)
SWEP.AimPos	=	Vector(0, 5, 0)
SWEP.DrawAmmo = true
SWEP.FreeAimRange = 10
SWEP.FreeAimSensivity = 2
SWEP.DrawCrosshair = false
SWEP.ReloadTime = 2.4
SWEP.ShootPos = Vector(6, -3, 0)
SWEP.MouseSensitivity = 1
SWEP.Cocked = true
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
	self:SetRecoilAngle(LerpAngle( math.Clamp(CurTime() - self:GetShotTime() ,0, 1), self:GetRecoilAngle(), Angle() ))
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

function SWEP:SetupDataTables()
	self:NetworkVar( "Angle", 0, "FreeAim" )
	self:NetworkVar( "Angle", 1, "RecoilAngle" )
	self:NetworkVar( "Float", 0, "NextReload" )
	self:NetworkVar( "Float", 1, "ShotTime" )
	self:NetworkVar( "Int", 0, "ShotCount" )
end

function SWEP:ShootBullet( damage, num_bullets, aimcone )
 	local freeaim = self:GetFreeAim() +self:GetRecoilAngle()
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
	bullet.Tracer	= 3	// Show a tracer on every x bullets 
    bullet.TracerName = "tracer" // what Tracer Effect should be used
	bullet.Force	= damage	// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.DamageType	= DMG_BLAST
	bullet.AmmoType = "ar2"
 	
	self.Owner:FireBullets( bullet )
 	self:TakePrimaryAmmo( 1 )
 
end
function SWEP:Reload()
	if (CurTime() < self:GetNextReload()) then return end
	self.Cocked = true
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "pump" ))
	self:EmitSound("Weapon_Shotgun.Special1")
	self:SetNextReload(CurTime() + 0.2)
	self:SetNextPrimaryFire(CurTime() + 0.3)
end

function SWEP:PrimaryAttack()
	local vm = self.Owner:GetViewModel()
	if (self.Cocked) then
		self.Cocked = false
		self:ShootBullet(8,12,0.05)
		self:EmitSound("Weapon_Shotgun.Single")
		local recoilangle = self:GetRecoilAngle()
		local randomangle = Angle(-10, 0, 0)
		math.randomseed( 1024 + self:GetShotCount())
		randomangle:RotateAroundAxis(randomangle:Forward(), math.random(-45, 45 ))
		math.randomseed(CurTime())
		self:SetRecoilAngle(recoilangle + randomangle)
			if IsFirstTimePredicted() then
			self.Owner:ViewPunchReset( 0 )
			self.Owner:ViewPunch(Angle(math.random(-5, -4 ), math.random(-2, 2 ), math.random(-2, 2 ))) 
		end
		self:SetShotCount(self:GetShotCount() + 1) 
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fire01" ))
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self:SetShotTime( CurTime() )
		self:SetNextPrimaryFire(CurTime() + 0.1)
		self:SetNextReload(CurTime() + 0.3)
	else
		self:Reload()
	end

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
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "draw" ))
	return true

end
