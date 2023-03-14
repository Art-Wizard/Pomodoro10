local pomodoroTime = 25 -- in minutes
local breakTime = 5 -- in minutes
local totalIntervals = 4
local currentInterval = 1
local isItPomodoroTime = false
local minutesLeft = 25
local secondsLeft = 0
local PomodoroRunning = false
local canItPause = false
local timeSecond = 10 -- in milliseconds (1000 = 1 second), currently set to 10 milliseconds for testing purposes
local timeMinute = 600 -- in milliseconds (1000 = 1 second), currently set to 600 milliseconds for testing purposes
local hasRandomTimeHappened = false

-- create an options button to top right on the screen to change the minutes of the pomodoro and break time
local optionsButton = display.newText("Options", display.contentWidth - 100, 100, native.systemFont, 50)

-- create a text object to display time
local timeDisplay = display.newText(string.format("%02d:%02d", minutesLeft, secondsLeft), display.contentCenterX, display.contentCenterY, native.systemFont, 100)
timeDisplay:setFillColor(1, 1, 1)

-- create a text object to display the current interval out of the total intervals
local intervalDisplay = display.newText(string.format("%d/%d", currentInterval, totalIntervals), display.contentCenterX, display.contentCenterY + 300, native.systemFont, 50)
intervalDisplay:setFillColor(0.7, 0.7, 0.7)

-- create a text object to display the current phase of the pomodoro
local phaseDisplay = display.newText("Ready", display.contentCenterX, display.contentCenterY - 300, native.systemFont, 50)
phaseDisplay:setFillColor(0.7, 0.7, 0.7)

-- create a start button
local startButton = display.newText("Start", display.contentCenterX, display.contentHeight - 100, native.systemFont, 50)
startButton:setFillColor(1, 1, 1)

-- create a pause button above the start button
local pauseButton = display.newText("Pause", display.contentCenterX, display.contentHeight - 300, native.systemFont, 50)
pauseButton:setFillColor(1, 1, 1)


--TODO: figure out why stopTheClock() doesn't work even when intervals are done
-- create a function to display and count the intervals of pomodoro, and if the pomodoro intervals are done, display a "done!" message and reset everything
local function updateInterval()
    if currentInterval < totalIntervals then
        currentInterval = currentInterval + 1
        intervalDisplay.text = string.format("%d/%d", currentInterval, totalIntervals)
    else
        currentInterval = 1
        intervalDisplay.text = string.format("%d/%d", currentInterval, totalIntervals)
        phaseDisplay.text = "Done!"
        stopTheClock()
    end
end

-- create a function to count down the time given in minutesLeft and secondsLeft and update the display
local function updateTime()
    timeDisplay.text = string.format("%02d:%02d", minutesLeft, secondsLeft)
    secondsLeft = secondsLeft - 1
    if secondsLeft < 0 then
        secondsLeft = 59
        minutesLeft = minutesLeft - 1
    end
    if minutesLeft == 0 and secondsLeft == 0 then  
        if isItPomodoroTime then
            minutesLeft = breakTime
            isItPomodoroTime = false
            phaseDisplay.text = "Break Time"
        else
            minutesLeft = pomodoroTime
            isItPomodoroTime = true
            phaseDisplay.text = "Pomodoro Time"
            randomTimer()
            updateInterval()
        end
   
    
end
    
end

local function pomoDoroSetup()
    minutesLeft = pomodoroTime
    secondsLeft = 0
    phaseDisplay.text = "Pomodoro Time"
    startButton.text = "Stop"
    pauseButton.text = "Pause"
    isItPomodoroTime = true
    PomodoroRunning = true
    canItPause = true
    randomTimer()
    timer.performWithDelay(timeSecond, updateTime, 0, "pomTime")
    
end


local function startPomodoro()
    if PomodoroRunning then
        timer.cancel("pomTime")
        phaseDisplay.text = "Ready"
        startButton.text = "Start"
        PomodoroRunning = false
        canItPause = false

    else
        print("startPomodoro")
        pomoDoroSetup()
    end
end

local function pausePomodoro()
    if canItPause then
        print("pausePomodoro")
        if PomodoroRunning then
            timer.pause("pomTime")
            phaseDisplay.text = "Paused"
            startButton.text = "Restart"
            pauseButton.text = "Resume"
            PomodoroRunning = false
        else
            timer.resume("pomTime")
            if isItPomodoroTime then
                phaseDisplay.text = "Pomodoro Time"
            else
                phaseDisplay.text = "Break Time"
            end
            pauseButton.text = "Pause"
            PomodoroRunning = true
        end
    end
end

function stopTheClock()
    timer.cancel("pomTime")
    print ("stopTheClock")
    minutesLeft = pomodoroTime
    secondsLeft = 0
    startButton.text = "Start"
    pauseButton.text = "Pause"
end

-- create a function that pauses the timer randomly for 10 seconds during the pomodoro time
function randomPause()
    print( "startingRandomPause" )
    if isItPomodoroTime and hasRandomTimeHappened == false then
        print( "randomPauseHappened" )
        timer.pause("pomTime")
        phaseDisplay.text = "Random Pause"
        --change the background color to red
        display.setDefault("background", 1, 0, 0)
        startButton.text = "Restart"
        pauseButton.text = "Resume"
        PomodoroRunning = false
        timer.performWithDelay(10000, function()
            print( "randomPauseEnded" )
            timer.resume("pomTime")
            phaseDisplay.text = "Pomodoro Time"
            startButton.text = "Stop"
            pauseButton.text = "Pause"
            PomodoroRunning = true
            hasRandomTimeHappened = true
            --change the background color off of red
            display.setDefault("background", 0, 0, 0)

        end)
    end
end
-- TODO: figure out why the random pause is not working
--create a function to create the random time when the random pause will happen
function randomTimer()
    --if 2 minutes has passed, then create a random time between 1 and 10 minutes
    if pomodoroTime-minutesLeft >= 2 then
        randomTime = math.random(1, 10)
        --start a countdown timer for the randomPause function with the random time
        timer.performWithDelay(randomTime*timeMinute, randomPause)
    end
end

-- create a function to change the time of the pomodoro and break
local function options()
    -- disable the options button, start button, and pause button while the options screen is up
    optionsButton:removeEventListener("tap", options)
    startButton:removeEventListener("tap", startPomodoro)
    pauseButton:removeEventListener("tap", pausePomodoro)
    -- fade out the options button, start button, and pause button
    transition.fadeOut(optionsButton, {time = 500})
    transition.fadeOut(startButton, {time = 500})
    transition.fadeOut(pauseButton, {time = 500})
    print("options")
    local optionsGroup = display.newGroup()
    local optionsBackground = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    optionsBackground:setFillColor(0.2, 0.2, 0.2)
    optionsGroup:insert(optionsBackground)
    -- create a text object to explain the default if nothing is entered, and fit the text to the screen
    local defaultText = display.newText("Default is 25 minutes for pomodoro and 5 minutes for break", display.contentCenterX, display.contentCenterY - 400, display.contentWidth - 100, 0, native.systemFont, 50)
    optionsGroup:insert(defaultText)
    local optionsText = display.newText("Options", display.contentCenterX, display.contentCenterY - 300, native.systemFont, 50)
    optionsGroup:insert(optionsText)
    local pomodoroTimeText = display.newText("Pomodoro Time", display.contentCenterX, display.contentCenterY - 200, native.systemFont, 50)
    optionsGroup:insert(pomodoroTimeText)
    local pomodoroTimeInput = native.newTextField(display.contentCenterX, display.contentCenterY - 100, 200, 100)
    optionsGroup:insert(pomodoroTimeInput)
    local breakTimeText = display.newText("Break Time", display.contentCenterX, display.contentCenterY, native.systemFont, 50)
    optionsGroup:insert(breakTimeText)
    local breakTimeInput = native.newTextField(display.contentCenterX, display.contentCenterY + 100, 200, 100)
    optionsGroup:insert(breakTimeInput)
    local totalIntervalsText = display.newText("Total Intervals", display.contentCenterX, display.contentCenterY + 200, native.systemFont, 50)
    optionsGroup:insert(totalIntervalsText)
    local totalIntervalsInput = native.newTextField(display.contentCenterX, display.contentCenterY + 300, 200, 100)
    optionsGroup:insert(totalIntervalsInput)
    local optionsDoneButton = display.newText("Done", display.contentCenterX, display.contentCenterY + 400, native.systemFont, 50)
    optionsGroup:insert(optionsDoneButton)
    --create a button to close the options screen without applying any changes, to same place as options button on main screen
    local optionsCancelButton = display.newText("Cancel", display.contentCenterX, display.contentCenterY + 500, native.systemFont, 50)
    optionsGroup:insert(optionsCancelButton)
    optionsCancelButton:addEventListener("tap", function()
        optionsGroup:removeSelf()
        optionsGroup = nil
        --fade in the buttons
        transition.to(optionsButton, {time = 500, alpha = 1})
        transition.to(startButton, {time = 500, alpha = 1})
        transition.to(pauseButton, {time = 500, alpha = 1})
        --re-enable the buttons
        optionsButton:addEventListener("tap", options)
        startButton:addEventListener("tap", startPomodoro)
        pauseButton:addEventListener("tap", pausePomodoro)
    end)
    optionsDoneButton:addEventListener("tap", function()
        optionsGroup:removeSelf()
        optionsGroup = nil
          -- if nothing is entered in the text fields, set the time to 25 minutes for pomodoro and 5 minutes for break
        if pomodoroTimeInput.text == "" then
            pomodoroTime = 25
        else
            pomodoroTime = tonumber(pomodoroTimeInput.text)
        end
        if breakTimeInput.text == "" then
            breakTime = 5
        else
            breakTime = tonumber(breakTimeInput.text)
        end
        if totalIntervalsInput.text == "" then
            totalIntervals = 4
        else
            totalIntervals = tonumber(totalIntervalsInput.text)
        end
        minutesLeft = pomodoroTime
        secondsLeft = 0
        timeDisplay.text = string.format("%02d:%02d", minutesLeft, secondsLeft)
        phaseDisplay.text = "Ready"
        startButton.text = "Start"
        pauseButton.text = "Pause"
        intervalDisplay.text = string.format("%d/%d", currentInterval, totalIntervals)
        isItPomodoroTime = false
        PomodoroRunning = false
        canItPause = false
        --fade in the buttons
        transition.to(optionsButton, {time = 500, alpha = 1})
        transition.to(startButton, {time = 500, alpha = 1})
        transition.to(pauseButton, {time = 500, alpha = 1})
        --re-enable the buttons
        optionsButton:addEventListener("tap", options)
        startButton:addEventListener("tap", startPomodoro)
        pauseButton:addEventListener("tap", pausePomodoro)
    end)

end
  



-- Add event listeners to start and pause buttons
startButton:addEventListener("tap", startPomodoro)
pauseButton:addEventListener("tap", pausePomodoro)
optionsButton:addEventListener("tap", options)