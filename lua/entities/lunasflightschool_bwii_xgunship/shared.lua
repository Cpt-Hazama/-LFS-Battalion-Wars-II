ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName = "Gunship"
ENT.Author = "Cpt. Hazama"
ENT.Information = ""
ENT.Category = "[LFS] BWII"

ENT.Spawnable		= true
ENT.AdminSpawnable  = false

ENT.MDL = "models/cpthazama/bwii/xylvania/gunship.mdl"

ENT.AITEAM = TEAM_XYLVANIA

ENT.Mass = 1500
local inert = 4000
ENT.Inertia = Vector(inert,inert,inert)
ENT.Drag = 0

ENT.HideDriver = true
ENT.SeatPos = Vector(65,0,35)
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

function ENT:AddDataTables()
	self:NetworkVar("Entity",12,"GunnerPodLeft")
	self:NetworkVar("Entity",13,"GunnerPodRight")
	self:NetworkVar("Entity",14,"GunnerLeft")
	self:NetworkVar("Entity",15,"GunnerRight")
end

sound.Add({
	name = "LFS_XGUNSHIP_ENGINE",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "cpthazama/bwii/xylvania/gunship_engine1.wav"
})

sound.Add({
	name = "LFS_XGUNSHIP_ENGINE2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	sound = "cpthazama/bwii/xylvania/gunship_engine2.wav"
})

sound.Add({
	name = "LFS_XGUNSHIP_GUN",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "cpthazama/bwii/xylvania/machinegun_fire.wav"
})

sound.Add({
	name = "LFS_XGUNSHIP_MISSILE",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 95,
	sound = "cpthazama/bwii/xylvania/missile_fire.wav"
})