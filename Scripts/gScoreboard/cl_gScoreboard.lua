local scoreboard
local playerBalance = 0

local function getPlayerMoney(steamID)
    net.Start("gBankGetPlayerBalance")
    net.WriteString(steamID)
    net.SendToServer()
end

net.Receive("gBankRecievePlayerBalance", function (len, ply)
    playerBalance = net.ReadUInt(32)
end)

surface.CreateFont("gScoreboard", {
    font = "Arial",
    extended = false,
    size = 15,
    weight = 125
})

local function ToggleScoreboard(toggle)
    if toggle then
        local scrw, scrh = ScrW(), ScrH()

        if not IsValid(scoreboard) then
            scoreboard = vgui.Create("DFrame")
            scoreboard:SetTitle("")
            scoreboard:SetSize(scrw * 0.3, scrh * 0.6)
            scoreboard:Center()
            scoreboard:MakePopup()
            scoreboard:ShowCloseButton(false)
            scoreboard:SetDraggable(false)
    
            scoreboard.Paint = function(self, w, h)
                surface.SetDrawColor(0, 0, 0, 170)
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText("Scoreboard", "gScoreboard", w / 2, h * .03, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Name", "gScoreboard", w * 0.1, h * .09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Kills", "gScoreboard", w * 0.4, h * .09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Deaths", "gScoreboard", w * 0.6, h * .09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Money", "gScoreboard", w * 0.8, h * .09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end 

            local yPos = scoreboard:GetTall() * 0.1
            for k, v in ipairs(player.GetAll()) do
                local playerList = vgui.Create("DPanel", scoreboard)

                playerList:SetPos(0, yPos)
                playerList:SetSize(scoreboard:GetWide(), scoreboard:GetTall() * .05)
                
                playerList.Paint = function(self, w, h)
                    surface.SetDrawColor(0, 0, 0, 200)
                    surface.DrawRect(0, 0, w, h)
                    draw.SimpleText(v:Nick(), "gScoreboard", w * 0.1, h / 2, Color(255, 255, 255, 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(v:Frags(), "gScoreboard", w * 0.4, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(v:Deaths(), "gScoreboard", w * 0.6, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    getPlayerMoney(v:SteamID())
                    draw.SimpleText(playerBalance, "gScoreboard", w * 0.8, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                end

                yPos = yPos + playerList:GetTall() * 1.1
            end
        end
    else
        if IsValid(scoreboard) then
            scoreboard:Remove()
            scoreboard = nil 
        end
    end
end


hook.Add("ScoreboardShow", "gScoreboardOpen1", function()
    ToggleScoreboard(true)
    return false
end)

hook.Add("ScoreboardHide", "gScoreboardClose", function()
    ToggleScoreboard(false)
end)