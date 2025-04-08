;─────────────────────────────────────────────;
; Bit Heroes Bot – Multi-State Logic Skeleton  ;
; (All actions have a 20-minute cooldown)       ;
;─────────────────────────────────────────────;
#Include FindText.ahk
#Persistent
#SingleInstance Force

;------------- User Configurations -------------
; Enable/Disable each action as desired.
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
actionCooldown := 1200000          ; 20 minutes in milliseconds.
lastActionTime := {}               ; Track last execution time for each action.
; Initialize cooldown timestamps for all actions.
for index, act in actionOrder {
    lastActionTime[act] := 0
}

; Bot state management:
; "NotLoggedIn"  – waiting for a stable main-screen indicator,
; "HandlingPopups" – closing interfering popups,
; "NormalOperation" – rotating through actions,
; "Paused" – bot is paused.
gameState := "NotLoggedIn"

; Log startup.
DebugLog("Script started. Initial gameState = NotLoggedIn.")

; Set a timer to run the main bot loop every 1000 ms.
SetTimer, BotMain, 1000
Return

;─────────────────────────────────────────────;
; BotMain – Main Loop: State Transitions & Action Dispatch  ;
;─────────────────────────────────────────────;
BotMain:
{
    if (gameState = "Paused")
        Return

    ;---------------------------------------------------------
    ; STATE: NotLoggedIn – Wait for the main screen "anchor".
    ;---------------------------------------------------------
    if (gameState = "NotLoggedIn") {
        DebugLog("State: NotLoggedIn – Checking for main screen anchor.")
        if (IsMainScreenAnchorDetected()) {
            DebugLog("Main screen anchor detected. Transitioning to HandlingPopups.")
            gameState := "HandlingPopups"
        } else {
            DebugLog("Main screen anchor not detected. Remaining in NotLoggedIn.")
        }
        Return
    }

    ;---------------------------------------------------------
    ; STATE: HandlingPopups – Close interfering popups.
    ;---------------------------------------------------------
    if (gameState = "HandlingPopups") {
        DebugLog("State: HandlingPopups – Checking for popups.")
        if (ArePopupsPresent()) {
            DebugLog("Popup detected. Sending {Esc} to close it.")
            Send, {Esc}
            Sleep, 700  ; Allow time for the popup to close.
            Return  ; Stay in HandlingPopups for the next cycle.
        } else {
            ; this text check for the red X on quest icon itself
                Text:="|<>*147$71.zzzs000000Dzzzzk000000TzzzzU000000zzzzz0000001zk0000000000DU0000000000T00000000000y00000000001w00000000003z00000000D00C00000000S00Q00000000w00s00000001s01ky000001w003Vw000003s0073s000007k00C7k00000DU00QDU00000T000s0zs000Dy001k1zk000Tw003U3zU000zs00707z0001zk00C00zzk1zk000Q01zzU3zU000s03zz07z0001k07zy0Dy0003U0Dzw0Tw0007000zzz00000C001zzy00000Q003zzw00000s007zzs00001k00Dzzk00003U001w0T0003z0003s0y0007y0007k1w000Dw000DU3s000T00000zs0000y00001zk0001w00003zU0003s00007z00007k0000Dy0000DU003zzzs007z0007zzzk00Dy000DzzzU00Tw000Tzzz000zs00Tw0Tzs01zk00zs0zzk03zU01zk1zzU07z003zU3zz00Dy007z07zy00Tw03k000Tw0Tw007U000zs0zs00D0001zk1zk00S0003zU3zU0T00000D1zky0y00000S3zVw1w00000w7z3s3s00001sDy7k7k00003kTwDU0000000TzsT00000000zzky00000001zzVw00000003zz3s00000000Dy7k00000000TwDU00000000zsT000000001zky000000003zVw000000007z0000000000Dy0000000000Tw0E"
                if (ok:=FindText(X, Y, 1299-150000, 622-150000, 1299+150000, 622+150000, 0, 0, Text))
                    {
                        DebugLog("No popups detected and anchor stable. Transitioning to NormalOperation.")
                        gameState := "NormalOperation"
            } else {
                DebugLog("Anchor lost during HandlingPopups. Reverting to NotLoggedIn.")
                gameState := "NotLoggedIn"
            }
        }
        Return
    }
    
    ;---------------------------------------------------------
    ; STATE: NormalOperation – Rotate & execute actions.
    ;---------------------------------------------------------
    if (gameState = "NormalOperation") {
        currentAction := actionOrder[currentActionIndex]
        DebugLog("NormalOperation: Attempting action: " . currentAction)
        
        ; Move to the next action in the rotation for the next cycle.
        currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1

        ; Execute only if the action is enabled in user configuration.
        if (!actionConfig[currentAction]) {
            DebugLog("Action " . currentAction . " is disabled. Skipping.")
            Return
        }

        now := A_TickCount
        ; Check if 20 minutes have passed since this action last ran.
        if ((now - lastActionTime[currentAction]) >= actionCooldown) {
            Switch currentAction {
                Case "Quest":
                    DebugLog("Executing Quest action.")
                    ActionQuest()
                Case "PVP":
                    DebugLog("Executing PVP action.")
                    ActionPVP()
                Case "WorldBoss":
                    DebugLog("Executing World Boss action.")
                    ActionWorldBoss()
                Case "Raid":
                    DebugLog("Executing Raid action.")
                    ActionRaid()
                Case "Trials":
                    DebugLog("Executing Trials action.")
                    ActionTrials()
                Case "Expedition":
                    DebugLog("Executing Expedition action.")
                    ActionExpedition()
                Case "Gauntlet":
                    DebugLog("Executing Gauntlet action.")
                    ActionGauntlet()
            }
            lastActionTime[currentAction] := now
        } else {
            DebugLog(currentAction . " skipped - cooldown active.")
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
; Functions – OCR & UI Detection Placeholders
; Replace these with your actual integrated OCR routines.
;─────────────────────────────────────────────;

IsMainScreenAnchorDetected() {
Text:="|<>*159$81.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz7zzzzzzzzzzzzszzzzzzzzzzzzz7zzzzzzzzzzzzw"
if (ok:=FindText(X, Y, 2673-150000, 739-150000, 2673+150000, 739+150000, 0, 0, Text)) ;this text search for any red X corner
    {
        SoundBeep, 800, 300
        Return True
    }
    DebugLog("IsMainScreenAnchorDetected() called (placeholder).")
    return false  ; Replace with your actual detection logic.
}

ArePopupsPresent() {
    Text:="|<>*159$81.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzzs0000zzzzzzzzz00007zzzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzzk000000Tzzzzzy0000003zzzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy000Tzk001zzzzk003zy000Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzk07zzzz00Dzzzy00zzzzs01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz7zzzzzzzzzzzzszzzzzzzzzzzzz7zzzzzzzzzzzzw"
if (ok:=FindText(X, Y, 2673-150000, 739-150000, 2673+150000, 739+150000, 0, 0, Text)) ;same as the one above, searches for any red X corner
    {
        DebugLog("Found an X, pop up present. Closing")
        send {esc}
        return True
    }
    ; This function should return true if any interfering popup (e.g. daily rewards) is detected.
    DebugLog("ArePopupsPresent() reports no popups")
    return false  ; Replace with your actual detection logic.
}

;─────────────────────────────────────────────;
; Action Functions – Replace with your input automation commands.
;─────────────────────────────────────────────;

ActionQuest() {
    DebugLog("ActionQuest() executed (placeholder).")
    Sleep, 500  ; Replace with actual keystroke/mouse routines.
}

ActionPVP() {
    DebugLog("ActionPVP() executed (placeholder).")
    Sleep, 500
}

ActionWorldBoss() {
    DebugLog("ActionWorldBoss() executed (placeholder).")
    Sleep, 500
}

ActionRaid() {
    DebugLog("ActionRaid() executed (placeholder).")
    Sleep, 500
}

ActionTrials() {
    DebugLog("ActionTrials() executed (placeholder).")
    Sleep, 500
}

ActionExpedition() {
    DebugLog("ActionExpedition() executed (placeholder).")
    Sleep, 500
}

ActionGauntlet() {
    DebugLog("ActionGauntlet() executed (placeholder).")
    Sleep, 500
}

;─────────────────────────────────────────────;
; Hotkey: Toggle Bot Activity (F12)
;─────────────────────────────────────────────;
F12::
    if (gameState = "Paused") {
        gameState := "NotLoggedIn"
        DebugLog("Bot resumed via hotkey.")
    } else {
        gameState := "Paused"
        DebugLog("Bot paused via hotkey.")
    }
    Return
