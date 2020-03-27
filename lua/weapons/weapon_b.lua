
AddCSLuaFile()

SWEP.PrintName = "#Weapon_b"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_crowbar_c4.mdl" 
SWEP.ViewModelFOV = 60
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
SWEP.HitDistance 	= 70

SWEP.WorldModel = "models/morrowind/wooden/staff/w_wooden_staff.mdl"
SWEP.ViewModelAngle				= Angle(180,0,180)
SWEP.ViewModelPos				= Vector(-5,2,2)
-- SWEP.WorldModel = "models/weapons/c_crowbar.mdl"
-- SWEP.ViewModelAngle				= Angle(170,6,5.5)
-- SWEP.ViewModelPos				= Vector(-27.7,-12.21,16.3)
SWEP.ViewModelRendergroup		= 10 
SWEP.SwayScale					= 0					-- The scale of the viewmodel sway
SWEP.BobScale					= 0.0	
local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.BulletImpact" )

function SWEP:Initialize()
	self:SetHoldType( "melee" )
	CreateClientConVar( "modelb", self.WorldModel, true, false )

end

function SWEP:GetViewModelPosition( pos, ang )
	return pos + ang:Forward() * 0 + ang:Up() * 0, ang
end

function SWEP:PostDrawViewModel( vm, weapon, ply )
	if (LocalPlayer():GetViewModel(1) != vm) then
			local CsModel = ClientsideModel(GetConVar( "modelb" ):GetString(), self.ViewModelRendergroup)
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

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )

end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end

function SWEP:PrimaryAttack( right )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	local anim
	if (self.Owner:KeyDown(IN_SPEED)) then
		anim = "blunt_misscenter02"
	else
		anim = "one_short_misscenter02"
	end
	if ( right ) then
		if (self.Owner:KeyDown(IN_SPEED)) then
			anim = "blunt_misscenter03"
		else
			anim = "one_short_misscenter01"
		end
	end

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )

	self:UpdateNextIdle()
	self:SetNextMeleeAttack( CurTime() + 0.35 )

	self:SetNextPrimaryFire( CurTime() + 0.8 )
	self:SetNextSecondaryFire( CurTime() + 0.8 )

end

function SWEP:SecondaryAttack()

	self:PrimaryAttack( true )

end

function SWEP:DealDamage()

	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self.Owner:LagCompensation( true )
	local tr
	local filter = {}
	table.insert(filter, self.Owner)
	for i=1, 5 do
			tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = filter,
			mask = MASK_SHOT_HULL
		} )
		if ( !IsValid( tr.Entity ) ) then
			tr = util.TraceHull( {
				start = self.Owner:GetShootPos(),
				endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
				filter = filter,
				mins = Vector( -10, -10, -8 ),
				maxs = Vector( 10, 10, 8 ),
				mask = MASK_SHOT_HULL
			} )
		end
		table.insert(filter, tr.Entity)
	

		if (!( game.SinglePlayer() && CLIENT ) ) then
			if (tr.Hit) then
				self:EmitSound( HitSound )
				//util.ScreenShake( tr.HitPos, 8, 10, 0.4, 1000 )
			else
				self:EmitSound( SwingSound )
			end
		end

		local hit = false

		if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) ) then
			local dmginfo = DamageInfo()

			local attacker = self.Owner
			if ( !IsValid( attacker ) ) then attacker = self end
			dmginfo:SetAttacker( attacker )

			dmginfo:SetInflictor( self )
			dmginfo:SetDamage(self.Damage)
			dmginfo:SetDamageType(self.DamageType)

			if ( anim == "blunt_misscenter06" || anim == "blunt_misscenter05"|| anim == "one_short_misscenter01" ) then
				dmginfo:SetDamageForce( self.Owner:GetAimVector() * 25000 )
			elseif ( anim == "blunt_misscenter03" ) then
				dmginfo:SetDamageForce( tr.Entity:GetUp() * -25000 )
			elseif ( anim == "one_short_misscenter02" ) then
				dmginfo:SetDamageForce( self.Owner:GetRight() * 5000 + self.Owner:GetForward() * 10000 + tr.Entity:GetUp() * 10000) -- Yes we need those specific numbers
			elseif ( anim == "blunt_misscenter02" ) then
				dmginfo:SetDamageForce( self.Owner:GetRight() * -15000 + self.Owner:GetForward() * 10000 ) -- Yes we need those specific numbers
			end

			tr.Entity:TakeDamageInfo( dmginfo )
			hit = true

		end

		if ( SERVER && IsValid( tr.Entity ) ) then
			local phys = tr.Entity:GetPhysicsObject()
			if ( IsValid( phys ) ) then
				phys:ApplyForceOffset( self.Owner:GetAimVector() * 50000, tr.HitPos )
			end
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

	if ( idletime > 0 && CurTime() > idletime ) then

		vm:SendViewModelMatchingSequence( vm:LookupSequence( "one_short_idle" ))

		self:UpdateNextIdle()

	end

	local meleetime = self:GetNextMeleeAttack()

	if ( meleetime > 0 && CurTime() > meleetime ) then

		self:DealDamage()

		self:SetNextMeleeAttack( 0 )

	end

end
