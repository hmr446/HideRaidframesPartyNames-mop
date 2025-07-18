-- HideRaidframesPartyNames for WoW 5.4.8
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

-- 配置存储
HPN_SHOW_PARTY = HPN_SHOW_PARTY or false

-- 5.4.8兼容的颜色函数
local function ColorText(text, color)
    local colorCodes = {
        yellow = "|cFFFFFC01",
        blue = "|cFF00FAF6",
        green = "|cFF3CE13F",
        purple = "|cFFA335EE",
        orange = "|cFFFF8000",
        red = "|cFFFF4700",
        default = "|cFFFFFC01"
    }
    
    return (colorCodes[color] or colorCodes["default"]) .. text .. "|r"
end

-- 5.4.8兼容的超链接函数
local function MakeLink(text, id)
    return format("|H%s|h%s|h", id, text)
end

-- 核心名字切换函数（5.4.8兼容）
local function ToggleName(frame)
    if not frame or not frame.GetName then return end
    
    -- 5.4.8中名字在frame.name对象中
    local nameText = frame.name
    
    if nameText and nameText:IsObjectType("FontString") then
        if HPN_SHOW_PARTY then
            nameText:Show()
        else
            nameText:Hide()
        end
    end
end

-- 5.4.8兼容的框架处理函数
local function ProcessFrames()
    -- 处理团队框架 (1-40)
    for i = 1, 40 do
        local frame = _G["CompactRaidFrame"..i]
        if frame then
            ToggleName(frame)
        end
        
        -- 处理宠物框架
        local petFrame = _G["CompactRaidFrame"..i.."PetFrame"]
        if petFrame and petFrame.name then
            ToggleName(petFrame)
        end
    end
    
    -- 处理小队框架 (1-5)
    for i = 1, 5 do
        local frame = _G["PartyMemberFrame"..i]
        if frame then
            ToggleName(frame)
        end
    end
end

-- 事件处理
function f:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "HideRaidframesPartyNames" then
        -- 初始化配置
        HPN_SHOW_PARTY = HPN_SHOW_PARTY or false
        
        -- 安全钩住名字更新函数
        hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
            ToggleName(frame)
        end)
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- 确保UI加载完成后再处理
        C_Timer.After(2, function()
            ProcessFrames()
        end)
    end
end

f:SetScript("OnEvent", f.OnEvent)

-- 切换名字显示状态
local function CallToggleEvent()
    HPN_SHOW_PARTY = not HPN_SHOW_PARTY
    ProcessFrames()
    
    -- 显示状态消息
    local statusText = HPN_SHOW_PARTY and ColorText("ON", "green") or ColorText("OFF", "red")
    DEFAULT_CHAT_FRAME:AddMessage(ColorText("[HideRaidframesPartyNames]", "blue") .. 
        " 团队框架名字显示: " .. statusText)
end

-- 命令处理
local function ProcessCommands(msg, editbox)
    msg = msg and strlower(msg) or ""
    
    if msg == "toggle" then
        CallToggleEvent()
    else
        -- 显示帮助信息
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("[HideRaidframesPartyNames] 命令帮助:", "yellow"))
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("/hrpn toggle", "orange") .. " - 切换名字显示状态")
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("/hrpn status", "orange") .. " - 显示当前状态")
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("当前状态: ", "yellow") .. 
            (HPN_SHOW_PARTY and ColorText("显示名字", "green") or ColorText("隐藏名字", "red")))
    end
end

-- 注册斜杠命令
SLASH_HIDEPARTYNAME1 = "/hrpn"
SlashCmdList["HIDEPARTYNAME"] = ProcessCommands

-- 5.4.8兼容的超链接处理
local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
    if link and link:sub(1, 8) == "myXghkkL" then
        CallToggleEvent()
    else
        SetHyperlink(self, link, ...)
    end
end

-- 初始处理
C_Timer.After(3, function()
    ProcessFrames()
end)