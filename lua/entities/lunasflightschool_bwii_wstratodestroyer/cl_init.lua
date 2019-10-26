include("shared.lua")

local lExhuast = Vector(-231.41,91.83,184.26)
local rExhuast = Vector(-231.41,-91.83,184.26)
local engineLeft1 = Vector(-223.93,93.85,109)
local engineLeft2 = Vector(-226.28,123.15,109)
local engineLeft3 = Vector(-224.03,178.2,102)
local engineLeft4 = Vector(-224.31,204.57,102)
local engineRight1 = Vector(-223.93,-93.85,109)
local engineRight2 = Vector(-226.28,-123.15,109)
local engineRight3 = Vector(-224.03,-178.2,102)
local engineRight4 = Vector(-224.31,-204.57,102)

local mainTurret = 26
local topTurret = 30
local backTurret = 27

ENT.tbl_Exhuast = {
	Vector(-138.98,241.06,35.36),
	Vector(-140.94,220.1,23.83),
	Vector(-73.94,240.23,34.29),
	Vector(-74.8,219.18,22.6),
	Vector(-138.98,-241.06,35.36),
	Vector(-140.94,-220.1,23.83),
	Vector(-73.94,-240.23,34.29),
	Vector(-74.8,-219.18,22.6),
}

ENT.tbl_Engines = {
	[1] = engineLeft1,
	[2] = engineLeft2,
	[3] = engineLeft3,
	[4] = engineLeft4,
	[5] = engineRight1,
	[6] = engineRight2,
	[7] = engineRight3,
	[8] = engineRight4,
}

function ENT:Initialize()
	self.tbl_DamagedEngines = {}
	for i = 1,#self.tbl_Engines do
		if math.random(1,3) == 1 then
			table.insert(self.tbl_DamagedEngines,self.tbl_Engines[i])
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
	for i = 1,#self.tbl_Engines do
		self:SmokeEffect(self.tbl_Engines[i])
	end
	for _,v in pairs(self.tbl_Exhuast) do
		self:ExEffect(v)
	end
end

function ENT:ExEffect(pos)
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

function ENT:SmokeEffect(pos)
	self.SmokeEmitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.SmokeEmitter:Add("particles/smokey",self:LocalToWorld(pos))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(1)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)

	if self:GetVelocity():Length() > 50 then
		self.FlameEffect1 = self.SmokeEmitter:Add("particles/flamelet2",self:LocalToWorld(pos))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.3)
		self.FlameEffect1:SetStartAlpha(100)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(30)
		self.FlameEffect1:SetEndSize(1)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
	end
	self.SmokeEmitter:Finish()
end

local mat = Material( "sprites/light_glow02_add" )
ENT.NextFlashT = CurTime()
ENT.IsFlashing = false
ENT.tbl_Lights = {
	[1]={pos=Vector(-271.25,34.37,87.66),time=CurTime(),flash=false},
	[2]={pos=Vector(-271.25,-34.37,87.66),time=CurTime(),flash=false},
	[3]={pos=Vector(-248.31,46.99,89.6),time=CurTime(),flash=false},
	[4]={pos=Vector(-248.31,-46.99,89.6),time=CurTime(),flash=false},
	[5]={pos=Vector(-0.88,245.3,130.73),time=CurTime(),flash=false},
	[6]={pos=Vector(-0.88,-245.3,130.73),time=CurTime(),flash=false},
	[7]={pos=Vector(121.69,29.11,170.4),time=CurTime(),flash=false},
	[8]={pos=Vector(121.69,-29.11,170.4),time=CurTime(),flash=false},
	[9]={pos=Vector(254.54,33.45,85.83),time=CurTime(),flash=false},
	[10]={pos=Vector(254.54,-33.45,85.83),time=CurTime(),flash=false},
	[11]={pos=Vector(51.53,224.65,52.64),time=CurTime(),flash=false},
	[12]={pos=Vector(51.53,-224.65,52.64),time=CurTime(),flash=false},
	[13]={pos=Vector(119.08,0,8.77),time=CurTime(),flash=false},
}
function ENT:Draw()
	self:DrawModel()
	if self:GetEngineActive() then
		local Size = 115
		render.SetMaterial(mat)
		for i = 1,#self.tbl_Lights do
			render.DrawSprite(self:LocalToWorld(self.tbl_Lights[i].pos),Size,Size,Color(255,180,0,255))
			if CurTime() > self.tbl_Lights[i].time && !self.tbl_Lights[i].flash then
				self.tbl_Lights[i].flash = true
				render.DrawSprite(self:LocalToWorld(self.tbl_Lights[i].pos),170,170,Color(255,180,0,255))
				timer.Simple(1,function()
					if IsValid(self) then
						self.tbl_Lights[i].flash = false
						self.tbl_Lights[i].time = CurTime() +1
					end
				end)
			end
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
		self.EngineSound1 = CreateSound(self,"LFS_WSTRATO_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_WFIGHTER_ENGINE")
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

	self:TurnTurret(Driver,HasGunner,topTurret,0,120,0,true)
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
	self:ManipulateBoneAngles(bone,Angle(0,0,-Pitch))
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()

end

function ENT:AnimLandingGear()

end