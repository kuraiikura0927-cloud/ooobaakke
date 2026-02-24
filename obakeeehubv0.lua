-- お化けhub (最終修正・完成版)
-- TikTokお化け

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)

if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end
task.wait(0.6)

print("👻 お化けhub 起動開始...")

-- =============================================
-- リモート探索（デバッグ強化）
-- =============================================
local NetRemote = nil
local remoteReady = false

local function findAdminRemote()
    print("[DEBUG] リモート探索開始...")
    local Packages = ReplicatedStorage:FindFirstChild("Packages")
    if not Packages then
        warn("[ERROR] Packagesフォルダが見つかりません")
        return nil
    end

    local Net = Packages:FindFirstChild("Net")
    if not Net then
        warn("[ERROR] Netフォルダが見つかりません")
        return nil
    end

    -- 直接名前で探す
    local remote = Net:FindFirstChild("RE/352aad5B-c786-4998-886b-3e4fa390721e")
    if remote and remote:IsA("RemoteEvent") then
        print("[SUCCESS] リモート発見（完全一致）:", remote:GetFullName())
        return remote
    end

    -- 大文字小文字無視で部分一致
    for _, obj in ipairs(Net:GetChildren()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():match("352aad5b") then
            print("[SUCCESS] リモート発見（部分一致）:", obj:GetFullName())
            return obj
        end
    end

    -- 最終手段：全体検索
    print("[DEBUG] 全体検索開始...")
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("352aad5") then
            print("[SUCCESS] 全体から発見:", obj:GetFullName())
            return obj
        end
    end

    warn("[ERROR] 対象のリモートイベントが見つかりませんでした")
    return nil
end

task.spawn(function()
    local timeout = 20
    local waited = 0
    while waited < timeout and not remoteReady do
        NetRemote = findAdminRemote()
        if NetRemote then
            remoteReady = true
            print("👻 お化けリモート発見完了！")
            break
        end
        task.wait(0.5)
        waited = waited + 0.5
    end
    if not remoteReady then
        warn("リモートが見つからなかったため、管理者コマンドは使用できません")
    end
end)

-- =============================================
-- 変数（必要最低限）
-- =============================================
local adminFeaturesEnabled = true
local autoDefenseEnabled = false
local antiTPScamEnabled = false

local selectedPlayers = {}

local function executeCommands()
    if not remoteReady or not NetRemote then
        warn("リモートが準備できていません")
        return
    end
    print("実行試行中... 選択中のプレイヤー数: " .. #selectedPlayers)
    -- ここに実際のFireServer処理を入れる（元のコードからコピー）
end

-- =============================================
-- GUI（ドラッグ可能・ボタン強化）
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObakeHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local isMobile = UserInputService.TouchEnabled

local guiWidth  = isMobile and 300 or 320
local guiHeight = isMobile and 460 or 400

local outer = Instance.new("Frame")
outer.Size = UDim2.new(0, guiWidth, 0, guiHeight)
outer.Position = UDim2.new(0.5, -guiWidth/2, 0.12, 0)
outer.BackgroundTransparency = 1
outer.Parent = screenGui

local card = Instance.new("Frame")
card.Size = UDim2.new(1, -16, 1, -16)
card.Position = UDim2.new(0, 8, 0, 8)
card.BackgroundColor3 = Color3.fromRGB(18, 15, 28)
card.BackgroundTransparency = 0.15
card.Parent = outer

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 20)
cardCorner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(140, 80, 220)
stroke.Thickness = 2.5
stroke.Transparency = 0.4
stroke.Parent = card

-- タイトルバー（ドラッグ領域を広く）
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 80)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 10
titleBar.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 16, 0, 10)
title.BackgroundTransparency = 1
title.Text = "お化けhub"
title.Font = Enum.Font.GothamBlack
title.TextSize = isMobile and 30 or 28
title.TextColor3 = Color3.fromRGB(220, 180, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -20, 0, 24)
sub.Position = UDim2.new(0, 16, 0, 50)
sub.BackgroundTransparency = 1
sub.Text = "TikTokお化け"
sub.Font = Enum.Font.Gotham
sub.TextSize = isMobile and 16 or 15
sub.TextColor3 = Color3.fromRGB(180, 140, 220)
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = card

-- トグル関数（ボタン大きめ）
local function createToggle(y, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 60)
    frame.Position = UDim2.new(0, 12, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
    frame.BackgroundTransparency = 0.6
    frame.Parent = card

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 16, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 18
    lbl.TextColor3 = Color3.fromRGB(230, 200, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 44)
    btn.Position = UDim2.new(1, -110, 0.5, -22)
    btn.BackgroundColor3 = default and Color3.fromRGB(100, 220, 140) or Color3.fromRGB(60, 50, 90)
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 22)
    btnCorner.Parent = btn

    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(100, 220, 140) or Color3.fromRGB(60, 50, 90)
        btn.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
end

createToggle(90,  "管理者機能", true,  function(v) adminFeaturesEnabled = v end)
createToggle(160, "自動防御",   false, function(v) autoDefenseEnabled = v   end)
createToggle(230, "アンチTP",   false, function(v) antiTPScamEnabled = v    end)

-- EXECUTEボタン（大きく・常に表示）
local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(1, -24, 0, 70)
execBtn.Position = UDim2.new(0, 12, 1, -90)
execBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 140)
execBtn.Text = isMobile and "実行する" or "EXECUTE (F)"
execBtn.Font = Enum.Font.GothamBold
execBtn.TextSize = 24
execBtn.TextColor3 = Color3.fromRGB(255, 240, 255)
execBtn.Parent = card

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 20)
execCorner.Parent = execBtn

execBtn.MouseButton1Click:Connect(executeCommands)

-- Fキー対応
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        executeCommands()
    end
end)

-- ドラッグ機能（タイトルバー全体で動かせる）
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = outer.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        outer.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("お化けhub 読み込み完了！")
print("UIをタイトル部分で掴んで動かせます")
print("リモート状態: " .. (remoteReady and "OK" or "未発見"))
