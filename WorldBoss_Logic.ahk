Bot.WorldBoss.UiOrder := [ "Orlag Clan"
                         , "Netherworld"
                         , "Melvin Factory"
                         , "Extermination"
                         , "Brimstone Syndicate"
                         , "Titans Attack"
                         , "The Ignited Abyss"
                         , "Project Goodall" ]


Bot.ocr.WorldBossValidTiers := { "Orlag Clan":          [12, 11, 10, 9, 8, 7, 6, 5, 4, 3] ; Highest to lowest
    , "Netherworld":         [13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3]
    , "Melvin Factory":      [11, 10]
    , "Extermination":       [11, 10]
    , "Brimstone Syndicate": [12, 11]
    , "Titans Attack":       [14, 13, 12, 11]
    , "The Ignited Abyss":   [14, 13]
    , "Project Goodall":     [14, 7] }

ActionWorldBoss() {
    global Bot
    DebugLog("ActionWorldBoss: --- Entered function ---")

    ; --- 1. Get Configuration ---
    configListIndex := Bot.WorldBoss.Conf.CurrentIndex
    if (!IsObject(Bot.WorldBoss.Conf.List) || configListIndex < 1 || configListIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
        DebugLog("ActionWorldBoss: ERROR - Invalid World Boss configuration or index. Resetting index to 1 and returning 'retry'.")
        Bot.WorldBoss.Conf.CurrentIndex := 1
        return "retry"
    }
    currentConfig := Bot.WorldBoss.Conf.List[configListIndex]
    targetBossName := currentConfig.Name
    targetTier := currentConfig.Tier
    targetDifficulty := Bot.WorldBoss.Conf.Difficulty
    DebugLog("ActionWorldBoss: Target Boss: '" . targetBossName . "', Target Tier Config: '" . targetTier . "', Difficulty: '" . targetDifficulty . "'") ; Log the configured tier

    ; --- 2. Navigation
    DebugLog("ActionWorldBoss: Clicking WB icon...")
    if (!ClickWorldBossIcon()) {
        DebugLog("ActionWorldBoss: ClickWorldBossIcon failed. Returning 'retry'.")
        return "retry"
    }
    Sleep, 990
    if (!IsWorldBossWindowOpen()) {
        DebugLog("ActionWorldBoss: WB window did not appear after clicking icon. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: WB window opened successfully.")


    ; --- 3. Click Initial Summon Button ---
    DebugLog("ActionWorldBoss: Clicking initial Summon button...")
    if (!ClickWorldBossSummonButton()) {
        DebugLog("ActionWorldBoss: Initial Summon click failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: Initial Summon button clicked.")
    Sleep, 500

    ; --- 4 & 5. Ensure Correct Boss is Selected (Detect & Navigate) ---
    DebugLog("ActionWorldBoss: Ensuring correct boss '" . targetBossName . "' is selected...")
    if (!EnsureCorrectWorldBossSelected(targetBossName)) {
        DebugLog("ActionWorldBoss: EnsureCorrectWorldBossSelected failed for '" . targetBossName . "'. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: Successfully ensured boss '" . targetBossName . "' is selected.")
    Sleep, 500

    ; --- 6. Click Summon Again (After Selecting Boss) ---
    DebugLog("ActionWorldBoss: Clicking Summon button again (after boss selection)...")
    if (!ClickWorldBossSummonButton()) {
        DebugLog("ActionWorldBoss: Second Summon click failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: Second Summon button clicked.")
    Sleep, 800

    resolvedTier := targetTier ; Initialize
    if (targetTier = "HighestAvailable") {
        DebugLog("ActionWorldBoss: 'HighestAvailable' tier requested. Finding highest available tier...")
        resolvedTier := FindHighestAvailableTier(targetBossName)
        if (resolvedTier <= 0) { ; Check if FindHighestAvailableTier failed
            DebugLog("ActionWorldBoss: ERROR - Could not find any available tier for '" . targetBossName . "' (Highest). Skipping this config.")
            Bot.WorldBoss.Conf.CurrentIndex += 1 ; Advance index
            if (Bot.WorldBoss.Conf.CurrentIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
                Bot.WorldBoss.Conf.CurrentIndex := 1
            }
            DebugLog("ActionWorldBoss: Advanced WB index to " . Bot.WorldBoss.Conf.CurrentIndex . ". Returning 'success' to advance main action loop.")
            return "success" ; Treat as success to move to next config/action ?
        }
        DebugLog("ActionWorldBoss: Found highest available tier: " . resolvedTier)
    }
    else if (targetTier = "LowestAvailable") {
        DebugLog("ActionWorldBoss: 'LowestAvailable' tier requested. Finding lowest available tier...")
        resolvedTier := FindLowestAvailableTier(targetBossName)
        if (resolvedTier <= 0) { ; Check if FindLowestAvailableTier failed
            DebugLog("ActionWorldBoss: ERROR - Could not find any available tier for '" . targetBossName . "' (Lowest). Skipping this config.")
            Bot.WorldBoss.Conf.CurrentIndex += 1 ; Advance index
            if (Bot.WorldBoss.Conf.CurrentIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
                Bot.WorldBoss.Conf.CurrentIndex := 1
            }
            DebugLog("ActionWorldBoss: Advanced WB index to " . Bot.WorldBoss.Conf.CurrentIndex . ". Returning 'success' to advance main action loop.")
            return "success"
        }
        DebugLog("ActionWorldBoss: Found lowest available tier: " . resolvedTier)
    }


    ; 7. Select Tier
    DebugLog("ActionWorldBoss: Selecting Tier '" . resolvedTier . "' for Boss '" . targetBossName . "'...")
    selectTierAttempts := 0
    maxSelectTierAttempts := 7 ; Outer loop for major retries (e.g., if detection fails initially)
    selectedTierResult := false
    Loop, % maxSelectTierAttempts {
        selectTierAttempts := A_Index
        DebugLog("ActionWorldBoss: Calling SelectWorldBossTier (Outer Attempt " . selectTierAttempts . "/" . maxSelectTierAttempts . ")")
        selectedTierResult := SelectWorldBossTier(targetBossName, resolvedTier)

        if (selectedTierResult = "invalid_tier") {
             DebugLog("ActionWorldBoss: Tier '" . resolvedTier . "' is invalid/unavailable. Skipping config.")
             Bot.WorldBoss.Conf.CurrentIndex += 1
             if (Bot.WorldBoss.Conf.CurrentIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
                 Bot.WorldBoss.Conf.CurrentIndex := 1
             }
             DebugLog("ActionWorldBoss: Advanced WB index to " . Bot.WorldBoss.Conf.CurrentIndex . ". Returning 'success'.")
             return "success"
        } else if (selectedTierResult = true) {
            DebugLog("ActionWorldBoss: SelectWorldBossTier returned true. Tier selected.")
            break ; Success
        } else { ; selectedTierResult is "retry"
            DebugLog("ActionWorldBoss: SelectWorldBossTier returned 'retry'. Retrying outer loop...")
            Sleep, 600 ; Wait before retrying the entire function
        }
    }

    ; Check result after the outer loop
    if (selectedTierResult != true) {
        DebugLog("ActionWorldBoss: Failed to select Tier '" . resolvedTier . "' after " . maxSelectTierAttempts . " outer attempts. Returning 'retry'.")
        return "retry"
    }
    ; 

    DebugLog("ActionWorldBoss: Successfully selected tier.")
    Sleep, 500

     ; 8. Select Difficulty 
     DebugLog("ActionWorldBoss: Selecting Difficulty '" . targetDifficulty . "'...")
     if (!SelectWorldBossDifficulty(targetDifficulty)) {
         DebugLog("ActionWorldBoss: SelectWorldBossDifficulty failed for '" . targetDifficulty . "'. Returning 'retry'.")
         return "retry"
     }
     DebugLog("ActionWorldBoss: Successfully selected difficulty '" . targetDifficulty . "'.")
     Sleep, 500

    ; 9. Check/Toggle Private Lobby 
    DebugLog("ActionWorldBoss: Ensuring Private Lobby is ON...")
    if (!EnsureWorldBossPrivateLobby()) {
         DebugLog("ActionWorldBoss: EnsureWorldBossPrivateLobby failed. Returning 'retry'.")
         return "retry"
    }
    DebugLog("ActionWorldBoss: Private Lobby confirmed ON.")
    Sleep, 300

    ;  10. Click Final Summon/Attack Button
    DebugLog("ActionWorldBoss: Clicking final Summon button...")
    if (!ClickWorldBossSummonButton()) { ; Assuming this is the final button
        DebugLog("ActionWorldBoss: ClickWorldBossSummonButton failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: Clicked final Attack/Summon button.")
    Sleep, 1000

    if (CheckOutOfResources()) {
        DebugLog("ActionWorldBoss: Out of resources detected before final Start. Returning 'outofresource'.") // Corrected log context
        return "outofresource"
    }

    ; 10a & 11. Attempt to Start WB and Handle Confirmation
    DebugLog("ActionWorldBoss: Attempting to start WB and handle confirmation...")
    startResult := AttemptWorldBossStartWithConfirmation("ActionWorldBoss")

    if (startResult = "start_failed") {
        DebugLog("ActionWorldBoss: AttemptWorldBossStartWithConfirmation indicated 'start_failed'. Returning 'retry'.")
        return "retry"
    } else if (startResult = "success_with_warning") {
        DebugLog("ActionWorldBoss: AttemptWorldBossStartWithConfirmation was 'success_with_warning' (warning clicked).")
    } else { ; success_no_warning
        DebugLog("ActionWorldBoss: AttemptWorldBossStartWithConfirmation was 'success_no_warning' (no warning needed/found).")
    }
    Sleep, 300 ; General pause after start sequence

    ; --- 12. Check Resources ---
    if (CheckOutOfResources()) {
        DebugLog("ActionWorldBoss: Out of resources detected after starting attack. Returning 'outofresource'.")
        return "outofresource"
    }
    DebugLog("ActionWorldBoss: No 'Out Of Resources' detected.")

    ; --- ADDED: 12a. Ensure Autopilot is On ---
    DebugLog("ActionWorldBoss: Performing one-time AutoPilot check.")
    autoPilotOk := EnsureAutoPilotOn() ; Assumes this function has own logs
    if (!autoPilotOk) {
        DebugLog("ActionWorldBoss: Warning - EnsureAutoPilotOn failed after starting")
        ; Continue anyway, AutoPilot isn't critical for starting
    } else {
         DebugLog("ActionWorldBoss: EnsureAutoPilotOn completed successfully (check its logs for details).")
    }


    ; NOTE: Index advancement now happens in BotMain after monitor confirms completion
    DebugLog("ActionWorldBoss: --- Success! WB Started. Returning 'started'. ---")
    return "started"
}

; --- Monitor function for World Boss ---
MonitorWorldBossProgress() {
    global Bot
    DebugLog("MonitorWorldBossProgress: --- Entered function ---")
    if (IsActionComplete()) {
        DebugLog("MonitorWorldBoss: Completion screen detected.")
        Sleep, 500

        if (ClickRegroupOnComplete()) {
            DebugLog("MonitorWorldBoss: ClickRegroupOnComplete succeeded.")
            Sleep, 500

            ; --- ADDED: Conditional logic based on config count ---
            if (IsObject(Bot.WorldBoss.Conf.List) && Bot.WorldBoss.Conf.List.MaxIndex() > 1) {
                ; Multiple configs exist: Advance to the next one
                DebugLog("MonitorWorldBoss: Multiple WB configs detected. Returning 'worldboss_completed' to advance.")
                return "worldboss_completed"
            } else {
                ; Only one config (or error): Rerun the current one
                DebugLog("MonitorWorldBoss: Single WB config detected. Rerunning current config.")

                ; --- Re-run sequence: use helper function ---
                DebugLog("MonitorWorldBoss: Attempting to restart WB (rerun) and handle confirmation...")
                startResult := AttemptWorldBossStartWithConfirmation("MonitorWorldBossRerun")

                if (startResult = "start_failed") {
                    DebugLog("MonitorWorldBoss: AttemptWorldBossStartWithConfirmation indicated 'start_failed' for rerun. Returning 'error'.")
                    return "error"
                } else if (startResult = "success_with_warning") {
                    DebugLog("MonitorWorldBoss: Rerun start was 'success_with_warning' (warning clicked).")
                } else { ; success_no_warning
                    DebugLog("MonitorWorldBoss: Rerun start was 'success_no_warning' (no warning needed/found).")
                }
                Sleep, 300 ; General pause after start sequence

                ; --- Check resources AFTER attempting start ---
                if (CheckOutOfResources()) {
                    DebugLog("MonitorWorldBoss: Out of resources detected during rerun attempt. Returning 'outofresource'.")
                    return "outofresource"
                }

                DebugLog("MonitorWorldBoss: Rerun initiated. Returning 'in_progress' to continue monitoring.")
                return "in_progress"
            }
        } else {
            DebugLog("MonitorWorldBoss: WARNING - Failed regroup click; exiting monitor.")
            Send, {Esc}
            Sleep, 500
            return "error"
        }
    }

    ; 2. Check for Failure/Interrupt States
    disconnected := IsDisconnected()
    DebugLog("MonitorWorldBoss: IsDisconnected returned: '" . (disconnected ? "True" : "False") . "'")
    if (disconnected) {
        DebugLog("MonitorWorldBoss: Disconnected detected.")
        AttemptReconnect()
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorWorldBoss: State changed to NotLoggedIn. Returning 'disconnected'.")
        return "disconnected"
    }

    playerDead := IsPlayerDead()
    DebugLog("MonitorWorldBoss: IsPlayerDead returned: '" . (playerDead ? "True" : "False") . "'")
    if (playerDead) {
        DebugLog("MonitorWorldBoss: Player Dead detected.")
        Send, {Esc} ; Try to dismiss
        Sleep, 800
        Bot.gameState := "NotLoggedIn" ; Change state directly here
        DebugLog("MonitorWorldBoss: State changed to NotLoggedIn. Returning 'player_dead'.")
        return "player_dead" ; Return the specific state
    }


    dialogueHandled := HandleInProgressDialogue()
    if (dialogueHandled) {
        DebugLog("MonitorWorldBoss: Handled in-progress dialogue during World Boss.")
    }


    DebugLog("MonitorWorldBoss: No end/fail/dialogue state change detected. Returning 'in_progress'.")
    return "in_progress"
}

; --- World Boss Helpers ---
IsWorldBossWindowOpen() {
    global Bot
    DebugLog("IsWorldBossWindowOpen: Checking for WB window anchor.")
    if (FindText(X, Y, 1476-150000, 689-150000, 1476+150000, 689+150000, 0, 0, Bot.ocr.WorldBossWindowAnchor)) {
        result := true
    } else {
        result := false
    }

    DebugLog("IsWorldBossWindowOpen: Result = " . result)
    return result
}

ClickWorldBossIcon() {
    global Bot
    DebugLog("ClickWorldBossIcon: Searching for WB main icon.")
    if (FindText(X, Y, 801-150000, 901-150000, 801+150000, 901+150000, 0, 0, Bot.ocr.WorldBossMainIcon)) {
        DebugLog("ClickWorldBossIcon: Found WB icon. Clicking.")
        FindText().Click(X, Y, 1) ; 1=Left click
        return true
    } else {
        DebugLog("ClickWorldBossIcon: WB icon not found.")
        return false
    }
}

ClickWorldBossSummonButton() { ; For the initial summon / potentially after selecting boss name
    global Bot
    DebugLog("ClickWorldBossSummonButton: Searching for WB Summon button...")
Loop, 7 {
    if FindText(X, Y, 684, 502, 2487, 1657, 0, 0, Bot.ocr.WorldBossSummonButton) {
         DebugLog("ClickWorldBossSummonButton: Found. Clicking.")
         FindText().Click(X, Y, "L")
         Sleep, 500
         return true
     } else {
         DebugLog("ClickWorldBossSummonButton: Summon button NOT found!")
     }
    }
    DebugLog("ClickWorldBossSummonButton: Failed to find Summon button after 3 attempts.")
    return false
}

DetectCurrentWorldBossName() {
    global Bot
    DebugLog("DetectCurrentWorldBossName: --- Entered function ---")
    if (!IsObject(Bot.ocr.WorldBossNames)) {
         DebugLog("DetectCurrentWorldBossName: ERROR - Bot.ocr.WorldBossNames is not defined as an object in Patterns.ahk")
         return ""
    }
    for name, pattern in Bot.ocr.WorldBossNames {
        if (pattern = "") {
            DebugLog("DetectCurrentWorldBossName: WARNING - Pattern for '" . name . "' is empty!!! Oh no!")
            continue
        }
        if FindText(X, Y, 441, 679, 2502, 1816, 0, 0, pattern) {
            DebugLog("DetectCurrentWorldBossName: Found Boss Name '" . name . "'. --- Exiting function ---")
            return name
        }
    }
    DebugLog("DetectCurrentWorldBossName: No known WB name pattern found!")
    return "" ; Return empty if none found
}

ClickWorldBossLeftArrow() {
    global Bot
    DebugLog("ClickWorldBossLeftArrow: Searching for WB Left Arrow...")
    if FindText(X, Y, 629, 492, 1603, 1678, 0, 0, Bot.ocr.RaidLeftArrow) { ;WE ARE USING RAID LEFT ARROW FOR NOW because its an exact match. No need to define the same pattern twice.
        DebugLog("ClickWorldBossLeftArrow: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 400
        return true
    } else {
        DebugLog("ClickWorldBossLeftArrow: Arrow NOT found!")
        return false
    }
}

ClickWorldBossRightArrow() {
    global Bot
    DebugLog("ClickWorldBossRightArrow: Searching for WB Right Arrow...")
    if FindText(X, Y, 1587, 480, 2571, 1662, 0, 0, Bot.ocr.RaidRightArrow) { ;Same as above
        DebugLog("ClickWorldBossRightArrow: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 400
        return true
    } else {
        DebugLog("ClickWorldBossRightArrow: Arrow NOT found!")
        return false
    }
}


GetWorldBossIndexByName(bossName) {
    global Bot
    if (!IsObject(Bot.WorldBoss.Conf.List))
        return 0
    for index, configObject in Bot.WorldBoss.Conf.List {
        if (configObject.Name = bossName) {
            return index
        }
    }
    return 0 ; Not found in configured list
}


GetWorldBossUiIndex(bossName) {
    global Bot
    if (!IsObject(Bot.WorldBoss.UiOrder)) {
        DebugLog("GetWorldBossUiIndex: ERROR - Bot.WorldBoss.UiOrder array not defined.")
        return 0
    }
    for index, nameInList in Bot.WorldBoss.UiOrder {
        if (nameInList = bossName) {
            return index
        }
    }
    DebugLog("GetWorldBossUiIndex: WARNING - Boss name '" . bossName . "' not found in Bot.WorldBoss.UiOrder.")
    return 0 ; Not found
}


EnsureCorrectWorldBossSelected(targetBossName) {
    global Bot
    DebugLog("EnsureCorrectWorldBossSelected: --- Entered Function --- Target Name: '" . targetBossName . "'")
    attempts := 0
    maxAttempts := 15 ; Adjust as needed


    targetUiIndex := GetWorldBossUiIndex(targetBossName)
    if (targetUiIndex = 0) {
        DebugLog("EnsureCorrectWorldBossSelected: ERROR - Target boss '" . targetBossName . "' not found in UI Order list. Cannot navigate effectively.")
        ; Optional: Fallback to simple right-click or just fail? Let's fail for now.
        return false
    }
    listLength := Bot.WorldBoss.UiOrder.MaxIndex()
    if (listLength = 0) {
        DebugLog("EnsureCorrectWorldBossSelected: ERROR - Bot.WorldBoss.UiOrder list is empty.")
        return false
    }
  


    Loop, % maxAttempts + 1 {
        currentBossName := DetectCurrentWorldBossName()
        DebugLog("EnsureCorrectWorldBossSelected: Detected '" . currentBossName . "' (Attempt " . attempts . ")")

        if (currentBossName = targetBossName) {
            DebugLog("EnsureCorrectWorldBossSelected: Correct boss is displayed. Returning True.")
            return true
        }

        if (attempts >= maxAttempts) {
            DebugLog("EnsureCorrectWorldBossSelected: Max attempts reached. Failed to find target boss.")
            break
        }

        ; --- UPDATED: Navigation Logic ---
        currentUiIndex := GetWorldBossUiIndex(currentBossName)
        if (currentUiIndex = 0) {
            DebugLog("EnsureCorrectWorldBossSelected: WARNING - Detected boss '" . currentBossName . "' not found in UI Order list. Defaulting to Right Arrow.")
            if (!ClickWorldBossRightArrow()) {
                 DebugLog("EnsureCorrectWorldBossSelected: Failed to click right arrow (fallback). Aborting.")
                 return false
            }
        } else {
            ; Calculate shortest path
            clicksRight := Mod(targetUiIndex - currentUiIndex + listLength, listLength)
            clicksLeft := Mod(currentUiIndex - targetUiIndex + listLength, listLength)
            DebugLog("EnsureCorrectWorldBossSelected: Clicks Right=" . clicksRight . ", Clicks Left=" . clicksLeft)

            if (clicksRight <= clicksLeft) {
                DebugLog("EnsureCorrectWorldBossSelected: Clicking Right Arrow (Attempt " . attempts . ")")
                if (!ClickWorldBossRightArrow()) {
                     DebugLog("EnsureCorrectWorldBossSelected: Failed to click right arrow. Aborting.")
                     return false
                }
            } else {
                DebugLog("EnsureCorrectWorldBossSelected: Clicking Left Arrow (Attempt " . attempts . ")")
                if (!ClickWorldBossLeftArrow()) {
                     DebugLog("EnsureCorrectWorldBossSelected: Failed to click left arrow. Aborting.")
                     return false
                }
            }
        }

        Sleep, 900
        attempts++
    }

    DebugLog("EnsureCorrectWorldBossSelected: --- Failed! Target boss '" . targetBossName . "' NOT displayed after " . attempts . " attempts. ---")
    return false
}


SelectWorldBossTier(targetBossName, targetTier) {
    global Bot
    DebugLog("SelectWorldBossTier: Target Tier = '" . targetTier . "' for Boss '" . targetBossName . "'")

    ; --- Ensure targetTier is numeric AFTER potential "HighestAvailable" resolution ---
    if !(targetTier is number) {
        DebugLog("SelectWorldBossTier: ERROR - Target Tier '" . targetTier . "' is not numeric at this stage. This shouldn't happen if 'HighestAvailable' was resolved correctly.")
        return "retry"
    }
    targetTierNum := targetTier + 0 ; Ensure it's treated as a number

    DebugLog("SelectWorldBossTier: Processing numeric Tier " . targetTierNum . ".")

    ; --- Check 1: Is the requested tier valid for this boss? ---
    tierIsValid := false
    if (Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        for index, validTierNum in Bot.Ocr.WorldBossValidTiers[targetBossName] {
            if (validTierNum = targetTierNum) {
                tierIsValid := true
                break
            }
        }
    }
    if (!tierIsValid) {
        DebugLog("SelectWorldBossTier: Requested Tier " . targetTierNum . " is not listed as valid for Boss '" . targetBossName . "'. Returning 'invalid_tier'.")
        return "invalid_tier"
    }

    ; --- Check 2: Determine Currently Selected Tier ---
    Sleep, 200
    currentlySelectedTier := -1 ; Default to unknown
    if (!IsObject(Bot.ocr.WorldBossTierSelected)) {
        DebugLog("SelectWorldBossTier: ERROR - Bot.ocr.WorldBossTierSelected pattern object not defined.")
        return "retry"
    }
    if (Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
  
        for index, validNum in Bot.Ocr.WorldBossValidTiers[targetBossName] {
            if (Bot.ocr.WorldBossTierSelected.HasKey(validNum) && Bot.ocr.WorldBossTierSelected[validNum] != "") {
                if FindText(X, Y, 635, 471, 2509, 1692, 0, 0, Bot.ocr.WorldBossTierSelected[validNum]) {
                    currentlySelectedTier := validNum
                    DebugLog("SelectWorldBossTier: Detected currently selected Tier: " . currentlySelectedTier)
                    break ; Found it
                }
            }
        }
    }
    if (currentlySelectedTier = -1) {
         DebugLog("SelectWorldBossTier: ERROR - Could not detect the currently selected tier.")
         return "retry"
    }

    ; --- Check 3: Compare and Click/Navigate if Necessary ---
    if (currentlySelectedTier = targetTierNum) {
        DebugLog("SelectWorldBossTier: Target Tier " . targetTierNum . " is already selected.")
        return true ; Already correct
    } else {
        DebugLog("SelectWorldBossTier: Target Tier " . targetTierNum . " is NOT selected (Current: " . currentlySelectedTier . "). Attempting to click or navigate...")

        ; --- Check 4: Is the pattern for the target clickable button defined? ---
        if (!Bot.ocr.WorldBossTierButton.HasKey(targetTierNum) || Bot.ocr.WorldBossTierButton[targetTierNum] = "") {
            DebugLog("SelectWorldBossTier: ERROR - Pattern for clickable Tier " . targetTierNum . " button is missing or empty.")
            return "retry"
        }
        tierPattern := Bot.ocr.WorldBossTierButton[targetTierNum]
        currentSelectedPattern := Bot.ocr.WorldBossTierSelected[currentlySelectedTier]

        ; --- Step 4: Click the CURRENTLY selected tier pattern to open/ensure list is open ---
        clickedCurrent := false
        if FindText(X, Y, 548, 458, 2546, 1723, 0, 0, currentSelectedPattern) {
            DebugLog("SelectWorldBossTier: Clicking currently selected Tier " . currentlySelectedTier . " to open list.")
            FindText().Click(X, Y, "L")
            Sleep, 600
            clickedCurrent := true

        } else {
            DebugLog("SelectWorldBossTier: WARNING - Could not find currently selected Tier " . currentlySelectedTier . " pattern to click open list. Proceeding to check target visibility.")
            ; Continue anyway, maybe list is already open or FindText failed
        }

        ; --- Step 5 & 6 Combined: Internal Loop for Clicking/Navigating ---
        maxInternalAttempts := 5
        Loop, % maxInternalAttempts {
            internalAttempt := A_Index
            DebugLog("SelectWorldBossTier: Internal attempt " . internalAttempt . "/" . maxInternalAttempts . " to find/navigate/click Tier " . targetTierNum)
            Sleep, 200

            ; --- Check if TARGET button is VISIBLE now ---
            if FindText(X, Y, 590, 466, 2513, 1724, 0, 0, tierPattern) {
                DebugLog("SelectWorldBossTier: Found VISIBLE clickable Tier " . targetTierNum . " button. Clicking.")
                FindText().Click(X, Y, "L")
                Sleep, 600

                ; --- Verification step ---
                Sleep, 200
                newlySelectedTier := -1
                if (Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
                    for index, validNum in Bot.Ocr.WorldBossValidTiers[targetBossName] {
                        if (Bot.ocr.WorldBossTierSelected.HasKey(validNum) && Bot.ocr.WorldBossTierSelected[validNum] != "") {
                            if FindText(X, Y, 609, 438, 2563, 1723, 0, 0, Bot.ocr.WorldBossTierSelected[validNum]) {
                                newlySelectedTier := validNum
                                DebugLog("SelectWorldBossTier: Re-detected selected Tier as: " . newlySelectedTier)
                                break
                            }
                        }
                    }
                }

                if (newlySelectedTier = targetTierNum) {
                     DebugLog("SelectWorldBossTier: Verified Tier " . targetTierNum . " is now selected. SUCCESS.")
                     return true
                } else {
                     DebugLog("SelectWorldBossTier: WARNING - Clicked VISIBLE Tier " . targetTierNum . ", but verification failed (Detected: " . newlySelectedTier . "). Continuing internal loop.")
                     ; Loop continues
                }
            } else {
                 DebugLog("SelectWorldBossTier: Clickable button for Tier " . targetTierNum . " not visible. Attempting navigation.")

                 ; --- Navigation Logic ---
                 if (targetTierNum > currentlySelectedTier) { ; Higher tiers are usually visually higher
                     DebugLog("SelectWorldBossTier: Target tier is higher. Clicking UP arrow.")
                     if (!ClickWorldBossNavigationUp()) {
                         DebugLog("SelectWorldBossTier: ERROR - Failed to click UP arrow. Returning 'retry'.")
                         return "retry" ; Critical error
                     }
                 } else { ; Target tier is lower
                     DebugLog("SelectWorldBossTier: Target tier is lower. Clicking DOWN arrow.")
                     if (!ClickWorldBossNavigationDown()) {
                         DebugLog("SelectWorldBossTier: ERROR - Failed to click DOWN arrow. Returning 'retry'.")
                         return "retry" ; Critical error
                     }
                 }
                 Sleep, 400

                 DebugLog("SelectWorldBossTier: Clicked navigation arrow. Continuing internal loop to check visibility/click again.")

            }
        }

        ; --- If internal loop finishes without returning true ---
        DebugLog("SelectWorldBossTier: Failed to select Tier " . targetTierNum . " after " . maxInternalAttempts . " internal attempts. Returning 'retry'.")
        return "retry" ; Signal outer loop in ActionWorldBoss to retry the whole function. This isn't graceful. Probably hangs if it fails here.
    }
}

SelectWorldBossDifficulty(difficultyName) {
    global Bot
    DebugLog("SelectWorldBossDifficulty: Attempting to ensure difficulty '" . difficultyName . "' is selected...")

    ; --- Check 1: Required Pattern Object ---
    if (!IsObject(Bot.ocr.WorldBossDifficultySelected)) {
        DebugLog("SelectWorldBossDifficulty: ERROR - Required pattern object WorldBossDifficultySelected not defined.")
        return false
    }
    if (!Bot.ocr.WorldBossDifficultySelected.HasKey(difficultyName)) {
        DebugLog("SelectWorldBossDifficulty: ERROR - Pattern for selected state of difficulty '" . difficultyName . "' not defined in WorldBossDifficultySelected.")
        return false
    }


    ; --- Check 2: Determine Currently Selected Difficulty ---

    currentlySelectedDifficulty := ""
    for knownDiffName, selectedPattern in Bot.ocr.WorldBossDifficultySelected {
        if (selectedPattern != "") {
            if FindText(X, Y, 605, 430, 2548, 1686, 0, 0, selectedPattern) {
                currentlySelectedDifficulty := knownDiffName
                DebugLog("SelectWorldBossDifficulty: Detected currently selected Difficulty: '" . currentlySelectedDifficulty . "'")
                break ; Found it
            }
        }
    }
    if (currentlySelectedDifficulty = "") {
         DebugLog("SelectWorldBossDifficulty: ERROR - Could not detect the currently selected difficulty.")
         return false
    }

    ; --- Check 3: Compare and Click if Necessary ---
    if (currentlySelectedDifficulty = difficultyName) {
        DebugLog("SelectWorldBossDifficulty: Target Difficulty '" . difficultyName . "' is already selected.")
        return true
    } else {
        DebugLog("SelectWorldBossDifficulty: Target Difficulty '" . difficultyName . "' is NOT selected (Current: '" . currentlySelectedDifficulty . "').")

        ; 1) Open the drop‑down by clicking the currently selected button
        if FindText(X, Y, 605, 430, 2548, 1686, 0, 0, Bot.ocr.WorldBossDifficultySelected[currentlySelectedDifficulty]) {
            DebugLog("SelectWorldBossDifficulty: Opening menu via current '" . currentlySelectedDifficulty . "'")
            FindText().Click(X, Y, "L")
            Sleep, 800
        } else {
            DebugLog("SelectWorldBossDifficulty: ERROR - Failed to click current difficulty to open menu.")
            return false
        }

        ; 2) Now find & click the desired difficulty
        if (!IsObject(Bot.ocr.WorldBossDifficultyButton)) {
            DebugLog("SelectWorldBossDifficulty: ERROR - Required pattern object WorldBossDifficultyButton not defined.")
            return false
        }
        if (!Bot.ocr.WorldBossDifficultyButton.HasKey(difficultyName)) {
            DebugLog("SelectWorldBossDifficulty: ERROR - Pattern for clickable button of difficulty '" . difficultyName . "' not defined in WorldBossDifficultyButton.")
            return false
        }
        diffPattern := Bot.ocr.WorldBossDifficultyButton[difficultyName]

        Loop, 3
        {
            attemptNum := A_Index
            DebugLog("SelectWorldBossDifficulty: Attempt " . attemptNum . "/3 to find '" . difficultyName . "' in menu...")
            if FindText(X, Y, 605, 430, 2548, 1686, 0, 0, diffPattern) {
            DebugLog("SelectWorldBossDifficulty: Found '" . difficultyName . "' in menu on attempt " . attemptNum . ". Clicking.")
            FindText().Click(X, Y, "L")
            Sleep, 500
            return true ; Success
            } else {
            DebugLog("SelectWorldBossDifficulty: Difficulty '" . difficultyName . "' not found on attempt " . attemptNum . ".")
            if (attemptNum < 3) {
                Sleep, 450
            }
            }
        }


        DebugLog("SelectWorldBossDifficulty: ERROR - Desired difficulty '" . difficultyName . "' not found in menu after 3 attempts.")
        return false
    }
}

EnsureWorldBossPrivateLobby() {
    global Bot
    DebugLog("EnsureWorldBossPrivateLobby: Checking Private toggle...")

    Loop, 3
    {
        attemptNum := A_Index
        DebugLog("EnsureWorldBossPrivateLobby: Attempt " . attemptNum . "/3...")

        if FindText(X, Y, 564, 658, 2385, 1727, 0, 0, Bot.ocr.WorldBossPrivateToggleOFF) {
            DebugLog("EnsureWorldBossPrivateLobby: Private toggle is OFF (Attempt " . attemptNum . "). Clicking to enable.")
            FindText().Click(X, Y, "L")
            Sleep, 500

            if FindText(X, Y, 564, 658, 2385, 1727, 0, 0, Bot.ocr.WorldBossPrivateToggleON) {
                 DebugLog("EnsureWorldBossPrivateLobby: Private toggle successfully enabled.")
                 return true
            } else {
                 DebugLog("EnsureWorldBossPrivateLobby: ERROR - Clicked toggle, but failed to verify ON state.")
                 return false ; Return false immediately on verification failure since we can't confirm the toggle is ON
            }
        } else if FindText(X, Y, 564, 658, 2385, 1727, 0, 0, Bot.ocr.WorldBossPrivateToggleON) {
             DebugLog("EnsureWorldBossPrivateLobby: Private toggle is already ON (Attempt " . attemptNum . ").")
             return true ; Return true immediately if found ON
        } else {
            DebugLog("EnsureWorldBossPrivateLobby: Could not find Private toggle in either state on attempt " . attemptNum . ".")
            if (attemptNum = 1) {
                Sleep, 450
            }
        }
    }

    ; If the loop completes without finding the toggle in either state
    DebugLog("EnsureWorldBossPrivateLobby: Failed to find Private toggle after 2 attempts.")
    return false
}


ClickWorldBossStartButton() {
    global Bot
    DebugLog("ClickWorldBossStartButton: Searching for WB Start button...")

    Loop, 4
    {
        attemptNum := A_Index
        DebugLog("ClickWorldBossStartButton: Attempt " . attemptNum . "/4...")

        if FindText(X, Y, 488, 1011, 2269, 1836, 0, 0, Bot.ocr.Button.WorldBossStart) {
            DebugLog("ClickWorldBossStartButton: Found on attempt " . attemptNum . ". Clicking.")
            FindText().Click(X, Y, "L")
            Sleep, 500
            return true ; Found it
        } else {
            DebugLog("ClickWorldBossStartButton: Start button NOT found on attempt " . attemptNum . ".")
            if (attemptNum = 1) { ; If it was the first attempt
                Sleep, 450
            }
        }
    }


    DebugLog("ClickWorldBossStartButton: Start button NOT found after 2 attempts.")
    return false
}

ClickWorldBossYesWarning() {
    global Bot
    DebugLog("ClickWorldBossYesWarning: Searching for 'Team not full' Yes button...")
    if FindText(X, Y, 687, 849, 1973, 1712, 0, 0, Bot.ocr.WorldBossYesButton) {
        DebugLog("ClickWorldBossYesWarning: Found Yes button. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 500
        return true
    } else {
        DebugLog("ClickWorldBossYesWarning: Yes button NOT found.")
        return false
    }
}

ClickRegroupOnComplete() {
    global Bot
    DebugLog("ClickRegroupOnComplete: Searching for Regroup button on completion screen...")
    ; Checking for regroup button for WB specific rerunning
    result := FindText(X, Y, 434, 750, 2486, 1758, 0, 0, Bot.ocr.Button.Regroup)
    found := result ? "True" : "False"
    if (result) {
        FindText().Click(X, Y, "L")
    }
    DebugLog("ClickRegroupOnComplete: FindText for Regroup button returned: " . (result ? "True" : "False") . "Clicked and exiting function.")
    Sleep, 800
    return result
}
; NEW fucntion, testing
AttemptWorldBossStartWithConfirmation(logPrefix := "AttemptWBStart") {
    global Bot
    DebugLog(logPrefix . ": Attempting to start World Boss and handle 'Yes' warning...")

    Loop, 4 { ; Try the whole Start + Yes Check sequence up to 2 times
        currentAttempt := A_Index
        DebugLog(logPrefix . ": Overall Start Attempt " . currentAttempt . "/4")

        DebugLog(logPrefix . ": Clicking WB Start button...")
        if (!ClickWorldBossStartButton()) {
            DebugLog(logPrefix . ": ClickWorldBossStartButton failed on attempt " . currentAttempt . ".")
            if (currentAttempt = 2) { ; If this was the last attempt
                DebugLog(logPrefix . ": All attempts to click Start button failed.")
                return "start_failed"
            }
            Sleep, 750 ; Wait before retrying Start
            continue    ; Go to the next iteration of the loop to retry Start
        }
        DebugLog(logPrefix . ": ClickWorldBossStartButton SUCCEEDED on attempt " . currentAttempt . ".")
        Sleep, 600      ; Give generous time for 'Yes' warning to appear

        DebugLog(logPrefix . ": Checking for 'Yes' warning...")
        yesButtonWasClicked := ClickWorldBossYesWarning() ; Returns true if clicked, false if not found

        if (yesButtonWasClicked) {
            DebugLog(logPrefix . ": 'Yes' warning was found and clicked. WB start confirmed.")
            return "success_with_warning" ; WB started, warning handled
        } else {
            DebugLog(logPrefix . ": 'Yes' warning was NOT found after Start button click on attempt " . currentAttempt . ".")
            if (currentAttempt < 2) {
                DebugLog(logPrefix . ": Start click might have been too early or ineffective. Retrying entire sequence...")
                Sleep, 500 ; Wait before retrying the whole sequence (which starts with ClickWorldBossStartButton)
                ; Loop will continue for the next overall attempt
            } else {
                DebugLog(logPrefix . ": 'Yes' warning still not found after final attempt. Assuming WB started without needing 'Yes', or start was ineffective but not detected by ClickWorldBossStartButton.")
                ; If Start button was clicked successfully, and Yes warning is still not there after retries,
                ; we proceed assuming it wasn't needed, aligning with the original idea that "not found is not necessarily an error" for the Yes button.
                return "success_no_warning"
            }
        }
    }
    ; Fallback, should ideally not be reached if loop logic is correct
    DebugLog(logPrefix . ": Unexpectedly exited start attempt loop.")
    return "start_failed"
}

FindHighestAvailableTier(targetBossName) {
    global Bot
    DebugLog("FindHighestAvailableTier: Searching for highest available tier for '" . targetBossName . "'")

    ; --- ADDED: Step 0a: Determine the ACTUAL Highest VALID Tier for this Boss ---
    actualHighestValidTier := -1
    if (!Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        DebugLog("FindHighestAvailableTier: ERROR - No valid tiers defined for '" . targetBossName . "'")
        return 0
    }
    validTiers := Bot.Ocr.WorldBossValidTiers[targetBossName] ; Highest first
    if (validTiers.MaxIndex() > 0) {
        actualHighestValidTier := validTiers[1] ; Get the FIRST element (highest number)
        DebugLog("FindHighestAvailableTier: The highest VALID tier defined for '" . targetBossName . "' is Tier " . actualHighestValidTier)
    } else {
        DebugLog("FindHighestAvailableTier: ERROR - Valid tiers list for '" . targetBossName . "' is empty.")
        return 0
    }


  
    Sleep, 200
    currentlySelectedTier := -1
    currentSelectedPattern := "" ; Keep track of pattern for later click if needed
    if (Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        for index, validNum in Bot.Ocr.WorldBossValidTiers[targetBossName] {
            if (Bot.ocr.WorldBossTierSelected.HasKey(validNum) && Bot.ocr.WorldBossTierSelected[validNum] != "") {
                ; Use detection coordinates
                if FindText(X, Y, 609, 438, 2563, 1723, 0, 0, Bot.ocr.WorldBossTierSelected[validNum]) {
                    currentlySelectedTier := validNum
                    currentSelectedPattern := Bot.ocr.WorldBossTierSelected[validNum]
                    DebugLog("FindHighestAvailableTier: Detected currently selected Tier: " . currentlySelectedTier)
                    break
                }
            }
        }
    }
    if (currentlySelectedTier = -1) {
         DebugLog("FindHighestAvailableTier: WARNING - Could not detect the currently selected tier before searching. Proceeding anyway.")
    }


    ; Check if Currently Selected IS the Highest Valid Tier
    if (currentlySelectedTier = actualHighestValidTier) {
        DebugLog("FindHighestAvailableTier: Currently selected tier (" . currentlySelectedTier . ") IS the highest valid tier (" . actualHighestValidTier . "). SUCCESS.")
        return currentlySelectedTier ; Return immediately, no clicks needed
    } else {
         if (currentlySelectedTier != -1) {
             DebugLog("FindHighestAvailableTier: Current tier (" . currentlySelectedTier . ") is not the highest valid tier (" . actualHighestValidTier . "). Proceeding to change.")
         }
    }



    listOpened := false
    if (currentlySelectedTier != -1 && currentSelectedPattern != "") { ; Check if we detected a tier AND it wasn't the target
        if FindText(X, Y, 609, 438, 2563, 1723, 0, 0, currentSelectedPattern) {
            DebugLog("FindHighestAvailableTier: Clicking currently selected Tier " . currentlySelectedTier . " to open list.")
            FindText().Click(X, Y, "L")
            Sleep, 600
            listOpened := true
        } else {
            DebugLog("FindHighestAvailableTier: WARNING - Found selected tier " . currentlySelectedTier . " but failed FindText for clicking it. Proceeding anyway.")
        }
    } else if (currentlySelectedTier = -1) {
         DebugLog("FindHighestAvailableTier: No current tier detected initially. Assuming list needs opening/is open.")
         ; We might need a fallback click here? Or just hope FindText below works.
         Sleep, 300
         listOpened := true ; Assume opened or will open if no current detected?
    }
    ;Removed redundant !listOpened check, simplified logic ---
    if (!listOpened && currentlySelectedTier != -1) {
         DebugLog("FindHighestAvailableTier: WARNING - Did not explicitly open the list via click. Results may be unreliable.")
         Sleep, 300
         listOpened := true ; Still assume opened for logic below
    }



    ; --- Step 2: Search for Highest Visible Clickable Button, Click, and Verify (NO SCROLLING DOWN) ---
    if (!IsObject(Bot.ocr.WorldBossTierButton)) {
        DebugLog("FindHighestAvailableTier: ERROR - Bot.ocr.WorldBossTierButton pattern object not defined.")
        return 0
    }

    for index, tierNum in validTiers { ; Outer loop: Iterate through tiers High -> Low
        DebugLog("FindHighestAvailableTier: Checking for Tier " . tierNum)

        if (!Bot.ocr.WorldBossTierButton.HasKey(tierNum) || Bot.ocr.WorldBossTierButton[tierNum] = "") {
            DebugLog("FindHighestAvailableTier: WARNING - Pattern for clickable Tier " . tierNum . " button missing. Skipping.")
            continue ; Skip to next lower tier
        }
        tierPattern := Bot.ocr.WorldBossTierButton[tierNum]


        if FindText(X, Y, 590, 466, 2513, 1724, 0, 0, tierPattern) {
            DebugLog("FindHighestAvailableTier: Found VISIBLE clickable Tier " . tierNum . ". Clicking it.")
            FindText().Click(X, Y, "L")
            send {esc} ;this is absolutely necessary to close, see dev notes
            Sleep, 800 

            ; --- Verification Step with Retry Loop ---
            DebugLog("FindHighestAvailableTier: Verifying selection of Tier " . tierNum)
            if (Bot.ocr.WorldBossTierSelected.HasKey(tierNum) && Bot.ocr.WorldBossTierSelected[tierNum] != "") {
                Loop, 3
                {
                    verificationAttempt := A_Index
                    DebugLog("FindHighestAvailableTier: Verification attempt " . verificationAttempt . "/3 for Tier " . tierNum)
                    ; --- Use the same coordinates as Step 0b detection ---
                    if FindText(VerifyX, VerifyY, 609, 438, 2563, 1723, 0, 0, Bot.ocr.WorldBossTierSelected[tierNum]) {
                        DebugLog("FindHighestAvailableTier: Verified Tier " . tierNum . " is now selected on attempt " . verificationAttempt . ". SUCCESS.")
                        return tierNum ; Successfully clicked and verified
                    } else {
                        DebugLog("FindHighestAvailableTier: Verification failed on attempt " . verificationAttempt . ".")
                        if (verificationAttempt < 3) {
                            Sleep, 450
                        }
                    }
                }
                ; If loop completes without returning success
                DebugLog("FindHighestAvailableTier: WARNING - Clicked Tier " . tierNum . " but failed verification after 3 attempts. Assuming click succeeded and returning tier number anyway.")
                return tierNum ; Indicate assumed success
            } else {
                DebugLog("FindHighestAvailableTier: ERROR - No 'Selected' pattern defined for Tier " . tierNum . ". Cannot verify.")
                Send, {Esc} ; Try to close list
                Sleep, 300
                ; --- MODIFIED: Return tierNum even if verification pattern is missing, with warning ---
                DebugLog("FindHighestAvailableTier: WARNING - Proceeding with Tier " . tierNum . " despite missing verification pattern.")
                return tierNum ; Indicate assumed success
            }
            ; --- End Verification Step ---
        } else {
            ; Tier button not visible, continue to the next lower tier in the outer loop
            DebugLog("FindHighestAvailableTier: Tier " . tierNum . " button not visible. Checking next lower tier.")
        }
    } ; End Outer tier loop

    DebugLog("FindHighestAvailableTier: ERROR - Failed to find/select/verify any available tier buttons for '" . targetBossName . "' after checking all valid tiers.")
    Send, {Esc} ; Attempt to close list just in case before failing
    Sleep, 300
    return 0
}

FindLowestAvailableTier(targetBossName) {
    global Bot
    DebugLog("FindLowestAvailableTier: Searching for lowest available tier for '" . targetBossName . "'")

    ; Determine the ACTUAL Lowest VALID Tier for this Boss
    actualLowestValidTier := -1
    if (!Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        DebugLog("FindLowestAvailableTier: ERROR - No valid tiers defined for '" . targetBossName . "'")
        return 0
    }
    validTiers := Bot.Ocr.WorldBossValidTiers[targetBossName] ; Highest first
    if (validTiers.MaxIndex() > 0) {
        actualLowestValidTier := validTiers[validTiers.MaxIndex()] ; Get the last element (lowest number)
        DebugLog("FindLowestAvailableTier: The lowest VALID tier defined for '" . targetBossName . "' is Tier " . actualLowestValidTier)
    } else {
        DebugLog("FindLowestAvailableTier: ERROR - Valid tiers list for '" . targetBossName . "' is empty.")
        return 0
    }

    ; Step 2: Detect Currently Selected Tier 
    Sleep, 200
    currentlySelectedTier := -1
    currentSelectedPattern := ""
    if (Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        for index, validNum in Bot.Ocr.WorldBossValidTiers[targetBossName] {
            if (Bot.ocr.WorldBossTierSelected.HasKey(validNum) && Bot.ocr.WorldBossTierSelected[validNum] != "") {
                if FindText(X, Y, 609, 438, 2563, 1723, 0, 0, Bot.ocr.WorldBossTierSelected[validNum]) {
                    currentlySelectedTier := validNum
                    currentSelectedPattern := Bot.ocr.WorldBossTierSelected[validNum]
                    DebugLog("FindLowestAvailableTier: Detected currently selected Tier: " . currentlySelectedTier)
                    break
                }
            }
        }
    }
    if (currentlySelectedTier = -1) {
         DebugLog("FindLowestAvailableTier: WARNING - Could not detect the currently selected tier. Proceeding to open list and select lowest.")

    }


    ; Check if Currently Selected IS the Lowest Valid Tier
    if (currentlySelectedTier = actualLowestValidTier) {
        DebugLog("FindLowestAvailableTier: Currently selected tier (" . currentlySelectedTier . ") IS the lowest valid tier (" . actualLowestValidTier . "). SUCCESS.")
        return currentlySelectedTier ; Return immediately, no clicks needed
    } else {
         if (currentlySelectedTier != -1) {
             DebugLog("FindLowestAvailableTier: Current tier (" . currentlySelectedTier . ") is not the lowest valid tier (" . actualLowestValidTier . "). Proceeding to change.")
         }

    }



    ; --- Step 4: Open List (if needed) ---
    listOpened := false
    if (currentlySelectedTier != -1 && currentSelectedPattern != "") {
        if FindText(X, Y, 609, 438, 2563, 1723, 0, 0, currentSelectedPattern) {
            DebugLog("FindLowestAvailableTier: Clicking currently selected Tier " . currentlySelectedTier . " to open list.")
            FindText().Click(X, Y, "L")
            Sleep, 600
            listOpened := true
        } else {
            DebugLog("FindLowestAvailableTier: WARNING - Found selected tier " . currentlySelectedTier . " pattern but failed FindText for clicking it. Proceeding anyway.")
        }
    } else {
         DebugLog("FindLowestAvailableTier: No current tier detected initially, or pattern missing. Assuming list needs opening/is open.")
         Sleep, 300
         listOpened := true ; Assume opened or will open if no current detected
    }
    if (!listOpened && currentlySelectedTier != -1) { ; Add check if click failed but we knew current tier
         DebugLog("FindLowestAvailableTier: WARNING - Did not explicitly open the list via click. Results may be unreliable.")
         Sleep, 300
         listOpened := true ; Still assume opened for logic below
    }


    ; Find and Click the ACTUAL Lowest Valid Tier Button
    targetTierNum := actualLowestValidTier ; The tier we need to click
    DebugLog("FindLowestAvailableTier: Attempting to find and click the lowest valid tier button: Tier " . targetTierNum)

    if (!Bot.ocr.WorldBossTierButton.HasKey(targetTierNum) || Bot.ocr.WorldBossTierButton[targetTierNum] = "") {
        DebugLog("FindLowestAvailableTier: ERROR - Pattern for clickable Tier " . targetTierNum . " button missing. Cannot proceed.")
        Send, {Esc}
        Sleep, 300
        return 0 ; Cannot click the target
    }
    tierPattern := Bot.ocr.WorldBossTierButton[targetTierNum]

    ; Initial Search for the lowest valid tier button
    foundButton := FindText(X, Y, 511, 462, 2514, 1702, 0, 0, tierPattern)

    if (!foundButton && listOpened) { ; Only scroll if not found AND list was likely opened
        DebugLog("FindLowestAvailableTier: Lowest tier button not immediately visible. Attempting scroll and check.")
        maxScrollAttempts := 5 ; Number of times to scroll down twice (this number is multiplied by 2 in the loop)
        Loop, % maxScrollAttempts {
            scrollCycle := A_Index
            DebugLog("FindLowestAvailableTier: Scroll Cycle " . scrollCycle . "/" . maxScrollAttempts)

            ; Scroll down twice for every maxScrollAttempts
            Loop, 2 {
                scrollNum := A_Index
                if (!ClickWorldBossNavigationDown()) {
                    DebugLog("FindLowestAvailableTier: Down arrow not found during scroll " . scrollNum . " of cycle " . scrollCycle . ". Assuming bottom reached or error.")
                    foundButton := true ; Set flag to break outer loop
                    break ; Exit inner scroll loop
                }
                DebugLog("FindLowestAvailableTier: Clicked Down Arrow (Scroll " . scrollNum . "/2 in cycle " . scrollCycle . ")")
                Sleep, 150
            }

            if (foundButton) { ; If down arrow disappeared, break outer loop too
                 break
            }

            Sleep, 200 ; Pause after scrolling twice

            ; Check if button is visible now
            DebugLog("FindLowestAvailableTier: Checking for Tier " . targetTierNum . " button after scroll cycle " . scrollCycle)
            if (FindText(X, Y, 511, 462, 2514, 1702, 0, 0, tierPattern)) {
                DebugLog("FindLowestAvailableTier: Found button after scroll cycle " . scrollCycle)
                foundButton := true
                break ; Exit the scroll cycle loop
            } else {
                 DebugLog("FindLowestAvailableTier: Button not found after scroll cycle " . scrollCycle)
            }
        }
        ; Check if loop finished because arrow disappeared or max attempts reached without finding
        if (!foundButton) {
             DebugLog("FindLowestAvailableTier: Finished scroll attempts or arrow disappeared, button still not found.")
        }

    } else if (!foundButton && !listOpened) {
         DebugLog("FindLowestAvailableTier: Button not found initially and list opening was uncertain. Skipping scroll.")
    }

    ; Click and Verify (if found either time)
    if (foundButton) {
        DebugLog("FindLowestAvailableTier: Found VISIBLE clickable Tier " . targetTierNum . " button. Clicking it.")
        FindText().Click(X, Y, "L")
        Sleep, 800 ; Wait for click to register and list to close

        ; Verification Step with Retry Loop
        DebugLog("FindLowestAvailableTier: Verifying selection of Tier " . targetTierNum)
        if (Bot.ocr.WorldBossTierSelected.HasKey(targetTierNum) && Bot.ocr.WorldBossTierSelected[targetTierNum] != "") {
             Loop, 3
             {
                verificationAttempt := A_Index
                DebugLog("FindLowestAvailableTier: Verification attempt " . verificationAttempt . "/3 for Tier " . targetTierNum)
                ; --- Use the same coordinates as Step 2 detection ---
                if FindText(VerifyX, VerifyY, 609, 438, 2563, 1723, 0, 0, Bot.ocr.WorldBossTierSelected[targetTierNum]) {
                    DebugLog("FindLowestAvailableTier: Verified Tier " . targetTierNum . " is now selected on attempt " . verificationAttempt . ". SUCCESS.")
                    return targetTierNum ; Successfully clicked and verified
                } else {
                    DebugLog("FindLowestAvailableTier: Verification failed on attempt " . verificationAttempt . ".")
                    if (verificationAttempt < 3) {
                        Sleep, 450 ; Wait before next verification attempt
                    }
                }
             }
             ; If loop completes without returning success
             DebugLog("FindLowestAvailableTier: WARNING - Clicked Tier " . targetTierNum . " but failed verification after 3 attempts. Assuming click succeeded and returning tier number anyway.")
             return targetTierNum ; Indicate assumed success
        } else {
             DebugLog("FindLowestAvailableTier: ERROR - No 'Selected' pattern defined for Tier " . targetTierNum . ". Cannot verify.")
             Send, {Esc} ; Try to close list
             Sleep, 300
             DebugLog("FindLowestAvailableTier: WARNING - Proceeding with Tier " . targetTierNum . " despite missing verification pattern.")
             return targetTierNum ; Indicate assumed success
        }

    } else {
        DebugLog("FindLowestAvailableTier: ERROR - Clickable button for lowest valid Tier " . targetTierNum . " not found in list (even after potential scrolling).")
        Send, {Esc} ; Attempt to close list just in case before failing
        Sleep, 300
        return 0 ; Return 0 as we failed to find/click the target
    }
}

ClickWorldBossNavigationUp() {
    global Bot
    DebugLog("ClickWorldBossNavigationUp: Searching for WB Tier List UP Arrow...")

    if FindText(X, Y, 640, 474, 2517, 1643, 0, 0, Bot.ocr.WorldBossNavigationUp) {
        DebugLog("ClickWorldBossNavigationUp: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 350 ; --- INCREASED SLEEP ---
        return true
    } else {
        DebugLog("ClickWorldBossNavigationUp: Arrow NOT found!")
        return false
    }
}

ClickWorldBossNavigationDown() {
    global Bot
    DebugLog("ClickWorldBossNavigationDown: Searching for WB Tier List DOWN Arrow...")
    if FindText(X, Y, 640, 474, 2517, 1643, 0, 0, Bot.ocr.WorldBossNavigationDown) {
        DebugLog("ClickWorldBossNavigationDown: Found. Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 350 ; --- INCREASED SLEEP ---
        return true
    } else {
        DebugLog("ClickWorldBossNavigationDown: Arrow NOT found!")
        return false
    }
}
