ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Gunship"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/westernfrontier/gunship.mdl"

ENT.AITEAM = TEAM_FRONTIER

ENT.Mass = 1500
local inert = 4000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = 0

ENT.HideDriver = true
ENT.SeatPos = Vector(92.53,0,35.82)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxThrustHeli = 8
ENT.MaxTurnPitchHeli = 30
ENT.MaxTurnYawHeli = 50
ENT.MaxTurnRollHeli = 100

ENT.ThrustEfficiencyHeli = 0.9

ENT.RotorPos = Vector(24.92,0,112.36)
ENT.RotorAngle = Angle(0,0,0)
ENT.RotorRadius = 180

ENT.MaxHealth = BWII_HP_GUNSHIP

ENT.MaxPrimaryAmmo = 500

sound.Add({
	name = "LFS_WGUNSHIP_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/westernfrontier/VW_Gunship_Eng1.wav"
})

sound.Add({
	name = "LFS_WGUNSHIP_ENGINE2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/westernfrontier/VW_Gunship_Eng2.wav"
})

sound.Add({
	name = "LFS_WGUNSHIP_GUN",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "cpthazama/bwii/westernfrontier/WW_HMG_Fire_2.wav"
})

sound.Add({
	name = "LFS_WGUNSHIP_MISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/westernfrontier/WW_Baz_Fire.wav"
})