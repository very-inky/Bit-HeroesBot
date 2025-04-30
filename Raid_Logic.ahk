;———————————————————————————————————————————————————————————————
; === Raid Flow ===
ActionRaid() {
    global Bot
    DebugLog("ActionRaid: --- Entered function ---")

    ; --- Check Configuration ---
    isObj := IsObject(Bot.Raid.Conf.List)
    maxIdx := ""
    if (isObj) {
            maxIdx := Bot.Raid.Conf.List.MaxIndex() 
               }
    DebugLog("ActionRaid: Config Check - IsObject(Bot.Raid.Conf.List) = " . isObj . ", Bot.Raid.Conf.List.MaxIndex() = " . maxIdx)
    if (!isObj || maxIdx = "" || maxIdx = 0) {
        DebugLog("ActionRaid: ERROR - Failed config check. No raids defined in Bot.Raid.Conf.List. Returning 'error'.")
        return "error"
    }
    if (Bot.Raid.Conf.CurrentIndex < 1 || Bot.Raid.Conf.CurrentIndex > Bot.Raid.Conf.List.MaxIndex()) {
        DebugLog("ActionRaid: Warning - Invalid Bot.Raid.Conf.CurrentIndex. Resetting to 1.")
        Bot.Raid.Conf.CurrentIndex := 1
    }

    ; --- Determine Target Raid ---
    configListIndex := Bot.Raid.Conf.CurrentIndex
    targetRaidName := Bot.Raid.Conf.List[configListIndex] ; Get the NAME (e.g., "Raid2")
    targetDifficulty := Bot.Raid.Conf.Difficulty

    ; *** NEW: Extract the numeric index FROM the NAME ***
    targetMappingIndex := SubStr(targetRaidName, 5) ; Extract number part (assumes format "RaidN")
    if (targetMappingIndex is not number or targetMappingIndex < 1) {
        DebugLog("ActionRaid: ERROR - Could not extract valid numeric index from raid name '" . targetRaidName . "'. Returning 'error'.")
        return "error"
    }
    ; Convert to integer just in case
    targetMappingIndex += 0 
    
    DebugLog("ActionRaid: Config List Index: " . configListIndex . ", Target Raid Name: '" . targetRaidName . "', Target Mapping Index: " . targetMappingIndex . ", Difficulty: '" . targetDifficulty . "'")


    ; --- Navigation ---
    DebugLog("ActionRaid: Checking if Raid window is open...")
    if (!IsRaidWindowOpen()) {
        DebugLog("ActionRaid: Raid window not open. Clicking Raid icon...")
        if (!ClickRaidIcon()) {
            DebugLog("ActionRaid: ClickRaidIcon failed. Returning 'retry'.")
            return "retry"
        }
        Sleep, 900
        if (!IsRaidWindowOpen()) {
            DebugLog("ActionRaid: Raid window did not appear after clicking icon. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionRaid: Raid window opened.")
    } else {
        DebugLog("ActionRaid: Raid window already open.")
    }

    ; --- Select Raid (Using Correct Target Index) ---
    ; *** Call the helper using the correct MAPPING INDEX ***
    DebugLog("ActionRaid: Ensuring correct raid (Mapping Index: " . targetMappingIndex . ") is selected...")
    if (!EnsureCorrectRaidSelected(targetMappingIndex)) {
        DebugLog("ActionRaid: EnsureCorrectRaidSelected failed for index '" . targetMappingIndex . "'. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionRaid: Successfully ensured raid index '" . targetMappingIndex . "' is selected.")
    Sleep, 500

    ; --- Click SUMMON Button ---
    DebugLog("ActionRaid: Clicking Raid Summon button...")
    if (!ClickRaidSummonButton()) {
        DebugLog("ActionRaid: ClickRaidSummonButton failed. Returning 'retry'.")
        return "retry"
    }
     DebugLog("ActionRaid: Clicked Raid Summon button.")
    Sleep, 1000

 ; --- *** NEW: Handle Pre-Raid Dialogue (Looping) *** ---
    DebugLog("ActionRaid: Checking for pre-raid dialogue...")
    dialogueAttempts := 0
    maxDialogueAttempts := 9 ; Try up to 9 times to close dialogue
    Loop, %maxDialogueAttempts%
    {
        dialogueFound := ClickPreRaidDialogue()
        if (!dialogueFound) { ; Dialogue is not present
            if (A_Index = 1) { ; Dialogue wasn't found on the very first check
                 DebugLog("ActionRaid: No pre-raid dialogue detected.")
            } else { ; Dialogue was found previously but is now gone
                 DebugLog("ActionRaid: Dialogue successfully closed after " . (A_Index - 1) . " attempt(s).")
            }
            break ; Exit the dialogue handling loop
        }
        ; If dialogue WAS found...
        DebugLog("ActionRaid: Dialogue found (Attempt " . A_Index . "). Esc sent by handler. Waiting...")
        Sleep, 750 ; Wait longer for Esc to take effect before checking again
    }

    ; Check if the loop finished because dialogue is gone, or because attempts ran out
    if (dialogueFound) { ; If dialogueFound is still true, the loop finished without breaking
        DebugLog("ActionRaid: ERROR - Dialogue still present after " . maxDialogueAttempts . " attempts! Returning 'retry'.")
        return "retry"
    }
    
    ; --- Select Difficulty ---
    DebugLog("ActionRaid: Selecting Difficulty '" . targetDifficulty . "'...")
    if (!SelectRaidDifficulty(targetDifficulty)) {
        DebugLog("ActionRaid: SelectRaidDifficulty failed for '" . targetDifficulty . "'. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionRaid: Successfully selected difficulty '" . targetDifficulty . "'.")
    Sleep, 700

    ; --- Start Raid (Click Play Button) ---
    DebugLog("ActionRaid: Clicking Play button...")
    if (!ClickRaidPlayButton()) {
        DebugLog("ActionRaid: ClickRaidPlayButton failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionRaid: Clicked Play button.")
    Sleep, 1000

    ; --- Check Resources ---
    if (CheckOutOfResources()) {
        DebugLog("ActionRaid: Out of resources detected after clicking Play. Returning 'outofresource'.")
        return "outofresource"
    }
    DebugLog("ActionRaid: No 'Out Of Resources' detected after clicking Play.")

    DebugLog("ActionRaid: Performing one-time AutoPilot check.")
    autoPilotOk := EnsureAutoPilotOn() ; Assumes this function has own logs
    if (!autoPilotOk) {
        DebugLog("ActionRaid: Warning - EnsureAutoPilotOn failed after starting")
        ; Continue anyway
    } else {
         DebugLog("ActionRaid: EnsureAutoPilotOn completed successfully (check its logs for details).")
    }

    DebugLog("ActionRaid: --- Success! Raid started. Returning 'started'. ---")
    return "started"
}

MonitorRaidProgress() {
    global Bot
    ; Note: BotMain logs "monitoring Raid"

    ; 1. Check for Completion first (using IsRaidComplete helper)
    isComplete := IsActionComplete()
    DebugLog("MonitorRaid: IsActionComplete returned true")
    if (isComplete) {
        DebugLog("MonitorRaid: Raid Complete detected.")

        ; Check if configured for single raid or multiple
        if (Bot.Raid.Conf.List.MaxIndex() = 1) {
            ; --- SINGLE RAID CONFIG: Attempt Rerun ---
            DebugLog("MonitorRaid: Single raid config - attempting Rerun.")
            if (ClickRerun()) {
                 DebugLog("MonitorRaid: ClickRerun succeeded. Sleeping and checking resources...")
                 Sleep, 2000 ; Wait after clicking rerun
                 outOfRes := CheckOutOfResources() ; Check resources AFTER clicking rerun
                 returnVal := outOfRes ? "outofresource" : "raid_rerun" ; Return "raid_rerun" if resources OK
                 DebugLog("MonitorRaid: Rerun attempt finished. Returning '" . returnVal . "'")
                 return returnVal
            } else {
                 DebugLog("MonitorRaid: ClickRerun failed. Returning 'error'.")
                 return "error" ; Failed to click Rerun
            }

        } else {
            ; --- MULTI RAID CONFIG: Attempt Town/Exit ---
            DebugLog("MonitorRaid: Multi-raid config - attempting ClickTownOnComplete.")
            if (ClickTownOnComplete()) { ; Reuse the generic Town button clicker
                 DebugLog("MonitorRaid: ClickTownOnComplete succeeded.")
                 Sleep, 1000 ; Wait after clicking town
                 ; NOTE: We don't usually need to check resources when just exiting to town.
                 DebugLog("MonitorRaid: Returning 'raid_completed_next'.")
                 return "raid_completed_next" ; Signal BotMain to setup next raid in list
            } else {
                 DebugLog("MonitorRaid: ClickTownOnComplete failed. Looking for Raid Accept button as fallback...")
                 ; Fallback: Maybe an "Accept" button instead of "Town"?
                 acceptClicked := ClickRaidAccept()
                 if (acceptClicked) {
                     DebugLog("MonitorRaid: ClickRaidAccept (fallback) succeeded.")
                     Sleep, 1000
                     DebugLog("MonitorRaid: Returning 'raid_completed_next'.")
                     return "raid_completed_next" ; Signal BotMain to setup next raid
                 } else {
                     DebugLog("MonitorRaid: ERROR - Neither Town nor Accept button found after multi-raid completion.")
                     return "error" ; Stuck on completion screen
                 }
            }
        }
    }

    ; 2. If NOT complete, check for Failure/Interrupt States
    disconnected := IsDisconnected()
    DebugLog("MonitorRaid: IsDisconnected returned: '" . (disconnected ? "True" : "False") . "'")
    if (disconnected) {
        DebugLog("MonitorRaid: Disconnected detected.")
        AttemptReconnect()
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorRaid: State changed to NotLoggedIn. Returning 'disconnected'.")
        return "disconnected"
    }

    playerDead := IsPlayerDead()
    DebugLog("MonitorRaid: IsPlayerDead returned: '" . (playerDead ? "True" : "False") . "'")
    if (playerDead) {
        DebugLog("MonitorRaid: Player Dead detected.")
        Send, {Esc} ; Try to dismiss
        Sleep, 800
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorRaid: State changed to NotLoggedIn. Returning 'player_dead'.")
        return "player_dead"
    }

    ; Removed the CheckOutOfResources from here, as per your request

    ; Check for in-progress dialogue
    dialogueHandled := HandleInProgressDialogue()
    if (dialogueHandled) {
        DebugLog("MonitorRaid: Handled in-progress dialogue during raid.")
        ; Continue monitoring after handling
    }

    ; 3. Still In Progress
    DebugLog("MonitorRaid: No end/fail/dialogue state change detected. Returning 'in_progress'.")
    return "in_progress"
}


; --- Raid Helpers ---
IsRaidWindowOpen() {
    global Bot
    DebugLog("IsRaidWindowOpen: Checking for Raid window pattern...")
    result := FindText(X, Y, 376, 409, 2761, 1746, 0, 0, Bot.ocr.RaidWindow) 
    found := result ? "True" : "False"
    DebugLog("IsRaidWindowOpen: FindText result: " . found)
    return result
}

ClickRaidIcon() {
    global Bot
    DebugLog("ClickRaidIcon: Searching for Raid icon on main screen...")
    if FindText(X, Y, 710, 1014, 858, 1158, 0, 0, Bot.ocr.RaidIcon) {
        DebugLog("ClickRaidIcon: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 900 ; Short sleep after click
        return true
    } else {
        DebugLog("ClickRaidIcon: Raid icon NOT found!")
        return false
    }
}

EnsureCorrectRaidSelected(targetRaidIndex) {
    global Bot
    DebugLog("EnsureCorrectRaidSelected: --- OPTIMIZED Entered Function --- Target Index: " . targetRaidIndex)

    ; --- Step 1: Detect Current Raid Index (with retry) ---
    currentIndex := 0 ; Initialize to 0 (failure state)
    Loop, 2 ; Try up to 2 times to detect the current raid
    {
        DebugLog("EnsureCorrectRaidSelected: Detecting current raid index (Attempt " . A_Index . " of 2)...")
        currentIndex := DetectCurrentlyDisplayedRaidIndex()
        if (currentIndex != 0) { ; If detection succeeded
            DebugLog("EnsureCorrectRaidSelected: Detected index '" . currentIndex . "' on attempt " A_Index . ".")
            break ; Exit the detection loop
        }
        if (A_Index = 1) { ; If first attempt failed, wait before retrying
            DebugLog("EnsureCorrectRaidSelected: Attempt 1 failed. Sleeping 500ms before retry.")
            Sleep, 500
        }
    }

    ; Check if detection failed after all attempts
    if (currentIndex = 0) {
        DebugLog("EnsureCorrectRaidSelected: Failed to detect initial raid index after 2 attempts. Returning False.")
        return false
    }

    ; --- Proceed only if detection was successful ---
    DebugLog("EnsureCorrectRaidSelected: Initial detected index: '" . currentIndex . "'")

    if (currentIndex = targetRaidIndex) { ; Already on the correctraid
        DebugLog("EnsureCorrectRaidSelected: Already on target raid index " . targetRaidIndex . ". Returning True.")
        return true
    }

    ; --- Step 2: Calculate Clicks Needed ---
    totalRaids := Bot.ocr.RaidMapping.MaxIndex() ; Get total number of raids defined
    if (totalRaids <= 1) { ; Should not happen if check passed in ActionRaid, but safety check
         DebugLog("EnsureCorrectRaidSelected: Only 1 or fewer raids defined in mapping. Cannot navigate.")
         return (currentIndex = targetRaidIndex) ; Return true only if already correct
    }

    ; Calculate distance in both directions (handling wrap-around)
    diffRight := targetRaidIndex - currentIndex
    if (diffRight < 0) { ; Wrap around going right (e.g., from 10 to 2)
        diffRight += totalRaids
    }

    diffLeft := currentIndex - targetRaidIndex
    if (diffLeft < 0) { ; Wrap around going left (e.g., from 2 to 10)
         diffLeft += totalRaids
    }

    ; Determine direction and number of clicks
    numClicks := 0
    clickDirection := ""
    if (diffLeft < diffRight) {
        numClicks := diffLeft
        clickDirection := "Left"
    } else { ; Includes diffLeft = diffRight case, prefer right? Or choose based on shortest path? Let's prefer right if equal.
        numClicks := diffRight
        clickDirection := "Right"
    }

    if (numClicks = 0) { ; Should only happen if current = target, already handled
        DebugLog("EnsureCorrectRaidSelected: Calculated 0 clicks needed? Returning True (already correct).")
        return true
    }

    DebugLog("EnsureCorrectRaidSelected: Need to click " . clickDirection . " " . numClicks . " time(s).")

    ; --- Step 3: Perform Arrow Clicks ---
    Loop, %numClicks%
    {
        DebugLog("EnsureCorrectRaidSelected: Clicking " . clickDirection . " Arrow (Click " . A_Index . " of " . numClicks . ")")
        if (clickDirection = "Left") {
            if (!ClickRaidLeftArrow()) { ; Check if click function indicated failure
                 DebugLog("EnsureCorrectRaidSelected: ClickRaidLeftArrow failed during loop. Aborting.")
                 return false ; Abort if arrow not found
            }
        } else { ; Must be Right
            if (!ClickRaidRightArrow()) {
                 DebugLog("EnsureCorrectRaidSelected: ClickRaidRightArrow failed during loop. Aborting.")
                 return false ; Abort if arrow not found
            }
        }
        Sleep, 150 ; Smaller sleep between clicks - adjust if needed
    }

    ; --- Step 4: Final Verification ---
    DebugLog("EnsureCorrectRaidSelected: Finished clicking arrows. Verifying final position...")
    Sleep, 600 ; Wait a bit longer for screen to settle after last click

    finalIndex := DetectCurrentlyDisplayedRaidIndex()
    DebugLog("EnsureCorrectRaidSelected: Final detected index: '" . finalIndex . "'")

    if (finalIndex = targetRaidIndex) {
        DebugLog("EnsureCorrectRaidSelected: --- Success! Target raid index '" . targetRaidIndex . "' is displayed. ---")
        return true
    } else {
        DebugLog("EnsureCorrectRaidSelected: --- Failed! Target raid index '" . targetRaidIndex . "' NOT displayed after clicking. Detected '" . finalIndex . "' instead. ---")
        return false
    }
}

DetectCurrentlyDisplayedRaidIndex() {
    global Bot
    DebugLog("DetectCurrentlyDisplayedRaidIndex: --- Entered function ---")

    for index, pattern in Bot.ocr.RaidMapping {
        if (pattern = "") ; Skip empty patterns if any
            continue
        if FindText(X, Y, 603, 462, 2539, 1728, 0, 0, pattern) {
            DebugLog("DetectCurrentlyDisplayedRaidIndex: Found pattern for index " . index . ". --- Exiting function ---")
            return index ; Return the INDEX (1, 2, 3...)
        }
    }
    DebugLog("DetectCurrentlyDisplayedRaidIndex: No known raid pattern found! --- Exiting function ---")
    return 0 ; Return 0 if no known raid found
}

ClickRaidLeftArrow() {
    global Bot
    DebugLog("ClickRaidLeftArrow: Searching for Raid Left Arrow...")

    if FindText(X, Y, 629, 492, 1603, 1678, 0, 0, Bot.ocr.RaidLeftArrow) {
        DebugLog("ClickRaidLeftArrow: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 400 ; Short sleep after click
        return true
    } else {
        DebugLog("ClickRaidLeftArrow: Arrow NOT found!")
        return false
    }
}

ClickRaidRightArrow() {
    global Bot
    DebugLog("ClickRaidRightArrow: Searching for Raid Right Arrow...")

    if FindText(X, Y, 1587, 480, 2571, 1662, 0, 0, Bot.ocr.RaidRightArrow) {
        DebugLog("ClickRaidRightArrow: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 400 ; Short sleep after click
        return true
    } else {
        DebugLog("ClickRaidRightArrow: Arrow NOT found!")
        return false
    }
}

ClickRaidSummonButton() {
    global Bot
    DebugLog("ClickRaidSummonButton: Searching for Raid Summon button...")
    if FindText(X, Y, 659, 482, 2521, 1642, 0, 0, Bot.ocr.Button.RaidSummon) {
        DebugLog("ClickRaidSummonButton: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 900 ; Short sleep after click
        return true
    } else {
        DebugLog("ClickRaidSummonButton: Raid Summon button NOT found!")
        return false
    }
}

ClickPreRaidDialogue() {
    global Bot
    DebugLog("ClickPreRaidDialogue: Searching for Pre-Raid dialogue...")
    if FindText(X, Y, 1868, 617, 2804, 1745, 0, 0, Bot.ocr.PreRaidDialogue) {
        DebugLog("ClickPreRaidDialogue: Found. Sending {Esc}.")
        Send, {Esc}
        Sleep, 200 ; Short sleep after sending key
        return true
    }
    return false
}

SelectRaidDifficulty(difficultyName) {
    global Bot
    DebugLog("SelectRaidDifficulty: Attempting to select difficulty '" . difficultyName . "'...")
    if (!Bot.ocr.RaidDifficulty.HasKey(difficultyName)) {
        DebugLog("SelectRaidDifficulty: ERROR - Pattern for difficulty '" . difficultyName . "' not defined.")
        return false
    }
    diffPattern := Bot.ocr.RaidDifficulty[difficultyName]
    ; Adjust search region for difficulty buttons
    if (FindText(X, Y, 697, 496, 2495, 1651, 0, 0, diffPattern)) {
        DebugLog("SelectRaidDifficulty: Found pattern for '" . difficultyName . "'. Clicking.")
        FindText().Click(X, Y, "L")
        ; Optional: Add verification step if needed
        return true
    } else {
        DebugLog("SelectRaidDifficulty: Pattern for '" . difficultyName . "' not found.")
        return false
    }
}

ClickRaidPlayButton() {
    global Bot
    DebugLog("ClickRaidPlayButton: Searching for Play button...")
    ; Adjust search region for the play button
    if (FindText(X, Y, 1861-150000, 1539-150000, 1861+150000, 1539+150000, 0, 0, Bot.ocr.Button.Accept)) {
        DebugLog("ClickRaidPlayButton: Found. Clicking.")
        FindText().Click(X, Y, "L")
        return true
    } else {
        DebugLog("ClickRaidPlayButton: Play button not found.")
        return false
    }
}

IsRaidComplete() {
    global Bot
    DebugLog("IsRaidComplete: Checking for Raid completion screen...")
    ; Adjust search region for completion indicators
    result := FindText(X, Y, 800, 300, 2400, 1000, 0, 0, Bot.ocr.Raid.CompletionScreen)
    found := result ? "True" : "False"
    DebugLog("IsRaidComplete: FindText result: " . found)
    return result
}


ClickRaidAccept() {
    global Bot
    DebugLog("ClickRaidAccept: Searching for Accept button on completion screen...")
    ; Adjust search region for the accept button after a raid
    if (FindText(X, Y, 1500, 1400, 2200, 1700, 0, 0, Bot.ocr.Button.Rerun)) { ; Might be same pattern as Bot.ocr.Button.Accept
        DebugLog("ClickRaidAccept: Found. Clicking.")
        FindText().Click(X, Y, "L")
        return true
    } else {
        DebugLog("ClickRaidAccept: Accept button not found.")
        return false
    }
}