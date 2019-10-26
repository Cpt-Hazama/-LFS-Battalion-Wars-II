include("shared.lua")

local lPipe = Vector(-160.28,20.07,83.91)
local rPipe = Vector(-159.5,-19.61,83.72)
local cPipe = Vector(-153.2,0,72.63)

local lEngine = Vector(-15.91,46.38,56.68)
local rEngine = Vector(-15.91,-46.38,56.68)

local tTurret = 21

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
		effectdata:SetOrigin(self:LocalToWorld(lEngine))
		util.Effect( "lfs_blacksmoke", effectdata )

		local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(rEngine))
		util.Effect( "lfs_blacksmoke", effectdata )
	end
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)

	-- Engines --

	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(lEngine))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.3)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(70,70,70,200)
	self.Emitter:Finish()
	
	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(rEngine))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.3)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(70,70,70,200)
	self.Emitter:Finish()
	
	-- Pipes --

	self.Emitter = ParticleEmitter(self:GetPos())
	if self:GetVelocity():Length() > 50 then
		self.FlameEffect1 = self.Emitter:Add("particles/flamelet2",self:LocalToWorld(lPipe))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.3)
		self.FlameEffect1:SetStartAlpha(100)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(12)
		self.FlameEffect1:SetEndSize(1)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
		self.FlameEffect1:SetColor(255,125,0,255)

		self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(lPipe))
		self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
		self.SmokeEffect1:SetDieTime(0.3)
		self.SmokeEffect1:SetStartAlpha(90)
		self.SmokeEffect1:SetEndAlpha(0)
		self.SmokeEffect1:SetStartSize(12)
		self.SmokeEffect1:SetEndSize(1)
		self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.SmokeEffect1:SetColor(70,70,70,200)
	end
	self.Emitter:Finish()

	self.Emitter = ParticleEmitter(self:GetPos())
	if self:GetVelocity():Length() > 50 then
		self.FlameEffect1 = self.Emitter:Add("particles/flamelet2",self:LocalToWorld(cPipe))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.3)
		self.FlameEffect1:SetStartAlpha(100)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(12)
		self.FlameEffect1:SetEndSize(1)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
		self.FlameEffect1:SetColor(255,125,0,255)

		self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(cPipe))
		self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
		self.SmokeEffect1:SetDieTime(0.3)
		self.SmokeEffect1:SetStartAlpha(90)
		self.SmokeEffect1:SetEndAlpha(0)
		self.SmokeEffect1:SetStartSize(12)
		self.SmokeEffect1:SetEndSize(1)
		self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.SmokeEffect1:SetColor(70,70,70,200)
	end
	self.Emitter:Finish()

	self.Emitter = ParticleEmitter(self:GetPos())
	if self:GetVelocity():Length() > 50 then
		self.FlameEffect1 = self.Emitter:Add("particles/flamelet2",self:LocalToWorld(rPipe))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.3)
		self.FlameEffect1:SetStartAlpha(100)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(12)
		self.FlameEffect1:SetEndSize(1)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
		self.FlameEffect1:SetColor(255,125,0,255)

		self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(rPipe))
		self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
		self.SmokeEffect1:SetDieTime(0.3)
		self.SmokeEffect1:SetStartAlpha(90)
		self.SmokeEffect1:SetEndAlpha(0)
		self.SmokeEffect1:SetStartSize(12)
		self.SmokeEffect1:SetEndSize(1)
		self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.SmokeEffect1:SetColor(70,70,70,200)
	end
	self.Emitter:Finish()
end

function ENT:Draw()
	self:DrawModel()
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
		self.EngineSound2:ChangePitch(math.Clamp(100 *(RPM *0.0004),75,125))
		self.EngineSound2:ChangeVolume(math.Clamp(100 *(RPM *0.0004),90,70))
	end
end

function ENT:EngineActiveChanged(bActive)
	if bActive then
		self.EngineSound1 = CreateSound(self,"LFS_IBOMBER_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_IBOMBER_ENGINE2")
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
	
	if HasGunner then
		Driver = Gunner
	end

	local turn = 40
	local up = 40
	local down = 10
	self:TurnTurret(Driver,HasGunner,25,turn,up,down)
end

function ENT:TurnTurret(Driver,HasGunner,bone,turn,up,down)
	local EyeAngles = self:WorldToLocalAngles(Driver:EyeAngles())
	EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
	local Yaw = math.Clamp(EyeAngles.y,-turn,turn)
	local Pitch = math.Clamp(EyeAngles.p,-down,up)

	if not HasGunner then
		Yaw = 0
		Pitch = 0
	end
	self:ManipulateBoneAngles(bone,Angle(Yaw,0,Pitch))
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()

end

function ENT:AnimLandingGear()

end