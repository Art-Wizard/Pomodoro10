local pomodoroTime = 1 -- in minutes
local breakTime = 5 -- in minutes
local totalIntervals = 4

local minutesLeft = pomodoroTime
local secondsLeft = 0

-- create a background to fill screen with darkest gray
local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
background:setFillColor(0.1, 0.1, 0.1)



-- create a text object to display time
local timeDisplay = display.newText("25:00", display.contentCenterX, display.contentCenterY, native.systemFont, 100)
timeDisplay:setFillColor(1, 1, 1)

local function updateTime()
    secondsLeft = secondsLeft - 1
  if secondsLeft < 0 then
    secondsLeft = 59
    minutesLeft = minutesLeft - 1
  end
  if minutesLeft < 0 then
    -- Pomodoro interval completed, start break time
    minutesLeft = breakTime
    secondsLeft = 0
    timer.performWithDelay(1000, startBreak)
  else
    -- Update time display
    timeDisplay.text = string.format("%02d:%02d", minutesLeft, secondsLeft)
    print( timeDisplay.text )
  end
end

local function startPomodoro()
    print("startPomodoro")
  minutesLeft = pomodoroTime
  secondsLeft = 0
  timer.performWithDelay(1000, updateTime, totalIntervals)
end

local function startBreak()
    print("startBreak")
  minutesLeft = breakTime
  secondsLeft = 0
  timer.performWithDelay(1000, updateTime, totalIntervals)
end 


-- create a start button
local startButton = display.newText("Start", display.contentCenterX, display.contentHeight - 100, native.systemFont, 50)
startButton:setFillColor(1, 1, 1)

-- create a break button
local breakButton = display.newText("Break", display.contentCenterX, display.contentHeight - 50, native.systemFont, 50)
breakButton:setFillColor(1, 1, 1)



-- Add event listeners to start and break buttons
startButton:addEventListener("tap", startPomodoro)
breakButton:addEventListener("tap", startBreak)
