;CURRENTLY ONLY WORKS ON 4k RESOLUTION AND 150% ZOOM BROWSER
;we can search multiple strings at once. pipe separates, example:
;Text:="|<>...pipe-separated OCR patterns..."
;─────────────────────────────────────────────;
; Bit Heroes Bot – Multi-State Logic Skeleton  ;
; (All actions have a 20-minute cooldown)       ;
;─────────────────────────────────────────────;
SetBatchLines, -1
#Include FindText.ahk
#Persistent
#SingleInstance Force

;------------- User Configurations -------------
actionConfig := {}  ; Associative array for user settings.
actionConfig["Quest"]      := True
actionConfig["PVP"]        := True
actionConfig["WorldBoss"]  := True
actionConfig["Raid"]       := True
actionConfig["Trials"]     := True
actionConfig["Expedition"] := True
actionConfig["Gauntlet"]   := True

; Define the rotation order of actions.
actionOrder := ["Quest", "PVP", "WorldBoss", "Raid", "Trials", "Expedition", "Gauntlet"]
currentActionIndex := 1

;------------- Global Variables -------------
actionCooldown := 1200000          ; 20 minutes (in ms).
lastActionTime := {}               ; Track last execution time per action.
for index, act in actionOrder {
    lastActionTime[act] := 0
}

;------------- Bot State Management -------------
; States:
; "NotLoggedIn"   – Waiting for the quest icon.
; "HandlingPopups"– Pop-ups are present; clear them.
; "NormalOperation" – Rotating through actions.
; "Paused"        – Bot is paused.
gameState := "NotLoggedIn"

DebugLog("Script started. Initial gameState = NotLoggedIn.")

; Set timer to run main bot loop every 1000 ms.
SetTimer, BotMain, 1000
Return

;─────────────────────────────────────────────;
; BotMain – Main Loop: State Transitions & Action Dispatch
;─────────────────────────────────────────────;
BotMain:
{
    if (gameState = "Paused")
        Return

    if (gameState = "NotLoggedIn") {
        DebugLog("NotLoggedIn: Checking for quest icon...")
        if (IsMainScreenAnchorDetected()) {
            DebugLog("Quest icon detected. Transitioning to NormalOperation.")
            gameState := "NormalOperation"
        } else {
            DebugLog("Quest icon not detected. Transitioning to HandlingPopups.")
            gameState := "HandlingPopups"
        }
        Return
    }
    
    if (gameState = "HandlingPopups") {
        DebugLog("HandlingPopups: Attempting to clear pop-ups...")
        popupAttempts := 0
        while (!IsMainScreenAnchorDetected()) {
            Send, {Esc}
            Sleep, 1000
            popupAttempts++
            DebugLog("HandlingPopups: Sent {Esc}, attempt #" . popupAttempts)
        }
        DebugLog("HandlingPopups: Quest icon detected. Transitioning to NormalOperation.")
        gameState := "NormalOperation"
        Return
    }
    
    if (gameState = "NormalOperation") {
        currentAction := actionOrder[currentActionIndex]
        DebugLog("NormalOperation: Current action: " . currentAction)
        
        now := A_TickCount
        if ((now - lastActionTime[currentAction]) >= actionCooldown) {
            result := ""
            Switch currentAction {
                Case "Quest":
                    DebugLog("NormalOperation: Executing Quest action.")
                    result := ActionQuest()
                Case "PVP":
                    DebugLog("NormalOperation: Executing PVP action.")
                    result := ActionPVP()
                Case "WorldBoss":
                    DebugLog("NormalOperation: Executing World Boss action.")
                    result := ActionWorldBoss()
                Case "Raid":
                    DebugLog("NormalOperation: Executing Raid action.")
                    result := ActionRaid()
                Case "Trials":
                    DebugLog("NormalOperation: Executing Trials action.")
                    result := ActionTrials()
                Case "Expedition":
                    DebugLog("NormalOperation: Executing Expedition action.")
                    result := ActionExpedition()
                Case "Gauntlet":
                    DebugLog("NormalOperation: Executing Gauntlet action.")
                    result := ActionGauntlet()
            }
            if (result = "outofresource") {
                DebugLog("NormalOperation: " . currentAction . " returned 'outofresource'; starting cooldown and advancing to next action.")
                lastActionTime[currentAction] := now
                currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
            } else if (result = "success") {
                DebugLog("NormalOperation: " . currentAction . " completed successfully; repeating action.")
                ; No cooldown update—action will be retried immediately.
            } else {
                DebugLog("NormalOperation: " . currentAction . " returned '" . result . "'; retrying on next cycle.")
            }
        } else {
            DebugLog("NormalOperation: " . currentAction . " skipped - cooldown active.")
        }
    }
}
Return

;─────────────────────────────────────────────;
; DebugLog: Helper Function for Debug Output
;─────────────────────────────────────────────;
DebugLog(msg) {
    OutputDebug, % msg
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    FileAppend, % timestamp " - " msg "`n", debug_log.txt
}

;─────────────────────────────────────────────;
; OCR & UI Detection Functions
;─────────────────────────────────────────────;
IsMainScreenAnchorDetected() {
    Text := "|<>E8D0A6-0.90$59.0zzzzs01zk1zzzzk03zU3kTzk007Us7UzzU00D1kD1zz000S3US3zy000w70w7zw001sC1zk1sD1w0Q3zU3kS3s0s7z07Uw7k1kDy0D1sDU3UTzk03zU3z0zzU07z07y1zz00Dy0Dw3zy00Tw0Ts7zw00zs0zkDzzk0001zUTzzU0003z0zzz00007y1zzy0000Dw3zzw0000Ts7zzzU00DzkDzzz000TzUTzzy000zz0zzzw001zyzzzzs01zzxzzzzk03zzvzzzzU07zzrzzzz00Dzzjzzzy00TzzTzzz0001zyzzzy0003zxzzzw0007zvzzzs000Dzrzzs0zs01zjzzk1zk03zTzzU3zU07yzzz07z00Dxzzy0Dy00Tzzz3zz000zzzy7zy001zzzwDzw003zzzsTzs007zzsDzzk00DXzkTzzU00T7zUzzz000yDz1zzy001wTy3zzw003szzzzzs01s1zzzzzk03k3zzzzzU07U7zzzzz00D0Dz07zzzzzwTy0Dzzzzzszw0Tzzzzzlzs0zzzzzzXzk1zzzzzz7s007zzzzyDk00DzzzzwTU00Tzzzzsz000zzzzzly001zzzzzW0000DzzzU40000Tzzz080000zzzy0E0001zzzw0U0003zzy0100007zzw02"
    if (ok := FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Text)) {
        SoundBeep, 800, 200
        DebugLog("IsMainScreenAnchorDetected: Quest icon detected.")
        Return True
    }
    DebugLog("IsMainScreenAnchorDetected: Quest icon NOT detected.")
    Return False
}

ArePopupsPresent() {
    Text := "|<>**50$59.k07w01z00CU08000200F00E000400W00U0008014010000E028020000U04E07y03z008U00404000F000808000W000E0E0014000U0U0028001010004E003zy0008zU000000zk1000000100200000020040000004008000000800E000000E00U000000U01zU0003z0001000040000200008000040000E000080000U0000E000100000U000200001000040000200008000040000E000080000U0000E000100000U00020003z00007y0040000004008000000800E000000E00U000000U01000000103y0000003z4000zzU0028001010004E002020008U00404000F000808000W000E0E0014000U0U002E"
    if (ok := FindText(X, Y, 2177-150000, 680-150000, 2177+150000, 680+150000, 0, 0, Text)) {
        DebugLog("ArePopupsPresent: Popup detected (red X).")
        Return True
    }
    Return False
}

;─────────────────────────────────────────────;
; Shared Resource Check Function
;─────────────────────────────────────────────;
CheckOutOfResources() {
    ; This function checks if a “resource out” indicator is visible.
    ; Replace the OCR string with your resource-warning string.
    Text := "|<>RESOURCE-OUT$placeholder"
    if (ok := FindText(X, Y, 1000-150000, 800-150000, 1000+150000, 800+150000, 0, 0, Text))
        return true
    return false
}

;─────────────────────────────────────────────;
; Quest Action – Full Quest Logic
;─────────────────────────────────────────────;
ActionQuest() {
    ; Step 1: Open the Quest Window if it isn’t already open.
    if (!IsQuestWindowOpen()) {
        DebugLog("ActionQuest: Quest window not open. Clicking quest icon.")
        ClickQuestIcon()
        Sleep, 500
        if (!IsQuestWindowOpen()) {
            DebugLog("ActionQuest: Quest window still not detected; retrying later.")
            return "retry"
        }
    }
    ; Step 2: Navigate to the desired dungeon/zone.
    if (!EnsureCorrectZoneSelected()) {
        DebugLog("ActionQuest: Could not navigate to the desired zone; retrying.")
        return "retry"
    }
    ; Step 3: Select Heroic difficulty.
    if (!SelectHeroicDifficulty()) {
        DebugLog("ActionQuest: Failed to select Heroic difficulty; retrying.")
        return "retry"
    }
    ; Step 4: Click Accept.
    if (!ClickAccept()) {
        DebugLog("ActionQuest: Accept button was not confirmed; retrying.")
        return "retry"
    }
    Sleep, 500
    ; Step 5: After Accept, check if we are out of resources.
    if (CheckOutOfResources()) {
        DebugLog("ActionQuest: Detected resource shortage after Accept.")
        return "outofresource"
    }
    DebugLog("ActionQuest: Quest action completed successfully.")
    return "success"
}

;─────────────────────────────────────────────;
; Quest Helper Functions
;─────────────────────────────────────────────;
IsQuestWindowOpen() {
    ; Use OCR to check if the quest window (list) is visible.
    Text := "|<>QUEST-WINDOW$pattern"  ; Replace with your OCR string for the quest window.
    if (ok := FindText(X, Y, 500-150000, 400-150000, 500+150000, 400+150000, 0, 0, Text))
        return true
    return false
}

ClickQuestIcon() {
    ; Simulate clicking on the quest icon.
    MouseClick, left, 800, 300
    DebugLog("ClickQuestIcon: Quest icon clicked.")
}

EnsureCorrectZoneSelected() {
    ; Example: you might have an array of zone names. Here we suppose the desired zone is "Zone3".
    zones := ["Zone1", "Zone2", "Zone3", "Zone4"]
    desiredZone := "Zone3"
    currentZone := DetectCurrentZone()
    attempts := 0
    while (currentZone != desiredZone) {
        if (currentZone = "") {
            DebugLog("EnsureCorrectZoneSelected: Unable to detect current zone; retrying.")
        } else if (currentZone < desiredZone) {
            ClickRightArrow()
        } else {
            ClickLeftArrow()
        }
        Sleep, 500
        currentZone := DetectCurrentZone()
        attempts++
        if (attempts > 20) {
            DebugLog("EnsureCorrectZoneSelected: Failed to select the desired zone after 20 attempts.")
            return false
        }
    }
    DebugLog("EnsureCorrectZoneSelected: Desired zone selected: " . desiredZone)
    return true
}

DetectCurrentZone() {
    ; Use OCR on the zone region to determine the current zone.
    Text := "|<>Zone2$pattern"  ; Placeholder OCR string for current zone.
    if (ok := FindText(X, Y, 600-150000, 500-150000, 600+150000, 500+150000, 0, 0, Text))
        return "Zone2"
    return ""
}

ClickRightArrow() {
    MouseClick, left, 1000, 500
    DebugLog("ClickRightArrow: Right arrow clicked.")
}

ClickLeftArrow() {
    MouseClick, left, 700, 500
    DebugLog("ClickLeftArrow: Left arrow clicked.")
}

SelectHeroicDifficulty() {
    ; Click on the Heroic difficulty button.
    MouseClick, left, 850, 600
    Sleep, 500
    if (IsHeroicSelected())
        return true
    return false
}

IsHeroicSelected() {
    ; Use OCR to verify if Heroic difficulty is selected.
    Text := "|<>HEROIC$pattern"  ; Placeholder OCR string for Heroic selection.
    if (ok := FindText(X, Y, 840-150000, 590-150000, 840+150000, 590+150000, 0, 0, Text))
        return true
    return false
}

ClickAccept() {
    ; Click the Accept button.
    MouseClick, left, 900, 700
    DebugLog("ClickAccept: Accept button clicked.")
    Sleep, 500
    if (IsAcceptConfirmed())
        return true
    return false
}

IsAcceptConfirmed() {
    ; Use OCR to check if the Accept confirmation is visible.
    Text := "|<>ACCEPTED$pattern"  ; Placeholder OCR string for accept confirmation.
    if (ok := FindText(X, Y, 900-150000, 700-150000, 900+150000, 700+150000, 0, 0, Text))
        return true
    return false
}

;─────────────────────────────────────────────;
; Other Action Functions (PVP, WorldBoss, Raid, Trials, Expedition, Gauntlet)
; remain similar with shared resource check.
;─────────────────────────────────────────────;
ActionPVP() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionPVP: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionPVP: Executed successfully.")
    return "success"
}

ActionWorldBoss() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionWorldBoss: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionWorldBoss: Executed successfully.")
    return "success"
}

ActionRaid() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionRaid: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionRaid: Executed successfully.")
    return "success"
}

ActionTrials() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionTrials: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionTrials: Executed successfully.")
    return "success"
}

ActionExpedition() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionExpedition: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionExpedition: Executed successfully.")
    return "success"
}

ActionGauntlet() {
    Sleep, 500
    if (CheckOutOfResources()) {
        DebugLog("ActionGauntlet: Out of resources detected.")
        return "outofresource"
    }
    DebugLog("ActionGauntlet: Executed successfully.")
    return "success"
}

;─────────────────────────────────────────────;
; Hotkey: Toggle Bot Activity (F12)
;─────────────────────────────────────────────;
F12::
    if (gameState = "Paused") {
        gameState := "NotLoggedIn"
        DebugLog("Resumed via hotkey. Resetting state to NotLoggedIn.")
    } else {
        previousState := gameState
        gameState := "Paused"
        DebugLog("Paused via hotkey. Previous state: " . previousState)
    }
    Return
