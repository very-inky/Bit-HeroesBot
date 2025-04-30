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

    ; --- ADDED: Handle "HighestAvailable" / "LowestAvailable" Tier ---
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
            return "success" ; Treat as success to move to next config/action
        }
        targetTier := resolvedTier ; Update targetTier with the found numeric tier
        DebugLog("ActionWorldBoss: Found highest available tier: " . targetTier)
    }
    else if (targetTier = "LowestAvailable") { ; <<< ADDED THIS BLOCK
        DebugLog("ActionWorldBoss: 'LowestAvailable' tier requested. Finding lowest available tier...")
        resolvedTier := FindLowestAvailableTier(targetBossName)
        if (resolvedTier <= 0) { ; Check if FindLowestAvailableTier failed
            DebugLog("ActionWorldBoss: ERROR - Could not find any available tier for '" . targetBossName . "' (Lowest). Skipping this config.")
            Bot.WorldBoss.Conf.CurrentIndex += 1 ; Advance index
            if (Bot.WorldBoss.Conf.CurrentIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
                Bot.WorldBoss.Conf.CurrentIndex := 1
            }
            DebugLog("ActionWorldBoss: Advanced WB index to " . Bot.WorldBoss.Conf.CurrentIndex . ". Returning 'success' to advance main action loop.")
            return "success" ; Treat as success to move to next config/action
        }
        targetTier := resolvedTier ; Update targetTier with the found numeric tier
        DebugLog("ActionWorldBoss: Found lowest available tier: " . targetTier)
    }
    ; --- END MODIFIED CODE ---

    ; --- 2. Navigation ---
    DebugLog("ActionWorldBoss: Checking if World Boss window is open...")
    if (!IsWorldBossWindowOpen()) {
        DebugLog("ActionWorldBoss: WB window not open. Clicking WB icon...")
        if (!ClickWorldBossIcon()) {
            DebugLog("ActionWorldBoss: ClickWorldBossIcon failed. Returning 'retry'.")
            return "retry"
        }
        Sleep, 990
        if (!IsWorldBossWindowOpen()) {
            DebugLog("ActionWorldBoss: WB window did not appear after clicking icon. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionWorldBoss: WB window opened.")
    } else {
        DebugLog("ActionWorldBoss: WB window already open.")
    }

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

    ; --- 7. Select Tier ---
    DebugLog("ActionWorldBoss: Selecting Tier '" . targetTier . "' for Boss '" . targetBossName . "'...") ; Now logs the potentially resolved numeric tier
    selectedTierResult := SelectWorldBossTier(targetBossName, targetTier)
    if (selectedTierResult = "invalid_tier") {
         DebugLog("ActionWorldBoss: Tier '" . targetTier . "' is invalid/unavailable. Skipping this config.")
         Bot.WorldBoss.Conf.CurrentIndex += 1 ; Advance index
         if (Bot.WorldBoss.Conf.CurrentIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
             Bot.WorldBoss.Conf.CurrentIndex := 1
         }
         DebugLog("ActionWorldBoss: Advanced WB index to " . Bot.WorldBoss.Conf.CurrentIndex . ". Returning 'success' to advance main action loop.")
         return "success"
    } else if (!selectedTierResult) {
        DebugLog("ActionWorldBoss: SelectWorldBossTier failed for Tier '" . targetTier . "'. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: Successfully selected tier.")
    Sleep, 500

     ; --- 8. Select Difficulty ---
     DebugLog("ActionWorldBoss: Selecting Difficulty '" . targetDifficulty . "'...")
     if (!SelectWorldBossDifficulty(targetDifficulty)) {
         DebugLog("ActionWorldBoss: SelectWorldBossDifficulty failed for '" . targetDifficulty . "'. Returning 'retry'.")
         return "retry"
     }
     DebugLog("ActionWorldBoss: Successfully selected difficulty '" . targetDifficulty . "'.")
     Sleep, 500

    ; --- 9. Check/Toggle Private Lobby ---
    DebugLog("ActionWorldBoss: Ensuring Private Lobby is ON...")
    if (!EnsureWorldBossPrivateLobby()) {
         DebugLog("ActionWorldBoss: EnsureWorldBossPrivateLobby failed. Returning 'retry'.")
         return "retry"
    }
    DebugLog("ActionWorldBoss: Private Lobby confirmed ON.")
    Sleep, 300

    ; --- 10. Click Final Summon/Attack Button ---
    DebugLog("ActionWorldBoss: Clicking final Summon button...")
    if (!ClickWorldBossSummonButton()) { ; Assuming this is the final button
        DebugLog("ActionWorldBoss: ClickWorldBossSummonButton failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: Clicked final Attack/Summon button.")
    Sleep, 1000 ; Wait after final click

    if (CheckOutOfResources()) {
        DebugLog("MonitorWorldBoss: Out of resources detected during rerun attempt. Returning 'outofresource'.")
        return "outofresource"
    }

    ; --- 10a. Click WB Start button ---
    DebugLog("ActionWorldBoss: Clicking WB Start button...")
    if (!ClickWorldBossStartButton()) {
        DebugLog("ActionWorldBoss: ClickWorldBossStartButton failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionWorldBoss: WB Start button clicked.")
    Sleep, 500

    ; --- 11. Handle "Team not full" Warning ---
    DebugLog("ActionWorldBoss: Checking for 'Team not full' warning...")
    if (!ClickWorldBossYesWarning()) {
        DebugLog("ActionWorldBoss: 'Team not full' Yes button not found (or not needed). Continuing...")
    } else {
        DebugLog("ActionWorldBoss: Clicked 'Yes' on warning.")
        Sleep, 500 ; Wait after clicking warning
    }

    ; --- 12. Check Resources ---
    if (CheckOutOfResources()) {
        DebugLog("ActionWorldBoss: Out of resources detected after starting attack. Returning 'outofresource'.")
        return "outofresource"
    }
    DebugLog("ActionWorldBoss: No 'Out Of Resources' detected.")

    ; --- 13. Success -> Return "started" for Monitoring ---
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

                ; --- Re-run sequence: click Start + Yes warning ---
                DebugLog("MonitorWorldBoss: Clicking WB Start button for rerun.")
                ClickWorldBossStartButton()
                Sleep, 500
                DebugLog("MonitorWorldBoss: Clicking 'Yes' warning for rerun.")
                ClickWorldBossYesWarning()
                Sleep, 500

                ; --- Check resources AFTER clicking Yes warning on rerun ---
                if (CheckOutOfResources()) {
                    DebugLog("MonitorWorldBoss: Out of resources detected during rerun attempt. Returning 'outofresource'.")
                    return "outofresource"
                }

                DebugLog("MonitorWorldBoss: Rerun initiated. Returning 'in_progress' to continue monitoring.")
                return "in_progress"
            }
            ; --- END CHANGE ---

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

     ; Check for dialogue popups during WB
    dialogueHandled := HandleInProgressDialogue()
    if (dialogueHandled) {
        DebugLog("MonitorWorldBoss: Handled in-progress dialogue during World Boss.")
    }

    ; 3. Still In Progress
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
            return name ; Return the NAME string
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

; Helper to get the list index corresponding to a boss name
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

; --- ADDED: Helper to get the UI list index corresponding to a boss name ---
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
; --- END ADDED HELPER ---

EnsureCorrectWorldBossSelected(targetBossName) {
    global Bot
    DebugLog("EnsureCorrectWorldBossSelected: --- Entered Function --- Target Name: '" . targetBossName . "'")
    attempts := 0
    maxAttempts := 15 ; Adjust as needed

    ; --- REMOVED: Old targetIndex calculation (not needed for navigation) ---
    ; targetIndex := GetWorldBossIndexByName(targetBossName)
    ; if (targetIndex = 0) { ... }

    ; --- ADDED: Check if target name exists in UI order list early ---
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
    ; --- END ADDED CHECK ---


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
            } else { ; clicksLeft < clicksRight
                DebugLog("EnsureCorrectWorldBossSelected: Clicking Left Arrow (Attempt " . attempts . ")")
                if (!ClickWorldBossLeftArrow()) {
                     DebugLog("EnsureCorrectWorldBossSelected: Failed to click left arrow. Aborting.")
                     return false
                }
            }
        }
        ; --- END UPDATED NAVIGATION ---

        Sleep, 600
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
        return false ; Should have been resolved to a number by ActionWorldBoss
    }
    targetTierNum := targetTier + 0 ; Ensure it's treated as a number

    DebugLog("SelectWorldBossTier: Processing numeric Tier " . targetTierNum . ".")

    ; --- Check 1: Is the requested tier even valid for this boss? ---
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
    ; *** REQUIRES NEW PATTERNS: Bot.ocr.WorldBoss.TierSelected[tierNum] for each possible tier ***
    currentlySelectedTier := -1 ; Default to unknown
    if (!IsObject(Bot.ocr.WorldBossTierSelected)) {
        DebugLog("SelectWorldBossTier: ERROR - Bot.ocr.WorldBoss.TierSelected pattern object not defined.")
        return false
    }
    ; Check valid tiers first, might be faster if usually one is selected
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
    ; Add a broader check if needed, or handle error if not found among valid
    if (currentlySelectedTier = -1) {
         DebugLog("SelectWorldBossTier: ERROR - Could not detect the currently selected tier.")
         return false
    }

    ; --- Check 3: Compare and Click if Necessary ---
    if (currentlySelectedTier = targetTierNum) {
        DebugLog("SelectWorldBossTier: Target Tier " . targetTierNum . " is already selected.")
        return true ; Already correct
    } else {
        DebugLog("SelectWorldBossTier: Target Tier " . targetTierNum . " is NOT selected (Current: " . currentlySelectedTier . "). Attempting to click...")

        ; --- Check 4: Is the pattern for the target clickable button defined? ---
        ; *** USES EXISTING PATTERNS: Bot.ocr.WorldBossTierButton[tierNum] ***
        if (!Bot.ocr.WorldBossTierButton.HasKey(targetTierNum) || Bot.ocr.WorldBossTierButton[targetTierNum] = "") {
            DebugLog("SelectWorldBossTier: ERROR - Pattern for clickable Tier " . targetTierNum . " button is missing or empty.")
            return false
        }
        tierPattern := Bot.ocr.WorldBossTierButton[targetTierNum]

        ; --- Check 5: Try to find and click the target button ---
        if FindText(X, Y, 511, 462, 2514, 1702, 0, 0, 0, 0, tierPattern) {
            DebugLog("SelectWorldBossTier: Found clickable Tier " . targetTierNum . " button. Clicking.")
            FindText().Click(X, Y, "L")
            Sleep, 500
            ; Optional: Add verification step here to see if selection changed
            return true
        } else {
             DebugLog("SelectWorldBossTier: ERROR - Failed to find clickable button for Tier " . targetTierNum . ".")
             ; Check if the tier became unavailable *after* the initial valid check?
             ; Or maybe it's just an OCR miss. Returning false for retry.
             return false
        }
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
    ; *** REQUIRES NEW PATTERNS: Bot.ocr.WorldBoss.DifficultySelected[diffName] ***
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
        ; *** REQUIRES NEW PATTERNS: Bot.ocr.WorldBoss.WorldBossDifficultyButton[diffName] ***
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
            Sleep, 500 ; Wait after click
            return true ; Success
            } else {
            DebugLog("SelectWorldBossDifficulty: Difficulty '" . difficultyName . "' not found on attempt " . attemptNum . ".")
            if (attemptNum < 3) { ; Only sleep if not the last attempt
                Sleep, 450
            }
            }
        }

        ; If the loop completes without finding the button
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
            ; Optional: Verify it changed to ON state
            if FindText(X, Y, 564, 658, 2385, 1727, 0, 0, Bot.ocr.WorldBossPrivateToggleON) {
                 DebugLog("EnsureWorldBossPrivateLobby: Private toggle successfully enabled.")
                 return true
            } else {
                 DebugLog("EnsureWorldBossPrivateLobby: ERROR - Clicked toggle, but failed to verify ON state.")
                 return false ; Return false immediately on verification failure
            }
        } else if FindText(X, Y, 564, 658, 2385, 1727, 0, 0, Bot.ocr.WorldBossPrivateToggleON) {
             DebugLog("EnsureWorldBossPrivateLobby: Private toggle is already ON (Attempt " . attemptNum . ").")
             return true ; Return true immediately if found ON
        } else {
            DebugLog("EnsureWorldBossPrivateLobby: Could not find Private toggle in either state on attempt " . attemptNum . ".")
            if (attemptNum = 1) {
                Sleep, 450 ; Wait before the next attempt
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

    Loop, 3
    {
        attemptNum := A_Index
        DebugLog("ClickWorldBossStartButton: Attempt " . attemptNum . "/3...")

        if FindText(X, Y, 488, 1011, 2269, 1836, 0, 0, Bot.ocr.Button.WorldBossStart) {
            DebugLog("ClickWorldBossStartButton: Found on attempt " . attemptNum . ". Clicking.")
            FindText().Click(X, Y, "L")
            Sleep, 500
            return true ; Found it, return true immediately
        } else {
            DebugLog("ClickWorldBossStartButton: Start button NOT found on attempt " . attemptNum . ".")
            if (attemptNum = 1) { ; If it was the first attempt
                Sleep, 450 ; Wait before the second attempt
            }
        }
    }

    ; If the loop completes without finding the button
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
        DebugLog("ClickWorldBossYesWarning: Yes button not found. Not necessarily an error.")
        return true ; Return true even if not found, as warning may not always appear
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
    Sleep, 500 ; Wait after clicking
    return result
}

; --- NEW HELPER: Find Highest Available Tier ---
FindHighestAvailableTier(targetBossName) {
    global Bot
    DebugLog("FindHighestAvailableTier: Searching for highest available tier for '" . targetBossName . "'")

    ; Check if valid tiers are defined for this boss
    if (!Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        DebugLog("FindHighestAvailableTier: ERROR - No valid tiers defined in Bot.Ocr.WorldBossValidTiers for '" . targetBossName . "'")
        return 0 ; Indicate error/not found
    }

    ; Check if tier button patterns are defined
    if (!IsObject(Bot.ocr.WorldBossTierButton)) {
        DebugLog("FindHighestAvailableTier: ERROR - Bot.ocr.WorldBossTierButton pattern object not defined.")
        return 0 ; Indicate error
    }

    validTiers := Bot.Ocr.WorldBossValidTiers[targetBossName] ; Get the array of valid tiers (highest first)

    ; Iterate through the valid tiers from highest to lowest
    for index, tierNum in validTiers {
        DebugLog("FindHighestAvailableTier: Checking availability of Tier " . tierNum)

        ; Check if a pattern exists for this tier button
        if (!Bot.ocr.WorldBossTierButton.HasKey(tierNum) || Bot.ocr.WorldBossTierButton[tierNum] = "") {
            DebugLog("FindHighestAvailableTier: WARNING - Pattern for clickable Tier " . tierNum . " button is missing or empty. Skipping.")
            continue ; Skip to the next tier
        }
        tierPattern := Bot.ocr.WorldBossTierButton[tierNum]

        ; Try to find the tier button on screen
        if FindText(X, Y, 511, 462, 2514, 1702, 0, 0, tierPattern) { ; Use coordinates from SelectWorldBossTier
            DebugLog("FindHighestAvailableTier: Found available Tier " . tierNum . ". Returning this tier.")
            return tierNum ; Found the highest available tier
        } else {
            DebugLog("FindHighestAvailableTier: Tier " . tierNum . " button not found.")
        }
        Sleep, 50 ; Small delay between checks if needed
    }

    DebugLog("FindHighestAvailableTier: ERROR - Failed to find any available tier buttons for '" . targetBossName . "' among the valid tiers.")
    return 0 ; Indicate no available tier found
}
; --- END NEW HELPER ---

; --- NEW HELPER: Find Lowest Available Tier ---
FindLowestAvailableTier(targetBossName) {
    global Bot
    DebugLog("FindLowestAvailableTier: Searching for lowest available tier for '" . targetBossName . "'")

    ; Check if valid tiers are defined for this boss
    if (!Bot.Ocr.WorldBossValidTiers.HasKey(targetBossName)) {
        DebugLog("FindLowestAvailableTier: ERROR - No valid tiers defined in Bot.Ocr.WorldBossValidTiers for '" . targetBossName . "'")
        return 0 ; Indicate error/not found
    }

    ; Check if tier button patterns are defined
    if (!IsObject(Bot.ocr.WorldBossTierButton)) {
        DebugLog("FindLowestAvailableTier: ERROR - Bot.ocr.WorldBossTierButton pattern object not defined.")
        return 0 ; Indicate error
    }

    validTiers := Bot.Ocr.WorldBossValidTiers[targetBossName] ; Get the array of valid tiers (highest first)

    ; Iterate through the valid tiers from LOWEST to highest (reverse the array order)
    loopIndex := validTiers.MaxIndex()
    while (loopIndex >= 1)
    {
        tierNum := validTiers[loopIndex]
        DebugLog("FindLowestAvailableTier: Checking availability of Tier " . tierNum)

        ; Check if a pattern exists for this tier button
        if (!Bot.ocr.WorldBossTierButton.HasKey(tierNum) || Bot.ocr.WorldBossTierButton[tierNum] = "") {
            DebugLog("FindLowestAvailableTier: WARNING - Pattern for clickable Tier " . tierNum . " button is missing or empty. Skipping.")
            loopIndex-- ; Move to the next lower index (higher tier number in original array)
            continue ; Skip to the next tier
        }
        tierPattern := Bot.ocr.WorldBossTierButton[tierNum]

        ; Try to find the tier button on screen
        if FindText(X, Y, 511, 462, 2514, 1702, 0, 0, tierPattern) { ; Use coordinates from SelectWorldBossTier
            DebugLog("FindLowestAvailableTier: Found available Tier " . tierNum . ". Returning this tier.")
            return tierNum ; Found the lowest available tier
        } else {
            DebugLog("FindLowestAvailableTier: Tier " . tierNum . " button not found.")
        }
        Sleep, 50 ; Small delay between checks if needed
        loopIndex-- ; Move to the next lower index (higher tier number in original array)
    }


    DebugLog("FindLowestAvailableTier: ERROR - Failed to find any available tier buttons for '" . targetBossName . "' among the valid tiers.")
    return 0 ; Indicate no available tier found
}
; --- END NEW HELPER ---