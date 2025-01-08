-- last update 08.01.2025
-- повышена производительность и добавлены новые функции
if CLIENT then
    local scoreboard = {}
    local selectedPlayer = nil
    local infoPanel = nil
    local isInfoPanelOpen = false
    local hoveredPlayer = nil

    scoreboard.scrollOffset = 0

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
    local gui_MousePos = gui.MousePos
    local input_IsMouseDown = input.IsMouseDown
    local input_WasMousePressed = input.WasMousePressed
    local notification_AddLegacy = notification.AddLegacy
    local SetClipboardText = SetClipboardText
    local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
    local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
    local TEXT_ALIGN_RIGHT = TEXT_ALIGN_RIGHT

    local L = {
        title = "⋘ BlackoutPVP ⋙",
        header_name = "Имя",
        header_privilege = "Привелегия",
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
    }

    surface.CreateFont("Scoreboard_Title", {
        font = "Montserrat SemiBold",
        size = 28,
        weight = 600,
        antialias = true,
        extended = true,
    })

    surface.CreateFont("Scoreboard_Header", {
        font = "Montserrat SemiBold",
        size = 20,
        weight = 600,
        antialias = true,
        extended = true,
    })

    surface.CreateFont("Scoreboard_PlayerName", {
        font = "Montserrat Medium",
        size = 20,
        weight = 500,
        antialias = true,
        extended = true,
    })

    surface.CreateFont("Scoreboard_PlayerInfo", {
        font = "Montserrat Regular",
        size = 16,
        weight = 400,
        antialias = true,
        extended = true,
    })

    surface.CreateFont("Scoreboard_ButtonFont", {
        font = "Montserrat Medium",
        size = 16,
        weight = 100,
        antialias = true,
        extended = true,
    })

    surface.CreateFont("Scoreboard_PlayerInfo_Priv", {
        font = "Montserrat Medium",
        size = 20,
        weight = 600,
        antialias = true,
        extended = true,
    })

    scoreboard.alpha = 0
    scoreboard.targetAlpha = 0
    scoreboard.animationSpeed = 10

    scoreboard.currentY = -ScrH()
    scoreboard.targetY = 0
    scoreboard.animationYSpeed = 10

    scoreboard.bgColor = Color(25, 25, 25, 220)
    scoreboard.headerColor = Color(35, 35, 35, 255)
    scoreboard.playerBgColor = Color(40, 40, 40, 200)
    scoreboard.textColor = Color(255, 255, 255, 255)
    scoreboard.accentColor = Color(50, 50, 50, 255)
    scoreboard.buttonHoverColor = Color(70, 70, 70, 255)
    scoreboard.headerTextColor = Color(200, 200, 200, 255)
    scoreboard.hoverColor = Color(60, 60, 60, 255)

    local function GetPingColor(ping)
        if ping <= 90 then
            return Color(0, 255, 0, 255)
        elseif ping <= 150 then
            return Color(255, 255, 0, 255)
        else
            return Color(255, 0, 0, 255)
        end
    end

    hook.Add("ScoreboardShow", "CustomScoreboard_Show", function()
        scoreboard.targetAlpha = 255
        scoreboard.targetY = (ScrH() - (ScrH() * 0.6)) / 2
        gui.EnableScreenClicker(true)
        return true
    end)

    hook.Add("ScoreboardHide", "CustomScoreboard_Hide", function()
        scoreboard.targetAlpha = 0
        scoreboard.targetY = -ScrH()
        gui.EnableScreenClicker(false)
        if infoPanel and infoPanel:IsValid() then
            infoPanel:Remove()
            selectedPlayer = nil
            isInfoPanelOpen = false
        end
        return true
    end)

    local function CreateInfoPanel(ply, scoreboardX, scoreboardY, scoreboardWidth, scoreboardHeight)
        if infoPanel and infoPanel:IsValid() then
            infoPanel:Remove()
        end

        infoPanel = vgui.Create("DPanel")
        infoPanel:SetSize(300, 648)
        infoPanel:SetPos(scoreboardX + scoreboardWidth, scoreboardY + 1)
        infoPanel:SetAlpha(0)
        infoPanel:AlphaTo(255, 0.3, 0)
        isInfoPanelOpen = true
        surface.PlaySound("tab/quarter-full-finger-tapping.wav")

        function infoPanel:Paint(w, h)
            draw.RoundedBoxEx(12, 0, 0, w, h, ColorAlpha(scoreboard.bgColor, self:GetAlpha()), false, true, false, true)
        end

        local avatar = vgui.Create("AvatarImage", infoPanel)
        avatar:SetSize(64, 64)
        avatar:SetPlayer(ply, 184)
        avatar:SetPos((infoPanel:GetWide() - avatar:GetWide()) / 2, 20)

        local nameLabel = vgui.Create("DLabel", infoPanel)
        nameLabel:SetText(ply:Nick())
        nameLabel:SetFont("Scoreboard_PlayerName")
        nameLabel:SetColor(scoreboard.textColor)
        nameLabel:SizeToContents()
        nameLabel:SetPos((infoPanel:GetWide() - nameLabel:GetWide()) / 2, 100)

        local copyNameButton = vgui.Create("DButton", infoPanel)
        copyNameButton:SetSize(infoPanel:GetWide() - 40, 30)
        copyNameButton:SetText("")
        copyNameButton:SetFont("Scoreboard_ButtonFont")
        copyNameButton:SetPos(20, 140)
        copyNameButton:SetTextColor(Color(255, 255, 255))
        copyNameButton:SetCursor("hand")
        copyNameButton.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, scoreboard.buttonHoverColor)
            else
                draw.RoundedBox(6, 0, 0, w, h, scoreboard.accentColor)
            end

            local text = L.copy_name
            draw.SimpleText(text, "Scoreboard_ButtonFont", w / 2, h / 2, self:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        copyNameButton.DoClick = function()
            SetClipboardText(ply:Nick())
            notification_AddLegacy(L.name_copied, NOTIFY_GENERIC, 2)
            surface.PlaySound("tab/bottle-slam-on-plastic-cap-menu.wav")
        end

        local copySteamIDButton = vgui.Create("DButton", infoPanel)
        copySteamIDButton:SetSize(infoPanel:GetWide() - 40, 30)
        copySteamIDButton:SetText("")
        copySteamIDButton:SetFont("Scoreboard_ButtonFont")
        copySteamIDButton:SetPos(20, 180)
        copySteamIDButton:SetTextColor(Color(255, 255, 255))
        copySteamIDButton:SetCursor("hand")
        copySteamIDButton.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, scoreboard.buttonHoverColor)
            else
                draw.RoundedBox(6, 0, 0, w, h, scoreboard.accentColor)
            end

            local text = L.copy_steamid
            draw.SimpleText(text, "Scoreboard_ButtonFont", w / 2, h / 2, self:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        copySteamIDButton.DoClick = function()
            SetClipboardText(ply:SteamID())
            notification_AddLegacy(L.steamid_copied, NOTIFY_GENERIC, 2)
            surface.PlaySound("tab/bottle-slam-on-plastic-cap-menu.wav")
        end
    end

    hook.Add("HUDPaint", "CustomScoreboard_Draw", function()
        scoreboard.alpha = Lerp(FrameTime() * scoreboard.animationSpeed, scoreboard.alpha, scoreboard.targetAlpha)
        scoreboard.currentY = Lerp(FrameTime() * scoreboard.animationYSpeed, scoreboard.currentY, scoreboard.targetY)
        if scoreboard.alpha <= 0 then return end

        if input_WasMousePressed(MOUSE_WHEEL_UP) then
            scoreboard.scrollOffset = scoreboard.scrollOffset + 20
        elseif input_WasMousePressed(MOUSE_WHEEL_DOWN) then
            scoreboard.scrollOffset = scoreboard.scrollOffset - 20
        end

        local scrW, scrH = ScrW(), ScrH()
        local width, height = scrW * 0.4, scrH * 0.6
        local x, y = (scrW - width) / 2, scoreboard.currentY

        if isInfoPanelOpen then
            draw.RoundedBoxEx(12, x, y, width, height, ColorAlpha(scoreboard.bgColor, scoreboard.alpha), true, false, false, false)
            draw.RoundedBoxEx(12, x, y, width, 50, ColorAlpha(scoreboard.headerColor, scoreboard.alpha), true, false, false, false)
        else
            draw.RoundedBox(12, x, y, width, height, ColorAlpha(scoreboard.bgColor, scoreboard.alpha))
            draw.RoundedBoxEx(12, x, y, width, 50, ColorAlpha(scoreboard.headerColor, scoreboard.alpha), true, true, true, true)
        end

        draw.SimpleText(L.title, "Scoreboard_Title", x + width / 2, y + 25, scoreboard.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local padding = 10
        local playerHeight = 40
        local startY = y + 60

        local nameColumnX = x + padding * 2 + 10
        local privilegeColumnX = nameColumnX + 200
        local killsColumnX = privilegeColumnX + 150
        local deathsColumnX = killsColumnX + 150
        local pingColumnX = deathsColumnX + 150

        draw.SimpleText(L.header_name, "Scoreboard_Header", nameColumnX, y + 65, scoreboard.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(L.header_privilege, "Scoreboard_Header", privilegeColumnX, y + 65, scoreboard.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(L.header_kills, "Scoreboard_Header", killsColumnX, y + 65, scoreboard.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(L.header_deaths, "Scoreboard_Header", deathsColumnX, y + 65, scoreboard.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(L.header_ping, "Scoreboard_Header", pingColumnX, y + 65, scoreboard.headerTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local playersList = player_GetAll()
        local totalPlayerHeight = #playersList * (playerHeight + padding)
        local visibleHeight = height - 80 - 20 

        local maxScrollOffset = 0
        local minScrollOffset = math.min(0, visibleHeight - totalPlayerHeight)

        scoreboard.scrollOffset = math.Clamp(scoreboard.scrollOffset, minScrollOffset, maxScrollOffset)

        local playerStartY = y + 80 + scoreboard.scrollOffset

        local scissorX = x + padding
        local scissorY = y + 80
        local scissorWidth = width - 2 * padding
        local scissorHeight = visibleHeight

        render.SetScissorRect(scissorX, scissorY, scissorX + scissorWidth, scissorY + scissorHeight, true)

        local mouseX, mouseY = gui_MousePos()
        local mousePressed = input_IsMouseDown(MOUSE_LEFT)

        hoveredPlayer = nil

        for i, ply in ipairs(playersList) do
            local plyName = ply:Nick()
            local plyPing = ply:Ping()
            local plyKills = ply:Frags()
            local plyDeaths = ply:Deaths()
            local plyY = playerStartY + (i - 1) * (playerHeight + padding)

            local privilegeInfo = specialPrivileges[ply:SteamID()]
            local plyPrivilege, privilegeColor
            if privilegeInfo then
                plyPrivilege = privilegeInfo.role
                privilegeColor = privilegeInfo.color
            else
                plyPrivilege = ply:GetUserGroup() or "User"
                privilegeColor = scoreboard.textColor
            end

            local isHovered = mouseX > x + padding and mouseX < x + width - padding and mouseY > plyY and mouseY < plyY + playerHeight
            if isHovered then
                hoveredPlayer = ply
            end

            local bgColor = ColorAlpha(scoreboard.playerBgColor, scoreboard.alpha)
            if isHovered then
                bgColor = ColorAlpha(scoreboard.hoverColor, scoreboard.alpha)
            end

            draw.RoundedBox(8, x + padding, plyY, width - 2 * padding, playerHeight, bgColor)

            draw.SimpleText(plyName, "Scoreboard_PlayerName", nameColumnX, plyY + playerHeight / 2, scoreboard.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(plyPrivilege, "Scoreboard_PlayerInfo_Priv", privilegeColumnX, plyY + playerHeight / 2, privilegeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(tostring(plyKills), "Scoreboard_PlayerInfo", killsColumnX, plyY + playerHeight / 2, scoreboard.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(tostring(plyDeaths), "Scoreboard_PlayerInfo", deathsColumnX, plyY + playerHeight / 2, scoreboard.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local pingColor = GetPingColor(plyPing)
            draw.SimpleText(tostring(plyPing), "Scoreboard_PlayerInfo", pingColumnX, plyY + playerHeight / 2, pingColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if isHovered then
                if mousePressed and not ply.clicked then
                    selectedPlayer = ply
                    CreateInfoPanel(ply, x, y, width, height)
                    ply.clicked = true
                elseif not mousePressed then
                    ply.clicked = false
                end
            end
        end

        render.SetScissorRect(0, 0, 0, 0, false)
    end)

    hook.Add("Think", "CustomScoreboard_CloseInfoPanel", function()
        if input.IsKeyDown(KEY_ESCAPE) and infoPanel and infoPanel:IsValid() then
            infoPanel:Remove()
            selectedPlayer = nil
            isInfoPanelOpen = false
        end
    end)
end