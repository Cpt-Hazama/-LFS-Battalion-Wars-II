AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

local fGunner = Vector(246.02,0,12.58)
local bGunner = Vector(-31.66,0,10.12)
local tGunner = Vector(28.91,0,136.54)
-- local bomb = Vector(83.2,0,-17.92)
local bomb = Vector(83.2,0,-32)

local fTurret = 20
local bTurret = 22
local tTurret = 21

ENT.AttackDistance = 1500

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
	-- self:SetGunnerSeat(self:AddPassengerSeat(fGunner,Angle(0,0,0)))
	-- self:SetGunnerSeat(self:AddPassengerSeat(bGunner,Angle(0,180,0)))
	self:AddPassengerSeat(fGunner,Angle(0,-90,0))
	self:AddPassengerSeat(bGunner,Angle(0,90,0))
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
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
	
function ENT:AltPrimaryAttack( Driver, Pod, AllowPrimary )
	if not self:CanAltPrimaryAttack() then return end
	if not AllowPrimary then AllowPrimary = true end
	if not IsValid(Pod) then Pod = self:GetDriverSeat() end
	if not IsValid(Driver) then Driver = Pod:GetDriver() end
	if not IsValid(Pod) then return end
	if not IsValid(Driver) then return end
	local seats = self:GetPassengerSeats()
	local index
	for _,ply in pairs( player.GetAll() ) do
		if ply:lfsGetPlane() == self then
			local Pod = ply:GetVehicle()
			index = Pod:GetNWInt( "pPodIndex",-1)
		end
	end
	local turn = 0
	local up = 73
	local down = 15

	local EyeAngles = Pod:WorldToLocalAngles(Driver:EyeAngles())
	local Forward = -self:GetForward()
	
	local AimDirToForwardDir = math.deg(math.acos(math.Clamp(Forward:Dot(EyeAngles:Forward()),-1,1)))
	-- self:PlayerChat(AimDirToForwardDir)
	if AimDirToForwardDir > 35 then
		if AllowPrimary then
			self:PrimaryAttack()
		end
		return
	end
	
	self:SetNextAltPrimary(0.1)

	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull({
		start = startpos,
		endpos = (startpos +EyeAngles:Forward() *50000),
		mins = Vector( -10,-10,-10),
		maxs = Vector(10,10,10),
		filter = self
	})

	local pos,ang = self:GetBonePosition(tTurret)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,10,0)
	bullet.Dir 			= (TracePlane.HitPos -pos):GetNormalized()
	bullet.Spread 		= Vector(0.03,0.03,0)
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

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +Vector(0,-10,0)
	bullet.Dir 			= (TracePlane.HitPos -pos):GetNormalized()
	bullet.Spread 		= Vector(0.03,0.03,0)
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
end

ENT.TotalBombsFire = 0
function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self.TotalBombsFire >= 12 then
		return
	end
	self:SetNextPrimary(0.3)
	self:TakePrimaryAmmo()
	self.TotalBombsFire = self.TotalBombsFire +1
	if self.TotalBombsFire >= 12 then
		timer.Simple(6,function()
			if IsValid(self) then
				self.TotalBombsFire = 0
			end
		end)
	end
	self:EmitSound("LFS_WBOMBER_BOMB")
	
	self.MirrorPrimary = not self.MirrorPrimary	
	local Mirror = self.MirrorPrimary and -1 or 1
	
	local ent = ents.Create("lunasflightschool_bwii_bomb")
	local Pos = self:LocalToWorld(bomb)
	ent:SetPos(Pos)
	ent:SetAngles(Angle(90,0,0))
	ent.SmallExplosion = true
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker(self:GetDriver())
	ent:SetInflictor(self)
	ent:SetStartVelocity(0)
	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetVelocity(self:GetVelocity() *1 +self:GetUp() *-1800 +self:GetForward() *1100)
	end
	ent.DMG = BWII_DMG_BOMB
	ent.DMGDist = 400
	ent:SetModel("models/cpthazama/bwii/westernfrontier/bomb.mdl")
	constraint.NoCollide(ent,self,0,0)
end


function ENT:SecondaryAttack()
end

function ENT:HandleWeapons(Fire1,Fire2)
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid(Gunner)
	local FireTurret = false
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown(IN_ATTACK)
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
	
	if HasGunner then
		if Gunner:KeyDown(IN_ATTACK) then
			self:AltPrimaryAttack(Gunner,self:GetGunnerSeat(),false)
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

function ENT:RunAI()
	local RangerLength = 15000
	local mySpeed = self:GetVelocity():Length()
	local MinDist = 600 + mySpeed * 2
	local StartPos = self:GetPos()
	
	local TraceFilter = {self,self.wheel_L,self.wheel_R,self.wheel_C}
	
	local FrontLeft = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(0,20,0) ):Forward() * RangerLength } )
	local FrontRight = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(0,-20,0) ):Forward() * RangerLength } )
	
	local FrontLeft2 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(25,65,0) ):Forward() * RangerLength } )
	local FrontRight2 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(25,-65,0) ):Forward() * RangerLength } )
	
	local FrontLeft3 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(-25,65,0) ):Forward() * RangerLength } )
	local FrontRight3 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(-25,-65,0) ):Forward() * RangerLength } )
	
	local FrontUp = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(-20,0,0) ):Forward() * RangerLength } )
	local FrontDown = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:LocalToWorldAngles( Angle(20,0,0) ):Forward() * RangerLength } )

	local Up = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + self:GetUp() * RangerLength } )
	local Down = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - self:GetUp() * RangerLength } )
	
	local Down2 = util.TraceLine( { start = self:LocalToWorld( Vector(0,0,100) ), filter = TraceFilter, endpos = StartPos + Vector(0,0,-RangerLength) } )
	
	local cAvoid = Vector(0,0,0)
	if istable( self.FoundPlanes ) then
		local myRadius = self:BoundingRadius() 
		local myPos = self:GetPos()
		local myDir = self:GetForward()
		for _, v in pairs( self.FoundPlanes ) do
			if IsValid( v ) and v ~= self and v.LFS then
				local theirRadius = v:BoundingRadius() 
				local Sub = (myPos - v:GetPos())
				local Dir = Sub:GetNormalized()
				local Dist = Sub:Length()
				
				if Dist < (theirRadius + myRadius + 200) then
					if math.deg( math.acos( math.Clamp( myDir:Dot( -Dir ) ,-1,1) ) ) < 90 then
						cAvoid = cAvoid + Dir * (theirRadius + myRadius + 500)
					end
				end
			end
		end
	end
	
	local FLp = FrontLeft.HitPos + FrontLeft.HitNormal * MinDist + cAvoid * 8
	local FRp = FrontRight.HitPos + FrontRight.HitNormal * MinDist + cAvoid * 8
	
	local FL2p = FrontLeft2.HitPos + FrontLeft2.HitNormal * MinDist
	local FR2p = FrontRight2.HitPos + FrontRight2.HitNormal * MinDist
	
	local FL3p = FrontLeft3.HitPos + FrontLeft3.HitNormal * MinDist
	local FR3p = FrontRight3.HitPos + FrontRight3.HitNormal * MinDist
	
	local FUp = FrontUp.HitPos + FrontUp.HitNormal * MinDist
	local FDp = FrontDown.HitPos + FrontDown.HitNormal * MinDist
	
	local Up = Up.HitPos + Up.HitNormal * MinDist
	local Dp = Down.HitPos + Down.HitNormal * MinDist
	
	local TargetPos = (FLp+FRp+FL2p+FR2p+FL3p+FR3p+FUp+FDp+Up+Dp) / 10
	
	local alt = (self:GetPos() - Down2.HitPos):Length()
	
	if alt < MinDist then 
		self.TargetRPM = self:GetMaxRPM()
		
		if self:GetStability() < 0.4 then
			self.TargetRPM = self:GetLimitRPM()
			TargetPos.z = self:GetPos().z + 2000
		end
		
		if self.LandingGearUp and mySpeed < 100 and not self:IsPlayerHolding() then
			local pObj = self:GetPhysicsObject()
			if IsValid( pObj ) then
				if pObj:IsMotionEnabled() then
					self:Explode()
				end
			end
		end
	else
		if self:GetStability() < 0.3 then
			self.TargetRPM = self:GetLimitRPM()
			TargetPos.z = self:GetPos().z + 600
		else
			if alt > mySpeed then
				local Target = self:AIGetTarget()
				if IsValid( Target ) then
					if self:AITargetInfront( Target, 65 ) then
						TargetPos = Target:GetPos() + cAvoid * 8 + Target:GetVelocity() * math.abs(math.cos( CurTime() * 150 ) ) * 3
						
						local Throttle = (self:GetPos() - TargetPos):Length() / 8000 * self:GetMaxRPM()
						self.TargetRPM = math.Clamp( Throttle,self:GetIdleRPM(),self:GetMaxRPM())
						
						local startpos =  self:GetRotorPos()
						local tr = util.TraceHull( {
							start = startpos,
							endpos = (startpos + self:GetForward() * 50000),
							mins = Vector( -30, -30, -30 ),
							maxs = Vector( 30, 30, 30 ),
							filter = TraceFilter
						} )
					
						local CanShoot = (IsValid( tr.Entity ) and tr.Entity.LFS and tr.Entity.GetAITEAM) and (tr.Entity:GetAITEAM() ~= self:GetAITEAM() or tr.Entity:GetAITEAM() == 0) or true
						if CanShoot then
							if self:AITargetInfront( Target, 15 ) && (Target:GetPos().z -self:GetPos().z) < 0 && self:GetPos():Distance(Target:GetPos()) <= self.AttackDistance then
								self:HandleWeapons( true )
								
								if self:AITargetInfront( Target, 10 ) && (Target:GetPos().z -self:GetPos().z) < 0 && self:GetPos():Distance(Target:GetPos()) <= self.AttackDistance then
									self:HandleWeapons( true, true )
								end
							end
						end
					else
						if alt > 6000 and self:AITargetInfront( Target, 90 ) then
							TargetPos = Target:GetPos()
						else
							TargetPos = TargetPos
						end
						
						self.TargetRPM = self:GetMaxRPM()
					end
				else
					self.TargetRPM = self:GetMaxRPM()
				end
			else
				self.TargetRPM = self:GetMaxRPM()
				TargetPos.z = self:GetPos().z + 2000
			end
		end
		self:RaiseLandingGear()
	end
	
	if self:IsDestroyed() or not self:GetEngineActive() then
		self.TargetRPM = 0
	end
	
	self.smTargetPos = self.smTargetPos and self.smTargetPos + (TargetPos - self.smTargetPos) * FrameTime() or self:GetPos()
	
	local TargetAng = (self.smTargetPos - self:GetPos()):GetNormalized():Angle()
	
	return TargetAng
end