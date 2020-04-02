SWEP.PrintName				= "hah2"
SWEP.Category				= "HL2 Melee"
SWEP.ViewModel 				= "models/weapons/v_models/v_hand.mdl"
SWEP.WorldModel				= ""
SWEP.UseHands 				= false
SWEP.DrawCrosshair 			= true
SWEP.BobScale 				= 0
SWEP.SwayScale 				= 0
SWEP.Spawnable				= true
SWEP.Secondary.Automatic	= true
SWEP.Primary.Automatic		= true
SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip1 		= true
SWEP.MinHoldTime 			= 0.05
SWEP.NextPunchTime 			= 0.3
SWEP.PunchTime 				= 0.2
SWEP.SizeLimit 				= 5
SWEP.ComboHoldTime 			= 0.03
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "StartHoldingTime" )
	self:NetworkVar( "Int", 0, "CurMove" )
	self:NetworkVar( "String", 0, "ClientSideModelName" )
	self:NetworkVar( "Vector", 0, "PropMins" )
	self:NetworkVar( "Float", 1, "HoldingTime" )
	self:NetworkVar( "Int", 1, "Combo" )
	self:NetworkVar( "Bool", 1, "HoldingProp" )
	self:NetworkVar( "Vector", 1, "PropMaxs" )
	self:NetworkVar( "Float", 2, "NextStep" )
	self:NetworkVar( "Bool", 2, "RightReleasing" )
	self:NetworkVar( "Vector", 2, "CenterMass" )
	self:NetworkVar( "Bool", 3, "LeftReleasing" )
	self:NetworkVar( "Float", 3, "PropMass" )
	self:NetworkVar( "Bool", 4, "RightBusy" )
	self:NetworkVar( "Bool", 5, "LeftBusy" )
	self:NetworkVar( "Float", 5, "NextUse" )
	self:NetworkVar( "Bool", 6, "RightPulling" )
	self:NetworkVar( "Bool", 7, "LeftPulling" )
	self:NetworkVar( "Bool", 8, "Holstered" )
end

function SWEP:Holster()
	local viewmodel1 = self.Owner:GetViewModel( 1 )
	if ( IsValid( viewmodel1 ) ) then
		viewmodel1:SetWeaponModel( self.ViewModel , nil)
	end
	return true
end

function SWEP:OnDrop()
if CLIENT then
	self.csmodel:Remove()
end
	self:Remove()	-- You can't drop fists
end

function SWEP:Initialize()
	self:SetHoldType( "fist" )
	self:SetCurMove(1)
end

function SWEP:PostDrawViewModel( vm, weapon, ply )
	if (vm == ply:GetViewModel(1)) then
		return
	end
	if IsValid((ply:GetActiveWeapon()).csmodel) then
		local boneid = ply:GetViewModel(0):LookupBone( "ValveBiped.Bip01_R_Hand" )
		if not boneid then
			return
		end
		local matrix = self.Owner:GetViewModel( 0 ):GetBoneMatrix( boneid )
		if not matrix then
			return
		end
		local ang = matrix:GetAngles()
		local pos = matrix:GetTranslation()
		local mins,maxs = self.csmodel:GetModelBounds()
		local masscenter = self:GetCenterMass()
		if (HL2_MELEE[self:GetClientSideModelName()]) != nil then
			pos = pos + ang:Forward()*(HL2_MELEE[self:GetClientSideModelName()]["pos"]).x +ang:Right()*(HL2_MELEE[self:GetClientSideModelName()]["pos"]).y + ang:Up()*(HL2_MELEE[self:GetClientSideModelName()]["pos"]).z
			ang:RotateAroundAxis( ang:Forward(), (HL2_MELEE[self:GetClientSideModelName()]["ang"]).p )
			ang:RotateAroundAxis( ang:Right(), (HL2_MELEE[self:GetClientSideModelName()]["ang"]).y )
			ang:RotateAroundAxis( ang:Up(), (HL2_MELEE[self:GetClientSideModelName()]["ang"]).r )
		else
			if (maxs.x - mins.x) >= (maxs.y - mins.y ) && (maxs.x - mins.x) >= (maxs.z - mins.z ) then
				pos = pos + ang:Forward()*((mins.y + maxs.y)/2) +ang:Right()*-((mins.z + maxs.z)/2) + ang:Up()*-((mins.x + maxs.x)/2) --[[ + ang:Up()*-((maxs.x - mins.x)/3) ]]
				pos = pos + ang:Forward() * 3
				pos = pos + ang:Right() * 1
				ang:RotateAroundAxis( ang:Forward(), 90 )
				ang:RotateAroundAxis( ang:Up(), 90 )

			elseif (maxs.y - mins.y) >= (maxs.x - mins.x ) && (maxs.y - mins.y) >= (maxs.z - mins.z ) then
	
				pos = pos + ang:Forward()*-((mins.x + maxs.x)/2) +ang:Right()*-((mins.y + maxs.y)/2) + ang:Up()*-((mins.x + maxs.z)/2)
				pos = pos + ang:Forward() * 3
				pos = pos + ang:Right() * 1
				ang:RotateAroundAxis( ang:Right(), -90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
			elseif (maxs.z - mins.z) >= (maxs.x - mins.x ) && (maxs.z - mins.z) >= (maxs.y - mins.y ) then
				if (masscenter.z >= (maxs.z+mins.z)/2) then
					ang:RotateAroundAxis( ang:Forward(), 180 )
				else
					pos = pos + ang:Up()*((masscenter.z))
					//pos = pos + ang:Forward() * 3
					//pos = pos + ang:Right() * 1
				end
				if (maxs.x-mins.x > maxs.y-mins.y) then
					if (masscenter.x > (maxs.x + mins.x)/2) then
						ang:RotateAroundAxis( ang:Up(), 180 )
					end
				else
					if (masscenter.y > (maxs.y+mins.y)/2) then
						ang:RotateAroundAxis( ang:Up(), 90 )
						pos = pos + ang:Forward()*-((masscenter.x)) + ang:Right()*(masscenter.y)
						pos = pos + ang:Forward() * -3
						pos = pos + ang:Right() * 1
					else
						ang:RotateAroundAxis( ang:Up(), -90 )
					end
				end
				
			end
		end
			self.csmodel:SetPos(pos)
			self.csmodel:SetAngles(ang)
			self.csmodel:SetRenderOrigin( pos)
			self.csmodel:SetRenderAngles( ang )
			self.csmodel:SetupBones()
			self.csmodel:DrawModel()
	end
end


function SWEP:DrawWorldModel()
	print(IsValid(self.csmodel))
	if !IsValid(self.csmodel) then
		return
	end
	local boneid = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" )

	if not boneid then
		return
	end

	local matrix = self.Owner:GetBoneMatrix( boneid )

	if not matrix then
		return
	end
	local ang = matrix:GetAngles()
	local pos = matrix:GetTranslation()
	local mins,maxs = self.csmodel:GetModelBounds()

		if (HL2_MELEE[self:GetClientSideModelName()]) != nil then
			pos = pos + ang:Forward()*(HL2_MELEE[self:GetClientSideModelName()]["pos"]).x +ang:Right()*(HL2_MELEE[self:GetClientSideModelName()]["pos"]).y + ang:Up()*(HL2_MELEE[self:GetClientSideModelName()]["pos"]).z
			ang:RotateAroundAxis( ang:Forward(), (HL2_MELEE[self:GetClientSideModelName()]["ang"]).p )
			ang:RotateAroundAxis( ang:Right(), (HL2_MELEE[self:GetClientSideModelName()]["ang"]).y )
			ang:RotateAroundAxis( ang:Up(), (HL2_MELEE[self:GetClientSideModelName()]["ang"]).r )
		else
			if (maxs.x - mins.x) >= (maxs.y - mins.y ) && (maxs.x - mins.x) >= (maxs.z - mins.z ) then
				pos = pos + ang:Forward()*((mins.y + maxs.y)/2) +ang:Right()*-((mins.z + maxs.z)/2) + ang:Up()*-((mins.x + maxs.x)/2)
				pos = pos + ang:Forward() * 3
				pos = pos + ang:Right() * 1
				ang:RotateAroundAxis( ang:Forward(), 90 )
				ang:RotateAroundAxis( ang:Up(), 90 )

			elseif (maxs.y - mins.y) >= (maxs.x - mins.x ) && (maxs.y - mins.y) >= (maxs.z - mins.z ) then
				pos = pos + ang:Forward()*-((mins.x + maxs.x)/2) +ang:Right()*-((mins.y + maxs.y)/2) + ang:Up()*-((mins.x + maxs.z)/2)
				pos = pos + ang:Forward() * 3
				pos = pos + ang:Right() * 1
				ang:RotateAroundAxis( ang:Right(), -90 )
				ang:RotateAroundAxis( ang:Up(), -90 )
			elseif (maxs.z - mins.z) >= (maxs.x - mins.x ) && (maxs.z - mins.z) >= (maxs.y - mins.y ) then
				pos = pos + ang:Forward()*-((mins.x + maxs.x)/2) +ang:Right()*-((mins.y + maxs.y)/2) + ang:Up()*((mins.z + maxs.z)/2)
				ang:RotateAroundAxis( ang:Forward(), 180 )
				pos = pos + ang:Forward() * 3
				pos = pos + ang:Right() * -1
			end
		end

	self.csmodel:SetPos( pos )
	self.csmodel:SetAngles( ang)
	self.csmodel:SetRenderOrigin( pos )
	self.csmodel:SetRenderAngles( ang )
	self.csmodel:SetupBones()
	self.csmodel:DrawModel()
 end

function SWEP:Think()
	
	if self:GetHolstered() && !(self:GetNextStep() <= CurTime()) then
		return true
	else
		self:SetHolstered(false)
	end
	
	if self.Owner:KeyDown( IN_RELOAD ) && !self:GetLeftPulling() && !self:GetRightPulling() && !self:GetLeftReleasing() && !self:GetRightReleasing() && (self.Owner:KeyDown( IN_ATTACK2 ) || self.Owner:KeyDown( IN_ATTACK )) then
		if self.Owner:KeyDown( IN_ATTACK2 )  && !self:GetHoldingProp() then
			self:SetRightBusy(true)
			self:SetCurSequence(0,"idle_middlefinger")
		end		
		if self.Owner:KeyDown( IN_ATTACK ) then
			self:SetLeftBusy(true)
			self:SetCurSequence(1,"idle_middlefinger") 
		end  
		
	
	end
	
	if self.Owner:KeyDown( IN_USE ) && !self.Owner:KeyDown( IN_RELOAD ) && CurTime() >= self:GetNextUse() && !self:GetLeftPulling() && !self:GetRightPulling() && !self:GetRightReleasing() && !self:GetLeftReleasing() then
		self:SetNextUse(CurTime() + 0.2)
		if !self:GetHoldingProp() then
			local tr = util.TraceLine( {
					start = self.Owner:EyePos(),
					endpos = self.Owner:EyePos() + (self.Owner:EyeAngles()):Forward() * 100,
					filter = self.Owner,
			} ) 
			if tr.Hit then
				if IsValid(tr.Entity) then
					if tr.Entity:GetClass() == "prop_physics" then
						local mins,maxs = tr.Entity:GetModelBounds()
						local phys = tr.Entity:GetPhysicsObject()
						if ( IsValid( phys ) ) then
							if (maxs.x - mins.x) >= (maxs.y - mins.y ) && (maxs.x - mins.x) >= (maxs.z - mins.z ) then
								print("longest on x")
							elseif (maxs.y - mins.y) >= (maxs.x - mins.x ) && (maxs.y - mins.y) >= (maxs.z - mins.z ) then
								print("longest on y")
							elseif (maxs.z - mins.z) >= (maxs.x - mins.x ) && (maxs.z - mins.z) >= (maxs.y - mins.y ) then
								print("longest on z")
							end
							self:SetPropMass(phys:GetMass())
							self:SetCenterMass(phys:GetMassCenter())
							print("mass",self:GetPropMass())
							print("size ",(maxs.x + maxs.y + maxs.z - mins.x - mins.y - mins.z))
							print("ModelCenter ",(maxs+mins)/2)
							print("ModelSize ",(maxs-mins))
							print("MassCenter ",phys:GetMassCenter())
						end
						if !(GetConVarNumber( "sv_allowpickupsizelimit" ) >= (maxs.x + maxs.y + maxs.z - mins.x - mins.y - mins.z)) then
							return
						end		
						if !(GetConVarNumber( "sv_allowpickupmasslimit" ) >= self:GetPropMass()) then
							return
						end
						self:SetClientSideModelName(tr.Entity:GetModel())
						self:SetPropMins(mins)
						self:SetPropMaxs(maxs)
						tr.Entity:Remove()
						self:SetHoldingProp(true)
						self:SetRightBusy(false)
						if ((maxs.x + maxs.y + maxs.z - mins.x - mins.y - mins.z) >= 60) then
							self:SetHoldType("melee2")
						else
							self:SetHoldType("melee")
						end
					end
				end
			end
		else
			if SERVER then
				local boneid = self.Owner:GetViewModel( 0 ):LookupBone( "ValveBiped.Bip01_R_Hand" )
				if not boneid then
					return
				end
				
				local matrix = self.Owner:GetViewModel( 0 ):GetBoneMatrix( boneid )
				if not matrix then
					return
				end
				local ang = matrix:GetAngles()
				local pos = matrix:GetTranslation()
				local tr = util.TraceLine( {
					start = self.Owner:EyePos(),
					endpos = self.Owner:EyePos() + (self.Owner:EyeAngles()):Forward() * 100,
					filter = self.Owner,
				} )
				local barrel = ents.Create("prop_physics")
				barrel:SetModel(self:GetClientSideModelName())
				print(tr.HitNormal)
				if tr.Hit then
					if tr.HitNormal.z < 0 then
						barrel:SetPos(tr.HitPos - Vector(0,0,self:GetPropMaxs().z))
					else
						barrel:SetPos(tr.HitPos - Vector(0,0,self:GetPropMins().z))
					end
				else
					barrel:SetPos(self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 100 - Vector(0,0,self:GetPropMins().z)) 
				end
				//barrel:SetOwner(self.Owner)
				barrel:SetAngles(Angle(0,self.Owner:EyeAngles().y + 180 + tr.HitNormal.y,0))
				//barrel:SetAngles( tr.HitNormal)
				barrel:Spawn()
				undo.Create("prop")
					undo.AddEntity(barrel)
					undo.SetPlayer(self.Owner)
				undo.Finish()
				self:SetHoldingProp(false)
				self:SetHoldType("fist")
			end
		end
	end
	
	if !self.Owner:KeyDown( IN_RELOAD ) && (self.Owner:KeyDown( IN_ATTACK2 ) || self.Owner:KeyDown( IN_ATTACK )) && !self:GetLeftPulling() && !self:GetRightPulling() && !self:GetLeftReleasing() && !self:GetRightReleasing() && self:GetNextStep() <= CurTime() then
		if self.Owner:KeyDown( IN_ATTACK ) then
			self:SetLeftBusy(false)
			self:SetLeftPulling(true)
		elseif self.Owner:KeyDown( IN_ATTACK2 ) then
			self:SetRightBusy(false)
			self:SetRightPulling(true)
		end
		self:SetStartHoldingTime(CurTime())
	end	
	
	if ((self.Owner:KeyReleased(IN_ATTACK) && self:GetLeftPulling()) || (self.Owner:KeyReleased(IN_ATTACK2) && self:GetRightPulling())) && !self:GetLeftReleasing() && !self:GetRightReleasing() then
			self:SetNextStep(CurTime() + self.PunchTime)
			self:SetHoldingTime(CurTime() - self:GetStartHoldingTime())
			if !(self:GetHoldingTime() <= self.MinHoldTime) then
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				if self:GetRightPulling() then
					self:SetRightReleasing(true)
					self:SetRightPulling(false)
				end
				
				if self:GetLeftPulling() then
					self:SetLeftReleasing(true)
					self:SetLeftPulling(false)
				end
			else
				if self:GetRightPulling() then
					self:SetRightPulling(false)
				end
				
				if self:GetLeftPulling() then
					self:SetLeftPulling(false)
				end
			end
	end
	
	if (self:GetRightReleasing() || self:GetLeftReleasing()) then	 					
				if (self:GetNextStep() < CurTime()) then
					self:Hitscan(self:GetHoldingTime())
					self:SetNextStep(CurTime() + self.NextPunchTime)
					if !self.Owner:KeyDown( IN_RELOAD ) && self.Owner:KeyDown( IN_ATTACK2 ) && self:GetLeftReleasing() && !self:GetHoldingProp() then
						self:SetStartHoldingTime(CurTime() - self.MinHoldTime + self.ComboHoldTime  )
						self:SetRightPulling(true)
						self:SetRightBusy(false)
						self:SetCombo(self:GetCombo() + 1)
					end	
					if !self.Owner:KeyDown( IN_RELOAD ) && self.Owner:KeyDown( IN_ATTACK ) && self:GetRightReleasing() && !self:GetHoldingProp() then
						self:SetStartHoldingTime(CurTime() - self.MinHoldTime + self.ComboHoldTime  )
						self:SetLeftPulling(true)
						self:SetLeftBusy(false)
						self:SetCombo(self:GetCombo() + 1)
					end
					self:SetLeftReleasing(false)				
					self:SetRightReleasing(false)		
					if self:GetCurMove() != 3 then	
						self:SetCurMove(self:GetCurMove() + 1)
					else 
						self:SetCurMove(1)
					end				
				end
	end
	
	if CLIENT  then
		if !self:GetHoldingProp() then
			if IsValid(self.csmodel) then 
				self.csmodel:Remove()
			end 
		else
			if !IsValid(self.csmodel) then 
				self.csmodel = ClientsideModel(self:GetClientSideModelName())
				self.csmodel:SetNoDraw(true)
				self.csmodel:DrawModel(false)
			end 
		end
	end
	
	if !self:GetRightBusy() then	
		if !self:IsCurSequence(0,self:GetFightStyle(0)) then
			self:SetCurSequence(0, self:GetFightStyle(0))
		end
	end 
	
	if !self:GetLeftBusy() then
		if !self:IsCurSequence(1,self:GetFightStyle(1)) then
			self:SetCurSequence(1, self:GetFightStyle(1))
		end
	end
	
	return true  
end

function SWEP:GetFightStyle(hand)
		if self:GetRightPulling() then
			if hand == 0 then
				if self:GetHoldingProp() then
					return ("idle_prop_lowered")
				else
					return ("idle_box_lowered"..self:GetCurMove())
				end
			end
			if hand == 1 then
				return ("idle_hand_far")
			end
		end
		
		if self:GetLeftPulling()  then
			if hand == 0 then
				if self:GetHoldingProp() then
					return ("idle")
				else
					return ("idle_hand_far")
				end
			end
			if hand == 1 then
				return ("idle_box_lowered"..self:GetCurMove())
			end
		end	
		
		if self:GetRightReleasing() then
			if hand == 0 then
				if self:GetHoldingProp() then
					return ("idle_prop_hit")
				else
					return ("idle_box_hit"..self:GetCurMove())
				end
			end
			if hand == 1 then
				return ("idle_hand_close")
			end			
		end		
		
		if self:GetLeftReleasing() then 
			if hand == 0 then
				if self:GetHoldingProp() then
					return ("idle")
				else
					return ("idle_hand_close")
				end
			end
			if hand == 1 then
				return ("idle_box_hit"..self:GetCurMove())
			end		
		end
		
		if !self:GetRightReleasing() && !self:GetRightPulling() && hand == 0 then
			
			if self:GetHoldingProp() then
				return ("idle_prop")
			else
				return ("idle_box_close") 
			end
		end	
		
		if !self:GetLeftReleasing() && !self:GetLeftPulling() && hand == 1 then
			return ("idle_box_far")
		end	
end

function SWEP:SetCurSequence(idx,sequence)
		self.Owner:GetViewModel(idx):SendViewModelMatchingSequence( self.Owner:GetViewModel(idx):LookupSequence(sequence))
end

function SWEP:Deploy()
	if ( IsValid( self.Owner:GetViewModel( 1 ) ) ) then
		self.Owner:GetViewModel( 1 ):SetWeaponModel( self.ViewModel , self )
	end
	self:SetHolstered(true)
	self:SetRightBusy(false)
	self:SetLeftBusy(false)
	self:SetCurSequence(0, "idle" )
	self:SetCurSequence(1, "idle" )
	self:SetNextStep(CurTime() + 1/GetConVarNumber( "sv_defaultdeployspeed" ))
	return true
end

function SWEP:SendViewModelAnim( act , index , rate )

	if ( not game.SinglePlayer() and not IsFirstTimePredicted() ) then
		return
	end

	local vm = self.Owner:GetViewModel( index )

	if ( not IsValid( vm ) ) then
		return
	end

	local seq = vm:SelectWeightedSequence( act )

	if ( seq == -1 ) then
		return
	end

	vm:SendViewModelMatchingSequence( seq )
	vm:SetPlaybackRate( rate or 1 )
end

function SWEP:IsCurSequence(idx,str)
	if (self.Owner:GetViewModel(idx):GetSequence() == self.Owner:GetViewModel(idx):LookupSequence( str )) then
		return true
	else
		return false
	end
end

function SWEP:Hitscan(dmg_mult)
self.Owner:LagCompensation( true )
local reach
local dmg
local mins = self:GetPropMins()
local maxs = self:GetPropMaxs()
	if self:GetHoldingProp() && self:GetRightReleasing() then
		if HL2_MELEE[wep:GetClientSideModelName()] != nil then
			dmg = HL2_MELEE[wep:GetClientSideModelName()]["dmg"] * math.min(1,math.max(dmg_mult*3,0.1))
			reach = HL2_MELEE[wep:GetClientSideModelName()]["reach"]
		else
			dmg = 30 + (self:GetPropMass())
			if (maxs.x - mins.x) >= (maxs.y - mins.y ) && (maxs.x - mins.x) >= (maxs.z - mins.z ) then
				reach = 40 + (maxs.x - mins.x)/2
			elseif (maxs.y - mins.y) >= (maxs.x - mins.x ) && (maxs.y - mins.y) >= (maxs.z - mins.z ) then
				reach = 40 + (maxs.y - mins.y)/2
			elseif (maxs.z - mins.z) >= (maxs.x - mins.x ) && (maxs.z - mins.z) >= (maxs.y - mins.y ) then
				reach = 40 + (maxs.z - mins.z)/2
			end
		end
	else
		dmg = 50
		reach = 80
	end
	print(dmg)
	local tr = util.TraceHull( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() +  self.Owner:GetAimVector() * reach,
		filter = self.Owner,
		mins = Vector( -5, -5, -5 ),
		maxs = Vector( 5, 5, 5 ),
		mask = MASK_SHOT_HULL
	} )
	
	if ( tr.Hit && !( game.SinglePlayer() && CLIENT ) ) then
		self:EmitSound( "Flesh.ImpactHard" )
	end
if SERVER then 
	if tr.Hit then 
				print(dmg * math.min(1,math.max(dmg_mult*3,0.1)))
				print(dmg_mult)
				local damage = DamageInfo()
				damage:SetDamageType(DMG_CLUB)
				damage:SetDamage(dmg * math.min(1,math.max(dmg_mult*3,0.1)))
				damage:SetAttacker(self.Owner)
				damage:SetInflictor(self)
			//	if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
					//tr.Entity:SetVelocity( self.Owner:GetAimVector() * 500 )
					//damage:SetDamageForce(self.Owner:GetUp() * 5000)
				//else
					damage:SetDamageForce(self.Owner:EyeAngles():Forward())
				//end
				tr.Entity:TakeDamageInfo(damage)
	end	
end 
self.Owner:LagCompensation( false )
end

function SWEP.Reload()
end

function SWEP.PrimaryAttack()
end

function SWEP.SecondaryAttack()
end

function SWEP:GetViewModelPosition( pos, ang )
	ang:RotateAroundAxis( ang:Forward(), 0 )
	ang:RotateAroundAxis( ang:Up(), 0 )
	ang:RotateAroundAxis( ang:Right(), 0 )
	pos = pos + ang:Right() * 1 + ang:Forward() * 1 + ang:Up() * 1
	return pos, ang
end