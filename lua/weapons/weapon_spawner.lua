AddCSLuaFile()

SWEP.PrintName = "WeaponSpawner"
SWEP.Base = "weapon_melee"
SWEP.Spawnable = true

function SWEP:PostDrawViewModel( vm, weapon, ply )
	if (self.WorldModel != nil and ply:GetViewModel(1) != vm) then
		local model = ClientsideModel(self.WorldModel)
		local mins, maxs = model:GetModelBounds()
		local bone = vm:LookupBone( "ValveBiped.Bip01_R_Hand" )
		local matrix = vm:GetBoneMatrix( bone )
		local ang = matrix:GetAngles()
		local pos = matrix:GetTranslation()
		model:SetNoDraw(true)
		ang:RotateAroundAxis( ang:Forward(), 180 )
		ang:RotateAroundAxis( ang:Up(), 180 )
		pos:Add(ang:Forward() * -3)
		pos:Add(ang:Right() * 1)
		if self.ModelRadius then
			model:SetModelScale( 4 / self.ModelRadius )
			pos:Add(ang:Up() * -(4 * mins.z / self.ModelRadius))
		end
		model:SetRenderOrigin( pos )
		model:SetRenderAngles( ang )
		model:SetupBones()
		model:DrawModel()
		model:Remove()	
	end
end

function SWEP:Pickup()
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )
	if ( !IsValid(tr.Entity) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ), 	
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end
	if ( tr.Hit ) then
		-- PrintTable(util.GetModelInfo( tr.Entity:GetModel() ))
		-- PrintTable(util.GetSurfaceData(tr.SurfaceProps))
		local classname
		if (util.IsValidModel(tr.Entity:GetModel())) then
			classname = "spawn_"..string.match(tr.Entity:GetModel(), "^.*/(.*).mdl$")
		else
			classname = "spawn_"..tr.Entity:GetModel()
		end
		if (!self.Owner:HasWeapon( classname )) then
			if (weapons.Get( classname ) == nil && !tr.Entity:IsWorld()) then
				local weapon_table = {
					PrintName = classname,
					EntityClass = tr.Entity:GetClass(),
					ModelRadius = tr.Entity:GetModelRadius(),
					EntityTable = tr.Entity:GetTable(),
					WorldModel = tr.Entity:GetModel(),
					Base = "weapon_spawner",
				}
				weapons.Register( weapon_table, classname)
			end
			if (SERVER) then
				self.Owner:Give(classname) 
				tr.Entity:Remove()
			end
		end
	end
end

function SWEP:Throw()
	if (CLIENT) then return end
	if (self.EntityClass != nil) then
		local ent = ents.Create(self.EntityClass) -- This creates our zombie entity
		ent:SetModel(self.WorldModel)
		if self.EntityTable then ent:SetTable(self.EntityTable) end
		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 128,
			filter = self.Owner,
			mask = MASK_SHOT_HULL
		} )
		if tr.Hit then
			local mins, maxs = ent:GetModelBounds()
			ent:SetPos(tr.HitPos - Vector(0,0,mins.z))
			ent:SetPos(self.Owner:EyePos() * self.Owner:GetAimVector() * 128) -- This positions the zombie at the place our trace hit.
			ent:Spawn()
			ent:Activate()
			undo.Create( self.ClassName )
			undo.AddEntity( ent )
			undo.SetPlayer( self.Owner )
			undo.Finish()
			self:Remove()
		end
	end
end
