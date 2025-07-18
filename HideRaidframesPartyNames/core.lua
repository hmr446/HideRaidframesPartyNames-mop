-- HideRaidframesPartyNames for WoW 5.4.8
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

-- ���ô洢
HPN_SHOW_PARTY = HPN_SHOW_PARTY or false

-- 5.4.8���ݵ���ɫ����
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

-- 5.4.8���ݵĳ����Ӻ���
local function MakeLink(text, id)
    return format("|H%s|h%s|h", id, text)
end

-- ���������л�������5.4.8���ݣ�
local function ToggleName(frame)
    if not frame or not frame.GetName then return end
    
    -- 5.4.8��������frame.name������
    local nameText = frame.name
    
    if nameText and nameText:IsObjectType("FontString") then
        if HPN_SHOW_PARTY then
            nameText:Show()
        else
            nameText:Hide()
        end
    end
end

-- 5.4.8���ݵĿ�ܴ�����
local function ProcessFrames()
    -- �����Ŷӿ�� (1-40)
    for i = 1, 40 do
        local frame = _G["CompactRaidFrame"..i]
        if frame then
            ToggleName(frame)
        end
        
        -- ���������
        local petFrame = _G["CompactRaidFrame"..i.."PetFrame"]
        if petFrame and petFrame.name then
            ToggleName(petFrame)
        end
    end
    
    -- ����С�ӿ�� (1-5)
    for i = 1, 5 do
        local frame = _G["PartyMemberFrame"..i]
        if frame then
            ToggleName(frame)
        end
    end
end

-- �¼�����
function f:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "HideRaidframesPartyNames" then
        -- ��ʼ������
        HPN_SHOW_PARTY = HPN_SHOW_PARTY or false
        
        -- ��ȫ��ס���ָ��º���
        hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
            ToggleName(frame)
        end)
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- ȷ��UI������ɺ��ٴ���
        C_Timer.After(2, function()
            ProcessFrames()
        end)
    end
end

f:SetScript("OnEvent", f.OnEvent)

-- �л�������ʾ״̬
local function CallToggleEvent()
    HPN_SHOW_PARTY = not HPN_SHOW_PARTY
    ProcessFrames()
    
    -- ��ʾ״̬��Ϣ
    local statusText = HPN_SHOW_PARTY and ColorText("ON", "green") or ColorText("OFF", "red")
    DEFAULT_CHAT_FRAME:AddMessage(ColorText("[HideRaidframesPartyNames]", "blue") .. 
        " �Ŷӿ��������ʾ: " .. statusText)
end

-- �����
local function ProcessCommands(msg, editbox)
    msg = msg and strlower(msg) or ""
    
    if msg == "toggle" then
        CallToggleEvent()
    else
        -- ��ʾ������Ϣ
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("[HideRaidframesPartyNames] �������:", "yellow"))
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("/hrpn toggle", "orange") .. " - �л�������ʾ״̬")
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("/hrpn status", "orange") .. " - ��ʾ��ǰ״̬")
        DEFAULT_CHAT_FRAME:AddMessage(ColorText("��ǰ״̬: ", "yellow") .. 
            (HPN_SHOW_PARTY and ColorText("��ʾ����", "green") or ColorText("��������", "red")))
    end
end

-- ע��б������
SLASH_HIDEPARTYNAME1 = "/hrpn"
SlashCmdList["HIDEPARTYNAME"] = ProcessCommands

-- 5.4.8���ݵĳ����Ӵ���
local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
    if link and link:sub(1, 8) == "myXghkkL" then
        CallToggleEvent()
    else
        SetHyperlink(self, link, ...)
    end
end

-- ��ʼ����
C_Timer.After(3, function()
    ProcessFrames()
end)