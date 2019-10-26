AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

local lRocket1 = Vector(30.75,60.93,31.96)
local lRocket2 = Vector(30.78,85.39,25.8)
local rRocket1 = Vector(30.75,-60.93,31.96)
local rRocket2 = Vector(30.78,-85.39,25.8)

ENT.AIAttackRange = 50

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 55 )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:RunOnSpawn()
	self:GetDriverSeat().ExitPos = Vector(100,math.Rand(-150,150),15)
	self.MirrorPrimary = 1
end
	
function ENT:SecondaryAttack( Driver, Pod )
	if not self:CanSecondaryAttack() then return end
	if not IsValid(Pod) then Pod = self:GetDriverSeat() end
	if not IsValid(Driver) then Driver = Pod:GetDriver() end
	if not IsValid(Pod) then return end
	if not IsValid(Driver) then return end

	local EyeAngles = Pod:WorldToLocalAngles(Driver:EyeAngles())
	local Forward = self:GetForward()
			
	self:SetNextSecondary(0.1)

	local AimDirToForwardDir = math.deg(math.acos(math.Clamp(Forward:Dot(EyeAngles:Forward()),-1,1)))
	if AimDirToForwardDir > 50 then
		return
	end

	local startpos =  self:GetRotorPos()
	local TracePlane = util.TraceHull({
		start = startpos,
		endpos = (startpos +EyeAngles:Forward() *50000),
		mins = Vector( -10,-10,-10),
		maxs = Vector(10,10,10),
		filter = self
	})

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= self:GetBonePosition(5) +self:GetForward() *15
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= 8
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_IBOMBER_GUN")
	self:TakeSecondaryAmmo()

	local bullet = {}
	bullet.Num 			= 1
	bullet.Src 			= self:GetBonePosition(4) +self:GetForward() *15
	bullet.Dir 			= (TracePlane.HitPos - bullet.Src):GetNormalized()
	bullet.Spread 		= Vector(0.09,0.09,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= "lfs_tracer_white"
	bullet.Force		= 15
	bullet.HullSize 	= 10
	bullet.Damage		= 8
	bullet.Attacker 	= Driver
	bullet.AmmoType 	= "Pistol"
	bullet.Callback 	= function(att,tr,dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets(bullet)
	self:EmitSound("LFS_IBOMBER_GUN")
	self:TakeSecondaryAmmo()
end

ENT.TotalBombsFire = 0
function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self.TotalBombsFire >= 4 then
		return
	end
	self:SetNextPrimary(0.28)
	self:TakePrimaryAmmo()
	self:EmitSound("LFS_IGUNSHIP_MISSILE")

	self.TotalBombsFire = self.TotalBombsFire +1
	if self.TotalBombsFire >= 4 then
		timer.Simple(1,function()
			if IsValid(self) then
				self.TotalBombsFire = 0
			end
		end)
	end
	
	self.MirrorPrimary = self.MirrorPrimary +1
	if self.MirrorPrimary == 5 then
		self.MirrorPrimary = 1
	end

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
	
	local ent = ents.Create("lunasflightschool_bwii_missile")
	local Pos
	if self.MirrorPrimary == 1 then
		Pos = self:LocalToWorld(lRocket1)
	elseif self.MirrorPrimary == 2 then
		Pos = self:LocalToWorld(lRocket2)
	elseif self.MirrorPrimary == 3 then
		Pos = self:LocalToWorld(rRocket1)
	elseif self.MirrorPrimary == 4 then
		Pos = self:LocalToWorld(rRocket2)
	end
	ent:SetPos(Pos +self:GetForward() *50)
	if self:GetAI() then
		local Target = self:AIGetTarget()
		if IsValid(Target) then
			if self:AITargetInfront(Target,self.AIAttackRange) then
				ent:SetAngles((Target:GetPos() -Pos):Angle())
			end
		end
	else
		ent:SetAngles((tr.HitPos -Pos):Angle())
	end
	ent.FireStraight = true
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker(self:GetDriver())
	ent:SetInflictor(self)
	ent:SetStartVelocity(self:GetVelocity():Length())
	ent:SetCleanMissile(true)
	ent.FireStraight = true
	constraint.NoCollide(ent,self,0,0) 
end

function ENT:HandleWeapons(Fire1,Fire2)
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid(Gunner)
	
	if IsValid(Driver) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown(IN_ATTACK)
		end
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	end

	if self:GetAI() then
		local Target = self:AIGetTarget()
		
		if IsValid( Target ) then
			if self:AITargetInfront( Target, self.AIAttackRange ) then
				Fire1 = true
			end
		end
	end

	if Fire1 then
		self:PrimaryAttack()
	end

	if Fire2 then
		self:SecondaryAttack(Driver)
	end
end

function ENT:OnEngineStarted()
	self:EmitSound("lfs/heli_start_generic.ogg")
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

function ENT:OnRotorDestroyed()
	self:EmitSound("physics/metal/metal_box_break2.wav")
	self:Destroy()
end

-- function ENT:HandleActive()
	-- local gPod = self:GetGunnerSeat()
	
	-- if IsValid( gPod ) then
		-- local Gunner = gPod:GetDriver()
		
		-- if Gunner ~= self:GetGunner() then
			-- self:SetGunner( Gunner )
			
			-- if IsValid( Gunner ) then
				-- Gunner:CrosshairEnable() 
			-- end
		-- end
		
		-- if IsValid( Gunner ) then
			-- if self.HideDriver then
				-- Gunner:SetNoDraw(true)
			-- end
			-- Gunner:lfsBuildControls()
		-- end
	-- end
	
	-- local Pod = self:GetDriverSeat()
	
	-- if not IsValid( Pod ) then
		-- self:SetActive( false )
		-- return
	-- end
	
	-- local Driver = Pod:GetDriver()
	-- local Active = self:GetActive()
	
	-- if Driver ~= self:GetDriver() then
		-- if self.HideDriver then
			-- if IsValid( self:GetDriver() ) then
				-- self:GetDriver():SetNoDraw( false )
			-- end
			-- if IsValid( Driver ) then
				-- Driver:SetNoDraw( true )
			-- end
		-- end
		
		-- self:SetDriver( Driver )
		-- self:SetActive( IsValid( Driver ) )
		
		-- if IsValid( Driver ) then
			-- Driver:lfsBuildControls()
		-- end
		
		-- if Active then
			-- self:EmitSound( "vehicles/atv_ammo_close.wav" )
		-- else
			-- self:EmitSound( "vehicles/atv_ammo_open.wav" )
		-- end
	-- end
	
	-- local Time = CurTime()
	
	-- self.NextSetInertia = self.NextSetInertia or 0
	
	-- if self.NextSetInertia < Time then
		-- local inea = Active or self:GetEngineActive() or (self:GetStability() > 0.1) or not self:HitGround()
		-- local TargetInertia = inea and self.Inertia or self.LFSInertiaDefault
		
		-- self.NextSetInertia = Time + 1 -- !!!hack!!! reset every second. There are so many factors that could possibly break this like touching the planes with the physgun which sometimes causes ent:GetInertia() to return a wrong value?!?!
		
		-- local PObj = self:GetPhysicsObject()
		-- if IsValid( PObj ) then
			-- if PObj:IsMotionEnabled() then -- only set when unfrozen
				-- PObj:SetMass( self.Mass ) -- !!!hack!!!
				-- PObj:SetInertia( TargetInertia ) -- !!!hack!!!
			-- end
		-- end
	-- end
-- end