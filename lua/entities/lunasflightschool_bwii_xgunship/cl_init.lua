include("shared.lua")

local cLight = Vector(-98.98,0,24.97)
local lLight = Vector(-1.66,33.32,15.96)
local rLight = Vector(-1.66,-33.32,15.96)

local cPipe = Vector(-14.66,-0,98.04)
local lPipe = Vector(-0.45,13.29,92.49)
local rPipe = Vector(-0.45,-13.29,92.49)
local lRotor = Vector(-107.96,51.97,74.9)
local rRotor = Vector(-107.96,-51.97,74.9)

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
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(cPipe))
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
	self.SmokeEffect1:SetDieTime(0.3)
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
	self.SmokeEffect1:SetDieTime(0.3)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.Emitter:Finish()

	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(rPipe))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.3)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)
	self.Emitter:Finish()
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	if self:GetEngineActive() then
		local Size = 60
		render.SetMaterial(mat)
		render.DrawSprite(self:LocalToWorld(cLight),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(lLight),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(rLight),Size,Size,Color(255,220,0,255))
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
		self.EngineSound1 = CreateSound(self,"LFS_XGUNSHIP_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_XGUNSHIP_ENGINE2")
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
end

function ENT:AnimRotor()
	local RPM = self:GetRPM()
	local HP = self:GetHP()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	ROTOR = 12
	LEFTROTOR = 13
	RIGHTROTOR = 16
	local Rot1 = Angle(0,self.RPM,0)
	local Rot2 = Angle(0,0,self.RPM)
	local Rot3 = Angle(0,0,self.RPM)
	Rot1:Normalize() 
	Rot2:Normalize() 
	Rot3:Normalize() 
	self:ManipulateBoneAngles(ROTOR,Rot1)
	self:ManipulateBoneAngles(LEFTROTOR,-Rot2)
	self:ManipulateBoneAngles(RIGHTROTOR,-Rot3)
end