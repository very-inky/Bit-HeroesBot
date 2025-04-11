;===========================================
; Bit Heroes Bot – Multi-State Logic Skeleton
;CURRENTLY ONLY WORKS ON 4k RESOLUTION AND 150% ZOOM BROWSER
;we can search multiple strings at once. pipe separates, example:
;Text:="|<>...pipe-separated OCR patterns..."
;===========================================

SetBatchLines, -1
#Include FindText.ahk
#Persistent
#SingleInstance Force

;------------- User Configurations -------------
actionConfig := {}   ; Associative array for action settings.
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

;------------- Multiple Choice Configuration -------------
; Specify multiple desired zone/dungeon pairs.
; In this example, the bot rotates between:
;  - Option 1: Zone6 with Dungeon3
;  - Option 2: Zone7 with Dungeon1
desiredZones := ["Zone6", "Zone7"]
desiredDungeons := ["Dungeon3", "Dungeon1"]  ; Corresponding dungeon choices.
global currentSelectionIndex := 1  ; Tracks which pair to use on this run.

;------------- Global Variables -------------
actionCooldown := 1200000          ; 20 minutes (in ms).
lastActionTime := {}               ; Track last execution time per action.
for index, act in actionOrder {
    lastActionTime[act] := 0
}

;------------- Bot State Management -------------
; States:
;   "NotLoggedIn"     - Waiting for the quest icon.
;   "HandlingPopups"  - Pop-ups are present; clear them.
;   "NormalOperation" - Rotating through actions.
;   "Paused"          - Bot is paused.
gameState := "NotLoggedIn"

DebugLog("Script started. Initial gameState = NotLoggedIn.")

; The only timer used is the main loop timer:
SetTimer, BotMain, 1000  ; Main loop runs every 1000 ms.
Return

;===========================================
; BotMain – Main Loop: State Transitions & Action Dispatch
;===========================================
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
                ; Action repeats immediately (no cooldown update).
            } else {
                DebugLog("NormalOperation: " . currentAction . " returned '" . result . "'; retrying on next cycle.")
            }
        } else {
            DebugLog("NormalOperation: " . currentAction . " skipped - cooldown active.")
        }
    }
}
Return

;===========================================
; DebugLog: Helper Function for Debug Output
;===========================================
DebugLog(msg) {
    OutputDebug, % msg
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    FileAppend, % timestamp " - " msg "`n", debug_log.txt
}

;===========================================
; OCR & UI Detection Functions (using placeholder OCR strings)
;===========================================
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


CheckOutOfResources() {
    ; Replace with your resource-out OCR pattern.
    Text := "|<>[ResourceOut OCR Pattern]"
    if (ok := FindText(X, Y, 1000-150000, 800-150000, 1000+150000, 800+150000, 0, 0, Text))
        return true
    return false
}

;===========================================
; Quest Action – Full Quest Logic
;===========================================
ActionQuest() {
    ; Step 1: Open the Quest Window if not already open.
    if (!IsQuestWindowOpen()) {
        DebugLog("ActionQuest: Quest window not open. Clicking quest icon.")
        ClickQuestIcon()
        Sleep, 500
        if (!IsQuestWindowOpen()) {
            DebugLog("ActionQuest: Quest window still not detected; retrying later.")
            return "retry"
        }
    }
    
    ; Step 2: Retrieve the current desired zone/dungeon configuration.
    global desiredZones, desiredDungeons, currentSelectionIndex
    selectedZone := desiredZones[currentSelectionIndex]
    selectedDungeon := desiredDungeons[currentSelectionIndex]   ; Optional: for dungeon selection.
    DebugLog("ActionQuest: Selected configuration: " . selectedZone . " - " . selectedDungeon)
    
    ; Step 3: Navigate to the desired zone.
    if (!EnsureCorrectZoneSelected(selectedZone)) {
        DebugLog("ActionQuest: Could not navigate to " . selectedZone . "; retrying.")
        return "retry"
    }
    
    ; Step 4: (Optional) Navigate/select the desired dungeon.
    ; Implement EnsureCorrectDungeonSelected(selectedDungeon) if needed.
    
    ; Step 5: Select Heroic difficulty.
    if (!SelectHeroicDifficulty()) {
        DebugLog("ActionQuest: Failed to select Heroic difficulty; retrying.")
        return "retry"
    }
    
    ; Step 6: Click Accept.
    if (!ClickAccept()) {
        DebugLog("ActionQuest: Accept button was not confirmed; retrying.")
        return "retry"
    }
    Sleep, 500
    
    ; Step 7: Check for resource shortage.
    if (CheckOutOfResources()) {
        DebugLog("ActionQuest: Detected resource shortage after Accept.")
        return "outofresource"
    }
    
    DebugLog("ActionQuest: Quest action completed successfully.")
    
    ; Step 8: Update selection index to rotate configuration.
    currentSelectionIndex := Mod(currentSelectionIndex, desiredZones.Length()) + 1
    return "success"
}

;===========================================
; Quest Helper Functions
;===========================================
IsQuestWindowOpen() {
    ; this OCR string is Zones button inside the quest menu, on map.
 Text:="|<>*143$173.00003zw003zzk00Dzz0000zy0003s00007zs007zzU00Tzy0001zw0007k0000DzU00Dzz000zzw0003zk000DU0000Tk0000z00003w00007s0000T00000zU0001y00007s0000Dk0000y00001z00003w0000Dk0000TU0001w00003y00007s0000TU0001z00003tzzk07w0Ty0Dk1zs0z07zzzy0DzzznzzU0Ds0zw0TU3zk1y0Dzzzw0Tzzzbzz00Tk1zs0z07zU3w0Tzzzs0zzzyDzy00zU3zk1y0Dz07s0zzzzk1zzzsTzw0Tz07zU3w0Ty0Dk1zzzjU3zzzU7w00zy0Dz07s0zw0TU00DUT0001zUTs01zw0Ty0Dk1zs0z000T0y0003zVzk03zs0zw0TU3zk1y000y1w0007z3zU07zk1zs0z07zU3w001w3s000DzDy07zjU3zk1y0Dz07s003s7zU00TyT00DyT07zU3w0Ty0Dk007kDz0001wy00Twy0Dz07s0zw0TU00DUTy0003tw00zzw0Ty0Dk1zs0z000Tzzw0007zs01zzs0zw0TU3zk1y000zzzs000Ds01zzzk1zs0z07zU3w0Tzzzzzzw0Tk03zzzU3zk1y0Dz07s0zzzzzzzs0zU07zzz07zU3w0Ty0Dk1zzzzzzzk1z00Dzzy0Dz07s0zw0TU3zzzzzzzU3y00Tzzw0Ty0Dk1zs0z07zzzzzzz07w0000Ds0000TU3zk1y00007w0000Ds0000Tk0000z07zU3w00007s0000Tk0000zU0001y0Dz07s0000Dk0000zU0001z00003w0Ty0Dk0000TU0001z00003zw003zs0zw0Tz0000z0001zy00007zs007zk1zs0zy0001y0003zw0000Dzk00DzU3zk1zw0003w0007zs0000TzU00Tz07zU3zs0007s000Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    if (ok:=FindText(X, Y, 1045-150000, 642-150000, 1045+150000, 642+150000, 0, 0, Text)) {
        return true
    }
    return false
}

ClickQuestIcon() {
    ; Simulate clicking on the quest icon.
    Text := "|<>E8D0A6-0.90$59.0zzzzs01zk1zzzzk03zU3kTzk007Us7UzzU00D1kD1zz000S3US3zy000w70w7zw001sC1zk1sD1w0Q3zU3kS3s0s7z07Uw7k1kDy0D1sDU3UTzk03zU3z0zzU07z07y1zz00Dy0Dw3zy00Tw0Ts7zw00zs0zkDzzk0001zUTzzU0003z0zzz00007y1zzy0000Dw3zzw0000Ts7zzzU00DzkDzzz000TzUTzzy000zz0zzzw001zyzzzzs01zzxzzzzk03zzvzzzzU07zzrzzzz00Dzzjzzzy00TzzTzzz0001zyzzzy0003zxzzzw0007zvzzzs000Dzrzzs0zs01zjzzk1zk03zTzzU3zU07yzzz07z00Dxzzy0Dy00Tzzz3zz000zzzy7zy001zzzwDzw003zzzsTzs007zzsDzzk00DXzkTzzU00T7zUzzz000yDz1zzy001wTy3zzw003szzzzzs01s1zzzzzk03k3zzzzzU07U7zzzzz00D0Dz07zzzzzwTy0Dzzzzzszw0Tzzzzzlzs0zzzzzzXzk1zzzzzz7s007zzzzyDk00DzzzzwTU00Tzzzzsz000zzzzzly001zzzzzW0000DzzzU40000Tzzz080000zzzy0E0001zzzw0U0003zzy0100007zzw02"
    if (ok := FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Text)) 
    {
        FindText().Click(X, Y, "L")
        sleep 100
        DebugLog("ClickQuestIcon: Quest icon clicked.")
    }
}
SelectHeroicDifficulty() {
    ; Simulate clicking the Heroic difficulty button (coordinates may need adjustment).
    MouseClick, left, 850, 600
    Sleep, 500
    if (IsHeroicSelected())
        return true
    return false
}

IsHeroicSelected() {
    ; Replace with your actual OCR string that confirms Heroic selection.
    Text := "|<>[Heroic Selected OCR Pattern]"
    if (ok := FindText(X, Y, 840-150000, 590-150000, 840+150000, 590+150000, 0, 0, Text))
        return true
    return false
}

ClickAccept() {
    ; Simulate clicking the Accept button.
    MouseClick, left, 900, 700
    DebugLog("ClickAccept: Accept button clicked.")
    Sleep, 500
    if (IsAcceptConfirmed())
        return true
    return false
}

IsAcceptConfirmed() {
    ; Replace with your actual OCR string that confirms Accept.
    Text := "|<>[Accept Confirmation OCR Pattern]"
    if (ok := FindText(X, Y, 900-150000, 700-150000, 900+150000, 700+150000, 0, 0, Text))
        return true
    return false
}

;===========================================
; Other Action Functions (PVP, WorldBoss, Raid, Trials, Expedition, Gauntlet)
; Each uses CheckOutOfResources for a simple resource check.
;===========================================
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

;===========================================
; Navigation Functions (Arrow Clicks & Zone Selection)
;===========================================
ClickRightArrow() {
    Text:="|<>*120$57.z0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz0007zzzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z00000000zs00000007z0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs000000Dzz0000001zzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz000003zzzs00000Tzzz00007zzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs0000zzzzz00007zzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs000zzzzzz0007zzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz00Dzzzzzzs01zzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzzs3zzzzzzzz0Tzzzzzzw"
if (ok:=FindText(X, Y, 2128, 891, 2640, 1378, 0, 0, Text))
{
   FindText().Click(X, Y, "L")
}
    DebugLog("ClickRightArrow: Right arrow clicked.")
    Sleep, 500
}

ClickLeftArrow() {
    ; Replace with coordinates for the left arrow button.
    Text:="|<>*133$53.zzzzzzlzzzzzzzzXzzzzzzzzs3zzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzU07zzzzzz00Dzzzzzy00Tzzzzzw00zzzzzzs01zzzzzzk03zzzzzzU07zzzzy000Dzzzzw000Tzzzzs000zzzzzk001zzzzzU003zzzzz0007zzzzy000Dzzzw0000Tzzzs0000zzzzk0001zzzzU0003zzzz00007zzzy0000Dzzs00000Tzzk00000zzzU00001zzz000003zzy000007zzw00000Dzzs00000TzU000000zz0000001zy0000003zw0000007zs000000Dzk000000TzU000000y00000001w00000003s00000007k0000000DU0000000T00000000y00000001w00000003s00000007k0000000DU0000000T00000000y00000001zy0000003zw0000007zs000000Dzk000000TzU000000zz0000001zy0000003zzy000007zzw00000Dzzs00000Tzzk00000zzzU00001zzz000003zzy000007zzzy0000Dzzzw0000Tzzzs0000zzzzk0001zzzzU0003zzzz00007zzzy0000Dzzzzw000Tzzzzs000zzzzzk001zzzzzU003zzzzz0007zzzzy000Dzzzzzy00Tzzzzzw00zzzzzzs01zzzzzzk03zzzzzzU07zzzzzz00Dzzzzzy00Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzXzzzzzzzz7zzzzzzzyDzzzzzzzwTzzzzzzzszzzzzzzzlzz"
if (ok:=FindText(X, Y, 592, 742, 1005, 1383, 0, 0, Text))
{
  FindText().Click(X, Y, "L")
}
    DebugLog("ClickLeftArrow: Left arrow clicked.")
    Sleep, 500
}

EnsureCorrectZoneSelected(targetZone) {
    currentZone := DetectCurrentZone()
    attempts := 0
    
    ; Instead of creating and assigning in one line, build the object step-by-step.
    zoneIndex := {}  
    zoneIndex["Zone1"] := 1
    zoneIndex["Zone2"] := 2
    zoneIndex["Zone3"] := 3
    zoneIndex["Zone4"] := 4
    zoneIndex["Zone5"] := 5
    zoneIndex["Zone6"] := 6
    zoneIndex["Zone7"] := 7
    zoneIndex["Zone8"] := 8
    zoneIndex["Zone9"] := 9
    zoneIndex["Zone10"] := 10
    
    while (currentZone != targetZone) {
        if (currentZone = "") {
            DebugLog("EnsureCorrectZoneSelected: Unable to detect current zone; retrying.")
        } else if (zoneIndex[currentZone] < zoneIndex[targetZone]) {
            ClickRightArrow()
        } else if (zoneIndex[currentZone] > zoneIndex[targetZone]) {
            ClickLeftArrow()
        }
        Sleep, 500
        currentZone := DetectCurrentZone()
        attempts++
        if (attempts > 20) {
            DebugLog("EnsureCorrectZoneSelected: Failed to select " . targetZone . " after 20 attempts.")
            return false
        }
    }
    DebugLog("EnsureCorrectZoneSelected: Desired zone selected: " . targetZone)
    return true
}


;===========================================
; DetectCurrentZone Function
;===========================================
DetectCurrentZone() {
    zone1Pattern := "|<>*147$489.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000zzy00zzzzzzU0Dzzzzzzy000007z00Tzw01zzzs00000Tzy00zw0000007zzzzzzzzzs03zzU0Dzz00007zzk07zzzzzw01zzzzzzzk00000zs03zzU0Dzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000zzy00zzzzzzU0Dzzzzzzy000007z00Tzw01zzzs00000Tzy00zw0000007zzzzzzzzzs03zzU0Dzz00007zzk07zzzzzw01zzzzzzzk00000zs03zzU0Dzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000zzy00zzzzzzU0Dzzzzzzy000007z00Tzw01zzzs00000Tzy00zw0000007zzzzzzzzzs03zzU0Dzz00007zzk07zzzzzw01zzzzzzzk00000zs03zzU0Dzzz000003zzk07zU000000zzzzzzzzzz00Tzw01zzs0000Tzy00zzzzzzU0Dzzzzzzw000007z00Tzw01zzzs000000Dy00zw0000007zzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU000000zs03zzU0Dzzz0000001zk07zU000000zzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000007z00Tzw01zzzs000000Dy00zw0000007zzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU000000zs03zzU0Dzzz0000001zk07zU000000zzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000007z00Tzw01zzzs000000Dy00zw0000007zzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU000000zs03zzU0Dzzz00Tzs01zk07zzzk03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzs03zzU0Dzzz00Tzw01zk07zzzs03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzs03zzU0Dzzz00Tzw01zk07zzzs03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzs03zzU0Dzzz00Tzw01zk07zzzs03zzzzzzzzzzzz00Tzw01zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzz00Tzw01zzzs01zz0Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00Tzk03zk07zzzzzw01zzzzzzU07zzzzzs01zz00Dzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000Tzzz0000001zzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzs000000Dzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000Tzzz0000001zzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzs000000Dzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000Tzzz0000001zzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzzw0000Tzzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000TzzzzU0003zzzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzzw0000Tzzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000TzzzzU0003zzzzs00000Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy0000003zk07zzzzzw01zzzzzzU0003zzzzw0000Tzzzz000003zzk07zzzs03zzzzzzzzzzzz00Tzw01zk000000Ty00zzzzzzU0Dzzzzzw0000TzzzzU0003zzzzs03zz0Tzy00zzzz00Tzzzzzzzzzzzs03zzU0Dy00Tzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00Tzzzzz00Tzw01zk07zzzs03zzzzzzzzzzzz0000001zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzzzzk07zzzzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs000000Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00zzzzzz00Tzw01zk07zzzs03zzzzzzzzzzzz0000001zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzzzzk07zzzzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs000000Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00zzzzzz00Tzw01zk07zzzs03zzzzzzzzzzzz0000001zk07zz00Ty00zzzzzzU0Dzzzzzw01zzzzzzzzk07zzzzzs03zzU0Dy00zzzz00Tzzzzzzzzzzzs000000Dy00zzs03zk07zzzzzw01zzzzzzU0Dzzzzzzzy00zzzzzz00Tzs01zk07zzzs03zzzzzzzzzzzzzU0003zzk07zz00Ty00zzzzzzU07zzzzzw01zzzzzzzzk07zzzzzs000000Dy00zzzz00Tzzzzzzzzzzzzw0000Tzy00zzs03zk000000Tw0000007zU000000zzzy00zzzzzz0000001zk07zzzs03zzzzzzzzzzzzzU0003zzk07zz00Ty0000003zU000000zw0000007zzzk07zzzzzs000000Dy00zzzz00Tzzzzzzzzzzzzw0000Tzy00zzs03zk000000Tw0000007zU000000zzzy00zzzzzz0000001zk07zzzs03zzzzzzzzzzzzzU0003zzk07zz00Ty0000003zU000000zw0000007zzzk07zzzzzs000000Dy00zzzz00Tzzzzzzzzzzzzw0000Tzy00zzs03zk000000Tw0000007zU000000zzzy00zzzzzz000003zzk07zzzs03zzzzzzzzzzzzzzU07zzzk07zz00Tzy000003zzk00000zzw000007zzzk07zzzzzs00000Tzy00zzzz00Tzzzzzzzzzzzzzy00zzzy00zzs03zzs00000Tzy000007zzk00000zzzy00zzzzzz000003zzk07zzzs03zzzzzzzzzzzzzzk07zzzk07zz00Tzz000003zzk00000zzy000007zzzk07zzzzzs00000Tzy00zzzz00Tzzzzzzzzzzzzzy00zzzy00zzs03zzs00000Tzy000007zzk00000zzzy00zzzzzz000003zzk07zzzs03zzzzzzzzzzzzzzk07zzzk07zz00Tzz000003zzk00000zzy000007zzzk07zzzzzs00000Tzy00zzzz00Tzzzzzzzzzzzzzy00zzzy00zzs03zzs00000Tzy000007zzk00000zzzy00zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone2Pattern := "|<>*142$545.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz00Tzzy00zs03zzs0000zzw0000007zzk00000zzw0000TzzzU000000zzzz00007zzzk0001zzzy000007z00Tzw01y00zzzw01zk07zzk0001zzs0000007zzU00001zzs0000zzzz0000001zzzy0000DzzzU0003zzzw00000Dy00zzs03w01zzzs03zU0DzzU0003zzk000000Dzz000003zzk0001zzzy0000003zzzw0000Tzzz00007zzzs00000Tw01zzk07s03zzzk07z00Tzz00007zzU000000Tzy000007zzU0003zzzw0000007zzzs0000zzzy0000Dzzzk00000zs03zzU0Dk07zzzU0Dy00zzy0000Dzz0000000zzw00000Dzz00007zzzs000000Dzzzk0001zzzw0000TzzzU00001zk07zz00TU0Dzzz00Tw01zzw0000Tzy0000001zzs00000Tzy0000Dzzzk000000TzzzU0003zzzs0000zzzz000003zU0Dzy00z00Tzzy00zs03zzk0000zzw0000003zzU00000zzw0000Dzzz0000000Tzzy00007zzzU0000zzzw000007z00Tzw01y00zzzw01zk07zU000000zs0000007z0000001zk000000Ty000000000zs0000007z0000001zs000000Dy00zzs03w01zzzs03zU0Dz0000001zk000000Dy0000003zU000000zw000000001zk000000Dy0000003zk000000Tw01zzk07s03zzzk07z00Ty0000003zU000000Tw0000007z0000001zs000000003zU000000Tw0000007zU000000zs03zzU0Dk07zzzU0Dy00zw0000007z0000000zs000000Dy0000003zk000000007z0000000zs000000Dz0000001zk07zz00TU0Dzzz00Tw01zs000000Dy0000003zk000000Tw0000007zU00000000Dy0000001zk000000Ty0000003zU0Dzy00z00Tzzy00zs03zk07zz00Tzzz00DzzzU0Dzzzzzs01zzU0Dz00Ts03z00Tw00zzk03zU0Dzy00zw01zzzzzz00Tzw01y00zzzw01zk07zU0Dzy00zzzy00zzzz00Tzzzzzk07zz00Ty00zk07y00zs03zzk07z00Tzw01zs07zzzzzy00zzs03w01zzzs03zU0Dz00Tzw01zzzw01zzzy00zzzzzzU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03zk0Dzzzzzw01zzk07s03zzzk07z00Ty00zzs03zzzs03zzzw01zzzzzz00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07zU0Tzzzzzs03zzU0Dk07zzzU0Dy00zw01zzk07zzzk07zzzs03zzzzzy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dz00zzzzzzk07zz00TU0Dzzz00Tw01zs03zzU0DzzzU0Dzzzk07zzzzzw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ty01zzzzzzU0Dzy00z00Tzzy00zs03zk07zz00Tzzz00TzzzU0Dzzzzzs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zw03zzzzzz00Tzw01y00zzzw01zk07zU0Dzy00zzzy00zzzz00Dzzzzzk03zy00Ty00zk07y00zs00zzU07z00Dzs01zs01zzzzzy00Tzk03w01zUTs03zU0Dz00Tzw01zzzw01zzzy0000DzzzU000000zw01zU0Dw01zk000000Dy0000003zk00000zzw0000007s03z0zk07z00Ty00zzs03zzzs03zzzw0000Tzzz0000001zs03z00Ts03zU000000Tw0000007zU00001zzs000000Dk07y1zU0Dy00zw01zzk07zzzk07zzzs0000zzzy0000003zk07y00zk07z0000000zs000000Dz000003zzk000000TU0Dw3z00Tw01zs03zzU0DzzzU0Dzzzk0001zzzw0000007zU0Dw01zU0Dy0000001zk000000Ty000007zzU000000z00Ts7y00zs03zk07zz00Tzzz00TzzzU0003zzzs000000Dz00Ts03z00Tw0000003zU000000zw00000Dzz0000001y00zkDw01zk07zU0Dzy00zzzy00zzzz00007zzzk00000Tzy00zk07y00zs0000007z000003zzzs0000Tzy0000003w00000003zU0Dz00Tzw01zzzw01zzzy0000DzzzU00001zzw01zU0Dw01zk000000Dy000007zzzs00000Tw0000007s00000007z00Ty00zzs03zzzs03zzzw0000Tzzz000003zzs03z00Ts03zU000000Tw00000Dzzzk00000zs000000Dk0000000Dy00zw01zzk07zzzk07zzzs0000zzzy000007zzk07y00zk07z0000000zs00000TzzzU00001zk000000TU0000000Tw01zs03zzU0DzzzU0Dzzzk0001zzzw00000DzzU0Dw01zU0Dy0000001zk00000zzzz000003zU000000z00000000zs03zk07zz00Tzzz00TzzzU0003zzzs00000Tzz00Ts03z00Tw0000003zU00001zzzy000007z0000001y00000001zk07zU0Dzy00zzzy00zzzz00Dzzzzzk03y00Tzy00zk07y00zs01zzU07z00Dk03zzzzzzz00Dy00Tzk03w00000003zU0Dz00Tzw01zzzw01zzzy00zzzzzzU0Dw000zw01zU0Dw01zk07zzU0Dy00zk003zzzzzz00Tw01zzk07s00000007z00Ty00zzs03zzzs03zzzw01zzzzzz00Ts001zs03z00Ts03zU0Dzz00Tw01zU007zzzzzy00zs03zzU0Dk0000000Dy00zw01zzk07zzzk07zzzs03zzzzzy00zk003zk07y00zk07z00Tzy00zs03z000Dzzzzzw01zk07zz00TU0000000Tw01zs03zzU0DzzzU0Dzzzk07zzzzzw01zU007zU0Dw01zU0Dy00zzw01zk07y000Tzzzzzs03zU0Dzy00z00000000zs03zk07zz00Tzzz00TzzzU0Dzzzzzs03z000Dz00Ts03z00Tw01zzs03zU0Dw000zzzzzzk07z00Tzw01y00000001zk07zU0Dzy00zzzy00zzzz00Tzzzzzk07y000Ty00zk07y00zs03zzk07z00Ts001zzzzzzU0Dy00zzs03w000zk003zU0Dz00Tzw01zzzw01zzzy00zzzzzzU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03zzzzzy00Tw01zzk07s001zU007z00Ty00zzs03zzzs03zzzw0000007z00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07zU000000zs03zzU0Dk003z000Dy00zw01zzk07zzzk07zzzs000000Dy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dz0000001zk07zz00TU007y000Tw01zs03zzU0DzzzU0Dzzzk000000Tw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ty0000003zU0Dzy00z000Dw000zs03zk07zz00Tzzz00TzzzU000000zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zw0000007z00Tzw01y000Ts001zk07zU0Dzy00zzzy00zzzz0000001zk07zz00Ty00zk07y00zs03zzk07z00Tzw01zs000000Dy00zzs03w01zzzs03zU0Dz00Tzw01zzzw01zzzzz000003zU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03zk00000zzw01zzk07s03zzzk07z00Ty00zzs03zzzs03zzzzy000007z00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07zU00001zzs03zzU0Dk07zzzU0Dy00zw01zzk07zzzk07zzzzw00000Dy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dz000003zzk07zz00TU0Dzzz00Tw01zs03zzU0DzzzU0Dzzzzs00000Tw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ty000007zzU0Dzy00z00Tzzy00zs03zk07zz00Tzzz00Tzzzzk00000zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zw00000Dzz00Tzw01y00zzzw01zk07zU0Dzy00zzzy00zzzzzU00001zk07zz00Ty00zk07y00zs03zzk07z00Tzw01zs00000Tzy00zzs03w01zzzs03zU0Dz00Tzw01zzzw01zzzzz000003zU0Dzz00zw01zU0Dw01zs07zzU0Dy00zzs03zk00000zzw01zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone3Pattern := "|<>*142$467.zy00zzzzzzzk0001zzw01zzk07zzU00000zs03zzU0Dzz00003zzk07zz00Tzz000003zzk0001zzzzw01zzzzzzzU0003zzs03zzU0Dzz000001zk07zz00Tzy00007zzU0Dzy00zzy000007zzU0003zzzzs03zzzzzzz00007zzk07zz00Tzy000003zU0Dzy00zzw0000Dzz00Tzw01zzw00000Dzz00007zzzzk07zzzzzzy0000DzzU0Dzy00zzw000007z00Tzw01zzs0000Tzy00zzs03zzs00000Tzy0000DzzzzU0Dzzzzzzw0000Tzz00Tzw01zzs00000Dy00zzs03zzk0000zzw01zzk07zzk00000zzw0000Tzzzz00Tzzzzzzs0000zzy00zzs03zzk00000Tw01zzk07zzU0001zzs03zzU0DzzU00001zzs0000zzzzy00zzzzzzzk0000zzw01zzU07zzU00000zs03zzU0Dzz00003zzk07zz00Tzy000003zzk0000zzzzw01zzzzzz0000001zs03z000Dy0000001zk07zz00Tw0000003zU0Dzy00zw0000007z0000001zzzs03zzzzzy0000003zk07y000Tw0000003zU0Dzy00zs0000007z00Tzw01zs000000Dy0000003zzzk07zzzzzw0000007zU0Dw000zs0000007z00Tzw01zk000000Dy00zzs03zk000000Tw0000007zzzU0Dzzzzzs000000Dz00Ts001zk000000Dy00zzs03zU000000Tw01zzk07zU000000zs000000Dzzz00Tzzzzzk000000Ty00zk003zU000000Tw01zzk07z0000000zs03zzU0Dz0000001zk000000Tzzy00zzzzzzU07zy00zw01zU0Dzz00Dzzzzzs03zzU0Dy00Tzs01zk07zz00Ty00zzzzzzU0Dzy00zzzw01zzzzzz00Tzw01zs00000Tzy00zzzzzzk07zz00Tw01zzs03zU0Dzy00zw03zzzzzz00Tzw01zzzs03zzzzzy00zzs03zk00000zzw01zzzzzzU0Dzy00zs03zzk07z00Tzw01zs07zzzzzy00zzs03zzzk07zzzzzw01zzk07zU00001zzs03zzzzzz00Tzw01zk07zzU0Dy00zzs03zk0Dzzzzzw01zzk07zzzU0Dzzzzzs03zzU0Dz000003zzk07zzzzzy00zzs03zU0Dzz00Tw01zzk07zU0Tzzzzzs03zzU0Dzzz00Tzzzzzk07zz00Ty000007zzU0Dzzzzzw01zzk07z00Tzy00zs03zzU0Dz00zzzzzzk07zz00Tzzy00zzzzzzU0Dzy00zw00000Dzz00Tzzzzzs03zzU0Dy00zzw01zk07zz00Ty01zzzzzzU0Dzy00zzzw01zzzzzz00Dzs01zs0000zzzy00Tzzzzzk03zy00Tw00Tzk03zU0Dzy00zw00zzzzzz00Tzw01zzzs03zzzzzy0000003zk0001zzzw0000DzzzU000000zs0000007z00Tzw01zs0000zzzy00zzs03zzzk07zzzzzw0000007zU0003zzzs0000Tzzz0000001zk000000Dy00zzs03zk0001zzzw01zzk07zzzU0Dzzzzzs000000Dz00007zzzk0000zzzy0000003zU000000Tw01zzk07zU0003zzzs03zzU0Dzzz00Tzzzzzk000000Ty0000DzzzU0001zzzw0000007z0000000zs03zzU0Dz00007zzzk07zz00Tzzy00zzzzzzU000000zw0000Tzzz00003zzzs000000Dy0000001zk07zz00Ty0000DzzzU0Dzy00zzzw01zzzzzz0000001zs0000zzzy00007zzzk000000Tw0000003zU0Dzy00zw0000Tzzz00Tzw01zzzs03zzzzzy0000003zk0001zzzw0000DzzzU000000zs0000007z00Ts001zs0000zzzy00zzs03zzzk07zzzzzw0000007zU0003zzzs0000Tzzz0000001zk000000Dy00zk003zk0001zzzw01zzk07zzzU0Dzzzzzs000000Dz00007zzzk0000zzzy0000003zU000000Tw01zU007zU0003zzzs03zzU0Dzzz00Tzzzzzk000000Ty0000DzzzU0001zzzw0000007z0000000zs03z000Dz00007zzzk07zz00Tzzy00zzzzzzU000000zw0000Tzzz00003zzzs000000Dy0000001zk07y000Ty0000DzzzU0Dzy00zzzw01zzzzzz00Dzw01zs0000zzzy00Tzzzzzk03zy00Tw00zzk03zU0Dw00zzw01zzzzzz00Tzw01zzzs03zzzzzy00zzs03zk00000zzw01zzzzzzU0Dzy00zs03zzk07z000003zzs07zzzzzy00zzs03zzzk07zzzzzw01zzk07zU00001zzs03zzzzzz00Tzw01zk07zzU0Dy000007zzk0Dzzzzzw01zzk07zzzU0Dzzzzzs03zzU0Dz000003zzk07zzzzzy00zzs03zU0Dzz00Tw00000DzzU0Tzzzzzs03zzU0Dzzz00Tzzzzzk07zz00Ty000007zzU0Dzzzzzw01zzk07z00Tzy00zs00000Tzz00zzzzzzk07zz00Tzzy00zzzzzzU0Dzy00zw00000Dzz00Tzzzzzs03zzU0Dy00zzw01zk00000zzy01zzzzzzU0Dzy00zzzw01zzzzzz00Tzw01zs00000Tzy00zzzzzzk07zz00Tw01zzs03zU00001zzw03zzzzzz00Tzw01zzzs03zzzzzy00zzs03zk07y00Tzw00zzzzzzU0Dzy00zs03zzk07z00007zzzs03zzzzzy00zzs03zzzk000000Tw01zzk07zU0Dw000zs0000007z00Tzw01zk07zzU0Dy0000Dzzzk000000Tw01zzk07zzzU000000zs03zzU0Dz00Ts001zk000000Dy00zzs03zU0Dzz00Tw0000TzzzU000000zs03zzU0Dzzz0000001zk07zz00Ty00zk003zU000000Tw01zzk07z00Tzy00zs0000zzzz0000001zk07zz00Tzzy0000003zU0Dzy00zw01zU007z0000000zs03zzU0Dy00zzw01zk0001zzzy0000003zU0Dzy00zzzw0000007z00Tzw01zs03z000Dy0000001zk07zz00Tw01zzs03zU0003zzzw0000007z00Tzw01zzzzw00000Dy00zzs03zk07zz00Tzy000003zU0Dzy00zs03zzk07z000Dzzzzzs00000Dy00zzs03zzzzs00000Tw01zzk07zU0Dzy00zzw000007z00Tzw01zk07zzU0Dy000Tzzzzzs00000Tw01zzk07zzzzk00000zs03zzU0Dz00Tzw01zzs00000Dy00zzs03zU0Dzz00Tw000zzzzzzk00000zs03zzU0DzzzzU00001zk07zz00Ty00zzs03zzk00000Tw01zzk07z00Tzy00zs001zzzzzzU00001zk07zz00Tzzzz000003zU0Dzy00zw01zzk07zzU00000zs03zzU0Dy00zzw01zk003zzzzzz000003zU0Dzy00zzzzy000007z00Tzw01zs03zzU0Dzz000001zk07zz00Tw01zzs03zU007zzzzzy000007z00Tzw01zzzzw00000Dy00zzw03zk07zz00Tzz000007zU0Dzy00zw03zzk0Dz000Dzzzzzw00000Dy00zzs03zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone4Pattern := "|<>*142$363.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy0000Dzzzk00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzs00000Tzzzk0001zzzy000007z00Tzy00zs03zzU0Dzz00003zzk07zzzzzzz000003zzzy0000Dzzzk00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzs00000Tzzzk0001zzzy000007z00Tzy00zs03zzU0Dzz00003zzk07zzzzzzz000003zzzy0000Dzzzk00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzs00000Tzzzk0001zzzy000007z00Tzy00zs03zzU0Dzz00003zzk07zzzzzzz000003zzzy00007zzzU00000zs03zzk07z00Tzw01zzs0000Tzy00zzzzzzzk00000TzzU000000zw0000007z00Tzy00zs03zzU0Dy0000001zk07zzzzzy0000003zzw0000007zU000000zs03zzk07z00Tzw01zk000000Dy00zzzzzzk000000TzzU000000zw0000007z00Tzy00zs03zzU0Dy0000001zk07zzzzzy0000003zzw0000007zU000000zs03zzk07z00Tzw01zk000000Dy00zzzzzzk000000TzzU000000zw0000007z00Tzy00zs03zzU0Dy0000001zk07zzzzzy0000003zzw00zzk07zU0Dzzzzzs03zzk07z00Tzw01zk03zz00Dy00zzzzzzk07zzzzzzzU0Dzy00zw01zzzzzz00Tzy00zs03zzU0Dy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zU0Dzzzzzs03zzk07z00Tzw01zk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zw01zzzzzz00Tzy00zs03zzU0Dy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zU0Dzzzzzs03zzk07z00Tzw01zk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zw01zzzzzz00Tzy00zs03zzU0Dy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zU0Dzzzzzs03zzk07z00Tzw01zk07zzU0Dy00zzzzzzk0DzzzzzzzU07zw00zw00zzzzzz00Dzs00zs03zzU0Dy00Dzs01zk07zzzzzy00Tzzzzzzw0000007zU00001zzs0000007z00Tzw01zk000000Dy00zzzzzzk0001zzzzzU000000zw00000Dzz0000000zs03zzU0Dy0000001zk07zzzzzy0000Dzzzzw0000007zU00001zzs0000007z00Tzw01zk000000Dy00zzzzzzk0001zzzzzU000000zw00000Dzz0000000zs03zzU0Dy0000001zk07zzzzzy0000Dzzzzw0000007zU00001zzs0000007z00Tzw01zk000000Dy00zzzzzzk0001zzzzzU000000zzy0000Dzz0000000zs03zzU0Dy0000001zk07zzzzzy0000Dzzzzw0000007zzk00000zs0000007z00Ts001zk000000Dy00zzzzzzk0001zzzzzU000000zzy000007z0000000zs03z000Dy0000001zk07zzzzzy0000Dzzzzw0000007zzk00000zs0000007z00Ts001zk000000Dy00zzzzzzk0001zzzzzU000000zzy000007z0000000zs03z000Dy0000001zk07zzzzzy0000Dzzzzw0000007zzk00000zs0000007z00Ts001zk000000Dy00zzzzzzk0001zzzzzU07zy00zzzzzzU07z00Dzw00zs03z00Dzy00Tzs01zk07zzzzzy00zzzzzzzw01zzk07zzzzzy00zs03zzk07z000003zzk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zzzzzzk07z00Tzy00zs00000Tzy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zzzzzy00zs03zzk07z000003zzk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zzzzzzk07z00Tzy00zs00000Tzy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zzzzzy00zs03zzk07z000003zzk07zzU0Dy00zzzzzzk0DzzzzzzzU0Dzy00zzzzzzk07z00Tzy00zs00000Tzy00zzw01zk07zzzzzy01zzzzzzzw01zzk07zzzzzw00zs03zzk07z00007zzzk07zzU0Dy00Tzzzzzk07zzzzzzzU0Dzy00zw0000007z00Tzy00zs0000zzzy00zzw01zk000000Ty0000003zzw01zzk07zU000000zs03zzk07z00007zzzk07zzU0Dy0000003zk000000TzzU0Dzy00zw0000007z00Tzy00zs0000zzzy00zzw01zk000000Ty0000003zzw01zzk07zU000000zs03zzk07z00007zzzk07zzU0Dy0000003zk000000TzzU0Dzy00zw0000007z00Tzy00zs0000zzzy00zzw01zk000000Ty0000003zzw01zzk07zU00001zzs03zzk07z000Dzzzzk07zzU0Dzz000003zzk00000TzzU0Dzy00zw00000Dzz00Tzy00zs001zzzzy00zzw01zzs00000Tzz000003zzw01zzk07zU00001zzs03zzk07z000Dzzzzk07zzU0Dzz000003zzs00000TzzU0Dzy00zw00000Dzz00Tzy00zs001zzzzy00zzw01zzs00000Tzz000003zzw01zzk07zU00001zzs03zzk07z000Dzzzzk07zzU0Dzz000003zzs00000TzzU0Dzy00zw00000Dzz00Tzy00zs001zzzzy00zzw01zzs00000Tzz000003zzw01zzs07zU00001zzs03zzk0Dz000Dzzzzs07zzU0Tzz000003zzs00000Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    zone5Pattern := "|<>*143$373.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU0003zzzw0000Tzzz00007zzzs000000Dzzzk0001zzzw0000TzzzU00001zzzk0001zzzy0000DzzzU0003zzzw0000007zzzs0000zzzy0000Dzzzk00000zzzs0000zzzz00007zzzk0001zzzy0000003zzzw0000Tzzz00007zzzs00000Tzzw0000TzzzU0003zzzs0000zzzz0000001zzzy0000DzzzU0003zzzw00000Dzzy0000Dzzzk0001zzzw0000TzzzU000000zzzz00007zzzk0001zzzy000007zzz00007zzzs0000zzzy0000Dzzzk000000TzzzU0003zzzs0000zzzz000003zzzU0001zzzs0000Tzzz00003zzzk0000007zzzU0001zzzw0000Dzzz000001zzU000000zw0000007z0000001zs000000003zk000000Tw0000007zU000000zzk000000Ty0000003zU000000zw000000001zs000000Dy0000003zk000000Tzs000000Dz0000001zk000000Ty000000000zw0000007z0000001zs000000Dzw0000007zU000000zs000000Dz000000000Ty0000003zU000000zw0000007zy0000003zk000000Tw0000007zU00000000Dz0000001zk000000Ty0000003zz00Dzw01zs03zzU0Dy00Tzs03zk07y00zk07zU0Dzw00zs03zzU0Dz00TzzzzzzU0Dzy00zw01zzk07z00Tzy01zs03z00Ts03zk0Dzz00Tw01zzk07zU0Dzzzzzzk07zz00Ty00zzs03zU0Dzz00zw01zU0Dw01zs07zzU0Dy00zzs03zk07zzzzzzs03zzU0Dz00Tzw01zk07zzU0Ty00zk07y00zw03zzk07z00Tzw01zs03zzzzzzw01zzk07zU0Dzy00zs03zzk0Dz00Ts03z00Ty01zzs03zU0Dzy00zw01zzzzzzy00zzs03zk07zz00Tw01zzs07zU0Dw01zU0Dz00zzw01zk07zz00Ty00zzzzzzz00Tzw01zs03zzU0Dy00zzw03zk07y00zk07zU0Tzy00zs03zzU0Dz00TzzzzzzU07zw00zw00zzU07z00Dzs01zs03z00Ts03zk0Dzz00Tw00zzU07zU07zzzzzzk000000Ty0000003zU000000zw01zU0Dw01zs07zzU0Dy0000003zk0001zzzzs000000Dz0000001zk000000Ty00zk07y00zw03zzk07z0000001zs0000zzzzw0000007zU000000zs000000Dz00Ts03z00Ty01zzs03zU000000zw0000Tzzzy0000003zk000000Tw0000007zU0Dw01zU0Dz00zzw01zk000000Ty0000Dzzzz0000001zs000000Dy0000003zk07y00zk07zU0Tzy00zs000000Dz00007zzzzU000000zw00000Dzz0000001zs03z00Ts03zk0Dzz00Tw00000DzzU0003zzzzk000000Ty000007zzU000000zw01zU0Dw01zs07zzU0Dy000007zzk0001zzzzs000000Dz000003zzk000000Ty00zk07y00zw03zzk07z000003zzs0000zzzzw0000007zU00001zzs000000Dz00Ts03z00Ty01zzs03zU00001zzw0000Tzzzy0000003zk00000zzw0000007zU0Dw01zU0Dz00zzw01zk00000zzy0000Dzzzz0000001zs00000Tzy0000003zk07y00zk07zU0Tzy00zs00000Tzz00007zzzzU07zy00zw00z00Dzz00Dzw01zs03z00Ts03zk0Dzz00Tw00z00DzzU0Dzzzzzzk07zz00Ty00zk003zU0Dzz00zw01zU0Dw01zs07zzU0Dy00zk003zk07zzzzzzs03zzU0Dz00Ts001zk07zzU0Ty00zk07y00zw03zzk07z00Ts001zs03zzzzzzw01zzk07zU0Dw000zs03zzk0Dz00Ts03z00Ty01zzs03zU0Dw000zw01zzzzzzy00zzs03zk07y000Tw01zzs07zU0Dw01zU0Dz00zzw01zk07y000Ty00zzzzzzz00Tzw01zs03z000Dy00zzw03zk07y00zk07zU0Tzy00zs03z000Dz00TzzzzzzU0Dzy00zw01zU007z00Tzy01zs03z00Ts03zk0Dzz00Tw01zU007zU0Dzzzzzzk07zz00Ty00zzs03zU0Dzz00zw01zU0Dw01zs03zz00Dy00zzs03zk07zzzzzzs03zzU0Dz00Tzw01zk07zzU0Ty00zk07y00zw0000007z00Tzw01zs000000Dzw01zzk07zU0Dzy00zs03zzk0Dz00Ts03z00Ty0000003zU0Dzy00zw0000007zy00zzs03zk07zz00Tw01zzs07zU0Dw01zU0Dz0000001zk07zz00Ty0000003zz00Tzw01zs03zzU0Dy00zzw03zk07y00zk07zU000000zs03zzU0Dz0000001zzU0Dzy00zw01zzk07z00Tzy01zs03z00Ts03zk000000Tw01zzk07zU000000zzk07zz00Ty00zzs03zU0Dzz00zw01zU0Dw01zzs0000Tzy00zzs03zzk00000Tzs03zzU0Dz00Tzw01zk07zzU0Ty00zk07y00zzy0000Dzz00Tzw01zzw00000Dzw01zzk07zU0Dzy00zs03zzk0Dz00Ts03z00Tzz00007zzU0Dzy00zzy000007zy00zzs03zk07zz00Tw01zzs07zU0Dw01zU0DzzU0003zzk07zz00Tzz000003zz00Tzw01zs03zzU0Dy00zzw03zk07y00zk07zzk0001zzs03zzU0DzzU00001z"
    zone6Pattern := "|<>*142$461.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zzzU0DzzU0003zzzs0000zzzz000003zzk0000zzzy0000Dzzzk0001zzs000000Dz00Tzw01zU0Dzzz00Tzz00007zzzk0001zzzy000007zzU0001zzzw0000TzzzU0003zzk000000Ty00zzs03z00Tzzy00zzy0000DzzzU0003zzzw00000Dzz00003zzzs0000zzzz00007zzU000000zw01zzk07y00zzzw01zzw0000Tzzz00007zzzs00000Tzy00007zzzk0001zzzy0000Dzz0000001zs03zzU0Dw01zzzs03zzs0000zzzy0000Dzzzk00000zzw0000DzzzU0003zzzw0000Tzy0000003zk07zz00Ts03zzzk07zzk0001zzzw0000TzzzU00001zzs0000Tzzz00007zzzs0000zzw0000007zU0Dzy00zk03zzzU0Dzz00003zzzs0000Tzzy000003zzk0000zzzw00007zzzU0001zzs000000Dz00Tzw01zU007y000Ty0000003zU000000Tw0000007z0000000zs000000Dz0000001zk000000Ty00zzs03z000Dw000zw0000007z0000000zs000000Dy0000001zk000000Ty0000003zU000000zw01zzk07y000Ts001zs000000Dy0000001zk000000Tw0000003zU000000zw0000007z0000001zs03zzU0Dw000zk003zk000000Tw0000003zU000000zs0000007z0000001zs000000Dy0000003zk07zz00Ts001zU007zU000000zs0000007z0000001zk000000Dy0000003zk000000Tw0000007zU0Dzy00zk001z000Dz00Tzw01zk03zz00Dy00zzzzzzU07zy00Tw01zzk07zU0Dzw00zzzy00zzzz00Tzw01zU0000000Ty00zzs03zU0Dzz00Tw01zzzzzz00Tzy00zs03zzU0Dz00zzw01zzzw01zzzy00zzs03z00000000zw01zzk07z00Tzy00zs03zzzzzy00zzw01zk07zz00Ty01zzs03zzzs03zzzw01zzk07y00000001zs03zzU0Dy00zzw01zk07zzzzzw01zzs03zU0Dzy00zw03zzk07zzzk07zzzs03zzU0Dw00000003zk07zz00Tw01zzs03zU0Dzzzzzs03zzk07z00Tzw01zs07zzU0DzzzU0Dzzzk07zz00Ts00000007zU0Dzy00zs03zzk07z00Tzzzzzk07zzU0Dy00zzs03zk0Dzz00Tzzz00TzzzU0Dzy00zk0000000Dz00Tzw01zk07zzU0Dy00zzzzzzU0Dzz00Tw01zzk07zU0Tzy00zzzy00zzzz00Tzw01zU0000000Ty00zzs03zU07zw00Tw01zzzzzz00Tzy00zs01zz00Dz00zzw01zzzw01zzzy00Tzk03z00000000zw01zzk07z0000000zs03z000Dy00zzw01zk000000Ty01zzs03zzzs03zzzw0000007y00000001zs03zzU0Dy0000001zk07y000Tw01zzs03zU000000zw03zzk07zzzk07zzzs000000Dw00000003zk07zz00Tw0000003zU0Dw000zs03zzk07z0000001zs07zzU0DzzzU0Dzzzk000000Ts00000007zU0Dzy00zs0000007z00Ts001zk07zzU0Dy0000003zk0Dzz00Tzzz00TzzzU000000zk0000000Dz00Tzw01zk000000Dy00zk003zU0Dzz00Tw0000007zU0Tzy00zzzy00zzzz0000001zU07w1z00Ty00zzs03zU00000zzw01zU007z00Tzy00zs00000Tzz00zzw01zzzw01zzzy0000003z00Ts7y00zw01zzk07z000003zzs03z000Dy00zzw01zk00000zzy01zzs03zzzs03zzzw0000007y00zkDw01zs03zzU0Dy000007zzk07y000Tw01zzs03zU00001zzw03zzk07zzzk07zzzs000000Dw01zUTs03zk07zz00Tw00000DzzU0Dw000zs03zzk07z000003zzs07zzU0DzzzU0Dzzzk000000Ts03z0zk07zU0Dzy00zs00000Tzz00Ts001zk07zzU0Dy000007zzk0Dzz00Tzzz00TzzzU000000zk07y1zU0Dz00Tzw01zk00000zzy00zk003zU0Dzz00Tw00000DzzU0Tzy00zzzy00zzzz0000001zU0Dzzz00Ty00zzs03zU07w00zzw01zzU07z00Tzy00zs01y00Tzz00zzw01zzzw01zzzy00zzk03z00Tzzy00zw01zzk07z00Ts000zs03zzU0Dy00zzw01zk07y000Ty01zzs03zzzs03zzzw01zzk07y00zzzw01zs03zzU0Dy00zk001zk07zz00Tw01zzs03zU0Dw000zw03zzk07zzzk07zzzs03zzU0Dw01zzzs03zk07zz00Tw01zU003zU0Dzy00zs03zzk07z00Ts001zs07zzU0DzzzU0Dzzzk07zz00Ts03zzzk07zU0Dzy00zs03z0007z00Tzw01zk07zzU0Dy00zk003zk0Dzz00Tzzz00TzzzU0Dzy00zk07zzzU0Dz00Tzw01zk07y000Dy00zzs03zU0Dzz00Tw01zU007zU0Tzy00zzzy00zzzz00Tzw01zU0Dzzz00Ty00zzs03zU0Dw000Tw01zzk07z00Tzy00zs03z000Dz00zzw01zzzw01zzzy00zzs03z00Tzzy00zw00zzU07z00Tzw00zs01zz00Dy00Tzs01zk07zz00Ty00zzk03zzzs03zzzw01zzk07y00zzzw01zs000000Dy00zzw01zk000000Tw0000003zU0Dzy00zw0000007zzzk07zzzs03zzU0Dw01zzzs03zk000000Tw01zzs03zU000000zs0000007z00Tzw01zs000000DzzzU0Dzzzk07zz00Ts03zzzk07zU000000zs03zzk07z0000001zk000000Dy00zzs03zk000000Tzzz00TzzzU0Dzy00zk07zzzU0Dz0000001zk07zzU0Dy0000003zU000000Tw01zzk07zU000000zzzy00zzzz00Tzw01zU0Dzzz00Ty0000003zU0Dzz00Tw0000007z0000000zs03zzU0Dz0000001zzzw01zzzy00zzs03z00Tzzy00zzy0000Dzz00Tzy00zzw0000Tzzz00003zzk07zz00Tzy00007zzzzs03zzzw01zzk07y00zzzw01zzw0000Tzy00zzw01zzs0000zzzy00007zzU0Dzy00zzy0000Dzzzzk07zzzs03zzU0Dw01zzzs03zzs0000zzw01zzs03zzk0001zzzw0000Dzz00Tzw01zzw0000TzzzzU0Dzzzk07zz00Ts03zzzk07zzk0001zzs03zzk07zzU0003zzzs0000Tzy00zzs03zzs0000zzzzz00TzzzU0Dzy00zk07zzzU0DzzU0003zzk07zzU0Dzz00007zzzk0000zzw01zzk07zzk0001zzzzy00zzzz00Tzw01zU0Dzzz00Tzz00007zzU0Dzz00Tzy0000DzzzU0001zzs03zzU0DzzU0003zzzzw01zzzy00zzs03z00Tzzz00zzy0000Dzz00Tzy01zzw0000TzzzU0007zzk07zz00Tzz0000Dzzzzs03zzzw03zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    zone7Pattern := "|<>*144$373.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw00000DzzU0003zzzs000000DzzU00001zzzy0000DzzzU0003zzzw0000Tzzzy000003zzk0001zzzw0000007zzk00000zzzz00007zzzk0001zzzy0000Dzzzz000001zzs0000zzzy0000003zzs00000TzzzU0003zzzs0000zzzz00007zzzzU00000zzw0000Tzzz0000001zzw00000Dzzzk0001zzzw0000TzzzU0003zzzzk00000Tzy0000DzzzU000000zzy000007zzzs0000zzzy0000Dzzzk0001zzzzs00000Dzz00007zzzk000000Tzz000003zzzw0000Tzzz00007zzzs0000zzzzw000007zz00003zzzs0000007zzU00000zzzw0000DzzzU0001zzzs0000Tzzw0000003zU000000zs000000001zk000000Ty0000003zU000000zw0000007zy0000001zk000000Tw000000000zs000000Dz0000001zk000000Ty0000003zz0000000zs000000Dy000000000Tw0000007zU000000zs000000Dz0000001zzU000000Tw0000007z000000000Dy0000003zk000000Tw0000007zU000000zzk000000Dy0000003zU000000007z0000001zs000000Dy0000003zk000000Tzs01zzzzzz00Tzw01zk03y00Tk03zU0Dzy00zw01zzU07z00Tzw01zs03zz00Dzw01zzzzzzU0Dzy00zs03z00Tw01zk07zz00Ty01zzs03zU0Dzy00zw03zzk07zy00zzzzzzk07zz00Tw01zU0Dy00zs03zzU0Dz00zzw01zk07zz00Ty01zzs03zz00Tzzzzzs03zzU0Dy00zk07z00Tw01zzk07zU0Tzy00zs03zzU0Dz00zzw01zzU0Dzzzzzw01zzk07z00Ts03zU0Dy00zzs03zk0Dzz00Tw01zzk07zU0Tzy00zzk07zzzzzy00zzs03zU0Dw01zk07z00Tzw01zs07zzU0Dy00zzs03zk0Dzz00Tzs03zzzzzz00Tzw01zk07y00zs03zU0Dzy00zw03zzk07z00Tzw01zs07zzU0Dzw01zzzzzzU07zw00zs03z00Tw01zk03zy00Ty01zzs03zU07zw00zw00zzU07zy00zzzzzzk000000Tw01zU0Dy00zs000000Dz00zzw01zk000000Ty0000003zz00Tzzzzzs000000Dy00zk07z00Tw0000007zU0Tzy00zs000000Dz0000001zzU0Dzzzzzw0000007z00Ts03zU0Dy0000003zk0Dzz00Tw0000007zU000000zzk07zzzzzy0000003zU0Dw01zk07z0000001zs07zzU0Dy0000003zk000000Tzs03zzzzzz0000001zk07y00zs03zU000000zw03zzk07z0000001zs000000Dzw01zzzzzzU000000zs03z00Tw01zk000000Ty01zzs03zU00001zzw0000007zy00zzzzzzk000000Tw01zU0Dy00zs000000Dz00zzw01zk00000zzy0000003zz00Tzzzzzs000000Dy00zk07z00Tw0000007zU0Tzy00zs00000Tzz0000001zzU0Dzzzzzw0000007z00Ts03zU0Dy0000003zk0Dzz00Tw00000DzzU000000zzk07zzzzzy0000003zU0Dw01zk07z0000001zs07zzU0Dy000007zzk000000Tzs03zzzzzz0000001zk07y00zs03zU000000zw03zzk07z000003zzs000000Dzw01zzzzzzU07zw00zs03z00Tw01zk03zy00Ty01zzs03zU07s01zzw01zzU07zy00zzzzzzk07zz00Tw01zU0Dy00zs03zzU0Dz00zzw01zk07y000Ty01zzs03zz00Tzzzzzs03zzU0Dy00zk07z00Tw01zzk07zU0Tzy00zs03z000Dz00zzw01zzU0Dzzzzzw01zzk07z00Ts03zU0Dy00zzs03zk0Dzz00Tw01zU007zU0Tzy00zzk07zzzzzy00zzs03zU0Dw01zk07z00Tzw01zs07zzU0Dy00zk003zk0Dzz00Tzs03zzzzzz00Tzw01zk07y00zs03zU0Dzy00zw03zzk07z00Ts001zs07zzU0Dzw01zzzzzzU0Dzy00zs03z00Tw01zk07zz00Ty01zzs03zU0Dw000zw03zzk07zy00Tzzzzzk07zz00Tw01zU0Dy00zs01zz00Dz00Tzs01zk07zz00Ty01zzs03zz0000000zs03zzU0Dy00zk07z00Tw0000007zU000000zs03zzU0Dz00zzw01zzU000000Tw01zzk07z00Ts03zU0Dy0000003zk000000Tw01zzk07zU0Tzy00zzk000000Dy00zzs03zU0Dw01zk07z0000001zs000000Dy00zzs03zk0Dzz00Tzs0000007z00Tzw01zk07y00zs03zU000000zw0000007z00Tzw01zs07zzU0Dzw0000003zU0Dzy00zs03z00Tw01zk000000Ty0000003zU0Dzy00zw03zzk07zzz000001zk07zz00Tw01zU0Dy00zs00000Tzzz00003zzk07zz00Ty01zzs03zzzU00000zs03zzU0Dy00zk07z00Tw00000Dzzzk0001zzs03zzU0Dz00zzw01zzzk00000Tw01zzk07z00Ts03zU0Dy000007zzzs0000zzw01zzk07zU0Tzy00zzzs00000Dy00zzs03zU0Dw01zk07z000003zzzw0000Tzy00zzs03zk0Dzz00Tzzw000007z00Tzw01zk07y00zs03zU00001zzzy0000Dzz00Tzw01zs07zzU0Dzzy000003zU0Dzy00zs03z00Tw01zk00000zzzz00007zzU0Dzy00zw03zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    zone8Pattern := "|<>*143$347.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs00000Tzz00007zzU0Dzzzzzzy0000Dzzzk0001zzzw0000TzzzU0003zzk00000zzy0000Dzz00Tzzzzzzw0000TzzzU0003zzzs0000zzzz00007zzU00001zzw0000Tzy00zzzzzzzs0000zzzz00007zzzk0001zzzy0000Dzz000003zzs0000zzw01zzzzzzzk0001zzzy0000DzzzU0003zzzw0000Tzy000007zzk0001zzs03zzzzzzzU0003zzzw0000Tzzz00007zzzs0000zzw00000DzzU0003zzk07zzzzzzz00007zzzs0000zzzy0000Dzzzk0001zzs00000Tzy00007zzU0Dzzzzzzw00007zzzU0001zzzs0000Dzzz00003zk000000zw0000007z00Tzzzzzs000000Dy0000001zk000000Ty0000003U000001zs000000Dy00zzzzzzk000000Tw0000003zU000000zw00000070000003zk000000Tw01zzzzzzU000000zs0000007z0000001zs000000C0000007zU000000zs03zzzzzz0000001zk000000Dy0000003zk000000Q000000Dz0000001zk07zzzzzy0000003zU000000Tw0000007zU000000s03zzzzzy00zzs03zU0Dzzzzzw01zzk07z00Dzw00zs03zzU0Dz00Tzs01k0Dzzzzzw01zzk07z00Tzzzzzs03zzU0Dy00zzw01zk07zz00Ty01zzs03U0Tzzzzzs03zzU0Dy00zzzzzzk07zz00Tw01zzs03zU0Dzy00zw03zzk0700zzzzzzk07zz00Tw01zzzzzzU0Dzy00zs03zzk07z00Tzw01zs07zzU0C01zzzzzzU0Dzy00zs03zzzzzz00Tzw01zk07zzU0Dy00zzs03zk0Dzz00Q03zzzzzz00Tzw01zk07zzzzzy00zzs03zU0Dzz00Tw01zzk07zU0Tzy00s07zzzzzy00zzs03zU0Dzzzzzw01zzk07z00Tzy00zs03zzU0Dz00zzw01k0Dzzzzzw00zzU07z00Tzzzzzs01zz00Dy00Tzs01zk03zy00Ty01zzs03U0Ts001zs000000Dy00zzzzzzk000000Tw0000003zU000000zw03zzk0700zk003zk000000Tw01zzzzzzU000000zs0000007z0000001zs07zzU0C01zU007zU000000zs03zzzzzz0000001zk000000Dy0000003zk0Dzz00Q03z000Dz0000001zk07zzzzzy0000003zU000000Tw0000007zU0Tzy00s07y000Ty0000003zU0Dzzzzzw0000007z0000000zs000000Dz00zzw01k0Dw000zw0000007z00Tzzzzzs000000Dy000003zzk000000Ty01zzs03U0Ts001zs000000Dy00zzzzzzk000000Tw00000DzzU000000zw03zzk0700zk003zk000000Tw01zzzzzzU000000zs00000Tzz0000001zs07zzU0C01zU007zU000000zs03zzzzzz0000001zk00000zzy0000003zk0Dzz00Q03z000Dz0000001zk07zzzzzy0000003zU00001zzw0000007zU0Tzy00s07y000Ty0000003zU0Dzzzzzw0000007z000003zzs000000Dz00zzw01k0Dzy00zw00zzU07z00Tzzzzzs01zz00Dy00Tk03zzk03zy00Ty01zzs03U0Tzy01zs03zzU0Dy00zzzzzzk07zz00Tw01zk003zU0Dzy00zw03zzk0700zzw03zk07zz00Tw01zzzzzzU0Dzy00zs03zU007z00Tzw01zs07zzU0C01zzs07zU0Dzy00zs03zzzzzz00Tzw01zk07z000Dy00zzs03zk0Dzz00Q03zzk0Dz00Tzw01zk07zzzzzy00zzs03zU0Dy000Tw01zzk07zU0Tzy00s07zzU0Ty00zzs03zU0Dzzzzzw01zzk07z00Tw000zs03zzU0Dz00zzw01k0Dzz00zw01zzk07z00Tzzzzzs03zzU0Dy00zs001zk07zz00Ty01zzs03U0Dzw01zs03zzU0Dy00Tzzzzzk07zz00Tw01zzk03zU0Dzy00zw03zzk070000003zk07zz00Tw0000003zU0Dzy00zs03zzk07z00Tzw01zs07zzU0C0000007zU0Dzy00zs0000007z00Tzw01zk07zzU0Dy00zzs03zk0Dzz00Q000000Dz00Tzw01zk000000Dy00zzs03zU0Dzz00Tw01zzk07zU0Tzy00s000000Ty00zzs03zU000000Tw01zzk07z00Tzy00zs03zzU0Dz00zzw01k000000zw01zzk07z0000000zs03zzU0Dy00zzw01zk07zz00Ty01zzs03zU00001zs03zzU0Dzz000001zk07zz00Tw01zzs03zU0Dzy00zw03zzk07z000003zk07zz00Tzy000003zU0Dzy00zs03zzk07z00Tzw01zs07zzU0Dy000007zU0Dzy00zzw000007z00Tzw01zk07zzU0Dy00zzs03zk0Dzz00Tw00000Dz00Tzw01zzs00000Dy00zzs03zU0Dzz00Tw01zzk07zU0Tzy00zs00000Ty00zzs03zzk00000Tw01zzk07z00Tzy00zs03zzU0Dz00zzw01zk00000zw01zzk07zzU00000zs03zzU0Dy00zzw01zk07zz00Ty01zzs03zU00001zs03zzU0DzzU00003zk07zz00Ty01zzs07zU0Dzy00zw03zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone9Pattern := "|<>*143$307.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy000007zzU00001zs03zzU0Dy00zzzzzzk07zz00Tzy0000Dzzzz000003zzk00000zw01zzk07z00Tzzzzzs03zzU0Dzz00007zzzzU00001zzs00000Ty00zzs03zU0Dzzzzzw01zzk07zzU0003zzzzk00000zzw00000Dz00Tzw01zk07zzzzzy00zzs03zzk0001zzzzs00000Tzy000007zU0Dzy00zs03zzzzzz00Tzw01zzs0000zzzzw00000Dzz000003zk07zz00Tw01zzzzzzU0Dzy00zzw0000Tzzzw000007zzU00001zs03zzU0Dy00zzzzzzk07zz00Tzy00007zzy0000003zU000000zw01zzk07z00Tzzzzzs03zzU0Dy0000003zz0000001zk000000Ty00zzs03zU0Dzzzzzw01zzk07z0000001zzU000000zs000000Dz00Tzw01zk07zzzzzy00zzs03zU000000zzk000000Tw0000007zU0Dzy00zs03zzzzzz00Tzw01zk000000Tzs000000Dy0000003zk07zz00Tw01zzzzzzU0Dzy00zs000000Dzw01zzzzzz00Dzzzzzs03zzU0Dy00zzzzzzk07zz00Tw00zzk07zy00zzzzzzU0Dzzzzzw01zzk07z00Tzzzzzs03zzU0Dy00zzs03zz00Tzzzzzk07zzzzzy00zzs03zU0Dzzzzzw01zzk07z00Tzw01zzU0Dzzzzzs03zzzzzz00Tzw01zk07zzzzzy00zzs03zU0Dzy00zzk07zzzzzw01zzzzzzU0Dzy00zs03zzzzzz00Tzw01zk07zz00Tzs03zzzzzy00zzzzzzk07zz00Tw01zzzzzzU0Dzy00zs03zzU0Dzw01zzzzzz00Tzzzzzs03zzU0Dy00zzzzzzk07zz00Tw01zzk07zy00TzzzzzU07zzzzzw00zzU07z00Tzzzzzs01zz00Dy00zzs03zz00007zzzk00000zzy0000003zU0Dzzzzzw0000007z00Tzw01zzU0003zzzs00000Tzz0000001zk07zzzzzy0000003zU0Dzy00zzk0001zzzw00000DzzU000000zs03zzzzzz0000001zk07zz00Tzs0000zzzy000007zzk000000Tw01zzzzzzU000000zs03zzU0Dzw0000Tzzz000003zzs000000Dy00zzzzzzk000000Tw01zzk07zy0000Dzzzzk0000zzw0000007z00Tzzzzzzs0000Tzy00zzs03zz00007zzzzs00000Ty0000003zU0Dzzzzzzy0000Dzz00Tzw01zzU0003zzzzw00000Dz0000001zk07zzzzzzz00007zzU0Dzy00zzk0001zzzzy000007zU000000zs03zzzzzzzU0003zzk07zz00Tzs0000zzzzz000003zk000000Tw01zzzzzzzk0001zzs03zzU0Dzw0000TzzzzU00001zs000000Dy00zzzzzzzs0000zzw01zzk07zy00zzzzzzzzzzy00zw01zzU07z00Tzzzzzzzw00zzzy00zzs03zz00Tzzzzzzzzzz00Ty00zzs03zU0Dzzzzzzzz00Tzzz00Tzw01zzU0DzzzzzzzzzzU0Dz00Tzw01zk07zzzzzzzzU0DzzzU0Dzy00zzk07zzzzzzzzzzk07zU0Dzy00zs03zzzzzzzzk07zzzk07zz00Tzs03zzzzzzzzzzs03zk07zz00Tw01zzzzzzzzs03zzzs03zzU0Dzw01zzzzzzzzzzw01zs03zzU0Dy00zzzzzzzzw01zzzw01zzk07zy00zzzzzzzzzzy00zw01zzk07z00Tzzzzzzzy00zzzy00zzs03zz00Tzzzzzzzzzz00Ty00zzs03zU07zzzzzzzz00Tzzz00Tzw01zzU000000zs000000Dz00Tzw01zk000000TzzzU0DzzzU0Dzy00zzk000000Tw0000007zU0Dzy00zs000000Dzzzk07zzzk07zz00Tzs000000Dy0000003zk07zz00Tw0000007zzzs03zzzs03zzU0Dzw0000007z0000001zs03zzU0Dy0000003zzzw01zzzw01zzk07zy0000003zU000000zw01zzk07z0000001zzzy00zzzy00zzs03zzz000001zk00000Tzy00zzs03zzk00000zzzz00Tzzz00Tzw01zzzk00000zs00000Tzz00Tzw01zzs00000TzzzU0DzzzU0Dzy00zzzs00000Tw00000DzzU0Dzy00zzw00000Dzzzk07zzzk07zz00Tzzw00000Dy000007zzk07zz00Tzy000007zzzs03zzzs03zzU0Dzzy000007z000003zzs03zzU0Dzz000003zzzw01zzzw01zzk07zzz000003zU00001zzw01zzk07zzU00001zzzy00zzzy00zzs03zzzU00001zk00000zzy00zzs03zzk00000zzzz00Tzzz00Tzw01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
    zone10Pattern := "|<>*140$265.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zz00Tzy0000Dzzzk000000TzzzU0003zzzs0000zzs03zzU0Dzz00007zzzs000000Dzzzk0001zzzw0000Tzw01zzk07zzU0003zzzw0000007zzzs0000zzzy0000Dzy00zzs03zzk0001zzzy0000003zzzw0000Tzzz00007zz00Tzw01zzs0000zzzz0000001zzzy0000DzzzU0003zzU0Dzy00zzw0000TzzzU000000zzzz00007zzzk0001zzk07zz00Tzy00007zzzU000000Dzzz00003zzzk0000Tzs03zzU0Dy0000003zk000000007z0000000zs000000Dw01zzk07z0000001zs000000003zU000000Tw0000007y00zzs03zU000000zw000000001zk000000Dy0000003z00Tzw01zk000000Ty000000000zs0000007z0000001zU0Dzy00zs000000Dz000000000Tw0000003zU000000zk07zz00Tw00zzk07zU0Dw01zU0Dy00Tzs01zk07zz00Ts03zzU0Dy00zzs03zk07y00zk07z00Tzy00zs03zzU0Dw01zzk07z00Tzw01zs03z00Ts03zU0Dzz00Tw01zzk07y00zzs03zU0Dzy00zw01zU0Dw01zk07zzU0Dy00zzs03z00Tzw01zk07zz00Ty00zk07y00zs03zzk07z00Tzw01zU0Dzy00zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dzy00zk07zz00Tw01zzk07zU0Dw01zU0Dy00zzw01zk07zz00Ts03zzU0Dy00Tzk03zk07y00zk07z00Tzy00zs01zz00Dw01zzk07z0000001zs03z00Ts03zU0Dzz00Tw0000007y00zzs03zU000000zw01zU0Dw01zk07zzU0Dy0000003z00Tzw01zk000000Ty00zk07y00zs03zzk07z0000001zU0Dzy00zs000000Dz00Ts03z00Tw01zzs03zU000000zk07zz00Tw0000007zU0Dw01zU0Dy00zzw01zk000000Ts03zzU0Dy0000003zk07y00zk07z00Tzy00zs00000Tzw01zzk07z0000001zs03z00Ts03zU0Dzz00Tw00000Dzy00zzs03zU000000zw01zU0Dw01zk07zzU0Dy000007zz00Tzw01zk000000Ty00zk07y00zs03zzk07z000003zzU0Dzy00zs000000Dz00Ts03z00Tw01zzs03zU00001zzk07zz00Tw0000007zU0Dw01zU0Dy00zzw01zk00000zzs03zzU0Dy00Tzs03zk07y00zk07z00Tzy00zs01y00Tzw01zzk07z00Tzw01zs03z00Ts03zU0Dzz00Tw01zU007y00zzs03zU0Dzy00zw01zU0Dw01zk07zzU0Dy00zk003z00Tzw01zk07zz00Ty00zk07y00zs03zzk07z00Ts001zU0Dzy00zs03zzU0Dz00Ts03z00Tw01zzs03zU0Dw000zk07zz00Tw01zzk07zU0Dw01zU0Dy00zzw01zk07y000Ts03zzU0Dy00zzs03zk07y00zk07z00Tzy00zs03z000Dw00zzU07z00Tzw01zs03z00Ts03zU07zy00Tw01zzk07y0000003zU0Dzy00zw01zU0Dw01zk000000Dy00zzs03z0000001zk07zz00Ty00zk07y00zs0000007z00Tzw01zU000000zs03zzU0Dz00Ts03z00Tw0000003zU0Dzy00zk000000Tw01zzk07zU0Dw01zU0Dy0000001zk07zz00Ts000000Dy00zzs03zk07y00zk07z0000000zs03zzU0Dzy0000Dzz00Tzw01zs03z00Ts03zzk0000zzw01zzk07zz00007zzU0Dzy00zw01zU0Dw01zzw0000Tzy00zzs03zzU0003zzk07zz00Ty00zk07y00zzy0000Dzz00Tzw01zzk0001zzs03zzU0Dz00Ts03z00Tzz00007zzU0Dzy00zzs0000zzw01zzk07zU0Dw01zU0DzzU0003zzk07zz00Tzw0000Tzy00zzs03zk07y00zk07zzk0001zzs03zzU0Dzy0000Dzz00Tzy01zs03z00Ts03zzs0000zzw01zzk07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk"
    ;Zone pattern OCRs are being evaluated in the FOR loop, with a GetRange applied, see the comment in the for loop about this.


    ;add more zone patterns here

    zones := {}  ; Create an empty object because trying to create the object and assign all the contents pointing to variables doesnt work, so this must be done explicitly, here.
    zones["Zone1"] := zone1Pattern
    zones["Zone2"] := zone2Pattern
    zones["Zone3"] := zone3Pattern
    zones["Zone4"] := zone4Pattern
    zones["Zone5"] := zone5Pattern
    zones["Zone6"] := zone6Pattern
    zones["Zone7"] := zone7Pattern
    zones["Zone8"] := zone8Pattern
    zones["Zone9"] := zone9Pattern
    zones["Zone10"] := zone10Pattern
    ;object literals sort of like an array that point back to a var. ^^^^^
    
    for zoneName, pattern in zones {
        if (ok:=FindText(X, Y, 1191, 537, 1999, 700, 0, 0, pattern)) {
            DebugLog("DetectCurrentZone: Matched zone = " . zoneName)
            return zoneName
        ;At the IF, the FindText function was modified, to have a GetRange applied. This is only checking a small mortion of the screen for the zone's OCR pattern on screen. This can speed the if check up by about 10x, but means there is lexx flexibility in where that element can be on screen.
        ;FindText if checks like this: if (ok:=FindText(X, Y, 1318-150000, 1087-150000, 1318+150000, 1087+150000, 0, 0, Text)), where the -15000 and + 15000 is searching entire screen region for OCR.
        }
    }
    
    DebugLog("DetectCurrentZone: No matching zone found.")
    return ""
}


;===========================================
; Hotkey: Toggle Bot Activity (F12)
;===========================================
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
