local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local toolbar = plugin:CreateToolbar("Jardim Premium")
local createBtn = toolbar:CreateButton("Criar Jardim", "Inicializa o sistema premium", "rbxassetid://7078459360")
local removeBtn = toolbar:CreateButton("Remover Jardim", "Remove todos os elementos", "rbxassetid://7078459887")

-- Função segura para criar instâncias
local function safeCreate(instanceType, props, parent)
    local success, result = pcall(function()
        local obj = Instance.new(instanceType)
        for prop, value in pairs(props) do
            obj[prop] = value
        end
        if parent then
            obj.Parent = parent
        end
        return obj
    end)
    
    if not success then
        warn("Erro ao criar instância: " .. result)
        return nil
    end
    return result
end

-- Tela de carregamento
local function createLoadingScreen()
    local loadingScreen = safeCreate("ScreenGui", {
        Name = "LoadingScreen",
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    }, StarterGui)
    
    local frame = safeCreate("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 20, 30),
        ZIndex = 10
    }, loadingScreen)
    
    local logo = safeCreate("ImageLabel", {
        Image = "rbxassetid://7078461234",
        Size = UDim2.new(0.3, 0, 0.15, 0),
        Position = UDim2.new(0.35, 0, 0.2, 0),
        BackgroundTransparency = 1,
        ZIndex = 11
    }, frame)
    
    local progressBar = safeCreate("Frame", {
        Size = UDim2.new(0.6, 0, 0.03, 0),
        Position = UDim2.new(0.2, 0, 0.6, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        ZIndex = 11
    }, frame)
    
    local progressFill = safeCreate("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 200, 100),
        ZIndex = 12
    }, progressBar)
    
    local statusLabel = safeCreate("TextLabel", {
        Text = "Inicializando...",
        Size = UDim2.new(1, 0, 0.05, 0),
        Position = UDim2.new(0, 0, 0.65, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.Gotham,
        TextSize = 20,
        ZIndex = 11
    }, frame)
    
    return {
        gui = loadingScreen,
        update = function(text, progress)
            statusLabel.Text = text
            progressFill.Size = UDim2.new(progress, 0, 1, 0)
        end
    }
end

-- Sistema de geração do mapa
local function createGardenMap()
    -- Área principal
    local gardenArea = safeCreate("Part", {
        Name = "GardenArea",
        Size = Vector3.new(200, 1, 200),
        Position = Vector3.new(0, 0, 0),
        Anchored = true,
        Color = Color3.fromRGB(34, 139, 34),
        Material = Enum.Material.Grass
    }, Workspace)
    
    -- Canteiros
    local plots = {}
    for x = -80, 80, 20 do
        for z = -80, 80, 20 do
            local plot = safeCreate("Part", {
                Name = "GardenPlot",
                Size = Vector3.new(10, 1, 10),
                Position = Vector3.new(x, 0.5, z),
                Anchored = true,
                Color = Color3.fromRGB(101, 67, 33),
                Material = Enum.Material.WoodPlanks
            }, Workspace)
            
            safeCreate("BoxHandleAdornment", {
                Size = Vector3.new(10.1, 0.2, 10.1),
                Color3 = Color3.new(0,1,0),
                Transparency = 0.7,
                Adornee = plot,
                AlwaysOnTop = true,
                ZIndex = 1
            }, plot)
            
            local prompt = safeCreate("ProximityPrompt", {
                ActionText = "Plantar",
                ObjectText = "Canteiro",
                HoldDuration = 1,
                MaxActivationDistance = 15
            }, plot)
            
            table.insert(plots, plot)
        end
    end
    
    -- Loja
    local shopStand = safeCreate("Part", {
        Name = "SeedShop",
        Size = Vector3.new(15, 10, 15),
        Position = Vector3.new(0, 5, 100),
        Anchored = true,
        Color = Color3.fromRGB(30, 144, 255),
        Material = Enum.Material.Neon
    }, Workspace)
    
    local shopSign = safeCreate("BillboardGui", {
        Size = UDim2.new(10, 0, 3, 0),
        Adornee = shopStand,
        AlwaysOnTop = true,
        ExtentsOffset = Vector3.new(0, 8, 0)
    }, shopStand)
    
    safeCreate("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        Text = "MERCADO PREMIUM",
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 28
    }, shopSign)
    
    local shopPrompt = safeCreate("ProximityPrompt", {
        ActionText = "Abrir Loja",
        ObjectText = "Loja de Sementes",
        HoldDuration = 0.5,
        MaxActivationDistance = 20
    }, shopStand)
    
    -- Decoração
    local function createTree(position)
        local trunk = safeCreate("Part", {
            Size = Vector3.new(3, 12, 3),
            Position = position + Vector3.new(0, 6, 0),
            Anchored = true,
            Color = Color3.fromRGB(101, 67, 33),
            Material = Enum.Material.Wood
        }, Workspace)
        
        local leaves = safeCreate("Part", {
            Size = Vector3.new(12, 12, 12),
            Position = position + Vector3.new(0, 18, 0),
            Anchored = true,
            Color = Color3.fromRGB(34, 139, 34),
            Shape = Enum.PartType.Ball,
            Material = Enum.Material.Grass
        }, Workspace)
    end
    
    createTree(Vector3.new(50, 0, 50))
    createTree(Vector3.new(-50, 0, 50))
    createTree(Vector3.new(50, 0, -50))
    createTree(Vector3.new(-50, 0, -50))
    
    -- Fonte central
    local fountain = safeCreate("Part", {
        Size = Vector3.new(15, 2, 15),
        Position = Vector3.new(0, 1, 0),
        Anchored = true,
        Color = Color3.fromRGB(200, 200, 200),
        Material = Enum.Material.Marble
    }, Workspace)
    
    local water = safeCreate("Part", {
        Size = Vector3.new(12, 1, 12),
        Position = Vector3.new(0, 2.5, 0),
        Anchored = true,
        Transparency = 0.5,
        Color = Color3.fromRGB(100, 200, 255),
        Material = Enum.Material.Water
    }, Workspace)
    
    return {
        plots = plots,
        shop = shopStand
    }
end

-- Configuração principal
local function createGardenConfig()
    return safeCreate("ModuleScript", {
        Name = "GardenConfig",
        Source = [[
            return {
                AdminIDs = {3624250826, 2394709675},
                SeedRarities = {
                    Common = {chance = 50, valueMultiplier = 1.0},
                    Uncommon = {chance = 30, valueMultiplier = 1.5},
                    Rare = {chance = 12, valueMultiplier = 2.0},
                    Epic = {chance = 5, valueMultiplier = 3.0},
                    Legendary = {chance = 2, valueMultiplier = 5.0},
                    Event = {chance = 1, valueMultiplier = 10.0, hidden = true},
                    Impossible = {chance = 0, valueMultiplier = 25.0, hidden = true}
                },
                SeedData = {
                    ["Cenoura"] = {price = 5, rarity = "Common", yieldTime = 20, color = Color3.fromRGB(255, 127, 0), baseValue = 15},
                    ["Maçã"] = {price = 15, rarity = "Common", yieldTime = 30, color = Color3.fromRGB(255, 0, 0), baseValue = 45},
                    ["Banana"] = {price = 20, rarity = "Common", yieldTime = 40, color = Color3.fromRGB(255, 255, 0), baseValue = 60},
                    ["Laranja"] = {price = 25, rarity = "Common", yieldTime = 45, color = Color3.fromRGB(255, 165, 0), baseValue = 75},
                    ["Uva"] = {price = 30, rarity = "Common", yieldTime = 50, color = Color3.fromRGB(128, 0, 128), baseValue = 90},
                    ["Morango"] = {price = 35, rarity = "Common", yieldTime = 55, color = Color3.fromRGB(255, 0, 0), baseValue = 105},
                    ["Pêssego"] = {price = 50, rarity = "Uncommon", yieldTime = 60, color = Color3.fromRGB(255, 218, 185), baseValue = 150},
                    ["Pera"] = {price = 60, rarity = "Uncommon", yieldTime = 65, color = Color3.fromRGB(173, 255, 47), baseValue = 180},
                    ["Cereja"] = {price = 70, rarity = "Uncommon", yieldTime = 70, color = Color3.fromRGB(220, 20, 60), baseValue = 210},
                    ["Limão"] = {price = 80, rarity = "Uncommon", yieldTime = 75, color = Color3.fromRGB(255, 255, 0), baseValue = 240},
                    ["Manga"] = {price = 90, rarity = "Uncommon", yieldTime = 80, color = Color3.fromRGB(255, 165, 0), baseValue = 270},
                    ["Abacaxi"] = {price = 120, rarity = "Rare", yieldTime = 85, color = Color3.fromRGB(173, 255, 47), baseValue = 360},
                    ["Melancia"] = {price = 150, rarity = "Rare", yieldTime = 90, color = Color3.fromRGB(0, 100, 0), baseValue = 450},
                    ["Kiwi"] = {price = 180, rarity = "Rare", yieldTime = 95, color = Color3.fromRGB(127, 255, 0), baseValue = 540},
                    ["Coco"] = {price = 200, rarity = "Rare", yieldTime = 100, color = Color3.fromRGB(150, 75, 0), baseValue = 600},
                    ["Framboesa"] = {price = 220, rarity = "Rare", yieldTime = 105, color = Color3.fromRGB(227, 11, 92), baseValue = 660},
                    ["Fruta Dragão"] = {price = 350, rarity = "Epic", yieldTime = 150, color = Color3.fromRGB(255, 105, 180), baseValue = 1050},
                    ["Fruta Dourada"] = {price = 500, rarity = "Epic", yieldTime = 180, color = Color3.fromRGB(255, 215, 0), baseValue = 1500},
                    ["Fruta Cristal"] = {price = 600, rarity = "Epic", yieldTime = 200, color = Color3.fromRGB(173, 216, 230), baseValue = 1800},
                    ["Fruta Arco-Íris"] = {price = 750, rarity = "Epic", yieldTime = 220, color = Color3.fromRGB(255, 255, 255), baseValue = 2250},
                    ["Fruta Galáctica"] = {price = 1000, rarity = "Epic", yieldTime = 250, color = Color3.fromRGB(25, 25, 112), baseValue = 3000},
                    ["Semente Antiga"] = {price = 1500, rarity = "Legendary", yieldTime = 300, color = Color3.fromRGB(205, 127, 50), baseValue = 4500},
                    ["Fruta Fênix"] = {price = 2000, rarity = "Legendary", yieldTime = 350, color = Color3.fromRGB(255, 69, 0), baseValue = 6000},
                    ["Fruta Titã"] = {price = 3000, rarity = "Legendary", yieldTime = 400, color = Color3.fromRGB(192, 192, 192), baseValue = 9000},
                    ["Fruta Nebulosa"] = {price = 5000, rarity = "Legendary", yieldTime = 450, color = Color3.fromRGB(138, 43, 226), baseValue = 15000},
                    ["Fruta Infinita"] = {price = 10000, rarity = "Legendary", yieldTime = 500, color = Color3.fromRGB(0, 0, 0), baseValue = 30000}
                },
                Mutations = {
                    RGB = {multiplier = 25, chance = 0.01, color = Color3.new(1,0,1)},
                    Gold = {multiplier = 35, chance = 0.005, color = Color3.new(1,0.8,0)},
                    Giant = {multiplier = 5, chance = 0.02, sizeMultiplier = 1.8},
                    Shiny = {multiplier = 15, chance = 0.01, sparkles = true},
                    Crystal = {multiplier = 45, chance = 0.002, transparency = 0.5},
                    Rainbow = {multiplier = 55, chance = 0.001, rainbow = true},
                    Galaxy = {multiplier = 75, chance = 0.0005, particles = true},
                    Diamond = {multiplier = 100, chance = 0, adminOnly = true, material = Enum.Material.Diamond},
                    Void = {multiplier = 150, chance = 0, adminOnly = true, color = Color3.new(0,0,0)},
                    Angelic = {multiplier = 200, chance = 0, adminOnly = true, glow = true},
                    Cosmic = {multiplier = 300, chance = 0, adminOnly = true, particles = true, glow = true},
                    Divine = {multiplier = 500, chance = 0, adminOnly = true, rainbow = true, glow = true}
                },
                Tools = {
                    ["Regador Básico"] = {price = 50, effect = "growth_speed1.2"},
                    ["Regador Avançado"] = {price = 150, effect = "growth_speed1.5"},
                    ["Fertilizante"] = {price = 100, effect = "mutation2x"},
                    ["Luvas Mágicas"] = {price = 200, effect = "size1.5x"},
                    ["Tesoura Dourada"] = {price = 300, effect = "value1.3x"},
                    ["Colheitadeira 3000"] = {price = 500, effect = "auto_harvest"},
                    ["Amuleto da Sorte"] = {price = 250, effect = "luck2x"},
                    ["Distorcedor Temporal"] = {price = 400, effect = "time_warp"},
                    ["Kit Premium"] = {price = 150, effect = "premium_benefits", premium = true},
                    ["Regador Dourado"] = {price = 300, effect = "growth_speed2.0", premium = true},
                    ["Fertilizante Premium"] = {price = 200, effect = "mutation4x", premium = true}
                },
                PremiumBenefits = {
                    growthSpeed = 1.5,
                    mutationChance = 3.0,
                    extraMoney = 0.3,
                    exclusiveSeeds = {"Fruta Dourada", "Fruta Cristal"}
                },
                ShopResetTime = 300,
                StealPrice = 35,
                MaxSize = 3.5,
                ShopStockChance = {
                    Common = 1.0,
                    Uncommon = 0.8,
                    Rare = 0.6,
                    Epic = 0.4,
                    Legendary = 0.2
                },
                NotificationDuration = 5
            }
        ]]
    }, ReplicatedStorage)
end

-- Módulo de utilidades
local function createGardenUtils()
    return safeCreate("ModuleScript", {
        Name = "GardenUtils",
        Source = [[
            local TweenService = game:GetService("TweenService")
            local GardenConfig = require(script.Parent.GardenConfig)
            
            local module = {}
            
            function module.calculateYield(seed, size, mutations, isPremium)
                local seedData = GardenConfig.SeedData[seed]
                if not seedData then return 0 end
                
                local rarityMultiplier = GardenConfig.SeedRarities[seedData.rarity].valueMultiplier
                local baseValue = seedData.baseValue * rarityMultiplier
                
                local sizeBonus = 1 + (size - 1) * 1.5
                local value = baseValue * sizeBonus
                
                if mutations then
                    for _, mutation in ipairs(mutations) do
                        if GardenConfig.Mutations[mutation] then
                            value = value * GardenConfig.Mutations[mutation].multiplier
                        end
                    end
                end
                
                -- Benefícios Premium
                if isPremium then
                    value = value * (1 + GardenConfig.PremiumBenefits.extraMoney)
                end
                
                return math.floor(value)
            end
            
            function module.createPlantModel(seed, size, mutations)
                local plant = Instance.new("Model")
                plant.Name = seed
                
                -- Caule
                local stem = Instance.new("Part")
                stem.Name = "Stem"
                stem.Size = Vector3.new(0.5, 3 * size, 0.5)
                stem.BrickColor = BrickColor.new("Bright green")
                stem.Position = Vector3.new(0, 1.5 * size, 0)
                stem.Anchored = true
                stem.CanCollide = true
                stem.Material = Enum.Material.Wood
                stem.Parent = plant
                
                -- Fruta
                local fruit = Instance.new("Part")
                fruit.Name = "Fruit"
                fruit.Shape = Enum.PartType.Ball
                fruit.Size = Vector3.new(1.5 * size, 1.5 * size, 1.5 * size)
                fruit.Position = stem.Position + Vector3.new(0, stem.Size.Y/2 + fruit.Size.Y/2, 0)
                fruit.Anchored = true
                fruit.CanCollide = false
                fruit.Color = GardenConfig.SeedData[seed].color
                fruit.Material = Enum.Material.Neon
                
                -- Aplicar mutações
                if mutations then
                    for _, mutation in ipairs(mutations) do
                        local mutData = GardenConfig.Mutations[mutation]
                        if mutData then
                            if mutData.sizeMultiplier then
                                fruit.Size = fruit.Size * mutData.sizeMultiplier
                            end
                            
                            if mutData.color then
                                fruit.Color = mutData.color
                            end
                            
                            if mutData.material then
                                fruit.Material = mutData.material
                            end
                            
                            if mutData.transparency then
                                fruit.Transparency = mutData.transparency
                            end
                            
                            if mutData.glow then
                                local light = Instance.new("PointLight")
                                light.Color = Color3.new(1,1,0.8)
                                light.Range = 15
                                light.Brightness = 2
                                light.Parent = fruit
                            end
                        end
                    end
                end
                
                fruit.Parent = plant
                
                -- Folhas
                local leaves = Instance.new("Part")
                leaves.Name = "Leaves"
                leaves.Shape = Enum.PartType.Ball
                leaves.Size = Vector3.new(2 * size, 0.5 * size, 2 * size)
                leaves.Position = fruit.Position - Vector3.new(0, fruit.Size.Y/2 + leaves.Size.Y/2, 0)
                leaves.BrickColor = BrickColor.new("Lime green")
                leaves.Transparency = 0.3
                leaves.Anchored = true
                leaves.CanCollide = false
                leaves.Parent = plant
                
                -- Informações da planta
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "PlantInfo"
                billboard.Size = UDim2.new(6, 0, 2, 0)
                billboard.Adornee = fruit
                billboard.AlwaysOnTop = true
                billboard.ExtentsOffset = Vector3.new(0, 3, 0)
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0.4, 0)
                label.BackgroundTransparency = 1
                label.Text = seed
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 18
                label.TextColor3 = Color3.new(1,1,1)
                label.Parent = billboard
                
                if mutations and #mutations > 0 then
                    local mutationLabel = label:Clone()
                    mutationLabel.Text = "Mutações: " .. table.concat(mutations, ", ")
                    mutationLabel.Position = UDim2.new(0, 0, 0.4, 0)
                    mutationLabel.Size = UDim2.new(1, 0, 0.3, 0)
                    mutationLabel.TextColor3 = Color3.new(1, 0.8, 0.5)
                    mutationLabel.TextSize = 16
                    mutationLabel.Parent = billboard
                end
                
                local value = module.calculateYield(seed, size, mutations)
                local valueLabel = label:Clone()
                valueLabel.Text = "Valor: $" .. value
                valueLabel.Position = UDim2.new(0, 0, 0.7, 0)
                valueLabel.Size = UDim2.new(1, 0, 0.3, 0)
                valueLabel.TextColor3 = Color3.new(0.5, 1, 0.5)
                valueLabel.Parent = billboard
                
                billboard.Parent = plant
                
                -- Prompt para colheita
                local prompt = Instance.new("ProximityPrompt")
                prompt.Name = "HarvestPrompt"
                prompt.ActionText = "Colher"
                prompt.ObjectText = seed
                prompt.HoldDuration = 1.5
                prompt.Parent = fruit
                
                return plant, value
            end
            
            function module.generateShopStock()
                local stock = {}
                for seed, data in pairs(GardenConfig.SeedData) do
                    if not data.hidden and not data.robux then
                        local rarityData = GardenConfig.SeedRarities[data.rarity]
                        if rarityData and math.random() <= (GardenConfig.ShopStockChance[data.rarity] or 1) then
                            table.insert(stock, seed)
                        end
                    end
                end
                return stock
            end
            
            return module
        ]]
    }, ReplicatedStorage)
end

-- Script principal do servidor
local function createGardenMain()
    return safeCreate("Script", {
        Name = "GardenMain",
        Source = [[
            local DataStoreService = game:GetService("DataStoreService")
            local Players = game:GetService("Players")
            local GardenConfig = require(game.ReplicatedStorage:WaitForChild("GardenConfig"))
            local GardenUtils = require(game.ReplicatedStorage:WaitForChild("GardenUtils"))
            local MarketplaceService = game:GetService("MarketplaceService")
            
            local Gardens = Instance.new("Folder")
            Gardens.Name = "Gardens"
            Gardens.Parent = workspace
            
            local Remotes = Instance.new("Folder")
            Remotes.Name = "GardenRemotes"
            Remotes.Parent = game.ReplicatedStorage
            
            local function createRemote(name)
                local remote = Instance.new("RemoteEvent")
                remote.Name = name
                remote.Parent = Remotes
                return remote
            end
            
            local PlantSeed = createRemote("PlantSeed")
            local HarvestFruit = createRemote("HarvestFruit")
            local BuySeed = createRemote("BuySeed")
            local SellFruit = createRemote("SellFruit")
            local BuyTool = createRemote("BuyTool")
            local ShopReset = createRemote("ShopReset")
            local UpdateUI = createRemote("UpdateUI")
            local NotifyPlayer = createRemote("NotifyPlayer")
            local OpenShop = createRemote("OpenShop")
            
            local GardenStore = DataStoreService:GetDataStore("GardenDataV2")
            local shopStock = GardenUtils.generateShopStock()
            local lastReset = os.time()
            local playerData = {}
            
            local function resetShop()
                shopStock = GardenUtils.generateShopStock()
                ShopReset:FireAllClients(shopStock)
                lastReset = os.time()
            end
            
            coroutine.wrap(function()
                while true do
                    wait(5)
                    if os.time() - lastReset >= GardenConfig.ShopResetTime then
                        resetShop()
                    end
                end
            end)()
            
            local function setupPlayer(player)
                local data
                local success, err = pcall(function()
                    data = GardenStore:GetAsync(player.UserId)
                end)
                
                if not success then warn("Data error: "..err) end
                
                if not data then
                    data = {
                        money = 500,
                        seeds = {["Cenoura"] = 5},
                        tools = {},
                        garden = {},
                        fruits = {},
                        isPremium = false
                    }
                end
                
                playerData[player] = data
                player:SetAttribute("Money", data.money)
                player:SetAttribute("Premium", data.isPremium)
                
                local playerGarden = Instance.new("Folder")
                playerGarden.Name = player.UserId
                playerGarden.Parent = Gardens
                
                for _, plantData in ipairs(data.garden) do
                    local plant, value = GardenUtils.createPlantModel(plantData.seed, plantData.size, plantData.mutations)
                    plant:SetAttribute("Owner", player.UserId)
                    plant:SetAttribute("Value", value)
                    plant:SetAttribute("Size", plantData.size)
                    plant:SetAttribute("Mutations", plantData.mutations)
                    plant.PrimaryPart = plant:FindFirstChild("Fruit") or plant:FindFirstChildWhichIsA("Part")
                    plant:SetPrimaryPartCFrame(plantData.position)
                    plant.Parent = playerGarden
                    
                    local prompt = plant.PrimaryPart:FindFirstChild("HarvestPrompt")
                    if prompt then
                        prompt.Triggered:Connect(function(harvester)
                            if harvester == player then
                                HarvestFruit:FireClient(player, plant)
                            end
                        end)
                    end
                end
                
                NotifyPlayer:FireClient(player, "Bem-vindo ao Jardim Premium!", Color3.new(0, 1, 0))
                ShopReset:FireClient(player, shopStock)
            end
            
            local function savePlayer(player)
                local data = playerData[player]
                if not data then return end
                
                data.garden = {}
                local playerGarden = Gardens:FindFirstChild(player.UserId)
                if playerGarden then
                    for _, plant in ipairs(playerGarden:GetChildren()) do
                        if plant:IsA("Model") then
                            table.insert(data.garden, {
                                seed = plant.Name,
                                position = plant:GetPrimaryPartCFrame(),
                                size = plant:GetAttribute("Size"),
                                mutations = plant:GetAttribute("Mutations")
                            })
                        end
                    end
                end
                
                pcall(function()
                    GardenStore:SetAsync(player.UserId, data)
                end)
            end
            
            Players.PlayerAdded:Connect(function(player)
                setupPlayer(player)
                UpdateUI:FireClient(player)
            end)
            
            Players.PlayerRemoving:Connect(savePlayer)
            
            game:BindToClose(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    savePlayer(player)
                end
            end)
            
            -- Abrir shop quando interagir com a loja
            OpenShop.OnServerEvent:Connect(function(player)
                OpenShop:FireClient(player)
            end)
            
            PlantSeed.OnServerEvent:Connect(function(player, seedType, position)
                local data = playerData[player]
                if not data then return end
                
                if data.seeds[seedType] and data.seeds[seedType] > 0 then
                    data.seeds[seedType] = data.seeds[seedType] - 1
                    
                    local size = 1 + (math.random() * (GardenConfig.MaxSize - 1))
                    local mutationChance = 1.0
                    
                    -- Benefícios Premium
                    if data.isPremium then
                        mutationChance = mutationChance * GardenConfig.PremiumBenefits.mutationChance
                    end
                    
                    for _, tool in ipairs(data.tools) do
                        if tool == "Fertilizante" or tool == "Fertilizante Premium" then
                            mutationChance = mutationChance * 2
                        end
                        if tool == "Amuleto da Sorte" then
                            mutationChance = mutationChance * 2
                        end
                    end
                    
                    local mutations = {}
                    for mutName, mutData in pairs(GardenConfig.Mutations) do
                        if not mutData.adminOnly and math.random() < (mutData.chance * mutationChance) then
                            table.insert(mutations, mutName)
                        end
                    end
                    
                    local positionCF = CFrame.new(position.X, position.Y + 1, position.Z)
                    local plant, value = GardenUtils.createPlantModel(seedType, size, mutations)
                    
                    table.insert(data.garden, {
                        seed = seedType,
                        position = positionCF,
                        size = size,
                        mutations = mutations
                    })
                    
                    local playerGarden = Gardens:FindFirstChild(player.UserId)
                    if playerGarden then
                        plant:SetAttribute("Owner", player.UserId)
                        plant:SetAttribute("Value", value)
                        plant:SetAttribute("Size", size)
                        plant:SetAttribute("Mutations", mutations)
                        plant.PrimaryPart = plant:FindFirstChild("Fruit") or plant:FindFirstChildWhichIsA("Part")
                        plant:SetPrimaryPartCFrame(positionCF)
                        plant.Parent = playerGarden
                        
                        local prompt = plant.PrimaryPart:FindFirstChild("HarvestPrompt")
                        if prompt then
                            prompt.Triggered:Connect(function(harvester)
                                if harvester == player then
                                    HarvestFruit:FireClient(player, plant)
                                end
                            end)
                        end
                    end
                    
                    UpdateUI:FireClient(player)
                    NotifyPlayer:FireClient(player, "Semente de " .. seedType .. " plantada!", Color3.new(0, 1, 0))
                else
                    NotifyPlayer:FireClient(player, "Você não tem sementes de " .. seedType, Color3.new(1, 0.5, 0.5))
                end
            end)
            
            HarvestFruit.OnServerEvent:Connect(function(player, plant)
                local ownerId = plant:GetAttribute("Owner")
                if ownerId ~= player.UserId then return end
                
                local data = playerData[player]
                if not data then return end
                
                table.insert(data.fruits, {
                    seed = plant.Name,
                    size = plant:GetAttribute("Size"),
                    mutations = plant:GetAttribute("Mutations"),
                    value = plant:GetAttribute("Value")
                })
                
                for i, plantData in ipairs(data.garden) do
                    if (plantData.position.Position - plant:GetPrimaryPartCFrame().Position).Magnitude < 1 then
                        table.remove(data.garden, i)
                        break
                    end
                end
                
                plant:Destroy()
                UpdateUI:FireClient(player)
                NotifyPlayer:FireClient(player, "Colheita realizada! Valor: $" .. plant:GetAttribute("Value"), Color3.new(1, 0.8, 0))
            end)
            
            BuySeed.OnServerEvent:Connect(function(player, seedType)
                local data = playerData[player]
                if not data then return end
                
                local seedData = GardenConfig.SeedData[seedType]
                if not seedData then return end
                
                if data.money >= seedData.price then
                    data.money = data.money - seedData.price
                    data.seeds[seedType] = (data.seeds[seedType] or 0) + 1
                    player:SetAttribute("Money", data.money)
                    UpdateUI:FireClient(player)
                    NotifyPlayer:FireClient(player, "Compra realizada: " .. seedType, Color3.new(0.5, 1, 0.5))
                else
                    NotifyPlayer:FireClient(player, "Dinheiro insuficiente!", Color3.new(1, 0.5, 0.5))
                end
            end)
            
            BuyTool.OnServerEvent:Connect(function(player, toolName)
                local data = playerData[player]
                if not data then return end
                
                local toolData = GardenConfig.Tools[toolName]
                if not toolData then return end
                
                if data.money >= toolData.price then
                    data.money = data.money - toolData.price
                    table.insert(data.tools, toolName)
                    player:SetAttribute("Money", data.money)
                    UpdateUI:FireClient(player)
                    NotifyPlayer:FireClient(player, "Ferramenta comprada: " .. toolName, Color3.new(0.5, 1, 0.5))
                    
                    -- Ativar benefícios premium
                    if toolName == "Kit Premium" then
                        data.isPremium = true
                        player:SetAttribute("Premium", true)
                        NotifyPlayer:FireClient(player, "Benefícios Premium ativados!", Color3.new(1, 0.8, 0))
                    end
                else
                    NotifyPlayer:FireClient(player, "Dinheiro insuficiente!", Color3.new(1, 0.5, 0.5))
                end
            end)
            
            SellFruit.OnServerEvent:Connect(function(player, fruitIndex)
                local data = playerData[player]
                if not data or not data.fruits or not data.fruits[fruitIndex] then return end
                
                local fruit = data.fruits[fruitIndex]
                data.money = data.money + fruit.value
                table.remove(data.fruits, fruitIndex)
                player:SetAttribute("Money", data.money)
                UpdateUI:FireClient(player)
                NotifyPlayer:FireClient(player, "Fruta vendida por $" .. fruit.value, Color3.new(0.5, 1, 0.5))
            end)
        ]]
    }, game.ServerScriptService)
end

-- Interface do usuário
local function createPlayerUI()
    local PlayerUI = safeCreate("ScreenGui", {
        Name = "GardenUI",
        ResetOnSpawn = false
    }, StarterGui)
    
    -- Notificações
    local notificationFrame = safeCreate("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0.3, 0, 0.15, 0),
        Position = UDim2.new(0.7, 0, 0.05, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, PlayerUI)
    
    safeCreate("TextLabel", {
        Name = "NotificationTemplate",
        Size = UDim2.new(1, 0, 0.2, 0),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextWrapped = true,
        Visible = false
    }, notificationFrame)
    
    -- UI Principal
    local mainFrame = safeCreate("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0.5, 0, 0.7, 0),
        Position = UDim2.new(0.25, 0, 0.15, 0),
        BackgroundColor3 = Color3.fromRGB(40, 100, 60),
        BackgroundTransparency = 0.2,
        Visible = false,
        Active = true,
        Draggable = true
    }, PlayerUI)
    
    local moneyLabel = safeCreate("TextLabel", {
        Name = "MoneyLabel",
        Text = "Dinheiro: $500",
        Size = UDim2.new(0.25, 0, 0.05, 0),
        Position = UDim2.new(0.75, 0, 0.95, 0),
        BackgroundColor3 = Color3.fromRGB(30, 80, 40),
        BackgroundTransparency = 0.3,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 18
    }, PlayerUI)
    
    -- Abas
    local tabFrame = safeCreate("Frame", {
        Size = UDim2.new(1, 0, 0.1, 0),
        BackgroundColor3 = Color3.fromRGB(30, 80, 40)
    }, mainFrame)
    
    local seedsTab = safeCreate("TextButton", {
        Text = "Sementes",
        Size = UDim2.new(0.25, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 100, 60),
        TextColor3 = Color3.new(1,1,1)
    }, tabFrame)
    
    local toolsTab = safeCreate("TextButton", {
        Text = "Ferramentas",
        Size = UDim2.new(0.25, 0, 1, 0),
        Position = UDim2.new(0.25, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 100, 60),
        TextColor3 = Color3.new(1,1,1)
    }, tabFrame)
    
    local premiumTab = safeCreate("TextButton", {
        Text = "Premium",
        Size = UDim2.new(0.25, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 100, 60),
        TextColor3 = Color3.new(1,1,1)
    }, tabFrame)
    
    -- Painéis de conteúdo
    local contentFrame = safeCreate("Frame", {
        Size = UDim2.new(1, 0, 0.9, 0),
        Position = UDim2.new(0, 0, 0.1, 0),
        BackgroundTransparency = 1
    }, mainFrame)
    
    -- Painel de sementes
    local seedsFrame = safeCreate("Frame", {
        Name = "SeedsFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = true
    }, contentFrame)
    
    local seedsScroller = safeCreate("ScrollingFrame", {
        Name = "SeedsScroller",
        Size = UDim2.new(0.95, 0, 0.9, 0),
        Position = UDim2.new(0.025, 0, 0.05, 0),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 5
    }, seedsFrame)
    
    -- Painel de ferramentas
    local toolsFrame = safeCreate("Frame", {
        Name = "ToolsFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    }, contentFrame)
    
    local toolsScroller = safeCreate("ScrollingFrame", {
        Name = "ToolsScroller",
        Size = UDim2.new(0.95, 0, 0.9, 0),
        Position = UDim2.new(0.025, 0, 0.05, 0),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 5
    }, toolsFrame)
    
    -- Painel premium
    local premiumFrame = safeCreate("Frame", {
        Name = "PremiumFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    }, contentFrame)
    
    safeCreate("TextLabel", {
        Name = "PremiumLabel",
        Text = "BENEFÍCIOS PREMIUM",
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 215, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 24
    }, premiumFrame)
    
    -- Script da UI
    local UIScript = safeCreate("LocalScript", {
        Name = "UIScript",
        Source = [[
            local Player = game.Players.LocalPlayer
            local PlayerGui = Player:WaitForChild("PlayerGui")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local GardenRemotes = ReplicatedStorage:WaitForChild("GardenRemotes")
            local UpdateUI = GardenRemotes:WaitForChild("UpdateUI")
            local ShopReset = GardenRemotes:WaitForChild("ShopReset")
            local NotifyPlayer = GardenRemotes:WaitForChild("NotifyPlayer")
            local OpenShop = GardenRemotes:WaitForChild("OpenShop")
            local GardenConfig = require(ReplicatedStorage:WaitForChild("GardenConfig"))
            
            local ui = PlayerGui:WaitForChild("GardenUI")
            local mainFrame = ui:WaitForChild("MainFrame")
            local moneyLabel = ui:WaitForChild("MoneyLabel")
            local notificationFrame = ui:WaitForChild("Notifications")
            
            -- Elementos das abas
            local seedsFrame = mainFrame:WaitForChild("ContentFrame"):WaitForChild("SeedsFrame")
            local toolsFrame = mainFrame:WaitForChild("ContentFrame"):WaitForChild("ToolsFrame")
            local premiumFrame = mainFrame:WaitForChild("ContentFrame"):WaitForChild("PremiumFrame")
            
            local seedsScroller = seedsFrame:WaitForChild("SeedsScroller")
            local toolsScroller = toolsFrame:WaitForChild("ToolsScroller")
            
            -- Sistema de notificações
            local function showNotification(text, color)
                local template = notificationFrame:FindFirstChild("NotificationTemplate")
                if not template then return end
                
                local notification = template:Clone()
                notification.Text = text
                notification.BackgroundColor3 = color
                notification.Visible = true
                notification.Position = UDim2.new(1, 0, 0, 0)
                notification.Parent = notificationFrame
                
                local tweenIn = game:GetService("TweenService"):Create(
                    notification,
                    TweenInfo.new(0.5),
                    {Position = UDim2.new(0, 0, 0, 0)}
                )
                
                local tweenOut = game:GetService("TweenService"):Create(
                    notification,
                    TweenInfo.new(0.5, {delay = GardenConfig.NotificationDuration}),
                    {Position = UDim2.new(-1, 0, 0, 0)}
                )
                
                tweenIn:Play()
                tweenIn.Completed:Wait()
                
                wait(GardenConfig.NotificationDuration)
                
                tweenOut:Play()
                tweenOut.Completed:Connect(function()
                    notification:Destroy()
                end)
            end
            
            NotifyPlayer.OnClientEvent:Connect(showNotification)
            
            -- Função para criar botões de semente
            local function createSeedButton(seedType, yOffset)
                local seedData = GardenConfig.SeedData[seedType]
                if not seedData then return end
                
                local seedFrame = Instance.new("Frame")
                seedFrame.Size = UDim2.new(1, -10, 0, 70)
                seedFrame.Position = UDim2.new(0, 5, 0, yOffset)
                seedFrame.BackgroundTransparency = 0.8
                seedFrame.BackgroundColor3 = Color3.fromRGB(50, 80, 60)
                seedFrame.Parent = seedsScroller
                
                local seedIcon = Instance.new("ImageLabel")
                seedIcon.Size = UDim2.new(0.15, 0, 0.8, 0)
                seedIcon.Position = UDim2.new(0.05, 0, 0.1, 0)
                seedIcon.BackgroundTransparency = 1
                seedIcon.Image = "rbxassetid://7078465678"
                seedIcon.Parent = seedFrame
                
                local seedName = Instance.new("TextLabel")
                seedName.Text = seedType
                seedName.Size = UDim2.new(0.5, 0, 0.4, 0)
                seedName.Position = UDim2.new(0.2, 0, 0.1, 0)
                seedName.TextColor3 = Color3.new(1,1,1)
                seedName.Font = Enum.Font.GothamBold
                seedName.TextSize = 18
                seedName.BackgroundTransparency = 1
                seedName.Parent = seedFrame
                
                local seedPrice = Instance.new("TextLabel")
                seedPrice.Text = "Preço: $" .. seedData.price
                seedPrice.Size = UDim2.new(0.3, 0, 0.4, 0)
                seedPrice.Position = UDim2.new(0.2, 0, 0.5, 0)
                seedPrice.TextColor3 = Color3.new(1,1,0.5)
                seedPrice.Font = Enum.Font.Gotham
                seedPrice.TextSize = 16
                seedPrice.BackgroundTransparency = 1
                seedPrice.Parent = seedFrame
                
                local buyBtn = Instance.new("TextButton")
                buyBtn.Text = "COMPRAR"
                buyBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
                buyBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
                buyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
                buyBtn.TextColor3 = Color3.new(1,1,1)
                buyBtn.Font = Enum.Font.GothamBold
                buyBtn.TextSize = 16
                buyBtn.Parent = seedFrame
                
                buyBtn.MouseButton1Click:Connect(function()
                    GardenRemotes.BuySeed:FireServer(seedType)
                end)
                
                return seedFrame
            end
            
            -- Função para criar botões de ferramenta
            local function createToolButton(toolName, yOffset)
                local toolData = GardenConfig.Tools[toolName]
                if not toolData then return end
                
                local toolFrame = Instance.new("Frame")
                toolFrame.Size = UDim2.new(1, -10, 0, 70)
                toolFrame.Position = UDim2.new(0, 5, 0, yOffset)
                toolFrame.BackgroundTransparency = 0.8
                toolFrame.BackgroundColor3 = Color3.fromRGB(60, 70, 100)
                toolFrame.Parent = toolsScroller
                
                local toolIcon = Instance.new("ImageLabel")
                toolIcon.Size = UDim2.new(0.15, 0, 0.8, 0)
                toolIcon.Position = UDim2.new(0.05, 0, 0.1, 0)
                toolIcon.BackgroundTransparency = 1
                toolIcon.Image = "rbxassetid://7078467890"
                toolIcon.Parent = toolFrame
                
                local toolNameLabel = Instance.new("TextLabel")
                toolNameLabel.Text = toolName
                toolNameLabel.Size = UDim2.new(0.5, 0, 0.4, 0)
                toolNameLabel.Position = UDim2.new(0.2, 0, 0.1, 0)
                toolNameLabel.TextColor3 = Color3.new(1,1,1)
                toolNameLabel.Font = Enum.Font.GothamBold
                toolNameLabel.TextSize = 18
                toolNameLabel.BackgroundTransparency = 1
                toolNameLabel.Parent = toolFrame
                
                local toolPrice = Instance.new("TextLabel")
                toolPrice.Text = "Preço: $" .. toolData.price
                toolPrice.Size = UDim2.new(0.3, 0, 0.4, 0)
                toolPrice.Position = UDim2.new(0.2, 0, 0.5, 0)
                toolPrice.TextColor3 = Color3.new(1,1,0.5)
                toolPrice.Font = Enum.Font.Gotham
                toolPrice.TextSize = 16
                toolPrice.BackgroundTransparency = 1
                toolPrice.Parent = toolFrame
                
                local buyBtn = Instance.new("TextButton")
                buyBtn.Text = "COMPRAR"
                buyBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
                buyBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
                buyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
                buyBtn.TextColor3 = Color3.new(1,1,1)
                buyBtn.Font = Enum.Font.GothamBold
                buyBtn.TextSize = 16
                buyBtn.Parent = toolFrame
                
                buyBtn.MouseButton1Click:Connect(function()
                    GardenRemotes.BuyTool:FireServer(toolName)
                end)
                
                return toolFrame
            end
            
            -- Atualizar UI da loja
            local function updateShopUI(stock)
                seedsScroller:ClearAllChildren()
                
                local yOffset = 0
                for _, seedType in ipairs(stock) do
                    local seedFrame = createSeedButton(seedType, yOffset)
                    if seedFrame then
                        yOffset = yOffset + 75
                    end
                end
                seedsScroller.CanvasSize = UDim2.new(0, 0, 0, yOffset)
            end
            
            -- Atualizar UI de ferramentas
            local function updateToolsUI()
                toolsScroller:ClearAllChildren()
                
                local yOffset = 0
                for toolName, _ in pairs(GardenConfig.Tools) do
                    local toolFrame = createToolButton(toolName, yOffset)
                    if toolFrame then
                        yOffset = yOffset + 75
                    end
                end
                toolsScroller.CanvasSize = UDim2.new(0, 0, 0, yOffset)
            end
            
            -- Atualizar UI premium
            local function updatePremiumUI()
                local benefits = ""
                for benefit, value in pairs(GardenConfig.PremiumBenefits) do
                    local displayName = benefit:gsub("_", " "):gsub("^%l", string.upper)
                    benefits = benefits .. "• " .. displayName .. ": " .. tostring(value) .. "\n"
                end
                
                premiumFrame.PremiumLabel.Text = "BENEFÍCIOS PREMIUM:\n\n" .. benefits
            end
            
            -- Inicialização
            ShopReset.OnClientEvent:Connect(updateShopUI)
            UpdateUI.OnClientEvent:Connect(function()
                moneyLabel.Text = "Dinheiro: $" .. Player:GetAttribute("Money")
                updateToolsUI()
                updatePremiumUI()
            end)
            
            OpenShop.OnClientEvent:Connect(function()
                mainFrame.Visible = true
                seedsFrame.Visible = true
                toolsFrame.Visible = false
                premiumFrame.Visible = false
            end)
            
            Player:GetAttributeChangedSignal("Money"):Connect(function()
                moneyLabel.Text = "Dinheiro: $" .. Player:GetAttribute("Money")
            end)
            
            -- Controle de abas
            seedsTab.MouseButton1Click:Connect(function()
                seedsFrame.Visible = true
                toolsFrame.Visible = false
                premiumFrame.Visible = false
            end)
            
            toolsTab.MouseButton1Click:Connect(function()
                seedsFrame.Visible = false
                toolsFrame.Visible = true
                premiumFrame.Visible = false
            end)
            
            premiumTab.MouseButton1Click:Connect(function()
                seedsFrame.Visible = false
                toolsFrame.Visible = false
                premiumFrame.Visible = true
            end)
            
            -- Controle da GUI
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.B then
                    mainFrame.Visible = not mainFrame.Visible
                    seedsFrame.Visible = true
                    toolsFrame.Visible = false
                    premiumFrame.Visible = false
                end
            end)
            
            -- Sistema de plantio
            for _, plot in ipairs(workspace:GetChildren()) do
                if plot.Name == "GardenPlot" then
                    local prompt = plot:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        prompt.Triggered:Connect(function(player)
                            if player == Player then
                                mainFrame.Visible = true
                            end
                        end)
                    end
                end
            end
            
            -- Botão de admin para jogadores autorizados
            if table.find(GardenConfig.AdminIDs, Player.UserId) then
                local adminBtn = Instance.new("TextButton")
                adminBtn.Text = "ADMIN"
                adminBtn.Size = UDim2.new(0.1, 0, 0.05, 0)
                adminBtn.Position = UDim2.new(0.9, 0, 0.95, 0)
                adminBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
                adminBtn.TextColor3 = Color3.new(1,1,1)
                adminBtn.Font = Enum.Font.GothamBold
                adminBtn.TextSize = 16
                adminBtn.Parent = ui
            end
        ]]
    }, PlayerUI)
end

-- Função principal para criar o jardim
createBtn.Click:Connect(function()
    -- Criar tela de carregamento
    local loadingScreen = createLoadingScreen()
    loadingScreen.update("Criando configurações...", 0.1)
    wait(0.5)
    
    -- Configuração principal
    createGardenConfig()
    loadingScreen.update("Criando utilitários...", 0.2)
    wait(0.5)
    
    -- Módulo de utilidades
    createGardenUtils()
    loadingScreen.update("Criando script principal...", 0.3)
    wait(0.5)
    
    -- Script principal
    createGardenMain()
    loadingScreen.update("Criando interface...", 0.4)
    wait(0.5)
    
    -- Interface do usuário
    createPlayerUI()
    loadingScreen.update("Gerando mapa...", 0.6)
    wait(0.5)
    
    -- Gerar mapa
    createGardenMap()
    loadingScreen.update("Finalizando...", 0.9)
    wait(1)
    
    -- Remover tela de carregamento
    loadingScreen.gui:Destroy()
    
    -- Notificação final
    StarterGui:SetCore("SendNotification", {
        Title = "Jardim Premium V2 Criado!",
        Text = "Pressione B para abrir a loja de sementes",
        Duration = 8,
        Icon = "rbxassetid://7078467890"
    })
end)

-- Função para remover o jardim
removeBtn.Click:Connect(function()
    -- Remover elementos com segurança
    local function safeDestroy(obj)
        pcall(function()
            if obj then
                obj:Destroy()
            end
        end)
    end

    -- Remover jardins
    safeDestroy(Workspace:FindFirstChild("Gardens"))
    
    -- Remover partes do ambiente
    for _, plot in ipairs(Workspace:GetChildren()) do
        if plot.Name == "GardenPlot" or plot.Name == "SeedShop" or 
           plot.Name == "GardenArea" or plot.Name:find("Tree") or 
           plot.Name == "Fountain" or plot.Name == "Water" then
            safeDestroy(plot)
        end
    end
    
    -- Remover scripts e configurações
    safeDestroy(ReplicatedStorage:FindFirstChild("GardenConfig"))
    safeDestroy(ReplicatedStorage:FindFirstChild("GardenUtils"))
    safeDestroy(ReplicatedStorage:FindFirstChild("GardenRemotes"))
    safeDestroy(game.ServerScriptService:FindFirstChild("GardenMain"))
    safeDestroy(StarterGui:FindFirstChild("GardenUI"))
    safeDestroy(StarterGui:FindFirstChild("LoadingScreen"))
    
    -- Notificação de remoção
    StarterGui:SetCore("SendNotification", {
        Title = "Jardim Removido",
        Text = "Todos os elementos foram removidos com sucesso",
        Duration = 5
    })
end)
