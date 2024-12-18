include("shared.lua")


function ENT:Draw()
    self:DrawModel()

    local min, max = self:GetModelBounds()
    local pos = self:GetPos()
    local angle = self:GetAngles()
    local text = "Hi"

    angle:RotateAroundAxis(angle:Up(), 90)

    cam.Start3D2D(pos + angle:Up() * 11.5, angle, 0.5)
        draw.DrawText(self:GetStoredMoney(), "Default", 0, 0, Color(0, 255, 255, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

local function sendMoney(steamid, ammount)
    net.Start("gBankAddMoney")
    net.WriteString(steamid)
    net.WriteUInt(ammount, 32)
    net.SendToServer()
end


net.Receive("gBankStartMoney", function ()
    local steamId = net.ReadString()
    local ammountToAdd = net.ReadUInt(32)
    print("H")

    sendMoney(steamId, ammountToAdd)
end)