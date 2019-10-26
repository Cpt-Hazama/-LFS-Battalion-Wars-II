AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 55 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:RunOnSpawn()
	self:GetDriverSeat().ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(44.45,100.18,196.04),Angle(0,0,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(45.45,-100.18,196.04),Angle(0,180,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)

	// Left seats
	self:AddPassengerSeat(Vector(19.83,51.86,101.5),Angle(0,180,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-10,53.86,99.5),Angle(0,180,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-40,55.86,97.5),Angle(0,180,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-80,57.86,95.5),Angle(0,180,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-120,59.86,93.5),Angle(0,180,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)

	// Right seats
	self:AddPassengerSeat(Vector(19.83,-51.86,101.5),Angle(0,0,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-10,-53.86,99.5),Angle(0,0,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-40,-55.86,97.5),Angle(0,0,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-80,-57.86,95.5),Angle(0,0,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
	self:AddPassengerSeat(Vector(-120,-59.86,93.5),Angle(0,0,0)).ExitPos = Vector(-500.43,math.Rand(-150,150),140.49)
end

function ENT:SecondaryAttack( Driver, Pod )

end

function ENT:HandleWeapons(Fire1,Fire2)
	local Gunner = self:GetGunner()
	local HasGunner = IsValid(Gunner)
end

function ENT:OnEngineStarted()
	self:EmitSound("lfs/heli_start_generic.ogg")
end

function ENT:OnEngineStopped()
	self:EmitSound("lfs/bf109/stop.wav")
end

function ENT:OnLandingGearToggled(bOn)
	self:EmitSound("lfs/bf109/gear.wav")
end

function ENT:OnRemove() end

function ENT:CreateAI() end

function ENT:RemoveAI() end

function ENT:OnRotorDestroyed()
	self:EmitSound("physics/metal/metal_box_break2.wav")
	self:Destroy()
end