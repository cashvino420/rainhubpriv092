--[[rainhub v2 — FINAL COMBINED (UI + Logic in one, no scoping bugs)]]
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

if _G.__RAINHUB then pcall(_G.__RAINHUB) end
local CONNS={}
local HUB={CFG={},Tabs={}}
_G.__RAINHUB=HUB
_G.__RAINHUB_CORE=HUB
local CFG=HUB.CFG

local COL={
    bg=Color3.fromRGB(10,15,30), panel=Color3.fromRGB(15,20,40), border=Color3.fromRGB(0,120,255),
    txt=Color3.fromRGB(200,220,255), accent=Color3.fromRGB(0,150,255), off=Color3.fromRGB(30,40,60),
    enemy=Color3.fromRGB(255,60,60), teammate=Color3.fromRGB(0,255,140)
}

local gui=Instance.new("ScreenGui")
gui.Name="rainhub_v2"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
do local ok=pcall(function() gui.Parent=game:GetService("CoreGui") end) if not ok or not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end end
HUB.gui=gui

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
content.Size=UDim2.new(1,-130,1,-20); content.Position=UDim2.new(0,125,0,10); content.BackgroundTransparency=1

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

local function section(parentName, text)
    local parent=HUB.Tabs[parentName].page
    local lbl=Instance.new("TextLabel",parent)
    lbl.Size=UDim2.new(1,-10,0,25); lbl.BackgroundTransparency=1; lbl.Text="  "..text
    lbl.TextColor3=COL.accent; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
end
local function toggle(parentName, label, key)
    if CFG[key]==nil then CFG[key]=false end
    local parent=HUB.Tabs[parentName].page
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,-10,0,28); btn.BackgroundColor3=COL.panel; btn.BorderSizePixel=0
    btn.Text="  "..label; btn.TextColor3=COL.txt; btn.Font=Enum.Font.Gotham; btn.TextSize=12; btn.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local function paint() if CFG[key] then btn.BackgroundColor3=COL.accent; btn.BackgroundTransparency=0.5 else btn.BackgroundColor3=COL.panel; btn.BackgroundTransparency=0 end end
    btn.MouseButton1Click:Connect(function() CFG[key]=not CFG[key]; paint() end)
    paint()
end
local function slider(parentName, label, key, mn, mx, dec)
    if CFG[key]==nil then CFG[key]=mn end
    local parent=HUB.Tabs[parentName].page
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
local function dropdown(parentName, label, key, opts)
    if CFG[key]==nil then CFG[key]=opts[1] end
    local parent=HUB.Tabs[parentName].page
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

-- Build UI
section("Combat", "AIMBOT")
toggle("Combat", "Aim Assist (RMB)", "aimOn")
toggle("Combat", "Aim Lock (Snap)", "aimLock")
toggle("Combat", "Wall Check", "wallCheck")
dropdown("Combat", "Aim Bone", "aimBone", {"Head","UpperTorso","HumanoidRootPart"})
toggle("Combat", "Team Check", "teamCheck")
slider("Combat", "Aim FOV", "aimFOV", 50, 400)
slider("Combat", "Aim Strength", "aimStrength", 10, 100)
slider("Combat", "Aim Smooth", "aimSmooth", 0.02, 1.0, "%.2f")
section("Combat", "TRIGGERBOT")
toggle("Combat", "Triggerbot (Hold X)", "triggerbot")
slider("Combat", "Trigger Delay", "triggerDelay", 10, 200)
section("Combat", "WEAPON")
toggle("Combat", "No Recoil", "noRecoil")
slider("Combat", "Recoil Pull", "recoilPull", 0.3, 1.0, "%.2f")

section("Player", "PLAYER ESP")
toggle("Player", "Players", "espPlayers")
toggle("Player", "Boxes", "box")
toggle("Player", "Names", "names")
toggle("Player", "Distance", "distlbl")
toggle("Player", "Health Bar", "hpBar")
toggle("Player", "Chams", "chams")
slider("Player", "Player Dist", "playerMaxDist", 100, 2000)

section("Visuals", "VISUAL MODS")
toggle("Visuals", "Fullbright", "fullbright")
toggle("Visuals", "No Fog", "noFog")
toggle("Visuals", "No Shadows", "noShadow")
slider("Visuals", "FOV", "fov", 50, 120)
section("Visuals", "CAMERA")
toggle("Visuals", "Free Camera", "freeCam")
slider("Visuals", "Free Cam Speed", "freeCamSpeed", 10, 100)
toggle("Visuals", "Backpack Viewer", "backpackViewer")

section("World", "RESOURCES")
toggle("World", "Resource ESP", "resEsp")
toggle("World", "Stone", "resStone")
toggle("World", "Metal", "resMetal")
toggle("World", "Sulfur", "resSulfur")
toggle("World", "Wood", "resWood")
slider("World", "Resource Dist", "resDist", 50, 1000)
section("World", "ITEMS & BASES")
toggle("World", "Item ESP", "itemEsp")
toggle("World", "Base ESP", "baseEsp")
toggle("World", "Vehicles", "vehEsp")
slider("World", "Base Dist", "baseDist", 100, 1000)

section("Misc", "UTILITY")
toggle("Misc", "Container Loot (Press E)", "showLoot")

HUB.Tabs["Combat"].btn.BackgroundTransparency=0.8; HUB.Tabs["Combat"].page.Visible=true

-- ==========================================
-- LOGIC
-- ==========================================
local vp=Vector2.new(Cam.ViewportSize.X,Cam.ViewportSize.Y)
local function w2s(p) local v=Cam:WorldToViewportPoint(p) if v.Z>0 then return Vector2.new(v.X,v.Y) end end
local function getCh(plr) local c=plr.Character if not c then return end local h=c:FindFirstChild("HumanoidRootPart") local u=c:FindFirstChildOfClass("Humanoid") if not h or not u or u.Health<=0 then return end return c,h,u end
local function sameT(a,b) return a.Team and b.Team and a.Team==b.Team end
local function bboxCF(cf,sz)
  local half=sz/2; local a,b,x,y=math.huge,math.huge,-math.huge,-math.huge
  for xi=-1,1,2 do for yi=-1,1,2 do for zi=-1,1,2 do
    local wp=(cf*CFrame.new(half.X*xi,half.Y*yi,half.Z*zi)).Position; local v=Cam:WorldToViewportPoint(wp)
    if v.Z>0 then if v.X<a then a=v.X end if v.Y<b then b=v.Y end if v.X>x then x=v.X end if v.Y>y then y=v.Y end end
  end end end
  if a==math.huge then return end
  return Vector2.new(a,b),Vector2.new(x,y)
end

local espCache={}
local function setFor(k)
  local s=espCache[k]; if s then return s end
  s={box=Instance.new("Frame",gui),nm=Instance.new("TextLabel",gui),ds=Instance.new("TextLabel",gui),hp=Instance.new("Frame",gui),hpB=Instance.new("Frame",gui)}
  s.box.BackgroundTransparency=1; s.box.BorderSizePixel=2; s.box.Visible=false
  Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4)
  s.nm.BackgroundTransparency=1; s.nm.Font=Enum.Font.GothamBold; s.nm.TextSize=13; s.nm.Size=UDim2.new(0,200,0,14); s.nm.TextXAlignment=Enum.TextXAlignment.Center; s.nm.Visible=false
  s.ds.BackgroundTransparency=1; s.ds.TextColor3=Color3.fromRGB(220,220,220); s.ds.Font=Enum.Font.Gotham; s.ds.TextSize=11; s.ds.Size=UDim2.new(0,200,0,12); s.ds.TextXAlignment=Enum.TextXAlignment.Center; s.ds.Visible=false
  s.hp.BackgroundColor3=Color3.fromRGB(0,255,140); s.hp.BorderSizePixel=0; s.hp.Visible=false
  s.hpB.BackgroundColor3=Color3.fromRGB(30,30,30); s.hpB.BorderSizePixel=0; s.hpB.Visible=false
  espCache[k]=s; return s
end
local function hideEsp(s) s.box.Visible=false; s.nm.Visible=false; s.ds.Visible=false; s.hp.Visible=false; s.hpB.Visible=false end
local function drawEsp(s,tl,br,col,name,d,hpFrac)
  local w,h=br.X-tl.X,br.Y-tl.Y
  if CFG.box then s.box.Visible=true; s.box.Position=UDim2.new(0,tl.X,0,tl.Y); s.box.Size=UDim2.new(0,w,0,h); s.box.BorderColor3=col else s.box.Visible=false end
  if CFG.names then s.nm.Visible=true; s.nm.Text=name; s.nm.TextColor3=col; s.nm.Position=UDim2.new(0,tl.X+w/2-100,0,tl.Y-14) else s.nm.Visible=false end
  if CFG.distlbl then s.ds.Visible=true; s.ds.Text="["..math.floor(d).."m]"; s.ds.Position=UDim2.new(0,tl.X+w/2-100,0,br.Y+1) else s.ds.Visible=false end
  if CFG.hpBar and hpFrac then s.hpB.Visible=true; s.hpB.Position=UDim2.new(0,tl.X-4,0,tl.Y); s.hpB.Size=UDim2.new(0,2,0,h); s.hp.Visible=true; s.hp.Position=UDim2.new(0,tl.X-4,0,tl.Y+h-h*hpFrac); s.hp.Size=UDim2.new(0,2,0,h*hpFrac) else s.hp.Visible=false; s.hpB.Visible=false end
end

local cham={}
local function setChams(plr,ch)
  if not (CFG.chams and CFG.espPlayers) then local h=cham[plr]; if h and h.Parent then h:Destroy() end cham[plr]=nil return end
  local h=cham[plr]
  if not h or h.Parent~=ch then local o=cham[plr]; if o and o.Parent then o:Destroy() end h=Instance.new("Highlight"); h.Adornee=ch; h.Parent=ch; cham[plr]=h end
  h.FillColor=Color3.fromRGB(255,20,20); h.OutlineColor=Color3.fromRGB(255,0,0); h.FillTransparency=0.35; h.OutlineTransparency=0; h.DepthMode=Enum.HighlightDepthMode.Occluded
end

local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.IgnoreWater=true
local function visible(c,part)
  rp.FilterDescendantsInstances={c,LP.Character,Cam}
  local hit=WS:Raycast(Cam.CFrame.Position,part.Position-Cam.CFrame.Position,rp)
  if not hit then return true end
  return hit.Instance:IsDescendantOf(c)
end
local function boneOf(c) return c:FindFirstChild(CFG.aimBone) or c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart") end
local function aimPos(p)
  local cp=Cam.CFrame.Position; local pos=p.Position; local d=(pos-cp).Magnitude
  local v=Vector3.new(); pcall(function() v=p.AssemblyLinearVelocity end); if not v then v=Vector3.new() end
  local t=d/math.max(700,1)
  return pos+v*t
end
local function getTarget(requireVis)
  local c2=Vector2.new(vp.X/2,vp.Y/2); local best=nil
  for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=LP and not (CFG.teamCheck and sameT(LP,plr)) then
      local c=getCh(plr)
      if c then local b=boneOf(c)
        if b and (not requireVis or not CFG.wallCheck or visible(c,b)) then
          local aim=aimPos(b); local sp=w2s(aim)
          if sp then local d=(sp-c2).Magnitude; if d<=(CFG.aimFOV or 250) and (not best or d<best.d) then best={pos=aim,d=d} end end
        end
      end
    end
  end
  return best
end
local rP,rY=nil,nil; local lastShot=0
local function py() local l=Cam.CFrame.LookVector return math.asin(math.clamp(l.Y,-1,1)),math.atan2(-l.X,-l.Z) end
local function rb(p,y) local cp,sp=math.cos(p),math.sin(p) local cy,sy=math.cos(y),math.sin(y) local dir=Vector3.new(-sy*cp,sp,-cy*cp) local pos=Cam.CFrame.Position Cam.CFrame=CFrame.lookAt(pos,pos+dir) end
local function recoilTick()
  if not CFG.noRecoil then rP,rY=nil,nil return end
  local dt=(tick()-lastShot)*1000
  if dt>=260 or rP==nil then local p,y=py() rP,rY=p,y return end
  local cp,cy=py(); local dp=cp-rP; local dy=cy-rY
  if math.deg(math.abs(dp))>6 then rP,rY=cp,cy return end
  if math.deg(math.abs(dp))<0.01 then return end
  rb(cp-dp*(CFG.recoilPull or 0.98),cy-dy*(CFG.recoilPull or 0.98))
end

local fCam=false; local fPos=nil; local origType=nil

local snap={res={},items={},bases={},veh={}}
local wPool={}
local function wSet(k) local s=wPool[k] if s then return s end s={box=Instance.new("Frame",gui),nm=Instance.new("TextLabel",gui)} s.box.BackgroundTransparency=1 s.box.BorderSizePixel=2 s.box.Visible=false Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4) s.nm.BackgroundTransparency=1 s.nm.Font=Enum.Font.GothamBold s.nm.TextSize=11 s.nm.Size=UDim2.new(0,200,0,14) s.nm.TextXAlignment=Enum.TextXAlignment.Center s.nm.Visible=false wPool[k]=s return s end
local function wHide(s) s.box.Visible=false s.nm.Visible=false end
local function wDraw(s,sp,col,txt,sz) local w=sz or 20 s.box.Visible=true s.box.Position=UDim2.new(0,sp.X-w/2,0,sp.Y-w/2) s.box.Size=UDim2.new(0,w,0,w) s.box.BorderColor3=col s.nm.Visible=true s.nm.Text=txt s.nm.TextColor3=col s.nm.Position=UDim2.new(0,sp.X-100,0,sp.Y-w/2-14) end
local function fastPos(inst) if inst:IsA("BasePart") then return inst.Position end local ok,p=pcall(function() return inst:GetPivot().Position end) if ok then return p end end

local scanning=false
local function runScan()
  if scanning then return end
  scanning=true
  local camPos=Cam.CFrame.Position
  local r,it,b,v={},{},{},{}
  local stack={} for _,c in ipairs(WS:GetChildren()) do stack[#stack+1]=c end
  local i=0
  while #stack>0 do
    local inst=table.remove(stack) i=i+1
    local nm=string.lower(inst.Name)
    if CFG.resEsp and (nm:find("stone") or nm:find("metal") or nm:find("sulfur") or nm:find("wood") or nm:find("hemp")) then
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=(CFG.resDist or 400) then r[#r+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.itemEsp and inst:IsA("Model") and inst:FindFirstChildOfClass("Tool") then
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=400 then it[#it+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.baseEsp and (nm:find("door") or nm:find("furnace") or nm:find("chest") or nm:find("box") or nm:find("turret") or nm:find("trap") or nm:find("cupboard")) then
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=(CFG.baseDist or 400) then b[#b+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.vehEsp and (nm:find("atv") or nm:find("minicopter") or nm:find("boat")) then
      local p=fastPos(inst) if p then v[#v+1]={i=inst,p=p,d=(p-camPos).Magnitude,n=inst.Name} end
    end
    for _,ch in ipairs(inst:GetChildren()) do stack[#stack+1]=ch end
    if i%150==0 then task.wait() end
  end
  snap={res=r,items=it,bases=b,veh=v}
  scanning=false
end

local function tickAll()
  Lighting.Brightness = CFG.fullbright and 2 or 1
  Lighting.FogEnd = CFG.noFog and 1e6 or 100000
  Lighting.GlobalShadows = not CFG.noShadow
  if Cam then Cam.FieldOfView = CFG.fov or 90 end

  local camPos=Cam.CFrame.Position
  if CFG.espPlayers then
    local seen={}
    for _,plr in ipairs(Players:GetPlayers()) do
      if plr~=LP then
        local c,h,u=getCh(plr)
        if c then local d=(h.Position-camPos).Magnitude
          if d<=(CFG.playerMaxDist or 800) then
            local tl,br=bboxCF(h.CFrame,Vector3.new(2,5,1))
            if tl then seen[plr]=true local col=(CFG.teamCheck and sameT(LP,plr)) and COL.teammate or COL.enemy drawEsp(setFor(plr),tl,br,col,plr.Name,d,math.clamp(u.Health/u.MaxHealth,0,1)) setChams(plr,c) end
          end
        end
      end
    end
    for k,s in pairs(espCache) do if typeof(k)=="Instance" and k:IsA("Player") and not seen[k] then hideEsp(s) local h=cham[k] if h and h.Parent then h:Destroy() end cham[k]=nil end end
  end

  if (CFG.aimOn or CFG.aimLock) and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    local t = getTarget(not CFG.wallCheck)
    if t then
      local cp=Cam.CFrame.Position; local cur=Cam.CFrame.LookVector; local tgt=(t.pos-cp).Unit
      local pull=CFG.aimLock and 1.0 or math.clamp(CFG.aimSmooth or 0.35,0.02,1)
      local nl=cur:Lerp(tgt,pull).Unit
      rb(math.asin(math.clamp(nl.Y,-1,1)),math.atan2(-nl.X,-nl.Z))
    end
  end
  recoilTick()

  if CFG.triggerbot and UIS:IsKeyDown(Enum.KeyCode.X) then
    local t = getTarget(true)
    if t and w2s(t.pos) then
      pcall(function()
        local vim=game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2, 0, true, game, 1)
        task.wait((CFG.triggerDelay or 50)/1000)
        vim:SendMouseButtonEvent(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2, 0, false, game, 1)
      end)
    end
  end

  if CFG.resEsp or CFG.itemEsp or CFG.baseEsp or CFG.vehEsp then
    if tick() - (HUB.lastWScan or 0) >= 4 then HUB.lastWScan = tick() task.spawn(function() pcall(runScan) end) end
    local live={}
    for _,cat in pairs(snap) do
      for _,e in ipairs(cat) do
        if e.i.Parent then
          local sp=w2s(e.p)
          if sp then live[e.i]=true wDraw(wSet(e.i),sp,COL.accent,e.n) end
        end
      end
    end
    for k,s in pairs(wPool) do if not live[k] then wHide(s) end end
  else
    for _,s in pairs(wPool) do wHide(s) end
  end

  if CFG.freeCam and not fCam then fCam=true; fPos=Cam.CFrame.Position; origType=Cam.CameraType
  elseif not CFG.freeCam and fCam then fCam=false; Cam.CameraType=origType end
  if fCam then
    local rot=Cam.CFrame.Rotation; local pos=fPos; local m=Vector3.new(0,0,0)
    if UIS:IsKeyDown(Enum.KeyCode.W) then m=m+rot.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then m=m-rot.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then m=m-rot.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then m=m+rot.RightVector end
    if m.Magnitude>0 then pos=pos+m.Unit*(CFG.freeCamSpeed or 20)*0.1 end
    fPos=pos; Cam.CFrame=CFrame.new(pos, pos+rot.LookVector)
  end
end

CONNS[#CONNS+1]=UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end
  if inp.UserInputType==Enum.UserInputType.MouseButton1 then lastShot=tick() if CFG.noRecoil then local p,y=py() rP,rY=p,y end end
end)

local BIND="rainhub_final_"..tostring(math.random(100000,999999))
RS:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value+1, tickAll)
CONNS[#CONNS+1]={Disconnect=function() pcall(function() RS:UnbindFromRenderStep(BIND) end) end}

_G.__RAINHUB=function()
  for _,c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
  if fCam then Cam.CameraType=origType end
  for k,s in pairs(espCache) do hideEsp(s) end
  for _,s in pairs(wPool) do wHide(s) end
  pcall(function() gui:Destroy() end)
  _G.__RAINHUB_CORE=nil
end
print("[rainhub v2] FULLY LOADED — all features active")