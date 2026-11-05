--[[rainhub v2 — SCRIPT 2 of 2 · Logic Engine]]
local HUB = _G.RainHub
if not HUB then warn("[rainhub] UI missing — run script 1 first"); return end

local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera
local CFG=HUB.CFG
local COL=HUB.COL

if _G.__RAINHUB_LOGIC then pcall(_G.__RAINHUB_LOGIC) end
local CONNS={}

-- Helpers
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

-- Player ESP
local espCache={}
local function setFor(k)
  local s=espCache[k]; if s then return s end
  s={box=Instance.new("Frame",HUB.gui),nm=Instance.new("TextLabel",HUB.gui),ds=Instance.new("TextLabel",HUB.gui),hp=Instance.new("Frame",HUB.gui),hpB=Instance.new("Frame",HUB.gui)}
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

-- Chams
local cham={}
local function setChams(plr,ch)
  if not (CFG.chams and CFG.espPlayers) then local h=cham[plr]; if h and h.Parent then h:Destroy() end cham[plr]=nil return end
  local h=cham[plr]
  if not h or h.Parent~=ch then local o=cham[plr]; if o and o.Parent then o:Destroy() end h=Instance.new("Highlight"); h.Adornee=ch; h.Parent=ch; cham[plr]=h end
  h.FillColor=Color3.fromRGB(255,20,20); h.OutlineColor=Color3.fromRGB(255,0,0); h.FillTransparency=0.35; h.OutlineTransparency=0; h.DepthMode=Enum.HighlightDepthMode.Occluded
end

-- Aim
local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.IgnoreWater=true
local function visible(c,part)
  rp.FilterDescendantsInstances={c,LP.Character,Cam}
  local hit=WS:Raycast(Cam.CFrame.Position,part.Position-Cam.CFrame.Position,rp)
  if not hit then return true end
  return hit.Instance:IsDescendantOf(c)
end
local function boneOf(c) return c:FindFirstChild(CFG.aimBone or "Head") or c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart") end
local function aimPos(p)
  local cp=Cam.CFrame.Position; local pos=p.Position; local d=(pos-cp).Magnitude
  local v=Vector3.new(); pcall(function() v=p.AssemblyLinearVelocity end); if not v then v=Vector3.new() end
  local t=d/math.max(700,1)
  return pos+v*t
end
local function getTarget(requireVis)
  local c2=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2); local best=nil
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

-- Freecam
local fCam=false; local fPos=nil; local origType=nil

-- World Scan
local snap={res={},items={},bases={},veh={}}
local wPool={}
local function wSet(k) local s=wPool[k] if s then return s end s={box=Instance.new("Frame",HUB.gui),nm=Instance.new("TextLabel",HUB.gui)} s.box.BackgroundTransparency=1 s.box.BorderSizePixel=2 s.box.Visible=false Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4) s.nm.BackgroundTransparency=1 s.nm.Font=Enum.Font.GothamBold s.nm.TextSize=11 s.nm.Size=UDim2.new(0,200,0,14) s.nm.TextXAlignment=Enum.TextXAlignment.Center s.nm.Visible=false wPool[k]=s return s end
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
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=CFG.resDist then r[#r+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.itemEsp and inst:IsA("Model") and inst:FindFirstChildOfClass("Tool") then
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=400 then it[#it+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.baseEsp and (nm:find("door") or nm:find("furnace") or nm:find("chest") or nm:find("box") or nm:find("turret") or nm:find("trap") or nm:find("cupboard")) then
      local p=fastPos(inst) if p then local d=(p-camPos).Magnitude if d<=CFG.baseDist then b[#b+1]={i=inst,p=p,d=d,n=inst.Name} end end
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

-- Main Render Loop
local function tickAll()
  -- Visuals
  Lighting.Brightness = CFG.fullbright and 2 or 1
  Lighting.FogEnd = CFG.noFog and 1e6 or 100000
  Lighting.GlobalShadows = not CFG.noShadow
  if Cam then Cam.FieldOfView = CFG.fov or 90 end

  -- Player ESP
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

  -- Aim
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

  -- Triggerbot
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

  -- World ESP
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

  -- Free Cam
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

-- Input Hooks
CONNS[#CONNS+1]=UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.KeyCode==Enum.KeyCode.RightShift then HUB.gui.Enabled=not HUB.gui.Enabled end
  if inp.UserInputType==Enum.UserInputType.MouseButton1 then lastShot=tick() if CFG.noRecoil then local p,y=py() rP,rY=p,y end end
end)

-- Bind to Render
local BIND="rainhub_logic_"..tostring(math.random(100000,999999))
RS:BindToRenderStep(BIND, Enum.RenderPriority.Camera.Value+1, tickAll)
CONNS[#CONNS+1]={Disconnect=function() pcall(function() RS:UnbindFromRenderStep(BIND) end) end}

_G.__RAINHUB_LOGIC = function()
  for _,c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
  if fCam then Cam.CameraType=origType end
  for k,s in pairs(espCache) do hideEsp(s) end
  for _,s in pairs(wPool) do wHide(s) end
end

print("[rainhub] Logic script online")