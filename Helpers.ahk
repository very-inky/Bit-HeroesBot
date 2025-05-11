;────────────────────────────────────────────────────────────────
; General helpers, that may be used in more than one action

IsMainScreenAnchor() {
    global Bot
    SoundBeep, 1000, 500
    return FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Bot.ocr.QuestIcon)
}

AttemptReconnect() {
    global Bot
    DebugLog("AttemptReconnect: Checking for disconnect message...")
    if FindText(X, Y, 4, 40, 3837, 2159, 0, 0, Bot.ocr.Disconnect) {
         DebugLog("AttemptReconnect: Found disconnect message. Clicking OK.")
        FindText().Click(X,Y,"L")
        Sleep, 2000
    } else {
         DebugLog("AttemptReconnect: Disconnect message not found.")
    }
}

HandleTeamNotFull(actionContext := "Quest") {
    global Bot
    DebugLog("HandleTeamNotFull (" . actionContext . "): --- Entered function ---")
    ;sleep, 500

    maxWarningDetectAttempts := 2
    warningCheckDelay := 100
    autoButtonClicked := false

    Loop, %maxWarningDetectAttempts%
    {
        DebugLog("HandleTeamNotFull (" . actionContext . "): Attempt " . A_Index . "/" . maxWarningDetectAttempts . " to find 'Add Team Member' button.")
        if FindText(WarnX, WarnY, 0, 0, 3839, 2159, 0, 0, Bot.ocr.TeamAddButton) {
            DebugLog("HandleTeamNotFull (" . actionContext . "): Found 'Add Team Member' button.")
            DebugLog("HandleTeamNotFull (" . actionContext . "): Searching for 'Auto-fill' button.")
            if FindText(AutoX, AutoY, 0, 0, 3839, 2159, 0, 0, Bot.ocr.AutoFillButton) {
                DebugLog("HandleTeamNotFull (" . actionContext . "): Found 'Auto-fill' button. Clicking.")
                FindText().Click(AutoX, AutoY, "L")
                Sleep, 1000
                autoButtonClicked := true
            } else {
                DebugLog("HandleTeamNotFull (" . actionContext . "): 'Auto-fill' button NOT found after dismissing warning. This might be an issue")
            }
            DebugLog("HandleTeamNotFull (" . actionContext . "): --- Exiting function (Warning processed. Auto clicked: " . (autoButtonClicked ? "Yes" : "No") . ") ---")
            return autoButtonClicked ; Return true if Auto was clicked, false otherwise
        }
        DebugLog("HandleTeamNotFull (" . actionContext . "): Warning not found on attempt " . A_Index . ".")
        if (A_Index < maxWarningDetectAttempts) {
            Sleep, %warningCheckDelay%
        }
    }
    
    DebugLog("HandleTeamNotFull (" . actionContext . "): 'Team Not Full' warning NOT detected after " . maxWarningDetectAttempts . " attempts.")
    DebugLog("HandleTeamNotFull (" . actionContext . "): --- Exiting function (Warning Not Present) ---")
    return false
}


CheckOutOfResources() {
    global Bot
    DebugLog("CheckOutOfResources: --- Entered Function ---")
    ; Ensure Bot.ocr.OutOfResources pattern is correct
    result := FindText(X, Y, 1000-150000, 800-150000, 1000+150000, 800+150000, 0, 0, Bot.ocr.OutOfResources)
    found := result ? "True" : "False"
    DebugLog("CheckOutOfResources: FindText result: " . found . " Sent escape key and exiting function")
    if (result) {
        Send, {Esc}
        Sleep, 500 ; Wait for 2 seconds after sending the escape key
    }
    return result ; Returns the actual reselt
}

ClickRightArrow() {
    global Bot
    DebugLog("ClickRightArrow: Searching for right arrow (2128,891 to 2640,1378)...")
    if FindText(X, Y, 2048, 658, 2721, 1691, 0, 0, Bot.ocr.ZoneArrowRight) {
        DebugLog("ClickRightArrow: Found, Clicking.")
        FindText().Click(X,Y,"L")
    } else {
        DebugLog("ClickRightArrow: Arrow NOT found!")
    }
    Sleep, 400
}

ClickLeftArrow() {
    global Bot
     DebugLog("ClickLeftArrow: Searching for left arrow (592,742 to 1005,1383)...")
    if FindText(X, Y, 465, 716, 1021, 1448, 0, 0, Bot.ocr.ZoneArrowLeft) {
         DebugLog("ClickLeftArrow: Found, Clicking.")
        FindText().Click(X,Y,"L")
    } else {
         DebugLog("ClickLeftArrow: Arrow NOT found!")
    }
    Sleep, 400
}

EnsureAutoPilotOn() {
    global Bot
    DebugLog("EnsureAutoPilotOn: --- Entered function (will try up to 5 attempts with double-check for RED) ---")
    
    variation := 0.1 ; Color variation for FindText
    redConsecutiveDetections := 0 ; Counter for consecutive RED detections
    maxAttempts := 5

    Loop, %maxAttempts%
    {
        currentAttempt := A_Index
        DebugLog("EnsureAutoPilotOn: Attempt " . currentAttempt . " of " . maxAttempts . ".")

        ; 1. Check for GREEN (On) button first - if it's on, we're done.
        DebugLog("EnsureAutoPilotOn: Searching for AutoPilot GREEN button (Variation: " . variation . ")")
        if FindText(X, Y, 2480-150000, 1060-150000, 2480+150000, 1060+150000, variation, 0, Bot.ocr.AutoPilotGreen) {
            DebugLog("EnsureAutoPilotOn: Found GREEN AutoPilot button (already on). --- Exiting function (State Confirmed) ---")
            return true ; Success - Exit function immediately
        }
        DebugLog("EnsureAutoPilotOn: GREEN button not found on attempt " . currentAttempt . ".")

        ; 2. If GREEN wasn't found, check for RED (Off) button
        DebugLog("EnsureAutoPilotOn: Searching for AutoPilot RED button (Variation: " . variation . ")")
        if FindText(X, Y, 1186, 384, 3207, 1659, variation, 0, Bot.ocr.AutoPilotRed) {
            DebugLog("EnsureAutoPilotOn: Found RED AutoPilot button (Potential OFF state).")
            redConsecutiveDetections++
            DebugLog("EnsureAutoPilotOn: Consecutive RED detections: " . redConsecutiveDetections)

            if (redConsecutiveDetections >= 2) {
                DebugLog("EnsureAutoPilotOn: Found RED AutoPilot button twice consecutively. Sending {Space} to toggle ON.")
                Send, {space}
                ;Sleep, 500 not needed
                DebugLog("EnsureAutoPilotOn: --- Exiting function (Action Taken) ---")
                return true
            } else {
                DebugLog("EnsureAutoPilotOn: RED button found, but only " . redConsecutiveDetections . " time(s). Will check again.")
                Sleep, 280
                continue     ; Go to the next iteration of the main loop
            }
        } else {
            DebugLog("EnsureAutoPilotOn: RED button not found on this check.")
            redConsecutiveDetections := 0 ; Reset counter if RED is not found
        }

        ; 3. If neither was found on this attempt (or RED was found but not consecutively yet)
        DebugLog("EnsureAutoPilotOn: Attempt " . currentAttempt . ": No conclusive state yet (Green not found, Red not found or not yet consecutive).")
        if (currentAttempt < maxAttempts) {
             DebugLog("EnsureAutoPilotOn: Sleeping 400ms before next attempt.")
             Sleep, 400
        }
    }

    ; If loop finishes without returning true, then it failed all attempts
    DebugLog("EnsureAutoPilotOn: Neither GREEN found nor RED confirmed OFF after " . maxAttempts . " attempts. --- Exiting function (Failed) ---")
    return false
}

IsActionComplete() {
    global Bot
    DebugLog("IsActionComplete: --- Entered Function ---")
    ; Checking for "Town"
    result := FindText(X, Y, 601, 488, 2507, 1677, 0, 0, Bot.ocr.Button.Town)
    found := result ? "True" : "False"
    DebugLog("IsActionComplete: FindText for Town button returned: " . found . " --- Exiting function ---")
    return result
}

IsDisconnected() {
    global Bot
    DebugLog("IsDisconnected: --- Entered Function ---")
    ; Checking for disconnect popup
    result := FindText(X, Y, 4, 40, 3837, 2159, 0, 0, Bot.ocr.Disconnect)
     found := result ? "True" : "False"
    DebugLog("IsDisconnected: FindText for Disconnect pattern returned: " . found . " --- Exiting function ---")
    return result
}

IsPlayerDead() {
    global Bot
    DebugLog("IsPlayerDead: --- Entered Function ---")
    ; Checking for death
    result := FindText(X, Y, 672, 371, 2508, 944, 0, 0, Bot.ocr.PlayerDead)
    found := result ? "True" : "False"
    DebugLog("IsPlayerDead: FindText for PlayerDead pattern returned: " . found . " --- Exiting function ---")
    return result
}

ClickRerun() {
    global Bot
    DebugLog("ClickRerun: --- Entered Function ---")

    maxAttempts := 3
    attemptDelay := 250 ; Milliseconds to wait between attempts

    Loop, %maxAttempts%
    {
        DebugLog("ClickRerun: Attempt " . A_Index . "/" . maxAttempts . " to find Rerun button...")
        ; Checking for "Rerun" button using wide coords
        if FindText(X, Y, 1463-150000, 1563-150000, 1463+150000, 1563+150000, 0, 0, Bot.ocr.Button.Rerun) {
            DebugLog("ClickRerun: Found Rerun button on attempt " . A_Index . ". Clicking.")
            FindText().Click(X, Y, "L")
            Sleep, 500 ; Give click time to register
            DebugLog("ClickRerun: --- Exiting function (Success) ---")
            return true
        } else {
            DebugLog("ClickRerun: Rerun button NOT found on attempt " . A_Index . ".")
            if (A_Index < maxAttempts) {
                DebugLog("ClickRerun: Sleeping " . attemptDelay . "ms before next attempt.")
                Sleep, %attemptDelay%
            }
        }
    }

    ; If loop finishes, button was not found after all attempts
    DebugLog("ClickRerun: Rerun button NOT found after " . maxAttempts . " attempts! --- Exiting function (Failed) ---")
    return false
    ; DebugLog("This should not be reached") ; This line was unreachable before and still is.
}
ClickTownOnComplete() {
    global Bot
    DebugLog("ClickTownOnComplete: --- Entered Function ---")
    ; Checking for "Town" button using wide coords
    if FindText(X, Y, 1796-150000, 1532-150000, 1796+150000, 1532+150000, 0, 0, Bot.ocr.Button.Town) {
        DebugLog("ClickTownOnComplete: Found Town button-Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 500
        DebugLog("ClickTownOnComplete: Returning True. --- Exiting function ---")
        return true
    } else {
         DebugLog("ClickTownOnComplete: Town button NOT found! Returning False. --- Exiting function ---")
        return false
    }
}

HandleInProgressDialogue() {
    global Bot
    ; No entry/exit needed unless it becomes problematic. Just log IF found.
    if FindText(X, Y, 1859, 727, 2495, 1369, 0, 0, Bot.ocr.InProgressDialogue) {
        DebugLog("HandleInProgressDialogue: Found dialogue arrow. Sending {Esc}.")
        Send, {Esc}
        Sleep, 200
        return true ; Indicate dialogue was handled
    }
    return false ; Indicate no dialogue found/handled
}
