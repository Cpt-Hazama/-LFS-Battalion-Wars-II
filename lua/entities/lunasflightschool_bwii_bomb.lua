AddCSLuaFile()

ENT.Type            = "anim"

ENT.Model = "models/cpthazama/bwii/xylvania/bomb.mdl"
ENT.Mass = 20
ENT.DMG = BWII_DMG_BOMB
ENT.DMGDist = 400
ENT.IdleSound = "cpthazama/bwii/bomb_fall.wav"
ENT.ExplodeSound = "cpthazama/bwii/bomb_explode" .. math.random(1,2) .. ".wav"

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "Attacker" )
	self:NetworkVar( "Entity",1, "Inflictor" )
	self:NetworkVar( "Float",0, "StartVelocity" )
end

if SERVER then
	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 20 )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:PhysWake()
		local pObj = self:GetPhysicsObject()
		
		if IsValid( pObj ) then
			pObj:EnableGravity( true ) 
			pObj:SetMass(self.Mass) 
		end
		
		self.SpawnTime = CurTime()
	end

	function ENT:Think()	
		local curtime = CurTime()
		self:NextThink(curtime)
		
		if self.Explode then
			local Inflictor = self:GetInflictor()
			local Attacker = self:GetAttacker()
			util.BlastDamage( IsValid( Inflictor ) and Inflictor or Entity(0), IsValid( Attacker ) and Attacker or Entity(0), self:GetPos(),self.DMGDist,self.DMG)
			
			self:Remove()
		end
		
		if (self.SpawnTime + 12) < curtime then
			self:Remove()
		end
		
		return true
	end

	function ENT:PhysicsCollide( data )
		self.Explode = true
	end

	function ENT:OnTakeDamage( dmginfo )	

	end
else

	function ENT:Initialize()	
		self.Emitter = ParticleEmitter( self:GetPos(), false )
		
		self.Materials = {
			"particle/smokesprites_0001",
			"particle/smokesprites_0002",
			"particle/smokesprites_0003",
			"particle/smokesprites_0004",
			"particle/smokesprites_0005",
			"particle/smokesprites_0006",
			"particle/smokesprites_0007",
			"particle/smokesprites_0008",
			"particle/smokesprites_0009",
			"particle/smokesprites_0010",
			"particle/smokesprites_0011",
			"particle/smokesprites_0012",
			"particle/smokesprites_0013",
			"particle/smokesprites_0014",
			"particle/smokesprites_0015",
			"particle/smokesprites_0016"
		}
		
		self.snd = CreateSound(self,self.IdleSound)
		self.snd:Play()
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:OnRemove()
		
		local Pos = self:GetPos()
		
		self:Explosion( Pos + self:GetVelocity() / 20 )
		
		local random = math.random(1,2)
		self.snd:Stop()
		sound.Play(self.ExplodeSound, Pos, 95, 140, 1 )
	end

	function ENT:Explosion( pos )
		local emitter = self.Emitter
		if not emitter then return end
		if self.SmallExplosion then
			for i = 0,60 do
				local particle = emitter:Add( self.Materials[math.random(1,table.Count( self.Materials ))], pos )
				
				if particle then
					particle:SetVelocity( VectorRand(-1,1) * 600 )
					particle:SetDieTime( math.Rand(4,6) )
					particle:SetAirResistance( math.Rand(200,600) ) 
					particle:SetStartAlpha( 255 )
					particle:SetStartSize( math.Rand(10,30) )
					particle:SetEndSize( math.Rand(80,120) )
					particle:SetRoll( math.Rand(-1,1) )
					particle:SetColor( 50,50,50 )
					particle:SetGravity( Vector( 0, 0, 100 ) )
					particle:SetCollide( false )
				end
			end
			
			for i = 0, 40 do
				local particle = emitter:Add( "sprites/flamelet"..math.random(1,5), pos )
				
				if particle then
					particle:SetVelocity( VectorRand(-1,1) * 500 )
					particle:SetDieTime( 0.14 )
					particle:SetStartAlpha( 255 )
					particle:SetStartSize( 10 )
					particle:SetEndSize( math.Rand(30,60) )
					particle:SetEndAlpha( 100 )
					particle:SetRoll( math.Rand( -1, 1 ) )
					particle:SetColor( 200,150,150 )
					particle:SetCollide( false )
				end
			end
			
			local dlight = DynamicLight( math.random(0,9999) )
			if dlight then
				dlight.pos = pos
				dlight.r = 255
				dlight.g = 180
				dlight.b = 100
				dlight.brightness = 8
				dlight.Decay = 2000
				dlight.Size = 200
				dlight.DieTime = CurTime() + 0.1
			end
		else
			for i = 0,90 do
				local particle = emitter:Add( self.Materials[math.random(1,table.Count( self.Materials ))], pos )
				
				if particle then
					particle:SetVelocity( VectorRand(-1,1) * 1300 )
					particle:SetDieTime( math.Rand(8,12) )
					particle:SetAirResistance( math.Rand(200,600) ) 
					particle:SetStartAlpha( 255 )
					particle:SetStartSize( math.Rand(70,90) )
					particle:SetEndSize( math.Rand(180,210) )
					particle:SetRoll( math.Rand(-1,1) )
					particle:SetColor( 50,50,50 )
					particle:SetGravity( Vector( 0, 0, 100 ) )
					particle:SetCollide( false )
				end
			end
			
			for i = 0, 90 do
				local particle = emitter:Add( "sprites/flamelet"..math.random(1,5), pos )
				
				if particle then
					particle:SetVelocity( VectorRand(-1,1) * 800 )
					particle:SetDieTime(0.2)
					particle:SetStartAlpha( 255 )
					particle:SetStartSize(90)
					particle:SetEndSize( math.Rand(150,210) )
					particle:SetEndAlpha( 100 )
					particle:SetRoll( math.Rand( -1, 1 ) )
					particle:SetColor( 200,150,150 )
					particle:SetCollide( false )
				end
			end
			
			local dlight = DynamicLight( math.random(0,9999) )
			if dlight then
				dlight.pos = pos
				dlight.r = 255
				dlight.g = 180
				dlight.b = 100
				dlight.brightness = 8
				dlight.Decay = 2000
				dlight.Size = 200
				dlight.DieTime = CurTime() + 0.1
			end
		end
	end
end