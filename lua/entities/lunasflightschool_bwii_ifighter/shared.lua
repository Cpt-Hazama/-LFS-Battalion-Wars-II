ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Fighter"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/ironlegion/fighter.mdl"

ENT.AITEAM = TEAM_LEGION

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -10

ENT.HideDriver = true
ENT.SeatPos = Vector(140.8,-1.52,60.83)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	325 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	10
ENT.WheelPos_L 		= 	Vector(-89.72,58.55,5)
ENT.WheelPos_R 		= 	Vector(-89.72,-58.55,5)
ENT.WheelPos_C   	= 	Vector(118.73,0,8)

ENT.IdleRPM = 350
ENT.MaxRPM = 2000
ENT.LimitRPM = 2400

ENT.RotorPos = Vector(300.59,0,89.19)
ENT.WingPos = Vector(31.18,0,55.25)
ENT.ElevatorPos = Vector(-223.62,0,51.35)
ENT.RudderPos = Vector(-223.33,0,66.8)

ENT.MaxVelocity = 2800

ENT.MaxThrust = 800

ENT.MaxTurnPitch = 450
ENT.MaxTurnYaw = 1000
ENT.MaxTurnRoll = 200

ENT.MaxPerfVelocity = 	1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = BWII_HP_FIGHTER

ENT.MaxPrimaryAmmo = 500
ENT.MaxSecondaryAmmo = 800

ENT.MaxStability 	= 	0.9

sound.Add({
	name = "LFS_IFIGHTER_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/ironlegion/VU_Fighter_Eng1.wav"
})

sound.Add({
	name = "LFS_IFIGHTER_MISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/ironlegion/WU_Missile_Fire.wav"
})