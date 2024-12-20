AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local doBeam = false
util.AddNetworkString("gLaserWeaponDraw")
util.AddNetworkString("gLaserWeaponStop")
util.AddNetworkString("gLaserSendCharge")
local charge = 0


function SWEP:PrimaryAttack()
    --if not self:CanPrimaryAttack() then return end
    local player = self:GetOwner()

    if charge <= 0 then
        player:PrintMessage(HUD_PRINTTALK, "You need to charge this weapon before you can shoot!")
        return 
    end

    print("hi")

    local startPos = self.Owner:GetShootPos()
    local forwardVector = self.Owner:GetAimVector()
    local endPos = startPos + forwardVector * 10000

    local traceLine = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = self.Owner
    })

    local laserEndPos = traceLine.HitPos
    if not startPos or not laserEndPos then
        print("What") -- This really shouldnt ever happen lol
        return
    end

    if traceLine.Hit and IsValid(traceLine.Entity) then
        local hitEntity = traceLine.Entity
        if IsValid(hitEntity) then
            if hitEntity:IsNPC() or hitEntity:IsPlayer() then
                hitEntity:TakeDamage(5, self.Owner, self)
            end
        end
    end

    net.Start("gLaserWeaponDraw")
    net.WriteVector(startPos)
    net.WriteVector(laserEndPos)
    net.Send(self.Owner)

    self:EmitSound("ambient/levels/labs/electric_explosion1.wav")
end

local maxCharge = 150

function SWEP:Think()
    if self.Owner:KeyDown(IN_ATTACK) and charge > 0 then
        self:PrimaryAttack()
        charge = charge - 1
        doBeam = true
    elseif doBeam then
        net.Start("gLaserWeaponStop")
        net.Send(self.Owner)
    end

    if self.Owner:KeyDown(IN_ATTACK2) and charge < maxCharge then
        charge = charge + 1
    end

    net.Start("gLaserSendCharge")
    net.WriteInt(charge, 32)
    net.Send(self.Owner)
end

function SWEP:IsCarriedByLocalPlayer()
    print("Called")
end