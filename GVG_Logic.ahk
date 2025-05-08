; === GVG Flow ===
ActionGVG() {
    global Bot
    DebugLog("ActionGVG: --- Entered function ---")

    Loop, 2 {
    ; 1. Ensure GVG Window is Open
    GVGWindowOpen := IsGVGWindowOpen()
    DebugLog("ActionGVG: Initial IsGVGWindowOpen check returned: '" . (GVGWindowOpen ? "True" : "False") . "'")
        Sleep, 300
        }
    if (!GVGWindowOpen) {
        DebugLog("ActionGVG: GVG Window not open. Attempting to navigate...")
        DebugLog("ActionGVG: Calling ClickGVGButton...")
        if (!ClickGVGButton()) {
             DebugLog("ActionGVG: ClickGVGButton failed. Returning 'retry'.")
             return "retry"
        }
        Sleep, 600
        GVGWindowOpen := IsGVGWindowOpen() ; Check again after clicking
        DebugLog("ActionGVG: IsGVGWindowOpen (after click) returned: '" . (GVGWindowOpen ? "True" : "False") . "'")
        if (!GVGWindowOpen) {
              DebugLog("ActionGVG: GVG Window still not open after click. Returning 'retry'.")
              return "retry"
        }
        DebugLog("ActionGVG: GVG Window successfully opened.")
    } else {
        DebugLog("ActionGVG: GVG Window was already open.")
    }

    ; At this point, the GVG window *should* be open.

    ; 2. Ensure Opponent Selection Screen is Visible
    opponentsVisibleResult := GVGOpponentsVisible()
    DebugLog("ActionGVG: OpponentsVisible check returned: '" . (opponentsVisibleResult ? "True" : "False") . "'")

    if (!opponentsVisibleResult) {
        DebugLog("ActionGVG: Opponents not visible. Attempting to reach opponent screen...")

        DebugLog("ActionGVG: Calling EnsureCorrectBadges(Choice: " . Bot.GVGBadgeChoice . ")")
        BadgesCorrect := EnsureCorrectBadges(Bot.GVGBadgeChoice)
        DebugLog("ActionGVG: EnsureCorrectBadges returned: '" . (BadgesCorrect ? "True" : "False") . "'")
        if (!BadgesCorrect) {
            DebugLog("ActionGVG: EnsureCorrectBadges failed. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionGVG: Badges confirmed correct.")

        DebugLog("ActionGVG: Calling ClickGVGPlay...")
        if (!ClickGVGPlay()) {
            DebugLog("ActionGVG: ClickGVGPlay failed. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionGVG: ClickGVGPlay succeeded.")
        Sleep, 1000 ; Wait after clicking play

        DebugLog("ActionGVG: Calling CheckOutOfResources...")
        if (CheckOutOfResources()) {
            DebugLog("ActionGVG: Out of resources detected after clicking Play. Returning 'outofresource'.")
            return "outofresource"
        }
        DebugLog("ActionGVG: No 'Out Of Resources' detected after clicking Play.")

        ; Re-check if opponents are visible now after clicking Play
        opponentsVisibleResult := GVGOpponentsVisible()
        DebugLog("ActionGVG: OpponentsVisible (after Play) returned: '" . (opponentsVisibleResult ? "True" : "False") . "'")
        if (!opponentsVisibleResult) {
            DebugLog("ActionGVG: Opponents still not visible after clicking Play. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionGVG: Opponent screen successfully reached.")
    } else {
         DebugLog("ActionGVG: Opponents were already visible.")
    }

    ; Opponents should be visible at this point

    DebugLog("ActionGVG: Calling SelectGVGOpponent (Choice: " . Bot.GVGOpponentChoice . ")")
    opponentSelected := SelectGVGOpponent(Bot.GVGOpponentChoice)
    DebugLog("ActionGVG: SelectGVGOpponent returned: '" . (opponentSelected ? "True" : "False") . "'")
    if (!opponentSelected) {
        DebugLog("ActionGVG: SelectGVGOpponent failed. Returning 'retry'.")
        return "retry"
    }
     DebugLog("ActionGVG: Opponent selected.")


    Sleep, 500


    DebugLog("ActionGVG: Calling ClickGVGAccept...")
    accepted := ClickGVGAccept()
    DebugLog("ActionGVG: ClickGVGAccept returned: '" . (accepted ? "True" : "False") . "'")
    if (!accepted) {
         DebugLog("ActionGVG: ClickGVGAccept failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionGVG: GVG Accept clicked.")

    DebugLog("ActionGVG: Performing one-time AutoPilot check.")
    autoPilotOk := EnsureAutoPilotOn()
    if (!autoPilotOk) {
        DebugLog("ActionGVG: Warning - EnsureAutoPilotOn failed after starting")
        ; Continue anyway, AutoPilot isn't critical for starting
    } else {
         DebugLog("ActionGVG: EnsureAutoPilotOn completed successfully (check its logs for details).")
    }


    DebugLog("ActionGVG: --- Success! All steps completed. Returning 'started'. ---")
    return "started"
}

MonitorGVGProgress() {
    global Bot

    actionComplete := IsActionComplete() ; Check for Town button
    DebugLog("MonitorGVGProgress: IsActionComplete returned: '" . (actionComplete ? "True" : "False") . "'")
    if (actionComplete) {
        DebugLog("MonitorGVGProgress: GVG Complete detected. Attempting ClickTownOnComplete.")
        townClicked := ClickTownOnComplete()
        DebugLog("MonitorGVGProgress: ClickTownOnComplete returned: '" . (townClicked ? "True" : "False") . "'")
        if (townClicked) {
            Sleep, 2500
            DebugLog("MonitorGVGProgress: Successfully clicked Town. Returning 'GVG_completed_continue'")
            return "GVG_completed_continue" ; Signal BotMain to go back to NormalOperation to loop GVG
        } else {
            DebugLog("MonitorGVGProgress: ClickTownOnComplete FAILED. Returning 'error'")
            return "error"
        }
    }

    ; If action is not complete, check for other states:
    disconnected := IsDisconnected()
    DebugLog("MonitorGVGProgress: IsDisconnected returned: '" . (disconnected ? "True" : "False") . "'")
    if (disconnected) {
        DebugLog("MonitorGVGProgress: Disconnected detected.")
        AttemptReconnect()
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorGVGProgress: State changed to NotLoggedIn. Returning 'disconnected'")
        return "disconnected"
    }

    playerDead := IsPlayerDead()
    DebugLog("MonitorGVGProgress: IsPlayerDead returned: '" . (playerDead ? "True" : "False") . "'")
    if (playerDead) {
        DebugLog("MonitorGVGProgress: Player Dead detected.")
        DebugLog("MonitorGVGProgress: Sending Esc to clear death screen (if possible).")
        Send, {Esc}
        Sleep, 800
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorGVGProgress: State changed to NotLoggedIn. Returning 'player_dead'")
        return "player_dead"
    }

; GVG doesnt have IN progress dialogue

    ; If we reach here, the GVG match is still running normally
    DebugLog("MonitorGVGProgress: No end/fail state detected. Returning 'in_progress'")
    return "in_progress"
}

;GVG Helpers
IsGVGWindowOpen() {
    global Bot
    return FindText(X, Y, 679, 453, 2504, 1632, 0, 0, Bot.ocr.GVG.Window)
}

ClickGVGButton() {
    global Bot
    if FindText(X, Y, 612, 466, 2495, 1646, 0, 0, Bot.ocr.GVG.Button) {
        FindText().Click(X, Y, "L")
        Sleep, 800
        return true
    }
    return false
}

EnsureCorrectBadges(choice) { ; 'choice' is the desired number (1-5)
    global Bot, X, Y
    DebugLog("EnsureCorrectBadges: --- Entered function (Desired Choice: " . choice . ") ---")

    DebugLog("EnsureCorrectBadges: PART 1 - Checking current Badge selection...")
    current := "" ; Variable to store the currently selected Badge number (1-5)
    for i, pat in Bot.ocr.GVG.BadgeSelection {
        if FindText(X, Y, 581, 426, 2497, 1721, 0, 0, pat) {
            current := i ; Store the index of the pattern found
            DebugLog("EnsureCorrectBadges: Found displayed Badge pattern index " . i)
            break
        }
    }

    if (current = choice) {
        DebugLog("EnsureCorrectBadges: Badges already set to " . choice . ". Returning True. --- Exiting function ---")
        return true ; Already correct, EXIT HERE
    }

    if (current != "") {
        DebugLog("EnsureCorrectBadges: PART 2 - Mismatch. Current is " . current . ", desired is " . choice . ". Clicking dropdown trigger.")
    } else {
        DebugLog("EnsureCorrectBadges: PART 2 - Could not determine current selection. Attempting to click dropdown trigger anyway.")
    }
    DebugLog("EnsureCorrectBadges: Searching for dropdown trigger button...")
    ; Wide coordinates
    dropdownTriggerPattern := Bot.ocr.GVG.BadgeDropdownTrigger ; Make sure this pattern is defined in Patterns.ahk
    if (FindText(X, Y, 2030-150000, 920-150000, 2030+150000, 920+150000, 0, 0, dropdownTriggerPattern)) {
        DebugLog("EnsureCorrectBadges: Found dropdown trigger at X=" . X . " Y=" . Y . ". Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 990
    } else {
        DebugLog("EnsureCorrectBadges: Dropdown trigger button NOT found! Returning False. --- Exiting function ---")
        return false ; Cannot proceed if trigger isn't found
    }

    entryPattern := Bot.ocr.GVG.BadgeMenu[choice] ; Get pattern for the desired choice number from Patterns.ahk
    if (entryPattern = "") {
         DebugLog("EnsureCorrectBadges: ERROR - No pattern defined for BadgeMenu choice " . choice . ". Returning False.")
         return false
    }
    DebugLog("EnsureCorrectBadges: PART 3 - Searching for menu item pattern for choice " . choice . "...")
    if (FindText(X, Y, 905, 470, 2196, 1669, 0, 0, entryPattern)) {
        DebugLog("EnsureCorrectBadges: Found menu item " . choice . " at X=" . X . " Y=" . Y . ". Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 990


        expectedDisplayPattern := Bot.ocr.GVG.BadgeSelection[choice]
        Sleep, 300
        if (FindText(0, 0, 675, 470, 2496, 1641, 0, 0, expectedDisplayPattern)) {
             DebugLog("EnsureCorrectBadges: Badges successfully changed to " . choice . " (verified). Returning True. --- Exiting function ---")
             return true
        } else {
             DebugLog("EnsureCorrectBadges: Clicked menu item " . choice . ", but verification failed! Returning False. --- Exiting function ---")
             return false
        }
    } else {
        DebugLog("EnsureCorrectBadges: FAILED to find menu item pattern for choice " . choice . ". Returning False. --- Exiting function ---")
        Send, {Esc} ; Try to close dropdown if click failed
        return false
    }
}

ClickGVGPlay() {
    global Bot
    if FindText(X, Y, 659, 464, 2503, 1629, 0, 0, Bot.ocr.GVG.PlayButton) {
        FindText().Click(X, Y, "L")
        Sleep, 10
        Mousemove 300, 300
        Sleep, 800
        return true
    }
    return false
}

HandleGvgParticipationWarning() {
    global Bot
    DebugLog("HandleGvgParticipationWarning: --- Entered function ---")
; this function is not called yet, but it is necessary for the GVG to not hang if the user has not clicked the participation warning yet.
; the one about not being able to leave or be kicked from a guild if you participate in GVG.
    if FindText(WarnX, WarnY, 500, 500, 2500, 1700, 0, 0, Bot.ocr.Gvg.ParticipationWarning) {
        DebugLog("HandleGvgParticipationWarning: Found GVG participation warning popup.")

        ; Now find the confirm button *within* or *near* the popup area
        ; Use coordinates relative to the found warning (WarnX, WarnY) or a slightly larger fixed area
        if FindText(ConfirmX, ConfirmY, WarnX-100, WarnY, WarnX+400, WarnY+300, 0, 0, Bot.ocr.Gvg.ParticipationConfirm) {
            DebugLog("HandleGvgParticipationWarning: Found Confirm button. Clicking.")
            FindText().Click(ConfirmX, ConfirmY, "L")
            Sleep, 600 ; Pause after clicking confirm
            DebugLog("HandleGvgParticipationWarning: --- Exiting function (Warning Handled) ---")
            return true ; Indicate the warning was found and handled
        } else {
            DebugLog("HandleGvgParticipationWarning: Warning popup found, but Confirm button NOT found! Manual intervention might be needed.")
            DebugLog("HandleGvgParticipationWarning: --- Exiting function (Error) ---")
            return false ; Indicate an error state (warning present but couldn't confirm)
        }
    } else {
        DebugLog("HandleGvgParticipationWarning: Participation warning popup not found (normal after first time).")
        DebugLog("HandleGvgParticipationWarning: --- Exiting function (Not Found) ---")
        return false ; Indicate the warning wasn't found (expected on subsequent runs)
    }
}


GVGOpponentsVisible() {
    global Bot
    return FindText(X, Y, 451, 420, 2520, 1735, 0.09, 0.09, Bot.ocr.GVG.OpponentList)
}

SelectGVGOpponent(choice) {
    global Bot
    DebugLog("SelectGVGOpponent: --- Entered function (User Choice: " . choice . ") ---")

    DebugLog("SelectGVGOpponent: Searching for opponent entries...")
    hits := FindText(0, 0, 451, 420, 2520, 1735, 0.09, 0.09, Bot.ocr.GVG.OpponentList)

    if !(hits) {
        DebugLog("SelectGVGOpponent: No opponents found! Returning False. --- Exiting function ---")
        return false
    }
    DebugLog("SelectGVGOpponent: Found " . hits.MaxIndex() . " opponent button(s).")
    ;This funkiness is due to the fact that findtext returns the array of hits in a non-sequential order, so we need to map the user choice to the actual index of the hit array.
    map := [3, 1, 4, 2] ; Adjust map if needed!

    if (choice < 1 || choice > map.MaxIndex()) {
         DebugLog("SelectGVGOpponent: ERROR - Invalid GVGOpponentChoice (" . choice . ") configured. Must be between 1 and " . map.MaxIndex() . ". Returning False.")
         return false
    }

    realIdx := map[choice]
    DebugLog("SelectGVGOpponent: User choice " . choice . " maps to hits index " . realIdx)

    if (!hits[realIdx]) {
         DebugLog("SelectGVGOpponent: ERROR - Mapped index " . realIdx . " does not exist in the found 'hits' array (only found " . hits.MaxIndex() . " hits. Maybe FindText failed? Returning False.")
         return false
    }

    ; Get the specific hit object to click based on the mapped index
    hitToClick := hits[realIdx]
    clickX := hitToClick.x
    clickY := hitToClick.y

    DebugLog("SelectGVGOpponent: Clicking opponent at mapped index " . realIdx . " using coordinates (X=" . clickX . " Y=" . clickY . ")")


    FindText().Click(clickX, clickY, "L")


    Sleep, 300

    DebugLog("SelectGVGOpponent: Returning True. --- Exiting function ---")
    return true
}

ClickGVGAccept() {
    global Bot
    if FindText(X, Y, 1862-150000, 1541-150000, 1862+150000, 1541+150000, 0, 0, Bot.ocr.GVG.AcceptButton) {
        FindText().Click(X, Y, "L")
        Sleep, 800
        return true
    }
    DebugLog("ClickGVGAccept: Accept button not found.")
    return false
}