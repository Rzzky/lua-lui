local asciiArt = [[


       Hands Up Kiddo! - RzkyO Was Here
       ,            _..._            ,
      {'.         .'     '.         .'}
     { ~ '.      _|=    __|_      .'  ~}
    { ~  ~ '-._ (___________) _.-'~  ~  }
   {~  ~  ~   ~.'           '. ~    ~    }
  {  ~   ~  ~ /   /\     /\   \   ~    ~  }
  {   ~   ~  /    __     __    \ ~   ~    }
   {   ~  /\/  -<( o)   ( o)>-  \/\ ~   ~}
    { ~   ;(      \/ .-. \/      );   ~ }
     { ~ ~\_  ()  ^ (   ) ^  ()  _/ ~  }
      '-._~ \   (`-._'-'_.-')   / ~_.-'
          '--\   `'._'"'_.'`   /--'
              \     \`-'/     /
               `\    '-'    /'
                `\         /'
                  ''-...-''
 Taken picture from your webcam - jk - Enjoy!
]]

print(asciiArt)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local function TampilkanNotifikasi_Glitch(title, message, duration)
    duration = duration or 4

    local screenGui = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, 350, 0, 90)
    mainFrame.AnchorPoint = Vector2.new(1, 1)
    mainFrame.Position = UDim2.new(1, 20, 0.98, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    mainFrame.BorderColor3 = Color3.fromRGB(150, 50, 255)
    mainFrame.BorderSizePixel = 2
    
    local scanlines = Instance.new("ImageLabel", mainFrame)
    scanlines.Image = "rbxassetid://215353235"
    scanlines.ImageTransparency = 0.85
    scanlines.ScaleType = Enum.ScaleType.Tile
    scanlines.TileSize = UDim2.new(0, 4, 0, 4)
    scanlines.Size = UDim2.fromScale(1, 1)
    scanlines.BackgroundTransparency = 1
    scanlines.ZIndex = 3

    local function BuatTeksGlitch(parent, props)
        local textHolder = Instance.new("Frame", parent)
        textHolder.Size = props.Size
        textHolder.Position = props.Position
        textHolder.BackgroundTransparency = 1
        textHolder.ZIndex = 2
        textHolder.ClipsDescendants = true
        
        local text_R = Instance.new("TextLabel", textHolder)
        text_R.TextColor3 = Color3.new(1, 0.2, 0.2)
        
        local text_B = Instance.new("TextLabel", textHolder)
        text_B.TextColor3 = Color3.new(0.2, 0.2, 1)
        
        local text_G = Instance.new("TextLabel", textHolder)
        text_G.TextColor3 = Color3.fromRGB(230, 230, 230)

        for _, label in ipairs({text_R, text_B, text_G}) do
            label.Size = UDim2.fromScale(1, 1)
            label.Text = props.Text
            label.Font = props.Font
            label.TextSize = props.TextSize
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            if props.Wrapped then
                label.TextWrapped = true
                label.TextYAlignment = Enum.TextYAlignment.Top
            end
        end
        
        return textHolder, text_R, text_B
    end

    local titleProps = {
        Text = title,
        TextSize = 20,
        Font = Enum.Font.Code,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 25),
        Wrapped = false
    }
    local messageProps = {
        Text = message,
        TextSize = 16,
        Font = Enum.Font.Code,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 1, -40),
        Wrapped = true
    }

    local titleHolder, title_R, title_B = BuatTeksGlitch(mainFrame, titleProps)
    local messageHolder, message_R, message_B = BuatTeksGlitch(mainFrame, messageProps)

    local glitchCoroutine = coroutine.wrap(function()
        local glitchIntensity = 2.5
        while mainFrame.Parent do
            local offsetX_R = math.random(-glitchIntensity, glitchIntensity)
            local offsetY_R = math.random(-glitchIntensity, glitchIntensity)
            local offsetX_B = math.random(-glitchIntensity, glitchIntensity)
            local offsetY_B = math.random(-glitchIntensity, glitchIntensity)
            
            title_R.Position = UDim2.fromOffset(offsetX_R, offsetY_R)
            title_B.Position = UDim2.fromOffset(offsetX_B, offsetY_B)
            message_R.Position = UDim2.fromOffset(offsetX_R, offsetY_R)
            message_B.Position = UDim2.fromOffset(offsetX_B, offsetY_B)
            
            scanlines.Visible = math.random(1, 10) > 2
            
            RunService.Heartbeat:Wait()
        end
    end)

    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
    local tweenIn = TweenService:Create(mainFrame, tweenInfo, { Position = UDim2.new(0.98, 0, 0.98, 0) })
    tweenIn:Play()
    tweenIn.Completed:Wait()

    glitchCoroutine()

    wait(duration)

    local tweenInfoOut = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local tweenOut = TweenService:Create(mainFrame, tweenInfoOut, { Position = UDim2.new(1, 20, 0.98, 0) })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    
    screenGui:Destroy()
end

TampilkanNotifikasi_Glitch(
    "SYSTEM_INJECTED!",
    "Injected by RzkyO - Ready to break the rules.",
    4
)
