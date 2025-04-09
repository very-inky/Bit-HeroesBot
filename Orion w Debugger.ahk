;CURRENTLY ONLY WORKS ON 4k RESOLUTION AND 150% ZOOM BROWSER
;we can search multiple strings at once. pipe separates, example
;Text:="|<>FFFFFF-0.90$99.000000000000000000Ts7UQ1zs7zkzzU003z0w3UDz0zy7zw001zy7UQDzsTzkzzU00C1kw3Vs03k00C0001kC7UQD00S001k000C1kw3Vs03k00C0001kC7UQD0AS001k000C1kw3VzVXzs0C0001kC7UQDwA7z01k000C1kw3VzVUzy0C0001kC7UQD0001k1k000C7kw3Vs000C0C0001ky7UQD0001k1k000CDkw7Vs000S0C0001zy7zwDzsTzk1k0003zk7y0Dz3zs0C0000Ty0zk1zsTz01k0000000000000000004|<>FFFFFF-0.90$75.0zyC3XzszyDzU71lkQQ0700700sCC3XU0s00s071lkQQ1b00700sCC3XyAzs0s071lkQTlVz0700sCC3Xk00C0s071lkQQ001k700syC3XU00C0s077lkQQ001k700Dy3y0zszs0s4"
;with one string enclosed in quotes, separated by that pipe in the middle, we can search for the same element among different resolutions
;or use variable of current screen size for what text to look for? Gross.
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

    ;---------------------------------------------------------
    ; STATE: NotLoggedIn – Check for the quest icon.
    ;---------------------------------------------------------
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
    
    ;---------------------------------------------------------
    ; STATE: HandlingPopups – Clear pop-ups until quest icon is visible.
    ;---------------------------------------------------------
    if (gameState = "HandlingPopups") {
        DebugLog("HandlingPopups: Attempting to clear pop-ups...")
        popupAttempts := 0
        while (!IsMainScreenAnchorDetected()) {
            Send, {Esc}
            Sleep, 1000  ; Allow UI to update.
            popupAttempts++
            DebugLog("HandlingPopups: Sent {Esc}, attempt #" . popupAttempts)
        }
        DebugLog("HandlingPopups: Quest icon detected. Transitioning to NormalOperation.")
        gameState := "NormalOperation"
        Return
    }
    
    ;---------------------------------------------------------
    ; STATE: NormalOperation – Rotate & execute actions.
    ;---------------------------------------------------------
    if (gameState = "NormalOperation") {
        currentAction := actionOrder[currentActionIndex]
        DebugLog("NormalOperation: Attempting action: " . currentAction)
        
        ; Rotate to the next action for the next cycle.
        currentActionIndex := Mod(currentActionIndex, actionOrder.Length()) + 1

        if (!actionConfig[currentAction]) {
            DebugLog("NormalOperation: Action " . currentAction . " disabled. Skipping.")
            Return
        }

        now := A_TickCount
        if ((now - lastActionTime[currentAction]) >= actionCooldown) {
            Switch currentAction {
                Case "Quest":
                    DebugLog("NormalOperation: Executing Quest action.")
                    ActionQuest()
                Case "PVP":
                    DebugLog("NormalOperation: Executing PVP action.")
                    ActionPVP()
                Case "WorldBoss":
                    DebugLog("NormalOperation: Executing World Boss action.")
                    ActionWorldBoss()
                Case "Raid":
                    DebugLog("NormalOperation: Executing Raid action.")
                    ActionRaid()
                Case "Trials":
                    DebugLog("NormalOperation: Executing Trials action.")
                    ActionTrials()
                Case "Expedition":
                    DebugLog("NormalOperation: Executing Expedition action.")
                    ActionExpedition()
                Case "Gauntlet":
                    DebugLog("NormalOperation: Executing Gauntlet action.")
                    ActionGauntlet()
            }
            lastActionTime[currentAction] := now
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
    ; Assign quest icon pattern to Text (the variable name remains "Text" and its contents are set here).
    Text:="|<>E8D0A6-0.90$59.0zzzzs01zk1zzzzk03zU3kTzk007Us7UzzU00D1kD1zz000S3US3zy000w70w7zw001sC1zk1sD1w0Q3zU3kS3s0s7z07Uw7k1kDy0D1sDU3UTzk03zU3z0zzU07z07y1zz00Dy0Dw3zy00Tw0Ts7zw00zs0zkDzzk0001zUTzzU0003z0zzz00007y1zzy0000Dw3zzw0000Ts7zzzU00DzkDzzz000TzUTzzy000zz0zzzw001zyzzzzs01zzxzzzzk03zzvzzzzU07zzrzzzz00Dzzjzzzy00TzzTzzz0001zyzzzy0003zxzzzw0007zvzzzs000Dzrzzs0zs01zjzzk1zk03zTzzU3zU07yzzz07z00Dxzzy0Dy00Tzzz3zz000zzzy7zy001zzzwDzw003zzzsTzs007zzsDzzk00DXzkTzzU00T7zUzzz000yDz1zzy001wTy3zzw003szzzzzs01s1zzzzzk03k3zzzzzU07U7zzzzz00D0Dz07zzzzzwTy0Dzzzzzszw0Tzzzzzlzs0zzzzzzXzk1zzzzzz7s007zzzzyDk00DzzzzwTU00Tzzzzsz000zzzzzly001zzzzzW0000DzzzU40000Tzzz080000zzzy0E0001zzzw0U0003zzy0100007zzw02"
    if (ok:=FindText(X, Y, 790-150000, 579-150000, 790+150000, 579+150000, 0, 0, Text))
        {
            SoundBeep, 800, 200
        DebugLog("IsMainScreenAnchorDetected: Quest icon detected.")
        Return True
        }
    DebugLog("IsMainScreenAnchorDetected: Quest icon NOT detected.")
    Return False
}

ArePopupsPresent() {
Text:="|<>**50$59.k07w01z00CU08000200F00E000400W00U0008014010000E028020000U04E07y03z008U00404000F000808000W000E0E0014000U0U0028001010004E003zy0008zU000000zk1000000100200000020040000004008000000800E000000E00U000000U01zU0003z0001000040000200008000040000E000080000U0000E000100000U000200001000040000200008000040000E000080000U0000E000100000U00020003z00007y0040000004008000000800E000000E00U000000U01000000103y0000003z4000zzU0028001010004E002020008U00404000F000808000W000E0E0014000U0U002E"
if (ok:=FindText(X, Y, 2177-150000, 680-150000, 2177+150000, 680+150000, 0, 0, Text))
{ ;this text search for any red X corner
        DebugLog("ArePopupsPresent: Popup detected (red X).")
        Return True
    }
    Return False
}

;─────────────────────────────────────────────;
; Action Functions – Replace with your automation commands.
;─────────────────────────────────────────────;
ActionQuest() {
    DebugLog("ActionQuest() executed (placeholder).")
    Sleep, 500
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
        DebugLog("Resumed via hotkey. Resetting state to NotLoggedIn.")
    } else {
        previousState := gameState
        gameState := "Paused"
        DebugLog("Paused via hotkey. Previous state: " . previousState)
    }
    Return
