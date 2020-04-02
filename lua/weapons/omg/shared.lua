AddCSLuaFile()

SWEP.PrintName		= "OMG"
SWEP.Category		= "Other"
SWEP.Spawnable		= true
SWEP.ViewModel		= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel		= "models/weapons/w_shot_m3super90.mdl"
SWEP.Primary.Automatic	= true


function SWEP:AdjustMouseSensitivity()	end
function SWEP:Ammo1()					end
function SWEP:Ammo2()					end
function SWEP:CalcView()				end
function SWEP:CalcViewModelView()		end
function SWEP:CanPrimaryAttack()		end
function SWEP:CanSecondaryAttack()		end
function SWEP:CustomAmmoDisplay()		end
function SWEP:Deploy() self:SendWeaponAnim( ACT_VM_DRAW ) end
function SWEP:DoDrawCrosshair()		return true	end
function SWEP:DoImpactEffect()			end
function SWEP:DrawHUD()					end
function SWEP:DrawHUDBackground()	return false	end
function SWEP:DrawWeaponSelection() end
//function SWEP:DrawWorldModel() end
//function SWEP:DrawWorldModelTranslucent() end
function SWEP:Equip() end
function SWEP:EquipAmmo() end
//function SWEP:FireAnimationEvent() end
function SWEP:FireAnimationEvent( pos, ang, event, options )

	-- we don't want shell casings
	//if( event == 6001 ) then return true; end
	
	-- custom muzzle flash
	//if( event == 21 or event == 22 ) then

		//local effect = EffectData();
		//effect:SetOrigin( pos );
		//effect:SetAngles( ang );
		//effect:SetEntity( self );
		//effect:SetAttachment( 1 );

		//util.Effect( "NomadMuzzle", effect );
		
		return true;
end
function SWEP:FreezeMovement() end
function SWEP:GetCapabilities() end
function SWEP:GetTracerOrigin() end
function SWEP:GetViewModelPosition() end
function SWEP:Holster() return true end
function SWEP:HUDShouldDraw() return true end
function SWEP:Initialize() end
function SWEP:KeyValue() end
function SWEP:OnDrop() end
function SWEP:OnReloaded() end
function SWEP:OnRemove() end
function SWEP:OnRestore() end
function SWEP:OwnerChanged() end
function SWEP:PreDrawViewModel() end
function SWEP:PrimaryAttack() self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) self:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav",75,100,1,CHAN_STATIC) self:ShootBullet(15,5,0.051) self:SetNextPrimaryFire(CurTime() + 0.3) end
function SWEP:PrintWeaponInfo() end
function SWEP:Reload() self:SendWeaponAnim( ACT_VM_PICKUP ) end
//function SWEP:RenderScreen() end
function SWEP:SecondaryAttack() end
function SWEP:SetDeploySpeed() end
function SWEP:SetupDataTables() end
function SWEP:SetWeaponHoldType() end
//function SWEP:ShootBullet() end
function SWEP:ShootEffects() end
function SWEP:ShouldDropOnDie() end
function SWEP:TakePrimaryAmmo() end
function SWEP:TakeSecondaryAmmo() end
function SWEP:Think() end
//function SWEP:TranslateActivity() end
function SWEP:TranslateActivity( act )

	if ( self.Owner:IsNPC() ) then
		if ( self.ActivityTranslateAI[ act ] ) then
			return self.ActivityTranslateAI[ act ]
		end
		return -1
	end

	if ( self.ActivityTranslate[ act ] != nil ) then
		return self.ActivityTranslate[ act ]
	end

	return -1

end
function SWEP:TranslateFOV() end
function SWEP:ViewModelDrawn() end