local TABLENAME = "gBank:Players"

util.AddNetworkString("gBankGetPlayerBalance")
util.AddNetworkString("gBankRecievePlayerBalance")
util.AddNetworkString("gBankTransferMoney")
util.AddNetworkString("gBankAddMoney")
util.AddNetworkString("gBankGetPlayerList")
util.AddNetworkString("gBankPlayerList")
util.AddNetworkString("gBankUpdate")

if not sql.TableExists(TABLENAME) then
    sql.Begin()
        sql.Query("DROP TABLE IF EXISTS " .. TABLENAME)
        sql.Query("CREATE TABLE IF NOT EXISTS `" .. TABLENAME .. "` ( id int PRIMARY KEY, balance varchar )")
    sql.Commit()
end

-- Dont check balances, we've already made sure they have enough.
function transferBetweenPlayers(fromSteamID, toSteamID, ammount)
    updatePlayerBalance(toSteamID, ammount)
    local negativeAmmount = ammount * -1
    updatePlayerBalance(fromSteamID, negativeAmmount)
end

function loadPlayerData(steamID)
    if not steamID or steamID == "" then
        print("Invalid steamID: " .. steamID)
        return
    end

    local query = "SELECT balance FROM `" .. TABLENAME .. "` WHERE id = '" .. steamID .. "'"
    local result = sql.QueryRow(query)

    if result then -- Why do the rest if we found the value
        print("Loading Player")
        return result.balance
    end

    if not result then -- If the user is joining for the first time, insert new row
        local insertQuery = "INSERT INTO `" .. TABLENAME .. "` (id, balance) VALUES ('" .. steamID .. "', 1000)"
        local success = sql.Query(insertQuery)
        
        if not success then
            print("Failed to insert player data for steamID: " .. steamID .. ". Error: " .. sql.LastError())
            return
        else
            print("Player data inserted for steamID: " .. steamID)
        end
    end


    local finalResult = sql.QueryRow("SELECT balance FROM `" .. TABLENAME .. "` WHERE id = '" .. steamID .. "'")

    if finalResult then -- Just to make sure.
        print("Player Balance: " .. finalResult.balance)
    else
        print("Failed to load player balance for steamID: " .. steamID)
        return nil
    end

    return finalResult.balance
end

function updatePlayerBalance(steamID, changeValue)
    -- Fetch current balance
    local balanceResult = sql.Query("SELECT balance FROM `" .. TABLENAME .. "` WHERE id = '" .. steamID .. "'")
    print(balanceResult[1].balance)
    
    if not balanceResult or balanceResult == 0 then
        print("Failed to get player balance.")
        return nil
    end

    changeValue = balanceResult[1].balance + changeValue
    
    -- Update balance
    local queryString = "UPDATE `" .. TABLENAME .. "` set balance = " .. tonumber(changeValue) .. " where id = '" .. steamID .. "'"
    local success = sql.Query(queryString)
    
    local testBalanceUpdate = sql.Query("SELECT balance FROM `" .. TABLENAME .. "` WHERE id = '" .. steamID .. "'")
    testBalanceUpdate = testBalanceUpdate[1].balance

    if not testBalanceUpdate == changeValue then
        print("Failed to update player balance")
        return nil
    end

    return 1
end

--We check that the player can actually transfer money on client side, which is not the best, but its okay since this is my first script.
function getPlayerBalance(steamID)
    local currentBalance = sql.Query("SELECT balance FROM `" .. TABLENAME .. "` WHERE id = '" .. steamID .. "'")

    if not currentBalance then
        print("Failure to get current balance")
        return nil
    end

    return currentBalance[1].balance
end

net.Receive("gBankGetPlayerBalance", function (len, ply)
    local steamID = net.ReadString(64)

    local balance = getPlayerBalance(steamID)

    net.Start("gBankRecievePlayerBalance")
    net.WriteUInt(balance, 32)
    net.Send(ply)
end)

net.Receive("gBankTransferMoney", function (len, ply)
    local fromSteamID = net.ReadString(64)
    local toSteamID = net.ReadString(64)
    local ammountToSend = net.ReadUInt(32)

    print(fromSteamID .. " " .. toSteamID .. " " .. ammountToSend)
    transferBetweenPlayers(fromSteamID, toSteamID, ammountToSend)
end)

net.Receive("gBankAddMoney", function (len, ply)
    print("Hello")
    local addSteamID = net.ReadString()
    local ammountToAdd = net.ReadUInt(32)
    updatePlayerBalance(addSteamID, ammountToAdd)
end)

net.Receive("gBankGetPlayerList", function (len, ply)
    local players = player.GetAll()
    local playerTable = {}


    for k, v in ipairs(players) do -- 2d Array, playerTable[i][0] = Player Name, playerTable[i][1] = player steam id, this helps with /transfer greatly.
        playerTable[k] = {}
        playerTable[k][0] = v:GetName()
        playerTable[k][1] = v:SteamID()
    end

    net.Start("gBankPlayerList")
    net.WriteTable(playerTable)
    net.Send(ply)
end)

--This is technically unsafe, but we're still learning
net.Receive("gBankUpdate", function()
    print("Called")
    local steamID = net.ReadString(64) -- Steam ID is 64 bits
    local changeValue = net.ReadUInt(32) -- Int max

    if not updatePlayerBalance(steamID, changeValue) then
        print("Failure to update player balance... uhoh")
    end 

    print(getPlayerBalance(steamID))
end)

hook.Add("gBankJoin", "gBankOnJoin", function(steamID)
    return loadPlayerData(steamID)
end)

-- Kind of redundent, remove the custom hook for joining when already have on connect.
gameevent.Listen("player_connect")
hook.Add("player_connect", "getValueForClient", function(data)
    local steamID = data.networkid
    print(loadPlayerData(steamID))
end)