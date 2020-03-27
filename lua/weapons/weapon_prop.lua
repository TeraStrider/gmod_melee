AddCSLuaFile()
SWEP.Base = "weapon_melee"
SWEP.PrintName = "WeaponProp"
SWEP.DrawSequence = "gen_short_draw01"
SWEP.IdleSequence = "gen_short_idle01"
SWEP.RestoreSequence = "gen_short_draw01"
SWEP.AttackTime = 0.3
SWEP.RestoreTime = 0.3
SWEP.ChargeTime = 0.2
SWEP.MissSound = "WeaponFrag.Throw"
SWEP.DrawWeaponInfoBox = true
SWEP.UseHands = true
SWEP.HoldType = "melee2"
SWEP.Attack = {
	First = {
		Force = Vector(0,-0.707107,0.707107),
		ChargeSequence = "gen_short_charge01",
		AttackSequence = "gen_short_misscenter01"
	},
	Second = {
		Force = Vector(1,0,0),
		ChargeSequence = "gen_short_charge02",
		AttackSequence = "gen_short_misscenter02"
	},
	Middle = {
		Force = Vector(0.408248,0.816496,0.408248),
		ChargeSequence = "gen_short_charge03",
		AttackSequence = "gen_short_misscenter03"
	},
	Last = {
		Force = Vector(0.707107,0,-0.707107),
		ChargeSequence = "gen_short_charge03",
		AttackSequence = "gen_short_misscenter04"
	}
}
