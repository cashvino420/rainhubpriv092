--[[
    rainhub v2 — FULL COMBINED FILE
    RoyalHub UI · Combat · Visuals/World · Extras
    Built by ☠ SYSTEM BREACHED ☠
--]]

local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

if _G.__RAINHUB then pcall(_G.__RAINHUB) end
local CONNS={}
local HUB={CFG={},tickers={},pool={}}
_G.__RAINHUB=HUB
_G.__RAINHUB_CORE=HUB

local CFG=HUB.CFG
-- Combat
CFG.aimOn=false; CFG.aimLock=false; CFG.wallLock=false; CFG.aimFOV=150; CFG.aimSmooth=0.25; CFG.aimBone="Head"
CFG.triggerbot=false; CFG.triggerKey="X"; CFG.triggerDelay=50
CFG.noRecoil=false; CFG.noSpread=false; CFG.teamCheck=false
-- Visuals/World
CFG.resEsp=false; CFG.resStone=true; CFG.resMetal=true; CFG.resSulfur=true; CFG.resWood=true; CFG.resDist=400; CFG.resAutoAim=false
CFG.itemEsp=false; CFG.itemDist=200
CFG.baseEsp=false; CFG.baseDist=400
CFG.sleepEsp=false; CFG.vehEsp=false
CFG.fullbright=false; CFG.noFog=false; CFG.noGrass=false; CFG.noShadow=false; CFG.adminCheck=false
-- Extras
CFG.soundEsp=false; CFG.projEsp=false; CFG.lootKey="E"; CFG.showLoot=false
CFG.freeCam=false; CFG.freeCamSpeed=20; CFG.fullBp=false

local COL={
  bg=Color3.fromRGB(10,15,30), panel=Color3.fromRGB(15,20,40), border=Color3.fromRGB(0,120,255),
  txt=Color3.fromRGB(200,220,255), accent=Color3.fromRGB(0,150,255), off=Color3.fromRGB(30,40,60),
  enemy=Color3.fromRGB(255,60,60), teammate=Color3.fromRGB(0,255,140)
}
HUB.COL=COL

local gui=Instance.new("ScreenGui")
gui.Name="rainhub_v2"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
do local ok=pcall(function() gui.Parent=game:GetService("CoreGui") end) if not ok or not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end end
HUB.gui=gui

-- Main Window
local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,600,0,400); main.Position=UDim2.new(0.5,-300,0.5,-200)
main.BackgroundColor3=COL.bg; main.BorderSizePixel=0
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)
local stroke=Instance.new("UIStroke",main); stroke.Color=COL.border; stroke.Thickness=1.5

-- Sidebar
local side=Instance.new("Frame",main)
side.Size=UDim2.new(0,120,1,0); side.BackgroundColor3=COL.panel; side.BorderSizePixel=0
Instance.new("UICorner",side).CornerRadius=UDim.new(0,10)
local sideMask=Instance.new("Frame",side)
sideMask.Size=UDim2.new(0,10,1,0); sideMask.Position=UDim2.new(1,-10,0,0); sideMask.BackgroundColor3=COL.panel; sideMask.BorderSizePixel=0

local title=Instance.new("TextLabel",side)
title.Size=UDim2.new(1,0,0,50); title.BackgroundTransparency=1; title.Text="RAINHUB v2"
title.TextColor3=COL.accent; title.Font=Enum.Font.GothamBold; title.TextSize=16

local content=Instance.new("Frame",main)
content.Size=UDim2.new(1,-130,1,-20); content.Position=UDim2.new(0,125,0,10)
content.BackgroundTransparency=1

-- Tab Logic
local tabs={}
local function makeTab(name, y)
  local btn=Instance.new("TextButton",side)
  btn.Size=UDim2.new(1,-10,0,30); btn.Position=UDim2.new(0,5,0,y)
  btn.BackgroundColor3=COL.off; btn.BackgroundTransparency=1
  btn.Text="   "..name; btn.TextColor3=COL.txt; btn.Font=Enum.Font.Gotham; btn.TextSize=13; btn.TextXAlignment=Enum.TextXAlignment.Left
  Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
  
  local page=Instance.new("ScrollingFrame",content)
  page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1; page.BorderSizePixel=0
  page.CanvasSize=UDim2.new(0,0,0,0); page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ScrollBarThickness=2
  page.Visible=false
  tabs[name]={btn=btn,page=page}
  
  btn.MouseButton1Click:Connect(function()
    for n,t in pairs(tabs) do t.btn.BackgroundTransparency=1; t.page.Visible=false end
    btn.BackgroundTransparency=0.8; page.Visible=true
  end)
end
HUB.tabs=tabs

makeTab("Combat", 60); makeTab("Visuals", 95); makeTab("Player", 130); makeTab("World", 165); makeTab("Misc", 200)

-- UI Builders
local function section(parent, text)
  local lbl=Instance.new("TextLabel",parent)
  lbl.Size=UDim2.new(1,-10,0,25); lbl.BackgroundTransparency=1; lbl.Text="  "..text
  lbl.TextColor3=COL.accent; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
end
local function toggle(parent, label, key)
  local btn=Instance.new("TextButton",parent)
  btn.Size=UDim2.new(1,-10,0,28); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0
  btn.Text="  "..label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.Gotham; btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
  Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
  local function paint()
    if CFG[key] then btn.BackgroundColor3=COL.accent; btn.BackgroundTransparency=0.5 else btn.BackgroundColor3=COL.panel; btn.BackgroundTransparency=0 end
  end
  btn.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; paint() end)
  paint()
end
local function slider(parent, label, key, mn, mx)
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
    lbl.Text=label.." : "..math.floor(CFG[key])
  end
  local drag=false
  track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
  CONNS[#CONNS+1]=UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
      local p=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
      CFG[key]=mn+p*(mx-mn); paint()
    end
  end)
  CONNS[#CONNS+1]=UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
  paint()
end

-- Populate UI
local combat=tabs["Combat"].page
section(combat, "AIMBOT")
toggle(combat, "Aim Assist (RMB)", "aimOn")
toggle(combat, "Aim Lock (Snap)", "aimLock")
toggle(combat, "Wall Lock (See through walls)", "wallLock")
toggle(combat, "Team Check", "teamCheck")
slider(combat, "FOV Radius", "aimFOV", 50, 400)
slider(combat, "Smoothness", "aimSmooth", 0.02, 1.0)

section(combat, "TRIGGERBOT (Vis-Gated)")
toggle(combat, "Enable Triggerbot", "triggerbot")
slider(combat, "Trigger Delay (ms)", "triggerDelay", 10, 500)

section(combat, "WEAPON")
toggle(combat, "No Recoil", "noRecoil")
toggle(combat, "No Spread", "noSpread")

local world=tabs["World"].page
section(world, "RESOURCES")
toggle(world, "Resource ESP", "resEsp")
toggle(world, "Stone", "resStone"); toggle(world, "Metal", "resMetal"); toggle(world, "Sulfur", "resSulfur"); toggle(world, "Wood", "resWood")
slider(world, "Resource Dist", "resDist", 50, 1000)

section(world, "ITEMS & BASES")
toggle(world, "Item ESP (Dropped)", "itemEsp")
slider(world, "Item Dist", "itemDist", 50, 500)
toggle(world, "Base ESP (Doors/Chests)", "baseEsp")
slider(world, "Base Dist", "baseDist", 100, 1000)
toggle(world, "Sleeping Players", "sleepEsp")
toggle(world, "Vehicle ESP", "vehEsp")

local vis=tabs["Visuals"].page
section(vis, "VISUAL MODS")
toggle(vis, "Fullbright", "fullbright")
toggle(vis, "No Fog", "noFog")
toggle(vis, "No Grass", "noGrass")
toggle(vis, "No Shadows", "noShadow")

local misc=tabs["Misc"].page
section(misc, "SERVER & TRACKING")
toggle(misc, "Show Admin Alerts", "adminCheck")
toggle(misc, "Sound ESP (Bullets)", "soundEsp")
toggle(misc, "Projectile Trajectory", "projEsp")
toggle(misc, "Resource Auto-Aim", "resAutoAim")

section(misc, "UTILITY")
toggle(misc, "Container Loot Viewer (Press E)", "showLoot")
toggle(misc, "Full Backpack Viewer", "fullBp")

section(vis, "CAMERA")
toggle(vis, "Free Camera", "freeCam")
slider(vis, "Free Cam Speed", "freeCamSpeed", 10, 100)

-- Default Tab
tabs["Combat"].btn.BackgroundTransparency=0.8; combat.Visible=true

-- Helper Functions
local vp=Vector2.new(Cam.ViewportSize.X,Cam.ViewportSize.Y)
local function w2s(p) local v=Cam:WorldToViewportPoint(p) if v.Z>0 then return Vector2.new(v.X,v.Y) end end
local function getCh(plr) local c=plr.Character if not c then return end local h=c:FindFirstChild("HumanoidRootPart") local u=c:FindFirstChildOfClass("Humanoid") if not h or not u or u.Health<=0 then return end return c,h,u end
local function sameT(a,b) return a.Team and b.Team and a.Team==b.Team end
local function visible(c,part)
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={c,LP.Character,Cam}
  local hit=WS:Raycast(Cam.CFrame.Position,part.Position-Cam.CFrame.Position,rp)
  if not hit then return true end
  return hit.Instance:IsDescendantOf(c)
end
local function boneOf(c) return c:FindFirstChild(CFG.aimBone) or c:FindFirstChild("Head") end
local function aimPos(p)
  local cp=Cam.CFrame.Position; local pos=p.Position; local d=(pos-cp).Magnitude
  local v=Vector3.new(); pcall(function() v=p.AssemblyLinearVelocity end); if not v then v=Vector3.new() end
  local t=d/math.max(700,1)
  if v.Magnitude>2 then local dir=(pos-cp).Unit; local clv=-v:Dot(dir); local den=700+clv; if den>1e-3 then local t2=d/den if t2>0 and t2<5 then t=t2 end end end
  return pos+v*t
end

local function getTarget(requireVis)
  local c2=Vector2.new(vp.X/2,vp.Y/2); local best=nil
  for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=LP and not (CFG.teamCheck and sameT(LP,plr)) then
      local c=getCh(plr)
      if c then local b=boneOf(c)
        if b then
          if not requireVis or visible(c,b) then
            local aim=aimPos(b); local sp=w2s(aim)
            if sp then local d=(sp-c2).Magnitude
              if d<=CFG.aimFOV and (not best or d<best.d) then best={pos=aim,d=d,char=c} end
            end
          end
        end
      end
    end
  end
  return best
end

local rP,rY=nil,nil; local lastShot=0
local function py() local l=Cam.CFrame.LookVector return math.asin(math.clamp(l.Y,-1,1)),math.atan2(-l.X,-l.Z) end
local function rb(p,y) local cp,sp=math.cos(p),math.sin(p) local cy,sy=math.cos(y),math.sin(y) local pos=Cam.CFrame.Position Cam.CFrame=CFrame.lookAt(pos,pos+Vector3.new(-sy*cp,sp,-cy*cp)) end

CONNS[#CONNS+1]=UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.UserInputType==Enum.UserInputType.MouseButton1 then lastShot=tick() if CFG.noRecoil then local p,y=py() rP,rY=p,y end end
end)

local function recoilTick()
  if not CFG.noRecoil then rP,rY=nil,nil return end
  local dt=(tick()-lastShot)*1000
  if dt>=260 or rP==nil then local p,y=py() rP,rY=p,y return end
  local cp,cy=py(); local dp=cp-rP; local dy=cy-rY
  if math.deg(math.abs(dp))>6 then rP,rY=cp,cy return end
  if math.deg(math.abs(dp))<0.01 then return end
  rb(cp-dp*0.98,cy-dy*0.98)
end

-- World Scan Logic
local snap={res={},items={},bases={},sleep={},veh={}}
local wPool={}
local function wSet(k) local s=wPool[k] if s then return s end s={box=Instance.new("Frame",gui),nm=Instance.new("TextLabel",gui)} s.box.BackgroundTransparency=1 s.box.BorderSizePixel=2 s.box.Visible=false Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4) s.nm.BackgroundTransparency=1 s.nm.Font=Enum.Font.GothamBold s.nm.TextSize=11 s.nm.Size=UDim2.new(0,200,0,14) s.nm.TextXAlignment=Enum.TextXAlignment.Center s.nm.Visible=false wPool[k]=s return s end
local function wDraw(s,sp,col,txt) s.box.Visible=true s.box.Position=UDim2.new(0,sp.X-12,0,sp.Y-12) s.box.Size=UDim2.new(0,24,0,24) s.box.BorderColor3=col s.nm.Visible=true s.nm.Text=txt s.nm.TextColor3=col s.nm.Position=UDim2.new(0,sp.X-100,0,sp.Y-26) end
local function wHide(s) s.box.Visible=false s.nm.Visible=false end

local scanning=false
local function fastPos(inst) if inst:IsA("BasePart") then return inst.Position end local ok,p=pcall(function() return inst:GetPivot().Position end) if ok then return p end end
local function runScan()
  if scanning then return end
  scanning=true
  local camPos=Cam.CFrame.Position
  local r,it,b,sl,v={},{},{},{},{}
  local stack={} for _,c in ipairs(WS:GetChildren()) do stack[#stack+1]=c end
  local i=0
  while #stack>0 do
    local inst=table.remove(stack) i=i+1
    local nm=string.lower(inst.Name)
    if CFG.resEsp then
      local ty= (CFG.resStone and nm:find("stone")) or (CFG.resMetal and nm:find("metal")) or (CFG.resSulfur and nm:find("sulfur")) or (CFG.resWood and nm:find("wood"))
      if ty then local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=CFG.resDist then r[#r+1]={i=inst,p=p,d=d,n=inst.Name} end end end
    end
    if CFG.itemEsp and inst:IsA("Model") and inst:FindFirstChildOfClass("Tool") then
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=CFG.itemDist then it[#it+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.baseEsp then
      local isB = (nm:find("door") or nm:find("furnace") or nm:find("chest") or nm:find("box") or nm:find("turret") or nm:find("trap") or nm:find("locker") or nm:find("cupboard"))
      if isB and (inst:IsA("Model") or inst:IsA("BasePart")) then
        local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=CFG.baseDist then b[#b+1]={i=inst,p=p,d=d,n=inst.Name} end end
      end
    end
    if CFG.sleepEsp and inst:IsA("Model") and not Players:GetPlayerFromCharacter(inst) then
      local h=inst:FindFirstChildOfClass("Humanoid")
      if h and h.Health<=0 then local p=fastPos(inst) if p then sl[#sl+1]={i=inst,p=p,d=(p-camPos).Magnitude,n=inst.Name.." (Sleep)"} end end
    end
    if CFG.vehEsp and (nm:find("atv") or nm:find("minicopter") or nm:find("boat") or nm:find("rhib")) then
      local p=fastPos(inst) if p then v[#v+1]={i=inst,p=p,d=(p-camPos).Magnitude,n=inst.Name} end
    end
    for _,ch in ipairs(inst:GetChildren()) do stack[#stack+1]=ch end
    if i%150==0 then task.wait() end
  end
  snap={res=r,items=it,bases=b,sleep=sl,veh=v}
  scanning=false
end

-- Container Loot UI
local lootPanel=Instance.new("Frame",gui)
lootPanel.Size=UDim2.new(0,200,0,300); lootPanel.Position=UDim2.new(1,-220,0,100)
lootPanel.BackgroundColor3=COL.bg; lootPanel.BorderSizePixel=0; lootPanel.Visible=false
Instance.new("UICorner",lootPanel).CornerRadius=UDim.new(0,8)
local lpStroke=Instance.new("UIStroke",lootPanel); lpStroke.Color=COL.border
local lpScroll=Instance.new("ScrollingFrame",lootPanel); lpScroll.Size=UDim2.new(1,-10,1,-10); lpScroll.Position=UDim2.new(0,5,0,5); lpScroll.BackgroundTransparency=1; lpScroll.BorderSizePixel=0; lpScroll.CanvasSize=UDim2.new(0,0,0,0); lpScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local lpLyt=Instance.new("UIListLayout",lpScroll); lpLyt.Padding=UDim.new(0,2)

local function showLootUI(c)
  lootPanel.Visible=true
  for _,v in ipairs(lpScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
  local h=Instance.new("TextLabel",lpScroll); h.Size=UDim2.new(1,0,0,20); h.BackgroundTransparency=1; h.Text=c.Name; h.TextColor3=COL.accent; h.Font=Enum.Font.GothamBold; h.TextSize=13; h.TextXAlignment=Enum.TextXAlignment.Left
  for _,item in ipairs(c:GetChildren()) do
    if item:IsA("Tool") or item:IsA("Model") then
      local lbl=Instance.new("TextLabel",lpScroll); lbl.Size=UDim2.new(1,0,0,16); lbl.BackgroundTransparency=1; lbl.Text="  "..item.Name; lbl.TextColor3=COL.txt; lbl.Font=Enum.Font.Gotham; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
    end
  end
end

UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.KeyCode==Enum.KeyCode[CFG.lootKey] and CFG.showLoot then
    local rp=RaycastParams.new(); rp.FilterDescendantsInstances={LP.Character}
    local ray=WS:Raycast(Cam.CFrame.Position, Cam.CFrame.LookVector*15, rp)
    if ray then
      local target=ray.Instance
      while target and not (target:FindFirstChildOfClass("Tool") or target:FindFirstChild("Items")) do
        target=target.Parent
        if target==WS then target=nil break end
      end
      if target then showLootUI(target) else lootPanel.Visible=false end
    else lootPanel.Visible=false end
  end
end)

-- Free Cam
local fCam=false; local fPos=nil; local origType=nil

local function tickAll()
  recoilTick()
  
  -- Aim (can shoot through walls if wallLock is true)
  if (CFG.aimOn or CFG.aimLock) and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    local t = getTarget(not CFG.wallLock)
    if t then
      local cp=Cam.CFrame.Position; local cur=Cam.CFrame.LookVector; local tgt=(t.pos-cp).Unit
      local pull=CFG.aimLock and 1.0 or math.clamp(CFG.aimSmooth,0.02,1)
      local nl=cur:Lerp(tgt,pull).Unit
      rb(math.asin(math.clamp(nl.Y,-1,1)),math.atan2(-nl.X,-nl.Z))
    end
  end
  
  -- Triggerbot (ALWAYS vis-gated. Will not shoot through walls.)
  if CFG.triggerbot and UIS:IsKeyDown(Enum.KeyCode[CFG.triggerKey]) then
    local t = getTarget(true) -- true = MUST be visible
    if t and w2s(t.pos) then
      pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2, 0, true, game, 1)
        task.wait(CFG.triggerDelay/1000)
        vim:SendMouseButtonEvent(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2, 0, false, game, 1)
      end)
    end
  end
  
  -- Visual Mods
  Lighting.FogEnd = CFG.noFog and 1e6 or 100000
  Lighting.Brightness = CFG.fullbright and 2 or 1
  Lighting.GlobalShadows = not CFG.noShadow
  pcall(function() WS.Terrain.Decoration = CFG.noGrass end)

  -- World Scan
  if tick() - (HUB.lastWScan or 0) >= 4 then
    HUB.lastWScan = tick()
    task.spawn(function() pcall(runScan) end)
  end
  
  -- World Render
  local live={}
  local camPos=Cam.CFrame.Position
  for _,cat in pairs(snap) do
    for _,e in ipairs(cat) do
      if e.i.Parent then
        local sp=HUB.w2s(e.p)
        if sp then live[e.i]=true wDraw(wSet(e.i),sp,COL.accent,e.n) end
      end
    end
  end
  for k,s in pairs(wPool) do if not live[k] then wHide(s) end end

  -- Free Cam
  if CFG.freeCam and not fCam then
    fCam=true; fPos=Cam.CFrame.Position; origType=Cam.CameraType
  elseif not CFG.freeCam and fCam then
    fCam=false; Cam.CameraType=origType
  end
  if fCam then
    local rot=Cam.CFrame.Rotation
    local pos=fPos
    local m=Vector3.new(0,0,0)
    if UIS:IsKeyDown(Enum.KeyCode.W) then m=m+rot.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then m=m-rot.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then m=m-rot.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then m=m+rot.RightVector end
    if m.Magnitude>0 then pos=pos+m.Unit*CFG.freeCamSpeed*0.1 end
    fPos=pos
    Cam.CFrame=CFrame.new(pos, pos+rot.LookVector)
  end
  
  for _,fn in ipairs(HUB.tickers) do pcall(fn) end
end

local BIND="rainhub2_"..tostring(math.random(100000,999999))
RS:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value+1, tickAll)
CONNS[#CONNS+1]={Disconnect=function() pcall(function() RS:UnbindFromRenderStep(BIND) end) end}

_G.__RAINHUB=function()
  for _,c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
  pcall(function() gui:Destroy() end)
  _G.__RAINHUB_CORE=nil
end
print("[rainhub v2] FULL online — RoyalHub UI, Combat, World, Extras")