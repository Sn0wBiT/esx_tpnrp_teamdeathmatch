ESX = nil
isEnableMatch = true
isMatchStart = false
Deathmatch = {
    BlueTeam = {
        name = "Blue Team",
        player_list = {},
        score = 0
    },
    RedTeam = {
        name = "Red Team",
        player_list = {},
        score = 0
    }
}
matchWin = 3 -- 2 (bo3), 3 (bo5), 16 (bo30)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_tpnrp_teamdeathmatch:getStatus', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer ~= nil then
        cb(isEnableMatch)
    end
end)

RegisterServerEvent('esx_tpnrp_teamdeathmatch:toggleTeamdeathmatch')
AddEventHandler('esx_tpnrp_teamdeathmatch:toggleTeamdeathmatch', function() 
    if isEnableMatch then
        isEnableMatch = false
    else
        isEnableMatch = true
    end
    TriggerClientEvent('esx_tpnrp_teamdeathmatch:toggleTeamdeathmatch', -1, isEnableMatch)
end)

RegisterServerEvent('esx_tpnrp_teamdeathmatch:joinTeam')
AddEventHandler('esx_tpnrp_teamdeathmatch:joinTeam', function(team_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        if not isMatchStart then
            local _len = tablelength(Deathmatch[team_name])
            if _len < 5 then
                Deathmatch[team_name].player_list[_source] = {
                    isDead = false,
                    ready = false,
                    name = GetPlayerName(_source),
                    kill = 0,
                    ckill = 0,
                    death = 0
                }
                TriggerClientEvent('esx_tpnrp_teamdeathmatch:joinedMatch', _source, team_name, Deathmatch)
                updateUI()
            end
        else
            TriggerClientEvent("pNotify:SendNotification", _source, "The match is going on. You cannot participate!")
        end
    end
end)

RegisterServerEvent('esx_tpnrp_teamdeathmatch:iamDead')
AddEventHandler('esx_tpnrp_teamdeathmatch:iamDead', function(team_name) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        Deathmatch[team_name].player_list[_source].isDead = true
        Deathmatch[team_name].player_list[_source].death = Deathmatch[team_name].player_list[_source].death + 1
        checkMatch(team_name)
        updateUI()
    end
end)

RegisterServerEvent('esx_tpnrp_teamdeathmatch:iKilled')
AddEventHandler('esx_tpnrp_teamdeathmatch:iKilled', function(team_name) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        Deathmatch[team_name].player_list[_source].kill = Deathmatch[team_name].player_list[_source].kill + 1
        Deathmatch[team_name].player_list[_source].ckill = Deathmatch[team_name].player_list[_source].ckill + 1
        -- Anount
        -- AnountKill(_source, team_name)
        -- End Anount
        updateUI()
    end
end)

RegisterServerEvent('esx_tpnrp_teamdeathmatch:playerReady')
AddEventHandler('esx_tpnrp_teamdeathmatch:playerReady', function(team_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        Deathmatch[team_name].player_list[_source].ready = true
        checkReady()
    end
end)

RegisterServerEvent('esx_tpnrp_teamdeathmatch:quit')
AddEventHandler('esx_tpnrp_teamdeathmatch:quit', function(team_name) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        if isPlayerInMatch(_source) then
            local _player = ESX.GetPlayerFromId(_source)
            for i=1, #_player.loadout, 1 do
                _player.removeWeapon(_player.loadout[i].name)
            end
            removePlayerFromMatch(_source)
            checkAllMatch()
        end
    end
end)

function checkReady()
    local _blueReady = true
    local _redReady = true
    local _cntBlue = 0
    local _cntRed = 0
    -- Call update Game UI to all players Blue
    for k,v in pairs(Deathmatch["BlueTeam"].player_list) do
        if v ~= nil then
            _cntBlue = _cntBlue + 1
            if not v.ready then
                _blueReady = false
            end
        end
    end
    -- Red
    for k,v in pairs(Deathmatch["RedTeam"].player_list) do
        if v ~= nil then
            _cntRed = _cntRed + 1
            if not v.ready then
                _redReady = false
            end
        end
    end
    -- Check ready
    if _cntBlue > 0 and _cntRed > 0 then
        if _cntBlue == _cntRed then
            if _blueReady and _redReady then
                -- start match
                isMatchStart = true
                startMatch()
            end
        else
            TriggerClientEvent('chatMessage', -1, '', {255,255,255}, '^8Arena: ^1 unfair number of members! Red team: ' .. _cntRed .. ' blue team: '.. _cntBlue)    
        end
    else
        TriggerClientEvent('chatMessage', -1, '', {255,255,255}, '^8Arena: ^1 Not enough people cannot start the match!')
    end
end

function startMatch()
    -- Call update Game UI to all players Blue
    for k,v in pairs(Deathmatch["BlueTeam"].player_list) do
        TriggerClientEvent('esx_tpnrp_teamdeathmatch:startMatch', k)
    end
    -- Red
    for k,v in pairs(Deathmatch["RedTeam"].player_list) do
        TriggerClientEvent('esx_tpnrp_teamdeathmatch:startMatch', k)
    end
    TriggerClientEvent('chatMessage', -1, '', {255,255,255}, '^8Arena: ^1 The match has begun!')
end

function updateUI()
    -- Call update Game UI to all players Blue
    for k,v in pairs(Deathmatch["BlueTeam"].player_list) do
        TriggerClientEvent('esx_tpnrp_teamdeathmatch:updateGameUI', k, Deathmatch)
    end
    -- Red
    for k,v in pairs(Deathmatch["RedTeam"].player_list) do
        TriggerClientEvent('esx_tpnrp_teamdeathmatch:updateGameUI', k, Deathmatch)
    end
end

function checkMatch(team_name)
    -- Check Match
    local cntPlayers = 0
    local cntDead = 0
    for k,v in pairs(Deathmatch[team_name].player_list) do
        if v ~= nil then
            if v.isDead then
                cntDead = cntDead + 1
            end
            cntPlayers = cntPlayers + 1
        end
    end
    -- check dead
    if cntPlayers == cntDead then
        -- Match finish
        local winTeam = ""
        if team_name == "BlueTeam" then
            winTeam = "RedTeam"
        else
            winTeam = "BlueTeam"
        end
        Deathmatch[winTeam].score = Deathmatch[winTeam].score + 1
        if Deathmatch[winTeam].score == matchWin then
            -- Send Win message
            for k,v in pairs(Deathmatch[winTeam].player_list) do
                TriggerClientEvent('esx_tpnrp_teamdeathmatch:matchFinished', k, Deathmatch, winTeam)
            end
            -- Send Lose message
            for k,v in pairs(Deathmatch[team_name].player_list) do
                TriggerClientEvent('esx_tpnrp_teamdeathmatch:matchFinished', k, Deathmatch, winTeam)
            end
            TriggerClientEvent('chatMessage', -1, '', {255,255,255}, '^8Arena: ^1'.. Deathmatch[winTeam].name .. " won the final match!")
            SetTimeout(15000, function()
                -- Reset player inventory
                -- tele back to start point
                for k,v in pairs(Deathmatch[winTeam].player_list) do
                    if v.isDead then
                        Deathmatch[winTeam].player_list[k].isDead = false
                        TriggerClientEvent('esx_ambulancejob:revive', k)
                    end
                    SetTimeout(1500, function() 
                        local _player = ESX.GetPlayerFromId(k)
                        for i=1, #_player.loadout, 1 do
                            -- print("removed gun from " .. v.name)
                            _player.removeWeapon(_player.loadout[i].name)
                        end
                        TriggerClientEvent('esx_tpnrp_teamdeathmatch:endMatch', k, winTeam, winTeam)
                    end)
                end
                -- New round
                for k,v in pairs(Deathmatch[team_name].player_list) do
                    if v.isDead then
                        Deathmatch[team_name].player_list[k].isDead = false
                        TriggerClientEvent('esx_ambulancejob:revive', k)
                    end
                    SetTimeout(1500, function() 
                        local _player = ESX.GetPlayerFromId(k)
                        for i=1, #_player.loadout, 1 do
                            -- print("removed gun from " .. v.name)
                            _player.removeWeapon(_player.loadout[i].name)
                        end
                        TriggerClientEvent('esx_tpnrp_teamdeathmatch:endMatch', k, team_name, winTeam)
                    end)
                end
                -- reset save match data
                resetMatch()
            end)
        else
            -- Send Win message
            for k,v in pairs(Deathmatch[winTeam].player_list) do
                TriggerClientEvent('esx_tpnrp_teamdeathmatch:youWon', k, Deathmatch, winTeam)
            end
            -- Send Lose message
            for k,v in pairs(Deathmatch[team_name].player_list) do
                TriggerClientEvent('esx_tpnrp_teamdeathmatch:youLose', k, Deathmatch, winTeam)
            end
            TriggerClientEvent('chatMessage', -1, '', {255,255,255}, '^8Arena: ^1'.. Deathmatch[winTeam].name .. " won! Current score " .. Deathmatch[winTeam].score .. " - " .. Deathmatch[team_name].score .. " leaning in " .. Deathmatch[winTeam].name)
            SetTimeout(15000, function()
                -- Call tele all players
                -- Revive all players
                -- New round
                for k,v in pairs(Deathmatch[winTeam].player_list) do
                    if v.isDead then
                        Deathmatch[winTeam].player_list[k].isDead = false
                        TriggerClientEvent('esx_ambulancejob:revive', k)
                    end
                    Deathmatch[winTeam].player_list[k].ckill = 0
                    SetTimeout(1000, function() 
                        -- print("Tele " .. k .. " Team: " .. winTeam)
                        TriggerClientEvent('esx_tpnrp_teamdeathmatch:newRound', k, winTeam)
                    end)
                end
                -- New round
                for k,v in pairs(Deathmatch[team_name].player_list) do
                    if v.isDead then
                        Deathmatch[team_name].player_list[k].isDead = false
                        TriggerClientEvent('esx_ambulancejob:revive', k)
                    end
                    Deathmatch[team_name].player_list[k].ckill = 0
                    SetTimeout(1000, function() 
                        -- print("Tele " .. k .. " Team: " .. team_name)
                        TriggerClientEvent('esx_tpnrp_teamdeathmatch:newRound', k, team_name)
                    end)
                end
            end)
        end
    end
end

function resetMatch()
    Deathmatch = {
        BlueTeam = {
            name = "Blue Team",
            player_list = {},
            score = 0
        },
        RedTeam = {
            name = "Red Team",
            player_list = {},
            score = 0
        }
    }
    isMatchStart = false
end

function checkAllMatch()
    local cntPlayers = 0
    for k,v in pairs(Deathmatch["RedTeam"].player_list) do
        if v ~= nil then
            cntPlayers = cntPlayers + 1
        end
    end
    for k,v in pairs(Deathmatch["BlueTeam"].player_list) do
        if v ~= nil then
            cntPlayers = cntPlayers + 1
        end
    end
    if cntPlayers <= 0 then
        -- reset match
        resetMatch()
    end
end

function isPlayerInMatch(_source)
    -- Call update Game UI to all players Blue
    for k,v in pairs(Deathmatch["BlueTeam"].player_list) do
        if k == _source then
            return true
        end
    end
    -- Red
    for k,v in pairs(Deathmatch["RedTeam"].player_list) do
        if k == _source then
            return true
        end
    end
    return false
end

function removePlayerFromMatch(_source)
    -- Call update Game UI to all players Blue
    for k,v in pairs(Deathmatch["BlueTeam"].player_list) do
        if k == _source then
            Deathmatch["BlueTeam"].player_list[_source] = nil
            return true
        end
    end
    -- Red
    for k,v in pairs(Deathmatch["RedTeam"].player_list) do
        if k == _source then
            Deathmatch["RedTeam"].player_list[_source] = nil
            return true
        end
    end
    return false
end

function AnountKill(_source, team_name)
    local _other_team_name = "RedTeam"
    if team_name == "RedTeam" then
        _other_team_name = "BlueTeam"
    end
    local _kill = ""
    if Deathmatch[team_name].player_list[_source].ckill == 2 then
        _kill = "double"
    elseif Deathmatch[team_name].player_list[_source].ckill == 3 then
        _kill = "triple"
    elseif Deathmatch[team_name].player_list[_source].ckill == 4 then
        _kill = "quadra"
    elseif Deathmatch[team_name].player_list[_source].ckill == 5 then
        _kill = "penta"
    end
    for k,v in pairs(Deathmatch[team_name].player_list) do
        TriggerClientEvent('esx_tpnrp_teamdeathmatch:anountVoice', k, "allied", _kill)
    end
    for k,v in pairs(Deathmatch[_other_team_name].player_list) do
        TriggerClientEvent('esx_tpnrp_teamdeathmatch:anountVoice', k, "enemy", _kill)
    end
end


function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

AddEventHandler('playerDropped', function(reason)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer ~= nil and isMatchStart then
        if isPlayerInMatch(_source) then
            -- Remove player inventory
            local _player = ESX.GetPlayerFromId(_source)
            for i=1, #_player.loadout, 1 do
                _player.removeWeapon(_player.loadout[i].name)
            end
            -- Remove player in match
            removePlayerFromMatch(_source)
        end
	end
end)

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end
