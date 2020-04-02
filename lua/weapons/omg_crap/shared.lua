AddCSLuaFile()

SWEP.PrintName		= "CRAP"
SWEP.Category		= "Other"
SWEP.Spawnable		= true
SWEP.ViewModel		= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel		= "models/weapons/w_crowbar.mdl"
SWEP.Primary.Automatic	= true


-- function SWEP:AdjustMouseSensitivity()	end
-- function SWEP:Ammo1()					end
-- function SWEP:Ammo2()					end
-- function SWEP:CalcView()				end
-- function SWEP:CalcViewModelView()		end
-- function SWEP:CanPrimaryAttack()		end
-- function SWEP:CanSecondaryAttack()		end
-- function SWEP:CustomAmmoDisplay()		end
-- function SWEP:Deploy() self:SetWeaponHoldType("shotgun") end
-- function SWEP:DoDrawCrosshair()		return true	end
-- function SWEP:DoImpactEffect()			end
-- function SWEP:DrawHUD()					end
-- function SWEP:DrawHUDBackground()	return false	end
-- function SWEP:DrawWeaponSelection() end
--function SWEP:DrawWorldModel() end
--function SWEP:DrawWorldModelTranslucent() end
-- function SWEP:Equip() end
-- function SWEP:EquipAmmo() end
function SWEP:FireAnimationEvent() return true end
-- function SWEP:FreezeMovement() end
-- function SWEP:GetCapabilities() end
-- function SWEP:GetTracerOrigin() end
-- function SWEP:GetViewModelPosition() end
-- function SWEP:Holster() return true end
-- function SWEP:HUDShouldDraw() return true end
function SWEP:Initialize() self:SetWeaponHoldType("duel") end
-- function SWEP:KeyValue() end
-- function SWEP:OnDrop() end
-- function SWEP:OnReloaded() end
-- function SWEP:OnRemove() end
-- function SWEP:OnRestore() end
-- function SWEP:OwnerChanged() end
-- function SWEP:PreDrawViewModel() end
function SWEP:PrimaryAttack()
if CLIENT then
	--local r = math.sqrt(math.Rand(0,1))
	-- local r = math.Rand(0,1)
	local r = 1
	local sig = math.Rand(0,2 * math.pi)
	-- local x = r * math.cos(sig)
	-- local y = r * math.sin(sig)	
	local x = r * math.cos(-CurTime() * 7)
	local y = r * math.sin(-CurTime() * 7)
	local tr = util.TraceLine( {
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 10000 + self.Owner:EyeAngles():Up() * 500 * y + self.Owner:EyeAngles():Right() * 500 * x,
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
	} )
	//print( tr.HitPos, tr.Entity )
	//local tr = self.Owner:GetEyeTrace()
	local Pos1 = tr.HitPos + tr.HitNormal
	local Pos2 = tr.HitPos - tr.HitNormal
	//print(tr.MatType)
	util.Decal("Impact.Concrete", Pos1, Pos2)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "AR2Impact", effectdata )
	end	
//end
//`self:SetNextPrimaryFire(CurTime() + 0.1) 
end
function SWEP:TranslateMaterial(mattype)
if mattype == 70 then
	return ""
end
end
-- function SWEP:PrintWeaponInfo() end
-- function SWEP:Reload() self:SendWeaponAnim( ACT_VM_PICKUP ) end
--function SWEP:RenderScreen() end
--function SWEP:SecondaryAttack() end
--function SWEP:SetDeploySpeed() end
--function SWEP:SetupDataTables() end
--function SWEP:SetWeaponHoldType() end
-- function SWEP:ShootBullet() end
-- function SWEP:ShootEffects() end
-- function SWEP:ShouldDropOnDie() end
-- function SWEP:TakePrimaryAmmo() end
-- function SWEP:TakeSecondaryAmmo() end
-- function SWEP:Think() end
--function SWEP:TranslateActivity() end
function SWEP:TranslateFOV() end
function SWEP:ViewModelDrawn() end