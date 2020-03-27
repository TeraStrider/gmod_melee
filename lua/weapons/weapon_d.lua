
AddCSLuaFile()
game.AddParticles( "particles/explosion.pcf" )
PrecacheParticleSystem( "ExplosionCore_wall" )
local MaterialData = {
	[MAT_ANTLION] = { --//65
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_BLOODYFLESH] = {--//66
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_CONCRETE] = {--//67
		["default"] = {
		},
		decal =  "Impact.Concrete",
		effect = "vomit"
	},
	[MAT_DIRT] = {--//68
		["plaster"] = {
		},
		decal =  "Impact.Antlion",
		effect = "bloodspray",
		color = 1
	},
	[MAT_EGGSHELL] = {--//69
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_FLESH] = {--//70
		["flesh"] = {
		},
		decal =  "Impact.Flesh",
		effect = "BloodImpact",
		color = 0
	},
	[MAT_GRATE] = {--//71
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_ALIENFLESH] = {--//72
		["alienflesh"] = {
		},
		decal =  "Impact.AlienFlesh",
		effect = "BloodImpact",
		color = 2
	},
	[MAT_CLIP] = { --//73
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_SNOW] = {--//74
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_PLASTIC] = {--//76
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_METAL] = { --//77
		["strider"] = {
		},
		["metal"] = {
		},
		decal =  "Impact.Metal",
		effect = "MetalSpark"
	},
	[MAT_SAND] = {--//78
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_FOLIAGE] = {--//79
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_COMPUTER] = {--//80
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_SLOSH] = {--//83
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_TILE] = {--//84
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_GRASS] = {--//85
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_VENT] = {--//86
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_WOOD] = {--//87
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_DEFAULT] = {--//88
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_GLASS] = {--//89
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	},
	[MAT_WARPSHIELD] = {--//90
		["antlion"] = {
		},
		decal =  "Impact.Antlion",
		effect = "BloodImpact",
		color = 1
	}
}

SWEP.PrintName = "#Weapon_d"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.SequenceIdle = "gen_short_idle01"
SWEP.SequenceIdleCharged = "gen_short_idle01"
SWEP.SequenceDraw = "gen_short_draw01"
SWEP.SequenceCharge = "gen_short_charge03"
SWEP.SequenceAttackHit = "gen_short_misscenter03"

SWEP.PrimaryMelee = {
	Attack1 = {
		Force = Vector(5000,-10000,5000),
		Effect = "StunstickImpact",
		Damage = 100,
		SequenceCharge = {"gen_short_charge01"},
		SequenceAttack = {"gen_short_misscenter01"}
	},
	Attack2 = {
		Force = Vector(5000,-10000,5000),
		Effect = "StunstickImpact",
		SequenceCharge = {"gen_short_charge02"},
		SequenceAttack = {"gen_short_misscenter02"}
	},
	Attack3 = {
		Force = Vector(5000,-10000,5000),
		Effect = "StunstickImpact",
		SequenceCharge = {"gen_short_charge03"},
		SequenceAttack = {"gen_short_misscenter03"}
	},
	Attack4 = {
		Force = Vector(5000,-10000,5000),
		Effect = "StunstickImpact",
		SequenceCharge = {"gen_short_charge03"},
		SequenceAttack = {"gen_short_misscenter04"}
	}
}

SWEP.RestoreTime = 0.3
SWEP.ChargeTime = 0.2 
SWEP.AttackTime = 0.35
SWEP.ViewModel = "models/weapons/c_generic_187.mdl"
SWEP.WordModel = "models/morrowind/spiked/club/w_spiked_club.mdl"
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

SWEP.Damage 		= 1
SWEP.DamageType 	= DMG_SLASH
SWEP.HitDistance 	= 100

-- SWEP.WorldModel = "models/morrowind/wooden/staff/w_wooden_staff.mdl"
SWEP.ViewModelAngle				= Angle(180,0,180)
SWEP.ViewModelPos				= Vector(-5.5,2,2)
-- SWEP.ViewModelAngle				= Angle(170,6,5.5)
-- SWEP.ViewModelPos				= Vector(-27.7,-12.21,16.3)
SWEP.ViewModelRendergroup		= 10 
SWEP.SwayScale					= 0					-- The scale of the viewmodel sway
SWEP.BobScale					= 0	
SWEP.NextUse 					= 0
SWEP.HoldType 					= "melee"

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "WeaponFrag.Throw" )
local MeleeSpeed = GetConVarNumber( "sv_defaultmeleespeed" )
local Data = {}
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self:SetCanPrimaryAttack(true)
	self:SetIsCharging(false)
	self:SetIsAttacking(false)
end
function SWEP:GetViewModelPosition( pos, ang )
	return pos + ang:Forward() * 0 + ang:Up() * 0, ang
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	local length = tall - 32
	if (self.SpawnIcon == nil) then
		self.SpawnIcon = vgui.Create( "SpawnIcon" )
		self.SpawnIcon:SetWide( length )
		self.SpawnIcon:SetTall( length )
		self.SpawnIcon:SetModel( self.WorldModel ) -- Model we want for this spawn icon
		self.SpawnIcon:Hide()
	end
	self.SpawnIcon:SetPos( x + (wide - length) / 2, y + (tall - length))
	self.SpawnIcon:SetAlpha(alpha)
	self.SpawnIcon:Show()
	timer.Create(self.ClassName.."HideIcon",0,1,function()
		if (self.SpawnIcon != nil) then self.SpawnIcon:Hide() end
	end)
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

function SWEP:PostDrawViewModel( vm, weapon, ply )
	if (ply:GetViewModel(1) != vm) then
		local CsModel = ClientsideModel("models/morrowind/spiked/club/w_spiked_club.mdl", self.ViewModelRendergroup)
		-- if (CsModel:LookupBone( "ValveBiped.Bip01_R_Hand" ) != nil) then
			-- CsModel:SetNoDraw(true)
			-- CsModel:SetParent(vm)
			-- CsModel:SetRenderOrigin( ply:EyePos() )
			-- CsModel:SetRenderAngles( ply:EyeAngles() )
			-- CsModel:AddEffects(EF_BONEMERGE)
		-- else
			local matrix = vm:GetBoneMatrix( 23 )
			local ang = matrix:GetAngles()
			local pos = matrix:GetTranslation()
			ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.p )
			ang:RotateAroundAxis( ang:Right(), self.ViewModelAngle.y )
			ang:RotateAroundAxis( ang:Up(), self.ViewModelAngle.r )
			pos:Add(ang:Forward() * self.ViewModelPos.x)
			pos:Add(ang:Right() * self.ViewModelPos.y)
			pos:Add(ang:Up() * self.ViewModelPos.z)
			CsModel:SetNoDraw(true)
			CsModel:SetRenderOrigin( pos )
			CsModel:SetRenderAngles( ang )
		-- end
		CsModel:SetupBones()
		CsModel:DrawModel()
		CsModel:Remove()		
	end
end

function SWEP:DrawWorldModel()
	local CsModel = ClientsideModel(self.WorldModel, self.ViewModelRendergroup)
		if (CsModel:LookupBone( "ValveBiped.Bip01_R_Hand" ) != nil) then
			CsModel:SetNoDraw(true)
			CsModel:SetParent(self.Owner)
			CsModel:SetRenderOrigin( self.Owner:EyePos() )
			CsModel:SetRenderAngles( self.Owner:EyeAngles() )
			CsModel:AddEffects(EF_BONEMERGE)
		else
			local matrix = self.Owner:GetBoneMatrix( self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" ) )
			local ang = matrix:GetAngles()
			local pos = matrix:GetTranslation()
			ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.p )
			ang:RotateAroundAxis( ang:Right(), self.ViewModelAngle.y )
			ang:RotateAroundAxis( ang:Up(), self.ViewModelAngle.r )
			pos:Add(ang:Forward() * self.ViewModelPos.x)
			pos:Add(ang:Right() * self.ViewModelPos.y)
			pos:Add(ang:Up() * self.ViewModelPos.z)
			CsModel:SetNoDraw(true)
			CsModel:SetRenderOrigin( pos )
			CsModel:SetRenderAngles( ang )
		end
		CsModel:SetupBones()
		CsModel:DrawModel()
		CsModel:Remove()	
end
function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 0, "CanPrimaryAttack" )
	self:NetworkVar( "Float", 0, "AttackTime" )
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
end

function SWEP:SecondaryAttack()
end

function SWEP:DealDamage()
	local vm = self.Owner:GetViewModel()

	-- self.Owner:LagCompensation( true )
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	-- if ( !IsValid( tr.Entity ) ) then
	-- 	tr = util.TraceHull( {
	-- 		start = self.Owner:GetShootPos(),
	-- 		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
	-- 		filter = self.Owner,
	-- 		mins = Vector( -10, -10, -8 ),
	-- 		maxs = Vector( 10, 10, 8 ),
	-- 		mask = MASK_SHOT_HULL
	-- 	} )
	-- end
	local surface = util.GetSurfaceData(tr.SurfaceProps) 
	-- PrintTable(surface)
	local material = MaterialData[tr.MatType]
	if (tr.Hit && material != nil) then
		local decal = material.decal
		local color = material.color || 0
		local effect = material.effect
		if (material[surface.name] != nil) then
			print("ExistetMaterial:", surface.name)
			decal = material[surface.name].decal || decal
			color = material[surface.name].color || color
			effect = material[surface.name].effect || effect
		else
			print("NonExistetMaterial:", tr.MatType, surface.name)
		end
		if (decal != nil) then
			util.Decal(decal, self.Owner:GetShootPos(), tr.HitPos - tr.HitNormal, self.Owner)
		end
		if (effect != nil) then
			local effectdata = EffectData()
			effectdata:SetNormal( tr.HitNormal )
			effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
			effectdata:SetColor(color)
			effectdata:SetScale(5)
			effectdata:SetFlags(3)
			effectdata:SetRadius(1023)
			-- effectdata:SetRadius(1023)
			effectdata:SetMagnitude(1023)
			effectdata:SetSurfaceProp(tr.SurfaceProps)
			-- effectdata:SetMaterialIndex( tr.MatType)
			-- effectdata:SetStart( tr.HitPos + tr.HitNormal)
			util.Effect( effect, effectdata )
		end
	else
		print("NonExistetMaterial:", tr.MatType, surface.name)
	end
	if (!( game.SinglePlayer() && CLIENT ) ) then
		if (tr.Hit) then
			self:EmitSound( HitSound )
			self:EmitSound( util.GetSurfaceData(tr.SurfaceProps).impactHardSound )
		else
			self:EmitSound( SwingSound )
		end
	end
	if (SERVER && IsValid( tr.Entity )) then
		local force = (Data.Force * 1)
		force:Rotate(self.Owner:GetAimVector():Angle())
		if ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0  ) then
			local dmginfo = DamageInfo()
			local attacker = self.Owner
			if ( !IsValid( attacker ) ) then attacker = self end
			dmginfo:SetAttacker( attacker )
			dmginfo:SetInflictor( self )
			dmginfo:SetDamage(Data.Damage || self.Damage || 100 )
			dmginfo:SetDamageType(Data.DamageType || self.DamageType || DMG_GENERIC)
			dmginfo:SetDamageForce( force )
			tr.Entity:TakeDamageInfo( dmginfo )
		elseif (tr.Entity:GetClass()=="prop_ragdoll" ) then
			local bone = tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone)
			if (IsValid(bone)) then
				bone:ApplyForceOffset( force, tr.HitPos )
			end
		else
			local phys = tr.Entity:GetPhysicsObject()
			if ( IsValid( phys ) ) then
				phys:ApplyForceOffset( force, tr.HitPos )
			end
		end
	end
	-- self.Owner:LagCompensation( false )

end
function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end


function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceDraw ) )
	vm:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	return true

end

function SWEP:Think()
	MeleeSpeed = GetConVarNumber( "sv_defaultmeleespeed" )
	if (self.Owner:KeyDown(IN_USE) && self.NextUse < CurTime()) then
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
		if (IsValid(tr.Entity) && tr.Entity:GetClass() == "prop_physics") then
			local classname = "weapon_"..string.match(tr.Entity:GetModel(), "^.*/(.*).mdl$")
			-- if (!self.Owner:HasWeapon( classname )) then
				-- if (weapons.Get( classname ) == nil) then

					local weapon_table = weapons.GetStored( "weapon_d" )
					weapon_table.PrintName = classname
					weapon_table.ViewModel = "models/weapons/c_generic_187.mdl"
					weapon_table.WorldModel = tr.Entity:GetModel()
					weapons.Register( weapon_table, classname)
				-- end
				if (SERVER) then
					self.Owner:Give(classname) 
					tr.Entity:Remove()
				end
			-- end
			print(self.Owner:GetWeapon( classname ))
		end
		self.NextUse = CurTime() + 0.25
	end
	if (self.Owner:KeyDown(IN_RELOAD) && self.NextUse < CurTime() && SERVER) then
		-- ParticleEffect( "ExplosionCore_wall", self.Owner:GetEyeTrace().HitPos, Angle( 0, 0, 0 ) )
		local ent = ents.Create("prop_physics") -- This creates our zombie entity
		ent:SetPos(self.Owner:EyePos()) -- This positions the zombie at the place our trace hit.
		ent:SetAngles(AngleRand()) -- This positions the zombie at the place our trace hit.
		ent:SetOwner(self.Owner)
		ent:SetModel(self.WorldModel)
		ent:Spawn()
		undo.Create( "Remove"..self.ClassName )
		undo.AddEntity( ent )
		undo.SetPlayer( self.Owner )
		undo.Finish()
		ent:GetPhysicsObject():EnableDrag( false )
		ent:GetPhysicsObject():ApplyForceCenter( self.Owner:GetAimVector()*ent:GetPhysicsObject():GetMass()*1000 )
		ent:GetPhysicsObject():AddAngleVelocity( self.Owner:GetAimVector()*500 )
		self.NextUse = CurTime() + 0.25
	end
	if (!( game.SinglePlayer() && CLIENT )) then
		local vm = self.Owner:GetViewModel()
		local curtime = CurTime()
		local idletime = self:GetNextIdle()
		local charging = self:GetIsCharging()
		local attacking = self:GetIsAttacking()
		if ( idletime < curtime && !charging && !attacking) then
			vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceIdle ))
			self:UpdateNextIdle()
		end
		if (self:GetCanPrimaryAttack() && self.Owner:KeyDown(IN_ATTACK)) then
			Data = table.Random(self.PrimaryMelee)
			PrintTable(Data)
			vm:SendViewModelMatchingSequence( vm:LookupSequence( table.Random(Data.SequenceCharge)))
			vm:SetPlaybackRate( MeleeSpeed )
			self:UpdateNextIdle()
			self:SetChargeTime( CurTime() + self.ChargeTime / MeleeSpeed) 
			self:SetIsCharging(true)
			self:SetCanPrimaryAttack(false)
		elseif ( charging && self:GetChargeTime() < curtime && !self.Owner:KeyDown(IN_ATTACK)) then
			self:DealDamage()
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			vm:SendViewModelMatchingSequence( vm:LookupSequence( table.Random(Data.SequenceAttack)))
			vm:SetPlaybackRate( MeleeSpeed )
			self:UpdateNextIdle()
			self:SetAttackTime(curtime + self.AttackTime / MeleeSpeed)
			self:SetIsCharging(false)
			self:SetIsAttacking(true)
		elseif (attacking) then
			if (self:GetAttackTime() < curtime) then
				if (!self:GetCanPrimaryAttack()) then
					vm:SendViewModelMatchingSequence( vm:LookupSequence( self.SequenceDraw ) )
					vm:SetPlaybackRate( MeleeSpeed )
					self:UpdateNextIdle()
					self:SetIsAttacking(false)
					self:SetRestoreTime( curtime + self.RestoreTime / MeleeSpeed)
				end
			elseif (self.Owner:KeyDown(IN_ATTACK)) then
				Data = table.Random(self.PrimaryMelee)
				self:SetChargeTime(self:GetAttackTime())
				self:SetIsCharging(true)
				self:SetIsAttacking(false)
			end
		elseif(!attacking && !charging && !self:GetCanPrimaryAttack() && self:GetRestoreTime() < curtime) then
			self:SetCanPrimaryAttack(true)
		end
	end
end
