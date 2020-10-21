CurrentXP = 0
CurrentRank = 0
QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- RegisterNetEvent("qb_xpxp:load")
-- AddEventHandler("qb_xpxp:load", function()
--     local _source = source
--     local xPlayer = ESX.GetPlayerFromId(_source)

--     if xPlayer then
--         MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
--             ['@identifier'] = xPlayer.identifier
--         }, function(result)
--             if #result > 0 then

--                 if result[1]["rp_xp"] == nil or result[1]["rp_rank"] == nil then
--                     TriggerClientEvent("qb_xpxp:print", _source, _("err_db_columns"))
--                 else
--                     CurrentXP = tonumber(result[1]["rp_xp"])
--                     CurrentRank = tonumber(result[1]["rp_rank"])  

--                     xPlayer.set("xp", CurrentXP)
--                     xPlayer.set("rank", CurrentRank)                
                    
--                     if Config.Leaderboard.Enabled then
--                         FetchActivePlayers(_source, CurrentXP, CurrentRank)
--                     else
--                         TriggerClientEvent("qb_xpxp:init", _source, CurrentXP, CurrentRank, false)
--                     end
--                 end
--             else
--                 TriggerClientEvent("qb_xpxp:print", _source, _("err_db_user"))
--             end
--         end)
--     end
-- end)

RegisterNetEvent("qb_xpxp:load")
AddEventHandler("qb_xpxp:load",function()
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    if Player.PlayerData.metadata["xp"] == nil or Player.PlayerData.metadata["rank"] == nil then
        print("ehhhh")
    else
        CurrentXP = tonumber(Player.PlayerData.metadata["xp"])
        CurrentRank = tonumber(Player.PlayerData.metadata["rank"])

        Player.Functions.SetMetaData("xp", CurrentXP)
        Player.Functions.SetMetaData("rank", CurrentRank)

        TriggerClientEvent("qb_xpxp:init", _source, CurrentXP, CurrentRank, false)
    end
end)

function GetRank(_xp)
    local len = #Config.Ranks
    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1] > tonumber(_xp) then
                return rank
            end
        else
            return rank
        end
    end
end	

-- RegisterNetEvent("qb_xpxp:setXP")
-- AddEventHandler("qb_xpxp:setXP", function(_xp, _rank)
--     local _source = source
--     local xPlayer = ESX.GetPlayerFromId(_source)

--     _xp = tonumber(_xp)
--     _rank = tonumber(_rank)

--     if xPlayer then
--         MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank  WHERE identifier = @identifier', {
--             ['@identifier'] = xPlayer.identifier,
--             ['@xp'] = _xp,
--             ['@rank'] = _rank
--         }, function(result)
--             CurrentXP = tonumber(_xp)
--             CurrentRank = tonumber(_rank)

--             xPlayer.set("xp", CurrentXP)
--             xPlayer.set("rank", CurrentRank)

--             TriggerClientEvent("qb_xpxp:update", _source, CurrentXP, CurrentRank)
--         end)
--     end
-- end)

RegisterNetEvent("qb_xpxp:setXP")
AddEventHandler("qb_xpxp:setXP",function(_xp, _rank)
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    CurrentXP = tonumber(_xp)
    CurrentRank = tonumber(_rank)

    Player.Functions.SetMetaData("xp", CurrentXP)
    Player.Functions.SetMetaData("rank", CurrentRank)

    TriggerClientEvent("qb_xpxp:update", _source, CurrentXP, CurrentRank)
end)

-- function UpdatePlayer(source, xp)
--     local _source = source
--     local xPlayer = ESX.GetPlayerFromId(_source)

--     CurrentXP = tonumber(xp)
--     CurrentRank = GetRank(CurrentXP)

--     if xPlayer then
--         MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier', {
--             ['@identifier'] = xPlayer.identifier,
--             ['@xp'] = CurrentXP,
--             ['@rank'] = CurrentRank
--         }, function(result)

--             xPlayer.set("xp", CurrentXP)
--             xPlayer.set("rank", CurrentRank)

--             TriggerClientEvent("qb_xpxp:update", _source, CurrentXP, CurrentRank)
--         end)
--     end
-- end

function UpdatePlayer(source, xp)
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source) 

    CurrentXP = tonumber(xp)
    CurrentRank = GetRank(CurrentXP)

    Player.Functions.SetMetaData("xp", CurrentXP)
    Player.Functions.SetMetaData("rank", CurrentRank)

    TriggerClientEvent("qb_xpxp:update", _source, CurrentXP, CurrentRank)
end


-- RegisterNetEvent("qb_xpxp:getPlayerData")
-- AddEventHandler("qb_xpxp:getPlayerData", function()
--     local _source = source
--     MySQL.Async.fetchAll('SELECT * FROM users', {}, function(players)
--         if #players > 0 then     
--             TriggerClientEvent("qb_xpxp:setPlayerData", _source, GetOnlinePlayers(_source, players))
--         end
--     end) 
-- end)

------------------------------------------------------------
--                        EVENTS                          --
------------------------------------------------------------

AddEventHandler("qb_xpxp:setInitial", function(PlayerID, XPInit)
    if IsInt(XPInit) then
        UpdatePlayer(PlayerID, LimitXP(XPInit))
    end
end)

AddEventHandler("qb_xpxp:addXP", function(PlayerID, XPAdd)
    if IsInt(XPAdd) then
        local NewXP = CurrentXP + XPAdd
        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)

AddEventHandler("qb_xpxp:removeXP", function(PlayerID, XPRemove)
    if IsInt(XPRemove) then
        local NewXP = CurrentXP - XPRemove
        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)

QBCore.Commands.Add("checkxp", "check your xp", {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    CurrentXP = tonumber(Player.PlayerData.metadata["xp"])
    TriggerClientEvent('QBCore:Notify', source, CurrentXP, "error")
end, "admin")


QBCore.Commands.Add("addxp", "Add XP", {{name="ID", help="Player ID"}, {name="Amount", help="Amount"}}, true, function(source, args)
    id = args[1]
    xp = args[2]
    TriggerEvent("qb_xpxp:addXP",id,xp)
end, "admin")

RegisterNetEvent("qb-xp:SetXP")
AddEventHandler("qb-xp:SetXP",function(CurrentXP, CurrentRank)
    local Player = QBCore.Functions.GetPlayer(source)

    Player.Functions.SetMetaData("xp", CurrentXP)
    Player.Functions.SetMetaData("rank", CurrentRank)   
end)