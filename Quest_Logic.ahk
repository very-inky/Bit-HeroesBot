;———————————————————————————————————————————————————————————————
; === Quest Flow ===
ActionQuest() {
    global Bot
    DebugLog("ActionQuest: --- Entered function ---")

    ; Check if Quest window is open
    questWinOpen := IsQuestWindowOpen()
    DebugLog("ActionQuest: IsQuestWindowOpen returned: '" . (questWinOpen ? "True" : "False") . "'")

    if (!questWinOpen) {
        DebugLog("ActionQuest: Quest window NOT open, attempting ClickQuestIcon()")
        ClickQuestIcon() ; Assumes this function has its own logs
        Sleep, 600 ; Wait for window to potentially open
        questWinOpen := IsQuestWindowOpen() ; Check again
        DebugLog("ActionQuest: IsQuestWindowOpen (after click) returned: '" . (questWinOpen ? "True" : "False") . "'")
        if (!questWinOpen) {
            DebugLog("ActionQuest: Failed to open quest window after click. Returning 'retry'.")
            return "retry"
        }
    } else {
         DebugLog("ActionQuest: Quest window was already open.")
    }

    ; Get desired targets for this run
    targetZonePattern := Bot.desiredZones[Bot.currentSelectionIndex]
    targetDungeonName := Bot.desiredDungeons[Bot.currentSelectionIndex]
    DebugLog("ActionQuest: Target Zone Pattern starts: " . SubStr(targetZonePattern, 1, 10) . "..., Target Dungeon Name: " . targetDungeonName)

    ; Ensure the correct zone is displayed
    DebugLog("ActionQuest: Calling EnsureCorrectZone(...)")
    zoneCorrect := EnsureCorrectZone(targetZonePattern) ; Pass the PATTERN
    DebugLog("ActionQuest: EnsureCorrectZone returned: '" . zoneCorrect . "'")
    if (!zoneCorrect) {
        DebugLog("ActionQuest: EnsureCorrectZone failed. Returning 'retry'.")
        return "retry"
    }

    ; Get the name of the currently displayed zone (should match target now)
    currentZoneName := DetectCurrentZoneName()
    DebugLog("ActionQuest: Current confirmed zone name for dungeon check: " . currentZoneName)

    ; Check if the desired dungeon pattern is visible
    DebugLog("ActionQuest: Calling EnsureCorrectDungeon(" . currentZoneName . ", " . targetDungeonName . ") to check presence.")
    dungeonPresent := EnsureCorrectDungeon(currentZoneName, targetDungeonName) ; Gets result OBJECT (evaluates true/false)
    DebugLog("ActionQuest: EnsureCorrectDungeon (presence check) returned: '" . (dungeonPresent ? "Object (True)" : "0 (False)") . "'")

    if (!dungeonPresent) { ; Check if the dungeon pattern was found
        DebugLog("ActionQuest: EnsureCorrectDungeon failed (pattern not found). Returning 'retry'.")
        return "retry"
    } else {
        ; Dungeon pattern IS present. Now FIND IT AGAIN to update Global X/Y and CLICK.
        DebugLog("ActionQuest: Dungeon pattern found by check. Finding again to click...")

        ; Retrieve the pattern string again (needed for the local FindText call)
        ; Error handling for invalid zone/dungeon index happens within this block now
        if (!Bot.ocr.DungeonMapping.HasKey(currentZoneName)) {
             DebugLog("ActionQuest: ERROR - Zone '" . currentZoneName . "' not found in DungeonMapping for find-and-click.")
             return "retry"
        }
        dungeonPatternList := Bot.ocr.DungeonMapping[currentZoneName]
        dungeonIndex := SubStr(targetDungeonName, 8)
        if (dungeonIndex is not number or dungeonIndex < 1 || dungeonIndex > dungeonPatternList.MaxIndex()) {
            DebugLog("ActionQuest: ERROR - Invalid dungeon index '" . dungeonIndex . "' for find-and-click.")
            return "retry"
        }
        targetDungeonPattern := dungeonPatternList[dungeonIndex]

        ; Perform FindText AGAIN, this time using X, Y output vars to update globals
        if (FindText(X, Y, 660, 496, 2501, 1680, 0, 0, targetDungeonPattern)) {
             DebugLog("ActionQuest: Found dungeon again- Clicking")
             ; Use the standard click method which relies on the X,Y updated above
             FindText().Click(X, Y, "L")
             Sleep, 900 ; Increased delay after clicking dungeon
        } else {
             DebugLog("ActionQuest: ERROR - Failed to find dungeon pattern for click immediately after check found it!? Returning 'retry'.")
             return "retry" ; Should not happen if EnsureCorrectDungeon just worked, but safety check.
        }
    }

    ; Select Heroic Difficulty
    DebugLog("ActionQuest: Calling SelectHeroic()")
    heroicSelected := SelectHeroic() ; Assumes this function has own logs
    DebugLog("ActionQuest: SelectHeroic returned: '" . heroicSelected . "'")
    if (!heroicSelected) {
         DebugLog("ActionQuest: SelectHeroic failed. Returning 'retry'.")
        return "retry"
    }

    ; Click the final Accept button (which checks for resources)
    DebugLog("ActionQuest: Calling ClickAcceptQuest()")
    acceptResult := ClickAcceptQuest() ; Assumes this function has own logs
    DebugLog("ActionQuest: ClickAcceptQuest returned: '" . acceptResult . "'")

    if (acceptResult = "outofresource") {
         DebugLog("ActionQuest: Detected out of resources. Returning 'outofresource'.")
        return "outofresource"
    }
    if (acceptResult != "confirmed") {
        DebugLog("ActionQuest: ClickAcceptQuest returned unexpected value '" . acceptResult . "'. Returning 'retry'.")
        return "retry"
    }

    ; --- Quest Start Confirmed - Perform one-time AutoPilot check ---
    DebugLog("ActionQuest: Quest accepted. Waiting for quest screen to load before AutoPilot check...")
    Sleep, 1500 ; Wait 1.5 seconds (Adjust as needed)

    DebugLog("ActionQuest: Performing one-time AutoPilot check.")
    autoPilotOk := EnsureAutoPilotOn() ; Assumes this function has own logs
    if (!autoPilotOk) {
        DebugLog("ActionQuest: Warning - EnsureAutoPilotOn failed after starting quest.")
        ; Continue anyway, AutoPilot isn't critical for starting
    } else {
         DebugLog("ActionQuest: EnsureAutoPilotOn completed successfully (check its logs for details).")
    }
    ; --- End AutoPilot Check ---

    DebugLog("ActionQuest: --- Success! All steps completed. Returning 'started'. ---")
    return "started"
}
MonitorQuestProgress() {
    global Bot
    ; Note: No AutoPilot check here anymore.

    if (IsActionComplete()) {
        DebugLog("MonitorQuestProgress: IsActionComplete returned True.")
        if (Bot.desiredZones.Length() = 1) {
            DebugLog("MonitorQuestProgress: Single config - attempting Rerun.")
            ClickRerun()
            Sleep, 1200
            outOfRes := CheckOutOfResources()
            returnVal := outOfRes ? "outofresource" : "rerun"
            DebugLog("MonitorQuestProgress: Rerun attempt finished. Returning '" . returnVal . "'")
            return returnVal
        } else {
            DebugLog("MonitorQuestProgress: Multi-config - attempting ClickTownOnComplete.")
            if (ClickTownOnComplete()) {
                Sleep, 1000
                DebugLog("MonitorQuestProgress: ClickTownOnComplete succeeded. Returning 'start_next_config'")
                return "start_next_config"
            }
            DebugLog("MonitorQuestProgress: ClickTownOnComplete failed. Returning 'error'")
            return "error"
        }
    }
    ; If action is not complete, check for other states:
    if (IsDisconnected()) {
        DebugLog("MonitorQuestProgress: IsDisconnected returned True.")
        AttemptReconnect()
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorQuestProgress: State changed to NotLoggedIn. Returning 'disconnected'")
        return "disconnected"
    }
    if (IsPlayerDead()) {
        DebugLog("MonitorQuestProgress: IsPlayerDead returned True.")
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorQuestProgress: State changed to NotLoggedIn. Returning 'player_dead'")
        return "player_dead"
    }

    dialogueHandled := HandleInProgressDialogue()
    if (dialogueHandled) {
        DebugLog("MonitorQuestProgress: Handled in-progress dialogue.")
    }

    return "in_progress"
}

IsQuestWindowOpen() {
    global Bot
    DebugLog("IsQuestWindowOpen: --- Entered function ---")
    ; Use a reliable element WITHIN the quest window (e.g., the Accept button is good if using wide coords)
    ; Ensure Bot.ocr.Button.Accept pattern is correct
    result := FindText(X, Y, 1045-150000, 642-150000, 1045+150000, 642+150000, 0, 0, Bot.ocr.Button.QuestWindowOpen)
    found := result ? "True" : "False" ; Convert FindText result to True/False string
    DebugLog("IsQuestWindowOpen: FindText for the zone button within quest returned: " . found)
    DebugLog("IsQuestWindowOpen: --- Exiting function ---")
    return result ; Return the original FindText result (evaluates correctly in IFs)
}

ClickQuestIcon() {
    global Bot
    DebugLog("ClickQuestIcon: --- Entered function ---")
    ; Ensure Bot.ocr.QuestIcon pattern is correct
    found := FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Bot.ocr.QuestIcon)
    if (found) {
        DebugLog("ClickQuestIcon: Found, Clicking.")
        FindText().Click(X,Y,"L")
        Sleep, 100 ; Short sleep after click
    } else {
        DebugLog("ClickQuestIcon: Quest Icon NOT found!")
    }
    DebugLog("ClickQuestIcon: --- Exiting function ---")
    ; This function doesn't need to return anything, it just performs an action.
}

GetZoneNameFromPattern(patternToFind) {
    global Bot
    for index, patternInArray in Bot.ocr.Zone
    {
        if (patternInArray = patternToFind)
        {
            return "Zone" . index ; Return "Zone1", "Zone2" etc.
        }
    }
    return "UnknownZone" ; Return this if pattern not found in the array
}

EnsureCorrectZone(targetZonePattern) {
    global Bot
    targetZoneName := GetZoneNameFromPattern(targetZonePattern) ; Get target name for logging
    DebugLog("EnsureCorrectZone: --- Entered Function --- Target Zone: " . targetZoneName)

    attempts := 0
    currentZoneName := DetectCurrentZoneName() ; Get current name
    DebugLog("EnsureCorrectZone: Initial detected zone: '" . currentZoneName . "' (Attempt " . attempts . ")")

    ; Compare NAMES for loop condition
    while (currentZoneName != targetZoneName && attempts < 20) {
        DebugLog("EnsureCorrectZone: Mismatch! Current='" . currentZoneName . "', Target='" . targetZoneName . "'. Attempt " . attempts)

        ; --- Determine Click Direction (Needs Robust Logic) ---
        ; This requires knowing the order of zones. Assuming numerical order for now.
        ; Extract numbers from "ZoneN" strings
        currentZoneNum := SubStr(currentZoneName, 5) ; Get number part
        targetZoneNum := SubStr(targetZoneName, 5)   ; Get number part

        if (currentZoneNum is not number or targetZoneNum is not number) {
            DebugLog("EnsureCorrectZone: ERROR - Could not determine zone numbers for direction ('" . currentZoneName . "', '" . targetZoneName . "'). Clicking Right as default.")
            ClickRightArrow()
        } else if (currentZoneNum < targetZoneNum) {
             DebugLog("EnsureCorrectZone: Clicking Right Arrow.")
             ClickRightArrow()
        } else {
             DebugLog("EnsureCorrectZone: Clicking Left Arrow.")
             ClickLeftArrow()
        }
        ; --- End Direction Logic ---

        Sleep, 600           ; Increased sleep slightly
        currentZoneName := DetectCurrentZoneName() ; Detect NAME again
        attempts++
        DebugLog("EnsureCorrectZone: After arrow click & sleep, detected zone: '" . currentZoneName . "' (Attempt " . attempts . ")")

    } ; End while loop

    if (currentZoneName = targetZoneName) {
        DebugLog("EnsureCorrectZone: --- Success! Target zone '" . targetZoneName . "' reached. ---")
        return true
    } else {
        DebugLog("EnsureCorrectZone: --- Failed! Target zone '" . targetZoneName . "' NOT reached after " . attempts . " attempts. ---")
        return false
    }
}

DetectCurrentZoneName() {
    global Bot
    DebugLog("DetectCurrentZoneName: --- Entered function (searching 400,200 to 800,300) ---")
    for index, pat in Bot.ocr.Zone {
        ; Ensure these coordinates are correct for seeing the Zone Title Text
        if FindText(X, Y, 1191, 537, 1999, 700, 0, 0, pat) {
            zoneName := "Zone" . index
            DebugLog("DetectCurrentZoneName: Found " . zoneName . " --- Exiting function ---")
            return zoneName ; Return the NAME ("Zone1", "Zone2", etc.)
        }
    }
    DebugLog("DetectCurrentZoneName: No known zone pattern found! --- Exiting function ---")
    return "" ; Return empty if no known zone found
}


EnsureCorrectDungeon(zoneName, dungeonName) { ; Takes NAMES now
    global Bot ; Still need Bot for patterns
    DebugLog("EnsureCorrectDungeon: --- Entered Function --- Zone Name: " . zoneName . ", Dungeon Name: " . dungeonName)
    foundResult := false ; Default to false

    if (!Bot.ocr.DungeonMapping.HasKey(zoneName)) {
        DebugLog("EnsureCorrectDungeon: ERROR - Zone '" . zoneName . "' not found in DungeonMapping.")
        return false ; Return simple false (0)
    }
    dungeonPatternList := Bot.ocr.DungeonMapping[zoneName]
    dungeonIndex := SubStr(dungeonName, 8)

    if (dungeonIndex is not number or dungeonIndex < 1 || dungeonIndex > dungeonPatternList.MaxIndex()) {
         DebugLog("EnsureCorrectDungeon: ERROR - Invalid dungeon index '" . dungeonIndex . "' extracted from '" . dungeonName . "'.")
         return false ; Return simple false (0)
    }

    targetDungeonPattern := dungeonPatternList[dungeonIndex]
    DebugLog("EnsureCorrectDungeon: Target Dungeon Pattern starts: " . SubStr(targetDungeonPattern, 1, 10) . "...")
    DebugLog("EnsureCorrectDungeon: Searching for pattern in region 660,496 to 2501,1680...")

    ; Perform FindText and store the result OBJECT in foundResult
    ; DO NOT use global X, Y here.
    foundResult := FindText(X, Y, 660, 496, 2501, 1680, 0, 0, targetDungeonPattern)

    if (foundResult) {
        DebugLog("EnsureCorrectDungeon: FindText result: True (Pattern Found) --- Exiting function ---")
    } else {
        DebugLog("EnsureCorrectDungeon: FindText result: False (Pattern Not Found) --- Exiting function ---")
    }
    ; Return the raw FindText result OBJECT (evaluates correctly in IFs)
    return foundResult
}

SelectHeroic() {
    global Bot
    DebugLog("SelectHeroic: --- Entered Function ---")
    ; Ensure Bot.ocr.Button.Heroic pattern is correct
    DebugLog("SelectHeroic: Searching for Heroic button...")
    heroicButton := FindText(X, Y, 2020-150000, 1033-150000, 2020+150000, 1033+150000, 0, 0, Bot.ocr.Button.Heroic)
    if (heroicButton) {
         DebugLog("SelectHeroic: Found Heroic button-Clicking.")
        FindText().Click(X,Y,"L")
        Sleep, 950
        DebugLog("SelectHeroic: Returning True. --- Exiting function ---")
        return true
    } else {
        DebugLog("SelectHeroic: Heroic button NOT found. Returning False. --- Exiting function ---")
        return false
    }
}

ClickAcceptQuest() {
    global Bot
    DebugLog("ClickAcceptQuest: --- Entered Function ---")
    acceptButtonFound := false

    ; Now look for the Accept button
     DebugLog("ClickAcceptQuest: Searching for Accept button...")
    ; Ensure Bot.ocr.Button.Accept pattern is correct
    if FindText(X, Y, 1861-150000, 1539-150000, 1861+150000, 1539+150000, 0, 0, Bot.ocr.Button.Accept) {
        acceptButtonFound := true
        DebugLog("ClickAcceptQuest: Found Accept button-Clicking.")
        FindText().Click(X,Y,"L")
        Sleep, 900
        ; Check AGAIN for OutOfResources immediately after clicking Accept, as it might pop up then
        if (CheckOutOfResources()) {
             DebugLog("ClickAcceptQuest: Out of resources detected AFTER clicking Accept. Returning 'outofresource'. --- Exiting function ---")
             return "outofresource"
        }
        DebugLog("ClickAcceptQuest: Clicked Accept, no immediate 'Out of Resources'. Returning 'confirmed'. --- Exiting function ---")
        return "confirmed"
    } else {
        DebugLog("ClickAcceptQuest: Accept button NOT found. Returning 'notfound'. --- Exiting function ---")
        return "notfound" ; Return a specific value if not found
    }
}
