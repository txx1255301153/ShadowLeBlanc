--***Shadow LeBlanc***--

if myHero.charName ~= "Leblanc" then return end

local version,author,lVersion = "v1.0","TheCallunxz","8.11"

if FileExist(COMMON_PATH .. "Alpha.lua") then
	require 'Alpha'
elseif FileExist(COMMON_PATH .. "Auto/Alpha.lua") then
    require 'Auto/Alpha'
else
	print("ERROR: Alpha.lua is not present in your Scripts/Common folder. Please re open loader.")
end

PrintChat("Thank you for using Shadow LeBlanc | " ..version.. "")

local wPadPos = nil
local rPadPos = nil

local LocalGameTimer				= Game.Timer;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 				= Game.Turret;
local LocalGameWardCount 			= Game.WardCount;
local LocalGameWard 				= Game.Ward;
local LocalGameObjectCount 			= Game.ObjectCount;
local LocalGameObject				= Game.Object;
local LocalGameMissileCount 		= Game.MissileCount;
local LocalGameMissile				= Game.Missile;
local LocalGameParticleCount 		= Game.ParticleCount;
local LocalGameParticle				= Game.Particle;
local CastSpell 					= _G.Control.CastSpell
local LocalGeometry                 = _G.Alpha.Geometry
local LocalBuffManager              = _G.Alpha.BuffManager
local LocalObjectManager            = _G.Alpha.ObjectManager
local LocalDamageManager            = _G.Alpha.DamageManager
local LocalGameIsChatOpen			= Game.IsChatOpen;


local MenuIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e2/Mirror_Image.png"

class "ShadowLeBlanc"

function ShadowLeBlanc:__init()
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
end

function ShadowLeBlanc:LoadSpells()
	Q = {Range = 700, Delay = 0.25, Speed = 2000, Collision = false}
	W = {Range = 700, Delay = 0.25, Speed = 1450, Radius = 260, Collision = false}
	E = {Range = 700, Delay = 0.25, Speed = 1750, Radius = 27.5, Collision = true, IsLine = true}
end

function ShadowLeBlanc:LoadMenu()
    LBMenu = MenuElement({type = MENU, id = "LBMenu", name = "Shadow LeBlanc | " ..version.. "", icon = MenuIcon})
    
	LBMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	LBMenu.Combo:MenuElement({id = "useQ", name = "Q", value = true})
    LBMenu.Combo:MenuElement({id = "useW", name = "W", value = true})
    LBMenu.Combo:MenuElement({id = "useW2", name = "W2", value = true})
    LBMenu.Combo:MenuElement({id = "useE", name = "E", value = true})
    LBMenu.Combo:MenuElement({id = "useR", name = "R", value = true})
    LBMenu.Combo:MenuElement({id = "useSmart", name = "Smart Combo", value = true})
    LBMenu.Combo:MenuElement({id = "Ignite", name = "Ignite", value = true})

    LBMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
    LBMenu.Harass:MenuElement({id = "useQ", name = "Q", value = true})
    LBMenu.Harass:MenuElement({id = "useW", name = "W", value = true})
    LBMenu.Harass:MenuElement({id = "useW2", name = "W2", value = true})
    LBMenu.Harass:MenuElement({id = "useE", name = "E", value = false})

    LBMenu:MenuElement({id = "Clear", name = "Clear", type = MENU})
    LBMenu.Clear:MenuElement({id = "useQ", name = "Q (Last Hit)", value = true})
    LBMenu.Clear:MenuElement({id = "wCount", name = "Minion Count to W", value = 4, min = 0, max = 6, step = 1})
    LBMenu.Clear:MenuElement({id = "wLastHit", name = "Only W to Last Hit", value = true})
    LBMenu.Clear:MenuElement({id = "wTower", name = "W Under Turret?", value = false})

    LBMenu:MenuElement({type = MENU, id = "Key", name = "Keys Settings"})
	LBMenu.Key:MenuElement({id = "Combo", name = "Combo Key", key = 32})
	LBMenu.Key:MenuElement({id = "Harass", name = "Harass Key", key = string.byte("C")})
	LBMenu.Key:MenuElement({id = "Clear", name = "Clear Key", key = string.byte("V")})

    LBMenu:MenuElement({id = "blank", type = SPACE , name = ""})
	LBMenu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..version.. " - LoL Ver: "..lVersion.. ""})
	LBMenu:MenuElement({id = "blank", type = SPACE , name = "by "..author.. ""})
end

function ShadowLeBlanc:GetSmartCombo()

    target = Utils:GetTarget(700, false)
    if target == nil then return end

    local qDamage = 0
    local wDamage = 0
    local eDamage = 0
    local rQDamage = 0
    local rWDamage = 0
    local rEDamage = 0

    if(Utils:Ready(_Q)) then
        qDamage = 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        if LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/Q.Speed) + Q.Delay) then
            qDamage = qDamage + 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        end
        if LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/Q.Speed) + Q.Delay) then
            qDamage = qDamage + ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        end
        qDamage = LocalDamageManager:CalculateMagicDamage(myHero, target, qDamage)
    end
    if(Utils:Ready(_W)) then
        wDamage = 45 + ((myHero:GetSpellData(_W).level) * 40) + myHero.ap * 0.60
        if LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/W.Speed)) then
            wDamage = wDamage + 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        end
        if LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/W.Speed)) then
            wDamage = wDamage + ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        end
        wDamage = LocalDamageManager:CalculateMagicDamage(myHero, target, wDamage)
    end
    if(Utils:Ready(_E)) then
        eDamage = 20 + ((myHero:GetSpellData(_E).level) * 20) + myHero.ap * 0.30
        if LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay) then
            eDamage = eDamage + 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        end
        if LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay) then
            eDamage = eDamage + ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        end
        eDamage = LocalDamageManager:CalculateMagicDamage(myHero, target, eDamage)
    end
    if(Utils:Ready(_R) and Utils:GetRType() == "Q") then
        rQDamage = ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        if LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/Q.Speed) + Q.Delay) then
            rQDamage = rQDamage + 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        end
        if LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/Q.Speed) + Q.Delay) then
            rQDamage = rQDamage + ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        end
        rQDamage = LocalDamageManager:CalculateMagicDamage(myHero, target, rQDamage)
    end
    if(Utils:Ready(_R) and Utils:GetRType() == "W") then
        rWDamage = ((myHero:GetSpellData(_R).level) * 150) + myHero.ap * 0.75
        if LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/W.Speed)) then
            rWDamage = rWDamage + 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        end
        if LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/W.Speed)) then
            rWDamage = rWDamage + ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        end
        rWDamage = LocalDamageManager:CalculateMagicDamage(myHero, target, rWDamage)
    end
    if(Utils:Ready(_R) and Utils:GetRType() == "E") then
        rEDamage = ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        if LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay) then
            rEDamage = rEDamage + 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40
        end
        if LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay) then
            rEDamage = rEDamage + ((myHero:GetSpellData(_R).level) * 70) + myHero.ap * 0.40
        end
        rEDamage = LocalDamageManager:CalculateMagicDamage(myHero, target, rEDamage)
    end

    local extraIncoming = LocalDamageManager:RecordedIncomingDamage(target)
    local predictedHealth = target.health - extraIncoming
    
    if (predictedHealth > 0) and (qDamage > predictedHealth) then
        if(LBMenu.Combo.useQ:Value()) then
            self:ComboQ(false)
        end
    end

    if (predictedHealth > 0) and (wDamage > predictedHealth) then
        if(LBMenu.Combo.useW:Value()) then
            self:ComboW()
        end
    end

    if (predictedHealth > 0) and (eDamage > predictedHealth) then
        if(LBMenu.Combo.useE:Value()) then
            self:ComboE()
        end
    end

    if (predictedHealth > 0) and (rQDamage > predictedHealth) then
        if(LBMenu.Combo.useR:Value()) then
            self:ComboAnyR(false)
        end
    end

    if (predictedHealth > 0) and (rWDamage > predictedHealth) then
        if(LBMenu.Combo.useR:Value()) then
            self:ComboAnyR(false)
        end
    end

    if (predictedHealth > 0) and (rEDamage > predictedHealth) then
        if(LBMenu.Combo.useR:Value()) then
            self:ComboAnyR(false)
        end
    end

    if(myHero.levelData.lvl >= 6) then --AFTER LVL 6 COMBOS
        if (Utils:Ready(_W)) then
            local combo1Damage = qDamage + qDamage + wDamage +rWDamage + eDamage
            local combo2Damage = qDamage + qDamage + rQDamage + rQDamage + wDamage + eDamage

            if (predictedHealth > 0) and (combo1Damage > predictedHealth) then
                if(LBMenu.Combo.useQ:Value()) then
                    self:ComboQ(true)
                end
                if(LBMenu.Combo.useW:Value()) then
                    self:ComboW()
                end
                if(LBMenu.Combo.useR:Value()) then
                    self:ComboAnyR()
                end
                if(LBMenu.Combo.useE:Value()) then
                    self:ComboE()
                end
                if(LBMenu.Combo.useW2:Value()) then
                    self:ComboW2(-1)
                end
            end

            if(combo1Damage > combo2Damage) then
                if(LBMenu.Combo.useQ:Value()) then
                    self:ComboQ(true)
                end
                if(LBMenu.Combo.useW:Value()) then
                    self:ComboW()
                end
                if(LBMenu.Combo.useR:Value()) then
                    self:ComboAnyR()
                end
                if(LBMenu.Combo.useE:Value()) then
                    self:ComboE()
                end
                if(LBMenu.Combo.useW2:Value()) then
                    self:ComboW2(-1)
                end
            else
                if(LBMenu.Combo.useQ:Value()) then
                    self:ComboQ(true)
                end
                if(LBMenu.Combo.useR:Value()) then
                    self:ComboAnyR()
                end
                if(LBMenu.Combo.useW:Value()) then
                    self:ComboW()
                end
                if(LBMenu.Combo.useR:Value()) then
                    self:ComboAnyR()
                end
                if(LBMenu.Combo.useE:Value()) then
                    self:ComboE()
                end
                if(LBMenu.Combo.useR:Value()) then
                    self:ComboAnyR()
                end
                if(LBMenu.Combo.useW2:Value()) then
                    self:ComboW2(-1)
                end
            end
        else
            if(Utils:GetRType() == "W") then
                if(LBMenu.Combo.useR:Value()) then
                    self:ComboAnyR()
                end
            end
            if(LBMenu.Combo.useE:Value()) then
                self:ComboE()
            end
            if(LBMenu.Combo.useQ:Value()) then
                self:ComboQ(true)
            end
            if(LBMenu.Combo.useR:Value()) then
                self:ComboAnyR()
            end
            if(LBMenu.Combo.useW:Value()) then
                self:ComboW()
            end
            if(LBMenu.Combo.useR:Value()) then
                self:ComboAnyR()
            end
            if(LBMenu.Combo.useW2:Value()) then
                self:ComboW2(-1)
            end
        end
    else --PRE LVL 6 COMBOS
        if (Utils:Ready(_W)) then
            if(LBMenu.Combo.useQ:Value()) then
                self:ComboQ(true)
            end
            if(LBMenu.Combo.useW:Value()) then
                self:ComboW()
            end
            if(LBMenu.Combo.useE:Value()) then
                self:ComboE()
            end
            if(LBMenu.Combo.useW2:Value()) then
                self:ComboW2(-1)
            end
        else
            if(LBMenu.Combo.useE:Value()) then
                self:ComboE()
            end
            if(LBMenu.Combo.useQ:Value()) then
                self:ComboQ(true)
            end
            if(LBMenu.Combo.useW2:Value()) then
                self:ComboW2(-1)
            end
        end
    end
end

function ShadowLeBlanc:Tick()
    if myHero.dead or LocalGameIsChatOpen == true or Utils:IsRecalling() == true then return end

    if LBMenu.Key.Combo:Value() then
        if(LBMenu.Combo.useSmart:Value()) then
            self:GetSmartCombo()
        else
            if(LBMenu.Combo.useQ:Value()) then
                self:ComboQ(true)
            end
            if(LBMenu.Combo.useR:Value()) then
                self:ComboAnyR()
            end
            if(LBMenu.Combo.useW:Value()) then
                self:ComboW()
            end
            if(LBMenu.Combo.useR:Value()) then
                self:ComboAnyR()
            end
            if(LBMenu.Combo.useE:Value()) then
                self:ComboE()
            end
            if(LBMenu.Combo.useR:Value()) then
                self:ComboAnyR()
            end
            if(LBMenu.Combo.useW2:Value()) then
                self:ComboW2(-1)
                self:ComboR2(-1)
            end
        end
    end

    if LBMenu.Key.Harass:Value() then
        if(LBMenu.Harass.useQ:Value()) then
            self:ComboQ(false)
        end

        if(LBMenu.Harass.useW:Value()) then
            self:ComboW()
        end

        if(LBMenu.Harass.useE:Value()) then
            self:ComboE()
        end
        
        if(LBMenu.Harass.useW2:Value()) then
            self:ComboW2(0)
        end
    end

    if LBMenu.Key.Clear:Value() then
        self:OnClear()
    end
end

function ShadowLeBlanc:AutoE()
    
end

function ShadowLeBlanc:OnClear()
    self:ComboW2(0)
    if (myHero.attackData.state == STATE_WINDUP or Utils:IsWindingUp(myHero) == true) then return end

    local wDamage = 0
    local qDamage = 0

    local EnemyMinions = Utils:GetEnemyMinions(700)

    if(Utils:Ready(_W)) then
        wDamage = 45 + ((myHero:GetSpellData(_W).level) * 40) + myHero.ap * 0.60

        if #EnemyMinions >= LBMenu.Clear.wCount:Value() then
            for i = 1, #EnemyMinions do
                local minion = EnemyMinions[i]

                if not (LBMenu.Clear.wTower:Value()) then
                    if(Utils:IsUnderTurret(minion.pos)) then return end
                end

                local EnemyMinionsNear = Utils:GetEnemyMinions(W.Radius, minion)
                if(#EnemyMinionsNear >= LBMenu.Clear.wCount:Value()) then
                    if(LBMenu.Clear.wLastHit:Value()) then
                        for i = 1, #EnemyMinionsNear do
                            local newMinion = EnemyMinionsNear[i]
                            qDamage = LocalDamageManager:CalculateMagicDamage(myHero, newMinion, qDamage)
                            local extraIncoming = LocalDamageManager:RecordedIncomingDamage(newMinion)
                            local predictedHealth = newMinion.health - extraIncoming
                            if(predictedHealth > 0 and wDamage > predictedHealth) then
                                Utils:CastSpell(HK_W, minion.pos)
                            end
                        end
                    else
                        Utils:CastSpell(HK_W, minion.pos)
                    end
                end
            end
        end
    end

    if(LBMenu.Clear.useQ:Value()) then
        if(Utils:Ready(_Q)) then
            qDamage = 30 + ((myHero:GetSpellData(_Q).level) * 25) + myHero.ap * 0.40

            for i = 1, #EnemyMinions do
                local minion = EnemyMinions[i]

                qDamage = LocalDamageManager:CalculateMagicDamage(myHero, minion, qDamage)

                local extraIncoming = LocalDamageManager:RecordedIncomingDamage(minion)
                local predictedHealth = minion.health - extraIncoming

                if(predictedHealth > 0 and qDamage > predictedHealth) then
                    Utils:CastSpell(HK_Q, minion.pos)
                end
            end
        end
    end
end

LocalObjectManager:OnParticleCreate(function(particle) 
    if(particle.name == "LeBlanc_Base_W_return_indicator") then
        wPadPos = particle.pos
    end
    if(particle.name == "LeBlanc_Base_RW_return_indicator") then
        rPadPos = particle.pos
    end
end)

LocalObjectManager:OnParticleDestroy(function(particle) 
    if(particle.name == "LeBlanc_Base_W_return_indicator") then
        wPadPos = nil
    end
    if(particle.name == "LeBlanc_Base_RW_return_indicator") then
        rPadPos = nil
    end
end)

function ShadowLeBlanc:ComboQ(combo)
    if (Utils:Ready(_Q)) then
        target = Utils:GetTarget(Q.Range, false)
        if target == nil then return end
        if (Utils:CanTarget(target)) then
            if combo then
                if(Utils:Ready(_W) or (LocalBuffManager:HasBuff(target, "LeblancE", (Utils:GetDistance(myHero.pos, target.pos)/Q.Speed) + Q.Delay) or LocalBuffManager:HasBuff(target, "LeblancRE", (Utils:GetDistance(myHero.pos, target.pos)/Q.Speed) + Q.Delay)) or Utils:Ready(_E) or Utils:Ready(_R)) then
                    Utils:CastSpell(HK_Q, target.pos)
                elseif (myHero.levelData.lvl < 3) then
                    Utils:CastSpell(HK_Q, target.pos)
                end
            else
                Utils:CastSpell(HK_Q, target.pos)
            end
        end
    end
end

function ShadowLeBlanc:ComboAnyR(combo)
    local combo = combo or true
    if (Utils:Ready(_R) and Utils:GetRType() ~= "W2") then
        target = Utils:GetTarget(Utils:GetRRange(), false)
        if target == nil then return end
        if (Utils:CanTarget(target)) then
            if(Utils:GetRType() == "E") then
                if (combo == true) then
                    if((LocalBuffManager:HasBuff(target, "LeblancE", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay)) or (LocalBuffManager:HasBuff(target, "LeblancQMark", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay)) or (LocalBuffManager:HasBuff(target, "LeblancRQMark", (Utils:GetDistance(myHero.pos, target.pos)/E.Speed) + E.Delay))) then
                        local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, E.Range, E.Delay, E.Speed, E.Radius, E.Collision)
                        if(accuracy >= 2) then
                            Utils:CastSpell(HK_R, castPosition)
                        end
                    end
                else
                    local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, E.Range, E.Delay, E.Speed, E.Radius, E.Collision)
                    if(accuracy >= 2) then
                        Utils:CastSpell(HK_R, castPosition)
                    end
                end
                
            else
                Utils:CastSpell(HK_R, target.pos)
            end
        end
    end
end

function ShadowLeBlanc:ComboW()
    if (Utils:Ready(_W) and Utils:GetWType() ~= "W2") then
        target = Utils:GetTarget(W.Range, false)
        if target == nil then return end
        if (Utils:CanTarget(target)) then
            Utils:CastSpell(HK_W, target.pos)
        end
    end
end

function ShadowLeBlanc:ComboW2(bias)
    if (Utils:Ready(_W) and Utils:GetWType() == "W2") then
        if(wPadPos ~= nil) then
            target = Utils:GetTarget(Q.Range, false)
            if target == nil then return end
            if(self:checkSafeArea(700, wPadPos, target, bias)) then
                if(eChain == false and rChain == false) or (Utils:GetDistance(target, wPadPos) < 900) then
                    Utils:CastSpell(HK_W)
                end
            elseif(self:checkSafeArea(700, rPadPos, target)) and (Utils:CurrentPctLife(target) > Utils:CurrentPctLife(myHero)) then
                if(eChain == false and rChain == false) or (Utils:GetDistance(target, wPadPos) < 900) then
                    Utils:CastSpell(HK_W)
                end
            end
        end
    end
end

function ShadowLeBlanc:ComboR2(bias)
    if (Utils:Ready(_R) and Utils:GetRType() == "W2") then
        if(rPadPos ~= nil) then
            target = Utils:GetTarget(Q.Range, false)
            if target == nil then return end
            if(self:checkSafeArea(700, rPadPos, target, bias)) then
                if(eChain == false and rChain == false) or (Utils:GetDistance(target, rPadPos) < 900) then
                    Utils:CastSpell(HK_R)
                end
            elseif(self:checkSafeArea(700, rPadPos, target)) and (Utils:CurrentPctLife(target) > Utils:CurrentPctLife(myHero)) then
                if(eChain == false and rChain == false) or (Utils:GetDistance(target, rPadPos) < 900) then
                    Utils:CastSpell(HK_R)
                end
            end
        end
    end
end

function ShadowLeBlanc:ComboE()
    if (Utils:Ready(_E)) then
        target = Utils:GetTarget(E.Range, false)
        if target == nil then return end
        if (Utils:CanTarget(target)) then
            local castPosition, accuracy = LocalGeometry:GetCastPosition(myHero, target, E.Range, E.Delay, E.Speed, E.Radius, E.Collision)
            if(accuracy >= 2) then
                Utils:CastSpell(HK_E, castPosition)
            end
        end
    end
end

function ShadowLeBlanc:checkSafeArea(radius, areaPos, target, bias)
    local bias = bias or 0
    local closeEnemies = Utils:GetEnemyHeroes(radius, areaPos, target)
    local closeAllies = Utils:GetAllyHeroes(radius, areaPos, target)
    local closeEnemiesHere = Utils:GetEnemyHeroes(radius, myHero.pos, target)
    local closeAlliesHere = Utils:GetAllyHeroes(radius, myHero.pos, target)
    local safelvl = 0
    local safelvlhere = 0
    
    for i = 1, #closeEnemiesHere do
        local enemy = closeEnemiesHere[i];
        if(enemy ~= target) then
            safelvlhere = safelvlhere - 1
            if(enemy.health > myHero.health) then
                safelvlhere = safelvlhere - 1
            end
        end
    end

    for i = 1, #closeAlliesHere do
        local ally = closeAlliesHere[i];
        safelvlhere = safelvlhere + 1
        if(ally.health > myHero.health) then
            safelvlhere = safelvlhere + 1
        end
    end

    for i = 1, #closeEnemies do
        local enemy = closeEnemies[i];
        if(enemy ~= target) then
            safelvl = safelvl - 1
            if(enemy.health > myHero.health) then
                safelvl = safelvl - 1
            end
        end
    end

    for i = 1, #closeAllies do
        local ally = closeAllies[i];
        safelvl = safelvl + 1
        if(ally.health > myHero.health) then
            safelvl = safelvl + 1
        end
    end

    return (safelvl + bias >= safelvlhere)
end

class "Utils"

function Utils:GetDistanceSqr(a, b)
	if a.pos ~= nil then
		a = a.pos;
	end
	if b.pos ~= nil then
		b = b.pos;
	end
	if a.z ~= nil and b.z ~= nil then
		local x = (a.x - b.x)
		local z = (a.z - b.z)
		return x * x + z * z
	else
		local x = (a.x - b.x)
		local y = (a.y - b.y)
		return x * x + y * y
	end
end

function Utils:GetDistance(a, b)
	return math.sqrt(self:GetDistanceSqr(a, b))
end

function Utils:GetEnemyHeroes(range, fromPos, target)
    local result = {};
    for i = 1, LocalGameHeroCount() do
        local hero = LocalGameHero(i);
        if _G.SDK.Utilities:IsValidTarget(hero) and hero.isEnemy and (hero ~= target) then
            if _G.SDK.Utilities:IsInRange(fromPos, hero, range) then
                _G.SDK.Linq:Add(result, hero);
            end
        end
    end
    return result;
end

function Utils:GetAllyHeroes(range, fromPos, target)
    local result = {};
    for i = 1, LocalGameHeroCount() do
        local hero = LocalGameHero(i);
        if _G.SDK.Utilities:IsValidTarget(hero) and not hero.isEnemy and (hero ~= myHero) then
            if _G.SDK.Utilities:IsInRange(fromPos, hero, range) then
                _G.SDK.Linq:Add(result, hero);
            end
        end
    end
    return result;
end

function Utils:IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function Utils:IsWindingUp(unit)
	return unit.activeSpell.valid
end

function Utils:GetEnemyMinions(range, pos)
    local pos = pos or myHero
	local result = {}
	local counter = 1
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion.isEnemy and minion.team ~= 300 and minion.valid and minion.alive and minion.visible and minion.isTargetable then
			if self:GetDistanceSqr(pos, minion) <= range * range then
				result[counter] = minion
				counter = counter + 1
			end
		end
	end
	return result
end

function Utils:CanTarget(target)
	return target and target.pos and target.isEnemy and target.alive and target.health > 0 and target.visible and target.isTargetable
end

function Utils:Ready(spellSlot)
	return Game.CanUseSpell(spellSlot) == 0
end

function Utils:GetRType()
    local type
    if(myHero:GetSpellData(_R).name == "LeblancRQ") then
        type = "Q"
    end
    if(myHero:GetSpellData(_R).name == "LeblancRW") then
        type = "W"
    end
    if(myHero:GetSpellData(_R).name == "LeblancRWReturn") then
        type = "W2"
    end
    if(myHero:GetSpellData(_R).name == "LeblancRE") then
        type = "E"
    end
	return type
end

function Utils:GetWType()
    local type
    if(myHero:GetSpellData(_W).name == "LeblancW") then
        type = "W"
    end
    if(myHero:GetSpellData(_W).name == "LeblancWReturn") then
        type = "W2"
    end
	return type
end

function Utils:GetRRange()
    local rRange
    if(self:GetRType() == "Q") then
        rRange = Q.Range
    end
    if(self:GetRType() == "W") then
        rRange = W.Range
    end
    if(self:GetRType() == "W2") then
        rRange = W.Range
    end
    if(self:GetRType() == "E") then
        rRange = E.Range
    end
    return rRange
end

function Utils:IsUnderTurret(pos)
	local EnemyTurrets = self:GetEnemyTurrets(2000)
	for i = 1, #EnemyTurrets do
		local turret = EnemyTurrets[i]
		if self:GetDistanceSqr(pos, turret.pos) <= (760 + turret.boundingRadius + myHero.boundingRadius) ^ 2 then
			return true
		end
	end
	return false
end

function Utils:GetEnemyTurrets(range)
	local result = {}
	local counter = 1
	for i = 1, LocalGameTurretCount() do
		local turret = LocalGameTurret(i);
		if turret.isEnemy and turret.alive and turret.visible and turret.isTargetable then
			if self:GetDistanceSqr(myHero, turret) <= range * range then
				result[counter] = turret
				counter = counter + 1
			end
		end
	end
	return result
end

function Utils:CurrentPctLife(entity)
	local pctLife =  entity.health/entity.maxHealth  * 100
	return pctLife
end

function Utils:CurrentPctMana(entity)
	local pctMana =  entity.mana/entity.maxMana * 100
	return pctMana
end

function Utils:EnableOrb(bool)
    if _G.EOWLoaded then
        EOW:SetMovements(bool)
        EOW:SetAttacks(bool)
    elseif _G.SDK and _G.SDK.Orbwalker then
        _G.SDK.Orbwalker:SetMovement(bool)
        _G.SDK.Orbwalker:SetAttack(bool)
    else
        GOS.BlockMovement = not bool
        GOS.BlockAttack = not bool
    end
end

function Utils:GetTarget(range, isAD)
	if forcedTarget and LocalGeometry:IsInRange(myHero.pos, forcedTarget.pos, range) then return forcedTarget end
	if isAD then		
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	else
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
	end
end

function Utils:CastSpell(key, pos, isLine)
	if not pos then Control.CastSpell(key) return end
	
	if type(pos) == "userdata" and pos.pos then
		pos = pos.pos
	end
	
	if not pos:ToScreen().onScreen and isLine then			
		pos = myHero.pos + (pos - myHero.pos):Normalized() * 250
	end
	
	if not pos:ToScreen().onScreen then
		return
	end
		
	self:EnableOrb(false)
	Control.CastSpell(key, pos)
	self:EnableOrb(true)		
end

function OnLoad()
	ShadowLeBlanc()
end