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
    if FindText(X, Y, 696, 470, 2503, 1632, 0, 0, Bot.ocr.Disconnect) {
         DebugLog("AttemptReconnect: Found disconnect message. Clicking OK.")
        FindText().Click(X,Y,"L")
        Sleep, 2000
    } else {
         DebugLog("AttemptReconnect: Disconnect message not found.")
    }
}

CheckOutOfResources() {
    global Bot
    DebugLog("CheckOutOfResources: --- Entered Function ---")
    ; Ensure Bot.ocr.OutOfResources pattern is correct
    result := FindText(X, Y, 1000-150000, 800-150000, 1000+150000, 800+150000, 0, 0, Bot.ocr.OutOfResources)
    found := result ? "True" : "False"
    DebugLog("CheckOutOfResources: FindText result: " . found . " --- Exiting function ---")
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
    DebugLog("EnsureAutoPilotOn: --- Entered function (will try up to 3 times) ---")
    foundRed := false, foundGreen := false, variation := 0.1 ; Keep color variation

    Loop, 3
    {
        DebugLog("EnsureAutoPilotOn: Attempt " . A_Index . " of 3.")

        ; 1. Check for RED (Off) button
        DebugLog("EnsureAutoPilotOn: Searching for AutoPilot RED button (Variation: " . variation . ")")
        foundRed := FindText(X, Y, 1186, 384, 3207, 1659, variation, 0, Bot.ocr.AutoPilotRed)

        if (foundRed) {
            DebugLog("EnsureAutoPilotOn: Found RED AutoPilot button. Sending {Space} to toggle ON.")
            Send, {space}
            Sleep, 300
            DebugLog("EnsureAutoPilotOn: --- Exiting function (Action Taken) ---")
            return true
        }

        ; 2. If RED wasn't found, check for GREEN (On) button
        DebugLog("EnsureAutoPilotOn: RED not found. Searching for AutoPilot GREEN button (Variation: " . variation . ")")
        foundGreen := FindText(X, Y, 2480-150000, 1060-150000, 2480+150000, 1060+150000, variation, 0, Bot.ocr.AutoPilotGreen)

        if (foundGreen) {
            DebugLog("EnsureAutoPilotOn: Found GREEN AutoPilot button (already on). --- Exiting function (State Confirmed) ---")
            return true ; Success - Exit function immediately
        }

        ; 3. If neither was found on this attempt
        DebugLog("EnsureAutoPilotOn: Attempt " . A_Index . ": Neither RED nor GREEN button found.")
        if (A_Index < 3) {
             DebugLog("EnsureAutoPilotOn: Sleeping 400ms before next attempt.")
             Sleep, 400
        }
    } ; End Loop

    ; If loop finishes without returning true, then it failed all attempts
    DebugLog("EnsureAutoPilotOn: Neither button found after 3 attempts. --- Exiting function (Failed) ---")
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
    result := FindText(X, Y, 696, 470, 2503, 1632, 0, 0, Bot.ocr.Disconnect)
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
    ; Checking for "Rerun" button using wide coords
    if FindText(X, Y, 1463-150000, 1563-150000, 1463+150000, 1563+150000, 0, 0, Bot.ocr.Button.Rerun) {
        DebugLog("ClickRerun: Found Rerun button-Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 500
        return true
    } else {
         DebugLog("ClickRerun: Rerun button NOT found!")
         return false
    }
     DebugLog("This should not be reached")
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
