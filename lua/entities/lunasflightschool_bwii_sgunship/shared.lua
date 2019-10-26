ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Gunship"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/solarempire/gunship.mdl"

ENT.AITEAM = TEAM_SOLAR

ENT.Mass = 1750
local inert = 4000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -0.1

ENT.HideDriver = false
ENT.SeatPos = Vector(110,0,50.23)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxThrustHeli = 15
ENT.MaxTurnPitchHeli = 60
ENT.MaxTurnYawHeli = 85
ENT.MaxTurnRollHeli = 135

ENT.ThrustEfficiencyHeli = 0.9

ENT.RotorPos = Vector(0,0,80)
ENT.RotorAngle = Angle(25,0,0)
ENT.RotorRadius = 0

ENT.MaxHealth = BWII_HP_GUNSHIP

ENT.MaxPrimaryAmmo = 500
ENT.MaxSecondaryAmmo = 1000

sound.Add({
	name = "LFS_SGUNSHIP_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	sound = "cpthazama/bwii/solarempire/VS_Gunship_Eng3.wav"
})

sound.Add({
	name = "LFS_SGUNSHIP_ENGINE2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/solarempire/VS_Gunship_Eng4.wav"
})

sound.Add({
	name = "LFS_SGUNSHIP_MISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/solarempire/WS_Baz_Fire.wav"
})

sound.Add({
	name = "LFS_SGUNSHIP_TURRET",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/solarempire/WS_Rifle_Fire.wav"
})