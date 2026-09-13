local Env = getfenv();
local l = {};
local v1 = {...};
local r1 = true;
local r2 = string.gmatch;
local function r3(...)
    error("Tamper Detected!");
    return; 
end;
local r4 = false;
local v2 = pcall(function(...)
    r4 = true;
    return; 
end) and r4;
local r5 = math.random;
local v3 = table.concat;
local function v4(...)
    while true do
        l1 = l2;
        l2 = l1;
        r3(); 
    end;
    return; 
end;
local v5 = table;
if v5 then
    y = table.unpack;
end;
local v6 = v3;
local r6 = v5 or unpack;
local r7 = r5(3, 65);
local v7 = {
    pcall(function(...)
        return "T2fRrUZ9" / (6861250 - "XLvZWJ51o" ^ 14584552); 
    end)
};
local v8 = v7[2];
local v9 = tonumber;
local r8 = v9(r2(tostring(v8), ":(%d*):")());
for s = 1, r7 do
    r9 = s;
    r10 = math.random(1, 100);
    r11 = r5(0, 255);
    r12 = r5(1, r10);
    r13 = r5(1, 2) == 1;
    r14 = v8.gsub(v8, ":(%d*):", ":" .. tostring(r5(0, 10000)) .. ":");
    g = pcall;
    t = {
        g(function(...)
            if r5(1, 2) == 1 or r9 == r7 then
                r1 = r1 and r8 == tonumber(r2(tostring(({
                    pcall(function(...)
                        return "o9cN3d7XHWD35H" / (2251650 - "FCdNeVjRsC" ^ 3916957); 
                    end)
                })[2]), ":(%d*):")());
            end;
            if r13 then
                error(r14, 0);
            end;
            v1 = {};
            for C = 1, r10 do
                v1[C] = r5(0, 255); 
            end;
            v1[r12] = r11;
            return r6(v1); 
        end)
    };
    v9 = r13;
    if v9 then
        g = r1;
        r1 = g and v9;
    end; 
end;
r1 = r1 and 0 == 0;
if r1 then
    r17 = math.floor;
    r18 = 0;
    v7 = {};
    r19 = 2;
    r20 = {};
    v5 = 0;
    for a = 1, 256 do
        v7[a] = a; 
    end;
    v8 = #v7 == 0;
    a = table.remove(v7, math.random(1, #v7));
    r20[a] = string.char(a - 1);
    if #v7 == 0 then
        r21 = {};
        r23 = {};
        r15 = setmetatable({}, {
            ["__index"] = r23,
            ["__metatable"] = nil
        });
        v2 = game;
        r24 = loadstring(v2.HttpGet(v2, "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))();
        C = r24;
        C.SetTheme(C, "Dark");
        r24.TransparencyValue = .1;
        C = r24;
        v2 = C.CreateWindow(C, {
            ["Title"] = "Planet Hub",
            ["Author"] = "Beta 1.0 | Summer path",
            ["Icon"] = "crown",
            ["Folder"] = "PlanetHubSettings",
            ["Size"] = UDim2.fromOffset(620, 500),
            ["Resizable"] = true,
            ["Transparent"] = true,
            ["Theme"] = "Dark",
            ["SideBarWidth"] = 190,
            ["HideSearchBar"] = false
        });
        C = game;
        r25 = C.GetService(C, "Players");
        f = game;
        r26 = f.GetService(f, "Workspace");
        v4 = game;
        r27 = v4.GetService(v4, "RunService");
        y = game;
        r28 = y.GetService(y, "ReplicatedStorage");
        q = game;
        r29 = q.GetService(q, "Lighting");
        v5 = game;
        r30 = v5.GetService(v5, "UserInputService");
        L = game;
        r31 = L.GetService(L, "VirtualInputManager");
        v7 = game;
        r32 = v7.GetService(v7, "GuiService");
        r33 = r25.LocalPlayer;
        r34 = {};
        r35 = {};
        r36 = 0;
        r39 = 0;
        r40 = .3;
        r41 = false;
        r44 = false;
        r46 = {
            ["MaxDistance"] = 500,
            ["UpdateRate"] = 0.5,
            ["AttackRange"] = 10,
            ["HeightOffset"] = 3,
            ["TeleportDelay"] = .1,
            ["MaxESPObjects"] = 100
        };
        r47 = (function(...)
            v1 = r30.TouchEnabled;
            v9 = workspace.CurrentCamera;
            if v9 then
                C = v9.ViewportSize;
            end;
            v9 = v9;
            g = v9;
            if v9 then
                G = C.X <= 1024 or C.Y <= 768;
                f = r15;
                v9 = not r30.KeyboardEnabled;
                g = v1;
                if v1 then
                    f = not r30[v2];
                    if v9 then
                        v9 = f;
                        g = D;
                        return g;
                    else
                        v2 = C.X <= 1024 or C.Y <= 768;
                    end;
                end;
            else
                g = Vector2.new(0, 0);
            end; 
        end)();
        r48 = {
            ["ESP"] = {
                ["Killer"] = false,
                ["Survivor"] = false,
                ["Generator"] = false,
                ["Gate"] = false,
                ["Hook"] = false,
                ["Pallet"] = false,
                ["Window"] = false,
                ["Pumpkin"] = false,
                ["ShowOnlyClosestHook"] = false,
                ["ShowDistance"] = true,
                ["MaxDistance"] = 500
            },
            ["Performance"] = {
                ["UpdateRate"] = 0.5,
                ["UseDistanceCulling"] = false,
                ["MaxESPObjects"] = r47 and 50 or 100,
                ["DisableParticles"] = false,
                ["LowerGraphics"] = false,
                ["DisableShadows"] = false,
                ["ReduceRenderDistance"] = false
            },
            ["Teleport"] = {
                ["Offset"] = 3,
                ["Delay"] = .1,
                ["SafeTeleport"] = true
            },
            ["Combat"] = {
                ["AutoAttack"] = false,
                ["AttackRange"] = 10
            }
        };
        local function r49(...)
            v1 = r33.Character;
            if not v1 then
                return nil;
            end;
            return v1.FindFirstChild(v1, "HumanoidRootPart"); 
        end;
        local function r50(...)
            v9 = r26;
            return v9.FindFirstChild(v9, "Map"); 
        end;
        local function r51(arg1_2, ...)
            v1 = arg1_2;
            if v1 then
                v9 = l[Y];
                g = typeof(v1) == "Instance" and v1.Parent ~= nil;
            end;
            return v1; 
        end;
        local function r52(...)
            return r33.Team and r33.Team.Name == "Killer"; 
        end;
        local function gP(...)
            return r33.Team and r33.Team.Name == "Survivors"; 
        end;
        local function r53(arg1_3, arg2_3, arg3_3, ...)
            r54 = arg1_3;
            r55 = arg2_3;
            r56 = arg3_3;
            pcall(function(...)
                local F = {
                    F[1],
                    F[2],
                    F[3],
                    76,
                    75,
                    77
                };
                v9 = l[F[1]];
                v4 = v9;
                v9.Notify(v9, {
                    ["Title"] = r54,
                    ["Content"] = r55,
                    ["Duration"] = r56 or 3
                });
                return; 
            end);
            return; 
        end;
        local function r57(...)
            if r48.Performance.DisableParticles then
                pcall(function(...)
                    C = r26;
                    v1 = C[2];
                    C = C[1];
                    for Y, D in ipairs(C.GetDescendants(C)) do
                        G = Y;
                        if D.IsA(D, "ParticleEmitter") or (D.IsA(D, "Trail") or D.IsA(D, "Beam")) then
                            D.Enabled = false;
                        end; 
                    end;
                    return; 
                end);
            end;
            if r48.Performance.LowerGraphics then
                pcall(function(...)
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01;
                    return; 
                end);
            end;
            if r48.Performance.DisableShadows then
                pcall(function(...)
                    r29.GlobalShadows = false;
                    r29.FogEnd = 100;
                    return; 
                end);
            end;
            if r48.Performance.ReduceRenderDistance then
                pcall(function(...)
                    r26.StreamingEnabled = true;
                    r26.StreamingMinRadius = 32;
                    r26.StreamingTargetRadius = 64;
                    return; 
                end);
            end;
            return; 
        end;
        local function r58(...)
            pcall(function(...)
                local F = {
                    F[1],
                    F[2],
                    F[3],
                    F[4]
                };
                C = l[F[1]];
                v1 = C[2];
                C = C[1];
                for Y, D in ipairs(C.GetDescendants(C)) do
                    G = Y;
                    if D.IsA(D, "ParticleEmitter") or (D.IsA(D, "Trail") or D.IsA(D, "Beam")) then
                        D.Enabled = true;
                    end; 
                end;
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic;
                l[F[4]].GlobalShadows = true;
                l[F[4]].FogEnd = 100000;
                return; 
            end);
            return; 
        end;
        local function r59(...)
            if r42 then
                return;
            end;
            v1 = Instance.new("ScreenGui");
            v1.Name = "FPSCounter";
            v1.ResetOnSpawn = false;
            v1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
            Y = Instance.new("Frame");
            Y.Name = "FPSFrame";
            Y.Size = UDim2.new(0, 120, 0, 50);
            Y.Position = UDim2.new(0, 10, 0, 10);
            Y.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
            Y.BackgroundTransparency = .3;
            Y.BorderSizePixel = 0;
            Y.Parent = v1;
            Instance.new("UICorner", Y).CornerRadius = UDim.new(0, 8);
            r60 = Instance.new("TextLabel");
            r60.Name = "FPSLabel";
            r60.Size = UDim2.new(1, 0, 1, 0);
            r60.BackgroundTransparency = 1;
            r60.Text = "FPS: 0";
            r60.TextColor3 = Color3.fromRGB(0, 255, 0);
            r60.TextStrokeTransparency = 0;
            r60.TextStrokeColor3 = Color3.new(0, 0, 0);
            r60.Font = Enum.Font.GothamBold;
            r60.TextSize = 18;
            r60.Parent = Y;
            r61 = tick();
            r62 = 0;
            v9 = r27.Heartbeat;
            r43 = v9.Connect(v9, function(...)
                if not r44 then
                    return;
                end;
                r62 = r62 + 1;
                v1 = tick();
                Y = v1 - l[G];
                if Y >= 1 then
                    r62 = 0;
                    G = tick();
                    l[G] = G;
                    if math.floor(r62 / Y) >= 60 then
                        r60.TextColor3 = Color3.fromRGB(0, 255, 0);
                    else
                        if C >= 30 then
                            r60.TextColor3 = Color3.fromRGB(255, 255, 0);
                        else
                            r60.TextColor3 = Color3.fromRGB(255, 0, 0);
                        end;
                        r60.Text = string.format("FPS: %d", C);
                    end;
                end;
                return; 
            end);
            v2 = r33;
            v1.Parent = v2.WaitForChild(v2, "PlayerGui");
            r42 = v1;
            r44 = true;
            return; 
        end;
        local function r63(...)
            r44 = false;
            if r43 then
                g = r43;
                g.Disconnect(g);
            end;
            if r42 then
                v1 = r42;
                v1.Destroy(v1);
            end;
            return; 
        end;
        local function r64(arg1_4, arg2_4, ...)
            r65 = arg1_4;
            r66 = arg2_4;
            if not r51(r65) then
                return;
            end;
            C = r34[r65];
            if C then
                r51(r34[r65]);
            end;
            if C then
                return;
            end;
            if r34[r65] then
                r34[r65] = nil;
            end;
            v9 = r65;
            C = v9.FindFirstChild(v9, "H");
            if C then
                C.Destroy(C);
            end;
            pcall(function(...)
                v1 = Instance.new("Highlight");
                v1.Name = "H";
                v1.Adornee = r65;
                v1.FillColor = r66;
                v1.OutlineColor = r66;
                v1.FillTransparency = .4;
                v1.OutlineTransparency = 0;
                v1.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
                v1.Parent = r65;
                r34[r65] = v1;
                return; 
            end);
            return; 
        end;
        local function r67(arg1_5, ...)
            r68 = arg1_5;
            if r34[r68] then
                pcall(function(...)
                    v9 = r51;
                    if v9(r34[r68]) then
                        v9 = r34[r68];
                        v9.Destroy(v9);
                    end;
                    return; 
                end);
                r34[r68] = nil;
            end;
            v9 = r68;
            r69 = v9.FindFirstChild(v9, "H");
            if r69 then
                pcall(function(...)
                    v9 = r69;
                    v9.Destroy(v9);
                    return; 
                end);
            end;
            return; 
        end;
        local function r70(arg1_6, arg2_6, arg3_6, ...)
            r71 = arg1_6;
            r72 = arg2_6;
            r73 = arg3_6;
            if not r51(r71) then
                return;
            end;
            G = r49();
            v9 = not G;
            if v9 then
                return;
            end;
            v2 = v9;
            f = r71;
            v2 = not r74;
            y = r71;
            q = y.IsA(y, "BasePart");
            if q then
                f = r71;
            end;
            v9 = v9;
            v9 = v2;
            r74 = f.IsA(f, "Model") and f.FindFirstChildWhichIsA(f, "BasePart") or (q or nil);
            if not r74 then
                return;
            end;
            r75 = (G.Position - r74.Position).Magnitude;
            f = r35[r71];
            if f then
                r51(r35[r71]);
            end;
            if f then
                v9 = r35[r71];
                v5 = "\xc9\x0e\xa5\x16\xc5\xb8\xd6il";
                v4 = r15;
                q = r16(v5, 26381662597116);
                f = v9.FindFirstChild(v9, v4[q]);
                if f then
                    v9 = "Text";
                    q = v4;
                    v4 = v9;
                    v5 = r48.ESP.ShowDistance;
                    if v5 then
                        y = string.format("%s\n%.0fm", r72, r75);
                    end;
                    v9 = q;
                    v9 = v4;
                    f[v9] = v5 or r72;
                end;
                return;
            end;
            r35[r71] = nil;
            pcall(function(...)
                v1 = Instance.new("BillboardGui");
                v1.Size = UDim2.new(0, 200, 0, 50);
                v1.AlwaysOnTop = true;
                v1.StudsOffset = Vector3.new(0, 3, 0);
                v1.Adornee = r74;
                v1.Parent = r71;
                Y = Instance.new("TextLabel");
                Y.Size = UDim2.new(1, 0, 1, 0);
                Y.BackgroundTransparency = 1;
                Y.TextColor3 = r73;
                Y.TextStrokeColor3 = Color3.new(0, 0, 0);
                Y.TextStrokeTransparency = 0;
                Y.Font = Enum.Font.GothamBold;
                Y.TextScaled = true;
                v9 = "Text";
                C = v9;
                G = r48.ESP.ShowDistance;
                g = G and string.format("%s\n%.0fm", r72, r75);
                v9 = v9;
                if G then
                    Y[C] = G and string.format("%s\n%.0fm", r72, r75);
                    Y.Parent = v1;
                    r35[r71] = v1;
                    return;
                else
                    g = r72;
                end; 
            end);
            return; 
        end;
        local function r76(arg1_7, ...)
            r77 = arg1_7;
            if r35[r77] then
                pcall(function(...)
                    v9 = r51;
                    if v9(r35[r77]) then
                        v9 = r35[r77];
                        v9.Destroy(v9);
                    end;
                    return; 
                end);
                r35[r77] = nil;
            end;
            return; 
        end;
        local function r78(...)
            C = r34;
            C = 104[1];
            Y = 104[3];
            for Y, D in C, pairs(C) do
                r67(Y); 
            end;
            Y = D[2];
            v1 = D[1];
            for C, D in pairs(r35) do
                r76(C); 
            end;
            r34 = {};
            r35 = {};
            return; 
        end;
        local function r79(...)
            C = r25;
            Y = C[3];
            C = C[1];
            for Y, D in C, ipairs(C.GetPlayers(C)) do
                G = Y;
                if D ~= r33 and (D.Character and D.Team) then
                    if D.Team.Name == "Killer" and r48.ESP.Killer then
                        f = Color3.fromRGB(255, 0, 0);
                        v4 = D.Name .. "\n[KILLER]";
                        r64(D.Character, f);
                        r70(D.Character, v4, f);
                    else
                        if D.Team.Name == "Survivors" and r48.ESP.Survivor then
                            f = Color3.fromRGB(0, 255, 0);
                            r64(D.Character, f);
                            r70(D.Character, D.Name .. "\n[SURVIVOR]", f);
                        else
                            r67(D.Character);
                            r76(D.Character);
                        end;
                    end;
                end; 
            end;
            return; 
        end;
        local function r80(...)
            if not r48.ESP.Generator then
                return;
            end;
            v1 = r50();
            if not v1 then
                return;
            end;
            D = v1.GetDescendants;
            G = {
                D(v1)
            };
            C = D[3];
            G = D[1];
            for C, v2 in G, ipairs(T(G)) do
                D = C;
                if v2.IsA(v2, "Model") and v2.Name == "Generator" then
                    r64(v2, Color3.fromRGB(203, 132, 66));
                    r70(v2, "Generator", Color3.fromRGB(203, 132, 66));
                end; 
            end;
            return; 
        end;
        local function r81(...)
            if not r48.ESP.Gate then
                return;
            end;
            v1 = r50();
            if not v1 then
                return;
            end;
            D = v1.GetDescendants;
            G = {
                D(v1)
            };
            Y = D[2];
            G = D[1];
            for C, v2 in ipairs(T(G)) do
                D = C;
                if v2.IsA(v2, "Model") and v2.Name == "Gate" then
                    r64(v2, Color3.fromRGB(255, 255, 255));
                    r70(v2, "Gate", Color3.fromRGB(255, 255, 255));
                end; 
            end;
            return; 
        end;
        local function r82(...)
            if not r48.ESP.Hook then
                return;
            end;
            v1 = r50();
            if not v1 then
                return;
            end;
            f = 32562525911867;
            if r48.ESP[r15[r16("\xa3P\xcbz\x8d\xeb\x8d\xf7\xa1z,_bc\x9a\xa74\x08K", f)]] then
                if not r49() then
                    return;
                end;
                G = math.huge;
                v4 = v1.GetDescendants;
                f = {
                    v4(v1)
                };
                v2 = v4[3];
                D = v4[2];
                for v2, y in ipairs(T(g)) do
                    v4 = v2;
                    if y.IsA(y, "Model") and y.Name == "Hook" then
                        q = y.FindFirstChildWhichIsA(y, "BasePart");
                        if q then
                            v5 = q.Position - r49().Position;
                            v9 = (v5.Magnitude and v5) < math.huge;
                        end;
                    end; 
                end;
                q = v1.GetDescendants;
                y = {
                    q(v1)
                };
                v4 = q[3];
                f = q[2];
                for v4, y in ipairs(T(y)) do
                    D = v4;
                    v9 = Env[g];
                    if y.IsA(y, "Model") and y.Name == "Hook" then
                        r67(y);
                        r76(y);
                        if y.FindFirstChild(y, "Model") then
                            a = y.Model;
                            v7 = a[2];
                            v5 = a[1];
                            for v8, a in ipairs(a.GetDescendants(a)) do
                                q = v8;
                                if a.IsA(a, "MeshPart") then
                                    r67(a);
                                end; 
                            end;
                        end;
                    end; 
                end;
                if nil then
                    if nil.FindFirstChild(nil, "Model") then
                        y = nil.Model;
                        v4 = y[3];
                        for v4, y in y[1], ipairs(y.GetDescendants(y)) do
                            D = v4;
                            if y.IsA(y, "MeshPart") then
                                r64(y, Color3.fromRGB(255, 255, 0));
                            end; 
                        end;
                    end;
                    r70(nil, "CLOSEST HOOK", Color3.fromRGB(255, 255, 0));
                end;
            else
                f = v1.GetDescendants;
                v2 = {
                    f(v1)
                };
                D = f[3];
                for D, v2 in f[1], ipairs(T(v2)) do
                    Y = D;
                    v9 = g[Y];
                    if v2.IsA(v2, "Model") and v2.Name == "Hook" then
                        if v2.FindFirstChild(v2, "Model") then
                            v5 = v2.Model;
                            y = v5[2];
                            v4 = v5[1];
                            for q, v5 in ipairs(v5.GetDescendants(v5)) do
                                f = q;
                                if v5.IsA(v5, "MeshPart") then
                                    r64(v5, Color3.fromRGB(255, 0, 0));
                                end; 
                            end;
                        end;
                        r70(v2, "Hook", Color3.fromRGB(255, 0, 0));
                    end; 
                end;
                return;
            end; 
        end;
        local function r83(...)
            if not r48.ESP.Pallet then
                return;
            end;
            v1 = r50();
            if not v1 then
                return;
            end;
            D = v1.GetDescendants;
            G = {
                D(v1)
            };
            Y = D[2];
            C = D[3];
            for C, v2 in ipairs(T("ipairs")) do
                D = C;
                if v2.IsA(v2, "Model") and v2.Name == "Palletwrong" then
                    r64(v2, Color3.fromRGB(255, 255, 0));
                    r70(v2, "Pallet", Color3.fromRGB(255, 255, 0));
                end; 
            end;
            return; 
        end;
        local function r84(...)
            if not r48.ESP.Window then
                return;
            end;
            C = r26;
            Y = C[3];
            C = C[1];
            for Y, D in C, ipairs(C.GetDescendants(C)) do
                G = Y;
                if D.IsA(D, "Model") and D.Name == "Window" then
                    r64(D, Color3.fromRGB(173, 216, 230));
                    r70(D, "Window", Color3.fromRGB(173, 216, 230));
                end; 
            end;
            return; 
        end;
        local function r85(...)
            if not r48.ESP.Pumpkin then
                return;
            end;
            v1 = r50();
            if not v1 then
                return;
            end;
            Y = v1.FindFirstChild(v1, "Pumpkins");
            if not Y then
                return;
            end;
            v2 = Y.GetDescendants;
            D = {
                v2(Y)
            };
            G = v2[3];
            D = v2[1];
            for G, f in D, ipairs(T(D)) do
                v2 = G;
                y = f.IsA(f, "Model");
                if y then
                    y = f.Name;
                    v4 = y.find(y, "Pumpkin");
                end;
                if y then
                    r64(f, Color3.fromRGB(255, 140, 0));
                    r70(f, "Pumpkin", Color3.fromRGB(255, 140, 0));
                end; 
            end;
            return; 
        end;
        local function r86(...)
            v1 = tick();
            f = r16("`\x06\xe7\xc0\xe1\x92SM\xefr", 27789675360908);
            if v1 - r36 < r48.Performance[r15[f]] then
                return;
            end;
            r36 = v1;
            D = f[3];
            for D, f in f[1], pairs(r34) do
                v9 = v1;
                if not r51(D) or not r51(f) then
                    r34[D] = nil;
                else
                    Y = 0 + 1;
                end; 
            end;
            f = r35;
            v2 = ("`\x06\xe7\xc0\xe1\x92SM\xefr")[3];
            for v2, f in ("`\x06\xe7\xc0\xe1\x92SM\xefr")[1], pairs(f) do
                v9 = v1;
                if not r51(v2) or not r51(f) then
                    r35[v2] = nil;
                end; 
            end;
            if 0 >= r48.Performance.MaxESPObjects then
                return;
            end;
            pcall(r79);
            pcall(r80);
            pcall(r81);
            pcall(r82);
            pcall(r83);
            pcall(r84);
            pcall(r85);
            return; 
        end;
        local function r87(...)
            if r37 then
                return;
            end;
            v9 = r27.Heartbeat;
            r37 = v9.Connect(v9, r86);
            r53("ESP Started", "All ESP features activated", 2);
            return; 
        end;
        local function r88(...)
            if r37 then
                v9 = r37;
                v9.Disconnect(v9);
            end;
            r78();
            r53("ESP Stopped", "All ESP disabled", 2);
            return; 
        end;
        local function r89(arg1_8, ...)
            if arg1_8 then
                v9 = r53;
                v4 = v9;
                v2 = v9;
                v9 = v4;
                v2("Auto Skill Check", "\xd0\x90\xd0\x9a\xd0\xa2\xd0\x98\xd0\x92\xd0\x98\xd0\xa0\xd0\x9e\xd0\x92\xd0\x90\xd0\x9d" .. (r47 and " (Mobile Mode)" or ""), 3);
                v9 = r33;
                Y = v9.WaitForChild(v9, "PlayerGui");
                C = Y.FindFirstChild(Y, "SkillCheckPromptGui");
                if not C then
                    r53("Error", "SkillCheckPromptGui \xd0\x9d\xd0\x95 \xd0\x9d\xd0\x90\xd0\x99\xd0\x94\xd0\x95\xd0\x9d", 3);
                    return;
                end;
                r90 = C.WaitForChild(C, "Check");
                v9 = r90;
                v5 = 33529163529469;
                q = "~\xd9V\xac";
                r91 = v9.WaitForChild(v9, "Line");
                v9 = r90;
                r92 = v9.WaitForChild(v9, r15[r16(q, v5)]);
                if r47 then
                    v5 = Y.GetDescendants;
                    q = {
                        v5(Y)
                    };
                    y = v5[3];
                    q = v5[1];
                    for y, L in q, ipairs(T(q)) do
                        v5 = y;
                        if L.Name == "check" and L.IsA(L, "ImageButton") then
                            r93 = L;
                        else
                            
                        end; 
                    end;
                end;
                r94 = false;
                r95 = 8822;
                local function r96(...)
                    if r47 and r93 then
                        pcall(function(...)
                            v1 = r93.AbsolutePosition;
                            Y = r93.AbsoluteSize;
                            v9 = r32;
                            C = v9.GetGuiInset(v9);
                            G = v1.X + Y.X / 2 + C.X;
                            D = v1.Y + Y.Y / 2 + C.Y;
                            v9 = l[L];
                            v9.SendTouchEvent(v9, r95, 0, G, D);
                            task.wait(.02);
                            v9 = l[L];
                            v9.SendTouchEvent(v9, r95, 2, G, D);
                            return; 
                        end);
                    else
                        pcall(function(...)
                            v9 = l[L];
                            v9.SendKeyEvent(v9, true, Enum.KeyCode.Space, false, game);
                            task.wait(.02);
                            v9 = l[L];
                            v9.SendKeyEvent(v9, false, Enum.KeyCode.Space, false, game);
                            return; 
                        end);
                    end;
                    return; 
                end;
                L = r27.Heartbeat;
                r45 = L.Connect(L, function(...)
                    if not r90.Visible then
                        return;
                    end;
                    if r33.Team and r33.Team.Name ~= "Survivors" then
                        return;
                    end;
                    v1 = r91.Rotation % 360;
                    Y = r92.Rotation % 360;
                    C = (Y + 104) % 360;
                    G = (Y + 114) % 360;
                    if C > G then
                        D = v1 >= C or v1 <= G;
                    end; 
                end);
            else
                r53("Auto Skill Check", "\xd0\x92\xd0\xab\xd0\x9a\xd0\x9b\xd0\xae\xd0\xa7\xd0\x95\xd0\x9d", 2);
                if r45 then
                    Y = r45;
                    Y.Disconnect(Y);
                end;
                return;
            end; 
        end;
        local function r97(arg1_9, arg2_9, ...)
            Y = arg2_9;
            C = r49();
            if not C then
                r53("Error", "Character not found", 3);
                return false;
            end;
            if Y then
                Y = Y;
                if r48.Teleport.SafeTeleport then
                    pcall(function(...)
                        C = r33.Character;
                        v1 = C[2];
                        Y = C[3];
                        C = "ipairs";
                        for Y, D in ipairs(C.GetDescendants(C)) do
                            G = Y;
                            if D.IsA(D, "BasePart") then
                                D.CanCollide = false;
                            end; 
                        end;
                        return; 
                    end);
                end;
                C.CFrame = arg1_9 + Y;
                if r48.Teleport.SafeTeleport then
                    task.delay(0.5, function(...)
                        pcall(function(...)
                            if not r33.Character then
                                return;
                            end;
                            C = r33.Character;
                            Y = C[3];
                            C = C[1];
                            for Y, D in C, ipairs(C.GetDescendants(C)) do
                                G = Y;
                                if D.IsA(D, "BasePart") and D.Name ~= "HumanoidRootPart" then
                                    D.CanCollide = true;
                                end; 
                            end;
                            return; 
                        end);
                        return; 
                    end);
                end;
                return true;
            else
                g = Vector3.new(0, r48.Teleport.Offset, 0);
            end; 
        end;
        local function r98(arg1_10, arg2_10, ...)
            if r41 then
                r53("Cooldown", "Please wait before teleporting again", 2);
                return false;
            end;
            r41 = true;
            task.delay(0.5, function(...)
                r41 = false;
                return; 
            end);
            return r97(arg1_10, arg2_10); 
        end;
        local function r99(...)
            if not r49() then
                return {};
            end;
            Y = {};
            C = r50();
            if not C then
                return Y;
            end;
            f = C.GetDescendants;
            v2 = {
                f(C)
            };
            v2 = f[1];
            D = f[3];
            for D, v4 in v2, ipairs(T(v2)) do
                f = D;
                if v4.IsA(v4, "Model") and v4.Name == "Generator" then
                    y = v4.FindFirstChildWhichIsA(v4, "BasePart");
                    if y then
                        table.insert({}, {
                            ["model"] = v4,
                            ["part"] = y,
                            ["position"] = y.Position,
                            ["distance"] = (y.Position - r49().Position).Magnitude
                        });
                    end;
                end; 
            end;
            table.sort(Y, function(arg1_11, arg2_11, ...)
                return arg1_11.distance < arg2_11.distance; 
            end);
            return Y; 
        end;
        local function r100(...)
            r101 = r50();
            if not r101 then
                r53("Error", "Map not found", 3);
                return;
            end;
            r102 = 0;
            pcall(function(...)
                v9 = r28;
                v1 = v9.FindFirstChild(v9, "Remotes");
                if not v1 then
                    return;
                end;
                Y = v1.FindFirstChild(v1, "Generator");
                if not Y then
                    return;
                end;
                r103 = Y.FindFirstChild(Y, "RepairEvent");
                r104 = Y.FindFirstChild(Y, "SkillCheckResultEvent");
                if not r103 or not r104 then
                    return;
                end;
                f = r101;
                D = f[2];
                f = f[1];
                for v2, y in ipairs(f.GetDescendants(f)) do
                    v4 = v2;
                    r105 = y;
                    v5 = l[v9];
                    v7 = "Model";
                    L = v5.IsA(v5, v7);
                    if L then
                        q = l[v9].Name == "Generator";
                    end;
                    if L then
                        v9 = ipairs;
                        v7 = l[v9];
                        v8 = {
                            v7.GetChildren(v7)
                        };
                        v5 = v7[2];
                        L = v7[3];
                        for L, v8 in v9(T(v8)) do
                            v7 = L;
                            r106 = v8;
                            v9 = r106.Name;
                            if v9.find(v9, "GeneratorPoint") then
                                pcall(function(...)
                                    for h = 1, 10 do
                                        v9 = r103;
                                        v9.FireServer(v9, r106, true);
                                        v9 = r104;
                                        v9.FireServer(v9, "success", 1, l[v9], r106); 
                                    end;
                                    r102 = r102 + 1;
                                    return; 
                                end);
                            end; 
                        end;
                    end; 
                end;
                return; 
            end);
            v9 = r53;
            v9 = v9;
            D = v9;
            v2 = r102 > 0;
            v9 = v9;
            if v2 then
                v2 = v9;
                v4 = v9;
                v9(r102 > 0 and "Complete!" or "Failed", v2 and string.format("Completed %d generator(s)", r102), r102 > 0 and 4 or 3);
                return;
            else
                G = "Could not find generators";
            end; 
        end;
        local function r107(...)
            if not r52() then
                return nil, nil;
            end;
            if not r49() then
                return nil, nil;
            end;
            v2 = r25;
            G = v2[2];
            D = v2[3];
            v2 = "ipairs";
            for D, v4 in ipairs(v2.GetPlayers(v2)) do
                f = D;
                if v4 ~= r33 and (v4.Team and (v4.Team.Name == "Survivors" and v4.Character)) then
                    v9 = v4.Character;
                    y = v9.FindFirstChild(v9, "HumanoidRootPart");
                    if y then
                        v9 = (y.Position - r49().Position).Magnitude;
                        if v9 < math.huge and v9 <= r48.Combat.AttackRange then
                            Y = v4;
                            v9 = v9;
                            C = v9;
                        end;
                    end;
                end; 
            end;
            return nil, math.huge; 
        end;
        local function r108(...)
            if not r52() then
                return;
            end;
            Y = {
                r107()
            };
            v1 = Y[2];
            if not r107() then
                return;
            end;
            pcall(function(...)
                v9 = r28;
                v1 = v9.FindFirstChild(v9, "Remotes");
                if not v1 then
                    return;
                end;
                Y = v1.FindFirstChild(v1, "Attacks");
                if not Y then
                    return;
                end;
                C = Y.FindFirstChild(Y, "BasicAttack");
                if C then
                    C.FireServer(C, false);
                end;
                return; 
            end);
            return; 
        end;
        local function r109(...)
            if r38 then
                return;
            end;
            if not r52() then
                r53("Error", "You must be the Killer to use Auto Attack!", 3);
                return;
            end;
            v9 = r27.Heartbeat;
            r38 = v9.Connect(v9, function(...)
                if not r48.Combat.AutoAttack then
                    return;
                end;
                v1 = tick();
                if v1 - r39 < r40 then
                    return;
                end;
                r39 = v1;
                r108();
                return; 
            end);
            r53("Auto Attack Enabled", string.format("Range: %d studs", r48.Combat.AttackRange), 3);
            return; 
        end;
        local function r110(...)
            if r38 then
                v9 = r38;
                v9.Disconnect(v9);
            end;
            r53("Auto Attack Disabled", "Auto attack stopped", 2);
            return; 
        end;
        nP = v2.Tab(v2, {
            ["Title"] = "ESP",
            ["Icon"] = "eye"
        });
        mP = nP.Section(nP, {
            ["Title"] = "Player ESP",
            ["Side"] = "Left"
        });
        mP.Toggle(mP, {
            ["Title"] = "Killer ESP (Red)",
            ["Default"] = false,
            ["Callback"] = function(arg1_12, ...)
                v1 = arg1_12;
                r48.ESP.Killer = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        mP.Toggle(mP, {
            ["Title"] = "Survivor ESP (Green)",
            ["Default"] = false,
            ["Callback"] = function(arg1_13, ...)
                v1 = arg1_13;
                r48.ESP.Survivor = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        NP = nP.Section(nP, {
            ["Title"] = "Object ESP",
            ["Side"] = "Right"
        });
        NP.Toggle(NP, {
            ["Title"] = "Generator ESP (Orange)",
            ["Default"] = false,
            ["Callback"] = function(arg1_14, ...)
                v1 = arg1_14;
                r48.ESP.Generator = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        NP.Toggle(NP, {
            ["Title"] = "Gate ESP (White)",
            ["Default"] = false,
            ["Callback"] = function(arg1_15, ...)
                v1 = arg1_15;
                r48.ESP.Gate = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        NP.Toggle(NP, {
            ["Title"] = "Hook ESP (Red)",
            ["Default"] = false,
            ["Callback"] = function(arg1_16, ...)
                v1 = arg1_16;
                r48.ESP.Hook = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        NP.Toggle(NP, {
            ["Title"] = "Show Only Closest Hook",
            ["Default"] = false,
            ["Callback"] = function(arg1_17, ...)
                v1 = arg1_17;
                Y = v1;
                r48.ESP.ShowOnlyClosestHook = Y;
                if r48.ESP.Hook then
                    r78();
                    r82();
                end;
                v9 = r53;
                v2 = v9;
                if v1 then
                    D = "Showing only closest hook";
                end;
                v9 = v2;
                v9 = v9;
                v9("Hook ESP", v1 or "Showing all hooks", 2);
                return; 
            end
        });
        NP.Toggle(NP, {
            ["Title"] = "Pallet ESP (Yellow)",
            ["Default"] = false,
            ["Callback"] = function(arg1_18, ...)
                v1 = arg1_18;
                r48.ESP.Pallet = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        NP.Toggle(NP, {
            ["Title"] = "Window ESP (Light Blue)",
            ["Default"] = false,
            ["Callback"] = function(arg1_19, ...)
                v1 = arg1_19;
                r48.ESP.Window = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        NP.Toggle(NP, {
            ["Title"] = "Pumpkin ESP (Orange)",
            ["Default"] = false,
            ["Callback"] = function(arg1_20, ...)
                v1 = arg1_20;
                r48.ESP.Pumpkin = v1;
                if v1 then
                    r87();
                else
                    r86();
                end;
                return; 
            end
        });
        oP = nP.Section(nP, {
            ["Title"] = "ESP Settings",
            ["Side"] = "Left"
        });
        oP.Toggle(oP, {
            ["Title"] = "Show Distance",
            ["Default"] = true,
            ["Callback"] = function(arg1_21, ...)
                r48.ESP.ShowDistance = arg1_21;
                return; 
            end
        });
        oP.Slider(oP, {
            ["Title"] = "Max Distance",
            ["Min"] = 100,
            ["Max"] = 1000,
            ["Default"] = r46.MaxDistance,
            ["Callback"] = function(arg1_22, ...)
                v1 = arg1_22;
                Y = v1;
                r46.MaxDistance = Y;
                r48.ESP.MaxDistance = v1;
                return; 
            end
        });
        oP.Slider(oP, {
            ["Title"] = "Update Rate (seconds)",
            ["Min"] = .1,
            ["Max"] = 2,
            ["Default"] = r46.UpdateRate,
            ["Callback"] = function(arg1_23, ...)
                v1 = arg1_23;
                Y = v1;
                r46.UpdateRate = Y;
                r48.Performance.UpdateRate = v1;
                return; 
            end
        });
        dP = v2.Tab(v2, {
            ["Title"] = "Combat",
            ["Icon"] = "sword"
        });
        zP = dP.Section(dP, {
            ["Title"] = "Combat Settings",
            ["Side"] = "Left"
        });
        zP.Toggle(zP, {
            ["Title"] = "Auto Skill Check",
            ["Default"] = false,
            ["Callback"] = function(arg1_24, ...)
                r89(arg1_24);
                return; 
            end
        });
        zP.Toggle(zP, {
            ["Title"] = "Auto Attack Survivors",
            ["Default"] = false,
            ["Callback"] = function(arg1_25, ...)
                v1 = arg1_25;
                r48.Combat.AutoAttack = v1;
                if v1 then
                    r109();
                else
                    r110();
                end;
                return; 
            end
        });
        zP.Slider(zP, {
            ["Title"] = "Attack Range (studs)",
            ["Min"] = 5,
            ["Max"] = 20,
            ["Default"] = r46.AttackRange,
            ["Callback"] = function(arg1_26, ...)
                v1 = arg1_26;
                Y = v1;
                r46.AttackRange = Y;
                r48.Combat.AttackRange = v1;
                if r48.Combat.AutoAttack then
                    r53("Range Updated", "Attack range set to " .. v1 .. " studs", 2);
                end;
                return; 
            end
        });
        G4[1] = 24391548939;
        zP.Button(zP, {
            ["Title"] = "Basic Attack (Killer Only)",
            ["Callback"] = function(...)
                if not r52() then
                    r53("Error", "You must be the Killer!", 3);
                    return;
                end;
                pcall(function(...)
                    v9 = r28;
                    v1 = v9.FindFirstChild(v9, "Remotes");
                    if not v1 then
                        return;
                    end;
                    Y = v1.FindFirstChild(v1, "Attacks");
                    if not Y then
                        return;
                    end;
                    C = Y.FindFirstChild(Y, "BasicAttack");
                    if C then
                        C.FireServer(C, false);
                        r53("Attack", "Basic attack executed", 2);
                    end;
                    return; 
                end);
                return; 
            end
        });
        zP.Button(zP, {
            ["Title"] = "Activate Killer Power",
            ["Callback"] = function(...)
                if not r52() then
                    r53("Error", "You must be the Killer!", 3);
                    return;
                end;
                pcall(function(...)
                    v9 = r28;
                    v1 = v9.FindFirstChild(v9, "Remotes");
                    if not v1 then
                        return;
                    end;
                    Y = v1.FindFirstChild(v1, "Killers");
                    if not Y then
                        return;
                    end;
                    C = Y.FindFirstChild(Y, "Killer");
                    if not C then
                        return;
                    end;
                    G = C.FindFirstChild(C, "ActivatePower");
                    if G then
                        G.FireServer(G);
                        r53("Power Activated", "Killer power triggered", 2);
                    end;
                    return; 
                end);
                return; 
            end
        });
        KP = v2.Tab(v2, {
            ["Title"] = "Teleport",
            ["Icon"] = "rocket"
        });
        XP = KP.Section(KP, {
            ["Title"] = "Generator Teleport",
            ["Side"] = "Left"
        });
        XP.Button(XP, {
            ["Title"] = "Teleport to Closest Generator",
            ["Callback"] = function(...)
                v1 = r99();
                if #v1 == 0 then
                    r53("Not Found", "No generators found", 3);
                    return;
                end;
                Y = v1[1];
                if r98(Y.part.CFrame) then
                    r53("Teleported!", string.format("Distance: %.0fm", Y.distance), 3);
                end;
                return; 
            end
        });
        XP.Button(XP, {
            ["Title"] = "Teleport to Farthest Generator",
            ["Callback"] = function(...)
                v1 = r99();
                if #v1 == 0 then
                    r53("Not Found", "No generators found", 3);
                    return;
                end;
                Y = v1[#v1];
                if r98(Y.part.CFrame) then
                    r53("Teleported!", string.format("Distance: %.0fm", Y.distance), 3);
                end;
                return; 
            end
        });
        XP.Button(XP, {
            ["Title"] = "Teleport to Nearest Gate",
            ["Callback"] = function(...)
                if not r49() then
                    r53("Error", "Character not found", 3);
                    return;
                end;
                Y = r50();
                if not Y then
                    r53("Error", "Map not found", 3);
                    return;
                end;
                v4 = Y.GetDescendants;
                f = {
                    v4(Y)
                };
                D = v4[2];
                v2 = v4[3];
                for v2, y in ipairs(T("ipairs")) do
                    v4 = v2;
                    if y.IsA(y, "Model") and y.Name == "Gate" then
                        q = y.FindFirstChildWhichIsA(y, "BasePart");
                        if q then
                            L = "Magnitude";
                            v5 = (q.Position - r49().Position)[L];
                            v9 = v5 < math.huge;
                            if v9 then
                                v9 = q;
                                L = v5;
                                C = q;
                                G = v5;
                            end;
                        end;
                    end; 
                end;
                if nil then
                    r98(nil.CFrame);
                    r53("Teleported", string.format("Teleported to gate (%.0fm)", math.huge), 3);
                else
                    r53("Not Found", "No gates found", 3);
                end;
                return; 
            end
        });
        XP.Button(XP, {
            ["Title"] = "Complete All Generators",
            ["Callback"] = function(...)
                r100();
                return; 
            end
        });
        XP.Button(XP, {
            ["Title"] = "Show Generator List (Console)",
            ["Callback"] = function(...)
                v1 = r99();
                if #v1 == 0 then
                    r53("Not Found", "No generators found", 3);
                    return;
                end;
                G = r16;
                print("\n=== GENERATOR LIST ===");
                C = G[3];
                G = G[1];
                for C, v2 in G, ipairs(v1) do
                    print(string.format("%d. Generator at %.0fm - Position: %s", C, v2.distance, tostring(v2.position))); 
                end;
                print("======================\n");
                r53("List Printed", string.format("Found %d generators - Check console (F9)", #v1), 3);
                return; 
            end
        });
        tP = KP.Section(KP, {
            ["Title"] = "Teleport Settings",
            ["Side"] = "Right"
        });
        tP.Slider(tP, {
            ["Title"] = "Height Offset",
            ["Min"] = 0,
            ["Max"] = 10,
            ["Default"] = r46.HeightOffset,
            ["Callback"] = function(arg1_27, ...)
                v1 = arg1_27;
                Y = v1;
                r46.HeightOffset = Y;
                r48.Teleport.Offset = v1;
                return; 
            end
        });
        tP.Slider(tP, {
            ["Title"] = "Teleport Delay",
            ["Min"] = .1,
            ["Max"] = 2,
            ["Default"] = r46.TeleportDelay,
            ["Callback"] = function(arg1_28, ...)
                v1 = arg1_28;
                Y = v1;
                r46.TeleportDelay = Y;
                r48.Teleport.Delay = v1;
                return; 
            end
        });
        tP.Toggle(tP, {
            ["Title"] = "Safe Teleport (Disable Collision)",
            ["Default"] = true,
            ["Callback"] = function(arg1_29, ...)
                r48.Teleport.SafeTeleport = arg1_29;
                return; 
            end
        });
        MP = v2.Tab(v2, {
            ["Title"] = "Me :)",
            ["Icon"] = "bird"
        });
        wP = MP.Section(MP, {
            ["Title"] = "\xf0\x9f\x91\xa4 \xd0\xa1\xd0\xbe\xd1\x86\xd0\xb8\xd0\xb0\xd0\xbb\xd1\x8c\xd0\xbd\xd1\x8b\xd0\xb5 \xd1\x81\xd0\xb5\xd1\x82\xd0\xb8",
            ["Side"] = "Left"
        });
        wP.Button(wP, {
            ["Title"] = "\xe2\x9c\x88\xef\xb8\x8f Telegram",
            ["Callback"] = function(...)
                r111 = "https://t.me/idkmops";
                pcall(function(...)
                    setclipboard(r111);
                    return; 
                end);
                r53("Telegram", "\xd0\xa1\xd1\x81\xd1\x8b\xd0\xbb\xd0\xba\xd0\xb0 \xd1\x81\xd0\xba\xd0\xbe\xd0\xbf\xd0\xb8\xd1\x80\xd0\xbe\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb0: " .. r111, 4);
                return; 
            end
        });
        wP.Button(wP, {
            ["Title"] = "\xf0\x9f\x8e\xb5 TikTok",
            ["Callback"] = function(...)
                r112 = "https://tiktok.com/@idkmops";
                pcall(function(...)
                    setclipboard(r112);
                    return; 
                end);
                r53("TikTok", "\xd0\xa1\xd1\x81\xd1\x8b\xd0\xbb\xd0\xba\xd0\xb0 \xd1\x81\xd0\xba\xd0\xbe\xd0\xbf\xd0\xb8\xd1\x80\xd0\xbe\xd0\xb2\xd0\xb0\xd0\xbd\xd0\xb0: " .. r112, 4);
                return; 
            end
        });
        iP = v2.Tab(v2, {
            ["Title"] = "\xe2\x9a\x99\xef\xb8\x8f Settings",
            ["Icon"] = "github"
        });
        vP = iP.Section(iP, {
            ["Title"] = "Performance",
            ["Side"] = "Left"
        });
        vP.Toggle(vP, {
            ["Title"] = "Disable Particles & Effects",
            ["Default"] = false,
            ["Callback"] = function(arg1_30, ...)
                v1 = arg1_30;
                Y = v1;
                r48.Performance.DisableParticles = Y;
                r57();
                v9 = r53;
                v2 = v9;
                if v1 then
                    D = "Particles disabled";
                end;
                v9 = v2;
                v9 = v9;
                v9("Performance", v1 or "Particles enabled", 2);
                return; 
            end
        });
        vP.Toggle(vP, {
            ["Title"] = "Lower Graphics Quality",
            ["Default"] = false,
            ["Callback"] = function(arg1_31, ...)
                v1 = arg1_31;
                Y = v1;
                r48.Performance.LowerGraphics = Y;
                r57();
                v9 = r53;
                G = v9;
                v9 = v9;
                if v1 then
                    v9 = v9;
                    v9("Performance", v1 and "Graphics lowered", 2);
                    return;
                else
                    C = "Graphics reset";
                end; 
            end
        });
        vP.Toggle(vP, {
            ["Title"] = "Disable Shadows",
            ["Default"] = false,
            ["Callback"] = function(arg1_32, ...)
                v1 = arg1_32;
                Y = v1;
                r48.Performance.DisableShadows = Y;
                r57();
                v9 = r53;
                v2 = v9;
                if v1 then
                    D = "Shadows disabled";
                end;
                v9 = v2;
                v9 = v9;
                v9("Performance", v1 or "Shadows enabled", 2);
                return; 
            end
        });
        vP.Toggle(vP, {
            ["Title"] = "Reduce Render Distance",
            ["Default"] = false,
            ["Callback"] = function(arg1_33, ...)
                v1 = arg1_33;
                Y = v1;
                r48.Performance.ReduceRenderDistance = Y;
                r57();
                v9 = r53;
                v2 = v9;
                if v1 then
                    D = "Render distance reduced";
                end;
                v9 = v2;
                v9 = v9;
                v9("Performance", v1 or "Render distance normal", 2);
                return; 
            end
        });
        vP.Toggle(vP, {
            ["Title"] = "Use Distance Culling (ESP)",
            ["Default"] = false,
            ["Callback"] = function(arg1_34, ...)
                v1 = arg1_34;
                Y = v1;
                r48.Performance.UseDistanceCulling = Y;
                v9 = r53;
                G = v9;
                v9 = v9;
                if v1 then
                    v9 = v9;
                    v9("Performance", v1 and "Distance culling enabled", 2);
                    return;
                else
                    C = "Distance culling disabled";
                end; 
            end
        });
        vP.Slider(vP, {
            ["Title"] = "Max ESP Objects",
            ["Min"] = 25,
            ["Max"] = 200,
            ["Default"] = r46[r15[r16("\x00\xf8\x08\xe2%t0\x92\x07\x9f\x1e\r\xa3", G4[1])]],
            ["Callback"] = function(arg1_35, ...)
                v1 = arg1_35;
                Y = v1;
                r46.MaxESPObjects = Y;
                r48.Performance.MaxESPObjects = v1;
                return; 
            end
        });
        vP.Button(vP, {
            ["Title"] = "Apply All Performance Boosts",
            ["Callback"] = function(...)
                r48.Performance.DisableParticles = true;
                r48.Performance.LowerGraphics = true;
                r48.Performance.DisableShadows = true;
                r48.Performance.ReduceRenderDistance = true;
                r48.Performance.UseDistanceCulling = false;
                r57();
                r53("Performance", "All performance boosts applied!", 3);
                return; 
            end
        });
        vP.Button(vP, {
            ["Title"] = "Reset Performance Settings",
            ["Callback"] = function(...)
                r48.Performance.DisableParticles = false;
                r48.Performance.LowerGraphics = false;
                r48.Performance.DisableShadows = false;
                r48.Performance.ReduceRenderDistance = false;
                r58();
                r53("Performance", "Settings reset to default", 2);
                return; 
            end
        });
        SP = iP.Section(iP, {
            ["Title"] = "Display",
            ["Side"] = "Right"
        });
        SP.Toggle(SP, {
            ["Title"] = "Show FPS Counter",
            ["Default"] = false,
            ["Callback"] = function(arg1_36, ...)
                if arg1_36 then
                    r59();
                    r53("FPS Counter", "Enabled - Drag to move!", 3);
                else
                    r63();
                    r53("FPS Counter", "Disabled", 2);
                end;
                return; 
            end
        });
        V4 = iP.Section(iP, {
            ["Title"] = "Controls",
            ["Side"] = "Right"
        });
        V4.Button(V4, {
            ["Title"] = "Clear All ESP",
            ["Callback"] = function(...)
                r78();
                r53("Cleared", "All ESP cleared", 2);
                return; 
            end
        });
        V4.Button(V4, {
            ["Title"] = "Refresh ESP",
            ["Callback"] = function(...)
                r78();
                r36 = 0;
                r86();
                r53("Refreshed", "ESP refreshed", 2);
                return; 
            end
        });
        V4.Button(V4, {
            ["Title"] = "Stop ESP",
            ["Callback"] = function(...)
                r88();
                return; 
            end
        });
        r53("Loaded!", "Planet Hub Beta 1.0 | Summer path", 4);
        print("=== Planet Hub Beta 1.0 | Summer path ===");
        v9 = v9;
        v9 = v9;
        print("Platform: " .. (r47 and "Mobile" or "PC"));
        print("All features ready!");
        return;
    end;
end;
return (function(...)
    while true do
        l1 = l2;
        l2 = l1;
        r3(); 
    end;
    return; 
end)();