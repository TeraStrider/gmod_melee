AddCSLuaFile()

SWEP.PrintName = "_PROTOTYPE"

SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Spawnable = false
SWEP.ViewModel = "models/weapons/c_generic_187.mdl"

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
SWEP.SwayScale					= 0				-- The scale of the viewmodel sway
SWEP.BobScale					= 0	
-- SWEP.HoldType 					= "melee"
-- SWEP.Collateral					= 3
SWEP.Mins 						= Vector(-5,-5,-5)
SWEP.Maxs						= Vector(5,5,5)
SWEP.FreeAimRange = 5
SWEP.FreeAimSensivity = 0.5
SWEP.WorldModel = "models/morrowind/nordic/axe/w_nordicwaraxe.mdl"

SWEP.DrawWeapon = true
SWEP.WeaponModel = "models/morrowind/nordic/axe/w_nordicwaraxe.mdl"
SWEP.DrawSequence = "gen_short_draw01"


local model
function SWEP:Initialize()
	self:SetHoldType( "melee" )
	self:SetCanPrimaryAttack(true)
	self:SetIsCharging(false)
	self:SetIsAttacking(false)
	self:SetFreeAim(Angle())
	self:SetRecoilAngle(Angle())
	if CLIENT then
		if (self.WeaponModel == nil) then return end
		model = ClientsideModel(self.WeaponModel)
		model:SetParent(self.Owner:GetViewModel())
		model:AddEffects(EF_BONEMERGE)
	end

end

function SWEP:Tick()
local cmd = self.Owner:GetCurrentCommand()
	local x, y = cmd:GetMouseX() * engine.TickInterval() * self.FreeAimSensivity, cmd:GetMouseY() * engine.TickInterval() * self.FreeAimSensivity
	if ( x + y != 0) then
		local freeaim = self:GetFreeAim()
		x = freeaim.y - x 
		y = freeaim.p + y
		if (x * x + y * y > self.FreeAimRange * self.FreeAimRange) then
			local ratio = self.FreeAimRange / math.sqrt(x * x + y * y)
			freeaim.p = y * ratio
			freeaim.y = x * ratio
		else
			freeaim.p = y
			freeaim.y = x
		end
		self:SetFreeAim( freeaim )
	end
end

function SWEP:GetViewModelPosition( pos, ang )
	local freeaim = self:GetFreeAim() + self:GetRecoilAngle()
	freeaim = LerpAngle(self.ViewModelFOV / self.Owner:GetFOV( ),Angle(), freeaim) 
	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis( ang:Up(), freeaim.y)
	ang:RotateAroundAxis( ang:Right(), -freeaim.p )
	return pos, ang
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	if (self.WorldModel == nil or !self.WorldModel) then return false end

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
	if (self.WeaponModel == nil) then return end

	local handle = vm
	local bone = handle:LookupBone( "ValveBiped.Bip01_R_Hand" )
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
	-- model:SetNoDraw(true)
	-- model:SetupBones()
	-- model:SetRenderOrigin( pos )
	-- model:SetRenderAngles( ang )
	-- model:SetPos( pos )
	-- model:SetAngles( ang )
	-- model:SetNotSolid( true )
	-- model:DrawShadow( true )
	-- model:DrawModel()
end

function SWEP:DrawWorldModel(vm)
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
	self:NetworkVar( "Angle", 0, "FreeAim" )
	self:NetworkVar( "Angle", 1, "RecoilAngle" )
	
end

function SWEP:PrimaryAttack()
end
function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	if (!self.DrawSequence) then return end
	local speed = GetConVarNumber( "sv_defaultdeployspeed" )
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( self.DrawSequence ) )
	vm:SetPlaybackRate( speed )
end

function SWEP:Throw()
end

function SWEP:Pickup()
end

function SWEP:OnRemove()

end
function SWEP:Think()
	
end
