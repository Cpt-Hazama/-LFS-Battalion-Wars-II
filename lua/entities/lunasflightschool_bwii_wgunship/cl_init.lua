include("shared.lua")

local cPipe = Vector(67.27,-0.18,107.23)
local lPipe = Vector(-67.71,47.51,102.91)
local rPipe = Vector(-67.71,-47.51,102.91)
local lRotor = Vector(3.25,0,124.32)
local rRotor = Vector(-63.91,47.41,98.49)

local light1 = Vector(-73,9.06,77.59)
local light2 = Vector(-73,5.47,77.5)
local light3 = Vector(-73,1,77.5)
local light4 = Vector(-73,-3,77.5)
local light5 = Vector(-73,-7,77.5)
local light6 = Vector(-73,-10,77.5)

local missileSnd = "cpthazama/bwii/ui/UI_HUD_Missile.wav"
local missileBreak = "cpthazama/bwii/ui/UI_HUD_Missile_break.wav"
ENT.NextSoundT = 0
ENT.Missile = NULL
ENT.MissileDist = nil
ENT.Light = light1
ENT.LightInd = 1
ENT.LightType = true
ENT.NextLightT = CurTime()
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
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(lRotor))
		util.Effect( "lfs_blacksmoke", effectdata )

		local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(rRotor))
		util.Effect( "lfs_blacksmoke", effectdata )
	end
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(cPipe))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.1)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.Emitter:Finish()
	
	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(lPipe))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.1)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(20)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.Emitter:Finish()

	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(rPipe))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.1)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(20)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.Emitter:Finish()
end

function ENT:SwitchLight()
	if self.LightType then
		self.LightInd = self.LightInd +1
	else
		self.LightInd = self.LightInd -1
	end
	if self.LightInd == 7 then
		self.LightInd = 6
		self.LightType = false
	elseif self.LightInd == 0 then
		self.LightInd = 1
		self.LightType = true
	end
	local ind = self.LightInd
	if ind == 1 then
		self.Light = light1
	elseif ind == 2 then
		self.Light = light2
	elseif ind == 3 then
		self.Light = light3
	elseif ind == 4 then
		self.Light = light4
	elseif ind == 5 then
		self.Light = light5
	elseif ind == 6 then
		self.Light = light6
	end
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	if self:GetEngineActive() then
		local Size = 100
		render.SetMaterial(mat)
		if CurTime() > self.NextLightT then
			self:SwitchLight()
			self.NextLightT = CurTime() +0.1
		end
		render.DrawSprite(self:LocalToWorld(self.Light),Size,Size,Color(255,170,0,255))
		render.DrawSprite(self:LocalToWorld(light1),32,32,Color(255,170,0,255))
		render.DrawSprite(self:LocalToWorld(light2),32,32,Color(255,170,0,255))
		render.DrawSprite(self:LocalToWorld(light3),32,32,Color(255,170,0,255))
		render.DrawSprite(self:LocalToWorld(light4),32,32,Color(255,170,0,255))
		render.DrawSprite(self:LocalToWorld(light5),32,32,Color(255,170,0,255))
		render.DrawSprite(self:LocalToWorld(light6),32,32,Color(255,170,0,255))
	end
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local Low = 500
	local Mid = 700
	local High = 950
	if self.EngineSound1 then
		self.EngineSound1:ChangePitch(math.Clamp(100 *(RPM *0.0004),75,255))
		self.EngineSound1:ChangeVolume(math.Clamp(100 *(RPM *0.0004),90,180))
	end
	if self.EngineSound2 then
		self.EngineSound2:ChangePitch(math.Clamp(100 *(RPM *0.0004),75,125))
		self.EngineSound2:ChangeVolume(math.Clamp(100 *(RPM *0.0004),90,70))
	end
end

function ENT:EngineActiveChanged(bActive)
	if bActive then
		self.EngineSound1 = CreateSound(self,"LFS_WGUNSHIP_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_WGUNSHIP_ENGINE2")
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

function ENT:OnRemove()
	self:SoundStop()
end

function ENT:AnimFins()
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid( Gunner )
	if not IsValid(Driver) and not HasGunner then return end
	if HasGunner then Driver = Gunner end
	
	if HasGunner then -- Do right turret
		local EyeAngles = self:WorldToLocalAngles(Gunner:EyeAngles())
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),90)
		local Yaw = math.Clamp(EyeAngles.y,-65,65)
		local Pitch = math.Clamp(EyeAngles.p,-95,95)
		if not HasGunner then
			Yaw = 0
			Pitch = 0
		end
		if Yaw >= 0 or Yaw <= 64 then
			self:SetNWBool("RightTurret",false)
		else
			self:SetNWBool("RightTurret",true)
		end
		self:ManipulateBoneAngles(5,Angle(Yaw,Pitch,0))
	else -- Do left turret
		local EyeAngles = self:WorldToLocalAngles(Driver:EyeAngles())
		EyeAngles:RotateAroundAxis(EyeAngles:Up(),270)
		local Yaw = math.Clamp(EyeAngles.y,-65,65)
		local Pitch = math.Clamp(EyeAngles.p,-95,95)
		if not Driver:lfsGetInput("FREELOOK") then
			Yaw = 0
			Pitch = 0
		end
		local ang = Angle(Yaw,Pitch,0)
		self:ManipulateBoneAngles(4,ang)
		self:SetNWAngle("lturret",ang)
	end
end

function ENT:AnimRotor()
	local RPM = self:GetRPM()
	local HP = self:GetHP()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	ROTOR = 6
	TAILROTOR = 7
	local Rot1 = Angle(self.RPM,0,0)
	local Rot2 = Angle(0,0,self.RPM)
	Rot1:Normalize()
	Rot2:Normalize()
	self:ManipulateBoneAngles(ROTOR,Rot1)
	self:ManipulateBoneAngles(TAILROTOR,-Rot2)
end