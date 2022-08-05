-- RANDOMIZER
-- cl_init.lua
-- axi, 2022
-- this file runs all of the gamemode's clientside functions

print('client init')

local UI_BG = Color(0, 0, 0, 220)

surface.CreateFont("Font", {
    font = "Arial",
    extended = true,
    size = 20
})

-- clear the guis when we load in
local worldpanel = vgui.GetWorldPanel()

for i, panel in ipairs(worldpanel:GetChildren()) do
    print(panel:GetName())
    if panel:GetName() == "DFrame" then panel:Remove() end
end

-- team definitions
local teamNames = {'Red Team', 'Green Team', 'Blue Team', 'Yellow Team', 'You are the Target!'}
local teamColors = {Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255), Color(255, 255, 0), Color(255, 255, 255)}

-- state
local State = {
    roundType = 'Unknown round type',
    motd = '...'
}

notification.AddLegacy( "Welcome!", NOTIFY_GENERIC, 10 )

net.Receive('sendUserNotif', function()
    local string = net.ReadString()

    notification.AddLegacy( string, NOTIFY_GENERIC, 8 )
end)

net.Receive('roundUpdate', function()
    local typeName = net.ReadString()
    local motd = net.ReadString()

    State.typeName = typeName
    State.motd = motd
end)

hook.Add('InitPostEntity', 'randomizerClientInit', function()
    local GameGUI = vgui.Create("DFrame")
    GameGUI:SetPos(16, 16) 
    GameGUI:SetSize(400, 86) 
    GameGUI:SetTitle(' ') 
    GameGUI:SetDraggable(false)
    GameGUI:ShowCloseButton(false)
    
    GameGUI.Paint = function(self, w, h)
        -- Draws a rounded box with the color faded_black stored above.
        draw.RoundedBox(2, 0, 0, w, h, UI_BG)
        -- Round type
        draw.SimpleText(State.typeName, "Font", w / 2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- Team
        draw.SimpleText(teamNames[LocalPlayer():Team()], "Font", w / 2, 44, teamColors[LocalPlayer():Team()], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        -- Server message
        draw.SimpleText(State.motd, "Font", w / 2, 68, Color(255, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
