AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

local lMissile = Vector(-36.98,-68.12,50.05)
local rMissile = Vector(-36.98,68.12,50.05)

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 55 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:RunOnSpawn()
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(19.53,0,68.61),Angle(0,90,20)))
	self.FireCount = 0
	self:SetSkin(1)
	self.MirrorPrimary = false
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end
	
function ENT:AltPrimaryAttack( Driver, Pod, AllowPrimary )
	if not self:CanAltPrimaryAttack() then return end
	if not AllowPrimary then AllowPrimary = true end
	if not IsValid(Pod) then Pod = self:GetDriverSeat() end
	if not IsValid(Driver) then Driver = Pod:GetDriver() end
	if not IsValid(Pod) then return end
	if not IsValid(Driver) then return end

	local EyeAngles = Pod:WorldToLocalAngles(Driver:EyeAngles())
	local Forward = -self:GetForward()
	
	local AimDirToForwardDir = math.deg(math.acos(math.Clamp(Forward:Dot(EyeAngles:Forward()),-1,1)))
	if AimDirToForwardDir > 50 then
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

	local pos,ang = self:GetBonePosition(21)
	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= pos +self:GetForward() *-25
	bullet.Dir 			= (TracePlane.HitPos -pos):GetNormalized()
	bullet.Spread 		= Vector(0.03,0.03,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_laser_blue"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= BWII_DMG_HMG
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_DISSOLVE)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_SFIGHTER_TURRET")
end

function ENT:FireMissile(t)
	timer.Simple(t,function()
		if IsValid(self) then
			self:TakePrimaryAmmo()
			self:EmitSound("LFS_SFIGHTER_MISSILE")
			
			self.MirrorPrimary = not self.MirrorPrimary	
			local Mirror = self.MirrorPrimary and -1 or 1
			
			local startpos = self:GetRotorPos()
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
			
			local ent = ents.Create("lunasflightschool_bwii_missile")
			local Pos
			-- print(Mirror)
			if Mirror == 1 then
				Pos = self:LocalToWorld(lMissile)
			else
				Pos = self:LocalToWorld(rMissile)
			end
			ent:SetPos(Pos +self:GetForward() *100)
			ent:SetAngles(self:GetAngles())
			ent:SetNWBool("SolarEffects",true)
			ent:Spawn()
			ent:Activate()
			ent:SetAttacker(self:GetDriver())
			ent:SetInflictor(self)
			ent:SetStartVelocity(self:GetVelocity():Length())
			ent:SetCleanMissile(true)
			ent:SetNWBool("SolarEffects",true)
			if IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():SetVelocity(self:GetVelocity() *1 +self:GetForward() *300)
			end
			
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
				if tr.Hit then
					local Target = tr.Entity
					if IsValid(Target) then
						if string.find(Target:GetClass(),"lunasflightschool") && !string.find(Target:GetClass(),"_bwii_missile") && Target != self then
							ent:SetLockOn(Target)
							ent:SetStartVelocity(0)
						end
					end
				end
			end
			constraint.NoCollide(ent,self,0,0)
		end
	end)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local next = 1.5
	self.FireCount = self.FireCount +1
	if self.FireCount == 2 then
		next = 3.5
		self.FireCount = 0
	end
	self:SetNextPrimary(next)
	self:FireMissile(0)
	self:FireMissile(0.15)
	self:FireMissile(0.3)
end

function ENT:SecondaryAttack( Driver, Pod)
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
		self:SecondaryAttack(Driver)
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