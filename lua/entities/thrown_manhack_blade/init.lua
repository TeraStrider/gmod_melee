
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/v_models/v_manhack_blade.mdl") 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Use(activator, caller)
if self.CanPickup then
activator:Give("weapon_manhack_blade")
activator:SelectWeapon("weapon_manhack_blade")
self:Remove()
end
	return false
end

function ENT:OnRemove()
	return false
end 

local vel, len, pos, owner

function ENT:PhysicsCollide(data, physobj)
		vel = physobj:GetVelocity()
		len = vel:Length()
		if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() then
			if self.CanDamage then
				self:EmitSound( "physics/flesh/flesh_impact_bullet" .. math.random(1, 5) .. ".wav" )
				local dmg = DamageInfo()
				dmg:SetDamage(15)
				dmg:SetAttacker(self)
				dmg:SetDamageType(DMG_SLASH)
				dmg:SetInflictor(self)
				data.HitEntity:TakeDamageInfo(dmg)
			end
		end
self.CanDamage = false
self:SetOwner( NULL )
end 

function ENT:Think()
	len = self:GetPhysicsObject():GetVelocity():Length()
		if len > 500 then
			self.CanPickup = false
		else
			self.CanPickup = true
		end
		print(len)
end
