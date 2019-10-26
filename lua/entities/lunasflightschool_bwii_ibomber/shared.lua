ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Bomber"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/ironlegion/bomber.mdl"

ENT.AITEAM = TEAM_LEGION

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -5

ENT.HideDriver = false
ENT.SeatPos = Vector(201.17,0,48.71)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	300 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	5
ENT.WheelPos_L 		= 	Vector(11.33,137.04,1.37)
ENT.WheelPos_R 		= 	Vector(11.33,-137.04,1.37)
ENT.WheelPos_C   	= 	Vector(172.23,0,0.83)

ENT.IdleRPM = 325
ENT.MaxRPM = 1325
ENT.LimitRPM = 1650

ENT.RotorPos = Vector(404.43,0,42.38)
-- ENT.WingPos = Vector(28.18,0,52.25)
ENT.WingPos = Vector(116.54,2.03,151.05)
-- ENT.ElevatorPos = Vector(-220.62,0,48.35)
ENT.ElevatorPos = Vector(-236.1,0,123.73)
-- ENT.RudderPos = Vector(-220.33,0,63.8)
ENT.RudderPos = Vector(-236.1,0,123.73)

ENT.MaxVelocity = 1100

ENT.MaxThrust = 750

ENT.MaxTurnPitch = 350
ENT.MaxTurnYaw = 700
ENT.MaxTurnRoll = 100

ENT.MaxPerfVelocity = 	1000 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = BWII_HP_BOMBER

ENT.MaxPrimaryAmmo = 100
ENT.MaxSecondaryAmmo = 1000

ENT.MaxStability 	= 	0.9

sound.Add({
	name = "LFS_IBOMBER_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = 85,
	sound = "cpthazama/bwii/ironlegion/VU_Fighter_Eng1.wav"
})

sound.Add({
	name = "LFS_IBOMBER_ENGINE2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/ironlegion/VU_Bomber_Eng2.wav"
})

sound.Add({
	name = "LFS_IBOMBER_GUN",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "cpthazama/bwii/ironlegion/WU_HMG_Fire.wav"
})

sound.Add({
	name = "LFS_IBOMBER_BOMB",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/bombrelease.wav"
})