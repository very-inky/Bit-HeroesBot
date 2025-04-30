SetBatchLines, -1
#SingleInstance, Force
#Persistent
#Include Helpers.ahk
#Include Debug.ahk
#Include FindText.ahk
#Include Patterns.ahk
#Include Quest_Logic.ahk
#Include PVP_Logic.ahk
#Include Raid_Logic.ahk
#Include WorldBoss_Logic.ahk

;Soundbeep, 500, 600


;——— Build the Bot “context” object —————————————————————————————
global Bot := {}

; 1) Action configurations & rotation
Bot.actionConfig := { Quest: false, PVP: false, WorldBoss: true
                  , Raid: false, Trials: false, Expedition: false, Gauntlet: false }
Bot.actionOrder := ["Quest","PVP","WorldBoss","Raid","Trials","Expedition","Gauntlet"]
Bot.currentActionIndex := 3

; 2) Questing configs
; --- Define the specific Zone PATTERNS and Dungeon NAMES you want to run ---
Bot.desiredZones       := [ Patterns.Zone[3], Patterns.Zone[2] ] ; Use the PATTERN for Zone 3 from Patterns.ahk
Bot.desiredDungeons    := [ "Dungeon2", "Dungeon1" ]       ;  Not all zones have 3 dungeons!
; --- If running multiple configurations, add more pairs!

Bot.currentSelectionIndex := 1

; 3) PVP configs
Bot.PvpTicketChoice   := 5    ; 1–5
Bot.PvpOpponentChoice := 2    ; 1–4

Bot.Raid := {}
Bot.Raid.Conf := {}
; 4) Raid configs
Bot.Raid.Conf.List := ["Raid8"] ; List of raids to run. (MATCH THESE TO Patterns.Raid.RaidName
Bot.Raid.Conf.Count := 0 ; Number of raids to run, (0 for infinite, run raids till out of resources.)
Bot.Raid.Conf.Difficulty := "Heroic" ; Raid difficulty (Normal, Hard, Heroic)
Bot.Raid.Conf.CurrentIndex := 1 ; Tracks which raid in the list to run next
Bot.Raid.Conf.CompletedCount := 0 ; Tracks how many raids have been completed in this session/cycle

; 5) World Boss configs
Bot.WorldBoss := {}
Bot.WorldBoss.Conf := {}
; --- List of configs for specifying worldboss name and tier ---
; --- Tier can be a specific number OR "HighestAvailable" OR "LowestAvailable" Check ValidTiers section below for which tiers are valid for each WB
; Initialize as an empty array first
Bot.WorldBoss.Conf.List := []
; Add each configuration object separately
Bot.WorldBoss.Conf.List.Push({ Name: "Orlag Clan", Tier: 7 })
Bot.WorldBoss.Conf.List.Push({ Name: "Netherworld", Tier: 7 })
;Bot.WorldBoss.Conf.List.Push({ Name: "Netherworld", Tier: "HighestAvailable" }) ; Run Netherworld Highest Available
;Bot.WorldBoss.Conf.List.Push({ Name: "Orlag Clan", Tier: "LowestAvailable" })   ; Run Orlag Clan Lowest Available
;Bot.WorldBoss.Conf.List.Push({ Name: "Titans Attack", Tier: 11 })           ; Run Titans Attack Tier 11 (if available)
;Bot.WorldBoss.Conf.List.Push({ Name: "Project Goodall", Tier: 99 })         ; Example of an invalid tier for testing
Bot.WorldBoss.Conf.CurrentIndex := 1 ; Tracks which WB config in the list to run next, shouldnt need to change this, multiple configs are handled in the monitor function and ran automatically
Bot.WorldBoss.Conf.Difficulty := "Heroic" ; Add Difficulty setting (Normal, Hard, Heroic)
; Bot.WorldBoss.Conf.TierPreference := "HighestAvailable" ; This is now part of the List object

; --- ADDED: Full UI Order of World Bosses (Adjust if necessary!) ---
Bot.WorldBoss.UiOrder := [ "Orlag Clan"
                         , "Netherworld"
                         , "Melvin Factory"
                         , "Extermination"
                         , "Brimstone Syndicate"
                         , "Titans Attack"
                         , "The Ignited Abyss"
                         , "Project Goodall" ]

; 6) OCR patterns
Bot.ocr := Patterns       ; so we can point Bot.ocr with the Patterns for easier handling.
; --- Add World Boss Tier Mapping to OCR patterns ---
Bot.ocr.WorldBossValidTiers := { "Orlag Clan":          [12, 11, 10, 9, 8, 7, 6, 5, 4, 3] ; Highest to lowest
                                , "Netherworld":         [13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3]
                                , "Melvin Factory":      [11, 10]
                                , "Extermination":       [11, 10]
                                , "Brimstone Syndicate": [12, 11]
                                , "Titans Attack":       [14, 13, 12, 11]
                                , "The Ignited Abyss":   [14, 13]
                                , "Project Goodall":     [14, 7] }
; --- Placeholder patterns for WB elements are now in Patterns.ahk ---

; 7) State & cooldown tracking
Bot.gameState     := "NotLoggedIn"
Bot.actionCooldown := 1200000  ; 20 min in ms
DebugLog("=== BOT LOADED; initial gameState=" Bot.gameState)
Bot.lastActionTime := {}
for idx, act in Bot.actionOrder
    Bot.lastActionTime[act] := 0

;———————————————————————————————————————————————————————————————
; Kick off the main loop
SetTimer, BotMain, 1000
return

;———————————————————————————————————————————————————————————————
BotMain:
    global Bot

    if (Bot.gameState = "Paused")
        return

    ; === NotLoggedIn ===
    if (Bot.gameState = "NotLoggedIn") {
        DebugLog("NotLoggedIn: looking for quest icon")
        if (IsMainScreenAnchor()) {
            Bot.gameState := "NormalOperation"
            DebugLog("→ NormalOperation")
        } else {
            AttemptReconnect()
            Bot.gameState := "HandlingPopups"
            ; No need to DebugLog state change here, HandlingPopups will log entry
        }
        return
    }

    ; === HandlingPopups ===
    if (Bot.gameState = "HandlingPopups") {
        DebugLog("HandlingPopups: clearing pop‑ups")
        popupAttempts := 0
        ; Loop until main screen anchor is found OR attempts run out
        while (!IsMainScreenAnchor() and popupAttempts < 7) {
            if FindText(X, Y, 610, 490, 2515, 1649, 0, 0, Bot.ocr.Popup)
                FindText().Click(X, Y, "L")
            if FindText(X, Y, 610, 490, 2515, 1649, 0, 0, Bot.ocr.PopupYes)
                FindText().Click(X, Y, "L")
            Send, {Esc}
            Sleep, 500
            popupAttempts++
            if (IsDisconnected()) {
                AttemptReconnect() ; This function should have its own logs
                Sleep, 2000
            }
            ; Check anchor again inside loop for faster exit if Esc worked quickly
            if (IsMainScreenAnchor()) {
                DebugLog("HandlingPopups: Main screen anchor found during popup clearing.")
                break ; Exit the while loop early
            }
        }
        ; After loop, determine next state based on whether anchor was found
        finalAnchorCheck := IsMainScreenAnchor()
        nextState := finalAnchorCheck ? "NormalOperation" : "NotLoggedIn"
        DebugLog("HandlingPopups: Finished attempts. Anchor found: " . (finalAnchorCheck ? "Yes" : "No") . ". → " . nextState)
        Bot.gameState := nextState
        return
    }

    ; === NormalOperation ===
    if (Bot.gameState = "NormalOperation") {
        current := Bot.actionOrder[Bot.currentActionIndex]
        now := A_TickCount

        ; skip if disabled in config
        if (! Bot.actionConfig[current]) {
            DebugLog("NormalOperation: Skipping " . current . " (disabled in config)")
            Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
            return
        }

        ; cooldown check
        if ((now - Bot.lastActionTime[current]) >= Bot.actionCooldown) {
            DebugLog("NormalOperation: Running " . current . " (cooldown ready)")
            result := ""

            ; --- Raid Count Check (Specific for Raid) ---
            if (current = "Raid" && Bot.Raid.Conf.Count > 0 && Bot.Raid.Conf.CompletedCount >= Bot.Raid.Conf.Count) {
                 DebugLog("NormalOperation: Skipping Raid - Target count (" . Bot.Raid.Conf.Count . ") already reached.")
                 Bot.lastActionTime[current] := now ; Update cooldown time even if skipped due to count
                 Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
                 return ; Skip to next action
            }
            ; --- End Raid Count Check ---

            Switch current
            {
                Case "Quest":      result := ActionQuest()
                Case "PVP":        result := ActionPVP()
                Case "WorldBoss":  result := ActionWorldBoss()
                Case "Raid":       result := ActionRaid()
                Case "Trials":     result := ActionTrials()
                Case "Expedition": result := ActionExpedition()
                Case "Gauntlet":   result := ActionGauntlet()
                Default:
                    DebugLog("NormalOperation: ERROR - Unknown action '" . current . "'")
                    result := "error_unknown_action"
            }

            ; --- Process action result ---
            DebugLog("BotMain: Action '" . current . "' returned: '" . result . "'") ; Log result

            if (result = "started") {
                Bot.gameState := "ActionRunning"
                DebugLog("BotMain: " . current . " → ActionRunning")
            }
            else if (result = "outofresource") {
                DebugLog("BotMain: '" . current . "' reported 'outofresource'. Setting cooldown and returning to HandlingPopups state.")
                ; No need to call ClosePopup() here - HandlingPopups state will send Esc.

                ; Set the cooldown for the action that failed
                Bot.lastActionTime[current] := now
                DebugLog("BotMain: Cooldown set for " . current)
                Loop, 4
                {
                    Send, {esc}
                    Sleep 600
                }
                ; --- Change state to force UI reset via HandlingPopups logic ---
                Bot.gameState := "HandlingPopups"
                DebugLog("BotMain: State changed to HandlingPopups to ensure return to main screen.")

                ; DO NOT advance Bot.currentActionIndex here. Let HandlingPopups resolve first.
            }
            else if (result = "disconnected") {
                Bot.gameState := "NotLoggedIn"
                ; No DebugLog needed here, NotLoggedIn state handles its entry log
            }
            else if (current = "PVP" and result = "success") { ; Note: PVP returns "started", not "success" now
                ; loop PVP immediately - do nothing here, next loop iteration will handle it
                 DebugLog("BotMain: PVP returned success, looping PVP immediately.")
            }
            else {
                ; Default case for other results ("retry", "success" for non-PVP/non-Raid, "error", etc.)
                ; Start cooldown & advance to next action
                 DebugLog("BotMain: Action '" . current . "' finished with result '" . result . "'. Starting cooldown and advancing.")
                Bot.lastActionTime[current] := now
                Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
            }
        } else {
            ; skip due to cooldown
            DebugLog("NormalOperation: Skipping " . current . " (on cooldown)")
            Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
        }
        return
    }

  ; === ActionRunning ===
    if (Bot.gameState = "ActionRunning") {
        current := Bot.actionOrder[Bot.currentActionIndex]
        DebugLog("ActionRunning: monitoring " . current)
        monitorResult := ""

        ; Call the appropriate monitoring function based on the current action
        Switch current
        {
            Case "Quest": monitorResult := MonitorQuestProgress()
            Case "PVP":   monitorResult := MonitorPVPProgress()
            Case "Raid":  monitorResult := MonitorRaidProgress()
            Case "WorldBoss": monitorResult := MonitorWorldBossProgress()
            Default:
                ; No monitor needed for simple actions (Trials, Expedition, Gauntlet)
                DebugLog("ActionRunning: No monitor function for '" . current . "'. Returning to NormalOperation.")
                Bot.gameState := "NormalOperation"
                Bot.lastActionTime[current] := A_TickCount
                Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
                DebugLog("ActionRunning: Cooldown set for " . current . ", index advanced.")
                return
        }

        DebugLog("ActionRunning: Monitor function for '" . current . "' returned: '" . monitorResult . "'")

        ; --- Process monitor result ---
        if (monitorResult = "pvp_completed_continue") {
            DebugLog("ActionRunning: PVP monitor reported completion. Returning to NormalOperation.")
            Bot.gameState := "NormalOperation"
            return
        }
        ; --- CORRECTED: World Boss Completion Handling ---
        else if (monitorResult = "worldboss_completed") {
            DebugLog("ActionRunning: World Boss monitor reported completion for current config.")
            Bot.WorldBoss.Conf.CurrentIndex += 1
            if (Bot.WorldBoss.Conf.CurrentIndex > Bot.WorldBoss.Conf.List.MaxIndex()) {
                Bot.WorldBoss.Conf.CurrentIndex := 1 ; Wrap around
                DebugLog("ActionRunning: Wrapped WB config index back to 1.")
            }
            DebugLog("ActionRunning: Advanced WB config index to " . Bot.WorldBoss.Conf.CurrentIndex)

            ; --- REMOVED Cooldown setting and Main Action Index advancement ---
            ; Bot.lastActionTime[current] := A_TickCount ; Set cooldown for WorldBoss action type
            ; Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1 ; Advance main action index
            ; DebugLog("ActionRunning: Cooldown set for WorldBoss, main action index advanced.")

            ; Go back via popups to ensure clean state before starting next WB config
            Bot.gameState := "HandlingPopups"
            DebugLog("ActionRunning: State changed to HandlingPopups to attempt next WB config.")
            return
        }
        ; --- END CORRECTION ---
        else if (monitorResult = "raid_completed" or monitorResult = "raid_completed_next") { ; Check for EITHER raid complete result
            DebugLog("ActionRunning: Raid monitor reported completion.")
            Bot.Raid.Conf.CompletedCount += 1
            Bot.Raid.Conf.CurrentIndex += 1
            if (Bot.Raid.Conf.CurrentIndex > Bot.Raid.Conf.List.MaxIndex()) { ; Use MaxIndex here
                Bot.Raid.Conf.CurrentIndex := 1 ; Wrap around
            }
            DebugLog("ActionRunning: Raid count incremented to " . Bot.Raid.Conf.CompletedCount . ". Next Raid index: " . Bot.Raid.Conf.CurrentIndex)

            ; Check if target count reached (only if count > 0)
            if (Bot.Raid.Conf.Count > 0 && Bot.Raid.Conf.CompletedCount >= Bot.Raid.Conf.Count) {
                DebugLog("ActionRunning: Raid target count (" . Bot.Raid.Conf.Count . ") reached.")
                Bot.lastActionTime[current] := A_TickCount ; Set cooldown
                Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1 ; Advance past Raid
                DebugLog("ActionRunning: Cooldown set for Raid, index advanced.")
                Bot.gameState := "NormalOperation" ; Return to NormalOperation
                DebugLog("ActionRunning: Returning to NormalOperation.")
                return ; !!! Important: Return after handling state change
            } else {
                DebugLog("ActionRunning: Raid target count not reached or infinite. Cooldown NOT set, index NOT advanced (will attempt next raid).")
                Bot.gameState := "HandlingPopups" ; Go back via popups to restart Raid action
                DebugLog("ActionRunning: State changed to HandlingPopups to ensure return to main screen before next raid attempt.")
                return ; !!! Important: Return after handling state change
            }

        }
        else if (monitorResult = "raid_rerun") { ; Handle specific rerun case for single-config raid
             DebugLog("ActionRunning: Monitor reported 'raid_rerun'. Raid is restarting. Remaining in ActionRunning.")
             ; Do nothing, stay in ActionRunning state
             return
        }
        else if (monitorResult = "outofresource") {
            DebugLog("ActionRunning: Monitor reported 'outofresource' for " . current . ".")
            Bot.lastActionTime[current] := A_TickCount ; Set cooldown
            Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1 ; Advance past current action
            Bot.gameState := "HandlingPopups" ; Go handle popups first
            DebugLog("ActionRunning: Cooldown set for " . current . ", index advanced. State changed to HandlingPopups.")
            return
        }
        else if (monitorResult = "disconnected" or monitorResult = "player_dead") {
             DebugLog("ActionRunning: Monitor reported '" . monitorResult . "'. State already changed by monitor function.")
             ; Monitor function should have already changed Bot.gameState to NotLoggedIn
             return
         }
        else if (monitorResult = "error") {
             DebugLog("ActionRunning: Monitor reported 'error'. Setting cooldown and advancing past " . current . ".")
             Bot.lastActionTime[current] := A_TickCount
             Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
             Bot.gameState := "HandlingPopups" ; Go to popups after error for safety
             DebugLog("ActionRunning: State changed to HandlingPopups after error.")
             return
        }
        else if (monitorResult = "start_next_config") { ; Quest specific
            DebugLog("ActionRunning: Monitor reported quest config complete. Advancing config index.")
            Bot.currentSelectionIndex += 1
            if (Bot.currentSelectionIndex > Bot.desiredZones.MaxIndex()) {
                DebugLog("ActionRunning: All quest configs completed. Resetting config index.")
                Bot.currentSelectionIndex := 1
                Bot.lastActionTime[current] := A_TickCount
                Bot.currentActionIndex := Mod(Bot.currentActionIndex, Bot.actionOrder.Length()) + 1
                DebugLog("ActionRunning: Cooldown set for Quest, index advanced.")
                Bot.gameState := "NormalOperation"
            } else {
                DebugLog("ActionRunning: Moving to next quest config (Index: " . Bot.currentSelectionIndex . "). Returning to NormalOperation to start it.")
                Bot.gameState := "NormalOperation"
            }
            return
        }
        else if (monitorResult = "rerun") { ; Specific to single-config Quest monitor
             DebugLog("ActionRunning: Monitor reported 'rerun'. Quest is restarting. Remaining in ActionRunning.")
             return
         }

        ; Default case includes "in_progress" - stay in ActionRunning state
        ; No action needed, just wait for the next timer tick
        return
    }
ActionTrials()      {
    global Bot
    DebugLog("ActionTrials: --- Entered function ---")
    ; INCOMPLETE, THIS IS A PLACEHOLDER FOR YOUR LOGIC
    if (CheckOutOfResources()) 
        return "outofresource"
    DebugLog("ActionTrials: --- Success! Returning 'success'. ---")
    return "success"
                    }


ActionExpedition()  {
    global Bot
    DebugLog("ActionExpedition: --- Entered function ---")
    ; INCOMPLETE, THIS IS A PLACEHOLDER FOR YOUR LOGIC
    if (CheckOutOfResources())
        return "outofresource"
    DebugLog("ActionExpedition: --- Success! Returning 'success'. ---")
    return "success"
                    }


ActionGauntlet()    {
    global Bot
    DebugLog("ActionGauntlet: --- Entered function ---")
    ; INCOMPLETE, THIS IS A PLACEHOLDER FOR YOUR LOGIC
    if (CheckOutOfResources())
        return "outofresource"
    DebugLog("ActionGauntlet: --- Success! Returning 'success'. ---")
    return "success"
}

;────────────────────────────────────────────────────────────────

F12::
{
    global Bot

    if (A_IsPaused) {
        ; --- RESUME ---
        Pause, Off, 1
        
        if (Bot.previousState != "") {
            Bot.gameState := Bot.previousState
            DebugLog("Resumed via hotkey. Restoring previous state: " . Bot.gameState)
            Bot.previousState := ""
        } else {
            Bot.gameState := "NotLoggedIn"
            DebugLog("Resumed via hotkey. No previous state; resetting to NotLoggedIn.")
        }
    }
    else {
        ; --- PAUSE ---
        Bot.previousState := Bot.gameState
        Bot.gameState := "Paused"
        DebugLog("Paused via hotkey. Previous state: " . Bot.previousState)

        Pause, On, 1
    }
    return
}