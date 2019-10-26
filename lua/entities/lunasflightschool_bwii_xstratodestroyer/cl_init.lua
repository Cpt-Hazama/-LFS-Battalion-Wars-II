include("shared.lua")

local lExhuast = Vector(-231.41,91.83,184.26)
local rExhuast = Vector(-231.41,-91.83,184.26)
local engine1A = Vector(-12.43,395.2,181.03)
local engine1B = Vector(-12.43,395.2,156.24)
local engine2A = Vector(43.17,258.08,181.07)
local engine2B = Vector(43.17,258.08,156.24)
local engine3A = Vector(4.25,437.9,55.17)
local engine3B = Vector(4.25,437.9,30.17)
local engine4A = Vector(60.68,301,55.34)
local engine4B = Vector(60.68,301,31.44)
local engine5A = Vector(-12.43,-395.2,181.03)
local engine5B = Vector(-12.43,-395.2,156.24)
local engine6A = Vector(43.17,-258.08,181.07)
local engine6B = Vector(43.17,-258.08,156.24)
local engine7A = Vector(4.25,-437.9,55.17)
local engine7B = Vector(4.25,-437.9,30.17)
local engine8A = Vector(60.68,-301,55.34)
local engine8B = Vector(60.68,-301,31.44)

ENT.tbl_Lights = {
	Vector(-55.68,-474.21,74.56),
	Vector(-9.35,-273.18,65.14),
	Vector(-55.68,474.21,74.56),
	Vector(-9.35,273.18,65.14)
}

ENT.tbl_Engines = {
	[1] = Vector(115.12,359.61,169.69),
	[2] = Vector(172.63,222.75,169.83),
	[3] = Vector(115.12,-359.61,169.69),
	[4] = Vector(172.63,-222.75,169.83),
	[5] = Vector(126.51,403.97,43.19),
	[6] = Vector(184.26,267.76,43.6),
	[7] = Vector(126.51,-403.97,43.19),
	[8] = Vector(184.26,-267.76,43.6)
}

ENT.tbl_RotorsL = {
	16,
	17,
	20,
	21
}

ENT.tbl_RotorsR = {
	18,
	19,
	22,
	23
}

ENT.tbl_Rotors = {
	16,
	17,
	18,
	19,
	20,
	21,
	22,
	23
}

function ENT:Initialize()
	self.tbl_DamagedEngines = {}
	self.tbl_DamagedRotors = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false
	}
	for i = 1,#self.tbl_Engines do
		if math.random(1,3) == 1 then
			table.insert(self.tbl_DamagedEngines,self.tbl_Engines[i])
			-- table.remove(self.tbl_Rotors,self.tbl_Rotors[i])
		-- else
			-- self.tbl_DamagedRotors[i] = false
		end
	end
end

local missileSnd = "cpthazama/bwii/ui/UI_HUD_Missile.wav"
local missileBreak = "cpthazama/bwii/ui/UI_HUD_Missile_break.wav"
ENT.NextSoundT = 0
ENT.Missile = NULL
ENT.MissileDist = nil
function ENT:Think()
	self:CheckEngineState()
	self:ExhaustFX()
	self:DamageFX()
	self:AnimFins()
	self:AnimRotor()
	local driver = self:GetDriver()
	if self:GetAI() then
		driver = self
	end
	if !IsValid(self.Missile) then
		for _,v in ipairs(ents.FindInSphere(self:GetPos(),1500)) do
			if v:GetClass() == "lunasflightschool_bwii_missile" then
				if IsValid(v:GetLockOn()) && v:GetLockOn() == self then
					self.Missile = v
					self.MissileDist = self.Missile:GetPos():Distance(self:GetPos())
				end
			end
		end
	end
	if IsValid(self.Missile) then
		local dist = self.Missile:GetPos():Distance(self:GetPos())
		if dist > self.MissileDist then
			self.Missile = NULL
			if driver:IsPlayer() then driver:EmitSound(missileBreak,0.2,100) end
		end
		if CurTime() > self.NextSoundT then
			if IsValid(self.Missile) then
				self.MissileDist = self.Missile:GetPos():Distance(self:GetPos())
			end
			if driver:IsPlayer() then driver:EmitSound(missileSnd,0.2,100) end
			self.NextSoundT = CurTime() +math.Clamp(dist *0.0010,0.01,0.5)
		end
	end
end

function ENT:DamageFX()
	local HP = self:GetHP()
	if HP == 0 or HP > self:GetMaxHP() * 0.5 then return end
	
	self.nextDFX = self.nextDFX or 0
	
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.02
		for i = 1,#self.tbl_DamagedEngines do
			local effectdata = EffectData()
			effectdata:SetOrigin(self:LocalToWorld(self.tbl_DamagedEngines[i]))
			util.Effect( "lfs_blacksmoke", effectdata )
		end
	end
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	self:SmokeEffect(engine1A)
	self:SmokeEffect(engine1B)
	self:SmokeEffect(engine2A)
	self:SmokeEffect(engine2B)
	self:SmokeEffect(engine3A)
	self:SmokeEffect(engine3B)
	self:SmokeEffect(engine4A)
	self:SmokeEffect(engine4B)
	self:SmokeEffect(engine5A)
	self:SmokeEffect(engine5B)
	self:SmokeEffect(engine6A)
	self:SmokeEffect(engine6B)
	self:SmokeEffect(engine7A)
	self:SmokeEffect(engine7B)
	self:SmokeEffect(engine8A)
	self:SmokeEffect(engine8B)
	self:SmokeEffect(lExhuast)
	self:SmokeEffect(rExhuast)
end

function ENT:SmokeEffect(pos)
	self.SmokeEmitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.SmokeEmitter:Add("particles/smokey",self:LocalToWorld(pos))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.2)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.SmokeEmitter:Finish()
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	if self:GetEngineActive() then
		local Size = 95
		render.SetMaterial(mat)
		for i = 1,#self.tbl_Lights do
			render.DrawSprite(self:LocalToWorld(self.tbl_Lights[i]),Size,Size,Color(255,220,0,255))
		end
	end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local Low = 500
	local Mid = 700
	local High = 950
	if self.EngineSound1 then
		self.EngineSound1:ChangePitch(math.Clamp(100 *(RPM *0.0007),75,255))
		self.EngineSound1:ChangeVolume(math.Clamp(100 *(RPM *0.0007),90,180))
	end
	if self.EngineSound2 then
		self.EngineSound2:ChangePitch(math.Clamp(100 *(RPM *0.0007),75,255))
		self.EngineSound2:ChangeVolume(math.Clamp(100 *(RPM *0.0007),90,180))
	end
end

function ENT:EngineActiveChanged(bActive)
	if bActive then
		self.EngineSound1 = CreateSound(self,"LFS_XSTRATO_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_XBOMBER_ENGINE")
		self.EngineSound2:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:SoundStop()
	if self.EngineSound1 then
		self.EngineSound1:Stop()
	end
	if self.EngineSound2 then
		self.EngineSound2:Stop()
	end
end

function ENT:AnimFins()
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid( Gunner )
	if not IsValid( Driver ) and not HasGunner then return end
	if HasGunner then Driver = Gunner end

	CENTERGUN = 24
	self:TurnTurret(Driver,HasGunner,CENTERGUN,0,15,70,true)
	self:TurnMainTurret(Driver,HasGunner)
end

function ENT:TurnMainTurret(Driver,HasGunner)
	local EyeAngles = self:WorldToLocalAngles(Driver:EyeAngles())
	EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
	local Yaw = math.Clamp(EyeAngles.y,-45,45)
	local Pitch = math.Clamp(EyeAngles.p,-20,20)
	self:ManipulateBoneAngles(25,Angle(-Yaw,0,Pitch))
	self:ManipulateBoneAngles(26,Angle(-Yaw,0,Pitch))
end

function ENT:TurnTurret(Driver,HasGunner,bone,turn,up,down,checkForDriver)
	local EyeAngles = self:WorldToLocalAngles(Driver:EyeAngles())
	EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
	local Yaw = math.Clamp(EyeAngles.y,-turn,turn)
	local Pitch = math.Clamp(EyeAngles.p,-down,up)

	if checkForDriver then
		if not Driver:lfsGetInput("FREELOOK") and not HasGunner then
			Yaw = 0
			Pitch = 0
		end
	end
	self:ManipulateBoneAngles(bone,Angle(Yaw,0,Pitch))
end

function ENT:AnimRotor()
	local RPM = self:GetRPM()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	local Rot = Angle(0,self.RPM,0)
	Rot:Normalize()
	for index,rotor in pairs(self.tbl_RotorsL) do
		-- if table.HasValue(self.tbl_Rotors,rotor) then
			self:ManipulateBoneAngles(rotor,-Rot)
		-- end
	end
	for index,rotor in pairs(self.tbl_RotorsR) do
		-- if table.HasValue(self.tbl_Rotors,rotor) then
			self:ManipulateBoneAngles(rotor,Rot)
		-- end
	end
end

function ENT:AnimCabin()

end

function ENT:AnimLandingGear()

end