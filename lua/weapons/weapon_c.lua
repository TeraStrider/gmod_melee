
AddCSLuaFile()

SWEP.PrintName = "#Weapon_c"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.SequenceIdle = "one_blunt_idle01"
SWEP.SequenceIdleCharged = "one_blunt_idle_charge01"
SWEP.SequenceCharge = "one_blunt_charge01"
SWEP.SequenceAttackHit = "one_blunt_misscenter01"	
SWEP.SequenceAttackMiss = "one_blunt_misscenter01"


SWEP.RestoreTimeHit = 0.2
SWEP.RestoreTimeMiss = 0.5
SWEP.ChargeTime = 0.2
SWEP.ViewModel = "models/weapons/c_crowbar_h2.mdl" 
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
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

SWEP.Damage 		= 50
SWEP.DamageType 		= DMG_CLUB
SWEP.HitDistance 	= 60

SWEP.WorldModel = "models/morrowind/wooden/staff/w_wooden_staff.mdl"
SWEP.ViewModelAngle				= Angle(180,0,180)
SWEP.ViewModelPos				= Vector(-5,2,2)
-- SWEP.WorldModel = "models/weapons/c_crowbar.mdl"
-- SWEP.ViewModelAngle				= Angle(170,6,5.5)
-- SWEP.ViewModelPos				= Vector(-27.7,-12.21,16.3)
SWEP.ViewModelRendergroup		= 10 
SWEP.SwayScale					= 0					-- The scale of the viewmodel sway
SWEP.BobScale					= 0	
local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.BulletImpact" )

function SWEP:Initialize()
	self:SetHoldType( "melee" )
	CreateClientConVar( "modelc", self.WorldModel, true, false )
	self:SetCanPrimaryAttack(true)
	self:SetIsCharging(false)
	self:SetIsAttacking(false)
end

function SWEP:GetViewModelPosition( pos, ang )
	return pos + ang:Forward() * 0 + ang:Up() * 0, ang
end

function SWEP:PostDrawViewModel( vm, weapon, ply )
	if (LocalPlayer():GetViewModel(1) != vm) then
		print(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
			local CsModel = ClientsideModel(GetConVar( "modelc" ):GetString(), self.ViewModelRendergroup)
			local matrix = vm:GetBoneMatrix( 23 )
			local ang = matrix:GetAngles()
			local pos = matrix:GetTranslation()
			//render.DrawLine( pos, pos + ang:Forward() * 1 + ang:Right() * 0 + ang:Up() * -20, Color( 255, 255, 255 ), false ) 
			ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.p )
			ang:RotateAroundAxis( ang:Right(), self.ViewModelAngle.y )
			ang:RotateAroundAxis( ang:Up(), self.ViewModelAngle.r )
            pos:Add(ang:Forward() * self.ViewModelPos.x)
            pos:Add(ang:Right() * self.ViewModelPos.y)
            pos:Add(ang:Up() * self.ViewModelPos.z)
			CsModel:SetNoDraw(true)
			CsModel:SetRenderOrigin( pos )
			CsModel:SetRenderAngles( ang )
			CsModel:SetupBones()
			CsModel:DrawModel()
			CsModel:Remove()
	end
end

function SWEP:DrawWorldModel()
	-- if (IsValid(CsModel) && self.Owner:GetBoneMatrix( 11 ) != nil) then
			-- local matrix = self.Owner:GetBoneMatrix( 11 )
			-- local ang = matrix:GetAngles()
			-- local pos = matrix:GetTranslation()
			-- ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.p )
			-- ang:RotateAroundAxis( ang:Right(), self.ViewModelAngle.y )
			-- ang:RotateAroundAxis( ang:Up(), self.ViewModelAngle.r )
            -- pos:Add(ang:Forward() * self.ViewModelPos.x)
            -- pos:Add(ang:Right() * self.ViewModelPos.y)
            -- pos:Add(ang:Up() * self.ViewModelPos.z)
			-- CsModel:SetRenderOrigin( pos )
			-- CsModel:SetRenderAngles( ang )
			-- -- CsModel:SetupBones()
			-- CsModel:DrawModel()
	-- end
end
function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "AttackTime" )
	self:NetworkVar( "Bool", 0, "CanPrimaryAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Float", 2, "ChargeTime" )
	self:NetworkVar( "Float", 3, "RestoreTime" )
	self:NetworkVar( "Bool", 3, "IsAttacking" )
	self:NetworkVar( "Bool", 2, "IsCharging" )
	
end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end

function SWEP:PrimaryAttack(right)
	if (self:GetCanPrimaryAttack()) then
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceCharge ) )
		self:UpdateNextIdle()
		self:SetChargeTime( CurTime() + self.ChargeTime )
		self:SetIsCharging(true)
		self:SetCanPrimaryAttack(false)
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack(true)
end

function SWEP:DealDamage()
	local vm = self.Owner:GetViewModel()
	local anim = self:GetSequenceName(vm:GetSequence())

	self.Owner:LagCompensation( true )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if (!( game.SinglePlayer() && CLIENT ) ) then
		if (tr.Hit) then
			self:EmitSound( "physics/body/body_medium_break3.wav" )
			//util.ScreenShake( tr.HitPos, 8, 10, 0.4, 1000 )
			vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceAttackHit ))
			self:SetRestoreTime(CurTime() + self.RestoreTimeHit)
		else
			vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceAttackMiss ))
			self:EmitSound( SwingSound )
			self:SetRestoreTime(CurTime() + self.RestoreTimeMiss)
		end
	end
	self:UpdateNextIdle()

	local hit = false

	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) ) then
		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		dmginfo:SetInflictor( self )
		dmginfo:SetDamage(self.Damage)
		dmginfo:SetDamageType(self.DamageType)
		dmginfo:SetDamageForce( self.Owner:GetRight() * 5000 + self.Owner:GetForward() * 10000 + tr.Entity:GetUp() * 10000) -- Yes we need those specific numbers
		
		tr.Entity:TakeDamageInfo( dmginfo )
		hit = true

	end

	if ( SERVER && IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * 50000, tr.HitPos )
		end
	end

	self.Owner:LagCompensation( false )

end

function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end


function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "one_short_draw" ) )
	vm:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	return true

end

function SWEP:Think()
	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()
	local charging = self:GetIsCharging()
	local attacking = self:GetIsAttacking()
	if ( idletime > 0 && idletime < curtime ) then
		if (charging) then
			vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceIdleCharged ))
		else
			vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceIdle ))
		end
		self:UpdateNextIdle()
	end
	if ( charging && self:GetChargeTime() < curtime && !self.Owner:KeyDown(IN_ATTACK) && !self.Owner:KeyDown(IN_ATTACK2)) then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self:DealDamage()
		self:SetIsCharging(false)
		self:SetIsAttacking(true)
	elseif(self:GetIsAttacking() && !self:GetCanPrimaryAttack() && self:GetRestoreTime() < curtime) then
		self:SetCanPrimaryAttack(true)
		self:SetIsAttacking(false)
	end
end
