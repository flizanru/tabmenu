if CLIENT then
    local scoreboard = {}
    local selectedPlayer = nil
    local infoPanel = nil
    local isInfoPanelOpen = false

    local draw = draw
    local Color = Color
    local Lerp = Lerp
    local FrameTime = FrameTime
    local ScrW = ScrW
    local ScrH = ScrH
    local gui = gui
    local vgui = vgui
    local surface = surface
    local hook = hook
    local player_GetAll = player.GetAll
    local notification_AddLegacy = notification.AddLegacy
    local SetClipboardText = SetClipboardText
    local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
    local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
    local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT
    local input = input

    local L = {
        title = "⋘ BlackoutPVP ⋙",
        header_name = "Имя",
        header_privilege = "Привилегия",
        header_kills = "Убийства",
        header_deaths = "Смерти",
        header_ping = "Пинг",
        copy_name = "Копировать имя",
        copy_steamid = "Копировать SteamID",
        name_copied = "Имя скопировано!",
        steamid_copied = "SteamID скопирован!",
        developer = "Разработчик"
    }

    local specialPrivileges = {
        ["STEAM_0:0:562063878"] = { role = L.developer, color = Color(30, 144, 255) },
        ["STEAM_0:0:454092551"] = { role = "Отец", color = Color(220, 20, 60) },
    }

    local CreateFont = surface.CreateFont
    CreateFont("Scoreboard_Title", {
        font = "Montserrat SemiBold",
        size = 28,
        weight = 600,
        antialias = true,
        extended = true,
    })

    CreateFont("Scoreboard_Header", {
        font = "Montserrat SemiBold",
        size = 20,
        weight = 600,
        antialias = true,
        extended = true,
    })

    CreateFont("Scoreboard_PlayerName", {
        font = "Montserrat Medium",
        size = 20,
        weight = 500,
        antialias = true,
        extended = true,
    })

    CreateFont("Scoreboard_PlayerInfo", {
        font = "Montserrat Regular",
        size = 16,
        weight = 400,
        antialias = true,
        extended = true,
    })

    CreateFont("Scoreboard_ButtonFont", {
        font = "Montserrat Medium",
        size = 16,
        weight = 100,
        antialias = true,
        extended = true,
    })

    CreateFont("Scoreboard_PlayerInfo_Priv", {
        font = "Montserrat Medium",
        size = 20,
        weight = 600,
        antialias = true,
        extended = true,
    })

    scoreboard.colors = {
        bgColor = Color(25, 25, 25, 250),
        headerColor = Color(35, 35, 35, 255),
        playerBgColor = Color(40, 40, 40, 150),
        textColor = Color(255, 255, 255, 255),
        accentColor = Color(50, 50, 50, 255),
        buttonHoverColor = Color(70, 70, 70, 255),
        headerTextColor = Color(200, 200, 200, 255),
        hoverColor = Color(60, 60, 60, 255),
        infoBgColor = Color(25, 25, 25, 250) 
    }

    local function GetPingColor(ping)
        if ping <= 90 then
            return Color(0, 255, 0, 255)
        elseif ping <= 150 then
            return Color(255, 255, 0, 255)
        else
            return Color(255, 0, 0, 255)
        end
    end

    local function CreateInfoPanel(ply, parent)
        if infoPanel and infoPanel:IsValid() then
            infoPanel:Remove()
        end

        local frameX, frameY = scoreboard.frame:GetPos()
        local frameW, frameH = scoreboard.frame:GetSize()

        infoPanel = vgui.Create("DPanel", nil)
        infoPanel:SetSize(270, frameH - 50)
        infoPanel:SetPos(frameX + frameW, frameY + 50)
        infoPanel:SetAlpha(0)
        infoPanel:AlphaTo(255, 0.3, 0)
        isInfoPanelOpen = true
        surface.PlaySound("tab/quarter-full-finger-tapping.wav")

        infoPanel.Paint = function(self, w, h)
            draw.RoundedBoxEx(12, 0, 0, w, h, scoreboard.colors.infoBgColor, false, true, false, true)
        end

        local avatar = vgui.Create("AvatarImage", infoPanel)
        avatar:SetSize(100, 100)
        avatar:SetPlayer(ply, 100)
        avatar:SetPos((infoPanel:GetWide() - avatar:GetWide()) / 2, 20)

        local nameLabel = vgui.Create("DLabel", infoPanel)
        nameLabel:SetText(ply:Nick())
        nameLabel:SetFont("Scoreboard_PlayerName")
        nameLabel:SetColor(scoreboard.colors.textColor)
        nameLabel:SizeToContents()
        nameLabel:SetPos((infoPanel:GetWide() - nameLabel:GetWide()) / 2, 130)

        local copyButtons = {
            { text = L.copy_name, func = function()
                SetClipboardText(ply:Nick())
                notification_AddLegacy(L.name_copied, NOTIFY_GENERIC, 2)
                surface.PlaySound("tab/bottle-slam-on-plastic-cap-menu.wav")
            end },
            { text = L.copy_steamid, func = function()
                SetClipboardText(ply:SteamID())
                notification_AddLegacy(L.steamid_copied, NOTIFY_GENERIC, 2)
                surface.PlaySound("tab/bottle-slam-on-plastic-cap-menu.wav")
            end }
        }

        local buttonY = 170
        for _, btn in ipairs(copyButtons) do
            local copyButton = vgui.Create("DButton", infoPanel)
            copyButton:SetSize(infoPanel:GetWide() - 40, 30)
            copyButton:SetText("")
            copyButton:SetFont("Scoreboard_ButtonFont")
            copyButton:SetPos(20, buttonY)
            copyButton:SetTextColor(Color(255, 255, 255))
            copyButton:SetCursor("hand")
            copyButton.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and scoreboard.colors.buttonHoverColor or scoreboard.colors.accentColor)
                draw.SimpleText(btn.text, "Scoreboard_ButtonFont", w / 2, h / 2, self:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            copyButton.DoClick = btn.func
            buttonY = buttonY + 40
        end
    end

    local function CreateScoreboard()
        if scoreboard.frame and scoreboard.frame:IsValid() then
            scoreboard.frame:Remove()
        end

        scoreboard.frame = vgui.Create("DFrame")
        scoreboard.frame:SetTitle("")
        scoreboard.frame:SetSize(ScrW() * 0.4, ScrH() * 0.6)
        scoreboard.frame:SetPos((ScrW() - ScrW() * 0.4) / 2, (ScrH() - ScrH() * 0.6) / 2)
        scoreboard.frame:SetDraggable(false)
        scoreboard.frame:ShowCloseButton(false)
        scoreboard.frame:SetAlpha(0)
        scoreboard.frame:AlphaTo(255, 0.3, 0)

        scoreboard.frame.Paint = function(self, w, h)
            local topRight = not isInfoPanelOpen
            local bottomRight = not isInfoPanelOpen
            draw.RoundedBoxEx(12, 0, 0, w, h, scoreboard.colors.bgColor, true, topRight, true, bottomRight)
            draw.RoundedBoxEx(12, 0, 0, w, 50, scoreboard.colors.headerColor, true, true, true, true)
            draw.SimpleText(L.title, "Scoreboard_Title", w / 2, 25, scoreboard.colors.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        scoreboard.headerPanel = vgui.Create("DPanel", scoreboard.frame)
        scoreboard.headerPanel:SetTall(30)
        scoreboard.headerPanel:Dock(TOP)
        scoreboard.headerPanel:DockMargin(10, 25, 10, 0)
        scoreboard.headerPanel.Paint = function(self, w, h)
            draw.SimpleText(L.header_name, "Scoreboard_Header", 10, h / 2, scoreboard.colors.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(L.header_privilege, "Scoreboard_Header", 210, h / 2, scoreboard.colors.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(L.header_kills, "Scoreboard_Header", 360, h / 2, scoreboard.colors.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(L.header_deaths, "Scoreboard_Header", 510, h / 2, scoreboard.colors.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(L.header_ping, "Scoreboard_Header", 660, h / 2, scoreboard.colors.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(scoreboard.colors.accentColor)
            surface.DrawRect(0, h - 2, w, 2)
        end

        scoreboard.scrollPanel = vgui.Create("DScrollPanel", scoreboard.frame)
        scoreboard.scrollPanel:Dock(FILL)
        scoreboard.scrollPanel:DockMargin(10, 5, 10, 10)
        scoreboard.scrollPanel.VBar:SetWide(8)
        scoreboard.scrollPanel.VBar.Paint = function() end
        scoreboard.scrollPanel.VBar.btnUp.Paint = function() end
        scoreboard.scrollPanel.VBar.btnDown.Paint = function() end
        scoreboard.scrollPanel.VBar.btnGrip.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, scoreboard.colors.accentColor)
        end

        scoreboard.scrollDesired = 0

        scoreboard.scrollPanel.OnMouseWheeled = function(panel, delta)
            scoreboard.scrollDesired = math.Clamp(scoreboard.scrollDesired - delta * 40, 0, scoreboard.scrollPanel.VBar.CanvasSize)
        end

        hook.Add("Think", "CustomScoreboard_SmoothScroll", function()
            if scoreboard.scrollPanel and scoreboard.scrollPanel:IsValid() then
                local vbar = scoreboard.scrollPanel.VBar
                if vbar then
                    local current = vbar:GetScroll()
                    local desired = scoreboard.scrollDesired
                    local speed = 10
                    local newScroll = Lerp(FrameTime() * speed, current, desired)
                    vbar:SetScroll(newScroll)
                end
            end
        end)

        local playersList = player_GetAll()
        table.sort(playersList, function(a, b)
            return a:Nick() < b:Nick()
        end)

        for _, ply in ipairs(playersList) do
            local plyPanel = vgui.Create("DPanel", scoreboard.scrollPanel)
            plyPanel:SetTall(40)
            plyPanel:Dock(TOP)
            plyPanel:DockMargin(0, 5, 0, 5)
            plyPanel:SetCursor("hand")

            plyPanel.Paint = function(self, w, h)
                local plyName = ply:Nick()
                local plyPing = ply:Ping()
                local plyKills = ply:Frags()
                local plyDeaths = ply:Deaths()

                local privilegeInfo = specialPrivileges[ply:SteamID()]
                local plyPrivilege = privilegeInfo and privilegeInfo.role or (ply:GetUserGroup() or "User")
                local privilegeColor = privilegeInfo and privilegeInfo.color or scoreboard.colors.textColor

                local bgColor = self:IsHovered() and scoreboard.colors.hoverColor or scoreboard.colors.playerBgColor
                draw.RoundedBox(8, 0, 0, w, h, bgColor)
                draw.SimpleText(plyName, "Scoreboard_PlayerName", 10, h / 2, scoreboard.colors.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(plyPrivilege, "Scoreboard_PlayerInfo_Priv", 210, h / 2, privilegeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(tostring(plyKills), "Scoreboard_PlayerInfo", 360, h / 2, scoreboard.colors.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(tostring(plyDeaths), "Scoreboard_PlayerInfo", 510, h / 2, scoreboard.colors.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(tostring(plyPing), "Scoreboard_PlayerInfo", 660, h / 2, GetPingColor(plyPing), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            plyPanel.OnMousePressed = function(self, code)
                if code == MOUSE_LEFT then
                    selectedPlayer = ply
                    CreateInfoPanel(ply, scoreboard.frame)
                end
            end
        end
    end

    local function CloseScoreboard()
        if scoreboard.frame and scoreboard.frame:IsValid() then
            scoreboard.frame:Remove()
        end
        if infoPanel and infoPanel:IsValid() then
            infoPanel:Remove()
            selectedPlayer = nil
            isInfoPanelOpen = false
        end
        hook.Remove("Think", "CustomScoreboard_SmoothScroll")
    end

    hook.Add("ScoreboardShow", "CustomScoreboard_Show", function()
        CreateScoreboard()
        gui.EnableScreenClicker(true)
        return true
    end)

    hook.Add("ScoreboardHide", "CustomScoreboard_Hide", function()
        CloseScoreboard()
        gui.EnableScreenClicker(false)
        return true
    end)

    hook.Add("Think", "CustomScoreboard_CloseInfoPanel", function()
        if input.IsKeyDown(KEY_ESCAPE) and infoPanel and infoPanel:IsValid() then
            infoPanel:Remove()
            selectedPlayer = nil
            isInfoPanelOpen = false
            surface.PlaySound("buttons/button15.wav")
        end
    end)

    hook.Add("GUIMousePressed", "CustomScoreboard_CloseInfoPanel_OnClickOutside", function(code, mx, my)
        if isInfoPanelOpen and code == MOUSE_LEFT and infoPanel and infoPanel:IsValid() then
            local infoPanelX, infoPanelY = infoPanel:LocalToScreen(0, 0)
            local infoPanelW, infoPanelH = infoPanel:GetWide(), infoPanel:GetTall()

            if not (mx >= infoPanelX and mx <= infoPanelX + infoPanelW and my >= infoPanelY and my <= infoPanelY + infoPanelH) then
                infoPanel:Remove()
                selectedPlayer = nil
                isInfoPanelOpen = false
                surface.PlaySound("buttons/button15.wav")
            end
        end
    end)
end
