AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local doBeam = false
util.AddNetworkString("gLaserWeaponDraw")
util.AddNetworkString("gLaserWeaponStop")
util.AddNetworkString("gLaserSendCharge")
local charge = 0

function SWEP:Initialize()
    self:SetlaserWeaponCharge(0)
end


function SWEP:PrimaryAttack()
    --if not self:CanPrimaryAttack() then return end
    local player = self:GetOwner()

    if self:GetlaserWeaponCharge() <= 0 then
        player:PrintMessage(HUD_PRINTTALK, "You need to charge this weapon before you can shoot!")
        return 
    end

    local startPos = self:GetOwner():GetShootPos()
    local forwardVector = self:GetOwner():GetAimVector()
    local endPos = startPos + forwardVector * 10000

    local traceLine = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = self:GetOwner()
    })

    local laserEndPos = traceLine.HitPos
    if not startPos or not laserEndPos then
        print("Did not hit anything with laser weapon") -- This really shouldnt ever happen lol
        return
    end

    if traceLine.Hit and IsValid(traceLine.Entity) then
        local hitEntity = traceLine.Entity
        if IsValid(hitEntity) then
            if hitEntity:IsNPC() or hitEntity:IsPlayer() then
                hitEntity:TakeDamage(5, self:GetOwner(), self)
            end
        end
    end

    net.Start("gLaserWeaponDraw")
    net.WriteVector(startPos)
    net.WriteVector(laserEndPos)
    net.Send(self:GetOwner())

    self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
end

local maxCharge = 150

function SWEP:Think()
    if self:GetOwner():KeyDown(IN_ATTACK) and self:GetlaserWeaponCharge() > 0 then
        self:PrimaryAttack()
        self:SetlaserWeaponCharge(self:GetlaserWeaponCharge() - 1)
        doBeam = true
    elseif doBeam then
        net.Start("gLaserWeaponStop")
        net.Send(self:GetOwner())
    end

    if self:GetOwner():KeyDown(IN_ATTACK2) and self:GetlaserWeaponCharge() < maxCharge then
        self:SetlaserWeaponCharge(self:GetlaserWeaponCharge() + 1)
    end
end