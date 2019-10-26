ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Gunship"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/ironlegion/gunship.mdl"

ENT.AITEAM = TEAM_LEGION

ENT.Mass = 1500
local inert = 4000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = 0

ENT.HideDriver = false
ENT.SeatPos = Vector(63.99,0,40.3)
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
ENT.MaxSecondaryAmmo = 1000

sound.Add({
	name = "LFS_IGUNSHIP_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/ironlegion/VU_Gunship_Eng1.wav"
})

sound.Add({
	name = "LFS_IGUNSHIP_MISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/ironlegion/WU_Baz_Fire.wav"
})