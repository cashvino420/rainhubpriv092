--[[rainhub v2 — SCRIPT 1 of 2 · UI Shell]]
if _G.RainHub then pcall(_G.RainHub.Cleanup) end

local HUB = {
    CFG = {},
    Tabs = {},
    Elements = {}
}
_G.RainHub = HUB

local CFG = HUB.CFG
local COL = {
    bg=Color3.fromRGB(10,15,30), panel=Color3.fromRGB(15,20,40), border=Color3.fromRGB(0,120,255),
    txt=Color3.fromRGB(200,220,255), accent=Color3.fromRGB(0,150,255), off=Color3.fromRGB(30,40,60)
}

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer

local gui=Instance.new("ScreenGui")
gui.Name="rainhub_v2"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
do local ok=pcall(function() gui.Parent=game:GetService("CoreGui") end) if not ok or not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end end
HUB.gui = gui

local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,600,0,400); main.Position=UDim2.new(0.5,-300,0.5,-200)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0; main.Active=true; main.Draggable=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)
local stroke=Instance.new("UIStroke",main); stroke.Color=COL.border; stroke.Thickness=1.5

local side=Instance.new("Frame",main)
side.Size=UDim2.new(0,120,1,0); side.BackgroundColor3=COL.panel; side.BorderSizePixel=0
Instance.new("UICorner",side).CornerRadius=UDim.new(0,10)
local sideMask=Instance.new("Frame",side)
sideMask.Size=UDim2.new(0,10,1,0); sideMask.Position=UDim2.new(1,-10,0,0); sideMask.BackgroundColor3=COL.panel; sideMask.BorderSizePixel=0

local title=Instance.new("TextLabel",side)
title.Size=UDim2.new(1,0,0,50); title.BackgroundTransparency=1; title.Text="RAINHUB v2"
title.TextColor3=COL.accent; title.Font=Enum.Font.GothamBold; title.TextSize=16

local closeBtn=Instance.new("TextButton",main)
closeBtn.Size=UDim2.new(0,22,0,22); closeBtn.Position=UDim2.new(1,-28,0,6)
closeBtn.BackgroundColor3=Color3.fromRGB(160,40,200); closeBtn.Text="X"
closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=14; closeBtn.BorderSizePixel=0
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(1,0)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled=false end)

local content=Instance.new("Frame",main)
content.Size=UDim2.new(1,-130,1,-20); content.Position=UDim2.new(0,125,0,10)
content.BackgroundTransparency=1

local function makeTab(name, y)
    local btn=Instance.new("TextButton",side)
    btn.Size=UDim2.new(1,-10,0,30); btn.Position=UDim2.new(0,5,0,y)
    btn.BackgroundColor3=COL.off; btn.BackgroundTransparency=1
    btn.Text="   "..name; btn.TextColor3=COL.txt; btn.Font=Enum.Font.Gotham; btn.TextSize=13; btn.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local page=Instance.new("ScrollingFrame",content)
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ScrollBarThickness=2
    page.ScrollBarImageColor3=COL.accent; page.Visible=false
    HUB.Tabs[name]={btn=btn,page=page}
    btn.MouseButton1Click:Connect(function()
        for n,t in pairs(HUB.Tabs) do t.btn.BackgroundTransparency=1; t.page.Visible=false end
        btn.BackgroundTransparency=0.8; page.Visible=true
    end)
end

makeTab("Combat", 60); makeTab("Visuals", 95); makeTab("Player", 130); makeTab("World", 165); makeTab("Misc", 200)

function HUB.AddSection(parentName, text)
    local parent = HUB.Tabs[parentName].page
    local lbl=Instance.new("TextLabel",parent)
    lbl.Size=UDim2.new(1,-10,0,25); lbl.BackgroundTransparency=1; lbl.Text="  "..text
    lbl.TextColor3=COL.accent; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
end

function HUB.AddToggle(parentName, label, key)
    if CFG[key]==nil then CFG[key]=false end
    local parent = HUB.Tabs[parentName].page
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,-10,0,28); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0
    btn.Text="  "..label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.Gotham; btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local function paint() if CFG[key] then btn.BackgroundColor3=COL.accent; btn.BackgroundTransparency=0.5 else btn.BackgroundColor3=COL.panel; btn.BackgroundTransparency=0 end end
    btn.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; paint() end)
    paint()
end

function HUB.AddSlider(parentName, label, key, mn, mx, dec)
    if CFG[key]==nil then CFG[key]=mn end
    local parent = HUB.Tabs[parentName].page
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-10,0,40); row.BackgroundColor3=COL.panel; row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-10,0,16); lbl.Position=UDim2.new(0,10,0,2); lbl.BackgroundTransparency=1
    lbl.Text=label; lbl.TextColor3=COL.txt; lbl.Font=Enum.Font.Gotham; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",row); track.Size=UDim2.new(1,-20,0,6); track.Position=UDim2.new(0,10,0,24); track.BackgroundColor3=COL.off; track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",track); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=COL.accent; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local function paint()
        local p=(CFG[key]-mn)/(mx-mn); fill.Size=UDim2.new(p,0,1,0)
        if dec then lbl.Text=label.." : "..string.format(dec,CFG[key]) else lbl.Text=label.." : "..math.floor(CFG[key]) end
    end
    local drag=false
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local p=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            CFG[key]=mn+p*(mx-mn); paint()
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    paint()
end

function HUB.AddDropdown(parentName, label, key, opts)
    if CFG[key]==nil then CFG[key]=opts[1] end
    local parent = HUB.Tabs[parentName].page
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,-10,0,28); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0
    btn.Text="  "..label..": "..tostring(CFG[key]); btn.TextColor3=COL.txt; btn.Font=Enum.Font.Gotham; btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local open=false; local list=nil
    btn.MouseButton1Click:Connect(function()
        if open then if list then list:Destroy() end; open=false; return end
        open=true
        list=Instance.new("Frame",parent); list.Size=UDim2.new(1,-10,0,#opts*22+4); list.BackgroundColor3=COL.bg; list.BorderSizePixel=0
        Instance.new("UICorner",list).CornerRadius=UDim.new(0,6)
        for i,o in ipairs(opts) do
            local ob=Instance.new("TextButton",list); ob.Size=UDim2.new(1,-4,0,20); ob.Position=UDim2.new(0,2,0,2+(i-1)*22)
            ob.BackgroundColor3=(CFG[key]==o) and COL.accent or COL.off; ob.BackgroundTransparency=0.3; ob.BorderSizePixel=0
            ob.Text=o; ob.TextColor3=COL.txt; ob.Font=Enum.Font.Gotham; ob.TextSize=11
            Instance.new("UICorner",ob).CornerRadius=UDim.new(0,4)
            ob.MouseButton1Click:Connect(function() CFG[key]=o; btn.Text="  "..label..": "..o; if list then list:Destroy() end; open=false end)
        end
    end)
end

-- Build all the menu rows (Empty for now, Script 2 hooks into these)
-- COMBAT
HUB.AddSection("Combat", "AIMBOT")
HUB.AddToggle("Combat", "Aim Assist (RMB)", "aimOn")
HUB.AddToggle("Combat", "Aim Lock (Snap)", "aimLock")
HUB.AddToggle("Combat", "Wall Check", "wallCheck")
HUB.AddDropdown("Combat", "Aim Bone", "aimBone", {"Head","UpperTorso","HumanoidRootPart"})
HUB.AddToggle("Combat", "Team Check", "teamCheck")
HUB.AddSlider("Combat", "Aim FOV", "aimFOV", 50, 400)
HUB.AddSlider("Combat", "Aim Strength", "aimStrength", 10, 100)
HUB.AddSlider("Combat", "Aim Smooth", "aimSmooth", 0.02, 1.0, "%.2f")
HUB.AddSection("Combat", "TRIGGERBOT")
HUB.AddToggle("Combat", "Triggerbot (Hold X)", "triggerbot")
HUB.AddSlider("Combat", "Trigger Delay", "triggerDelay", 10, 200)
HUB.AddSection("Combat", "WEAPON")
HUB.AddToggle("Combat", "No Recoil", "noRecoil")
HUB.AddSlider("Combat", "Recoil Pull", "recoilPull", 0.3, 1.0, "%.2f")

-- PLAYER
HUB.AddSection("Player", "PLAYER ESP")
HUB.AddToggle("Player", "Players", "espPlayers")
HUB.AddToggle("Player", "Boxes", "box")
HUB.AddToggle("Player", "Names", "names")
HUB.AddToggle("Player", "Distance", "distlbl")
HUB.AddToggle("Player", "Health Bar", "hpBar")
HUB.AddToggle("Player", "Chams", "chams")
HUB.AddSlider("Player", "Player Dist", "playerMaxDist", 100, 2000)

-- VISUALS
HUB.AddSection("Visuals", "VISUAL MODS")
HUB.AddToggle("Visuals", "Fullbright", "fullbright")
HUB.AddToggle("Visuals", "No Fog", "noFog")
HUB.AddToggle("Visuals", "No Shadows", "noShadow")
HUB.AddSlider("Visuals", "FOV", "fov", 50, 120)
HUB.AddSection("Visuals", "CAMERA")
HUB.AddToggle("Visuals", "Free Camera", "freeCam")
HUB.AddSlider("Visuals", "Free Cam Speed", "freeCamSpeed", 10, 100)
HUB.AddToggle("Visuals", "Backpack Viewer", "backpackViewer")

-- WORLD
HUB.AddSection("World", "RESOURCES")
HUB.AddToggle("World", "Resource ESP", "resEsp")
HUB.AddToggle("World", "Stone", "resStone")
HUB.AddToggle("World", "Metal", "resMetal")
HUB.AddToggle("World", "Sulfur", "resSulfur")
HUB.AddToggle("World", "Wood", "resWood")
HUB.AddSlider("World", "Resource Dist", "resDist", 50, 1000)
HUB.AddSection("World", "ITEMS & BASES")
HUB.AddToggle("World", "Item ESP", "itemEsp")
HUB.AddToggle("World", "Base ESP", "baseEsp")
HUB.AddToggle("World", "Vehicles", "vehEsp")
HUB.AddSlider("World", "Base Dist", "baseDist", 100, 1000)

-- MISC
HUB.AddSection("Misc", "UTILITY")
HUB.AddToggle("Misc", "Container Loot (Press E)", "showLoot")

HUB.Tabs["Combat"].btn.BackgroundTransparency=0.8; HUB.Tabs["Combat"].page.Visible=true

_G.RainHub.Cleanup = function()
    pcall(function() gui:Destroy() end)
    _G.RainHub = nil
end

print("[rainhub] UI script online")