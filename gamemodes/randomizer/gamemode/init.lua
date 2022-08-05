-- RANDOMIZER
-- init.lua
-- axi, 2022
-- this file runs all of the gamemode's server functions
-- apologies for my spaghetti code lol

AddCSLuaFile( "cl_init.lua" )

print('server init')

-- net strings
util.AddNetworkString('sendUserNotif')
util.AddNetworkString('roundUpdate')

local randomizerRoundTypes = {
    {name = 'DEFAULT', readable = 'Standard'}, 
    {name = '2TEAM', readable = '2 Teams'}, 
    {name = '4TEAM', readable = '4 Teams'}, 
    {name = 'TRUE', readable = 'True Random'}, 
    {name = 'TARGET', readable = 'Target'}, 
    {name = 'EQUAL', readable = 'Equalized'}
}

local roundType = 'DEFAULT'
local roundTypeReadable = ''
local isTeamBased = false

local randomizerWeaponsPoolDefault = {'weapon_frag', 'weapon_ar2', 'weapon_crossbow', 'weapon_stunstick', 'weapon_rpg', 'weapon_smg1', 'weapon_crowbar', 'weapon_pistol', 'weapon_shotgun'}
local randomizerWeaponsPool = {}

-- process weapons
local weaponsVar = GetConVar('rz_weaponset'):GetString()
local weaponsTabl = string.Split(weaponsVar, ' ')

if #weaponsVar >= 1 then 
    randomizerWeaponsPool = weaponsTabl
else 
    randomizerWeaponsPool = randomizerWeaponsPoolDefault
end

local IS_ROUND_IN_PROGRESS = true
local nextRoundStartEpoch = -1

local constWepSet = {}

-- setup the teams
team.SetUp(1, "Red", Color(255, 0, 0))
team.SetUp(2, "Green", Color(0, 255, 0))
team.SetUp(3, "Blue", Color(0, 0, 255))
team.SetUp(4, "Yellow", Color(255, 255, 0))
team.SetUp(5, "Target", Color(255, 255, 255))

local teamsTabl = {'Red', 'Green', 'Blue', 'Yellow', 'Target'}

-- util function to broadcast a notification
local function notify(str)
    net.Start('sendUserNotif')
    net.WriteString(str)
    net.Broadcast()
end

-- util function to send out a server status update
local serverMessage = '...'

local function statusUpdate(message)
    if message then serverMessage = message end

    net.Start('roundUpdate')
    net.WriteString(roundTypeReadable)
    net.WriteString(serverMessage)
    net.Broadcast()
end

-- function to give all players "infinite ammo"
local function giveAllAmmo()
    local plrs = player.GetAll()

    for i, player in ipairs( plrs ) do
        local plrWeapon = player:GetActiveWeapon()
        if IsValid(plrWeapon) then
            local wepPrimAmmo = plrWeapon:GetPrimaryAmmoType()
            local wepSecAmmo = plrWeapon:GetSecondaryAmmoType()

            player:SetAmmo(999, wepPrimAmmo)
            player:SetAmmo(999, wepSecAmmo)
        end
    end
end

local function checkRoundTimer()
    if nextRoundStartEpoch < 0 then return end

    if nextRoundStartEpoch < CurTime() then return true else return false end
end

local function pickNextRoundType()
    local validTypes = {}
    
    -- go through all the convars to build a list of valid roundtypes
    local cvars = {'rz_types_standard', 'rz_types_teams2', 'rz_types_teams4', 'rz_types_true', 'rz_types_target', 'rz_types_equal'}

    for i, var in pairs(cvars) do
        if GetConVar(var):GetBool() == true then
            table.insert(validTypes, randomizerRoundTypes[i])
        end
    end

    local type = validTypes[math.random(1,#validTypes)]
    return type
end

local function doRoundEnd()
    local nextType = pickNextRoundType()
    roundType = nextType.name
    roundTypeReadable = nextType.readable
    
    IS_ROUND_IN_PROGRESS = false

    -- reset all players' scores and kill 
    local plrs = player.GetAll()

    for i, player in ipairs( plrs ) do
        player:SetFrags(0)

        player:RemoveAllItems()
        player:SetHealth(GetConVar('rz_hp'):GetInt())

        randomizerHandlePlayerTeam(player)
    end

    notify('Intermission - next game starting in 30 seconds!')

    -- in 30 seconds
    nextRoundStartEpoch = CurTime() + 30

    notify('The next round type is: ' .. roundTypeReadable)

    statusUpdate('The next round type is: ' .. roundTypeReadable)
end

local function doRoundStart()
    nextRoundStartEpoch = -1
    notify('A new round is starting!')
    notify('The round type is: ' .. roundTypeReadable)

    local messageToSend = ''

    isTeamBased = false

    -- handle team-based types
    local teamBounds = 1
    if roundType == '2TEAM' then
        teamBounds = 2
        messageToSend = 'Get ' .. GetConVar('rz_team_goal'):GetInt() .. ' kills to win!'
        isTeamBased = true
    elseif roundType == '4TEAM' then
        teamBounds = 4
        messageToSend = 'Get ' .. GetConVar('rz_team_goal'):GetInt() .. ' kills to win!'
        isTeamBased = true
    end

    -- handle equal roundtype
    if roundType == 'EQUAL' then
        constWepSet = randomizerGenerateWeaponset()
        messageToSend = 'Get ' .. GetConVar('rz_goal'):GetInt() .. ' kills to win! Everyone has the same weapons!'
    end

    IS_ROUND_IN_PROGRESS = true

    for i, player in ipairs( player.GetAll() ) do
        player:SetHealth(GetConVar('rz_hp'):GetInt())

        local set = randomizerGenerateWeaponset()

        if roundType == 'EQUAL' then set = constWepSet end

        randomizerGivePlayerWeaponset(player, set)

        randomizerHandlePlayerTeam(player, math.random(1, teamBounds))
    end

    -- handle target roundtype
    if roundType == 'TARGET' then
        isTeamBased = true

        local players = player.GetAll()
        local player = players[math.random(1, #players)]

        randomizerHandlePlayerTeam(player, 5)

        player:SetHealth(GetConVar('rz_hp'):GetInt() * 2)
        player:SetArmor(GetConVar('rz_target_suit'):GetInt())

        notify(player:Nick() .. ' is the target! Kill them before they kill you!')

        messageToSend = player:Nick() .. ' is the target! Kill them before they kill you!'
    end

    if roundType == 'TRUE' then
        messageToSend = 'Get ' .. GetConVar('rz_goal'):GetInt() .. ' kills to win! Every kill is a new weapon!'
    end

    if roundType == 'DEFAULT' then
        messageToSend = 'Get ' .. GetConVar('rz_goal'):GetInt() .. ' kills to win!'
    end

    statusUpdate(messageToSend)
end 

function randomizerHandlePlayerTeam(ply, teamToSet)
    local plyOldTeam = ply:Team()

    ply:SetNoCollideWithTeammates(true)

    if ply:Team() == 1001 then
        ply:SetTeam(1)
    end

    if teamToSet then
        ply:SetTeam(teamToSet)
    end

    if IS_ROUND_IN_PROGRESS == false then
        ply:SetTeam(1)
    else
        ply:SetTeam(ply:Team())
    end

    -- set player color to their team color
    local tc = team.GetColor(ply:Team())
    ply:SetPlayerColor(Vector(tc.r / 255, tc.g / 255, tc.b / 255))

    -- notify the player if they were transferred to a diff team
    if plyOldTeam ~= ply:Team() then
        net.Start('sendUserNotif')
        net.WriteString('You are now on the ' .. teamsTabl[ply:Team()] .. ' team')
        net.Send(ply)
    end
end

function randomizerGenerateWeaponset()
    local weps = {}
    for i=1,GetConVar('rz_amt_weapons'):GetInt() do
        local wep = randomizerWeaponsPool[math.random(1,#randomizerWeaponsPool)]
        weps[i] = wep
    end

    return weps
end

function randomizerGivePlayerWeaponset(ply, set)
    ply:RemoveAllItems()

    for i, wep in pairs(set) do
        ply:Give(wep)

        -- notify the player of the weapon they were given
        -- net.Start('sendUserNotif')
        -- net.WriteString(wep)
        -- net.Send(ply)
    end
end

hook.Add('PlayerSpawn', 'rzPlayerSpawned', function(ply)
    randomizerHandlePlayerTeam(ply)

    -- set vitals
    ply:SetHealth(GetConVar('rz_hp'):GetInt())

    ply:SetWalkSpeed(400 * GetConVar('rz_speed_mult'):GetFloat())
    ply:SetRunSpeed(600 * GetConVar('rz_speed_mult'):GetFloat())

    ply:SetModel( "models/player/kleiner.mdl" )

    local set = randomizerGenerateWeaponset()

    if IS_ROUND_IN_PROGRESS == true then
        if roundType == 'EQUAL' then set = constWepSet end

        randomizerGivePlayerWeaponset(ply, set)
    end

    -- send a staus update to the player, in case they've just joined
    net.Start('roundUpdate')
    net.WriteString(roundTypeReadable)
    net.WriteString(serverMessage)
    net.Send(ply)
end)

hook.Add('Tick', 'rzTickFunctions', function()
    giveAllAmmo()

    -- if it's time for the next round, start it
    if checkRoundTimer() == true then
        doRoundStart()
    end
end)

hook.Add('PlayerDeath', 'rzPlayerDied', function(victim, inflictor, attacker)
    if victim == attacker then return end
    if not IsValid(attacker) then return end
    if not attacker:IsPlayer() then return end

    -- in the target round type, we need to end the round instantly if the target is killed
    if roundType == 'TARGET' and victim:Team() == 5 then
        doRoundEnd()
        notify(attacker:Nick() .. " landed the killing shot on the target! Good job!")
    end

    -- in the true round type, we give the player a new weapon every time they get a kill
    if roundType == 'TRUE' then
        local set = randomizerGenerateWeaponset()

        randomizerGivePlayerWeaponset(attacker, set)
    end

    -- exception for the target roundtype since it has special behaviour
    if attacker:Frags() >= GetConVar('rz_goal'):GetInt() and roundType ~= 'TARGET' and isTeamBased ~= true then
        -- win notif
        notify(attacker:Nick() .. " won the round with " .. attacker:Frags() .. " kills! ")

        -- end the round
        doRoundEnd()
    end

    -- special cases for if the round is team-based
    if isTeamBased then
        if victim:Team() == attacker:Team() then
            attacker:Kill()
            attacker:SetFrags(0)

            net.Start('sendUserNotif')
            net.WriteString('Your kills have been reset as a penalty for friendly fire.')
            net.Send(attacker)
        end

        local attTeam = attacker:Team()
        if team.TotalFrags(attTeam) >= GetConVar('rz_team_goal'):GetInt() then
            notify(teamsTabl[attTeam] .. " won the round with " .. team.TotalFrags(attTeam) .. " kills! " .. attacker:Nick() .. ' landed the final shot!')

            doRoundEnd()
        end
    end

    -- if the round type is target and the target reached the goal
    if attacker:Frags() >= GetConVar('rz_goal'):GetInt() and roundType == 'TARGET' and attacker:Team() == 5 then
        notify('Game over! ' .. attacker:Nick() .. ', the target, won the round.')
        doRoundEnd()
    end
end)

-- start a round when the server inits
hook.Add('InitPostEntity', 'rzServerInit', function()
    local nextType = pickNextRoundType()
    roundType = nextType.name
    roundTypeReadable = nextType.readable

    doRoundStart()
end)

concommand.Add('rz_skipround', function(ply)
    if ply:IsAdmin() then
        doRoundEnd()
    end
end)