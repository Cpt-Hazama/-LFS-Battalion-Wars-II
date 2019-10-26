ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Bomber"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/xylvania/bomber.mdl"

ENT.AITEAM = TEAM_XYLVANIA

ENT.Mass = 1000
local inert = 200000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = -5

ENT.HideDriver = true
ENT.SeatPos = Vector(160,0,60)
ENT.SeatAng = Angle(0,-90,0)

ENT.WheelMass 		= 	300 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	5
ENT.WheelPos_L 		= 	Vector(4.31,58.68,0.5)
ENT.WheelPos_R 		= 	Vector(4.31,-58.68,0.5)
ENT.WheelPos_C   	= 	Vector(110.17,0,8.45)

ENT.IdleRPM = 250
ENT.MaxRPM = 1200
ENT.LimitRPM = 1500

ENT.RotorPos = Vector(91.47,0,49.27)
ENT.WingPos = Vector(28.18,0,52.25)
ENT.ElevatorPos = Vector(-220.62,0,48.35)
ENT.RudderPos = Vector(-220.33,0,63.8)

ENT.MaxVelocity = 950

ENT.MaxThrust = 750

ENT.MaxTurnPitch = 350
ENT.MaxTurnYaw = 700
ENT.MaxTurnRoll = 100

ENT.MaxPerfVelocity = 	900 -- speed in which the plane will have its maximum turning potential

ENT.MaxHealth = BWII_HP_BOMBER

ENT.MaxPrimaryAmmo = 100
ENT.MaxSecondaryAmmo = -1

ENT.MaxStability 	= 	0.9

function ENT:GetPassengerPod(iPod)
	local pods = self:GetPassengerSeats()
	return pods[iPod]
end

function ENT:IsPod(inPod,iPod)
	local is = false
	local pods = self:GetPassengerSeats()
	if self:GetPassengerPod(iPod) == inPod then
		is = true
	end
	return is
end

sound.Add({
	name = "LFS_XBOMBER_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	pitch = 90,
	sound = "cpthazama/bwii/xylvania/fighter_engine.wav"
})

sound.Add({
	name = "LFS_XBOMBER_GUN",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "cpthazama/bwii/xylvania/machinegun_fire.wav"
})

sound.Add({
	name = "LFS_XBOMBER_BOMB",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/bombrelease.wav"
})