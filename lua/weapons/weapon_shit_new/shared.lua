AddCSLuaFile()

SWEP.Category		= "HL2 Melee"
SWEP.PrintName		= "This Is Cancer NEW"		-- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.UseHands 		= true
SWEP.BobScale		= 0
SWEP.SwayScale		= 2
SWEP.ViewModelFlip	= false
SWEP.DrawCrosshair	= false
SWEP.ViewModel		= "models/weapons/c_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_models/w_Cweaponry_psmg.mdl"
SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.AimFov				= 30
SWEP.AimFocus			= 0
SWEP.AimSensivity		= 1
SWEP.DefaultSensivity	= 1


SWEP.Primary.Automatic		= true			-- Automatic/Semi Auto
SWEP.Primary.Spread			= Vector(0.04,0.04,0)
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.TracerName		= "AR2Tracer"
SWEP.Primary.Tracer			= 1
SWEP.Primary.ClipSize		= -1					-- Size of a clip
SWEP.Primary.DefaultClip	= -1				-- Default number of bullets in a clip
SWEP.Primary.FireDelay		= 0.05
SWEP.Primary.Damage			= 35
SWEP.Primary.DamageType		= DMG_BULLET
SWEP.Primary.Force			= 35
SWEP.Primary.Bullets		= 1

SWEP.Secondary.ClipSize		= -1					-- Size of a clip
SWEP.Secondary.DefaultClip	= -1				-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"
SWEP.CrosshairColor 		= Color( 255, 255, 255, 255 )

-- SWEP.SprintPos = Vector(0,0,0)
-- SWEP.SprintAng = Angle(20,0,0)
SWEP.SprintPos = Vector(-2,-2,0)
SWEP.SprintAng = Angle(20,20,-15)

SWEP.SightPos = Vector(1, -6.4, 0)
SWEP.SightAng = Angle(0, 0, 0) 
-- SWEP.SightPos = Vector(0, 0, 0)
-- SWEP.SightAng = Angle(0, 0, 0) 

SWEP.DefaultPos = Vector(0, 0, -5)
SWEP.DefaultAng = Angle(0, 0, 0)

SWEP.CurDir = angle_zero

local g_aimang_old			= Angle()
local g_freeaimang_cur		= Angle()
local g_freeaimang_target	= Angle()
local g_sightang_cur		= Angle()
local g_sprintang_cur		= Angle()

local g_sightpos_cur		= Vector()
local g_sprintpos_cur		= Vector()

local g_primaryfire			= false
local g_sprinting			= false
local g_sight				= false

local g_nexprimaryfire		= 0
local g_primaryfire			= 0

local g_sighttime			= 0
local g_sightfrac_old		= 0
local g_sightfrac_cur		= 0

local g_runtime 			= 0
local g_runfrac_old 		= 0
local g_runfrac_cur 		= 0

local function LerpTime(frac,from,to,time)
	return to - (to - from)*(math.pow(math.Clamp(0,1 - frac,1),time))
end

function SWEP:CalcView( ply, pos, ang, fov )
	self.ViewModelFOV	= fov
	if self.AimFov != 0 then
		fov = fov + ((self.AimFov - fov) * g_sightfrac_old)
	end
	if self.AimFocus != 0 then
		local l_angsum = (g_freeaimang_cur) * g_sightfrac_old * self.AimFocus
		ang:RotateAroundAxis( ang:Up(), l_angsum.y )
		ang:RotateAroundAxis( ang:Right(), -l_angsum.p )
		ang = ang + Angle(0,0,l_angsum.r)
	end
	return pos, ang, fov
end

function SWEP:PrimaryAttack()
	if !game.SinglePlayer() then
		//if SERVER then
			self:SetNextPrimaryFire(CurTime() + self.Primary.FireDelay)
			self.Owner:GetViewModel(0):SendViewModelMatchingSequence( self.Owner:GetViewModel(0):LookupSequence("fire01"))
			self:EmitSound("weapons/smg1/smg1_fire1.wav",75,100,1,CHAN_STATIC)
		if g_nexprimaryfire <= CurTime() then
			self:ShootBullet()
		end
	end
end

function SWEP:SecondaryAttack()
self:SetNextSecondaryFire(CurTime() + self.Primary.FireDelay)
end

function SWEP:FireAnimationEvent() return true end

function SWEP:PostDrawViewModel(vm,weapon,ply)
	local l_angsum = g_freeaimang_cur + g_sprintang_cur
	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis( ang:Up(), l_angsum.y )
	ang:RotateAroundAxis( ang:Right(), -l_angsum.p )
	local tr = util.TraceLine( {
		start = LocalPlayer():EyePos(),
		endpos = LocalPlayer():EyePos() + ang:Forward()*100000 ,
		filter = LocalPlayer()
	} )
	if !tr.HitSky then
		render.SetMaterial( Material( "sprites/orangeflare1" ) ) 
		render.DrawSprite( tr.HitPos, math.pow(ply:EyePos():Distance( tr.HitPos),0.4)/1, math.pow(ply:EyePos():Distance( tr.HitPos),0.4)/1, Color( 255, 0, 0, math.Clamp(0,1 - ply:EyePos():Distance( tr.HitPos)/3000,1) * 255 ))
	end
	
end

function SWEP:PreDrawViewModel( vm, weapon, ply )
	if game.SinglePlayer() && self.Owner:KeyDown(IN_ATTACK) && g_nexprimaryfire <= CurTime() then
		self:ShootBullet()
		self.Owner:GetViewModel(0):SendViewModelMatchingSequence( self.Owner:GetViewModel(0):LookupSequence("fire01"))
		self:EmitSound("weapons/smg1/smg1_fire1.wav",75,100,1,CHAN_STATIC)
	end
	local ct				= CurTime()
	local aimang_cur		= ply:EyeAngles()
	local movespeed			= ply:GetVelocity():Length()
	local walkspeed			= ply:GetWalkSpeed()
	
	if (!g_sight && movespeed > walkspeed + 25 && ply:OnGround()) && !ply:KeyDown(IN_ATTACK) then
		if !g_sprinting then
			g_sprinting 	= true
			g_runtime  		= ct
			g_runfrac_cur 	= g_runfrac_old
		end
		g_runfrac_old = LerpTime(0.8,g_runfrac_cur,1,ct - g_runtime )
	else
		if g_sprinting then
			g_sprinting = false
			g_runtime  = ct
			g_runfrac_cur = g_runfrac_old
		end
		g_runfrac_old = LerpTime(0.999999,g_runfrac_cur,0,ct - g_runtime )
	end
	
	if ply:KeyDown(IN_ATTACK2) then
		if !g_sight then
			g_sight = true
			g_sighttime = ct
			g_sightfrac_cur = g_sightfrac_old
		end
		g_sightfrac_old 		= LerpTime(0.999999,g_sightfrac_cur,1,ct - g_sighttime )	
	else
		if g_sight then
			g_sight = false
			g_sighttime = ct
			g_sightfrac_cur = g_sightfrac_old
		end
		g_sightfrac_old 		= LerpTime(0.999,g_sightfrac_cur,0,ct - g_sighttime )
	end	
	
	g_sightpos_cur		= g_sightfrac_old * self.SightPos
	g_sightang_cur		= g_sightfrac_old * self.SightAng
	if !g_sight then
		g_sprintpos_cur 		= g_runfrac_old * self.SprintPos
		g_sprintang_cur 		= g_runfrac_old * self.SprintAng + math.min(ply:GetVelocity():Length() * 0.0025 ,1) * Angle(-1.5 * math.cos(ct * 20),-1.5 * math.sin(ct * 10),1.5 * math.cos(ct * 10))
	else
		g_sprintpos_cur 		= g_runfrac_old * self.SprintPos
		g_sprintang_cur 		= g_runfrac_old * self.SprintAng + math.min(ply:GetVelocity():Length() * 0.0025 ,1) * Angle(-0.75 * math.cos(ct * 20),-0.75 * math.sin(ct * 10),0.75 * math.cos(ct * 10))	
	end

	
	if aimang_cur != g_aimang_old then
		local radius_cur		= GetConVarNumber("sk_freeaim_radius")
		local speed				= GetConVarNumber("sk_freeaim_speed")
		if math.abs(aimang_cur.y - g_aimang_old.y) > 180 || math.abs(aimang_cur.p - g_aimang_old.p) > 180 then
			if math.abs(aimang_cur.y - g_aimang_old.y) > 180 then
				if (g_aimang_old.y < aimang_cur.y) then
					g_freeaimang_target = g_freeaimang_target + Angle(0,aimang_cur.y - g_aimang_old.y - 360,0)
				else
					g_freeaimang_target = g_freeaimang_target + Angle(0,aimang_cur.y - g_aimang_old.y + 360,0)
				end
			end
			if math.abs(aimang_cur.p - g_aimang_old.p) > 180 then
				if (g_aimang_old.p < aimang_cur.p) then
					g_freeaimang_target = g_freeaimang_target + Angle(aimang_cur.p - g_aimang_old.p - 360,0,0)
				else
					g_freeaimang_target = g_freeaimang_target + Angle(aimang_cur.p - g_aimang_old.p + 360,0,0)
				end
			end
			g_freeaimang_target = g_freeaimang_cur + g_freeaimang_target*speed
		else
			g_freeaimang_target = g_freeaimang_cur + aimang_cur*speed - g_aimang_old*speed
		end
		if math.pow(g_freeaimang_target.y,2) + math.pow(g_freeaimang_target.p,2) <= math.pow(radius_cur,2) then
			g_freeaimang_cur = g_freeaimang_target
		else
			if g_freeaimang_target.p > 0 then
				g_freeaimang_cur = Angle(radius_cur*math.sqrt(1 - math.pow(g_freeaimang_target.y / math.sqrt(math.pow(g_freeaimang_target.y,2) + math.pow(g_freeaimang_target.p,2)),2)),(g_freeaimang_target.y / math.sqrt(math.pow(g_freeaimang_target.y,2) + math.pow(g_freeaimang_target.p,2)))*radius_cur,0)
			else
				g_freeaimang_cur = Angle(-radius_cur*math.sqrt(1 - math.pow(g_freeaimang_target.y / math.sqrt(math.pow(g_freeaimang_target.y,2) + math.pow(g_freeaimang_target.p,2)),2)),(g_freeaimang_target.y / math.sqrt(math.pow(g_freeaimang_target.y,2) + math.pow(g_freeaimang_target.p,2)))*radius_cur,0)
			end
		end
		g_freeaimang_target = angle_zero
		g_aimang_old = aimang_cur
	end
end

function SWEP:AdjustMouseSensitivity()
	return self.DefaultSensivity - ((self.DefaultSensivity - self.AimSensivity) * g_sightfrac_old)
end

function SWEP:GetViewModelPosition( pos, ang )
	local l_angsum = g_freeaimang_cur + g_sightang_cur + g_sprintang_cur + self.DefaultAng
	local l_possum = g_sightpos_cur + g_sprintpos_cur + self.DefaultPos
	ang:RotateAroundAxis( ang:Up(), l_angsum.y )
	ang:RotateAroundAxis( ang:Right(), -l_angsum.p )
	ang = ang + Angle(0,0,l_angsum.r)
	pos = pos + ang:Forward()*l_possum.z + ang:Up()*l_possum.x + ang:Right()*l_possum.y

	return pos , ang
end

function SWEP:DrawHUD()
	return
end

function SWEP:ShootBullet()
if CLIENT then
		g_nexprimaryfire = CurTime() + self.Primary.FireDelay
		local l_angsum = g_freeaimang_cur + g_sightang_cur + g_sprintang_cur
		local ang = self.Owner:EyeAngles()
		ang:RotateAroundAxis( ang:Up(), l_angsum.y )
		ang:RotateAroundAxis( ang:Right(), -l_angsum.p )
		local ent_table = {}
		local damage
		local bullet = {}
			bullet.Src 			= self.Owner:EyePos()
			bullet.Force		= self.Primary.Force
			bullet.Damage		= self.Primary.Damage
			//bullet.Spread		= Vector(0.03,0.03,0)
			bullet.Tracer		= self.Primary.Tracer
			bullet.Num			= self.Primary.Bullets
			bullet.TracerName	= self.Primary.TracerName
			bullet.Dir 			= ang:Forward()
			bullet.Callback = function(ent, tr, dmg)
				if tr.Hit && tr.HitNonWorld then
					if tr.HitGroup == 1 then
						damage = dmg:GetDamage() * 2
					elseif tr.HitGroup > 3 then
						damage = dmg:GetDamage() / 2
					else
						damage = dmg:GetDamage()
					end
					if ent_table[tr.Entity] == nil then
						ent_table[tr.Entity] = {}
						ent_table[tr.Entity][0] = 0
						ent_table[tr.Entity][1] = tr.PhysicsBone
						ent_table[tr.Entity][2] = {dmg:GetDamageForce().x,dmg:GetDamageForce().y,dmg:GetDamageForce().z}
						ent_table[tr.Entity][3] = {dmg:GetDamagePosition().x,dmg:GetDamagePosition().y,dmg:GetDamagePosition().z}
					end
					ent_table[tr.Entity][0] = ent_table[tr.Entity][0] + damage
				end
			end
		self.Owner:FireBullets(bullet)
		net.Start("receive_test")
			net.WriteTable(ent_table)
		net.SendToServer()
	end
end

function SWEP:Think()
	return true 
end

function SWEP:Initialize()
	self:SetHoldType( "ar2" )
end

function SWEP:DrawWorldModel()
	self:DrawModel()
end
function SWEP:Reload()
	self:ShootBullet()
	return
end

function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
end

function SWEP:OnRemove()
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if CLIENT then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "AR2Impact", effectdata )
	end	
end