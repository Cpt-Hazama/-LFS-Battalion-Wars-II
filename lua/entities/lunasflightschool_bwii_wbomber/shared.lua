ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Bomber"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/westernfrontier/bomber.mdl"

ENT.AITEAM = TEAM_FRONTIER

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -5

ENT.HideDriver = true
ENT.SeatPos = Vector(190.11,0,116.92)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	300 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	5
ENT.WheelPos_L 		= 	Vector(68.28,67.29,0.29)
ENT.WheelPos_R 		= 	Vector(68.28,67.29,0.29)
ENT.WheelPos_C   	= 	Vector(203.24,0,-21.57)

ENT.IdleRPM = 325
ENT.MaxRPM = 1325
ENT.LimitRPM = 1650

ENT.RotorPos = Vector(379.05,-2.25,108.64)
ENT.WingPos = Vector(28.18,0,52.25)
ENT.ElevatorPos = Vector(-220.62,0,48.35)
ENT.RudderPos = Vector(-220.33,0,63.8)

ENT.MaxVelocity = 1100

ENT.MaxThrust = 750

ENT.MaxTurnPitch = 350
ENT.MaxTurnYaw = 700
ENT.MaxTurnRoll = 100

ENT.MaxPerfVelocity = 	1000 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = BWII_HP_BOMBER

ENT.MaxPrimaryAmmo = 100
ENT.MaxSecondaryAmmo = -1

ENT.MaxStability 	= 	0.9

sound.Add({
	name = "LFS_WBOMBER_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = 90,
	sound = "cpthazama/bwii/westernfrontier/VW_Fighter_Eng.wav"
})

sound.Add({
	name = "LFS_WBOMBER_IDLE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	sound = "cpthazama/bwii/westernfrontier/VW_Fighter_Idl.wav"
})

sound.Add({
	name = "LFS_WBOMBER_GUN",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "cpthazama/bwii/westernfrontier/WW_HMG_Fire_2.wav"
})

sound.Add({
	name = "LFS_WBOMBER_BOMB",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/bombrelease.wav"
})