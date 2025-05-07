; === PVP Flow ===
ActionPVP() {
    global Bot
    DebugLog("ActionPVP: --- Entered function ---")

    Loop, 2 {
    ; 1. Ensure PVP Window is Open
    pvpWindowOpen := IsPvpWindowOpen()
    DebugLog("ActionPVP: Initial IsPvpWindowOpen check returned: '" . (pvpWindowOpen ? "True" : "False") . "'")
        Sleep, 300
        }
    if (!pvpWindowOpen) {
        DebugLog("ActionPVP: PVP Window not open. Attempting to navigate...")
        DebugLog("ActionPVP: Calling ClickPVPButton...")
        if (!ClickPVPButton()) {
             DebugLog("ActionPVP: ClickPVPButton failed. Returning 'retry'.")
             return "retry"
        }
        Sleep, 600
        pvpWindowOpen := IsPvpWindowOpen() ; Check again after clicking
        DebugLog("ActionPVP: IsPvpWindowOpen (after click) returned: '" . (pvpWindowOpen ? "True" : "False") . "'")
        if (!pvpWindowOpen) {
              DebugLog("ActionPVP: PVP Window still not open after click. Returning 'retry'.")
              return "retry"
        }
        DebugLog("ActionPVP: PVP Window successfully opened.")
    } else {
        DebugLog("ActionPVP: PVP Window was already open.")
    }

    ; At this point, the PVP window *should* be open.

    ; 2. Ensure Opponent Selection Screen is Visible
    opponentsVisibleResult := OpponentsVisible()
    DebugLog("ActionPVP: OpponentsVisible check returned: '" . (opponentsVisibleResult ? "True" : "False") . "'")

    if (!opponentsVisibleResult) {
        DebugLog("ActionPVP: Opponents not visible. Attempting to reach opponent screen...")

        DebugLog("ActionPVP: Calling EnsureCorrectTickets(Choice: " . Bot.PvpTicketChoice . ")")
        ticketsCorrect := EnsureCorrectTickets(Bot.PvpTicketChoice)
        DebugLog("ActionPVP: EnsureCorrectTickets returned: '" . (ticketsCorrect ? "True" : "False") . "'")
        if (!ticketsCorrect) {
            DebugLog("ActionPVP: EnsureCorrectTickets failed. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionPVP: Tickets confirmed correct.")

        DebugLog("ActionPVP: Calling ClickPvpPlay...")
        if (!ClickPvpPlay()) {
            DebugLog("ActionPVP: ClickPvpPlay failed. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionPVP: ClickPvpPlay succeeded.")
        Sleep, 1000 ; Wait after clicking play

        DebugLog("ActionPVP: Calling CheckOutOfResources...")
        if (CheckOutOfResources()) {
            DebugLog("ActionPVP: Out of resources detected after clicking Play. Returning 'outofresource'.")
            return "outofresource"
        }
        DebugLog("ActionPVP: No 'Out Of Resources' detected after clicking Play.")

        ; Re-check if opponents are visible now after clicking Play
        opponentsVisibleResult := OpponentsVisible()
        DebugLog("ActionPVP: OpponentsVisible (after Play) returned: '" . (opponentsVisibleResult ? "True" : "False") . "'")
        if (!opponentsVisibleResult) {
            DebugLog("ActionPVP: Opponents still not visible after clicking Play. Returning 'retry'.")
            return "retry"
        }
        DebugLog("ActionPVP: Opponent screen successfully reached.")
    } else {
         DebugLog("ActionPVP: Opponents were already visible.")
    }

    ; Opponents should be visible at this point

    DebugLog("ActionPVP: Calling SelectPvpOpponent (Choice: " . Bot.PvpOpponentChoice . ")")
    opponentSelected := SelectPvpOpponent(Bot.PvpOpponentChoice)
    DebugLog("ActionPVP: SelectPvpOpponent returned: '" . (opponentSelected ? "True" : "False") . "'")
    if (!opponentSelected) {
        DebugLog("ActionPVP: SelectPvpOpponent failed. Returning 'retry'.")
        return "retry"
    }
     DebugLog("ActionPVP: Opponent selected.")


    Sleep, 500


    DebugLog("ActionPVP: Calling ClickPvpAccept...")
    accepted := ClickPvpAccept()
    DebugLog("ActionPVP: ClickPvpAccept returned: '" . (accepted ? "True" : "False") . "'")
    if (!accepted) {
         DebugLog("ActionPVP: ClickPvpAccept failed. Returning 'retry'.")
        return "retry"
    }
    DebugLog("ActionPVP: PVP Accept clicked.")

    DebugLog("ActionPVP: Performing one-time AutoPilot check.")
    autoPilotOk := EnsureAutoPilotOn()
    if (!autoPilotOk) {
        DebugLog("ActionPVP: Warning - EnsureAutoPilotOn failed after starting")
        ; Continue anyway, AutoPilot isn't critical for starting
    } else {
         DebugLog("ActionPVP: EnsureAutoPilotOn completed successfully (check its logs for details).")
    }


    DebugLog("ActionPVP: --- Success! All steps completed. Returning 'started'. ---")
    return "started"
}

MonitorPVPProgress() {
    global Bot

    actionComplete := IsActionComplete() ; Check for Town button
    DebugLog("MonitorPVPProgress: IsActionComplete returned: '" . (actionComplete ? "True" : "False") . "'")
    if (actionComplete) {
        DebugLog("MonitorPVPProgress: PVP Complete detected. Attempting ClickTownOnComplete.")
        townClicked := ClickTownOnComplete()
        DebugLog("MonitorPVPProgress: ClickTownOnComplete returned: '" . (townClicked ? "True" : "False") . "'")
        if (townClicked) {
            Sleep, 2500
            DebugLog("MonitorPVPProgress: Successfully clicked Town. Returning 'pvp_completed_continue'")
            return "pvp_completed_continue" ; Signal BotMain to go back to NormalOperation to loop PVP
        } else {
            DebugLog("MonitorPVPProgress: ClickTownOnComplete FAILED. Returning 'error'")
            return "error"
        }
    }

    ; If action is not complete, check for other states:
    disconnected := IsDisconnected()
    DebugLog("MonitorPVPProgress: IsDisconnected returned: '" . (disconnected ? "True" : "False") . "'")
    if (disconnected) {
        DebugLog("MonitorPVPProgress: Disconnected detected.")
        AttemptReconnect()
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorPVPProgress: State changed to NotLoggedIn. Returning 'disconnected'")
        return "disconnected"
    }

    playerDead := IsPlayerDead()
    DebugLog("MonitorPVPProgress: IsPlayerDead returned: '" . (playerDead ? "True" : "False") . "'")
    if (playerDead) {
        DebugLog("MonitorPVPProgress: Player Dead detected.")
        DebugLog("MonitorPVPProgress: Sending Esc to clear death screen (if possible).")
        Send, {Esc}
        Sleep, 800
        Bot.gameState := "NotLoggedIn"
        DebugLog("MonitorPVPProgress: State changed to NotLoggedIn. Returning 'player_dead'")
        return "player_dead"
    }

; PVP doesnt have IN progress dialogue

    ; If we reach here, the PVP match is still running normally
    DebugLog("MonitorPVPProgress: No end/fail state detected. Returning 'in_progress'")
    return "in_progress"
}

;PVP Helpers
IsPvpWindowOpen() {
    global Bot
    return FindText(X, Y, 679, 453, 2504, 1632, 0, 0, Bot.ocr.Pvp.Window)
}

ClickPVPButton() {
    global Bot
    if FindText(X, Y, 612, 466, 2495, 1646, 0, 0, Bot.ocr.Pvp.Button) {
        FindText().Click(X, Y, "L")
        Sleep, 800
        return true
    }
    return false
}

EnsureCorrectTickets(choice) { ; 'choice' is the desired number (1-5)
    global Bot, X, Y
    DebugLog("EnsureCorrectTickets: --- Entered function (Desired Choice: " . choice . ") ---")

    DebugLog("EnsureCorrectTickets: PART 1 - Checking current ticket selection...")
    current := "" ; Variable to store the currently selected ticket number (1-5)
    for i, pat in Bot.ocr.Pvp.TicketSelection {
        if FindText(X, Y, 581, 426, 2497, 1721, 0, 0, pat) {
            current := i ; Store the index of the pattern found
            DebugLog("EnsureCorrectTickets: Found displayed ticket pattern index " . i)
            break
        }
    }

    if (current = choice) {
        DebugLog("EnsureCorrectTickets: Tickets already set to " . choice . ". Returning True. --- Exiting function ---")
        return true ; Already correct, EXIT HERE
    }

    if (current != "") {
        DebugLog("EnsureCorrectTickets: PART 2 - Mismatch. Current is " . current . ", desired is " . choice . ". Clicking dropdown trigger.")
    } else {
        DebugLog("EnsureCorrectTickets: PART 2 - Could not determine current selection. Attempting to click dropdown trigger anyway.")
    }
    DebugLog("EnsureCorrectTickets: Searching for dropdown trigger button...")
    ; Wide coordinates
    dropdownTriggerPattern := Bot.ocr.Pvp.TicketDropdownTrigger ; Make sure this pattern is defined in Patterns.ahk
    if (FindText(X, Y, 2030-150000, 920-150000, 2030+150000, 920+150000, 0, 0, dropdownTriggerPattern)) {
        DebugLog("EnsureCorrectTickets: Found dropdown trigger at X=" . X . " Y=" . Y . ". Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 990
    } else {
        DebugLog("EnsureCorrectTickets: Dropdown trigger button NOT found! Returning False. --- Exiting function ---")
        return false ; Cannot proceed if trigger isn't found
    }

    entryPattern := Bot.ocr.Pvp.TicketMenu[choice] ; Get pattern for the desired choice number from Patterns.ahk
    if (entryPattern = "") {
         DebugLog("EnsureCorrectTickets: ERROR - No pattern defined for TicketMenu choice " . choice . ". Returning False.")
         return false
    }
    DebugLog("EnsureCorrectTickets: PART 3 - Searching for menu item pattern for choice " . choice . "...")
    if (FindText(X, Y, 905, 470, 2196, 1669, 0, 0, entryPattern)) {
        DebugLog("EnsureCorrectTickets: Found menu item " . choice . " at X=" . X . " Y=" . Y . ". Clicking.")
        FindText().Click(X, Y, "L")
        Sleep, 990


        expectedDisplayPattern := Bot.ocr.Pvp.TicketSelection[choice]
        Sleep, 300
        if (FindText(0, 0, 675, 470, 2496, 1641, 0, 0, expectedDisplayPattern)) {
             DebugLog("EnsureCorrectTickets: Tickets successfully changed to " . choice . " (verified). Returning True. --- Exiting function ---")
             return true
        } else {
             DebugLog("EnsureCorrectTickets: Clicked menu item " . choice . ", but verification failed! Returning False. --- Exiting function ---")
             return false
        }
    } else {
        DebugLog("EnsureCorrectTickets: FAILED to find menu item pattern for choice " . choice . ". Returning False. --- Exiting function ---")
        Send, {Esc} ; Try to close dropdown if click failed
        return false
    }
}

ClickPvpPlay() {
    global Bot
    if FindText(X, Y, 659, 464, 2503, 1629, 0, 0, Bot.ocr.Pvp.PlayButton) {
        FindText().Click(X, Y, "L")
        Sleep, 10
        Mousemove 300, 300
        Sleep, 800
        return true
    }
    return false
}

OpponentsVisible() {
    global Bot
    return FindText(X, Y, 451, 420, 2520, 1735, 0.09, 0.09, Bot.ocr.Pvp.OpponentList)
}

SelectPvpOpponent(choice) {
    global Bot
    DebugLog("SelectPvpOpponent: --- Entered function (User Choice: " . choice . ") ---")

    DebugLog("SelectPvpOpponent: Searching for opponent entries...")
    hits := FindText(0, 0, 451, 420, 2520, 1735, 0.09, 0.09, Bot.ocr.Pvp.OpponentList)

    if !(hits) {
        DebugLog("SelectPvpOpponent: No opponents found! Returning False. --- Exiting function ---")
        return false
    }
    DebugLog("SelectPvpOpponent: Found " . hits.MaxIndex() . " opponent button(s).")
    ;This funkiness is due to the fact that findtext returns the array of hits in a non-sequential order, so we need to map the user choice to the actual index of the hit array.
    map := [3, 1, 4, 2] ; Adjust map if needed!

    if (choice < 1 || choice > map.MaxIndex()) {
         DebugLog("SelectPvpOpponent: ERROR - Invalid PvpOpponentChoice (" . choice . ") configured. Must be between 1 and " . map.MaxIndex() . ". Returning False.")
         return false
    }

    realIdx := map[choice]
    DebugLog("SelectPvpOpponent: User choice " . choice . " maps to hits index " . realIdx)

    if (!hits[realIdx]) {
         DebugLog("SelectPvpOpponent: ERROR - Mapped index " . realIdx . " does not exist in the found 'hits' array (only found " . hits.MaxIndex() . " hits. Maybe FindText failed? Returning False.")
         return false
    }

    ; Get the specific hit object to click based on the mapped index
    hitToClick := hits[realIdx]
    clickX := hitToClick.x
    clickY := hitToClick.y

    DebugLog("SelectPvpOpponent: Clicking opponent at mapped index " . realIdx . " using coordinates (X=" . clickX . " Y=" . clickY . ")")


    FindText().Click(clickX, clickY, "L")


    Sleep, 300

    DebugLog("SelectPvpOpponent: Returning True. --- Exiting function ---")
    return true
}

ClickPvpAccept() {
    global Bot
    if FindText(X, Y, 1862-150000, 1541-150000, 1862+150000, 1541+150000, 0, 0, Bot.ocr.Pvp.AcceptButton) {
        FindText().Click(X, Y, "L")
        Sleep, 800
        return true
    }
    DebugLog("ClickPvpAccept: Accept button not found.")
    return false
}