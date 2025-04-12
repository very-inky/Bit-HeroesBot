;===========================================
; Bit Heroes Bot – Multi-State Logic Skeleton
; (Works on 4k resolution, 150% zoom browser)
;===========================================
SetBatchLines, -1
#Include FindText.ahk
#Persistent
#SingleInstance Force

;------------- User Configurations -------------
actionConfig := {}  ; Associative array for action settings.
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
; Specify desired zone/dungeon pairs.
desiredZones := ["Zone1"]
desiredDungeons := ["Dungeon3"]  ; Corresponding dungeon choices.
global currentSelectionIndex := 1  ; Tracks configuration index.

;------------- Dungeon Mapping Configuration -------------
; Each zone is mapped to an array of three dungeon OCR patterns.
dungeonMapping := {}
dungeonMapping["Zone1"] := ["|<>*104$85.00007k1zz0000000003s0zzU00000000Tw003k00000000Dy001s000000007z000w000000003zU00S000000001zk00D000000000w7zw7U00000000S3zy3k00000000D1zz1s000000007UzzUw000000003kTzkTw0000zzU07zzzkS3zz0Tzk03zzzsD1zzUDzs01zzzw7Uzzk7zw00zzzy3kTzs3zzw0Tzzz07zzzlzzy0DzzzU3zzzszzz07zzzk1zzzwTzzU3zzzs0zzzyDzzk1zzzw0Tzzz7zzs0zzzy0DzzzXzzw0Tzzz07zzzlzzy0DzzzU3zzzszzz07zzzk1zzzwTzzzzzzzzzzzzyDzzzzzzzzzzzzz7zzzzzzzzzzzzzXzzzzzzzzzzzzzlzzzzzzzzzzzzzszzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs0zzzy00Tzzzzzw0Tzzz00Dzzzzzy0DzzzU07zzzzzz07zzzk03zzzzzzU3zzzs01zzzzzzk1zzzw00zzzzzzs0zzzy00Tzzzzzw0Tzzz00Dzzzzzy0DzzzU07zzzzzz07zzzzU3zzzzzzU3zzzzk1zzzzzzk1zzzzs0zzzzzzs0zzzzw0Tzzzzzw0Tzzzy0Dzzzzzy0Dzzzz00Ty0zzz07zzzzU0Dz0TzzU3zzzzk07zUDzzk1zzzzs03zk00zzzzzzzzzy0000Tzzzzzzzzz0000DzzzzzzzzzU0007zzzzzzzzzk0003zzzzzzzzzs00000D000007U0000007U00003k0000003k00001s0000001s00000w0000000w00000S0000Tw0S00000D0000Dy0D000007U0007z07U00003k0003zU3k00001s00007zzs00000zzz073zzw00000TzzU3Vzzy00000Dzzk1kzzz000007zzs0sTzzU00003zzw0Tzzzk00001zzzzlzzzs00000zzzzszzzw00000TzzzwTzzy00000DzzzyDzzzzzzzzzU0004", "|<>*133$75.kDU0Dz3zUw6061w01zsTw7Uk0kDU0Dz3zUw6061w01zsTw7Uk07zy0Dz3zUw000zzk1zsTw7U007zy0Dz3zUw000zzk1zsTw7U007zzzzzzzzw000zzzzzzzzzU007zzzzzzzzw000zzzzzzzzzU007zzzzzzzzw000zzzzzzzzzU077zzzzzzzzw00szzzzzzzzzU077zzzzzzzzw00szzzzzzzzzU07zzzzzzzzzw00zzzzzzzzzzU07zzzzzzzzzw00zzzzzzzzzzU07zzzzzz3zz000zzzzzzsTzs007zzzzzz3zz000zzzzzzsTzs007zzzzzz3zz000zzzzzzzzzsTy7zzzzzzzzz3zkzzzzzzzzzsTy7zzzzzzzzz3zkzy001zzUzzz1zzk00Dzw7zzsDzy001zzUzzz1zzk00Dzw7zzsDzy001zzUzzz1zzk1wDzzzUzzz7y0DVzzzw7zzszk1wDzzzUzzz7y0DVzzzw7zzss0TzzzzzUzzkz03zzzzzw7zy7s0TzzzzzUzzkz03zzzzzw7zy7s0TzzzzzUzzkzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzs1zzVzzzzzzzz0DzwDzzzzzzzs1zzVzzzzzzzz0DzwDzzzzzzzs1zzzzzzzzzzs0Dzzzzzzzzzz01zzzzzzzzzzs0Dzzzzzzzzzz01zzzzzzzzzzszzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzzzz07zzzzzzzzzzs0zzzzzzzzw0007zzzzzzzzU000zzzzzzzzw0007zzzzzzzzU07kzzzzzzzzw7zy7zzzzzzzzUzzkzzzzzzzzw7zy7zzzzzzzzU000zzzzzzzzw0007s0TzzzzzU00D703zzzzzw001ss0TzzzzzU00D703zzzzzw001s00Tzzzzzzzzzs03zzzzzzzzzz00Tzzzzzzzzzs03zzzzzzzzzz00Tzzzzzzzzzw", "|<>*120$87.zzzzzzzzzzw0T07zzzzzzzzzzU07kzzzzzzzzzzw00y7zzzzzzzzzzU07kzzzzzzzzzzw00y7zzzzzzzzzzU07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzzs0y7zzzzzzzzzzz07kzzzzzzzzzzw0Ty7zzzzzzzzzzU3zkzzzzzzzzzzw0Ty7zzzzzzzzzzU3zkzzzzzzzzzzw0Ty7zzzzzzzzzzUw7kzzzzzzzzzzw7Uy7zzzzzzzzzzUw7kzzzzzzzzzzw7Uy7zzzzzzzzzzUw7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzzzzzzzzU3s0y7zzzzzzzzw0T07kzzzzzzzzzU3s0y7zzzzzzzzw0T07kzzzzzzzzzU3s0y7zzzzzzzy07U07kzzzzzzzzk0w00y7zzzzzzzy07U07kzzzzzzzzk0w00y7zzzzzzzy3s007kzzzzzzzzkT000y7zzzzzzzy3s007kzzzzzzzzkT000y7zzzzzzzy3s007kzzzzzzzwDU000y7zzzzzzzVw0007kzzzzzzzwDU000y7zzzzzzzVw0007kzzzzzzzwDU000y7zzzzzzzzw0007kzzzzzzzzzU000y7zzzzzzzzw0007kzzzzzzzzzU000y7zzzzzzk1w003zkzzzzzzy0DU00Ty7zzzzzzk1w003zkzzzzzzy0DU00Ty7zzzzzzk1w003zkzzzy0000DU3zUy7zzzk0001w0Tw7kzzzy0000DU3zUy7zzzk0001w0Tw7kzzzy0000DzzzUy7zzzk0001zzzw7kzzzy0000DzzzUy7zzzk0001zzzw7kzzzy0000DzzzUy7zzzzzzzzzs0w7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzzzzzzzzz07Uy7zzzzzzzzzs0w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy7zzs0S000000w7kzzz03k000007Uy4"]
dungeonMapping["Zone2"] := ["|<>[Zone2 Dungeon1 OCR Pattern]", "|<>[Zone2 Dungeon2 OCR Pattern]", "|<>[Zone2 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone3"] := ["|<>[Zone3 Dungeon1 OCR Pattern]", "|<>[Zone3 Dungeon2 OCR Pattern]", "|<>[Zone3 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone4"] := ["|<>[Zone4 Dungeon1 OCR Pattern]", "|<>[Zone4 Dungeon2 OCR Pattern]", "|<>[Zone4 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone5"] := ["|<>[Zone5 Dungeon1 OCR Pattern]", "|<>[Zone5 Dungeon2 OCR Pattern]", "|<>[Zone5 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone6"] := ["|<>[Zone6 Dungeon1 OCR Pattern]", "|<>[Zone6 Dungeon2 OCR Pattern]", "|<>[Zone6 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone7"] := ["|<>[Zone7 Dungeon1 OCR Pattern]", "|<>[Zone7 Dungeon2 OCR Pattern]", "|<>[Zone7 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone8"] := ["|<>[Zone8 Dungeon1 OCR Pattern]", "|<>[Zone8 Dungeon2 OCR Pattern]", "|<>[Zone8 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone9"] := ["|<>[Zone9 Dungeon1 OCR Pattern]", "|<>[Zone9 Dungeon2 OCR Pattern]", "|<>[Zone9 Dungeon3 OCR Pattern]"]
dungeonMapping["Zone10"] := ["|<>[Zone10 Dungeon1 OCR Pattern]", "|<>[Zone10 Dungeon2 OCR Pattern]", "|<>[Zone10 Dungeon3 OCR Pattern]"]

;------------- Global Variables -------------
global previousState := ""
actionCooldown := 1200000   ; 20 minutes (in ms).
lastActionTime := {}        ; Tracks last execution time per action.
for index, act in actionOrder {
    lastActionTime[act] := 0
}

;------------- Bot State Management -------------
; Global states:
; "NotLoggedIn"      - Waiting for quest icon.
; "HandlingPopups"   - Clearing pop-ups.
; "NormalOperation"  - Ready to start a new action.
; "ActionRunning"    - An action has been initiated and is in progress.
; "Paused"           - Bot is paused.
gameState := "NotLoggedIn"
DebugLog("Script started. Initial gameState = NotLoggedIn.")

; Main loop timer
SetTimer, BotMain, 1000  ; Runs every 1000 ms.
Return

;===========================================
; BotMain – Global State Machine
;===========================================
BotMain:
{
    if (gameState = "Paused")
        Return

    ; If not logged in, check for quest icon.
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
    
    ; Handling pop-ups before game can progress.
    if (gameState = "HandlingPopups") {
        DebugLog("HandlingPopups: Clearing pop-ups...")
        popupAttempts := 0
        while (!IsMainScreenAnchorDetected()) {
            if (gameState = "Paused") {
                while (gameState = "Paused")
                    Sleep, 500
            }
            Send, {Esc}
            Sleep, 1000
            popupAttempts++
            DebugLog("HandlingPopups: Sent {Esc}, attempt #" . popupAttempts)
        }
        DebugLog("HandlingPopups: Quest icon detected. Transitioning to NormalOperation.")
        gameState := "NormalOperation"
        Return
    }
    
    ; Normal operation – start new actions.
    if (gameState = "NormalOperation") {
        currentAction := actionOrder[currentActionIndex]
        DebugLog("NormalOperation: Current action: " . currentAction)
        now := A_TickCount
        
        if ((now - lastActionTime[currentAction]) >= actionCooldown) {
            result := ""
            Switch currentAction {
                Case "Quest":
                    result := ActionQuest()
                Case "PVP":
                    result := ActionPVP()
                Case "WorldBoss":
                    result := ActionWorldBoss()
                Case "Raid":
                    result := ActionRaid()
                Case "Trials":
                    result := ActionTrials()
                Case "Expedition":
                    result := ActionExpedition()
                Case "Gauntlet":
                    result := ActionGauntlet()
            }
            if (result = "outofresource") {
                DebugLog("NormalOperation: " . currentAction . " returned 'outofresource'; starting cooldown and advancing to next action.")
                lastActionTime[currentAction] := now
                currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1
            }
            else if (result = "started") {
                ; An action has started: update state.
                DebugLog("NormalOperation: " . currentAction . " initiated; switching state to ActionRunning.")
                gameState := "ActionRunning"
            }
            else if (result = "retry") {
                DebugLog("NormalOperation: " . currentAction . " returned 'retry'; will reattempt on next cycle.")
            }
            else {
                DebugLog("NormalOperation: " . currentAction . " returned '" . result . "'; retrying on next cycle.")
            }
        } else {
            DebugLog("NormalOperation: " . currentAction . " skipped - cooldown active.")
        }
    }
    
    ; While an action is running, monitor its progress.
    if (gameState = "ActionRunning") {
        MonitorActionProgress()  ; Checks for completion, disconnects, or early death.
    }
}
Return

;===========================================
; MonitorActionProgress – Action Running State
;===========================================
MonitorActionProgress() {
    ; Check if the action is complete (i.e. the rerun button is detected)
    if (IsActionComplete()) {
        DebugLog("MonitorActionProgress: Rerun button detected; re-running action.")
        ClickRerun()  ; Call function to click the rerun button.
        Sleep, 500  ; Allow the UI to update.
        ; Remain in the ActionRunning state – we do not change gameState.
        return
    }
    ; Check if the client is disconnected.
    else if (IsDisconnected()) {
        DebugLog("MonitorActionProgress: Disconnect detected; attempting reconnection.")
        AttemptReconnect()  ; Handle reconnection here.
        gameState := "NotLoggedIn"  ; Reset state to re-check the main screen anchor.
    }
    ; Check if the player is dead.
    else if (IsPlayerDead()) {
        DebugLog("MonitorActionProgress: Player death detected.")
        gameState := "NotLoggedIn"  ; Update state as needed.
    }
    DebugLog("Performed check for re-run, disconnect and death are placeholder for now")
}

;===========================================
; Helper function to click the rerun button
;===========================================
ClickRerun() {
    ; Define your OCR pattern for the rerun button (placeholder)
    Text:="|<>*143$154.000Dty000Dz001zs1zk3zs00Tk000zzs000zw007zU7z0DzU01zU003zzU003zk00Ty0Tw0zy007z000Dzy000Dz001zs1zk3zs00Tw0001y0000z0000TU7z0Dk0003k0007s0003w0001y0Tw0z0000D0000TU000Dk0007s1zk3w0000w0001y0000z0000TU7z0Dk0003k7zU7s1zzzw0zs1y0Tw0z0Dz0D0Ty0TU7zzzk3zU7s1zk3w0zw0w1zs1y0Tzzz0Dy0TU7z0Dk3zk3k7zU7s1zzzw0zs1y0Tw0z0Dz0D0Dy0TU7zw7k3zU7s1zk3w0zw0w0001y007kT0000TU7z0Dk3zk3k0007s00T1w0001y0Tw0z0Dz0D0000TU01w7k0007s1zk3w0zw0w000Ty007kT0007zU7z0Dk3zk3k003zs00T1w000Ty0Tw0z0Dz0D000DzU01w7k001zs1zk3w0zw0w000zy007kT0007zU7z0Dk3zk3k003zs00T1w000Ty0Tw0z0Dz0D0T00TU7zzzk3s07s1zk3w0zw0w1w01y0Tzzz0DU0TU7z0Dk3zk3k7k07s1zzzw0y01y0Tw0z0Dz0D0T00TU7zzzk3s07s1zk3w0zw0w1zs1y0000z0Dy0TU000Dk3zk3k7zU7s0003w0zs1y0000z0Dz0D0Ty0TU000Dk3zU7s0003w0zw0w1zs1y0000z0Dy0TU000Dk3zk3k7zU7zU003w0zs1zs00Dz0Dz0D0Ty0Ty000Dk3zU7zU00zw0zw0w1zs1zs000z0Dy0Ty003zk3zk3k7zU7zU003w0zs1zs00Dz0Dz0DzzzzyzzzzzzzzzzrzzzyzzzzzzzzzztzzzzzzzTzzTzzznzzzzzs"
    ; Adjust the coordinates to the region where the button appears.
    if (ok:=FindText(X, Y, 1463-150000, 1563-150000, 1463+150000, 1563+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        DebugLog("ClickRerun: Rerun button clicked.")
    } else {
        DebugLog("ClickRerun: Rerun button NOT detected.")
    }
}

;===========================================
; Helper function to attempt reconnection
;===========================================
AttemptReconnect() {
    ; Insert your reconnection logic here.
    ; This might include clicking on a 'reconnect' button,
    ; or navigating back to the main screen.
    ;DebugLog("AttemptReconnect: Executing reconnection routine...")
    ; For example, click {Esc} repeatedly, or simulate a refresh:
    ;Send, {Esc}
    ;Sleep, 1000
    ; After your reconnection routine, you may want to update gameState.
    ; For now, we simply log and let the main loop take care of resetting.
}

;===========================================
;Check Functions
;===========================================
IsActionComplete() {
    ; Insert OCR logic that looks for the rerun button.
    ; Return true if found.
    Text:="|<>*143$154.000Dty000Dz001zs1zk3zs00Tk000zzs000zw007zU7z0DzU01zU003zzU003zk00Ty0Tw0zy007z000Dzy000Dz001zs1zk3zs00Tw0001y0000z0000TU7z0Dk0003k0007s0003w0001y0Tw0z0000D0000TU000Dk0007s1zk3w0000w0001y0000z0000TU7z0Dk0003k7zU7s1zzzw0zs1y0Tw0z0Dz0D0Ty0TU7zzzk3zU7s1zk3w0zw0w1zs1y0Tzzz0Dy0TU7z0Dk3zk3k7zU7s1zzzw0zs1y0Tw0z0Dz0D0Dy0TU7zw7k3zU7s1zk3w0zw0w0001y007kT0000TU7z0Dk3zk3k0007s00T1w0001y0Tw0z0Dz0D0000TU01w7k0007s1zk3w0zw0w000Ty007kT0007zU7z0Dk3zk3k003zs00T1w000Ty0Tw0z0Dz0D000DzU01w7k001zs1zk3w0zw0w000zy007kT0007zU7z0Dk3zk3k003zs00T1w000Ty0Tw0z0Dz0D0T00TU7zzzk3s07s1zk3w0zw0w1w01y0Tzzz0DU0TU7z0Dk3zk3k7k07s1zzzw0y01y0Tw0z0Dz0D0T00TU7zzzk3s07s1zk3w0zw0w1zs1y0000z0Dy0TU000Dk3zk3k7zU7s0003w0zs1y0000z0Dz0D0Ty0TU000Dk3zU7s0003w0zw0w1zs1y0000z0Dy0TU000Dk3zk3k7zU7zU003w0zs1zs00Dz0Dz0D0Ty0Ty000Dk3zU7zU00zw0zw0w1zs1zs000z0Dy0Ty003zk3zk3k7zU7zU003w0zs1zs00Dz0Dz0DzzzzyzzzzzzzzzzrzzzyzzzzzzzzzztzzzzzzzTzzTzzznzzzzzs"
    if (ok:=FindText(X, Y, 1463-150000, 1563-150000, 1463+150000, 1563+150000, 0, 0, Text))
        return true
    return false
}

IsDisconnected() {
    ; Insert OCR or other logic to detect a disconnect.
    return false  ; Placeholder.
}

IsPlayerDead() {
    ; Insert OCR or other logic to detect if the player has died.
    return false  ; Placeholder.
}

;===========================================
; DebugLog: Helper Function for Debug Output
;===========================================
DebugLog(msg) {
    OutputDebug, % msg
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    FileAppend, % timestamp " - " msg "`n", debug_log.txt
}

;===========================================
; OCR & UI Detection Functions
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
        DebugLog("ArePopupsPresent: Popup detected.")
        Return True
    }
    Return False
}

CheckOutOfResources() {
    Text:="|<>*144$123.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy01zzU0Tw03zzs07zy01zk0Dzw03zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk000003zU0Tzz00zzk0Dy000000Tw03zzs07zy01zk07zs03zU0zzz00zzk0Dy01zzU0Tzzzzzs07zy01zk0Dzw03zzzzzz00zzk0Dy01zzU0Tzzzzzs07zy01zk0Dzw03zzzzzz00zzk0Dy01zzU0Tzzzzzs07zy01zk0Dzw03zzzzzz00TzU0Dy01zzU0Tzzzzzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzz000000Dy01zzU0Tw03zzs000001zk0Dzw03zU0Tzzz0000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0TzzzU000Dzy01zzU0Tw03zzzw0001zzk0Dzw03zU0Tzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    if (ok := FindText(X, Y, 1000-150000, 800-150000, 1000+150000, 800+150000, 0, 0, Text)) {
        DebugLog("Resources are depleted.")
        return true
        }
    return false       
}


;===========================================
; Quest Action – Full Quest Logic
;===========================================
ActionQuest() {
    ; Step 1: Open the Quest Window if not open.
    if (!IsQuestWindowOpen()) {
        DebugLog("ActionQuest: Quest window not open. Clicking quest icon.")
        ClickQuestIcon()
        Sleep, 500
        if (!IsQuestWindowOpen()) {
            DebugLog("ActionQuest: Quest window still not detected; will retry later.")
            return "retry"
        }
    }
    
    ; Step 2: Retrieve desired zone/dungeon configuration.
    global desiredZones, desiredDungeons, currentSelectionIndex
    selectedZone := desiredZones[currentSelectionIndex]
    selectedDungeon := desiredDungeons[currentSelectionIndex]
    DebugLog("ActionQuest: Selected configuration: " . selectedZone . " - " . selectedDungeon)
    
    ; Step 3: Navigate to the desired zone.
    if (!EnsureCorrectZoneSelected(selectedZone)) {
        DebugLog("ActionQuest: Could not navigate to " . selectedZone . "; retrying.")
        return "retry"
    }
    
    ; Step 4: Navigate/select the desired dungeon.
    targetDungeonIndex := SubStr(selectedDungeon, 8)  ; Assumes "Dungeon" is 7 chars.
    if (!EnsureCorrectDungeonSelected(selectedZone, targetDungeonIndex)) {
        DebugLog("ActionQuest: Could not select dungeon " . selectedDungeon . " in " . selectedZone . "; retrying.")
        return "retry"
    }
    
    ; Step 5: Select Heroic Difficulty.
    if (!SelectHeroicDifficulty()) {
        DebugLog("ActionQuest: Heroic difficulty not confirmed; retrying.")
        return "retry"
    }
    
  ; Step 6: Click Accept.
    result := ClickAccept()
    if (result = "confirmed") {
        Sleep, 800
    } else if (result = "outofresource") {
        DebugLog("ActionQuest: Out-of-resources detected after clicking Accept; starting cooldown and rotating action.")
        return "outofresource"
    } else {
        DebugLog("ActionQuest: Accept button not confirmed; retrying.")
        return "retry"
    }
    
    ; Step 7: Check for resource shortage.
    if (CheckOutOfResources()) {
        DebugLog("ActionQuest: Detected resource shortage after Accept.")
        return "outofresource"
    }
    
    DebugLog("ActionQuest: Quest action initiated successfully.")
    ; Return a special signal indicating the action has started.
    return "started"
}

;===========================================
; Heroic Difficulty Functions
;===========================================
SelectHeroicDifficulty() {
    ; Define your OCR pattern for detecting the heroic difficulty button.
    Text:="|<>*133$179.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007zs3zw0zzzzU1zzzk07zzzU7zs1zzzzzwTzy7zzzzsDzzzs0zzzzUzzsDzzzzzwzzyDzzzzszzzzs3zzzzXzzszzzzzzvzzwzzzzztzzzzk7zzzzjzzvzzzzzzzzzxzzzzzrzzzzUDzzzzTzzrzzzz07zU3zs000DzU00Dvz000zy0DzU00C0Dz07zk000Tz000Tzy001zw0Tz000Q0Ty0DzU000zy000zzw003zs0zy000s0zw0Tz0001zw001zzs007zk1zw001k1zs0zw0003zs003zzU007zU3zs003U3zk1y00007s0000Tk0000z07s000307zU3w0000Dk0000zU0001y0Dk00060Dz07s0000TU0001z00003w0TU000A0Ty0Dk0000z00003y00007s0z0000M0zw0TU3zzzy0DzU7w0Ty0Dk1y0Dz0k1zs0z07zzzw0Tz0Ds0zw0TU3w0Ty1U3zk1y0Dzzzs0zy0Tk1zs0z07s0zw307zU3w0Tzzzk1zw0zU3zk1y0Dk1zs60Dz07s0zzk7U1zk1z07zU3w0TU3zzw0000Dk007UD00003y0Dz07s0z07rzs0000TU00D0S00007w0Ty0Dk1y0Djzk0000z000S0w0000Ds0zw0TU3w0TDzU0001y000w1s0000Tk1zs0z07s0y7z00003w001s3k000DzU3zk1y0Dk1wDy00007s003k7U000Tz07zU3w0TU3tzw0000Dk007UD0000zy0Dz07s0z07rzs0000TU00D0S0001zw0Ty0Dk1y0Dzzk1zk0z07zz0w0D03zs0zw0TU3w0TzzU3zk1y0Dzzzs0z00Tk1zs0z07s0zw307zU3w0Tzzzk1y00zU3zk1y0Dk1zs60Dz07s0zzzzU3w01z07zU3w0TU3zkA0Ty0Dk1zzzz07s03y0Dz07s0z07zUM0zw0TU3zzzy0Dz07w0Tw0Dk1y07z0k1zs0z00003w0Tz0Ds0000TU3w0001U3zk1y00007s0zy0Tk0000z07s000307zU3w0000Dk1zw0zU0001y0Dk00060Dz07s0000TU3zs1z00003w0TU000A0Ty0DzU000z07zk3zw003zs0zy000s0zw0Tz0001y0DzU7zs007zk1zw001k1zs0zy0003w0Tz0Dzk00DzU3zs003U3zk1zw0007s0zy0TzU00Tz07zk007zzzzzvzzzzzzzzzzyTzzzyzzzjzzzzzzzzzbzzzzzzzzzzwzzzzxzzzTzzzzzyzzzDzzzzzzzrzztzzzzlzzwTzzzzzszzwDzzzzzzz7zzVzzzzVzzsTzzzzzUTzk7zzzwDzs7zy1zzzw1zz0Tzzy000000000000000000000000000000000000000000000000000000000004"
    if (ok := FindText(X, Y, 2020-150000, 1033-150000, 2020+150000, 1033+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
    }
    Sleep, 1100  ; Allow the UI to update.
    
    ; Check if we are on team screen via accept button
    if (IsHeroicSelected()) {
        DebugLog("SelectHeroicDifficulty: Heroic difficulty confirmed.")
        return true
    } else {
        DebugLog("SelectHeroicDifficulty: Heroic difficulty not confirmed.")
        return false
    }
}

IsHeroicSelected() {
    ; Define your OCR pattern for detecting if heroic difficulty is active.
    Text:="|<>*140$203.7zzzzUTzzzy1zzzzs3zzzzzDzzzzTzzzzzz000Try001zzs007yzU000Tz000zy00007y000zzw003zzk00Dzz0000zy001zw0000Dw001zzs007zzU00Tzy0001zw003zs0000Ts003zzk00Dzz000zzw0003zs007zk0000w0000Dk0000z00003y00007s0000TU0001s0000TU0001y00007w0000Dk0000z00003k0000z00003w0000Ds0000TU0001y00007U0001y00007s0000Tk0000z00003w0000D07z03w0Ty0Dk1zs0zU3zzzy0Dz07zzU3zy0Tz07s0zw0TU3zk1z0Dzzzw0Ty0Dzz07zw0zy0Dk1zs0z07zU3y0Tzzzs0zw0Tzy0Dzs1zw0TU3zk1y0Dz07w0zzzzk1zs0zzw0Tzk3zs0z07zU3w0Ty0Ds1zzzjU3zk1xzs0zzU3zU1y0Dzzzs0zzzzk1zzUT07zU3s7k1w700003w0Tzzzk1xzzzU00T0y00007kDU3kC00007s0yzzzU3vzzz000y1w0000DUT07UQ0000Dk1wzzz07nzzy001w3s0000T0y0D0s0000TU3sTzy0DVzxw003s7k0000y1w0S1k0000z07lzzw0T7zzs007kDU000zw3s0w3U0001y0Dbzzs0yTzzk00DUT0001zk7k1s700003w0TTzzk1xzzzU00T0y0003zUDU3sC00007s0zzzzU3zzzz000y1w0007y0T07kQ0Ty0Dk1zzzz07zzzy0Dzw3s0zzzU0y0DUs1zw0TU3zk1y0Dz07w0zzzzk1zzz01w0T1k3zs0z07zU3w0Ty0Ds1zzzzU3zzw03s0y3U7zk1y0Dz07s0zw0Tk3zzzz07zzs07k1w70DzU3w0Ty0Dk1zs0zU7zzzy0Dzz00DU3sC0Tz07s0000TU0001z00003w0T0000T07kQ0zy0Dk0000z00003y00007s0y0000y0DUs1zw0TU0001y00007w0000Dk1w0001w0T1k3zs0z00003w0000Ds0000TU3s0003s0y3U7zk1zs003zzk007zz0000z07k0007k1w70DzU3zs007zzU00Tzy0001y0DU000DU3sC0Tz07zk00Dzz000zzw0003w0T0000T07kQ0zy0DzU00Tzy001zzs0007s0y0000y0DUs1zw0Tz000zbw003zTk000Dk1w0001w0T1" 
    if (ok := FindText(X, Y, 1861-150000, 1539-150000, 1861+150000, 1539+150000, 0, 0, Text)) {
        return true
    } else {
        return false
    }
}

;===========================================
; Quest Helper Functions
;===========================================
IsQuestWindowOpen() {
    Text:="|<>*143$173.00003zw003zzk00Dzz0000zy0003s00007zs007zzU00Tzy0001zw0007k0000DzU00Dzz000zzw0003zk000DU0000Tk0000z00003w00007s0000T00000zU0001y00007s0000Dk0000y00001z00003w0000Dk0000TU0001w00003y00007s0000TU0001z00003tzzk07w0Ty0Dk1zs0z07zzzy0DzzznzzU0Ds0zw0TU3zk1y0Dzzzw0Tzzzbzz00Tk1zs0z07zU3w0Tzzzs0zzzyDzy00zU3zk1y0Dz07s0zzzzk1zzzsTzw0Tz07zU3w0Ty0Dk1zzzjU3zzzU7w00zy0Dz07s0zw0TU00DUT0001zUTs01zw0Ty0Dk1zs0z000T0y0003zVzk03zs0zw0TU3zk1y000y1w0007z3zU07zk1zs0z07zU3w001w3s000DzDy07zjU3zk1y0Dz07s003s7zU00TyT00DyT07zU3w0Ty0Dk007kDz0001wy00Twy0Dz07s0zw0TU00DUTy0003tw00zzw0Ty0Dk1zs0z000Tzzw0007zs01zzs0zw0TU3zk1y000zzzs000Ds01zzzk1zs0z07zU3w0Tzzzzzzw0Tk03zzzU3zk1y0Dz07s0zzzzzzzs0zU07zzz07zU3w0Ty0Dk1zzzzzzzk1z00Dzzy0Dz07s0zw0TU3zzzzzzzU3y00Tzzw0Ty0Dk1zs0z07zzzzzzz07w0000Ds0000TU3zk1y00007w0000Ds0000Tk0000z07zU3w00007s0000Tk0000zU0001y0Dz07s0000Dk0000zU0001z00003w0Ty0Dk0000TU0001z00003zw003zs0zw0Tz0000z0001zy00007zs007zk1zs0zy0001y0003zw0000Dzk00DzU3zk1zw0003w0007zs0000TzU00Tz07zU3zs0007s000Dzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
    if (ok := FindText(X, Y, 1045-150000, 642-150000, 1045+150000, 642+150000, 0, 0, Text))
        return true
    return false
}
ClickQuestIcon() {
    Text := "|<>E8D0A6-0.90$59.0zzzzs01zk1zzzzk03zU3kTzk007Us7UzzU00D1kD1zz000S3US3zy000w70w7zw001sC1zk1sD1w0Q3zU3kS3s0s7z07Uw7k1kDy0D1sDU3UTzk03zU3z0zzU07z07y1zz00Dy0Dw3zy00Tw0Ts7zw00zs0zkDzzk0001zUTzzU0003z0zzz00007y1zzy0000Dw3zzw0000Ts7zzzU00DzkDzzz000TzUTzzy000zz0zzzw001zyzzzzs01zzxzzzzk03zzvzzzzU07zzrzzzz00Dzzjzzzy00TzzTzzz0001zyzzzy0003zxzzzw0007zvzzzs000Dzrzzs0zs01zjzzk1zk03zTzzU3zU07yzzz07z00Dxzzy0Dy00Tzzz3zz000zzzy7zy001zzzwDzw003zzzsTzs007zzsDzzk00DXzkTzzU00T7zUzzz000yDz1zzy001wTy3zzw003szzzzzs01s1zzzzzk03k3zzzzzU07U7zzzzz00D0Dz07zzzzzwTy0Dzzzzzszw0Tzzzzzlzs0zzzzzzXzk1zzzzzz7s007zzzzyDk00DzzzzwTU00Tzzzzsz000zzzzzly001zzzzzW0000DzzzU40000Tzzz080000zzzy0E0001zzzw0U0003zzy0100007zzw02"
    if (ok := FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        Sleep, 100
        DebugLog("ClickQuestIcon: Quest icon clicked.")
    }
}

ClickAccept() {
    Text := "|<>*140$203.7zzzzUTzzzy1zzzzs3zzzzzDzzzzTzzzzzz000Try001zzs007yzU000Tz000zy00007y000zzw003zzk00Dzz0000zy001zw0000Dw001zzs007zzU00Tzy0001zw003zs0000Ts003zzk00Dzz000zzw0003zs007zk0000w0000Dk0000z00003y00007s0000TU0001s0000TU0001y00007w0000Dk0000z00003k0000z00003w0000Ds0000TU0001y00007U0001y00007s0000Tk0000z00003w0000D07z03w0Ty0Dk1zs0zU3zzzy0Dz07zzU3zy0Tz07s0zw0TU3zk1z0Dzzzw0Ty0Dzz07zw0zy0Dk1zs0z07zU3y0Tzzzs0zw0Tzy0Dzs1zw0TU3zk1y0Dz07w0zzzzk1zs0zzw0Tzk3zs0z07zU3w0Ty0Ds1zzzjU3zk1xzs0zzU3zU1y0Dzzzs0zzzzk1zzUT07zU3s7k1w700003w0Tzzzk1xzzzU00T0y00007kDU3kC00007s0yzzzU3vzzz000y1w0000DUT07UQ0000Dk1wzzz07nzzy001w3s0000T0y0D0s0000TU3sTzy0DVzxw003s7k0000y1w0S1k0000z07lzzw0T7zzs007kDU000zw3s0w3U0001y0Dbzzs0yTzzk00DUT0001zk7k1s700003w0TTzzk1xzzzU00T0y0003zUDU3sC00007s0zzzzU3zzzz000y1w0007y0T07kQ0Ty0Dk1zzzz07zzzy0Dzw3s0zzzU0y0DUs1zw0TU3zk1y0Dz07w0zzzzk1zzz01w0T1k3zs0z07zU3w0Ty0Ds1zzzzU3zzw03s0y3U7zk1y0Dz07s0zw0Tk3zzzz07zzs07k1w70DzU3w0Ty0Dk1zs0zU7zzzy0Dzz00DU3sC0Tz07s0000TU0001z00003w0T0000T07kQ0zy0Dk0000z00003y00007s0y0000y0DUs1zw0TU0001y00007w0000Dk1w0001w0T1k3zs0z00003w0000Ds0000TU3s0003s0y3U7zk1zs003zzk007zz0000z07k0007k1w70DzU3zs007zzU00Tzy0001y0DU000DU3sC0Tz07zk00Dzz000zzw0003w0T0000T07kQ0zy0DzU00Tzy001zzs0007s0y0000y0DUs1zw0Tz000zbw003zTk000Dk1w0001w0T1"
    if (ok := FindText(X, Y, 1861-150000, 1539-150000, 1861+150000, 1539+150000, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
        DebugLog("ClickAccept: Accept button clicked.")
        Sleep, 2000  ; Allow UI to update.
    }
    
    ; Immediately check for the out-of-resources condition.
    if (CheckOutOfResources()) {
        DebugLog("ClickAccept: Out-of-resources detected after clicking Accept.")
        Loop, 4 {
            Send, {Esc}
            Sleep, 650
        }
        ; Return a special status so the main routine triggers a cooldown and rotates to the next action.
        return "outofresource"
    }
    
    ; Finally, check if the accept confirmation appears.
    if (IsAcceptConfirmed()) {
        DebugLog("ClickAccept: Accept confirmed.")
        return "confirmed"
    }
    
    DebugLog("ClickAccept: Accept not confirmed.")
    return "retry"
}

IsAcceptConfirmed() {
    sleep 3000
    Text:="|<>*128$63.zzzzzzzzzzzzzU0003zzzzzw0000TzzzzzU0003zzzzzw0000Tzzzzs000007zzzz000000zzzzs000007zzzz000000zzzzs000007zzzU0000003zzw0000000TzzU0000003zzw0000000Tzs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z3zz000000zsTzs000007z3zz000000zsTzs000007z3s0000000zsT00000007z3s0000000zsT00000007z3s0000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007z000000000zs000000007zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
if (ok:=FindText(X, Y, 2458-150000, 873-150000, 2458+150000, 873+150000, 0, 0, Text)) {
        send {space}
        return true
}
    sleep 3000
    Text:="|<>8ED61E-0.90$19.7zzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyDzz7zzbzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzDzzXzzlzzszzwTzyDzz7zzXzzlzzszzwTzyTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzTzzbzzlzzszzwTzyDzz7zzXzzlzzw"
    if (ok:=FindText(X, Y, 2480-150000, 1060-150000, 2480+150000, 1060+150000, 0, 0, Text)){
    return true
    }
}

;===========================================
; Other Action Functions (PVP, WorldBoss, etc.)
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
    if (ok := FindText(X, Y, 2128, 891, 2640, 1378, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
    }
    DebugLog("ClickRightArrow: Right arrow clicked.")
    Sleep, 500
}

ClickLeftArrow() {
    Text:="|<>*133$53.zzzzzzlzzzzzzzzXzzzzzzzzs3zzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzU07zzzzzz00Dzzzzzy00Tzzzzzw00zzzzzzs01zzzzzzk03zzzzzzU07zzzzy000Dzzzzw000Tzzzzs000zzzzzk001zzzzzU003zzzzz0007zzzzy000Dzzzw0000Tzzzs0000zzzzk0001zzzzU0003zzzz00007zzzy0000Dzzs00000Tzzk00000zzzU00001zzz000003zzy000007zzw00000Dzzs00000TzU000000zz0000001zy0000003zw0000007zs000000Dzk000000TzU000000y00000001w00000003s00000007k0000000DU0000000T00000000y00000001w00000003s00000007k0000000DU0000000T00000000y00000001zy0000003zw0000007zs000000Dzk000000TzU000000zz0000001zy0000003zzy000007zzw00000Dzzs00000Tzzk00000zzzU00001zzz000003zzy000007zzzy0000Dzzzw0000Tzzzs0000zzzzk0001zzzzU0003zzzz00007zzzy0000Dzzzzw000Tzzzzs000zzzzzk001zzzzzU003zzzzz0007zzzzy000Dzzzzzy00Tzzzzzw00zzzzzzs01zzzzzzk03zzzzzzU07zzzzzz00Dzzzzzy00Tzzzzzzy0zzzzzzzw1zzzzzzzs3zzzzzzzk7zzzzzzzUDzzzzzzz0Tzzzzzzy0zzzzzzzXzzzzzzzz7zzzzzzzyDzzzzzzzwTzzzzzzzszzzzzzzzlzz"
    if (ok := FindText(X, Y, 592, 742, 1005, 1383, 0, 0, Text)) {
        FindText().Click(X, Y, "L")
    }
    DebugLog("ClickLeftArrow: Left arrow clicked.")
    Sleep, 500
}


EnsureCorrectZoneSelected(targetZone) {
    currentZone := DetectCurrentZone()
    attempts := 0

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
        if (currentZone = "")
            DebugLog("EnsureCorrectZoneSelected: Unable to detect current zone; retrying.")
        else if (zoneIndex[currentZone] < zoneIndex[targetZone])
            ClickRightArrow()
        else if (zoneIndex[currentZone] > zoneIndex[targetZone])
            ClickLeftArrow()

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

    zones := {}
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

    for zoneName, pattern in zones {
        if (ok := FindText(X, Y, 1191, 537, 1999, 700, 0, 0, pattern)) {
            DebugLog("DetectCurrentZone: Matched zone = " . zoneName)
            return zoneName
        }
    }
    DebugLog("DetectCurrentZone: No matching zone found.")
    return ""
}

EnsureCorrectDungeonSelected(zoneName, targetDungeonIndex) {
    global dungeonMapping
    dungeonArray := dungeonMapping[zoneName]
    if (!dungeonArray) {
        DebugLog("EnsureCorrectDungeonSelected: No dungeon mapping found for " . zoneName)
        return false
    }
    
    targetDungeonPattern := dungeonArray[targetDungeonIndex]
    if (ok := FindText(X, Y, 660, 496, 2501, 1680, 0, 0, targetDungeonPattern)) {
        FindText().Click(X, Y, "L")
        SoundBeep, 600, 500
        DebugLog("EnsureCorrectDungeonSelected: Target dungeon in " . zoneName . " detected using index " . targetDungeonIndex)
        return true
    } else {
        DebugLog("EnsureCorrectDungeonSelected: Target dungeon in " . zoneName . " NOT detected for index " . targetDungeonIndex)
        return false
    }
}

;===========================================
; Hotkey: Toggle Bot Activity (F12)
;===========================================
F12::
{
    if (gameState = "Paused") {
        ; Resume by restoring the previous state if available.
        if (previousState != "")
        {
            gameState := previousState
            DebugLog("Resumed via hotkey. Restoring previous state: " . gameState)
            previousState := ""  ; Optionally clear previousState after resuming.
        }
        else {
            gameState := "NotLoggedIn"
            DebugLog("Resumed via hotkey. No previous state stored; resetting state to NotLoggedIn.")
        }
    }
    else {
        ; Pause: save current state and set gameState to "Paused"
        previousState := gameState
        gameState := "Paused"
        DebugLog("Paused via hotkey. Previous state: " . previousState)
    }
}
Return
