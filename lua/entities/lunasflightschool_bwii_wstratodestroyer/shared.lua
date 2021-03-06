ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Strato Destroyer"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"
ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/westernfrontier/stratodestroyer.mdl"

ENT.AITEAM = TEAM_FRONTIER

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -5

ENT.HideDriver = true
ENT.SeatPos = Vector(272.16,0,100.65)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	300 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	30
ENT.WheelPos_L 		= 	Vector(-12.67,104.83,0)
ENT.WheelPos_R 		= 	Vector(-12.67,-104.83,0)
ENT.WheelPos_C   	= 	Vector(129.05,0,0)

ENT.IdleRPM = 300
ENT.MaxRPM = 2200
ENT.LimitRPM = 2200

ENT.RotorPos = Vector(50,0,135)
ENT.WingPos = Vector(28.18,0,52.25)
ENT.ElevatorPos = Vector(-220.62,0,48.35)
ENT.RudderPos = Vector(-220.33,0,63.8)

ENT.MaxVelocity = 1200

ENT.MaxThrust = 600

ENT.MaxTurnPitch = 250
ENT.MaxTurnYaw = 300
ENT.MaxTurnRoll = 90

ENT.MaxPerfVelocity = 	1100 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = BWII_HP_STRATODESTROYER

ENT.MaxPrimaryAmmo = 10000 -- Machine gun
ENT.MaxSecondaryAmmo = 1000 -- Missiles (Infinite bombs)

ENT.MaxStability 	= 	0.9

sound.Add({
	name = "LFS_WSTRATO_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 150,
	sound = "cpthazama/bwii/westernfrontier/VW_Strat_Eng_1.wav"
})