AddCSLuaFile()

SWEP.Category		= "HL2 Melee"
SWEP.PrintName		= "This Is Cancer"		-- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.UseHands 		= true
SWEP.BobScale		= 0
SWEP.SwayScale		= 4
SWEP.ViewModelFlip	= false
SWEP.DrawCrosshair	= true
SWEP.ViewModel		= "models/weapons/v_models/v_cweaponry_ebl_m2.mdl"
SWEP.WorldModel		= "models/weapons/w_models/w_Cweaponry_psmg.mdl"
SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.AimFov				= 0
SWEP.AimFocus			= 0
SWEP.AimSensivity		= 1
SWEP.DefaultSensivity	= 1


SWEP.Primary.Automatic		= true			-- Automatic/Semi Auto
SWEP.Primary.Spread			= Angle( 0.1, 0.1, 0 )
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.TracerName		= "AR2Tracer"
SWEP.Primary.Tracer			= 1
SWEP.Primary.ClipSize		= 30					-- Size of a clip
SWEP.Primary.DefaultClip	= 30				-- Default number of bullets in a clip
SWEP.Primary.FireDelay		= 0.1
SWEP.Primary.Damage			= 35
SWEP.Primary.DamageType		= DMG_BULLET
SWEP.Primary.Force			= 5
SWEP.Primary.Bullets		= 1

SWEP.Secondary.ClipSize		= -1					-- Size of a clip
SWEP.Secondary.DefaultClip	= -1				-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= true				-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"
SWEP.CrosshairColor 		= Color( 255, 255, 255, 255 )

-- SWEP.SprintPos = Vector(0,0,0)
-- SWEP.SprintAng = Angle(20,0,0)
SWEP.SprintPos = Vector(-5,10,0)
SWEP.SprintAng = Angle(0,50,0)

SWEP.SightPos = Vector(0.55, -3.31, 0)
SWEP.SightAng = Angle(0, 0, 0) 
-- SWEP.SightPos = Vector(0, 0, 0)
-- SWEP.SightAng = Angle(0, 0, 0) 

SWEP.DefaultPos = Vector(0, 0, -2)
SWEP.DefaultAng = Angle(0, 0, -3) 

local g_aimang_old			= Angle()
local g_freeaimang_cur		= Angle()
local g_freeaimang_target	= Angle()
local g_sightang_cur		= Angle()
local g_sprintang_cur		= Angle()

local g_sightpos_cur		= Vector()
local g_sprintpos_cur		= Vector()

local g_primaryfire		= false
local g_sprinting			= false
local g_sight			= false

local g_nexprimaryfire	= 0
local g_primaryfire		= 0

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
		local l_angsum = (g_freeaimang_cur + g_sprintang_cur) * g_sightfrac_old * self.AimFocus
		ang:RotateAroundAxis( ang:Up(), l_angsum.y )
		ang:RotateAroundAxis( ang:Right(), -l_angsum.p )
		ang = ang + Angle(0,0,l_angsum.r)
	end
	return pos, ang, fov
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then
		return
	end
	if CLIENT && g_nexprimaryfire <= CurTime() then
		self.vmodel:ResetSequence(1);
		self.vmodel:SetPlaybackRate(1);
		self.vmodel:SetCycle(0);
		//g_nexprimaryfire = CurTime() + self.Primary.FireDelay
		self.Owner:ViewPunch(rand)
		self.Owner:SetEyeAngles(self.Owner:EyeAngles() + rand)
		local bullet = {}
			bullet.Src 			= self.Owner:EyePos()
			bullet.Force		= self.Primary.Force
			bullet.Damage		= self.Primary.Damage
			bullet.AmmoType 	= self.Primary.AmmoType
			bullet.Tracer		= self.Primary.Tracer
			bullet.TracerName	= self.Primary.TracerName
			bullet.Callback = function(ent, tr, dmg)
				if tr.Hit && tr.HitNonWorld then
					net.Start("client_dmg")
						net.WriteEntity(tr.Entity)
						net.WriteEntity(self)
						if tr.HitGroup == HITGROUP_HEAD then
							net.WriteFloat(dmg:GetDamage() * 2)
						else
							net.WriteFloat(dmg:GetDamage())
						end
						net.WriteString(self.Primary.DamageType)
						net.WriteTable({dmg:GetDamageForce().x,dmg:GetDamageForce().y,dmg:GetDamageForce().z})
						net.WriteTable({dmg:GetDamagePosition().x,dmg:GetDamagePosition().y,dmg:GetDamagePosition().z})
					net.SendToServer()
				end
			end
			local randang
			for i = 1,self.Primary.Bullets do
				randang = (ang + Angle(self.Primary.Spread.p * math.Rand(-1,1),self.Primary.Spread.y * math.Rand(-1,1),0))
				bullet.Dir 	= randang:Forward()
				ply:FireBullets(bullet)
				net.Start("client_effects")
					net.WriteTable({self.Owner:EyePos().x,self.Owner:EyePos().y,self.Owner:EyePos().z})
					net.WriteTable({randang:Forward().x,randang:Forward().y,randang:Forward().z})
					net.WriteString(self.Primary.TracerName)
				net.SendToServer()
			end
			self:EmitSound(Sound("PSHOTGUN_FIRE"), 105, 100)
			net.Start("client_sound")
				net.WriteEntity(self)
				net.WriteString(Sound("PSHOTGUN_FIRE"))
				net.WriteFloat(75)
				net.WriteFloat(100)
			net.SendToServer()
			if !self.Owner:ShouldDrawLocalPlayer() then
				PrecacheParticleSystem("muzzleflash_smg")
				ParticleEffectAttach("muzzleflash_smg", PATTACH_POINT_FOLLOW, self.vmodel, self.vmodel:LookupAttachment("muzzle"))
			end	
	end
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
end

function SWEP:SetCurSequence(idx,sequence)
	self.Owner:GetViewModel(idx):SendViewModelMatchingSequence( self.Owner:GetViewModel(idx):LookupSequence(sequence))
end

function SWEP:Think()
	//print(self:CanPrimaryAttack())
	return true
end

function SWEP:PostDrawViewModel(vm,weapon,ply)
	local l_angsum = g_freeaimang_cur + g_sprintang_cur
	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis( ang:Up(), l_angsum.y )
	ang:RotateAroundAxis( ang:Right(), -l_angsum.p )
	ang = ang + Angle(0,0,l_angsum.r)
	local tr = util.TraceLine( {
		start = LocalPlayer():EyePos(),
		endpos = LocalPlayer():EyePos() + ang:Forward()*100000 ,
		filter = LocalPlayer()
	} )
	if !tr.HitSky then
		render.SetMaterial( Material( "sprites/orangeflare1" ) ) 
		render.DrawSprite( tr.HitPos, math.pow(ply:EyePos():Distance( tr.HitPos),0.4)/1, math.pow(ply:EyePos():Distance( tr.HitPos),0.4)/1, Color( 255, 0, 0, math.Clamp(0,1 - ply:EyePos():Distance( tr.HitPos)/3000,1) * 255 ))
	end
	local rand = Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),0)

end

function SWEP:PreDrawViewModel( vm, weapon, ply )
	local ct				= CurTime()
	local aimang_cur		= ply:EyeAngles()
	local movespeed			= ply:GetVelocity():Length()
	local walkspeed			= ply:GetWalkSpeed()

	self.vmodel:DrawModel()
	
	if !g_sight && movespeed > walkspeed + 25 && ply:OnGround() then
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
	local l_eyeang = self.Owner:EyeAngles()
	l_eyeang:RotateAroundAxis( l_eyeang:Up(), l_angsum.y )
	l_eyeang:RotateAroundAxis( l_eyeang:Right(), -l_angsum.p )
	l_eyeang = l_eyeang + Angle(0,0,l_angsum.r)
	pos = pos + l_eyeang:Forward()*l_possum.z + l_eyeang:Up()*l_possum.x + l_eyeang:Right()*l_possum.y
	
	self.vmodel:SetPos(pos)
	self.vmodel:SetAngles(l_eyeang)
	self.vmodel:SetRenderOrigin( pos)
	self.vmodel:SetRenderAngles( l_eyeang )
	self.vmodel:SetupBones()
	self.vmodel:FrameAdvance()
	return self.vmodel:GetAttachment(1).Pos , self.vmodel:GetAttachment(1).Ang
end

function SWEP:DrawHUD()
	return
end

function SWEP:Initialize()
	self:SetHoldType( "ar2" )
	if CLIENT then
		self.vmodel = ClientsideModel(self.ViewModel)
		self.vmodel:SetNoDraw(true)
		self.vmodel:DrawModel(false)
	end
end

function SWEP:DrawWorldModel()
	self:DrawModel()
end
function SWEP:Reload()
	return
end

function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	if ( IsValid( self.Owner:GetViewModel(0) ) ) then
		self.Owner:GetViewModel(0):SetWeaponModel( "models/effects/teleporttrail.mdl" , self)
	end
end

function SWEP:OnRemove()
	self:Remove()
	if CLIENT then
		self.vmodel:Remove()
	end
end

function SWEP:DoImpactEffect( tr, nDamageType )
	if CLIENT then
		print("Effect",CurTime())
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "AR2Impact", effectdata )
	end	
end