AddCSLuaFile()

SWEP.PrintName = "WeaponMelee"

SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Spawnable = false
SWEP.ViewModel = "models/weapons/c_generic_186.mdl"

SWEP.DrawAmmo = false

SWEP.Damage 		= 16
SWEP.DamageType 	= DMG_GENERIC
SWEP.Force 			= Vector(1,0,0)
SWEP.HitDistance 	= 64
SWEP.DrawWeaponInfoBox = false
SWEP.Weight = 6

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
-- SWEP.SwayScale					= 1				-- The scale of the viewmodel sway
-- SWEP.BobScale					= 3	
SWEP.NextUse 					= 0
-- SWEP.HoldType 					= "melee"
-- SWEP.Collateral					= 3
SWEP.Mins 						= Vector(-5,-5,-5)
SWEP.Maxs						= Vector(5,5,5)

function SWEP:Initialize()
	self:SetHoldType( "melee" )
	self:SetCanPrimaryAttack(true)
	self:SetIsCharging(false)
	self:SetIsAttacking(false)
end
function SWEP:GetViewModelPosition( pos, ang )
	return pos + ang:Forward() * 0 + ang:Up() * 0, ang
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	if (self.WorldModel == nil or !util.IsValidModel(self.WorldModel)) then return false end

	local length = tall - 32
	if (self.SpawnIcon == nil) then
		self.SpawnIcon = vgui.Create( "SpawnIcon" )
		self.SpawnIcon:SetWide( length )
		self.SpawnIcon:SetTall( length )
		self.SpawnIcon:SetModel( self.WorldModel )
		self.SpawnIcon:Hide()
	end
	self.SpawnIcon:SetPos( x + (wide - length) / 2, y + (tall - length))
	self.SpawnIcon:SetAlpha(alpha)
	self.SpawnIcon:Show()
	timer.Create(self.ClassName.."HideIcon",FrameTime(),1,function()
		if (self.SpawnIcon) then self.SpawnIcon:Hide() end
	end)
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

function SWEP:PostDrawViewModel( vm, weapon, ply )
	if (ply:GetViewModel(1) == vm) then return end
	if (self.WorldModel == nil) then return end

	local handle = vm
	local model = ClientsideModel(self.WorldModel)
	local bone = handle:LookupBone( "ValveBiped.Bip01_R_Hand" )
	-- local angpos = handle:GetAttachment( bone )
	-- local ang = angpos.Ang
	-- local pos = angpos.Pos
	local matrix = handle:GetBoneMatrix( bone )
	local ang = matrix:GetAngles()
	local pos = matrix:GetTranslation()
	if (self.ModelAngles or self.ModelPos) then
		if (self.ModelAngles) then
			ang:RotateAroundAxis( ang:Forward(), self.ModelAngles.p )
			ang:RotateAroundAxis( ang:Right(), self.ModelAngles.y )
			ang:RotateAroundAxis( ang:Up(), self.ModelAngles.r )
		end
		if (self.ModelPos) then
			pos:Add(ang:Forward() * self.ModelPos.x)
			pos:Add(ang:Right() * self.ModelPos.y)
			pos:Add(ang:Up() * self.ModelPos.z)
		end
	elseif (model:LookupBone( "ValveBiped.Bip01_R_Hand" ) or model:LookupBone( "ValveBiped.Bip01_L_Hand" )) then
		model:SetParent(handle)
		model:AddEffects(EF_BONEMERGE)
	else
		ang:RotateAroundAxis( ang:Forward(), 180 )
		ang:RotateAroundAxis( ang:Up(), 180 )
		pos:Add(ang:Forward() * -5)
	end
	model:SetNoDraw(true)
	model:SetRenderOrigin( pos )
	model:SetRenderAngles( ang )
	model:SetupBones()
	model:DrawModel()
	model:Remove()	
end

function SWEP:DrawWorldModel(vm)
	if (self.WorldModel == nil) then return end

	local handle = self.Owner
	local model = ClientsideModel(self.WorldModel)
	local bone = handle:LookupBone( "ValveBiped.Bip01_R_Hand" )
	local angpos = handle:GetAttachment( bone )
	local matrix
	local pos
	local ang
	if (angpos) then
		ang = angpos.Ang
		pos = angpos.Pos
	else
		matrix = handle:GetBoneMatrix( bone )
		ang = matrix:GetAngles()
		pos = matrix:GetTranslation()
	end
	if (self.ModelAngles or self.ModelPos) then
		if (self.ModelAngles) then
			ang:RotateAroundAxis( ang:Forward(), self.ModelAngles.p )
			ang:RotateAroundAxis( ang:Right(), self.ModelAngles.y )
			ang:RotateAroundAxis( ang:Up(), self.ModelAngles.r )
		end
		if (self.ModelPos) then
			pos:Add(ang:Forward() * self.ModelPos.x)
			pos:Add(ang:Right() * self.ModelPos.y)
			pos:Add(ang:Up() * self.ModelPos.z)
		end
	elseif (model:LookupBone( "ValveBiped.Bip01_R_Hand" ) or model:LookupBone( "ValveBiped.Bip01_L_Hand" )) then
		model:SetParent(handle)
		model:AddEffects(EF_BONEMERGE)
	else
		ang:RotateAroundAxis( ang:Forward(), 180 )
		ang:RotateAroundAxis( ang:Up(), 180 )
		pos:Add(ang:Forward() * -5)
	end
	model:SetNoDraw(true)
	model:SetRenderOrigin( pos )
	model:SetRenderAngles( ang )
	model:SetupBones()
	model:DrawModel()
	model:Remove()	
end
function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 0, "CanPrimaryAttack" )
	self:NetworkVar( "Bool", 1, "IsAttacking" )
	self:NetworkVar( "Bool", 2, "IsCharging" )
	self:NetworkVar( "Float", 0, "AttackTime" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Float", 2, "ChargeTime" )
	self:NetworkVar( "Float", 3, "RestoreTime" )
	self:NetworkVar( "Float", 4, "NextUse" )
	
end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end

function SWEP:PrimaryAttack()
end
function SWEP:SecondaryAttack()
end

function SWEP:DealDamage()
	local vm = self.Owner:GetViewModel()
	local shootpos = self.Owner:GetShootPos()
	local hitdistance = self.AttackHandle and self.AttackHandle.HitDistance or self.HitDistance
	local mins = self.AttackHandle and self.AttackHandle.Mins or self.Mins
	local maxs = self.AttackHandle and self.AttackHandle.Maxs or self.Maxs
	local damage = self.AttackHandle and self.AttackHandle.Damage or self.Damage
	local dmgtype = self.AttackHandle and self.AttackHandle.DamageType or self.DamageType
	local force = self.AttackHandle and self.AttackHandle.Force or self.Force
	local forcemul = self.AttackHandle and self.AttackHandle.ForceMultiplier or self.ForceMultiplier
	local hiteffect = self.AttackHandle and self.AttackHandle.HitEffect or self.HitEffect
	local hitsound =self.AttackHandle and self.AttackHandle.HitSoud or self.HitSound
	local hitdecal = self.AttackHandle and self.AttackHandle.HitDecal or self.HitDecal
	local hitcolor = self.AttackHandle and self.AttackHandle.HitColor or self.HitColor
	local misssound = self.AttackHandle and self.AttackHandle.MissSound or self.MissSound
	local endpos = shootpos + self.Owner:GetAimVector() * hitdistance

	self.Owner:LagCompensation( true )
	local tr = util.TraceLine( {
		start = shootpos,
		endpos = endpos,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )
	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = shootpos,
			endpos = endpos,
			filter = self.Owner,
			mins = self.Mins,
			maxs = self.Maxs,
			mask = MASK_SHOT_HULL
		} )
	end
	self.Owner:LagCompensation( false )	
	if (SERVER and IsValid( tr.Entity )) then
		force = (force * (forcemul or 1) * GetConVar( "sv_melee_force_multiplier" ):GetFloat())
		force:Rotate(self.Owner:GetAimVector():Angle())
		if ( tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0  ) then
			local dmginfo = DamageInfo()
			local attacker = self.Owner
			if ( !IsValid( attacker ) ) then attacker = self end
			dmginfo:SetAttacker( attacker )
			dmginfo:SetInflictor( self )
			dmginfo:SetDamage(damage)
			dmginfo:SetDamageType(dmgtype)
			if (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) then
				dmginfo:SetDamageForce( force )
			end
			tr.Entity:TakeDamageInfo( dmginfo )
		end
		local phys
		if (tr.Entity:GetClass() == "prop_ragdoll" ) then
			phys = tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone)
		else
			phys = tr.Entity:GetPhysicsObject()
		end
		if (IsValid(phys)) then
			phys:ApplyForceOffset(force, tr.HitPos)
		end
	end
	if (!IsFirstTimePredicted()) then return end
	if (tr.HitWorld) then
		tr = util.TraceLine( {
			start = shootpos,
			endpos = endpos,
			filter = self.Owner,
			mask = MASK_SHOT_HULL
		} )
	end
	if (tr.Hit) then
		local effectdata = EffectData()
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetStart( tr.StartPos )
		effectdata:SetHitBox( tr.HitBox )
		-- effectdata:SetMagnitude(2)
		-- effectdata:SetFlags(2)
		-- effectdata:SetScale(1)
		-- effectdata:SetRadius(100)
		effectdata:SetEntity( tr.Entity )	
		effectdata:SetSurfaceProp( tr.SurfaceProps )
		if SERVER then effectdata:SetEntIndex( tr.Entity:EntIndex() ) end
		local surface = util.GetSurfaceData(tr.SurfaceProps)
		local decal
		local effect
		if surface then
			if (surface.name == "alienflesh") then
				effectdata:SetColor(1)
				decal = "YellowBlood"
				effect = "BloodImpact"
			elseif (surface.name == "antlion") then
				effectdata:SetColor(2)
				decal = "YellowBlood"
				effect = "BloodImpact"
			elseif (surface.name == "hunter") then
				effectdata:SetColor(6)
				effect = "BloodImpact"
			elseif (surface.name == "flesh" or surface.name == "armorflesh" or surface.name == "bloodyflesh" or surface.name == "zombieflesh" ) then
				effectdata:SetColor(0)
				decal = "Blood"
				effect = "BloodImpact"
			end
		end
		util.Effect( "Impact", effectdata )
		if (effect) then
			util.Effect(effect, effectdata)
		end
		if (decal) then
			util.Decal(decal, shootpos, tr.HitPos + self.Owner:GetAimVector() * 96, {self.Owner, tr.Entity})
			util.Decal(decal, tr.HitPos, tr.HitPos + tr.HitNormal * 96, tr.Entity)
		end
		if (hiteffect) then
			if (hitcolor) then effectdata:SetColor(hitcolor) end
			util.Effect(hiteffect, effectdata)
		end
		if (hitdecal) then
			util.Decal(hitdecal, shootpos, endpos, self.Owner)
		end
		if (hitsound) then self:EmitSound( hitsound ) end
	else
		if (misssound) then self:EmitSound( misssound ) end
	end
	print(tr.Entity)
end

function SWEP:Deploy()
	if (!self.DrawSequence) then return end
	local speed = GetConVarNumber( "sv_defaultdeployspeed" )
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( self.DrawSequence ) )
	vm:SetPlaybackRate( speed )
	self:SetNextUse(CurTime() + 0.25)
	self:UpdateNextIdle()
end

function SWEP:Create(tr)
	local entity_name = self.EntityClass or "prop_physics"
	local model = self.WorldModel

	local ent = ents.Create( entity_name )
	if ( !IsValid( ent ) ) then return end

	local ang = self.Owner:EyeAngles()
	ang.yaw = ang.yaw + 180
	ang.roll = 0
	ang.pitch = 0

	if ( entity_name == "prop_ragdoll" ) then
		ang.pitch = -90
		tr.HitPos = tr.HitPos
	end

	ent:SetModel( model )
	ent:SetAngles( ang )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()

	if ( entity_name == "prop_effect" && IsValid( ent.AttachedEntity ) ) then
		ent.AttachedEntity:SetBodyGroups( strBody )
	end

	local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )
	vFlushPoint = ent:NearestPoint( vFlushPoint )
	vFlushPoint = ent:GetPos() - vFlushPoint
	vFlushPoint = tr.HitPos + vFlushPoint

	if ( entity_name != "prop_ragdoll" ) then

		ent:SetPos( vFlushPoint )

	else
		-- With ragdolls we need to move each physobject
		local VecOffset = vFlushPoint - ent:GetPos()
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			local phys = ent:GetPhysicsObjectNum( i )
			phys:SetPos( phys:GetPos() + VecOffset )
		end
	end
	return ent
end

function SWEP:Throw()
	if (SERVER) then
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 96),
			mins = self.Mins,
			maxs = self.Maxs,
			filter = self.Owner
		} )
		local ent = self:Create(tr)
		if (!tr.Hit) then
			local forcemul = (self.ForceMultiplierThrow or self.ForceMultiplier) * GetConVar( "sv_melee_force_multiplier" ):GetFloat()
			local torquemul = GetConVar( "sv_melee_torque_multiplier" ):GetFloat()
			local force = self.Owner:GetAimVector() * forcemul
			print(forcemul)
			if (ent:IsNPC()) then
					ent:SetLocalVelocity( force )
			else
				for i = 0, ent:GetPhysicsObjectCount() - 1 do
					local phys = ent:GetPhysicsObjectNum( i )
					local torque = self.Owner:GetAimVector() * torquemul
					torque:Rotate(AngleRand())
					phys:ApplyForceCenter(force)
					phys:ApplyTorqueCenter( torque )
				end
			end
		end
		self.EntityClass = nil
		self:Remove()
	end
end

function SWEP:Pickup()
end

function SWEP:OnRemove()
	if (!(IsValid(self.Owner))) then return end
	if (SERVER) then
		if (self.EntityClass) then
			local tr = util.TraceLine( {
				start = self.Owner:GetPos(),
				endpos = self.Owner:GetPos() + Vector(0,0,-96),
				mask = MASK_SHOT_HULL
			} )
			self:Create(tr)
		end
	end
	local weapons = self.Owner:GetWeapons()
	local heaviest = self.Owner:GetPreviousWeapon()
	if (!IsValid(heaviest)) then
		heaviest = nil
		for _, wep in pairs(weapons) do
			if (wep != self and wep:GetClass() != "gmod_tool" and wep:GetClass() != "gmod_camera") then
				if (!heaviest or weight and weight < wep:GetWeight() and weight) then
					heaviest = wep
					weight = wep:GetWeight()
				end
			end
		end
	end
	if (SERVER and heaviest) then
		self.Owner:SelectWeapon( heaviest:GetClass() )
	end
	if (CLIENT) then
		if (self.SpawnIcon) then
			print("what?")
			self.SpawnIcon:Hide()
			self.SpawnIcon:Remove()
		end
		-- if (heaviest) then
		-- 	-- input.SelectWeapon( heaviest )
		-- end
	end
end
function SWEP:Think()
	if ( game.SinglePlayer() and CLIENT ) then return end
	local MeleeSpeed = GetConVarNumber( "sv_melee_speed" )
	if (self.Owner:KeyDown(IN_RELOAD) and self:GetNextUse() < CurTime()) then
		print("height")
		self:Throw()
		self:SetNextUse(CurTime() + 0.25)
	end
	local curtime = CurTime()
	local vm = self.Owner:GetViewModel()
	local idletime = self:GetNextIdle()
	local charging = self:GetIsCharging()
	local attacking = self:GetIsAttacking()

	if ( self.IdleSequence && idletime < curtime and self:GetCanPrimaryAttack()) then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( self.IdleSequence ))
		self:UpdateNextIdle()
	end
	if (self:GetCanPrimaryAttack() and self.Owner:KeyDown(IN_ATTACK)) then
		local time = self.ChargeTime
		local sequence = self.ChargeSequence
		math.randomseed( curtime )
		self.AttackHandle = self.Attack and table.Random(self.Attack)
		if (self.AttackHandle) then
			time = self.AttackHandle.ChargeTime or time
			sequence = self.AttackHandle.ChargeSequence or sequence
		end
		if (sequence) then
			vm:SendViewModelMatchingSequence( vm:LookupSequence( sequence ))
			vm:SetPlaybackRate( MeleeSpeed )
			self:UpdateNextIdle()
		end
		if (time) then
			self:SetChargeTime( curtime + time / MeleeSpeed ) 
		end

		self:SetIsCharging(true)
		self:SetCanPrimaryAttack(false)
	elseif ( charging and self:GetChargeTime() < curtime and !self.Owner:KeyDown(IN_ATTACK)) then
		local time = self.AttackTime
		local sequence = self.AttackSequence
		if (self.AttackHandle) then
			time = self.AttackHandle.AttackTime or time
			sequence = self.AttackHandle.AttackSequence or sequence
		end
		if (sequence) then
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			vm:SendViewModelMatchingSequence( vm:LookupSequence( sequence ))
			vm:SetPlaybackRate( MeleeSpeed )
			self:UpdateNextIdle()
		end
		if (time) then
			self:SetAttackTime(curtime + time / MeleeSpeed)
		end
		self:DealDamage()
		self:SetIsCharging(false)
		self:SetIsAttacking(true)
	elseif (attacking) then
		if (self:GetAttackTime() < curtime) then
			if (!self:GetCanPrimaryAttack()) then
				local time = self.RestoreTime
				local sequence = self.RestoreSequence
				if (self.AttackHandle) then
					time = self.AttackHandle.RestoreTime or time
					sequence = self.AttackHandle.RestoreSequence or sequence
				end
				if (sequence) then
					vm:SendViewModelMatchingSequence( vm:LookupSequence( sequence ) )
					vm:SetPlaybackRate( MeleeSpeed )
					self:UpdateNextIdle()
				end
				if (time) then
					self:SetRestoreTime( curtime + time / MeleeSpeed)
				end
				self:SetIsAttacking(false)
			end
		elseif (self.Owner:KeyDown(IN_ATTACK)) then
			math.randomseed( curtime )
			self.AttackHandle = self.Attack and table.Random(self.Attack)
			self:SetChargeTime(self:GetAttackTime())
			self:SetIsCharging(true)
			self:SetIsAttacking(false)
		end
	elseif(!attacking and !charging and !self:GetCanPrimaryAttack() and self:GetRestoreTime() < curtime) then
		self:SetCanPrimaryAttack(true)
	end
end
