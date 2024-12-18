AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("gBankStartMoney")

local storedMoney = 0

function addMoney(ent)
    if not IsValid(ent) then return end

    local moneyToAdd = ent:GetMoneyToPrint()

    local ammount = ent:GetStoredMoney()
    ammount = ammount + moneyToAdd
    ent:SetStoredMoney(ammount)
end

function ENT:Initialize()
    self:SetModel("models/props_c17/consolebox01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetStoredMoney(0)
    self:SetMaxPrint(5)
    self:SetMinPrint(2)
    self:SetMoneyToPrint(1000)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
    end

    local maxTime = self:GetMaxPrint()
    local minTime = self:GetMinPrint()
    print(maxTime .. ' ' .. minTime)
    timer.Create("gPrintMoney", math.random(maxTime, minTime), -1, function() addMoney(self) end)

    timer.Start("gPrintMoney")
end

local lastUsedTime = {}
local cooldown = 10

function ENT:Use(player)
    if (player:IsPlayer()) and IsValid(self) then

        local currentTime = CurTime()
        if lastUsedTime[player:SteamID()] and currentTime - lastUsedTime[player:SteamID()] < cooldown then
            return
        end
        lastUsedTime[player:SteamID()] = currentTime

        local ammount = self:GetStoredMoney()

        local playerSteamId = player:SteamID()

        print(ammount .. ' ' .. playerSteamId)

        net.Start("gBankStartMoney")
        net.WriteString(playerSteamId)
        net.WriteUInt(ammount, 32)
        net.Send(player)

        self:SetStoredMoney(0)
    end
end

function ENT:Touch(ent)
    if ent:GetClass() == "gupgradetime" then

        if timer.Exists("gPrintMoney") then
           timer.Remove("gPrintMoney") 
        end
        self:SetMaxPrint(2)
        self:SetMinPrint(0)
        ent:Remove()

        local minTime = self:GetMinPrint()
        local maxTime = self:GetMaxPrint()
        local randomTime = math.random(maxTime, minTime)
        timer.Create("gPrintMoney", randomTime, -1, function() 
            addMoney(self) 
        end)
        return 
    end

    if(ent:GetClass() == "gupgradeammount") then
        if timer.Exists("gPrintMoney") then
            timer.Remove("gPrintMoney") 
        end

        local printAmmount = self:GetMoneyToPrint()
        printAmmount = printAmmount * 1.2
        self:SetMoneyToPrint(printAmmount)

        ent:Remove()

        local minTime = self:GetMinPrint()
        local maxTime = self:GetMaxPrint()
        local randomTime = math.random(maxTime, minTime)
        timer.Create("gPrintMoney", randomTime, -1, function() 
            addMoney(self) 
        end)
        return 
    end
end




