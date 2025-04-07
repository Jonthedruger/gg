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
