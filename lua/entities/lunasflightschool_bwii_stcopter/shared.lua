ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Transport Helicopter"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/solarempire/tcopter.mdl"

ENT.AITEAM = TEAM_SOLAR

ENT.Mass = 2500
local inert = 10000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = 0

ENT.HideDriver = false
ENT.SeatPos = Vector(151.64,0,28.74)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxThrustHeli = 8
ENT.MaxTurnPitchHeli = 30
ENT.MaxTurnYawHeli = 50
ENT.MaxTurnRollHeli = 20

ENT.ThrustEfficiencyHeli = 0.9

ENT.RotorPos = Vector(116.7,0,287.15)
ENT.RotorAngle = Angle(0,0,0)
ENT.RotorRadius = 0

ENT.MaxHealth = BWII_HP_TRANSPORTCOPTER

sound.Add({
	name = "LFS_XTCOPTER_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/xylvania/transport_engine1.wav"
})

sound.Add({
	name = "LFS_XTCOPTER_ENGINE2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	sound = "cpthazama/bwii/xylvania/transport_engine2.wav"
})