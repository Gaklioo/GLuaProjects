local frameIsOpen = false

hook.Add("OnPlayerChat", "gBankTransfer", function(player, text, teamChat, isDead)
    if (player != LocalPlayer()  || isDead) then return end

    strText = string.lower(text)
    if(strText == "/transfer") then

        if frameIsOpen then return end 
        frameIsOpen = true

        local localPlayerSteamID = player:SteamID()
        net.Start("gBankGetPlayerList")
        net.SendToServer()

        local Frame = vgui.Create("DFrame")
        Frame:SetPos(5, 5)
        Frame:SetSize(300, 200)
        Frame:SetTitle("gBank Transfer")
        Frame:SetVisible(true)
        Frame:SetDraggable(true)
        Frame:ShowCloseButton(true)
        Frame:MakePopup()

        local sendButton = vgui.Create("DButton", Frame)
        sendButton:SetText("Send Transfer")
        sendButton:SetTextColor(Color(255, 255, 255))
        sendButton:SetPos(75, 125)
        sendButton:SetSize(150, 50)

        local playerList = vgui.Create("DComboBox", Frame)
        playerList:SetPos(15, 75)

        playerList:Clear()
        local pList
        net.Receive("gBankPlayerList", function ()
            pList = net.ReadTable()

            for k, v in ipairs( pList ) do
                playerList:AddChoice(pList[k][0], pList[k][1], false, false)
            end
        end)

        local textEntry = vgui.Create("DNumberWang", Frame)
        textEntry:SetPos(200, 75)

        sendButton.DoClick = function()
            local sendTo = playerList:GetOptionData(playerList:GetSelectedID())
            print(sendTo)
            local ammount = textEntry:GetValue()

            if ammount <= 0 then
                LocalPlayer():PrintMessage(HUD_PRINTTALK, "Invalid Transfer Ammount")
                Frame:Close()
                frameIsOpen = false
                return
            end

            net.Start("gBankGetPlayerBalance")
            net.WriteString(localPlayerSteamID)
            net.SendToServer()
            --Something about this is causing multiple requests to the server, Will figure out soon.
            net.Receive("gBankRecievePlayerBalance", function (len, ply)
                    local playerBalance = net.ReadUInt(32)

                    if ammount > playerBalance then
                        LocalPlayer():PrintMessage(HUD_PRINTTALK, "Not enough money to send to player")
                        Frame:Close()
                        frameIsOpen = false
                        ammount = 0
                        return
                    end
                    
                    net.Start("gBankTransferMoney")
                    net.WriteString(localPlayerSteamID)
                    net.WriteString(sendTo)
                    net.WriteUInt(ammount, 32)
                    net.SendToServer()
        
                    Frame:Close()
                    frameIsOpen = false
                    return
            end)
        end
    end
end)
