
AddCSLuaFile()

SWEP.PrintName = "#Sward"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/v_models/v_cweaponry_pmg.mdl" 
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ViewModelAngle	=	Angle(180,0,90)
SWEP.ViewModelPos	=	Vector(0, 0, 0)
SWEP.DrawAmmo = false
SWEP.FreeAimRange = 10
SWEP.FreeAimSensivity = 0.15
SWEP.DrawCrosshair = true

function SWEP:Initialize()
	self:SetHoldType( "pistol" )
	self:SetFreeAim(Angle())
end

function SWEP:CalcView( ply, pos, ang, fov )
	self.ViewModelFOV	= fov
	return pos, ang, fov
end
function SWEP:GetViewModelPosition(pos, ang)
	local freeaim = self:GetFreeAim()
	ang:RotateAroundAxis( ang:Up(), freeaim.y )
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	return pos, ang
end
-- function SWEP:GetViewModelPosition()
-- 	return pos_glob, ang_glob
-- end

-- function SWEP:PreDrawViewModel( vm, ply, weapon ) 

-- end
function SWEP:Tick()
	-- print(FrameTime())
	-- print(engine.TickInterval())
	local cmd = self.Owner:GetCurrentCommand()
	local x, y = cmd:GetMouseX() * engine.TickInterval() * self.FreeAimSensivity, cmd:GetMouseY() * engine.TickInterval() * self.FreeAimSensivity
	if ( x ~= 0 or y ~= 0 ) then
		local a = util_NormalizeAngles( self:GetFreeAim() ) + Angle( y * self.FreeAimRange, x * -self.FreeAimRange, 0 )
		
		util_Clamp( a )
		self:SetFreeAim(a)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Angle", 0, "FreeAim" )
end

	
function SWEP:ShootBullet( damage, num_bullets, aimcone )
 	local freeaim = self:GetFreeAim()
 	local ang = self.Owner:EyeAngles()
 	ang:RotateAroundAxis( ang:Up(), freeaim.y )
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()	// Source
	bullet.Dir 		= ang:Forward()// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 1	// Show a tracer on every x bullets 
    bullet.TracerName = "AR2Tracer" // what Tracer Effect should be used
	bullet.Force	= 1	// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.DamageType	= DMG_DISSOLVE
	bullet.AmmoType = "Pistol"
 
	self.Owner:FireBullets( bullet )
 
	self:ShootEffects()
 
end

function SWEP:PrimaryAttack()
	local vm = self.Owner:GetViewModel()
	self:ShootBullet(50,1,0.02)
		local x, y, z = 0, -0.1, math.Rand(-5, 5)
		local a = util_NormalizeAngles( self:GetFreeAim() ) + Angle( y * self.FreeAimRange, x * -self.FreeAimRange, 0 )	
		util_Clamp( a )
		self:SetFreeAim(a)
	-- if IsFirstTimePredicted() then self.Owner:ViewPunch(Angle(x , y, z)) end
	if CLIENT and IsFirstTimePredicted() then self.Owner:SetEyeAngles(self.Owner:EyeAngles() + Angle(y * 10 , x * 10, 0)) end
	self:EmitSound("PSR_FIRE")
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fire3" ))
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire(CurTime() + 0.05)
	self:SetNextSecondaryFire(CurTime() + 0.01)

end

function SWEP:SecondaryAttack()

	self:PrimaryAttack()

end

function SWEP:CalcView(ply, pos, ang, fov)
	return pos, ang
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end

function SWEP:Deploy()

	return true

end

function SWEP:Think()

end

function SWEP:DoImpactEffect( tr, nDamageType )
	if (!IsFirstTimePredicted()) then return end
	if ( tr.HitSky ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "AR2Impact", effectdata )
	
end
