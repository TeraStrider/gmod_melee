
AddCSLuaFile()

SWEP.PrintName = "#Weapon_gta_sa"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.RestoreTimeHit = 0.4
SWEP.RestoreTimeMiss = 0.8
SWEP.ChargeTime = 0.2
SWEP.ViewModel = "models/weapons/v_shot_m3super90.mdl" 
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = 3
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.Damage 		= 100
SWEP.DamageType 		= DMG_BULLET

SWEP.SwayScale					= 0					-- The scale of the viewmodel sway
SWEP.BobScale					= 0	
local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.BulletImpact" )

function SWEP:Initialize()
	self:SetHoldType( "melee" )
end


function SWEP:GetViewModelPosition( pos, ang )
end

local max_spread = 0.05
local cur_spread = 0

function SWEP:PrimaryAttack(right)
	self:EmitSound("tec9/fire.wav")
	self:ShootBullet(self.damage, 1, cur_spread) 
	cur_spread = math.min(max_spread, cur_spread + 0.02) 
	self:SetNextPrimaryFire( CurTime() + 0.12)
end


function SWEP:ShootBullet( damage, num_bullets, aimcone)
	
	local bullet = {}
	local dir = self.Owner:GetAimVector()
	dir = dir + self.Owner:EyeAngles():Up() * math.sin(CurTime() * 6) * -aimcone
	dir = dir + self.Owner:EyeAngles():Right() * math.cos(CurTime() * 6) * aimcone
	bullet.Num 	= num_bullets
	bullet.Src 	= self.Owner:GetShootPos() -- Source
	bullet.Dir 	= dir -- Dir of bullet
	bullet.Spread 	= 0
	bullet.Tracer	= 5 -- Show a tracer on every x bullets
	bullet.Force	= damage -- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"

	self.Owner:FireBullets( bullet )

end
function SWEP:SecondaryAttack(right)
	cur_spread = 0;
end
function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end

function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )
	self:SetNextPrimaryFire( CurTime() + 1 / speed )
	self:SetNextSecondaryFire( CurTime() + 1 / speed )

	return true

end