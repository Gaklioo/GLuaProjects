local playerBalance = 0

hook.Add("HUDPaint", "gHudPaint", function()
    local scrw, scrh = ScrW(), ScrH()
    local player = LocalPlayer()
    local health = player:Health()
    local armor = player:Armor()
    local maxHealth = player:GetMaxHealth()

    surface.SetFont("gHudFont")
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, scrh * 0.8, 500, 200)


    local yPos = scrh / 1.25
    surface.SetDrawColor(0, 0, 128, 255)
    surface.SetTextPos(scrw * 0.9, scrh / 1.25)
    draw.SimpleText("Health", "gHudFont", 0, yPos + 150)
    draw.SimpleText("Armor", "gHudFont", 100, yPos + 150)

    surface.SetDrawColor(255, 0, 0, 255)
    surface.DrawRect(40, yPos, 15, 150 * (health / maxHealth))

    surface.SetDrawColor(0, 0, 255, 255)
    surface.DrawRect(135, yPos, 15, 150 * (health / maxHealth))

    surface.SetDrawColor(255, 255, 255, 255)
    draw.SimpleText(player:Name(), "gHudFont", scrw * 0.12, yPos + 20)
    net.Start("gBankGetPlayerBalance")
    net.WriteString(player:SteamID())
    net.SendToServer()

    surface.SetTextPos(scrw * 0.105 , yPos + 100)
    surface.DrawText('$' .. playerBalance, true)


    
end)

net.Receive("gBankRecievePlayerBalance", function (len, ply)
    playerBalance = net.ReadUInt(32)
end)

surface.CreateFont("gHudFont", {
    font = "Arial",
    size = 35
})

local hide = 
{
    ["CHudHealth"] = true,
    ["CHudBAttery"] = true 
}

hook.Add("HUDShouldDraw", "HideHud", function(name)
    if(hide[name]) then
        return false
    end
end)