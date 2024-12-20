include("shared.lua")

local startPos, endPos
local charge

net.Receive("gLaserSendCharge", function()
    charge = net.ReadInt(32)
end)


hook.Add("HUDPaint", "drawCharge", function()
    local player = LocalPlayer()

    if player:HasWeapon("gLaserGun") and player:GetActiveWeapon():GetClass() == "glasergun" then
        local scrw, scrh = ScrW(), ScrH()
        surface.SetFont("gHudFont")
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(scrw * 0.934, scrh * 0.8, 150, 75)

        yPos = scrh / 1.25
        xPos = scrw / 1.25
        draw.SimpleText("Charge % ", "gHudFont", xPos + 350, yPos)
        draw.SimpleText(charge, "gHudFont", xPos + 390, yPos + 30)
    end
end)

hook.Add("PostDrawTranslucentRenderables", "DrawLaserBeam", function()
    if not startPos or not endPos then return end

    local material = Material("cable/blue_electric")
    render.SetMaterial(material)
    render.DrawBeam(startPos, endPos, 2, 0, 0, Color(255, 255, 0))
end)

net.Receive("gLaserWeaponDraw", function()
    startPos = net.ReadVector()
    endPos = net.ReadVector()

    print(startPos)
    print(endPos)
end)

net.Receive("gLaserWeaponStop", function()
    beamActive = false
    startPos = nil
    endPos = nil
end)

function SWEP:SecondaryAttack() end -- Maybe play a charging sound?

