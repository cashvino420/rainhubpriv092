--[[rainhub v4 — COMPACT FULL SUITE]]
local P=game:GetService("Players")
local R=game:GetService("RunService")
local W=game:GetService("Workspace")
local U=game:GetService("UserInputService")
local L=game:GetService("Lighting")
local LP=P.LocalPlayer
local C=W.CurrentCamera
if _G.RH then pcall(_G.RH) end
local CN={}
local F={aim=false,aimLock=false,wall=false,bone="Head",team=false,fov=250,smooth=0.35,esp=true,box=true,nm=true,ds=true,hp=true,cham=false,pDist=800,fb=false,nofog=false,noshadow=false,fcam=false,fSpd=20,recoil=false,trig=false,trigKey="X",trigDel=50,spec="None",bp=false,loot=false,res=false,rStone=true,rMetal=true,rSulfur=true,rWood=true,rHemp=true,rDist=400,item=false,base=false,veh=false,sleep=false,visFov=90,resAuto=false,showLoot=false}
local TC={bg=Color3.fromRGB(10,15,30),pn=Color3.fromRGB(15,20,40),bd=Color3.fromRGB(0,120,255),tx=Color3.fromRGB(200,220,255),ac=Color3.fromRGB(0,150,255),of=Color3.fromRGB(30,40,60),en=Color3.fromRGB(255,60,60),tm=Color3.fromRGB(0,255,140)}
local G=Instance.new("ScreenGui"); G.Name="rh_v4"; G.ResetOnSpawn=false; G.IgnoreGuiInset=true
do local ok=pcall(function() G.Parent=game:GetService("CoreGui") end) if not ok or not G.Parent then G.Parent=LP:WaitForChild("PlayerGui") end end

local M=Instance.new("Frame",G); M.Size=UDim2.new(0,600,0,400); M.Position=UDim2.new(0.5,-300,0.5,-200); M.BackgroundColor3=TC.bg; M.BorderSizePixel=0; M.Active=true; M.Draggable=true
Instance.new("UICorner",M).CornerRadius=UDim.new(0,10); local MS=Instance.new("UIStroke",M); MS.Color=TC.bd; MS.Thickness=1.5
local SD=Instance.new("Frame",M); SD.Size=UDim2.new(0,120,1,0); SD.BackgroundColor3=TC.pn; SD.BorderSizePixel=0
Instance.new("UICorner",SD).CornerRadius=UDim.new(0,10); local SM=Instance.new("Frame",SD); SM.Size=UDim2.new(0,10,1,0); SM.Position=UDim2.new(1,-10,0,0); SM.BackgroundColor3=TC.pn; SM.BorderSizePixel=0
local TT=Instance.new("TextLabel",SD); TT.Size=UDim2.new(1,0,0,50); TT.BackgroundTransparency=1; TT.Text="RAINHUB v4"; TT.TextColor3=TC.ac; TT.Font=Enum.Font.GothamBold; TT.TextSize=16
local CB=Instance.new("TextButton",M); CB.Size=UDim2.new(0,22,0,22); CB.Position=UDim2.new(1,-28,0,6); CB.BackgroundColor3=Color3.fromRGB(160,40,200); CB.Text="X"; CB.TextColor3=Color3.fromRGB(255,255,255); CB.Font=Enum.Font.GothamBold; CB.TextSize=14; CB.BorderSizePixel=0
Instance.new("UICorner",CB).CornerRadius=UDim.new(1,0); CB.MouseButton1Click:Connect(function() G.Enabled=false end)
local CT=Instance.new("Frame",M); CT.Size=UDim2.new(1,-130,1,-20); CT.Position=UDim2.new(0,125,0,10); CT.BackgroundTransparency=1
local TB={}
local function MkTab(n,y)
    local b=Instance.new("TextButton",SD); b.Size=UDim2.new(1,-10,0,30); b.Position=UDim2.new(0,5,0,y); b.BackgroundColor3=TC.of; b.BackgroundTransparency=1; b.Text="   "..n; b.TextColor3=TC.tx; b.Font=Enum.Font.Gotham; b.TextSize=13; b.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local p=Instance.new("ScrollingFrame",CT); p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1; p.BorderSizePixel=0; p.CanvasSize=UDim2.new(0,0,0,0); p.AutomaticCanvasSize=Enum.AutomaticSize.Y; p.ScrollBarThickness=2; p.ScrollBarImageColor3=TC.ac; p.Visible=false
    TB[n]={btn=b,page=p}
    b.MouseButton1Click:Connect(function() for tn,t in pairs(TB) do t.btn.BackgroundTransparency=1; t.page.Visible=false end b.BackgroundTransparency=0.8; p.Visible=true end)
end
MkTab("Combat",60); MkTab("Player",95); MkTab("World",130); MkTab("Visuals",165); MkTab("Misc",200)

local function Sec(tab,txt) local p=TB[tab].page; local l=Instance.new("TextLabel",p); l.Size=UDim2.new(1,-10,0,25); l.BackgroundTransparency=1; l.Text="  "..txt; l.TextColor3=TC.ac; l.Font=Enum.Font.GothamBold; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left end
local function Tgl(tab,lbl,k) local p=TB[tab].page; local b=Instance.new("TextButton",p); b.Size=UDim2.new(1,-10,0,28); b.BackgroundColor3=TC.pn; b.BorderSizePixel=0; b.Text="  "..lbl; b.TextColor3=TC.tx; b.Font=Enum.Font.Gotham; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local function pt() if F[k] then b.BackgroundColor3=TC.ac; b.BackgroundTransparency=0.5 else b.BackgroundColor3=TC.pn; b.BackgroundTransparency=0 end end
    b.MouseButton1Click:Connect(function() F[k]=not F[k]; pt() end) pt()
end
local function Sld(tab,lbl,k,mn,mx,dc) local p=TB[tab].page; local r=Instance.new("Frame",p); r.Size=UDim2.new(1,-10,0,40); r.BackgroundColor3=TC.pn; r.BorderSizePixel=0
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel",r); l.Size=UDim2.new(1,-10,0,16); l.Position=UDim2.new(0,10,0,2); l.BackgroundTransparency=1; l.Text=lbl; l.TextColor3=TC.tx; l.Font=Enum.Font.Gotham; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left
    local t=Instance.new("Frame",r); t.Size=UDim2.new(1,-20,0,6); t.Position=UDim2.new(0,10,0,24); t.BackgroundColor3=TC.of; t.BorderSizePixel=0
    Instance.new("UICorner",t).CornerRadius=UDim.new(1,0)
    local f=Instance.new("Frame",t); f.Size=UDim2.new((F[k]-mn)/(mx-mn),0,1,0); f.BackgroundColor3=TC.ac; f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    local function pt() local pr=(F[k]-mn)/(mx-mn); f.Size=UDim2.new(pr,0,1,0); if dc then l.Text=lbl.." : "..string.format(dc,F[k]) else l.Text=lbl.." : "..math.floor(F[k]) end end
    local d=false
    t.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true end end)
    CN[#CN+1]=U.InputChanged:Connect(function(i) if d and i.UserInputType==Enum.UserInputType.MouseMovement then local pr=math.clamp((i.Position.X-t.AbsolutePosition.X)/t.AbsoluteSize.X,0,1); F[k]=mn+pr*(mx-mn); pt() end end)
    CN[#CN+1]=U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end end)
    pt()
end
local function DD(tab,lbl,k,opts) local p=TB[tab].page; local b=Instance.new("TextButton",p); b.Size=UDim2.new(1,-10,0,28); b.BackgroundColor3=TC.pn; b.BorderSizePixel=0; b.Text="  "..lbl..": "..tostring(F[k]); b.TextColor3=TC.tx; b.Font=Enum.Font.Gotham; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local o=false; local li=nil
    b.MouseButton1Click:Connect(function() if o then if li then li:Destroy() end o=false return end o=true; li=Instance.new("Frame",p); li.Size=UDim2.new(1,-10,0,#opts*22+4); li.BackgroundColor3=TC.bg; li.BorderSizePixel=0
        Instance.new("UICorner",li).CornerRadius=UDim.new(0,6)
        for i,v in ipairs(opts) do local ob=Instance.new("TextButton",li); ob.Size=UDim2.new(1,-4,0,20); ob.Position=UDim2.new(0,2,0,2+(i-1)*22); ob.BackgroundColor3=(F[k]==v) and TC.ac or TC.of; ob.BackgroundTransparency=0.3; ob.BorderSizePixel=0; ob.Text=v; ob.TextColor3=TC.tx; ob.Font=Enum.Font.Gotham; ob.TextSize=11
            Instance.new("UICorner",ob).CornerRadius=UDim.new(0,4)
            ob.MouseButton1Click:Connect(function() F[k]=v; b.Text="  "..lbl..": "..v; if li then li:Destroy() end o=false end)
        end
    end)
end

Sec("Combat","AIMBOT"); Tgl("Combat","Aim Assist (RMB)","aim"); Tgl("Combat","Aim Lock (Snap)","aimLock"); Tgl("Combat","Wall Check","wall"); DD("Combat","Aim Bone","bone",{"Head","UpperTorso","HumanoidRootPart"}); Tgl("Combat","Team Check","team"); Sld("Combat","Aim FOV","fov",50,400); Sld("Combat","Aim Smooth","smooth",0.02,1.0,"%.2f")
Sec("Combat","TRIGGERBOT"); Tgl("Combat","Enable Triggerbot (Hold X)","trig"); Sld("Combat","Trigger Delay (ms)","trigDel",10,200)
Sec("Combat","WEAPON"); Tgl("Combat","No Recoil","recoil")
Sec("Player","PLAYER ESP"); Tgl("Player","Players","esp"); Tgl("Player","Boxes","box"); Tgl("Player","Names","nm"); Tgl("Player","Distance","ds"); Tgl("Player","Health Bar","hp"); Tgl("Player","Chams","cham"); Sld("Player","Player Dist","pDist",100,2000)
Sec("World","RESOURCES"); Tgl("World","Resource ESP","res"); Tgl("World","Stone","rStone"); Tgl("World","Metal","rMetal"); Tgl("World","Sulfur","rSulfur"); Tgl("World","Wood","rWood"); Tgl("World","Hemp","rHemp"); Sld("World","Resource Dist","rDist",50,1000)
Sec("World","ITEMS"); Tgl("World","Item ESP","item"); Tgl("World","Base ESP","base"); Tgl("World","Vehicles","veh"); Tgl("World","Sleeping Players","sleep")
Sec("Visuals","VISUAL MODS"); Tgl("Visuals","Fullbright","fb"); Tgl("Visuals","No Fog","nofog"); Tgl("Visuals","No Shadows","noshadow"); Sld("Visuals","FOV","visFov",50,120)
Sec("Visuals","CAMERA"); Tgl("Visuals","Free Camera","fcam"); Sld("Visuals","Free Cam Speed","fSpd",10,100)
Sec("Misc","UTILITY"); Tgl("Misc","Container Loot (Press E)","loot")
TB["Combat"].btn.BackgroundTransparency=0.8; TB["Combat"].page.Visible=true

local vp=Vector2.new(C.ViewportSize.X,C.ViewportSize.Y)
local function w2s(p) local v=C:WorldToViewportPoint(p) if v.Z>0 then return Vector2.new(v.X,v.Y) end end
local function getC(p) local c=p.Character if not c then return end local h=c:FindFirstChild("HumanoidRootPart") local u=c:FindFirstChildOfClass("Humanoid") if not h or not u or u.Health<=0 then return end return c,h,u end
local function sameT(a,b) return a.Team and b.Team and a.Team==b.Team end
local function bb(cf,sz) local h=sz/2; local a,b,x,y=math.huge,math.huge,-math.huge,-math.huge for i=-1,1,2 do for j=-1,1,2 do for k=-1,1,2 do local w=(cf*CFrame.new(h.X*i,h.Y*j,h.Z*k)).Position local v=C:WorldToViewportPoint(w) if v.Z>0 then if v.X<a then a=v.X end if v.Y<b then b=v.Y end if v.X>x then x=v.X end if v.Y>y then y=v.Y end end end end end if a==math.huge then return end return Vector2.new(a,b),Vector2.new(x,y) end

local EC={}
local function sF(k) local s=EC[k] if s then return s end s={box=Instance.new("Frame",G),nm=Instance.new("TextLabel",G),ds=Instance.new("TextLabel",G),hp=Instance.new("Frame",G),hpB=Instance.new("Frame",G)} s.box.BackgroundTransparency=1 s.box.BorderSizePixel=2 s.box.Visible=false Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4) s.nm.BackgroundTransparency=1 s.nm.Font=Enum.Font.GothamBold s.nm.TextSize=13 s.nm.Size=UDim2.new(0,200,0,14) s.nm.TextXAlignment=Enum.TextXAlignment.Center s.nm.Visible=false s.ds.BackgroundTransparency=1 s.ds.TextColor3=Color3.fromRGB(220,220,220) s.ds.Font=Enum.Font.Gotham s.ds.TextSize=11 s.ds.Size=UDim2.new(0,200,0,12) s.ds.TextXAlignment=Enum.TextXAlignment.Center s.ds.Visible=false s.hp.BackgroundColor3=Color3.fromRGB(0,255,140) s.hp.BorderSizePixel=0 s.hp.Visible=false s.hpB.BackgroundColor3=Color3.fromRGB(30,30,30) s.hpB.BorderSizePixel=0 s.hpB.Visible=false EC[k]=s return s end
local function hE(s) s.box.Visible=false s.nm.Visible=false s.ds.Visible=false s.hp.Visible=false s.hpB.Visible=false end
local function dE(s,tl,br,col,name,d,hpf) local w,h=br.X-tl.X,br.Y-tl.Y if F.box then s.box.Visible=true s.box.Position=UDim2.new(0,tl.X,0,tl.Y) s.box.Size=UDim2.new(0,w,0,h) s.box.BorderColor3=col else s.box.Visible=false end if F.nm then s.nm.Visible=true s.nm.Text=name s.nm.TextColor3=col s.nm.Position=UDim2.new(0,tl.X+w/2-100,0,tl.Y-14) else s.nm.Visible=false end if F.ds then s.ds.Visible=true s.ds.Text="["..math.floor(d).."m]" s.ds.Position=UDim2.new(0,tl.X+w/2-100,0,br.Y+1) else s.ds.Visible=false end if F.hp and hpf then s.hpB.Visible=true s.hpB.Position=UDim2.new(0,tl.X-4,0,tl.Y) s.hpB.Size=UDim2.new(0,2,0,h) s.hp.Visible=true s.hp.Position=UDim2.new(0,tl.X-4,0,tl.Y+h-h*hpf) s.hp.Size=UDim2.new(0,2,0,h*hpf) else s.hp.Visible=false s.hpB.Visible=false end end

local CH={}
local function sC(p,c) if not (F.cham and F.esp) then local h=CH[p] if h and h.Parent then h:Destroy() end CH[p]=nil return end local h=CH[p] if not h or h.Parent~=c then local o=CH[p] if o and o.Parent then o:Destroy() end h=Instance.new("Highlight") h.Adornee=c h.Parent=c CH[p]=h end h.FillColor=Color3.fromRGB(255,20,20) h.OutlineColor=Color3.fromRGB(255,0,0) h.FillTransparency=0.35 h.OutlineTransparency=0 h.DepthMode=Enum.HighlightDepthMode.Occluded end

local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.IgnoreWater=true
local function vis(c,p) rp.FilterDescendantsInstances={c,LP.Character,C} local h=W:Raycast(C.CFrame.Position,p.Position-C.CFrame.Position,rp) if not h then return true end return h.Instance:IsDescendantOf(c) end
local function bn(c) return c:FindFirstChild(F.bone) or c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("HumanoidRootPart") end
local function aP(p) local cp=C.CFrame.Position local ps=p.Position local d=(ps-cp).Magnitude local v=Vector3.new() pcall(function() v=p.AssemblyLinearVelocity end) if not v then v=Vector3.new() end local t=d/math.max(700,1) return ps+v*t end
local function gT(req) local c2=Vector2.new(vp.X/2,vp.Y/2) local best=nil for _,p in ipairs(P:GetPlayers()) do if p~=LP and not (F.team and sameT(LP,p)) then local c=getC(p) if c then local b=bn(c) if b and (not req or not F.wall or vis(c,b)) then local a=aP(b) local sp=w2s(a) if sp then local d=(sp-c2).Magnitude if d<=F.fov and (not best or d<best.d) then best={pos=a,d=d} end end end end end end return best end

local rP,rY=nil,nil local ls=0
local function py() local l=C.CFrame.LookVector return math.asin(math.clamp(l.Y,-1,1)),math.atan2(-l.X,-l.Z) end
local function rb(p,y) local cp,sp=math.cos(p),math.sin(p) local cy,sy=math.cos(y),math.sin(y) local d=Vector3.new(-sy*cp,sp,-cy*cp) local pos=C.CFrame.Position C.CFrame=CFrame.lookAt(pos,pos+d) end
local function rT() if not F.recoil then rP,rY=nil,nil return end local dt=(tick()-ls)*1000 if dt>=260 or rP==nil then local p,y=py() rP,rY=p,y return end local cp,cy=py() local dp=cp-rP local dy=cy-rY if math.deg(math.abs(dp))>6 then rP,rY=cp,cy return end if math.deg(math.abs(dp))<0.01 then return end rb(cp-dp*0.98,cy-dy*0.98) end

local fC=false local fP=nil local oT=nil

local SNAP={res={},item={},base={},veh={}}
local WP={}
local function wS(k) local s=WP[k] if s then return s end s={box=Instance.new("Frame",G),nm=Instance.new("TextLabel",G)} s.box.BackgroundTransparency=1 s.box.BorderSizePixel=2 s.box.Visible=false Instance.new("UICorner",s.box).CornerRadius=UDim.new(0,4) s.nm.BackgroundTransparency=1 s.nm.Font=Enum.Font.GothamBold s.nm.TextSize=11 s.nm.Size=UDim2.new(0,200,0,14) s.nm.TextXAlignment=Enum.TextXAlignment.Center s.nm.Visible=false WP[k]=s return s end
local function wH(s) s.box.Visible=false s.nm.Visible=false end
local function wD(s,sp,col,txt,sz) local w=sz or 20 s.box.Visible=true s.box.Position=UDim2.new(0,sp.X-w/2,0,sp.Y-w/2) s.box.Size=UDim2.new(0,w,0,w) s.box.BorderColor3=col s.nm.Visible=true s.nm.Text=txt s.nm.TextColor3=col s.nm.Position=UDim2.new(0,sp.X-100,0,sp.Y-w/2-14) end
local function fp(i) if i:IsA("BasePart") then return i.Position end local ok,p=pcall(function() return i:GetPivot().Position end) if ok then return p end end

local scn=false
local function rS()
    if scn then return end scn=true
    local cp=C.CFrame.Position
    local r,it,b,v={},{},{},{}
    local st={} for _,c in ipairs(W:GetChildren()) do st[#st+1]=c end
    local i=0
    while #st>0 do
        local ins=table.remove(st) i=i+1
        local nm=string.lower(ins.Name)
        if F.res and (nm:find("stone") or nm:find("metal") or nm:find("sulfur") or nm:find("wood") or nm:find("hemp")) then local p=fp(ins) if p then local d=(p-cp).Magnitude if d<=F.rDist then r[#r+1]={i=ins,p=p,d=d,n=ins.Name} end end end
        if F.item and ins:IsA("Model") and ins:FindFirstChildOfClass("Tool") then local p=fp(ins) if p then local d=(p-cp).Magnitude if d<=400 then it[#it+1]={i=ins,p=p,d=d,n=ins.Name} end end end
        if F.base and (nm:find("door") or nm:find("furnace") or nm:find("chest") or nm:find("box") or nm:find("turret") or nm:find("trap") or nm:find("cupboard")) then local p=fp(ins) if p then local d=(p-cp).Magnitude if d<=400 then b[#b+1]={i=ins,p=p,d=d,n=ins.Name} end end end
        if F.veh and (nm:find("atv") or nm:find("minicopter") or nm:find("boat")) then local p=fp(ins) if p then v[#v+1]={i=ins,p=p,d=(p-cp).Magnitude,n=ins.Name} end end
        for _,ch in ipairs(ins:GetChildren()) do st[#st+1]=ch end
        if i%150==0 then task.wait() end
    end
    SNAP={res=r,item=it,base=b,veh=v}
    scn=false
end

local function tickAll()
    L.Brightness = F.fb and 2 or 1
    L.FogEnd = F.nofog and 1e6 or 100000
    L.GlobalShadows = not F.noshadow
    if C then C.FieldOfView = F.visFov or 90 end

    local cp=C.CFrame.Position
    if F.esp then
        local sn={}
        for _,p in ipairs(P:GetPlayers()) do
            if p~=LP then local c,h,u=getC(p) if c then local d=(h.Position-cp).Magnitude if d<=F.pDist then local tl,br=bb(h.CFrame,Vector3.new(2,5,1)) if tl then sn[p]=true local col=(F.team and sameT(LP,p)) and TC.tm or TC.en dE(sF(p),tl,br,col,p.Name,d,math.clamp(u.Health/u.MaxHealth,0,1)) sC(p,c) end end end end end
        end
        for k,s in pairs(EC) do if typeof(k)=="Instance" and k:IsA("Player") and not sn[k] then hE(s) local h=CH[k] if h and h.Parent then h:Destroy() end CH[k]=nil end end
    end

    if (F.aim or F.aimLock) and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=gT(not F.wall) if t then local ccp=C.CFrame.Position local cur=C.CFrame.LookVector local tgt=(t.pos-ccp).Unit local pull=F.aimLock and 1.0 or math.clamp(F.smooth,0.02,1) local nl=cur:Lerp(tgt,pull).Unit rb(math.asin(math.clamp(nl.Y,-1,1)),math.atan2(-nl.X,-nl.Z)) end
    end
    rT()

    if F.trig and U:IsKeyDown(Enum.KeyCode.X) then
        local t=gT(true) if t and w2s(t.pos) then pcall(function() local vim=game:GetService("VirtualInputManager") vim:SendMouseButtonEvent(C.ViewportSize.X/2,C.ViewportSize.Y/2,0,true,game,1) task.wait((F.trigDel or 50)/1000) vim:SendMouseButtonEvent(C.ViewportSize.X/2,C.ViewportSize.Y/2,0,false,game,1) end) end
    end

    if F.res or F.item or F.base or F.veh then
        if tick()-(_G._lastScan or 0)>=4 then _G._lastScan=tick() task.spawn(function() pcall(rS) end) end
        local live={}
        for _,cat in pairs(SNAP) do for _,e in ipairs(cat) do if e.i.Parent then local sp=w2s(e.p) if sp then live[e.i]=true wD(wS(e.i),sp,TC.ac,e.n) end end end end
        for k,s in pairs(WP) do if not live[k] then wH(s) end end
    else for _,s in pairs(WP) do wH(s) end end

    if F.fcam and not fC then fC=true fP=C.CFrame.Position oT=C.CameraType elseif not F.fcam and fC then fC=false C.CameraType=oT end
    if fC then local rot=C.CFrame.Rotation local pos=fP local m=Vector3.new(0,0,0) if U:IsKeyDown(Enum.KeyCode.W) then m=m+rot.LookVector end if U:IsKeyDown(Enum.KeyCode.S) then m=m-rot.LookVector end if U:IsKeyDown(Enum.KeyCode.A) then m=m-rot.RightVector end if U:IsKeyDown(Enum.KeyCode.D) then m=m+rot.RightVector end if m.Magnitude>0 then pos=pos+m.Unit*F.fSpd*0.1 end fP=pos C.CFrame=CFrame.new(pos,pos+rot.LookVector) end
end

CN[#CN+1]=U.InputBegan:Connect(function(inp,gp) if gp then return end if inp.KeyCode==Enum.KeyCode.RightShift then G.Enabled=not G.Enabled end if inp.UserInputType==Enum.UserInputType.MouseButton1 then ls=tick() if F.recoil then local p,y=py() rP,rY=p,y end end end)
local BIND="rh_"..tostring(math.random(100000,999999))
R:BindToRenderStep(BIND,Enum.RenderPriority.Camera.Value+1,tickAll)
CN[#CN+1]={Disconnect=function() pcall(function() R:UnbindFromRenderStep(BIND) end) end}

_G.__RAINHUB=function() for _,c in ipairs(CN) do pcall(function() c:Disconnect() end) end if fC then C.CameraType=oT end for k,s in pairs(EC) do hE(s) end for k,h in pairs(CH) do if h and h.Parent then h:Destroy() end end for _,s in pairs(WP) do wH(s) end pcall(function() G:Destroy() end) _G.__RAINHUB=nil end
print("[rainhub v4] COMPACT SUITE ONLINE")