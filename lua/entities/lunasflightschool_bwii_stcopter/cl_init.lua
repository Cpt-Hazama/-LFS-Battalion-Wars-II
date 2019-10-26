include("shared.lua")

local lEngine = {
	[1] = Vector(27.71,146.74,181.22),
	[2] = Vector(27.61,195.65,181.22),
	[3] = Vector(28.27,147.1,105.05),
	[4] = Vector(27.2,197.64,105.3)
}
local rEngine = {
	[1] = Vector(27.71,-146.74,181.22),
	[2] = Vector(27.61,-195.65,181.22),
	[3] = Vector(28.27,-147.1,105.05),
	[4] = Vector(27.2,-197.64,105.3)
}

-- function ENT:LFSCalcViewFirstPerson(view)
	-- view.origin = self:LocalToWorld(Vector(151.64,0,28.74)) +self:GetForward() *25 +self:GetUp() *28
	-- return view
-- end

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
		effectdata:SetOrigin(self:LocalToWorld(lRotor))
		util.Effect( "lfs_blacksmoke", effectdata )

		local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(rRotor))
		util.Effect( "lfs_blacksmoke", effectdata )

		local effectdata = EffectData()
		effectdata:SetOrigin(self:LocalToWorld(fRotor))
		util.Effect( "lfs_blacksmoke", effectdata )
	end
end

function ENT:FireEffect(pos,emitter)
	if self:GetVelocity():Length() > 50 then
		self.FlameEffect1 = emitter:Add("sprites/blueglow2",self:LocalToWorld(pos))
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
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)

	self.Emitter = ParticleEmitter(self:GetPos())
		for i = 1,#lEngine do
			self:FireEffect(lEngine[i],self.Emitter)
		end
		for i = 1,#rEngine do
			self:FireEffect(rEngine[i],self.Emitter)
		end
	self.Emitter:Finish()
end

local mat = Material( "sprites/light_glow02_add" )
function ENT:Draw()
	self:DrawModel()
	if self:GetEngineActive() then
		local Size = 60
		render.SetMaterial(mat)
		-- render.DrawSprite(self:LocalToWorld(cLight),Size,Size,Color(255,220,0,255))
		-- render.DrawSprite(self:LocalToWorld(lLight),Size,Size,Color(255,220,0,255))
		-- render.DrawSprite(self:LocalToWorld(rLight),Size,Size,Color(255,220,0,255))
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
		self.EngineSound2:ChangePitch(math.Clamp(100 *(RPM *0.0004),75,100))
		self.EngineSound2:ChangeVolume(math.Clamp(100 *(RPM *0.0004),90,70))
	end
end

function ENT:EngineActiveChanged(bActive)
	if bActive then
		self.EngineSound1 = CreateSound(self,"LFS_XTCOPTER_ENGINE")
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
	local FT = FrameTime() *5	
	local RPM = self:GetRPM() *0.001
	
	local Pitch = self:GetRotPitch()
	self.smPitch = self.smPitch and self.smPitch +(RPM -self.smPitch) *FT or 0

	self:ManipulateBoneAngles(11,Angle(0,0,-(self.smPitch *30)))
end

function ENT:AnimRotor()

end