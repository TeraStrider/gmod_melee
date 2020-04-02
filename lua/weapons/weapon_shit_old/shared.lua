AddCSLuaFile()

SWEP.Category				= "HL2 Melee"
SWEP.PrintName		= "This Is Cancer Pld"		-- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.UseHands 		= true
SWEP.BobScale		= 0
SWEP.SwayScale		= 0
SWEP.ViewModelFlip	= false
SWEP.DrawCrosshair	= false
SWEP.ViewModel		= "models/weapons/c_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.Primary.ClipSize		= 8					-- Size of a clip
SWEP.Primary.DefaultClip	= 32				-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true			-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"
SWEP.Secondary.ClipSize		= 8					-- Size of a clip
SWEP.Secondary.DefaultClip	= 32				-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "Pistol"
SWEP.CrosshairColor = Color( 255, 0, 0, 255 )
SWEP.SightsPos = Vector(1,-6.4,0)
SWEP.SightsAng = Angle(0,0,0)

if CLIENT then
local OldOffsetAim = Angle(0,0,0)
function SWEP:GetViewModelPosition( pos, ang )
	local sightspos = self:GetCurSightsPos()
	local jigglepos = self:GetCurOffsetJiggle()
	print(OldOffsetAim)
	ang = self.Owner:GetAimVector():Angle() + self:GetCurOffsetAim()
	pos = pos + ang:Right() * (jigglepos.y + sightspos.y) + ang:Up() * (jigglepos.p + sightspos.x) + ang:Forward() * jigglepos.r
	return pos, ang
end
end

function SWEP:Initialize()
	self:SetHoldType( "pistol" )
	CreateConVar( "sk_freeaim_radius", "5" ,268443648, "set freeaim limits" )
	CreateConVar( "sk_freeaim_speed", "0.5" ,268443648, "set freeaim speed" )
end
function SWEP:SetupDataTables()
--[[ 	self:NetworkVar( "Float", 0, "CurOffsetUp" )
	self:NetworkVar( "Float", 1, "CurOffsetRight" )
	self:NetworkVar( "Float", 2, "CurOffsetForward" )
	self:NetworkVar( "Float", 3, "CurOffsetForwardTarget" )
	self:NetworkVar( "Float", 4, "CurOffsetRightTarget" )
	self:NetworkVar( "Float", 5, "CurOffsetUpTarget" )
	self:NetworkVar( "Angle", 0, "CurOffsetAimTarget" )	
	self:NetworkVar( "Angle", 1, "CurOffsetAim" )	
	self:NetworkVar( "Float", 6, "CurOffsetJiggle" ) ]]
	//self:NetworkVar( "Float", 4, "SinFunc" )	
	self:NetworkVar( "Angle", 0, "CurOffsetAimOld" )
	self:NetworkVar( "Angle", 1, "CurOffsetAim" )
	self:NetworkVar( "Angle", 2, "CurOffsetRecoil" )
	self:NetworkVar( "Angle", 3, "CurOffsetJiggleOld" )
	self:NetworkVar( "Angle", 4, "CurOffsetJiggle" )
	self:NetworkVar( "Angle", 5, "CurOffsetJiggleTarget" )
	self:NetworkVar( "Vector", 0, "CurSightsPos" )
	self:NetworkVar( "Angle", 6, "CurSightsAng" )
	self:NetworkVar( "Float", 6, "CurRadius" )
end
function SWEP:PostDrawViewModel( vm, weapon, ply )
end
function SWEP:DrawWorldModel()
end
function SWEP:PrimaryAttack()
//self:SetCurOffsetForwardTarget(25)
self:SetCurOffsetRecoil(Angle(math.Rand(-0.4,0),math.Rand(-0.2,0.2),0))
if (self.Owner:KeyDown(IN_ATTACK2)) then
self:SetCurOffsetJiggleTarget(Angle(math.Rand(0,0),math.Rand(0,0),math.Rand(-5,-6)))
else
self:SetCurOffsetJiggleTarget(Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-5,-6)))
end
self.Owner:EmitSound( "Weapon_SMG1.Single",75,100 ) 
self:ShootBullet(20,1,0.02)
self:SetNextPrimaryFire(CurTime() + 0.07)
end

function SWEP:SecondaryAttack()
	return
end

function SWEP:Think()
	local radius = GetConVarNumber( "sk_freeaim_radius" )
	local speed = GetConVarNumber( "sk_freeaim_speed" )
	local target = Angle(0,0,0)
	self:SetCurOffsetRecoil(LerpAngle( FrameTime()*25, self:GetCurOffsetRecoil(),Angle(0,0,0)))	
	if (self.Owner:KeyDown(IN_ATTACK2)) then
		self:SetCurSightsPos(LerpVector(FrameTime()*12,self:GetCurSightsPos(),self.SightsPos))
		self:SetCurRadius(Lerp(FrameTime()*12,self:GetCurRadius(),math.min(0.2,radius)))
		radius = self:GetCurRadius()
	else
		self:SetCurRadius(radius)
		self:SetCurSightsPos(LerpVector(FrameTime()*4,self:GetCurSightsPos(),Vector(0,0,0)))
	end
	self:SetCurOffsetJiggleOld(LerpAngle(FrameTime()*25,self:GetCurOffsetJiggleOld(),self:GetCurOffsetJiggleTarget()))
	self:SetCurOffsetJiggle(LerpAngle(FrameTime()*25,self:GetCurOffsetJiggle(),self:GetCurOffsetJiggleOld()))
	self:SetCurOffsetJiggleTarget(LerpAngle(FrameTime()*10,self:GetCurOffsetJiggleTarget(),angle_zero))
	
	self.Owner:SetEyeAngles(self.Owner:GetAimVector():Angle() + self:GetCurOffsetRecoil())
	if SERVER then
	if ((math.abs(self.Owner:GetAimVector():Angle().y - self:GetCurOffsetAimOld().y) > 180) || (math.abs(self.Owner:GetAimVector():Angle().p - self:GetCurOffsetAimOld().p) > 180)) then
		if (math.abs(self.Owner:GetAimVector():Angle().y - self:GetCurOffsetAimOld().y) > 180) then
			if (self:GetCurOffsetAimOld().y < self.Owner:GetAimVector():Angle().y) then
				target = target + Angle(0,self.Owner:GetAimVector():Angle().y - 360 - self:GetCurOffsetAimOld().y,0)
			else
				target = target + Angle(0,360 + self.Owner:GetAimVector():Angle().y - self:GetCurOffsetAimOld().y,0)
			end
		else
			if (self:GetCurOffsetAimOld().p < self.Owner:GetAimVector():Angle().p) then
				target = target + Angle(self.Owner:GetAimVector():Angle().p - 360 - self:GetCurOffsetAimOld().p,0,0)
			else
				target = target + Angle(360 + self.Owner:GetAimVector():Angle().p - self:GetCurOffsetAimOld().p,0,0)
			end
		end
		target = self:GetCurOffsetAim() + target*speed
	else
		target = Angle(0,0,0)
		target = self:GetCurOffsetAim() + self.Owner:GetAimVector():Angle()*speed - self:GetCurOffsetAimOld()*speed
	end
	if math.pow(target.y,2) + math.pow(target.p,2) <= math.pow(radius,2) then
		self:SetCurOffsetAim(target) 
	else
		local ip = math.sqrt(target.y*target.y + target.p*target.p)
		local sin = target.y / ip
		if target.p >= 0 then
			self:SetCurOffsetAim(Angle(radius*math.sqrt(1-sin*sin),sin*radius,0)) 
		else
			self:SetCurOffsetAim(Angle((-1)*radius*math.sqrt(1-sin*sin),sin*radius,0)) 
		end
	end
	self:SetCurOffsetAimOld(self.Owner:GetAimVector():Angle())
	end
	return false
end

function SWEP:DrawHUD()
	local radius = GetConVarNumber( "sk_freeaim_radius" )
	if (self.Owner:KeyDown(IN_ATTACK2)) then
		radius = self:GetCurRadius()
	end
	if GetConVarNumber( "developer" ) >= 1 then
		
		surface.DrawCircle( ScrW() / 2, ScrH() / 2, (radius+radius)*7.7, self.CrosshairColor )
		surface.DrawCircle( ScrW() / 2 -  self:GetCurOffsetAim().y*15.4, ScrH()/2 + self:GetCurOffsetAim().p*15.4, 1, self.CrosshairColor )
		surface.DrawCircle( ScrW() / 2 +  (360 - self:GetCurOffsetAim().y)*15.4, ScrH()/2 + self:GetCurOffsetAim().p*15.4, 1, self.CrosshairColor )	
		surface.DrawCircle( ScrW() / 2 -  self:GetCurOffsetAim().y*15.4, ScrH()/2 - (360 - self:GetCurOffsetAim().p)*15.4, 1, self.CrosshairColor )
		surface.DrawCircle( ScrW() / 2 +  (360 - self:GetCurOffsetAim().y)*15.4, ScrH()/2 - (360 - self:GetCurOffsetAim().p)*15.4, 1, self.CrosshairColor )
	end
end

function SWEP:Reload()
end
function SWEP:Holster( wep )
	return true
end
function SWEP:Deploy()
	return true
end
function SWEP:ShootEffects()
	self.Owner:MuzzleFlash()								-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				-- 3rd Person Animation
end
function SWEP:ShootBullet( damage, num_bullets, aimcone )	
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:EyePos()// + self.Owner:GetAimVector():Angle():Right()*(self:GetCurOffsetAim().y - 300)/-30 + self.Owner:GetAimVector():Angle():Up()*(self:GetCurOffsetAim().p + 150)/-30-- Source
	bullet.Dir 		= self.Owner:GetAimVector() + self.Owner:GetAimVector():Angle():Up()*(self:GetCurOffsetAim().p/-33) + self.Owner:GetAimVector():Angle():Right()*(self:GetCurOffsetAim().y/-33)	-- Dir of bullet
	//bullet.Dir 		= self.Owner:GetAimVector()	-- Dir of bullet
	bullet.Spread 	= Vector( 0, 0, 0 )
	bullet.Tracer	= 1
	bullet.Force	= damage
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(a, b, c)
		c:SetDamageType(DMG_BULLET,DMG_AIRBOAT)
	end
	self.Owner:FireBullets( bullet )	
	self:ShootEffects()	
end
function SWEP:TakePrimaryAmmo( num )
	if ( self.Weapon:Clip1() <= 0 ) then 
		if ( self:Ammo1() <= 0 ) then return end
		self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
	return end
	self.Weapon:SetClip1( self.Weapon:Clip1() - num )	
end
function SWEP:TakeSecondaryAmmo( num )
	if ( self.Weapon:Clip2() <= 0 ) then
		if ( self:Ammo2() <= 0 ) then return end
		self.Owner:RemoveAmmo( num, self.Weapon:GetSecondaryAmmoType() )
	return end
	self.Weapon:SetClip2( self.Weapon:Clip2() - num )	
end
function SWEP:CanPrimaryAttack()
	if ( self.Weapon:Clip1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:Reload()
		return false	
	end
	return true
end
function SWEP:CanSecondaryAttack()
	if ( self.Weapon:Clip2() <= 0 ) then	
		self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 )
		return false		
	end
	return true
end
function SWEP:OnRemove()
self:Remove()
end
function SWEP:OwnerChanged()
end
function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() )
end
function SWEP:Ammo2()
	return self.Owner:GetAmmoCount( self.Weapon:GetSecondaryAmmoType() )
end
function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end
function SWEP:DoImpactEffect( tr, nDamageType )
if CLIENT then
--[[ 	if ( tr.HitSky ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "cball_bounce", effectdata ) ]]
	return false
end
end