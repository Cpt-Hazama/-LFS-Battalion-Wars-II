AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

local bGunner = Vector(-240.25,0,80.71)
local tGunner = Vector(82.84,0,163.71)
local bomb = Vector(6.39,0,-70.21)
local muzzleFront = Vector(329.51,0,57.83)
local muzzleLeft = Vector(133.28,292.11,58.7)
local muzzleRight = Vector(133.28,-292.11,58.7)
local muzzleBack = Vector(-300.68,0,101.05)

ENT.tbl_Missiles = {
	[1] = Vector(194.38,-201.79,96.8),
	[2] = Vector(196.14,-179.33,96.58),
	[3] = Vector(220.67,-120.72,103.01),
	[4] = Vector(218.6,-94.71,102.98),
	[5] = Vector(218.6,94.71,102.98),
	[6] = Vector(220.67,120.72,103.01),
	[7] = Vector(196.14,179.33,96.58),
	[8] = Vector(194.38,201.79,96.8),
}

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 60 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:RunOnSpawn()
	self:SetGunnerSeat(self:AddPassengerSeat(tGunner,Angle(0,90,0)))
	self:AddPassengerSeat(bGunner,Angle(0,90,0))
end

function ENT:SetNextAltPrimary(delay)
	self.NextAltPrimary = CurTime() +delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:PlayerChat(text)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(tostring(text))
	end
end

function ENT:AI_AltPrimaryAttack()
	if not self:CanAltPrimaryAttack() then return end

	self:SetNextAltPrimary(0.1)

	local startpos = self:GetBonePosition(30)
	local hull = 90
	local tr = util.TraceHull({
		start = startpos,
		endpos = startpos +self:GetForward() *-50000,
		mins = Vector(-hull,-hull,-hull),
		maxs = Vector(hull,hull,hull),
		filter = function(e)
			local collide = e ~= self
			return collide
		end
	})

	local pos = self:GetBonePosition(30)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,10,0)
	bullet.Dir 			= (self:AIGetTarget():GetPos() - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.02,0.02,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,-10,0)
	-- bullet.Dir 			= (tr.HitPos - bullet.Src):GetNormalized()
	bullet.Dir 			= (self:AIGetTarget():GetPos() - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.02,0.02,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()
end
	
function ENT:AltPrimaryAttack( Driver, Pod )
	if not self:CanAltPrimaryAttack() then return end
	if not IsValid(Pod) then Pod = self:GetDriverSeat() end
	if not IsValid(Driver) then Driver = Pod:GetDriver() end
	if not IsValid(Pod) then return end
	if not IsValid(Driver) then return end
	local turn = 0
	local up = 15
	local down = 73
	local att = "center_gun"

	local EyeAngles = Pod:WorldToLocalAngles(Driver:EyeAngles())
	local Forward = -self:GetForward()
	
	local AimDirToForwardDir = math.deg(math.acos(math.Clamp(Forward:Dot(EyeAngles:Forward()),-1,1)))
	-- self:PlayerChat(AimDirToForwardDir)
	if AimDirToForwardDir > 20 then /*if self:GetDriver() != Driver then self:PrimaryAttack() end*/ return end
	
	self:SetNextAltPrimary(0.1)

	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull({
		start = startpos,
		endpos = (startpos +EyeAngles:Forward() *50000),
		mins = Vector( -10,-10,-10),
		maxs = Vector(10,10,10),
		filter = self
	})

	-- local pos = self:LocalToWorld(muzzleBack)
	local pos = self:GetBonePosition(30)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.02,0.02,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,-10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.02,0.02,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -10, -10, -10 ),
		maxs = Vector( 10, 10, 10 ),
		filter = self
	} )
	
	self:SetNextPrimary(0.1)

	local pos = self:LocalToWorld(muzzleFront)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,-10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local pos = self:LocalToWorld(muzzleLeft)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,-10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local pos = self:LocalToWorld(muzzleRight)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,-10,0)
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_WBOMBER_GUN")
	self:TakePrimaryAmmo()
end

function ENT:SpawnBomb(Pos)
	local ent = ents.Create("lunasflightschool_bwii_bomb")
	ent:SetPos(Pos)
	ent:SetAngles(Angle(90,0,0))
	ent.Model = "models/cpthazama/bwii/xylvania/stratonuke.mdl"
	ent.Mass = 150
	ent.DMG = BWII_DMG_MININUKE
	ent.DMGDist = 900
	ent.IdleSound = "cpthazama/bwii/bomb_fall.wav"
	ent.ExplodeSound = "cpthazama/bwii/bomb_explode" .. math.random(1,2) .. ".wav"
	ent.SmallExplosion = false
	ent:Spawn()
	ent:Activate()
	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetVelocity(self:GetVelocity() *1 +self:GetUp() *-1800 +self:GetForward() *1100)
	end
	ent.SmallExplosion = false
	ent:SetAttacker(self:GetDriver())
	ent:SetInflictor(self)
	ent.Mass = 150
	ent.DMG = BWII_DMG_MININUKE
	ent.DMGDist = 900
	ent:SetModel("models/cpthazama/bwii/westernfrontier/bomb.mdl")
	ent:SetModelScale(2,0)
	constraint.NoCollide(ent,self,0,0) 
end

ENT.MissileIndex = 1
function ENT:FireMissile(Target,tr)
	self:SetNextSecondary(0.3)
	self:TakeSecondaryAmmo()
	self:EmitSound("LFS_XFIGHTER_MISSILE")
	local ent = ents.Create("lunasflightschool_bwii_missile")
	if self.MissileIndex > #self.tbl_Missiles then
		self.MissileIndex = 1
	end
	local Pos = self.tbl_Missiles[self.MissileIndex]
	self.MissileIndex = self.MissileIndex +1
	ent:SetPos(self:LocalToWorld(Pos) +self:GetForward() *100)
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker(self:GetDriver())
	ent:SetInflictor(self)
	ent:SetStartVelocity(self:GetVelocity():Length())
	ent:SetCleanMissile(true)
	
	if self:GetAI() then
		local enemy = self:AIGetTarget()
		if IsValid(enemy) then
			if math.random(1,8) != 1 then
				if string.find(enemy:GetClass(),"lunasflightschool") then
					if enemy:GetClass() == "lunasflightschool_bwii_missile" then return end
					ent:SetLockOn(enemy)
					ent:SetStartVelocity(0)
				end
			end
		end
	else
		ent:SetLockOn(Target)
		ent:SetStartVelocity(0)
	end
	constraint.NoCollide(ent,self,0,0) 
end

ENT.TotalBombsFire = 0
function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	local startpos =  self:GetRotorPos()
	local tr = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -40, -40, -40 ),
		maxs = Vector( 40, 40, 40 ),
		filter = function( e )
			local collide = e ~= self
			return collide
		end
	} )
	if self:GetAI() then
		self:FireMissile(Target,tr)
		return
	end
	if tr.Hit then
		local Target = tr.Entity
		if IsValid(Target) then
			if Target:GetClass():lower() ~= "lunasflightschool_bwii_missile" then
				self:FireMissile(Target,tr)
				return
			end
		end
	end
	if self.TotalBombsFire >= 20 then
		return
	end
	self:SetNextSecondary(0.3)
	self:TakeSecondaryAmmo()
	self.TotalBombsFire = self.TotalBombsFire +1
	if self.TotalBombsFire >= 20 then
		timer.Simple(6,function()
			if IsValid(self) then
				self.TotalBombsFire = 0
			end
		end)
	end
	self:EmitSound("LFS_WBOMBER_BOMB")
	
	self.MirrorPrimary = not self.MirrorPrimary	
	local Mirror = self.MirrorPrimary and -1 or 1
	local Pos = self:LocalToWorld(bomb)
	self:SpawnBomb(Pos)
end

function ENT:HandleWeapons(Fire1,Fire2)
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid(Gunner)
	local FireTurret = false

	if self:GetAI() then
		local Target = self:AIGetTarget()
		if IsValid(Target) then
			local startpos = self:GetBonePosition(30)
			local hull = 90
			local tr = util.TraceHull({
				start = startpos,
				endpos = startpos +self:GetForward() *-50000,
				mins = Vector(-hull,-hull,-hull),
				maxs = Vector(hull,hull,hull),
				filter = function(e)
					local collide = e ~= self
					return collide
				end
			})
			if tr.HitPos:Distance(Target:GetPos()) <= 400 then
				self:AI_AltPrimaryAttack()
			end
		end
	end
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		FireTurret = Driver:lfsGetInput("FREELOOK")
	end

	if Fire1 then
		if FireTurret and not HasGunner then
			self:AltPrimaryAttack()
		else
			self:PrimaryAttack()
		end
	end

	if Fire2 then
		self:SecondaryAttack()
	end
	
	if HasGunner then
		if Gunner:KeyDown(IN_ATTACK) then
			self:AltPrimaryAttack(Gunner,self:GetGunnerSeat())
		end
	end
end

function ENT:OnEngineStarted()
	self:EmitSound("lfs/bf109/start.wav")
end

function ENT:OnEngineStopped()
	self:EmitSound("lfs/bf109/stop.wav")
end

function ENT:OnLandingGearToggled(bOn)
	self:EmitSound("lfs/bf109/gear.wav")
end

function ENT:OnRemove()
end

function ENT:CreateAI()

end

function ENT:RemoveAI()

end


function ENT:HandleActive()
	local gPod = self:GetGunnerSeat()
	
	if IsValid( gPod ) then
		local Gunner = gPod:GetDriver()
		
		if Gunner ~= self:GetGunner() then
			self:SetGunner( Gunner )
			
			if IsValid( Gunner ) then
				Gunner:CrosshairEnable() 
			end
		end
		
		if IsValid( Gunner ) then
			if self.HideDriver then
				Gunner:SetNoDraw(true)
			end
			Gunner:lfsBuildControls()
		end
	end
	
	local Pod = self:GetDriverSeat()
	
	if not IsValid( Pod ) then
		self:SetActive( false )
		return
	end
	
	local Driver = Pod:GetDriver()
	local Active = self:GetActive()
	
	if Driver ~= self:GetDriver() then
		if self.HideDriver then
			if IsValid( self:GetDriver() ) then
				self:GetDriver():SetNoDraw( false )
			end
			if IsValid( Driver ) then
				Driver:SetNoDraw( true )
			end
		end
		
		self:SetDriver( Driver )
		self:SetActive( IsValid( Driver ) )
		
		if IsValid( Driver ) then
			Driver:lfsBuildControls()
		end
		
		if Active then
			self:EmitSound( "vehicles/atv_ammo_close.wav" )
		else
			self:EmitSound( "vehicles/atv_ammo_open.wav" )
		end
	end
	
	local Time = CurTime()
	
	self.NextSetInertia = self.NextSetInertia or 0
	
	if self.NextSetInertia < Time then
		local inea = Active or self:GetEngineActive() or (self:GetStability() > 0.1) or not self:HitGround()
		local TargetInertia = inea and self.Inertia or self.LFSInertiaDefault
		
		self.NextSetInertia = Time + 1 -- !!!hack!!! reset every second. There are so many factors that could possibly break this like touching the planes with the physgun which sometimes causes ent:GetInertia() to return a wrong value?!?!
		
		local PObj = self:GetPhysicsObject()
		if IsValid( PObj ) then
			if PObj:IsMotionEnabled() then -- only set when unfrozen
				PObj:SetMass( self.Mass ) -- !!!hack!!!
				PObj:SetInertia( TargetInertia ) -- !!!hack!!!
			end
		end
	end
end