local DrawingESP = {}
local run = game:GetService("RunService")
local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

function DrawText()
    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Visible = false
    return text
end

function DrawLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Visible = false
    return line
end

function DrawBox()
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Filled = false
    box.Visible = false
    return box
end

function AddESP(player)
    if player == localPlayer then return end
    local esp = {
        Box = DrawBox(),
        Name = DrawText(),
        Tracer = DrawLine(),
        Tool = DrawText()
    }
    DrawingESP[player] = esp
end

function RemoveESP(player)
    if DrawingESP[player] then
        for _, obj in pairs(DrawingESP[player]) do
            if obj then obj:Remove() end
        end
        DrawingESP[player] = nil
    end
end

players.PlayerAdded:Connect(AddESP)
players.PlayerRemoving:Connect(RemoveESP)

for _, player in pairs(players:GetPlayers()) do
    AddESP(player)
end

run.RenderStepped:Connect(function()
    if not getgenv().Visual.Enabled then
        for _, esp in pairs(DrawingESP) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
        return
    end

    for player, esp in pairs(DrawingESP) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        local tool = character and character:FindFirstChildOfClass("Tool")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if character and hrp and humanoid and humanoid.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            local scale = math.clamp(1 / (hrp.Position - camera.CFrame.Position).Magnitude * 100, 0.4, 3)

            if getgenv().Visual.Box then
                esp.Box.Size = Vector2.new(25 * scale, 45 * scale)
                esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                esp.Box.Color = Color3.new(1, 1, 1)
                esp.Box.Visible = onScreen
            else
                esp.Box.Visible = false
            end

            if getgenv().Visual.Name then
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(pos.X, pos.Y - 30 * scale)
                esp.Name.Color = Color3.new(1, 1, 1)
                esp.Name.Visible = onScreen
            else
                esp.Name.Visible = false
            end

            if getgenv().Visual.Tracer then
                esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                esp.Tracer.Color = Color3.new(1, 1, 1)
                esp.Tracer.Visible = onScreen
            else
                esp.Tracer.Visible = false
            end

            if getgenv().Visual.ToolName then
                esp.Tool.Text = tool and tool.Name or "None"
                esp.Tool.Position = Vector2.new(pos.X, pos.Y + 30 * scale)
                esp.Tool.Color = Color3.new(1, 1, 1)
                esp.Tool.Visible = onScreen
            else
                esp.Tool.Visible = false
            end
        else
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
    end
end)


-- FARM
getgenv().AutoFarmBox = false
getgenv().AutoRobCar = false
getgenv().AutoRobBank = false

local rs = game:GetService("RunService")
local p = game.Players.LocalPlayer
local hrp = p.Character and p.Character:WaitForChild("HumanoidRootPart") or nil
p.CharacterAdded:Connect(function(char)
    hrp = char:WaitForChild("HumanoidRootPart")
end)

rs.RenderStepped:Connect(function()
    if getgenv().AutoFarmBox and hrp then
        local j = workspace.Systems.BoxJob:GetChildren()
        if p:GetAttribute("Carrying") == 10000 then return end
        local b = p.Backpack:FindFirstChild("Box")
        if b then b.Parent = p.Character end
        hrp.CFrame = CFrame.new(-1776.31604, 249.147675, -84.1608582)
        fireproximityprompt(j[3]:FindFirstChild("PlacePrompt"))
        fireproximityprompt(j[4]:FindFirstChild("GrabPrompt"))
    end

    if getgenv().AutoRobCar and hrp then
        for _, car in pairs(workspace.Systems.CarRobbery:GetChildren()) do
            local gui = car:FindFirstChild("Attachment") and car.Attachment:FindFirstChild("BillboardGui")
            local prompt = car:FindFirstChild("ProximityPrompt")
            local status = gui and gui:FindFirstChild("Status") and gui.Status.Text
            if status and prompt then
                if status == "[ROBBABLE]" or status == "[ROBBERY IN PROGRESS]" then
                    hrp.CFrame = car.CFrame
                    fireproximityprompt(prompt)
                    break
                end
            end
        end
    end

    if getgenv().AutoRobBank and hrp then
        if p:GetAttribute("Carrying") == 10000 then return end
        if workspace.Systems.Bank.Alarm.Sound.Playing then
            hrp.CFrame = CFrame.new(-2183.43823, 248.14473, 934.501465)
            for _, cash in pairs(workspace.Systems.Bank.Cash:GetChildren()) do
                if cash:FindFirstChild("ProximityPrompt") then
                    hrp.CFrame = cash.CFrame + Vector3.new(0, 2, 0)
                    fireproximityprompt(cash.ProximityPrompt)
                    task.wait(0.2)
                end
            end
        else
            if workspace.Systems.Bank.TimeHolder.BillboardGui.TextLabel.Text == "The bank is not being robbed." then
                if not p.Backpack:FindFirstChild("Drill") and not p.Character:FindFirstChild("Drill") then
                    game:GetService("ReplicatedStorage").Remotes.ItemStore:FireServer("Drill")
                    task.wait(0.5)
                end
                local drill = p.Backpack:FindFirstChild("Drill")
                if drill then drill.Parent = p.Character end
                hrp.CFrame = CFrame.new(-2196.01001, 248.14473, 895.635376)
                task.wait(0.5)
                fireproximityprompt(workspace.Systems.Bank.Prompts.Part.HackGateway.ProximityPrompt)
                hrp.CFrame = CFrame.new(-2183.43823, 248.14473, 934.501465)
                task.wait(0.5)
                fireproximityprompt(workspace.Systems.Bank.Prompts.Part.DrillSpot.ProximityPrompt)
                task.wait(0.5)
                fireproximityprompt(workspace.Systems.Bank.Prompts.Part.DrillSpot.ProximityPrompt)
            end
        end
    end
end)

getgenv().SellCarriedLoot = function()
    local prev = hrp.CFrame
    hrp.CFrame = workspace.Systems.JeweleryRobbery.LootBuy.CFrame + Vector3.new(0, 2, 0)
    fireproximityprompt(workspace.Systems.JeweleryRobbery.LootBuy.ProximityPrompt)
    task.wait(0.2)
    hrp.CFrame = prev
end


getgenv().Aimbot = false
getgenv().AimbotMethod = "Closest"
getgenv().AimbotPart = "Head"

-- Inside a RunService loop
local rs = game:GetService("RunService")
local cam = workspace.CurrentCamera

rs.RenderStepped:Connect(function()
    if getgenv().Aimbot then
        local target = nil
        local shortest = math.huge

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= p and v.Character and v.Character:FindFirstChild(getgenv().AimbotPart) then
                local part = v.Character[getgenv().AimbotPart]
                local distance = (part.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortest then
                    shortest = distance
                    target = part
                end
            end
        end

        if target then
            game:GetService("ReplicatedStorage").Remotes.Look:FireServer(CFrame.new(target.Position))
        end
    end
end)

getgenv().AntiLag = function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
            obj:Destroy()
        end
    end
end

getgenv().FullBright = function()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
end
