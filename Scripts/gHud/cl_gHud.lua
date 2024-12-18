local playerBalance = 0

hook.Add("HUDPaint", "gHudPaint", function()
    local scrw, scrh = ScrW(), ScrH()
    local player = LocalPlayer()
    local health = player:Health()
    local maxHealth = player:GetMaxHealth()
    surface.SetFont("gHudFont")
    surface.SetDrawColor(0, 0, 128, 255)
    surface.SetTextPos(scrw / 9, scrh / 1.25)
    surface.DrawText(player:Name(), true)
    surface.SetDrawColor(0, 0, 0, 125)
    surface.DrawRect(scrw / scrw - 1, scrh / 1.263, 700, 300)

    surface.SetTextPos(0, scrh / 1.19)
    surface.DrawText("Health", true)

    local bW = scrw * .1
    local bH = scrh * 0.2
    surface.SetDrawColor(255,0 ,0 , 255)
    surface.DrawRect(150, scrw * 0.48, 300 * (health / maxHealth), 15)

    local localPlayerSteamID = player:SteamID()
    net.Start("gBankGetPlayerBalance")
    net.WriteString(localPlayerSteamID)
    net.SendToServer()

    surface.SetTextPos(0, scrh / 1.25)
    surface.DrawText('$' .. playerBalance, true)
end)

net.Receive("gBankRecievePlayerBalance", function (len, ply)
    playerBalance = net.ReadUInt(32)
end)

surface.CreateFont("gHudFont", {
    font = "Arial",
    size = 50
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