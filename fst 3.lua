--[[rainhub v2 — SCRIPT 3 · Triggerbot, Free Cam, Spectate, Backpack, Container Loot, Admin]]
local HUB=_G.__RAINHUB_CORE
if not HUB then warn("[rainhub] core not loaded"); return end
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local WS=game:GetService("Workspace")
local Cam=WS.CurrentCamera
local LP=Players.LocalPlayer
local CFG=HUB.CFG
local COL=HUB.COL
local gui=HUB.gui
local tabs=HUB.tabs
local section=HUB.addSection
local toggle=HUB.addToggle
local slider=HUB.addSlider

-- Extended Config
CFG.triggerbot=false; CFG.triggerKey="X"; CFG.triggerDelay=50
CFG.freeCam=false; CFG.freeCamSpeed=20
CFG.spectateName="None"
CFG.backpackViewer=false
CFG.lootKey="E"; CFG.showLoot=false
CFG.adminCheck=false; CFG.soundEsp=false; CFG.projEsp=false

-- UI: Combat (Triggerbot)
local combat=tabs["Combat"].page
section(combat, "TRIGGERBOT (Vis-Gated)")
toggle(combat, "Enable Triggerbot (Hold X)", "triggerbot")
slider(combat, "Trigger Delay (ms)", "triggerDelay", 10, 200)

-- UI: Visuals (Free Cam)
local vis=tabs["Visuals"].page
section(vis, "CAMERA")
toggle(vis, "Free Camera", "freeCam")
slider(vis, "Free Cam Speed", "freeCamSpeed", 10, 100)
toggle(vis, "Backpack Viewer", "backpackViewer")

local function buildPlayerOptions() local o={"None"} for _,p in ipairs(Players:GetPlayers()) do if p~=LP then o[#o+1]=p.Name end end return o end
HUB.addDropdown(vis, "Spectate Player", "spectateName", buildPlayerOptions)

-- UI: Misc (Extras)
local misc=tabs["Misc"].page
section(misc, "UTILITY")
toggle(misc, "Container Loot Viewer (Press E)", "showLoot")
toggle(misc, "Admin Join Alerts", "adminCheck")
toggle(misc, "Sound ESP", "soundEsp")

-- Helper: Get Visible Target for Triggerbot
local function visCheck(c,part)
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={c,LP.Character,Cam}
  local hit=WS:Raycast(Cam.CFrame.Position,part.Position-Cam.CFrame.Position,rp)
  if not hit then return true end
  return hit.Instance:IsDescendantOf(c)
end
local function getTbTarget()
  local c2=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2); local best=nil
  for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=LP and not (CFG.teamCheck and HUB.sameT(LP,plr)) then
      local c,h,u=HUB.getCh(plr)
      if c then local b=c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso")
        if b and visCheck(c,b) then
          local sp=HUB.w2s(b.Position)
          if sp then local d=(sp-c2).Magnitude
            if d<=CFG.aimFOV and (not best or d<best.d) then best={d=d, pos=b.Position} end
          end
        end
      end
    end
  end
  return best
end

-- Backpack Viewer Panel
local bpFrame=Instance.new("Frame",gui)
bpFrame.Size=UDim2.new(0,240,0,320); bpFrame.Position=UDim2.new(1,-256,0,60)
bpFrame.BackgroundColor3=COL.bg; bpFrame.BorderSizePixel=0; bpFrame.Visible=false
Instance.new("UICorner",bpFrame).CornerRadius=UDim.new(0,14)
local bpSt=Instance.new("UIStroke",bpFrame); bpSt.Color=COL.border; bpSt.Thickness=1.5
local bpScroll=Instance.new("ScrollingFrame",bpFrame); bpScroll.Size=UDim2.new(1,-12,1,-40); bpScroll.Position=UDim2.new(0,6,0,34)
bpScroll.BackgroundTransparency=1; bpScroll.BorderSizePixel=0; bpScroll.CanvasSize=UDim2.new(0,0,0,0); bpScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
bpScroll.ScrollBarThickness=3; bpScroll.ScrollBarImageColor3=COL.accent
local bpLyt=Instance.new("UIListLayout",bpScroll); bpLyt.Padding=UDim.new(0,3)

-- Container Loot Panel
local lootFrame=Instance.new("Frame",gui)
lootFrame.Size=UDim2.new(0,200,0,250); lootFrame.Position=UDim2.new(1,-260,0,60)
lootFrame.BackgroundColor3=COL.bg; lootFrame.BorderSizePixel=0; lootFrame.Visible=false
Instance.new("UICorner",lootFrame).CornerRadius=UDim.new(0,14)
local lootSt=Instance.new("UIStroke",lootFrame); lootSt.Color=COL.border; lootSt.Thickness=1.5
local lootScroll=Instance.new("ScrollingFrame",lootFrame); lootScroll.Size=UDim2.new(1,-12,1,-12); lootScroll.Position=UDim2.new(0,6,0,6)
lootScroll.BackgroundTransparency=1; lootScroll.BorderSizePixel=0; lootScroll.CanvasSize=UDim2.new(0,0,0,0); lootScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local lootLyt=Instance.new("UIListLayout",lootScroll); lootLyt.Padding=UDim.new(0,3)

-- Free Cam State
local fCam=false; local fPos=nil; local origType=nil
local specEng=false

UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.KeyCode==Enum.KeyCode[CFG.lootKey] and CFG.showLoot then
    local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character}
    local hit=WS:Raycast(Cam.CFrame.Position, Cam.CFrame.LookVector*15, rp)
    if hit then
      local tgt=hit.Instance
      while tgt and not tgt:FindFirstChild("Items") and not tgt:FindFirstChildOfClass("Tool") do
        tgt=tgt.Parent
        if tgt==WS then tgt=nil break end
      end
      if tgt then
        lootFrame.Visible=true
        for _,v in ipairs(lootScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
        local hd=Instance.new("TextLabel",lootScroll); hd.Size=UDim2.new(1,0,0,20); hd.BackgroundTransparency=1; hd.Text=tgt.Name; hd.TextColor3=COL.accent; hd.Font=Enum.Font.GothamBold; hd.TextSize=13; hd.TextXAlignment=Enum.TextXAlignment.Left
        for _,i in ipairs(tgt:GetChildren()) do
          if i:IsA("Model") or i:IsA("Tool") then
            local row=Instance.new("TextLabel",lootScroll); row.Size=UDim2.new(1,0,0,16); row.BackgroundTransparency=1; row.Text="  "..i.Name; row.TextColor3=COL.txt; row.Font=Enum.Font.Gotham; row.TextSize=11; row.TextXAlignment=Enum.TextXAlignment.Left
          end
        end
      else lootFrame.Visible=false end
    else lootFrame.Visible=false end
  end
end)

-- Spectate cleanup function
local function relSpec() if specEng then Cam.CameraType=origType or Enum.CameraType.Custom; origType=nil; specEng=false end end

HUB.addTicker(function()
  -- 1. Triggerbot
  if CFG.triggerbot and UIS:IsKeyDown(Enum.KeyCode[CFG.triggerKey]) then
    local t = getTbTarget()
    if t then
      pcall(function()
        local vim=game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2, 0, true, game, 1)
        task.wait(CFG.triggerDelay/1000)
        vim:SendMouseButtonEvent(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2, 0, false, game, 1)
      end)
    end
  end

  -- 2. Free Cam
  if CFG.freeCam and not fCam then fCam=true; fPos=Cam.CFrame.Position; origType=Cam.CameraType
  elseif not CFG.freeCam and fCam then fCam=false; Cam.CameraType=origType end
  if fCam then
    local rot=Cam.CFrame.Rotation; local pos=fPos; local m=Vector3.new(0,0,0)
    if UIS:IsKeyDown(Enum.KeyCode.W) then m=m+rot.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then m=m-rot.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then m=m-rot.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then m=m+rot.RightVector end
    if m.Magnitude>0 then pos=pos+m.Unit*CFG.freeCamSpeed*0.1 end
    fPos=pos; Cam.CFrame=CFrame.new(pos, pos+rot.LookVector)
  end

  -- 3. Spectate
  if fCam then relSpec()
  elseif CFG.spectateName~="" and CFG.spectateName~="None" then
    local p=Players:FindFirstChild(CFG.spectateName)
    if p then local c,h=HUB.getCh(p) if c and h then if origType==nil then origType=Cam.CameraType end Cam.CameraType=Enum.CameraType.Scriptable; Cam.CFrame=CFrame.lookAt(h.Position+h.CFrame.LookVector*-6+Vector3.new(0,2,0),h.Position); specEng=true else relSpec() end else relSpec() end
  else relSpec() end

  -- 4. Backpack Viewer (Simplified expandable)
  if CFG.backpackViewer then
    bpFrame.Visible=true
    if tick() - (HUB.lastBp or 0) >= 1 then
      HUB.lastBp=tick()
      for _,c in ipairs(bpScroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
      local idx=0
      for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
          idx=idx+1
          local hd=Instance.new("TextLabel",bpScroll); hd.Size=UDim2.new(1,0,0,18); hd.BackgroundTransparency=1; hd.Text=p.Name; hd.TextColor3=COL.accent; hd.Font=Enum.Font.GothamBold; hd.TextSize=12; hd.TextXAlignment=Enum.TextXAlignment.Left
          local bp=p:FindFirstChildOfClass("Backpack"); local eq=p.Character and p.Character:FindFirstChildOfClass("Tool")
          if eq then local r=Instance.new("TextLabel",bpScroll); r.Size=UDim2.new(1,0,0,14); r.BackgroundTransparency=1; r.Text="  [EQ] "..eq.Name; r.TextColor3=COL.txt; r.Font=Enum.Font.Gotham; r.TextSize=10; r.TextXAlignment=Enum.TextXAlignment.Left end
          if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local r=Instance.new("TextLabel",bpScroll); r.Size=UDim2.new(1,0,0,14); r.BackgroundTransparency=1; r.Text="  "..t.Name; r.TextColor3=COL.txt; r.Font=Enum.Font.Gotham; r.TextSize=10; r.TextXAlignment=Enum.TextXAlignment.Left end end end
        end
      end
    end
  else bpFrame.Visible=false end
end)

local oldCleanup=_G.__RAINHUB
_G.__RAINHUB=function()
  relSpec()
  if fCam then Cam.CameraType=origType end
  if bpFrame then bpFrame:Destroy() end
  if lootFrame then lootFrame:Destroy() end
  if oldCleanup then pcall(oldCleanup) end
end

print("[rainhub v2] script 3 online — Triggerbot, Cam, Spectate, Backpack, Loot")