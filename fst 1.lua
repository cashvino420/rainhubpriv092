--[[rainhub v2 — SCRIPT 1 · Core + Combat + Player ESP (v1 features preserved)]]
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

if _G.__RAINHUB then pcall(_G.__RAINHUB) end
local CONNS={}
local HUB={CFG={},tickers={},pool={},tabs={}}
_G.__RAINHUB=HUB
_G.__RAINHUB_CORE=HUB

local CFG=HUB.CFG
CFG.aimOn=false; CFG.aimLock=false; CFG.wallLock=false; CFG.aimFOV=250; CFG.aimStrength=85; CFG.aimSmooth=0.35; CFG.aimBone="Head"
CFG.lead=true; CFG.drop=true; CFG.bulletSpeed=700; CFG.dropMul=1; CFG.teamCheck=false
CFG.espPlayers=true; CFG.box=true; CFG.names=true; CFG.distlbl=true; CFG.hpBar=true; CFG.chams=false
CFG.playerMaxDist=800; CFG.fov=90
CFG.noRecoil=false; CFG.recoilPull=0.98; CFG.recoilAnchor=260; CFG.panicKey="Delete"

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

local tabs=HUB.tabs
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
makeTab("Combat", 60); makeTab("Visuals", 95); makeTab("Player", 130); makeTab("World", 165); makeTab("Misc", 200)

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
local function slider(parent, label, key, mn, mx, dec)
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
  CONNS[#CONNS+1]=UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
      local p=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
      CFG[key]=mn+p*(mx-mn); paint()
    end
  end)
  CONNS[#CONNS+1]=UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
  paint()
end
local function dropdown(parent, label, key, opts)
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
HUB.addSection=section; HUB.addToggle=toggle; HUB.addSlider=slider; HUB.addDropdown=dropdown

local combat=tabs["Combat"].page
section(combat, "AIMBOT")
toggle(combat, "Aim Assist (RMB)", "aimOn")
toggle(combat, "Aim Lock (Snap)", "aimLock")
toggle(combat, "Wall Check", "wallCheck")
dropdown(combat, "Aim Bone", "aimBone", {"Head","UpperTorso","HumanoidRootPart"})
toggle(combat, "Lead Moving", "lead")
toggle(combat, "Bullet Drop", "drop")
toggle(combat, "Team Check", "teamCheck")
slider(combat, "Aim FOV", "aimFOV", 50, 400)
slider(combat, "Aim Strength", "aimStrength", 10, 100)
slider(combat, "Bullet Speed", "bulletSpeed", 200, 2000)
slider(combat, "Drop Multiplier", "dropMul", 0.2, 3.0, "%.2f")
slider(combat, "Aim Smooth", "aimSmooth", 0.02, 1.0, "%.2f")
section(combat, "MISC")
toggle(combat, "No Recoil", "noRecoil")
slider(combat, "Recoil Pull", "recoilPull", 0.3, 1.0, "%.2f")
slider(combat, "Recoil Anchor", "recoilAnchor", 50, 500)

local player=tabs["Player"].page
section(player, "PLAYER ESP")
toggle(player, "Players", "espPlayers")
toggle(player, "Boxes", "box")
toggle(player, "Names", "names")
toggle(player, "Distance", "distlbl")
toggle(player, "Health Bar", "hpBar")
toggle(player, "Chams", "chams")
slider(player, "Player Dist", "playerMaxDist", 100, 2000)

local vis=tabs["Visuals"].page
section(vis, "VISUAL")
slider(vis, "FOV", "fov", 50, 120)

tabs["Combat"].btn.BackgroundTransparency=0.8; combat.Visible=true

local espCache={}
local function setFor(k)
  local s=espCache[k]; if s then return s end
  s={box=Instance.new("Frame",gui),nm=Instance.new("TextLabel",gui),ds=Instance.new("TextLabel",gui),hp=Instance.new("Frame",gui),hpB=Instance.new("Frame",gui)}
  s.box.BackgroundTransparency=1; s.box.BorderSizePixel=2; s.box.Visible=false
  Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4)
  s.nm.BackgroundTransparency=1; s.nm.Font=Enum.Font.GothamBold; s.nm.TextSize=13
  s.nm.Size=UDim2.new(0,200,0,14); s.nm.TextXAlignment=Enum.TextXAlignment.Center; s.nm.Visible=false
  s.ds.BackgroundTransparency=1; s.ds.TextColor3=Color3.fromRGB(220,220,220)
  s.ds.Font=Enum.Font.Gotham; s.ds.TextSize=11; s.ds.Size=UDim2.new(0,200,0,12); s.ds.TextXAlignment=Enum.TextXAlignment.Center; s.ds.Visible=false
  s.hp.BackgroundColor3=Color3.fromRGB(0,255,140); s.hp.BorderSizePixel=0; s.hp.Visible=false
  s.hpB.BackgroundColor3=Color3.fromRGB(30,30,30); s.hpB.BorderSizePixel=0; s.hpB.Visible=false
  espCache[k]=s; return s
end
local function hideEsp(s) s.box.Visible=false; s.nm.Visible=false; s.ds.Visible=false; s.hp.Visible=false; s.hpB.Visible=false end
HUB.setFor=setFor; HUB.hideEsp=hideEsp; HUB.espCache=espCache

local cham={}
local function setChams(plr,ch)
  if not (CFG.chams and CFG.espPlayers) then local h=cham[plr]; if h and h.Parent then h:Destroy() end cham[plr]=nil return end
  local h=cham[plr]
  if not h or h.Parent~=ch then local o=cham[plr]; if o and o.Parent then o:Destroy() end h=Instance.new("Highlight"); h.Adornee=ch; h.Parent=ch; cham[plr]=h end
  h.FillColor=Color3.fromRGB(255,20,20); h.OutlineColor=Color3.fromRGB(255,0,0)
  h.FillTransparency=0.35; h.OutlineTransparency=0; h.DepthMode=Enum.HighlightDepthMode.Occluded
end
HUB.cham=cham; HUB.setChams=setChams

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
local function drawEsp(s,tl,br,col,name,d,hpFrac)
  local w,h=br.X-tl.X,br.Y-tl.Y
  if CFG.box then s.box.Visible=true; s.box.Position=UDim2.new(0,tl.X,0,tl.Y); s.box.Size=UDim2.new(0,w,0,h); s.box.BorderColor3=col else s.box.Visible=false end
  if CFG.names then s.nm.Visible=true; s.nm.Text=name; s.nm.TextColor3=col; s.nm.Position=UDim2.new(0,tl.X+w/2-100,0,tl.Y-14) else s.nm.Visible=false end
  if CFG.distlbl then s.ds.Visible=true; s.ds.Text="["..math.floor(d).."m]"; s.ds.Position=UDim2.new(0,tl.X+w/2-100,0,br.Y+1) else s.ds.Visible=false end
  if CFG.hpBar and hpFrac then s.hpB.Visible=true; s.hpB.Position=UDim2.new(0,tl.X-4,0,tl.Y); s.hpB.Size=UDim2.new(0,2,0,h); s.hp.Visible=true; s.hp.Position=UDim2.new(0,tl.X-4,0,tl.Y+h-h*hpFrac); s.hp.Size=UDim2.new(0,2,0,h*hpFrac) else s.hp.Visible=false; s.hpB.Visible=false end
end
HUB.w2s=w2s; HUB.getCh=getCh; HUB.sameT=sameT; HUB.bboxCF=bboxCF; HUB.drawEsp=drawEsp

local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.IgnoreWater=true
local function visible(c,part)
  rp.FilterDescendantsInstances={c,LP.Character,Cam}
  local hit=WS:Raycast(Cam.CFrame.Position,part.Position-Cam.CFrame.Position,rp)
  if not hit then return true end
  return hit.Instance:IsDescendantOf(c)
end
local function boneOf(c)
  return c:FindFirstChild(CFG.aimBone) or c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart")
end
local function aimPos(p)
  local cp=Cam.CFrame.Position; local pos=p.Position; local d=(pos-cp).Magnitude
  local v=Vector3.new(); pcall(function() v=p.AssemblyLinearVelocity end); if not v then v=Vector3.new() end
  local t=d/math.max(CFG.bulletSpeed,1)
  if CFG.lead and v.Magnitude>2 then local dir=(pos-cp).Unit; local clv=-v:Dot(dir); local den=CFG.bulletSpeed+clv; if den>1e-3 then local t2=d/den if t2>0 and t2<5 then t=t2 end end end
  local dy=0; if CFG.drop then dy=0.5*196.2*t*t*CFG.dropMul end
  local lv=Vector3.new(); if CFG.lead and v.Magnitude>2 then lv=v*t end
  return pos+Vector3.new(0,dy,0)+lv
end
local function bestTarget(requireVis)
  local c2=Vector2.new(vp.X/2,vp.Y/2); local best=nil
  for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=LP and not (CFG.teamCheck and sameT(LP,plr)) then
      local c=getCh(plr)
      if c then local b=boneOf(c)
        if b and (not requireVis or not CFG.wallCheck or visible(c,b)) then
          local aim=aimPos(b); local sp=w2s(aim)
          if sp then local d=(sp-c2).Magnitude; if d<=CFG.aimFOV and (not best or d<best.d) then best={pos=aim,d=d} end end
        end
      end
    end
  end
  return best
end

local rP,rY=nil,nil; local lastShot=0
local function py() local l=Cam.CFrame.LookVector return math.asin(math.clamp(l.Y,-1,1)),math.atan2(-l.X,-l.Z) end
local function rb(p,y)
  local cp,sp=math.cos(p),math.sin(p); local cy,sy=math.cos(y),math.sin(y)
  local dir=Vector3.new(-sy*cp,sp,-cy*cp); local pos=Cam.CFrame.Position
  Cam.CFrame=CFrame.lookAt(pos,pos+dir)
end
CONNS[#CONNS+1]=UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.UserInputType==Enum.UserInputType.MouseButton1 then
    lastShot=tick(); if CFG.noRecoil then local p,y=py() rP,rY=p,y end
  end
  if inp.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end
  if inp.KeyCode==Enum.KeyCode[CFG.panicKey] then
    for k,v in pairs(CFG) do if type(v)=="boolean" then CFG[k]=false end end
    gui.Enabled=false
  end
end)
local function recoilTick()
  if not CFG.noRecoil then rP,rY=nil,nil return end
  local dt=(tick()-lastShot)*1000
  if dt>=CFG.recoilAnchor or rP==nil then local p,y=py() rP,rY=p,y return end
  local cp,cy=py(); local dp=cp-rP; local dy=cy-rY
  if math.deg(math.abs(dp))>6 then rP,rY=cp,cy return end
  if math.deg(math.abs(dp))<0.01 and math.deg(math.abs(dy))<0.01 then return end
  rb(cp-dp*CFG.recoilPull,cy-dy*CFG.recoilPull)
end
local function aimTick()
  if not (CFG.aimOn or CFG.aimLock) then return end
  if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
  local t=bestTarget(false); if not t then return end
  local cp=Cam.CFrame.Position; local cur=Cam.CFrame.LookVector; local tgt=(t.pos-cp).Unit
  local pull=CFG.aimLock and 1.0 or math.clamp(CFG.aimSmooth,0.02,1)
  local nl=cur:Lerp(tgt,pull).Unit
  rb(math.asin(math.clamp(nl.Y,-1,1)),math.atan2(-nl.X,-nl.Z))
end
local function espTick()
  vp=Vector2.new(Cam.ViewportSize.X,Cam.ViewportSize.Y); local camPos=Cam.CFrame.Position
  if CFG.espPlayers then
    local seen={}
    for _,plr in ipairs(Players:GetPlayers()) do
      if plr~=LP then
        local c,h,u=getCh(plr)
        if c then local d=(h.Position-camPos).Magnitude
          if d<=CFG.playerMaxDist then
            local tl,br=bboxCF(h.CFrame,Vector3.new(2,5,1))
            if tl then seen[plr]=true local col=(CFG.teamCheck and sameT(LP,plr)) and COL.teammate or COL.enemy drawEsp(setFor(plr),tl,br,col,plr.Name,d,math.clamp(u.Health/u.MaxHealth,0,1)) setChams(plr,c) end
          end
        end
      end
    end
    for k,s in pairs(espCache) do if typeof(k)=="Instance" and k:IsA("Player") and not seen[k] then hideEsp(s) local h=cham[k] if h and h.Parent then h:Destroy() end cham[k]=nil end end
  else
    for k,s in pairs(espCache) do if typeof(k)=="Instance" and k:IsA("Player") then hideEsp(s) end end
    for k,h in pairs(cham) do if h and h.Parent then h:Destroy() end end
    cham={}
  end
  if Cam then Cam.FieldOfView=CFG.fov end
end
local function tickAll()
  aimTick(); recoilTick(); espTick()
  for _,fn in ipairs(HUB.tickers) do pcall(fn) end
end
local BIND="rainhub2_"..tostring(math.random(100000,999999))
RS:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value+1, tickAll)
CONNS[#CONNS+1]={Disconnect=function() pcall(function() RS:UnbindFromRenderStep(BIND) end) end}

_G.__RAINHUB=function()
  for _,c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
  for k,s in pairs(espCache) do hideEsp(s) end
  for k,h in pairs(cham) do if h and h.Parent then h:Destroy() end end
  pcall(function() gui:Destroy() end)
  _G.__RAINHUB_CORE=nil
end
print("[rainhub v2] script 1 online — Core + Combat + Player ESP")