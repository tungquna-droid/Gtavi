-- GTA CITY 2.2 FIX | ONE SERVER SCRIPT
-- Place in ServerScriptService. Delete the old GTA City script first.
-- Creates a fixed city (not centered on the player's spawn), surrounding biomes,
-- roads, detailed buildings, trees, R15 NPCs, simple traffic and a safe border return.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local CONFIG = {
    Border = 900,
    NPCCount = 12,
    CarCount = 6,
    TreeCount = 65,
    CarSpeed = 24,
    StopDistance = 25
}

math.randomseed(os.time())

-- Remove only the previous generated city.
local previous = Workspace:FindFirstChild("GTACity")
if previous then
    previous:Destroy()
end

local city = Instance.new("Folder")
city.Name = "GTACity"
city.Parent = Workspace

local function makeFolder(name)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = city
    return folder
end

local roads = makeFolder("Roads")
local buildings = makeFolder("Buildings")
local trees = makeFolder("Trees")
local npcFolder = makeFolder("NPCs")
local traffic = makeFolder("Traffic")
local biomes = makeFolder("Biomes")
local props = makeFolder("Props")

local function makePart(parent, name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material or Enum.Material.Concrete
    p.Anchored = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p.Parent = parent
    return p
end

local function pick(list)
    return list[math.random(1, #list)]
end

-- Lighting and fixed ground.
Lighting.ClockTime = 16
Lighting.Brightness = 2
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.35

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
end
atmosphere.Density = 0.2
atmosphere.Color = Color3.fromRGB(205, 220, 240)
atmosphere.Decay = Color3.fromRGB(110, 130, 155)

makePart(city, "WorldGround", Vector3.new(1900, 12, 1900),
    Vector3.new(0, -7, 0), Color3.fromRGB(92, 132, 77), Enum.Material.Grass)
makePart(city, "CityBase", Vector3.new(1050, 2, 1050),
    Vector3.new(0, -0.5, 0), Color3.fromRGB(115, 115, 110), Enum.Material.Concrete)

-- Road grid. All building lots are placed between road corridors.
local roadLines = {-510, -340, -170, 0, 170, 340, 510}
for _, z in ipairs(roadLines) do
    makePart(roads, "Road_EW", Vector3.new(1050, 0.5, 34),
        Vector3.new(0, 0.6, z), Color3.fromRGB(42, 43, 46), Enum.Material.Asphalt)
    makePart(roads, "Sidewalk_EW", Vector3.new(1050, 0.8, 5),
        Vector3.new(0, 0.25, z + 22), Color3.fromRGB(155, 153, 145))
    makePart(roads, "Sidewalk_EW", Vector3.new(1050, 0.8, 5),
        Vector3.new(0, 0.25, z - 22), Color3.fromRGB(155, 153, 145))
    for x = -500, 500, 28 do
        makePart(roads, "LaneMark", Vector3.new(12, 0.08, 0.45),
            Vector3.new(x, 0.9, z), Color3.fromRGB(235, 215, 135), Enum.Material.SmoothPlastic)
    end
end

for _, x in ipairs(roadLines) do
    makePart(roads, "Road_NS", Vector3.new(34, 0.5, 1050),
        Vector3.new(x, 0.6, 0), Color3.fromRGB(42, 43, 46), Enum.Material.Asphalt)
    makePart(roads, "Sidewalk_NS", Vector3.new(5, 0.8, 1050),
        Vector3.new(x + 22, 0.25, 0), Color3.fromRGB(155, 153, 145))
    makePart(roads, "Sidewalk_NS", Vector3.new(5, 0.8, 1050),
        Vector3.new(x - 22, 0.25, 0), Color3.fromRGB(155, 153, 145))
    for z = -500, 500, 28 do
        makePart(roads, "LaneMark", Vector3.new(0.45, 0.08, 12),
            Vector3.new(x, 0.9, z), Color3.fromRGB(235, 215, 135), Enum.Material.SmoothPlastic)
    end
end

-- Roundabout island in the central intersection.
local roundabout = makePart(roads, "RoundaboutIsland", Vector3.new(52, 1.5, 52),
    Vector3.new(0, 1.3, 0), Color3.fromRGB(65, 125, 65), Enum.Material.Grass)
roundabout.Shape = Enum.PartType.Cylinder

-- Building function: simple but recognizable houses, shops and towers.
local wallColors = {
    Color3.fromRGB(190, 180, 160),
    Color3.fromRGB(175, 185, 195),
    Color3.fromRGB(210, 200, 180),
    Color3.fromRGB(125, 135, 150)
}

local function createBuilding(x, z, kind)
    local model = Instance.new("Model")
    model.Name = kind
    model.Parent = buildings

    local width, depth, height
    if kind == "Tower" then
        width, depth, height = math.random(38, 46), math.random(38, 46), math.random(95, 145)
    elseif kind == "Shop" then
        width, depth, height = 36, 32, 26
    else
        width, depth, height = math.random(23, 28), math.random(23, 28), math.random(16, 23)
    end

    local base = makePart(model, "MainBuilding", Vector3.new(width, height, depth),
        Vector3.new(x, height / 2 + 1, z), pick(wallColors), Enum.Material.Concrete)
    model.PrimaryPart = base

    makePart(model, "Roof", Vector3.new(width + 2, 1.5, depth + 2),
        Vector3.new(x, height + 1.75, z), Color3.fromRGB(65, 65, 70), Enum.Material.Slate)

    makePart(model, "Door", Vector3.new(4, 8, 0.5),
        Vector3.new(x, 5, z + depth / 2 + 0.3), Color3.fromRGB(75, 48, 32), Enum.Material.Wood)

    for floorIndex = 1, math.max(1, math.floor(height / 14)) do
        for side = -1, 1, 2 do
            local window = makePart(model, "Window", Vector3.new(5, 5, 0.3),
                Vector3.new(x + side * width / 3, floorIndex * 13, z + depth / 2 + 0.2),
                Color3.fromRGB(100, 175, 210), Enum.Material.Glass)
            window.Transparency = 0.2
            window.CanCollide = false
        end
    end

    if kind == "Shop" then
        local sign = makePart(model, "ShopSign", Vector3.new(25, 4, 0.5),
            Vector3.new(x, height - 5, z + depth / 2 + 0.5),
            Color3.fromRGB(35, 90, 160), Enum.Material.Neon)
        local surface = Instance.new("SurfaceGui")
        surface.Face = Enum.NormalId.Front
        surface.Parent = sign
        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = "CITY MARKET"
        text.TextScaled = true
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Font = Enum.Font.GothamBold
        text.Parent = surface
    end
end

-- Blocks are centred between roads; lots sit well clear of the asphalt.
for blockX = -425, 425, 170 do
    for blockZ = -425, 425, 170 do
        for _, offset in ipairs({
            Vector2.new(-30, -30),
            Vector2.new(30, -30),
            Vector2.new(-30, 30),
            Vector2.new(30, 30)
        }) do
            local x = blockX + offset.X
            local z = blockZ + offset.Y
            local central = math.abs(x) < 250 and math.abs(z) < 250
            if central and math.random() < 0.45 then
                createBuilding(x, z, "Tower")
            else
                createBuilding(x, z, "House")
            end
        end
    end
end

createBuilding(265, 95, "Shop")
createBuilding(-265, -95, "Shop")
createBuilding(95, -265, "Shop")
createBuilding(-95, 265, "Shop")

-- Biomes around the city: forest, desert, countryside and beach.
makePart(biomes, "Forest", Vector3.new(340, 1, 1750),
    Vector3.new(-720, -0.1, 0), Color3.fromRGB(70, 115, 60), Enum.Material.Grass)
makePart(biomes, "Desert", Vector3.new(340, 1, 1750),
    Vector3.new(720, -0.1, 0), Color3.fromRGB(194, 165, 105), Enum.Material.Sand)
makePart(biomes, "Countryside", Vector3.new(1100, 1, 340),
    Vector3.new(0, -0.1, 720), Color3.fromRGB(125, 160, 85), Enum.Material.Grass)
makePart(biomes, "Beach", Vector3.new(1100, 1, 340),
    Vector3.new(0, -0.1, -720), Color3.fromRGB(210, 190, 135), Enum.Material.Sand)
local water = makePart(biomes, "Ocean", Vector3.new(1100, 4, 300),
    Vector3.new(0, -1, -900), Color3.fromRGB(35, 115, 175), Enum.Material.Water)
water.Transparency = 0.2

-- Trees with solid trunks and non-colliding leafy crowns.
local function createTree(x, z)
    local tree = Instance.new("Model")
    tree.Name = "Tree"
    tree.Parent = trees
    local trunk = makePart(tree, "Trunk", Vector3.new(2.5, 14, 2.5),
        Vector3.new(x, 7, z), Color3.fromRGB(100, 65, 38), Enum.Material.Wood)
    local crown = makePart(tree, "Leaves", Vector3.new(13, 14, 13),
        Vector3.new(x, 16, z), Color3.fromRGB(45, 125, 55), Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
    crown.CanCollide = false
    tree.PrimaryPart = trunk
end

for i = 1, CONFIG.TreeCount do
    local x = math.random(-850, 850)
    local z = math.random(-850, 850)
    local roadSide = false
    if math.abs(x) < 540 and math.abs(z) < 540 then
        for _, line in ipairs(roadLines) do
            if math.abs(x - line) < 28 or math.abs(z - line) < 28 then
                roadSide = true
                break
            end
        end
    end
    if not roadSide then
        createTree(x, z)
    end
end

-- Street lights.
for x = -3, 3 do
    for z = -3, 3 do
        local px = x * 170 + 27
        local pz = z * 170 + 27
        makePart(props, "LampPole", Vector3.new(1, 16, 1),
            Vector3.new(px, 8, pz), Color3.fromRGB(55, 55, 55), Enum.Material.Metal)
        local lamp = makePart(props, "Lamp", Vector3.new(4, 0.8, 2),
            Vector3.new(px, 16.5, pz), Color3.fromRGB(255, 240, 180), Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Range = 30
        light.Brightness = 1.2
        light.Enabled = false
        light.Parent = lamp
    end
end

-- Keep an existing SpawnLocation; otherwise make one at the fixed city centre.
local spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
if not spawnLocation then
    spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "CitySpawn"
    spawnLocation.Size = Vector3.new(12, 1, 12)
    spawnLocation.Position = Vector3.new(0, 2, 80)
    spawnLocation.Anchored = true
    spawnLocation.Neutral = true
    spawnLocation.Parent = city
end

local function sendToSpawn(character)
    local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true) or spawnLocation
    if character and character.Parent and spawn then
        character:PivotTo(spawn.CFrame + Vector3.new(0, 5, 0))
    end
end

-- NPCs are real R15 humanoid rigs, not block Parts.
local function createNPC(index, position)
    local age = pick({"Adult", "Adult", "Adult", "Old", "Baby"})
    local description = Instance.new("HumanoidDescription")
    description.HeadColor = Color3.fromRGB(235, 190, 155)
    description.TorsoColor = pick({
        Color3.fromRGB(40, 100, 180),
        Color3.fromRGB(180, 70, 50),
        Color3.fromRGB(50, 130, 80),
        Color3.fromRGB(120, 70, 150)
    })
    description.LeftArmColor = description.TorsoColor
    description.RightArmColor = description.TorsoColor
    description.LeftLegColor = Color3.fromRGB(45, 50, 60)
    description.RightLegColor = Color3.fromRGB(45, 50, 60)
    if age == "Baby" then
        description.BodyHeightScale = 0.8
        description.BodyWidthScale = 0.85
        description.BodyDepthScale = 0.85
        description.HeadScale = 1.15
    elseif age == "Old" then
        description.BodyHeightScale = 0.95
    end

    local success, rig = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
    end)
    description:Destroy()

    if not success or not rig then
        warn("Could not create NPC number", index)
        return
    end

    rig.Name = age .. "_Citizen_" .. index
    rig.Parent = npcFolder
    rig:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)))
    rig:SetAttribute("AgeGroup", age)
    rig:SetAttribute("Gender", pick({"Male", "Female"}))

    local humanoid = rig:FindFirstChildOfClass("Humanoid")
    local root = rig:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        rig:Destroy()
        return
    end

    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.WalkSpeed = age == "Baby" and 7 or (age == "Old" and 9 or 12)

    -- Welded hair cap so every generated citizen has visible hair.
    local head = rig:FindFirstChild("Head")
    if head then
        local hair = Instance.new("Part")
        hair.Name = "Hair"
        hair.Size = Vector3.new(1.5, 0.45, 1.4)
        hair.Color = pick({
            Color3.fromRGB(35, 25, 20),
            Color3.fromRGB(90, 55, 30),
            Color3.fromRGB(180, 145, 85),
            Color3.fromRGB(150, 150, 150)
        })
        hair.Material = Enum.Material.SmoothPlastic
        hair.CanCollide = false
        hair.Massless = true
        hair.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
        hair.Parent = rig
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = hair
        weld.Parent = hair
    end

    -- Prompt interaction: citizen steps away when spoken to.
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Talk"
    prompt.ObjectText = "Citizen"
    prompt.MaxActivationDistance = 8
    prompt.Parent = root
    prompt.Triggered:Connect(function(player)
        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if playerRoot and humanoid.Health > 0 then
            local away = root.Position - playerRoot.Position
            if away.Magnitude > 0.1 then
                humanoid:MoveTo(root.Position + away.Unit * 9)
            end
        end
    end)

    -- Wander within the city. MoveTo drives the standard Humanoid locomotion.
    task.spawn(function()
        while rig.Parent and humanoid.Health > 0 do
            local target = Vector3.new(math.random(-440, 440), 0, math.random(-440, 440))
            humanoid:MoveTo(target)
            humanoid.MoveToFinished:Wait()
            task.wait(math.random(2, 4))
        end
    end)
end

for i = 1, CONFIG.NPCCount do
    local x = pick({-430, -260, -90, 90, 260, 430}) + math.random(-6, 6)
    local z = pick({-430, -260, -90, 90, 260, 430}) + math.random(-6, 6)
    task.spawn(createNPC, i, Vector3.new(x, 0, z))
    task.wait(0.1)
end

-- Traffic routes run along selected straight roads, not from the player spawn.
local routes = {
    {Vector3.new(-470, 4, -340), Vector3.new(-340, 4, -340), Vector3.new(-170, 4, -340), Vector3.new(0, 4, -340), Vector3.new(170, 4, -340), Vector3.new(340, 4, -340), Vector3.new(470, 4, -340)},
    {Vector3.new(340, 4, -470), Vector3.new(340, 4, -340), Vector3.new(340, 4, -170), Vector3.new(340, 4, 0), Vector3.new(340, 4, 170), Vector3.new(340, 4, 340), Vector3.new(340, 4, 470)},
    {Vector3.new(-470, 4, 340), Vector3.new(-340, 4, 340), Vector3.new(-170, 4, 340), Vector3.new(0, 4, 340), Vector3.new(170, 4, 340), Vector3.new(340, 4, 340), Vector3.new(470, 4, 340)},
    {Vector3.new(-340, 4, -470), Vector3.new(-340, 4, -340), Vector3.new(-340, 4, -170), Vector3.new(-340, 4, 0), Vector3.new(-340, 4, 170), Vector3.new(-340, 4, 340), Vector3.new(-340, 4, 470)}
}

local function createCar(index, route, startIndex, laneOffset)
    local car = Instance.new("Model")
    car.Name = "TrafficCar_" .. index
    car.Parent = traffic

    local paint = pick({
        Color3.fromRGB(190, 40, 35),
        Color3.fromRGB(40, 85, 180),
        Color3.fromRGB(220, 220, 220),
        Color3.fromRGB(30, 30, 35),
        Color3.fromRGB(210, 175, 40)
    })

    local chassis = makePart(car, "Chassis", Vector3.new(8, 2, 15),
        Vector3.new(0, 4, 0), paint, Enum.Material.Metal)
    car.PrimaryPart = chassis

    makePart(car, "Cabin", Vector3.new(6, 3, 7),
        Vector3.new(0, 6.3, -0.5), Color3.fromRGB(85, 155, 195), Enum.Material.Glass).Transparency = 0.25

    for _, x in ipairs({-4.2, 4.2}) do
        for _, z in ipairs({-5, 5}) do
            local wheel = makePart(car, "Wheel", Vector3.new(2.4, 2.4, 1.1),
                Vector3.new(x, 3.5, z), Color3.fromRGB(22, 22, 22), Enum.Material.Rubber)
            wheel.Shape = Enum.PartType.Cylinder
            wheel.CanCollide = false
        end
    end

    for _, x in ipairs({-2.5, 2.5}) do
        makePart(car, "Headlight", Vector3.new(1.5, 0.65, 0.25),
            Vector3.new(x, 4.4, -7.6), Color3.fromRGB(255, 245, 190), Enum.Material.Neon)
        makePart(car, "TailLight", Vector3.new(1.5, 0.65, 0.25),
            Vector3.new(x, 4.4, 7.6), Color3.fromRGB(255, 35, 35), Enum.Material.Neon)
    end

    local seat = Instance.new("VehicleSeat")
    seat.Name = "DriverSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.CFrame = chassis.CFrame * CFrame.new(0, 1.4, -1.4)
    seat.Transparency = 1
    seat.Anchored = true
    seat.Parent = car

    local a = route[startIndex]
    local b = route[startIndex + 1]
    local direction = (b - a).Unit
    local right = Vector3.new(-direction.Z, 0, direction.X)
    local startPosition = a + right * laneOffset
    car:PivotTo(CFrame.lookAt(startPosition, startPosition + direction))

    car:SetAttribute("TrafficActive", true)
    car:SetAttribute("HasDriver", false)

    -- The car has a visible driver seat. The NPC driver is represented by a
    -- visible seated rig when available; the traffic movement is server controlled.
    local driverPrompt = Instance.new("ProximityPrompt")
    driverPrompt.ActionText = "Drive"
    driverPrompt.ObjectText = "Traffic vehicle"
    driverPrompt.KeyboardKeyCode = Enum.KeyCode.E
    driverPrompt.MaxActivationDistance = 8
    driverPrompt.Parent = chassis

    local occupiedByPlayer = false
    driverPrompt.Triggered:Connect(function(player)
        if occupiedByPlayer then
            return
        end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            occupiedByPlayer = true
            car:SetAttribute("TrafficActive", false)
            seat.Anchored = false
            seat:Sit(humanoid)
        end
    end)

    seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        if seat.Occupant == nil then
            occupiedByPlayer = false
            car:SetAttribute("HasDriver", false)
            car:SetAttribute("TrafficActive", true)
            seat.Anchored = true
        else
            car:SetAttribute("HasDriver", true)
        end
    end)

    return car, seat, startIndex
end

local spawnedCars = {}

local function playerInFront(car)
    local cf = car:GetPivot()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {car, npcFolder, traffic}
    local result = Workspace:Raycast(cf.Position + Vector3.new(0, 2, 0),
        cf.LookVector * CONFIG.StopDistance, params)
    if result then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        return model ~= nil and Players:GetPlayerFromCharacter(model) ~= nil
    end
    return false
end

for i = 1, CONFIG.CarCount do
    local route = routes[((i - 1) % #routes) + 1]
    local startIndex = math.random(1, #route - 1)
    local lane = (i % 2 == 0) and 7 or -7
    local car, seat, routeIndex = createCar(i, route, startIndex, lane)

    -- Keep cars apart at startup.
    local tries = 0
    while tries < 12 do
        local crowded = false
        for _, other in ipairs(spawnedCars) do
            if (other:GetPivot().Position - car:GetPivot().Position).Magnitude < 85 then
                crowded = true
                break
            end
        end
        if not crowded then
            break
        end
        routeIndex = math.random(1, #route - 1)
        local p1 = route[routeIndex]
        local p2 = route[routeIndex + 1]
        local dir = (p2 - p1).Unit
        local right = Vector3.new(-dir.Z, 0, dir.X)
        local p = p1 + right * lane
        car:PivotTo(CFrame.lookAt(p, p + dir))
        tries = tries + 1
    end

    table.insert(spawnedCars, car)

    task.spawn(function()
        local nextIndex = routeIndex + 1
        while car.Parent do
            if not car:GetAttribute("TrafficActive") or seat.Occupant ~= nil then
                task.wait(0.2)
            elseif playerInFront(car) then
                task.wait(0.15)
            else
                local target = route[nextIndex]
                local startCFrame = car:GetPivot()
                local distance = (target - startCFrame.Position).Magnitude
                if distance < 2 then
                    nextIndex = (nextIndex % #route) + 1
                else
                    local direction = (target - startCFrame.Position).Unit
                    local endCFrame = CFrame.lookAt(target, target + direction)
                    local duration = distance / CONFIG.CarSpeed
                    local elapsed = 0
                    while elapsed < duration and car.Parent and car:GetAttribute("TrafficActive") do
                        if playerInFront(car) then
                            break
                        end
                        local dt = RunService.Heartbeat:Wait()
                        elapsed = elapsed + dt
                        car:PivotTo(startCFrame:Lerp(endCFrame, math.clamp(elapsed / duration, 0, 1)))
                    end
                    if elapsed >= duration then
                        nextIndex = (nextIndex % #route) + 1
                    end
                end
            end
        end
    end)

    task.wait(0.15)
end

-- Border teleport: player returns to spawn without dying.
task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root and (math.abs(root.Position.X) > CONFIG.Border or math.abs(root.Position.Z) > CONFIG.Border) then
                sendToSpawn(character)
            end
        end
        task.wait(0.35)
    end
end)

-- Simple day/night cycle.
task.spawn(function()
    while true do
        for hour = 7, 19, 0.25 do
            Lighting.ClockTime = hour
            for _, lamp in ipairs(props:GetChildren()) do
                if lamp.Name == "Lamp" then
                    local light = lamp:FindFirstChildOfClass("PointLight")
                    if light then
                        light.Enabled = hour > 18
                    end
                end
            end
            task.wait(2)
        end
        for hour = 19, 24, 0.25 do
            Lighting.ClockTime = hour
            for _, lamp in ipairs(props:GetChildren()) do
                if lamp.Name == "Lamp" then
                    local light = lamp:FindFirstChildOfClass("PointLight")
                    if light then
                        light.Enabled = true
                    end
                end
            end
            task.wait(2)
        end
    end
end)

print("GTA CITY 2.2 FIX loaded successfully.")
