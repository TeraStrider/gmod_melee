CreateConVar("sv_melee_speed", 1, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop weight",0)
CreateConVar("sv_melee_force_multiplier", 1024, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop weight",0)
CreateConVar("sv_melee_torque_multiplier", 1024, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop weight",0)
CreateConVar("sv_pickup_max_weight", 32, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop weight",0)
CreateConVar("sv_pickup_max_volume", 1024, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop volume",0)
CreateConVar("sv_pickup_max_aabb", -1, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop volume")
CreateConVar("sv_pickup_max_radius", -1, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Set max prop volume",0)
CreateConVar("sv_pickup_allow", 0, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Allow players to pickup props and weaponize them?")
CreateConVar("sv_pickup_allow_props", 1, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Allow players to pickup props and weaponize them?")
CreateConVar("sv_pickup_allow_npcs", 0, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Allow players to pickup props and weaponize them?")
CreateConVar("sv_pickup_allow_entities", 0, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Allow players to pickup props and weaponize them?")
CreateConVar("sv_pickup_allow_ragdolls", 0, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Allow players to pickup props and weaponize them?")
CreateConVar("sv_pickup_allow_brushes", 0, FCVAR_LUA_SERVER + FCVAR_REPLICATED, "Allow players to pickup props and weaponize them?")
hook.Add( "AllowPlayerPickup", "Prevent From Picking", function(ply, ent)
	local allow = GetConVar( "sv_pickup_allow" )
	if (allow:GetBool()) then return false end
end )
if SERVER then
	util.AddNetworkString( "RegisterWeapon" )
end
if CLIENT then
	net.Receive( "RegisterWeapon", function()
		local weapon_table = net.ReadTable()
		local classname = net.ReadString()
		print(classname)
		weapons.Register( weapon_table, classname)
	end )
end
hook.Add( "PreDrawHalos", "AddPropHalos", function()
	local entities = ents.GetAll()
	-- halo.Add( ents.FindByClass( "prop_physics*" ), Color( 0, 255, 0 ), 1, 1, 5,true,true )
end )
hook.Add( "KeyPress", "MeleePickupProp", function( ply, key )
	if ( key == IN_USE) then
		if CLIENT then return end
		if (!GetConVar( "sv_pickup_allow" ):GetBool()) then return end
		local tr = util.TraceLine( {
			start = ply:GetShootPos(),
			endpos =  ply:GetShootPos() + ply:GetAimVector() * 96,
			filter = ply,
			mask = MASK_SHOT_HULL
		} )
		if (!IsValid(tr.Entity)) then
			tr = util.TraceHull( {
			start = ply:GetShootPos(),
			endpos =  ply:GetShootPos() + ply:GetAimVector() * 96,
			filter = ply,
			mins = Vector(-5,-5,-5),
			maxs = Vector(5,5,5),
			mask = MASK_SHOT_HULL
		} )
		end
		print(tr.Entity)
		if (!IsValid(tr.Entity) or tr.Entity:IsPlayerHolding()) then return end
		local modelname = tr.Entity:GetModel()
		modelname = string.match(modelname, "^.*/(.*).mdl$")
		local classname
		local printname
		local entityclass = tr.Entity:GetClass()
		if (!util.IsValidModel(tr.Entity:GetModel())) then
			if (!GetConVar( "sv_pickup_allow_brushes" ):GetBool()) then return end
			classname = "melee_"..tr.Entity:GetModel()
			printname = "BRUSH "..tr.Entity:GetModel()
			entityclass = "prop_physics"
		elseif (tr.Entity:IsNPC()) then
			if (!GetConVar( "sv_pickup_allow_npcs" ):GetBool()) then return end
			classname = "melee_"..modelname
			printname = "NPC "..modelname
		elseif (tr.Entity:IsPlayer()) then
			return
		elseif (tr.Entity:IsScripted()) then
			if (!GetConVar( "sv_pickup_allow_entities" ):GetBool()) then return end
			classname = "melee_"..modelname
			printname = "ENTITY "..modelname
		elseif (tr.Entity:IsRagdoll()) then
			if (!GetConVar( "sv_pickup_allow_ragdolls" ):GetBool()) then return end
			classname = "melee_"..modelname
			printname = "RAGDOLL "..modelname
		elseif (tr.Entity:IsSolid()) then
			if (!GetConVar( "sv_pickup_allow_props" ):GetBool()) then return end
			classname = "weapon_"..modelname
			printname = "PROP "..modelname
			entityclass = "prop_physics"
		end
		if (!classname) then return end
		-- if (ply:HasWeapon( classname )) then return end
		local surface = util.GetSurfaceData(tr.SurfaceProps)
		local phys = tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone)
		local hitsound
		local breaksound
		local hitdecal
		local hiteffect
		local hitcolor
		local damage = 0
		if (IsValid(phys)) then
			if (surface) then

				PrintTable(surface)
				hitsound = surface.impactHardSound or surface.impactSoftSound
				breaksound = surface.BreakSound
				if (surface.name == "flesh" or surface.name == "armorflesh" or surface.name == "bloodyflesh" or surface.name == "zombieflesh") then
					hitcolor = 0
					hitdecal = "Blood"
					hiteffect = "BloodImpact"
				elseif (surface.name == "antlion") then
					hitcolor = 2
					hitdecal = "YellowBlood"
					hiteffect = "Blood"
				elseif (surface.name == "alienflesh") then
					hitcolor = 1
					hitdecal = "YellowBlood"
					hiteffect = "Blood"
				elseif (surface.name == "paintcan") then
					hitcolor = 1
					hitdecal = "PaintSplatBlue"
					hiteffect = "Blood"
				end
				-- damage = surface.density * phys:GetVolume() / 100000
				-- damage = damage < phys:GetMass() and damage or phys:GetMass()
			-- else
				-- damage = phys:GetMass()
			end
			damage = phys:GetMass()
		end
		-- if (weapons.Get( classname ) == nil) then
			local weapon_table = {
				PrintName = printname,
				EntityClass = entityclass,
				ForceMultiplier = damage,
				HitSound = hitsound,
				HitDecal = hitdecal,
				HitColor = hitcolor,
				HitEffect = hiteffect,
				BreakSound = breaksound,
				Damage = damage + 15,
				Instructions =  "entityclass: "..entityclass.."\n".."damage: "..damage + 15,
				HitDistance = 32 + tr.Entity:GetModelRadius(),
				WorldModel = tr.Entity:GetModel(),
				Base = "weapon_prop",
			}
			weapons.Register( weapon_table, classname)
			net.Start( "RegisterWeapon" )
				net.WriteTable( weapon_table )
				net.WriteString( classname )
			net.Broadcast()
		-- end
		ply:Give(classname)
		ply:SelectWeapon( classname )
		ply:GetWeapon(classname):Deploy()
		if (tr.Entity:IsPlayer()) then
			tr.Entity:KillSilent()
		else
			tr.Entity:Remove()
		end
	end
end )


-- list.Set( "PlayerOptionsModel", "m_anm", "models/m_anm.mdl" )
-- player_manager.AddValidModel( "m_anm", "models/m_anm.mdl" )
-- player_manager.AddValidHands( "m_anm", "models/weapons/c_arms.mdl", 0, "0" )