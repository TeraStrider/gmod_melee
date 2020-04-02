AddCSLuaFile("autorun/freeaimbase_shared.lua")

CreateConVar( "sk_freeaim_radius", "5", 8196, "set freeaim radius" )
CreateConVar( "sk_freeaim_speed", "0.3", 8196, "set freeaim radius" )

TranslateMaterial = {}
TranslateMaterial[72] = "Impact.Antlion"
TranslateMaterial[65] = "Impact.Antlion"
TranslateMaterial[66] = "Impact.BloodyFlesh"
TranslateMaterial[73] = "model"
TranslateMaterial[80] = "Impact.Concrete"
TranslateMaterial[67] = "Impact.Concrete"
TranslateMaterial[68] = "Impact.Concrete"
TranslateMaterial[69] = "Impact.Concrete"
TranslateMaterial[70] = "Impact.Flesh"
TranslateMaterial[79] = "Impact.Sand"
TranslateMaterial[89] = "Impact.Glass"
TranslateMaterial[71] = "Impact.Metal"
TranslateMaterial[74] = "Impact.Sand"
TranslateMaterial[77] = "Impact.Metal"
TranslateMaterial[76] = "Impact.Metal"
TranslateMaterial[78] = "Impact.Sand"
TranslateMaterial[83] = "Impact.Sand"
TranslateMaterial[84] = "Impact.Concrete"
TranslateMaterial[85] = "Impact.Concrete"
TranslateMaterial[86] = "Impact.Metal"
TranslateMaterial[87] = "Impact.Wood"
TranslateMaterial[88] = "Impact.Concrete"
TranslateMaterial[90] = "Impact.Concrete"
TranslateMaterial[45] = "Impact.Concrete"

if SERVER then
	util.AddNetworkString("g_freeaimang_cur")
	util.AddNetworkString("freeaimbase_client_dmg")
	util.AddNetworkString("setanim")
	util.AddNetworkString("setanim_echo")
	util.AddNetworkString("receive_test")
	net.Receive("receive_test",function(len,ply)
		local ent_table = net.ReadTable()
		if IsValid(ply) && ply:Alive() then
			local dmginfo 		= DamageInfo()
			for ent, dmg in pairs( ent_table ) do
				if ent:IsValid() then
					dmginfo:SetInflictor(ply)
					dmginfo:SetAttacker(ply)
					dmginfo:SetDamage(dmg[0])
					dmginfo:SetDamageType(DMG_BULLET)
					if !ent:IsNPC() && !ent:IsPlayer() && ent:GetPhysicsObject() then
						ent:GetPhysicsObjectNum(dmg[1]):ApplyForceOffset( Vector(dmg[2][1],dmg[2][2],dmg[2][3]), Vector(dmg[3][1],dmg[3][2],dmg[3][3]) )
					else
						dmginfo:SetDamageForce(Vector(dmg[2][1],dmg[2][2],dmg[2][3]))
						dmginfo:SetDamagePosition(Vector(dmg[3][1],dmg[3][2],dmg[3][3]))
					end
					ent:TakeDamageInfo(dmginfo)
				end
			end
		end
	end) 
	net.Receive("g_freeaimang_cur",function(len,ply)
		ply:GetActiveWeapon().CurDir = net.ReadAngle()
	end)
	net.Receive("setanim",function(len,ply)
		print("work")
		ply:GetActiveWeapon():SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		net.Start("setanim_echo")	
		net.Send(ply)
	end) 
	net.Receive("freeaimbase_client_dmg",function(len,ply)
	local entity 		= net.ReadEntity()
	local inflictor 	= net.ReadEntity()
	local damage 		= net.ReadFloat()
	local damagetype 	= net.ReadString()
	local force			= net.ReadTable()
	local force_pos		= net.ReadTable()
	local dmginfo 		= DamageInfo()
	if IsValid(entity) && IsValid(ply) && ply:Alive() then
		dmginfo:SetAttacker(ply)
		if IsValid(inflictor) then
			dmginfo:SetInflictor(inflictor)
		end
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageType(damagetype)
		dmginfo:SetDamageForce(Vector(force[1],force[2],force[3]))
		dmginfo:SetDamagePosition(Vector(force_pos[1],force_pos[2],force_pos[3]))
		entity:TakeDamageInfo(dmginfo)	
		entity:TakePhysicsDamage( dmginfo )
	end
end)  
end

if CLIENT then
	net.Receive("setanim_echo",function(len)
		print("cuck")
		LocalPlayer():GetActiveWeapon():SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end) 
end