CurrentXP = 0
CurrentRank = 0
Leaderboard = nil
Players = {}
Player = nil
UIActive = true
Ready = false


------------------------------------------------------------
--                          QB                           --
------------------------------------------------------------

QBCore = nil
Citizen.CreateThread(function() 
    while QBCore == nil do
        TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    TriggerServerEvent("qb_xpxp:load")
end)


------------------------------------------------------------
--                      MAIN EVENTS                       --
------------------------------------------------------------

-- CHECK RESOURCE IS READY
AddEventHandler('qb_xpxp:isReady', function(cb)
    cb(Ready)
end)


-- INITIALISE RESOURCE
RegisterNetEvent("qb_xpxp:init")
AddEventHandler("qb_xpxp:init", function(_xp, _rank, players)

    local Ranks = CheckRanks()

    -- All ranks are valid
    if #Ranks == 0 then
        CurrentXP = tonumber(_xp)
        CurrentRank = tonumber(_rank)

        local data = {
            xpm_init = true,
            xpm_config = Config,
            currentID = GetPlayerServerId(PlayerId()),
            xp = CurrentXP
        }
    
        if Config.Leaderboard.Enabled and players then
            data.leaderboard = true
            data.players = players

            for k, v in pairs(players) do
                if v.current then
                    Player = v
                end
            end        
    
            Players = players                       
        end
    
        -- Update UI
        SendNUIMessage(data)

        TriggerServerEvent("qb-xp:SetXP",CurrentXP, CurrentRank)  
    
        -- Native stats
        StatSetInt("MPPLY_GLOBALXP", CurrentXP, 1)

        -- Resource is ready to be used
        Ready = true

        -- Trigger event
        TriggerEvent("qb_xpxp:ready", {
            Player = QBCore.Functions.GetPlayerData(),
            xp = CurrentXP,
            rank = CurrentRank
        })
    end
end)

RegisterNetEvent("qb_xpxp:update")
AddEventHandler("qb_xpxp:update", function(_xp, _rank)

    local oldRank = CurrentRank
    local newRank = _rank
    local newXP = _xp

    SendNUIMessage({
        xpm_set = true,
        xp = newXP
    })

    CurrentXP = newXP
    CurrentRank = newRank

    TriggerServerEvent("qb-xp:SetXP",CurrentXP, CurrentRank)   
end)

if Config.Leaderboard.Enabled then
    RegisterNetEvent("qb_xpxp:setPlayerData")
    AddEventHandler("qb_xpxp:setPlayerData", function(players)

        -- Remove disconnected players
        for i=#Players,1,-1 do
            local active = PlayerIsActive(players, Players[i].id)

            if not Players[i].fake then
                if not active then
                    table.remove(Players, i)
                end
            end
        end

        -- Add new players
        for k, v in pairs(players) do
            local active = PlayerIsActive(Players, v.id)

            if not active then
                table.insert(Players, v)
            else
                Players[active] = v
            end

            if v.current then
                Player = v
            end            
        end

        -- Update leaderboard
        SendNUIMessage({
            xpm_updateleaderboard = true,
            xpm_players = Players
        })
    end)
end

-- Error Printing
RegisterNetEvent("qb_xpxp:print")
AddEventHandler("qb_xpxp:print", function(message)
    local s = string.rep("=", string.len(message))
    print(s)
    print(message)
    print(s)           
end)

------------------------------------------------------------
--                       FUNCTIONS                        --
------------------------------------------------------------

------------
-- UpdateXP.
--
-- @global
-- @param	int 	_xp 	
-- @param	bool	init	
-- @return	void
function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local points = CurrentXP + _xp
    local max = qb_xpxpGetMaxXP()

    if init then
        points = _xp
    end

    points = LimitXP(points)

    local rank = qb_xpxpGetRank(points)

    TriggerServerEvent("qb_xpxp:setXP", points, rank)
end


------------
-- qb_xpxpSetInitial.
--
-- @global
-- @param	int 	XPInit	
-- @return	void
function qb_xpxpSetInitial(XPInit)
    local GoalXP = tonumber(XPInit)
    -- Check for valid XP
    if not GoalXP or (GoalXP < 0 or GoalXP > qb_xpxpGetMaxXP()) then
        -- TriggerEvent("qb_xpxp:print", 'Invalid XP Passed', XPInit, "qb_xpxpSetInitial"))
        print("QB-XP: Invalid XP Passed ".. XPInit)
        return
    end    
    UpdateXP(tonumber(GoalXP), true)
end

------------
-- qb_xpxpSetRank.
--
-- @global
-- @param	int	Rank	
-- @return	void
function qb_xpxpSetRank(Rank)
    local GoalRank = tonumber(Rank)

    if not GoalRank then
        --TriggerEvent("qb_xpxp:print", "Invalid Rank Passed" Rank, "qb_xpxpSetRank"))
        print("QB-XP: Invalid Rank Passed "..Rank)
        return
    end

    local XPAdd = tonumber(Config.Ranks[GoalRank]) - CurrentXP

    qb_xpxpAdd(XPAdd)
end

------------
-- qb_xpxpAdd.
--
-- @global
-- @param	int 	XPAdd	
-- @return	void
function qb_xpxpAdd(XPAdd)
    -- Check for valid XP
    if not tonumber(XPAdd) then
        --TriggerEvent("qb_xpxp:print", "Invalid XP Passed ", XPAdd, "qb_xpxpAdd"))
        print("QB-XP: Invalid XP Passed "..XPAdd)
        return
    end       
    UpdateXP(tonumber(XPAdd))
end

------------
-- qb_xpxpRemove.
--
-- @global
-- @param	int 	XPRemove	
-- @return	void
function qb_xpxpRemove(XPRemove)
    -- Check for valid XP
    if not tonumber(XPRemove) then
        --TriggerEvent("qb_xpxp:print", "Invalid XP Passed", XPRemove, "qb_xpxpRemove"))
        print("QB-XP: Invalid XP Passed "..XPAdd)
        return
    end       
    UpdateXP(-(tonumber(XPRemove)))
end

------------
-- qb_xpxpGetRank.
--
-- @global
-- @param	int 	_xp	
-- @return	void
function qb_xpxpGetRank(_xp)

    if _xp == nil then
        return CurrentRank
    end

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

------------
-- qb_xpxpGetXPToNextRank.
--
-- @global
-- @return	int
function qb_xpxpGetXPToNextRank()
    local currentRank = qb_xpxpGetRank()

    return Config.Ranks[currentRank + 1] - tonumber(CurrentXP)   
end

------------
-- qb_xpxpGetXPToRank.
--
-- @global
-- @param	int 	Rank	
-- @return	int
function qb_xpxpGetXPToRank(Rank)
    local GoalRank = tonumber(Rank)
    -- Check for valid rank
    if not GoalRank or (GoalRank < 1 or GoalRank > #Config.Ranks) then
        print("QB-XP: Invalid XP Passed "..XPAdd)
        return
    end

    local goalXP = tonumber(Config.Ranks[GoalRankl])

    return goalXP - CurrentXP
end

------------
-- qb_xpxpGetXP.
--
-- @global
-- @return	int
function qb_xpxpGetXP()
    return tonumber(CurrentXP)
end

------------
-- qb_xpxpGetMaxXP.
--
-- @global
-- @return	int
function qb_xpxpGetMaxXP()
    return Config.Ranks[#Config.Ranks]
end

------------
-- qb_xpxpGetMaxRank.
--
-- @global
-- @return	int
function qb_xpxpGetMaxRank()
    return #Config.Ranks
end

------------
-- qb_xpxpShowUI.
--
-- @global
-- @return	void
function qb_xpxpShowUI(update)
    UIActive = true

    if update ~= nil then
        TriggerServerEvent("qb_xpxp:getPlayerData")
    end
    
    SendNUIMessage({
        xpm_show = true
    })    
end

------------
-- qb_xpxpHideUI.
--
-- @global
-- @return	void
function qb_xpxpHideUI()
    UIActive = false
        
    SendNUIMessage({
        xpm_hide = true
    })      
end

function qb_xpxpTimeoutUI(update)
    UIActive = true

    if update ~= nil then
        TriggerServerEvent("qb_xpxp:getPlayerData")
    end
    
    SendNUIMessage({
        xpm_display = true
    })    
end

function qb_xpxpSortLeaderboard(type)
    SendNUIMessage({
        xpm_lb_sort = true,
        xpm_lb_order = type or "rank"
    })   
end

------------------------------------------------------------
--                        CONTROLS                        --
------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, Config.UIKey) then
            UIActive = not UIActive
            
            if UIActive then
                TriggerServerEvent("qb_xpxp:getPlayerData")
                SendNUIMessage({
                    xpm_show = true
                })                 
            else
                SendNUIMessage({
                    xpm_hide = true
                })                
            end
        elseif IsControlJustPressed(0, 174) then
            if UIActive then
                SendNUIMessage({
                    xpm_lb_prev = true
                })
            end
        elseif IsControlJustPressed(0, 175) then
            if UIActive then
                SendNUIMessage({
                    xpm_lb_next = true
                })
            end
        end

        Citizen.Wait(1)
    end
end)


------------------------------------------------------------
--                          MAIN                          --
------------------------------------------------------------

-- UPDATE UI
RegisterNetEvent("qb_xpxp:updateUI")
AddEventHandler("qb_xpxp:updateUI", function(_xp)
    CurrentXP = tonumber(_xp)

    SendNUIMessage({
        xpm_set = true,
        xp = CurrentXP
    })
end)

-- SET INTITIAL XP
RegisterNetEvent("qb_xpxp:SetInitial")
AddEventHandler('qb_xpxp:SetInitial', qb_xpxpSetInitial)

-- ADD XP
RegisterNetEvent("qb_xpxp:Add")
AddEventHandler('qb_xpxp:Add', qb_xpxpAdd)

-- REMOVE XP
RegisterNetEvent("qb_xpxp:Remove")
AddEventHandler('qb_xpxp:Remove', qb_xpxpRemove)

RegisterNetEvent("qb_xpxp:SetRank")
AddEventHandler('qb_xpxp:SetRank', qb_xpxpSetRank)

-- RANK CHANGE NUI CALLBACK
RegisterNUICallback('xpm_rankchange', function(data)
    if data.rankUp then
        TriggerEvent("qb_xpxp:rankUp", data.current, data.previous)
    else
        TriggerEvent("qb_xpxp:rankDown", data.current, data.previous)
    end
end)

-- UI CHANGE
RegisterNUICallback('xpm_uichange', function(data)
    UIActive = false
end)


------------------------------------------------------------
--                        EXPORTS                         --
------------------------------------------------------------

-- SET INTITIAL XP
exports('qb_xpxpSetInitial', qb_xpxpSetInitial)

-- ADD XP
exports('qb_xpxpAdd', qb_xpxpAdd)

-- REMOVE XP
exports('qb_xpxpRemove', qb_xpxpRemove)

-- SET RANK
exports('qb_xpxpSetRank', qb_xpxpSetRank)

-- GET CURRENT XP
exports('qb_xpxpGetXP', qb_xpxpGetXP)

-- GET CURRENT RANK
exports('qb_xpxpGetRank', qb_xpxpGetRank)

-- GET XP REQUIRED TO RANK-UP
exports('qb_xpxpGetXPToNextRank', qb_xpxpGetXPToNextRank)

-- GET XP REQUIRED TO RANK-UP
exports('qb_xpxpGetXPToRank', qb_xpxpGetXPToRank)

-- GET MAX XP
exports('qb_xpxpGetMaxXP', qb_xpxpGetMaxXP)

-- GET MAX RANK
exports('qb_xpxpGetMaxRank', qb_xpxpGetMaxRank)

-- SHOW UI
exports('qb_xpxpShowUI', qb_xpxpShowUI)

-- HIDE UI
exports('qb_xpxpHideUI', qb_xpxpHideUI)

-- TIMEOUT UI
exports('qb_xpxpTimeoutUI', qb_xpxpTimeoutUI)

-- SORT LEADERBOARD
exports('qb_xpxpSortLeaderboard', qb_xpxpSortLeaderboard)

