AddCSLuaFile()
ENT.Type 		= "ai"
ENT.Base 		= "base_ai"
ENT.PrintName 		= "monster_test"
ENT.Author 		= "N/A"
ENT.Information		= "SNPC"
ENT.Category 		= "Half-Life: Source"

ENT.Spawnable 		= true
ENT.AdminSpawnable 	= true

function ENT:Initialize()
	self:SetModel("models/mossman.mdl")
	if (SERVER) then
		self:SetMaxHealth(100)
		self:SetHealth(100)
		self:SetHullType(HULL_HUMAN)
		self:SetHullSizeNormal()
		self:SetSolid(SOLID_BBOX)
		self:SetMoveType( MOVETYPE_STEP )
		self:SetSaveValue( "m_bloodColor", BLOOD_COLOR_RED);
		self:SetSaveValue( "m_MonsterState", MONSTERSTATE_NONE);
	end
end

function ENT:Classify()
	return CLASS_ALIEN_MONSTER
end

function ENT:USE() 
self:PlaySentence( "HG_CHARGE", 0, 1 )
end

function ENT:OnTakeDamage(dmg)
	self:SetSchedule( SCHED_FALL_TO_GROUND )
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then self:SetSchedule( SCHED_FALL_TO_GROUND ) end
	//self:EmitSound( Sound("scientist/absolutelynot.wav", self:GetPos(), 1, CHAN_VOICE, 1, 75, 0, 100 ))
	self:SetSaveValue("m_vecLastPosition", dmg:GetAttacker():GetPos())
	self:SetSchedule(SCHED_FORCED_GO)
	self:PlaySentence( "C2A2_", 0, 5 )
	return 0
end

function ENT:Think()
	if !SERVER then return end
	self:SetMovementActivity(ACT_WALK)
end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
 
	self.AutomaticFrameAdvance = bUsingAnim
 
end