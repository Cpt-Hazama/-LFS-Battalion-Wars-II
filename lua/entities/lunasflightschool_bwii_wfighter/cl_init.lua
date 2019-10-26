
include("shared.lua")

local lEngine = Vector(-201.22,41.63,74.72)
local rEngine = Vector(-201.22,-41.63,74.72)
local lLight1 = Vector(-94.95,161.12,88.76)
local lLight2 = Vector(-98.45,160.83,88.93)
local lLight3 = Vector(-101.41,160.69,89.04)
local lLight4 = Vector(-104,160.63,89.05)
local lLight5 = Vector(-108.26,160.49,89.24)
local lLight6 = Vector(-110.84,160.67,89.32)
local rLight1 = Vector(-94.95,-161.12,88.76)
local rLight2 = Vector(-98.45,-160.83,88.93)
local rLight3 = Vector(-101.41,-160.69,89.04)
local rLight4 = Vector(-104,-160.63,89.05)
local rLight5 = Vector(-108.26,-160.49,89.24)
local rLight6 = Vector(-110.84,-160.67,89.32)

ENT.NextLightT = 0

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
	local MAX = 50
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeEffect1 = self.Emitter:Add("particles/smokey",self:LocalToWorld(lEngine))
	self.SmokeEffect1:SetVelocity(self:GetForward() *-math.Rand(0,50) +Vector(math.Rand(5,5),math.Rand(5,5),math.Rand(5,5)))
	self.SmokeEffect1:SetDieTime(0.3)
	self.SmokeEffect1:SetStartAlpha(30)
	self.SmokeEffect1:SetEndAlpha(0)
	self.SmokeEffect1:SetStartSize(5)
	self.SmokeEffect1:SetEndSize(40)
	self.SmokeEffect1:SetRoll(math.Rand(-0.2,0.2))
	self.SmokeEffect1:SetColor(150,150,150,255)

	if self:GetVelocity():Length() > MAX then
		self.FlameEffect1 = self.Emitter:Add("particles/flamelet2",self:LocalToWorld(lEngine))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.16)
		self.FlameEffect1:SetStartAlpha(100)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(20)
		self.FlameEffect1:SetEndSize(1)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
	end
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
	self.SmokeEffect1:SetColor(150,150,150,255)

	if self:GetVelocity():Length() > MAX then
		self.FlameEffect1 = self.Emitter:Add("particles/flamelet2",self:LocalToWorld(rEngine))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.16)
		self.FlameEffect1:SetStartAlpha(100)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(20)
		self.FlameEffect1:SetEndSize(1)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
	end
	self.Emitter:Finish()
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	if self:GetEngineActive() then
		local Size = 38
		render.SetMaterial(mat)
		render.DrawSprite(self:LocalToWorld(lLight1),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(lLight2),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(lLight3),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(lLight4),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(lLight5),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(lLight6),Size,Size,Color(255,220,0,255))

		render.DrawSprite(self:LocalToWorld(rLight1),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(rLight2),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(rLight3),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(rLight4),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(rLight5),Size,Size,Color(255,220,0,255))
		render.DrawSprite(self:LocalToWorld(rLight6),Size,Size,Color(255,220,0,255))
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
	if self.EngineSound3 then
		self.EngineSound3:ChangePitch(math.Clamp(100 *(RPM *0.0004),75,125))
		self.EngineSound3:ChangeVolume(math.Clamp(100 *(RPM *0.0004),90,70))
	end
	if RPM < High then
		if self.EngineSound2 then
			self.EngineSound2:ChangePitch(100)
			self.EngineSound2:ChangeVolume(0)
		end
	else
		if self.EngineSound2 then
			self.EngineSound2:ChangePitch(math.Clamp(100 *(RPM *0.0007),75,255))
			self.EngineSound2:ChangeVolume(math.Clamp(100 *(RPM *0.0007),90,180))
		end
	end
end

function ENT:EngineActiveChanged(bActive)
	if bActive then
		self.EngineSound1 = CreateSound(self,"LFS_WFIGHTER_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_WFIGHTER_ENGINE2")
		self.EngineSound2:PlayEx(0,0)
		self.EngineSound3 = CreateSound(self,"LFS_WFIGHTER_IDLE")
		self.EngineSound3:PlayEx(0,0)
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
	if self.EngineSound3 then
		self.EngineSound3:Stop()
	end
end

function ENT:AnimFins()
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	
	local HasGunner = IsValid( Gunner )
	
	if not IsValid( Driver ) and not HasGunner then return end
	
	if HasGunner then Driver = Gunner end
	
	local EyeAngles = self:WorldToLocalAngles(Driver:EyeAngles())
	EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
	
	local Yaw = math.Clamp( EyeAngles.y,-0,0 )
	local Pitch = math.Clamp( EyeAngles.p,-40,60 )
	
	if not Driver:lfsGetInput( "FREELOOK" ) and not HasGunner then
		Yaw = 0
		Pitch = 0
	end
	self:ManipulateBoneAngles(24,Angle(Yaw,0,Pitch))
end

function ENT:AnimRotor()
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	
	self:ManipulateBoneAngles( 22, Angle( 0,0,self.smPitch) )
	self:ManipulateBoneAngles( 23, Angle( 0,0,self.smPitch) )
	
	self:ManipulateBoneAngles( 5, Angle( self.smYaw,0,0 ) )
	self:ManipulateBoneAngles( 6, Angle( self.smYaw,0,0 ) )
end

function ENT:AnimCabin()

end