
AddCSLuaFile()

SWEP.PrintName				= "Manhack Blade"
SWEP.Category				= "HL2 Melee"

SWEP.Slot				= 0
SWEP.SlotPos				= 0

SWEP.Spawnable				= true

SWEP.ViewModel				= Model( "models/weapons/v_models/v_manhack_blade.mdl" )
SWEP.WorldModel				= Model( "models/weapons/v_models/v_manhack_blade.mdl" )
SWEP.ViewModelFOV			= 60
SWEP.UseHands				= true
SWEP.CanAttack				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.DrawAmmo			= false
SWEP.Damage				= 20
SWEP.CanReload			= true

local SwingSound = Sound( "weapons/iceaxe/iceaxe_swing1.wav" )
local HitSoundWorld = Sound( "physics/metal/metal_computer_impact_hard2.wav" )

function SWEP:Initialize()

	self:SetHoldType( "melee" )
end

function SWEP:PrimaryAttack()
print(self.CanAttack)
	if !self.CanAttack then
		self:EmitSound("WeaponFrag.Throw")
		self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "punch" ) )
		self:SetHoldType( "fist" )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		timer.Create("hitdelay2", 0.1, 1, function() self:Hitscan2() end)
		timer.Create("restore", 0.2, 1, function() self:SetHoldType( "normal" ) end)
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.3 )
	else
		self:EmitSound( SwingSound )
		self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "attack" ) )
		//self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "hit" ) )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.6 )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.6 )
		timer.Create("hitdelay", 0.2, 1, function() self:Hitscan() end) 
	end
end

function SWEP:SecondaryAttack()
		if self.CanAttack then
			self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "holster" ) )
			self:SetHoldType( "normal" )
			self.CanAttack = false
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration("holster") )
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration("holster") )
		else
			self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "draw" ) )
			self:SetHoldType( "melee" )
			self.CanAttack = true
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration("draw") )
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration("draw") )	
		end
end


function SWEP:Reload()
	
	if !(self.CanReload) or (!self.CanAttack) then
	return
	end
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound( SwingSound )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "attack" ) )
if SERVER then
	timer.Create("throwdelay", 0.2, 1, function() self:Throw() end)

	timer.Start( "throwdelay" )
end
	
	self.CanReload = false
end

function SWEP:Throw()

	local ent = ents.Create( "thrown_manhack_blade" )

	if ( !IsValid( ent ) ) then return end
	ent:SetPos( self.Owner:EyePos() + Vector(0,0,10) )
	ent:SetOwner( self.Owner )
	ent:SetAngles( self.Owner:EyeAngles() - Angle( -70, -60, 0 ) )
	ent:Spawn()

	local phys = ent:GetPhysicsObject(); 
 
	phys:ApplyForceCenter (self.Owner:GetAimVector() * 7000 )
	phys:AddAngleVelocity(Vector( math.random(-1500, -3000), 0, 0 ))

	self.Owner:StripWeapon("weapon_manhack_blade")

end

function SWEP:Hitscan()
if SERVER then
	local vm = self.Owner:GetViewModel()
	
	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 45 ),
		filter = self.Owner,
		mins = Vector( -5, -5, -5 ),
		maxs = Vector( 5, 5, 5 ),
		mask = MASK_SHOT_HULL
	} )
		local tr2 = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 60 ),
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if tr2.Hit then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "hit" ) )
		if tr2.MatType == 72 or tr2.MatType == 65 or tr2.MatType == 70 or tr2.MatType == 66 then
			self:EmitSound( "physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav" )
		else
			self:EmitSound( HitSoundWorld )
		end
		
		local bullet = {}
		bullet.Num    = 1
		bullet.Src    = self.Owner:EyePos()
		bullet.Dir    = self.Owner:GetAimVector()
		bullet.Spread = Vector(0, 0, 0)
		bullet.Tracer = 0
		bullet.Callback = function( attacker, tr, dmginfo)
		dmginfo:SetDamage( 0 )
		dmginfo:SetDamageForce(Vector(0,0,0))
		end
		self.Owner:FireBullets(bullet)
		
		local dmg = DamageInfo()
		if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			dmg:SetDamageForce(self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989 )
			local ang = tr.Entity:EyeAngles()
			ang.p = 0
			ang = ang:Forward()	
			if ang:DotProduct(self.Owner:EyeAngles():Forward()) >= 0.4 then
				dmg:SetDamage(self.Damage * 3)
			else
				if tr2.HitGroup == 1 then
				dmg:SetDamage(self.Damage * 2)
				else
				dmg:SetDamage(self.Damage)
				end
			end
		else 
		dmg:SetDamageForce(self.Owner:EyeAngles():Forward() * 100 )
		dmg:SetDamage(self.Damage)
		end
		dmg:SetAttacker(self.Owner)
		dmg:SetDamageType(DMG_SLASH)
		dmg:SetInflictor(self)
		tr2.Entity:TakeDamageInfo(dmg)	
	
	elseif tr.Hit then
				vm:SendViewModelMatchingSequence( vm:LookupSequence( "hit" ) )
		if tr.MatType == 72 or tr.MatType == 65 or tr.MatType == 70 or tr.MatType == 66 then
			self:EmitSound( "physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav" )
		else
			self:EmitSound( HitSoundWorld )
		end
				local dmg = DamageInfo()
				dmg:SetDamageType(DMG_SLASH)
					if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
					dmg:SetDamageForce(self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989 )
						local ang = tr.Entity:EyeAngles()
						ang.p = 0
						ang = ang:Forward()	
							if ang:DotProduct(self.Owner:EyeAngles():Forward()) >= 0.4 then
								dmg:SetDamage(self.Damage * 3)
							else
								if tr2.HitGroup == 1 then
								dmg:SetDamage(self.Damage * 2)
								else
								dmg:SetDamage(self.Damage)
								end
							end
					else 
							dmg:SetDamageForce(self.Owner:EyeAngles():Forward() * 100)
							dmg:SetDamage(self.Damage)
					end		
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self)
				tr.Entity:TakeDamageInfo(dmg)
	end	
end
end 

function SWEP:Hitscan2()
if SERVER then
	local vm = self.Owner:GetViewModel()
	
	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 40 ),
		filter = self.Owner,
		mins = Vector( -5, -5, -5 ),
		maxs = Vector( 5, 5, 5 ),
		mask = MASK_SHOT_HULL
	} )
	
	if tr.Hit then
				self:EmitSound( "Flesh.ImpactHard" )
				local dmg = DamageInfo()
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetDamage(math.random( 6, 12 ))
				dmg:SetAttacker(self.Owner)
				dmg:SetInflictor(self)
				if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
					tr.Entity:SetVelocity( self.Owner:GetAimVector() * Vector( 1, 1, 0 ) * 500 )
					dmg:SetDamageForce(self.Owner:GetRight() * 4912 + self.Owner:GetForward() * 9998)
				else
					dmg:SetDamageForce(self.Owner:EyeAngles():Forward() * 100)
				end
				tr.Entity:TakeDamageInfo(dmg)
	end	
end
end 

function SWEP:Deploy()
	if SERVER then
		if self.CanAttack then
			self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "draw" ) )
			self.Weapon:SetNextSecondaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration("draw") )
			self.Weapon:SetNextPrimaryFire( CurTime() + self.Owner:GetViewModel():SequenceDuration("draw") )	
		else
			self.Owner:GetViewModel():SendViewModelMatchingSequence( self.Owner:GetViewModel():LookupSequence( "idle_holstered" ) )
		end
	end
end

function SWEP:Holster()
	timer.Remove("hitdelay")
	timer.Remove("hitdelay2")
	timer.Remove("restore")
		if self.CanAttack then
			self:SetHoldType( "melee" )
		else
			self:SetHoldType( "normal" )
		end
	return true
end

function SWEP:OnRemove()

	timer.Remove("restore")
	timer.Remove("hitdelay")
	timer.Remove("hitdelay2")
	timer.Remove("throwdelay")
		if self.CanAttack then
			self:SetHoldType( "melee" )
		else
			self:SetHoldType( "normal" )
		end
	return true
end