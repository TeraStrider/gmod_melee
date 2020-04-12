
-- Variables that are used on both client and server

SWEP.PrintName		= "Scripted Weapon 2" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= 8			-- Size of a clip
SWEP.Primary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Secondary.ClipSize		= 8			-- Size of a clip
SWEP.Secondary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Secondary.Automatic	=false		-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "Pistol"

function SWEP:Initialize()

	self:SetHoldType( "pistol" )

end
local savetable = nil
local entity = nil
function SWEP:PrimaryAttack()
	if (!savetable) then return end
	if (!entity) then return end
	local button = ents.Create( entity )
	if ( !IsValid( button ) ) then return end
	print(button:EntIndex())
	button:Spawn()
	
	for k, v in pairs( savetable ) do
		//if (!istable(v) && k != "hammerid") then
			print(k)
			button:SetSaveValue(k, v)
		//end
	end
	undo.Create("created")
	undo.AddEntity(button)
	undo.SetPlayer(self.Owner)
	undo.Finish()
	//button:SetPos(tr.HitPos)

end
function SWEP:SecondaryAttack()
	local tr = util.TraceLine({
	start = self.Owner:EyePos(),
	endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 10000,
	filter = self.Owner
	})
	if (!tr.Entity) then return end
	savetable = tr.Entity:GetSaveTable(false)
	entity = tr.Entity:GetClass()
	PrintTable(savetable)
	if (tr.Entity == Entity(0)) then
		savetable = nil
	else
		tr.Entity:Remove()
	end
end
function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
end
function SWEP:Think()
end
function SWEP:Holster( wep )
	return true
end
function SWEP:Deploy()
	return true
end
