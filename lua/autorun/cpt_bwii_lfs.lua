TEAM_ANGLO = 13
TEAM_FRONTIER = 14
TEAM_SOLAR = 15
TEAM_LEGION = 16
TEAM_TUNDRA = 17
TEAM_XYLVANIA = 18

BWII_AI_WAIT = 1
BWII_AI_FOLLOW = 2
BWII_AI_GUARD = 3
BWII_AI_ATTACK = 4

BWII_HP_GUNSHIP = 6500
BWII_HP_FIGHTER = 6000
BWII_HP_BOMBER = 11500
BWII_HP_STRATODESTROYER = 20000
BWII_HP_TRANSPORTCOPTER = 10000
BWII_HP_SPYBALLOON = 5000

BWII_DMG_ROCKET = 800
BWII_DMG_MISSILE = 600
BWII_DMG_BOMB = 1800
BWII_DMG_MININUKE = 2400
BWII_DMG_MG = 8
BWII_DMG_HMG = 18

hook.Add("CalcMainActivity", "bwii_lfs_customanimations", function(ply)
	local Ent = ply:lfsGetPlane()

	if not IsValid(Ent) then return end	
	local Pod = ply:GetVehicle()
	if Pod:GetNWBool("BWII_StandTurret") then
		if ply.m_bWasNoclipping then 
			ply.m_bWasNoclipping = nil 
			ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM) 
			if CLIENT then 
				ply:SetIK(true)
			end 
		end 
		
		ply.CalcIdeal = ACT_HL2MP_IDLE_DUEL
		ply.CalcSeqOverride = ply:LookupSequence("idle_dual")
		return ply.CalcIdeal, ply.CalcSeqOverride
	elseif Pod:GetNWBool("BWII_Stand") then
		if ply.m_bWasNoclipping then 
			ply.m_bWasNoclipping = nil 
			ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM) 
			if CLIENT then 
				ply:SetIK(true)
			end 
		end 
		
		ply.CalcIdeal = ACT_STAND
		ply.CalcSeqOverride = ply:LookupSequence("idle_all_02")
		return ply.CalcIdeal, ply.CalcSeqOverride
	end
end)

if CLIENT then
local function lfs_HUD_BWII()
	local ply = LocalPlayer()	
	if not IsValid( ply ) or not ply:Alive() then return end
	local pod = ply:GetVehicle()
	if not IsValid(pod) then return end
	local vehicle = ply:lfsGetPlane()
	if not IsValid(vehicle) then return end
	if !string.find(vehicle:GetClass(),"lunasflightschool_bwii") then return end
	local iTeam = ply:lfsGetAITeam()
	local teamTexture
	local teamColor = {r=255,g=255,b=255}
	if iTeam == TEAM_ANGLO then
		teamTexture = "a"
		teamColor = {r=255,g=212,b=0}
	elseif iTeam == TEAM_FRONTIER then
		teamTexture = "w"
		teamColor = {r=30,g=230,b=0}
	elseif iTeam == TEAM_SOLAR then
		teamTexture = "s"
		teamColor = {r=218,g=218,b=218}
	elseif iTeam == TEAM_LEGION then
		teamTexture = "i"
		teamColor = {r=191,g=127,b=255}
	elseif iTeam == TEAM_TUNDRA then
		teamTexture = "t"
		teamColor = {r=230,g=0,b=0}
	elseif iTeam == TEAM_XYLVANIA then
		teamTexture = "x"
		teamColor = {r=100,g=170,b=255}
	else
		teamTexture = "s"
		teamColor = {r=255,g=255,b=255}
	end
	-- local icon = vehicle:GetNWString("bwii_icon")
	local icon = "entities/" .. vehicle:GetClass() .. ".png"
	-- local name = vehicle:GetNWString("bwii_name")
	local name = language.GetPhrase(vehicle:GetClass())
	local hp = vehicle:GetHP()
	local maxhp = vehicle:GetMaxHP()

	local text = name
	local posX = 535
	local posY = 1050
	local color = Color(225,255,225,255)
	draw.SimpleText(text,"Trebuchet24",posX,posY,color)

	local scale = 100
	local scaleB = 32
	local posX = 593
	local posY = 1037
	surface.SetMaterial(Material("bwii/hud_hp.png"))
	surface.SetDrawColor(teamColor.r,teamColor.g,teamColor.b,255)
	surface.DrawTexturedRectRotated(posX,posY,scale,scaleB,0)
	
	local scale = ((120 /maxhp) *hp)
	local scaleB = 35
	local posXB = 593
	local posYB = 1037
	surface.SetMaterial(Material("bwii/bar.vtf"))
	surface.SetDrawColor(255,170,0,255)
	surface.DrawTexturedRectRotated(posXB -scale *(1 -(hp /maxhp)) *0.5,posYB,scale,scaleB,0)

	local scale = 100
	local scaleB = 70
	local posX = 595
	local posY = 985
	surface.SetMaterial(Material("bwii/" .. teamTexture .. "_plat.vtf"))
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRectRotated(posX,posY,scale,scaleB,0)

	local scale = 120
	local posX = 591
	local posY = 945
	surface.SetMaterial(Material(icon))
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRectRotated(posX,posY,scale,scale,0)
		
	-- if hp <= maxhp *0.4 then
		-- local scale = 85
		-- local posX = 591
		-- local posY = 945
		-- surface.SetMaterial(Material("bwii/enemy.png"))
		-- surface.SetDrawColor(255,255,255,255)
		-- surface.DrawTexturedRectRotated(posX,posY,scale,scale,0)
	-- end
end
hook.Add("HUDPaint","lfs_HUD_BWII",lfs_HUD_BWII)
end