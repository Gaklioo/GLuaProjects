local playerBalance = 0

hook.Add("HUDPaint", "gHudPaint", function()
    local scrw, scrh = ScrW(), ScrH()
    local player = LocalPlayer()
    local health = player:Health()
    local armor = player:Armor()
    local maxArmor = player:GetMaxArmor()
    local maxHealth = player:GetMaxHealth()

    surface.SetFont("gHudFont")
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, scrh * 0.8, 500, 200)


    local yPos = scrh / 1.25
    local xPos = scrw * 0.9
    surface.SetDrawColor(0, 0, 128, 255)
    surface.SetTextPos(scrw * 0.9, scrh / 1.25)
    draw.SimpleText("Health", "gHudFont", 0, yPos + 20)
    draw.SimpleText("Armor", "gHudFont", 0, yPos + 80)

    surface.SetDrawColor(255, 0, 0, 255)
    surface.DrawRect(100, yPos + 30, 150 * (health / maxHealth), 15)

    surface.SetDrawColor(0, 0, 255, 255)
    surface.DrawRect(100, yPos + 92, 150 * (armor / maxArmor), 15)

    surface.SetDrawColor(255, 255, 255, 255)
    draw.SimpleText(player:Name(), "gHudFont", scrw * 0.12, yPos + 20)

    surface.SetTextPos(scrw * 0.105 , yPos + 100)
    surface.DrawText('$' .. player:GetNWInt("playerBalance"), true)
    
end)

surface.CreateFont("gHudFont", {
    font = "Arial",
    size = 35
})

local hide = 
{
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true 
}

hook.Add("HUDShouldDraw", "HideHud", function(name)
    if(hide[name]) then
        return false
    end
end)
