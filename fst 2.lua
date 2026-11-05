--[[rainhub v2 — SCRIPT 2 · World ESP + Visuals]]
local HUB=_G.__RAINHUB_CORE
if not HUB then warn("[rainhub] core not loaded"); return end
local Players=game:GetService("Players")
local WS=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Cam=WS.CurrentCamera
local LP=Players.LocalPlayer
local CFG=HUB.CFG
local COL=HUB.COL
local gui=HUB.gui
local tabs=HUB.tabs

CFG.resEsp=false; CFG.resStone=true; CFG.resMetal=true; CFG.resSulfur=true; CFG.resWood=true; CFG.resHemp=true; CFG.resDist=400
CFG.itemEsp=false; CFG.itemDist=200
CFG.baseEsp=false; CFG.baseDist=400
CFG.sleepEsp=false; CFG.vehEsp=false
CFG.fullbright=false; CFG.noFog=false; CFG.noGrass=false; CFG.noShadow=false

local section=HUB.addSection
local toggle=HUB.addToggle
local slider=HUB.addSlider

local world=tabs["World"].page
section(world, "RESOURCES")
toggle(world, "Resource ESP", "resEsp")
toggle(world, "Stone", "resStone")
toggle(world, "Metal", "resMetal")
toggle(world, "Sulfur", "resSulfur")
toggle(world, "Wood", "resWood")
toggle(world, "Hemp", "resHemp")
slider(world, "Resource Dist", "resDist", 50, 1000)

section(world, "ITEMS")
toggle(world, "Item ESP (Dropped)", "itemEsp")
slider(world, "Item Dist", "itemDist", 50, 500)

section(world, "BASES & VEHICLES")
toggle(world, "Base ESP (Doors/Chests/Furnaces)", "baseEsp")
slider(world, "Base Dist", "baseDist", 100, 1000)
toggle(world, "Sleeping Players", "sleepEsp")
toggle(world, "Vehicle ESP", "vehEsp")

local vis=tabs["Visuals"].page
section(vis, "VISUAL MODS")
toggle(vis, "Fullbright", "fullbright")
toggle(vis, "No Fog", "noFog")
toggle(vis, "No Grass", "noGrass")
toggle(vis, "No Shadows", "noShadow")

local snap={res={},items={},bases={},sleep={},veh={}}
local wPool={}
local function wSet(k)
  local s=wPool[k]
  if s then return s end
  s={box=Instance.new("Frame",gui),nm=Instance.new("TextLabel",gui)}
  s.box.BackgroundTransparency=1; s.box.BorderSizePixel=2; s.box.Visible=false
  Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4)
  s.nm.BackgroundTransparency=1; s.nm.Font=Enum.Font.GothamBold; s.nm.TextSize=11
  s.nm.Size=UDim2.new(0,200,0,14); s.nm.TextXAlignment=Enum.TextXAlignment.Center; s.nm.Visible=false
  wPool[k]=s
  return s
end
local function wHide(s) s.box.Visible=false; s.nm.Visible=false end
local function wDraw(s,sp,col,txt,sz)
  local w=sz or 20
  s.box.Visible=true
  s.box.Position=UDim2.new(0,sp.X-w/2,0,sp.Y-w/2)
  s.box.Size=UDim2.new(0,w,0,w)
  s.box.BorderColor3=col
  s.nm.Visible=true; s.nm.Text=txt; s.nm.TextColor3=col
  s.nm.Position=UDim2.new(0,sp.X-100,0,sp.Y-w/2-14)
end

local function hit(n,list) for _,w in ipairs(list) do if n:find(w,1,true) then return true end end end
local function fastPos(inst)
  if inst:IsA("BasePart") then return inst.Position end
  local ok,p=pcall(function() return inst:GetPivot().Position end)
  if ok then return p end
end

local scanning=false
local RES_WORDS={stone={"stone","stoneore"},metal={"metal","metalore"},sulfur={"sulfur","sulfurore"},wood={"wood","woodpile","tree"},hemp={"hemp","hempbush"}}
local function runScan()
  if scanning then return end
  scanning=true
  local camPos=Cam.CFrame.Position
  local r,it,b,sl,v={},{},{},{},{}
  local stack={}
  for _,c in ipairs(WS:GetChildren()) do stack[#stack+1]=c end
  local i=0
  while #stack>0 do
    local inst=table.remove(stack)
    i=i+1
    local nm=string.lower(inst.Name)
    if CFG.resEsp then
      local resType=nil
      if CFG.resStone and hit(nm,RES_WORDS.stone) then resType="stone"
      elseif CFG.resMetal and hit(nm,RES_WORDS.metal) then resType="metal"
      elseif CFG.resSulfur and hit(nm,RES_WORDS.sulfur) then resType="sulfur"
      elseif CFG.resWood and hit(nm,RES_WORDS.wood) then resType="wood"
      elseif CFG.resHemp and hit(nm,RES_WORDS.hemp) then resType="hemp"
      end
      if resType then
        local p=fastPos(inst)
        if p then local d=(p-camPos).Magnitude if d<=CFG.resDist then r[#r+1]={i=inst,p=p,d=d,n=inst.Name} end end
      end
    end
    if CFG.itemEsp and inst:IsA("Model") and inst:FindFirstChildOfClass("Tool") then
      local p=fastPos(inst)
      if p then local d=(p-camPos).Magnitude if d<=CFG.itemDist then it[#it+1]={i=inst,p=p,d=d,n=inst.Name} end end
    end
    if CFG.baseEsp then
      local isB = nm:find("door") or nm:find("furnace") or nm:find("chest") or nm:find("box") or nm:find("turret") or nm:find("trap") or nm:find("locker") or nm:find("cupboard")
      if isB and (inst:IsA("Model") or inst:IsA("BasePart")) then
        local p=fastPos(inst)
        if p then local d=(p-camPos).Magnitude if d<=CFG.baseDist then b[#b+1]={i=inst,p=p,d=d,n=inst.Name} end end
      end
    end
    if CFG.sleepEsp and inst:IsA("Model") and not Players:GetPlayerFromCharacter(inst) then
      local h=inst:FindFirstChildOfClass("Humanoid")
      if h and h.Health<=0 then
        local p=fastPos(inst)
        if p then sl[#sl+1]={i=inst,p=p,d=(p-camPos).Magnitude,n=inst.Name.." (Sleep)"} end
      end
    end
    if CFG.vehEsp and (nm:find("atv") or nm:find("minicopter") or nm:find("boat") or nm:find("rhib")) then
      local p=fastPos(inst)
      if p then v[#v+1]={i=inst,p=p,d=(p-camPos).Magnitude,n=inst.Name} end
    end
    for _,ch in ipairs(inst:GetChildren()) do stack[#stack+1]=ch end
    if i%150==0 then task.wait() end
  end
  snap={res=r,items=it,bases=b,sleep=sl,veh=v}
  scanning=false
end

HUB.addTicker(function()
  Lighting.FogEnd = CFG.noFog and 1e6 or 100000
  Lighting.Brightness = CFG.fullbright and 2 or 1
  Lighting.GlobalShadows = not CFG.noShadow
  pcall(function() WS.Terrain.Decoration = CFG.noGrass end)

  if tick() - (HUB.lastWScan or 0) >= 4 then
    HUB.lastWScan = tick()
    task.spawn(function() pcall(runScan) end)
  end

  local live={}
  for _,cat in pairs(snap) do
    for _,e in ipairs(cat) do
      if e.i.Parent then
        local sp=HUB.w2s(e.p)
        if sp then
          live[e.i]=true
          local col=COL.accent
          if cat==snap.res then col=Color3.fromRGB(90,200,90)
          elseif cat==snap.items then col=Color3.fromRGB(255,220,120)
          elseif cat==snap.bases then col=Color3.fromRGB(255,90,120)
          elseif cat==snap.sleep then col=Color3.fromRGB(150,150,220)
          elseif cat==snap.veh then col=Color3.fromRGB(255,180,60)
          end
          wDraw(wSet(e.i),sp,col,e.n)
        end
      end
    end
  end
  for k,s in pairs(wPool) do if not live[k] then wHide(s) end end
end)

local oldCleanup=_G.__RAINHUB
_G.__RAINHUB=function()
  for _,s in pairs(wPool) do pcall(function() s.box:Destroy(); s.nm:Destroy() end) end
  if oldCleanup then pcall(oldCleanup) end
end

print("[rainhub v2] script 2 online — World + Visuals")