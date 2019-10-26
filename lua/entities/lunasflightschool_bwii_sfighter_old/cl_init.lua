include("shared.lua")

local engine = Vector(-81.07,0,43.84)

function ENT:GunCamera(view,ply)
	local pos,ang = self:GetBonePosition(20)
	local tbPos = {x=-6,y=-3.5,z=-7}
	view.origin = pos +ang:Right() *tbPos.y +ang:Up() *tbPos.z +ang:Forward() *tbPos.x
	return view
end

function ENT:LFSCalcViewFirstPerson(view,ply)
	if ply == self:GetDriver() and ply ~= self:GetGunner() then
		view.angles = ply:GetVehicle():LocalToWorldAngles(ply:EyeAngles())
		return
	end
	return self:GunCamera(view,ply)
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
	self:AnimLandingGear()
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
			-- self.Missile:SetDisabled( true )
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
		effectdata:SetOrigin(self:LocalToWorld(engine))
		util.Effect( "lfs_blacksmoke", effectdata )
	end
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	-- Engine --

	self.Emitter = ParticleEmitter(self:GetPos())
	if self:GetVelocity():Length() > 50 then
		self.FlameEffect1 = self.Emitter:Add("sprites/blueglow2",self:LocalToWorld(engine))
		self.FlameEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
		self.FlameEffect1:SetDieTime(0.195)
		self.FlameEffect1:SetStartAlpha(180)
		self.FlameEffect1:SetEndAlpha(0)
		self.FlameEffect1:SetStartSize(18)
		self.FlameEffect1:SetEndSize(10)
		self.FlameEffect1:SetRoll(math.Rand(-0.2,0.2))
		self.FlameEffect1:SetAirResistance(200)
		self.FlameEffect1:SetColor(0,161,255,255)
	end
	self.Emitter:Finish()
end

local mat = Material( "sprites/light_glow02_add" )
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
		self.EngineSound2:ChangePitch(math.Clamp(100 *(RPM *0.0007),75,255))
		self.EngineSound2:ChangeVolume(math.Clamp(100 *(RPM *0.0007),90,110))
	end
end

function ENT:EngineActiveChanged(bActive)
	if bActive then
		self.EngineSound1 = CreateSound(self,"LFS_SFIGHTER_ENGINE")
		self.EngineSound1:PlayEx(0,0)
		self.EngineSound2 = CreateSound(self,"LFS_SFIGHTER_ENGINE2")
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
	
	local EyeAngles = self:WorldToLocalAngles(Driver:EyeAngles())
	EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
	
	local Yaw = math.Clamp( EyeAngles.y,-90,90 )
	local Pitch = math.Clamp( EyeAngles.p,-12,90 )

	if HasGunner or Driver:lfsGetInput( "FREELOOK" ) then
		if not Driver:lfsGetInput( "FREELOOK" ) and not HasGunner then
			Yaw = 0
			Pitch = 0
		end
		self:ManipulateBoneAngles(20,Angle(Yaw,0,0))
		self:ManipulateBoneAngles(21,Angle(0,0,Pitch))
	end
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()

end

local value = 0
local move = Vector(0,0,0)
function ENT:AnimLandingGear()
	self.SMLG = self.SMLG and self.SMLG + (80 *  self:GetLGear() - self.SMLG) * FrameTime() * 8 or 0
	self.SMRG = self.SMRG and self.SMRG + (80 *  self:GetRGear() - self.SMRG) * FrameTime() * 8 or 0

	local gear = 4
	local skid = 5
	if self.SMLG <= 25 then // Closed
		move = LerpVector(1 *FrameTime(),move,Vector(0,25,-15))
	else
		move = LerpVector(1 *FrameTime(),move,Vector(0,0,0))
	end
	self:ManipulateBonePosition(4,move)
	self:ManipulateBonePosition(5,move)
end