# Orion Bit Heroes Automation Script (v0.2.5 Pre-Release)

## Overview

Orion is an automation script for the web version of Bit Heroes, built using AutoHotkey v1. It leverages the FindText.ahk library to identify game elements and automatically cycles through configured in-game actions like Quests, PVP, Raids, and World Bosses.

The script utilizes a state based approach for operation and includes features like automatic popup and dialogue handling, multi-config action cycling, and a pause system.

**Note:** This version is currently tuned for a **4K resolution** monitor with the browser zoomed to **150%**. OCR patterns (`Patterns.ahk`) and UI coordinates are based on this layout. Adjustments will be required for different resolutions or zoom levels.

## Features

* **State Machine–Based Flow:** Ensures the bot acts appropriately based on the game's current state:
    * `NotLoggedIn`: Waits for the main game screen (specifically the quest icon ) to appear before proceeding. Handles reconnect attempts if disconnected.
    * `HandlingPopups`: Automatically dismisses common pop-ups (like daily rewards, warnings) by clicking known patterns or sending `{Esc}` until the main screen is clear
    * `NormalOperation`: Selects the next available action from the configured rotation (`actionOrder`) based on readiness and cooldowns.
    * `ActionRunning`: Monitors the progress of long-running actions (Quest, PVP, Raid, World Boss), handling completion, errors, or interruptions.
    * `Paused`: A responsive paused state, toggled by `F12`.

* **Modular Structure:**
    * Core logic is organized into separate include files for better maintainability:
        * `Helpers.ahk`: Common utility functions (checking resources, handling dialogue, clicking arrows, etc.).
        * `Quest_Logic.ahk`: Handles Quest initiation and monitoring.
        * `PVP_Logic.ahk`: Handles PVP initiation and monitoring.
        * `Raid_Logic.ahk`: Handles Raid initiation and monitoring.
        * `WorldBoss_Logic.ahk`: Handles World Boss initiation and monitoring.
        * `Patterns.ahk`: Contains all OCR patterns used by FindText
        * `Debug.ahk`: Provides detailed logging functionality

* **Action Rotation & Cooldown:**
    * Rotates through enabled actions specified in `Bot.actionOrder` (e.g., "Quest", "PVP", "WorldBoss", "Raid", etc.)
    * Actions are skipped if disabled in `Bot.actionConfig`
    * Raid supports so many runs before manually moving the index. Specify how many raids to run this cycle or 0 for infinite until out of shards.
    * An action generally goes on cooldown (default: 20 minutes) if it fails due to lack of resources
    

* **Multi-Action Monitoring (`ActionRunning` state):**
    * **Quest (`MonitorQuestProgress`):** Handles completion (rerun or exit to town for next config, disconnects, player death, and dialogue popups].
    * **PVP (`MonitorPVPProgress`):** Handles completion (exits to town to allow looping ), disconnects, and player death
    * **Raid (`MonitorRaidProgress`):** Handles completion (rerun or exit/accept for next config), disconnects, player death, and dialogue popups.
    * **World Boss (`MonitorWorldBossProgress`):** Handles completion (clicks Regroup, then either reruns the *same* boss if only one is configured, or signals completion to allow `BotMain` to advance to the next configured WB), disconnect, player death, and dialogue popups. (wip)

* **Multi-Stage Quest Logic (`ActionQuest`):**
    * Initiation: Opens the quest window, navigates to the configured zone and dungeon, selects Heroic difficulty, clicks Accept, checks for resource issues.
    * Handles single or multiple quest configurations defined in `Bot.desiredZones` and `Bot.desiredDungeons`.

* **PVP Logic (`ActionPVP`):**
    * Navigates the PVP menu, ensures the correct number of tickets is selected, selects the configured opponent, accepts the match, and checks for resource issues.

* **Raid Logic (`ActionRaid`):**
    * Navigates the Raid menu, selects the configured raid(s) and difficulty, handles pre-raid dialogue, starts the raid, and checks for resource issues. Supports single or multiple raid configurations.

* **World Boss Logic (`ActionWorldBoss`):**
    * Navigates the World Boss menu, selects the configured boss, tier, and difficulty.
    * Supports specific tier numbers or `"HighestAvailable"` / `"LowestAvailable"` selection (logic implemented in `SelectWorldBossTier`).
    * Ensures the "Private Lobby" toggle is enabled
    * Handles the final summon sequence, including the "Team not full" warning.
    * Checks for resource issues before starting and on rerun
    * Supports running multiple different World Boss configurations sequentially.

* **Responsive Pause/Resume (`F12` Hotkey):**
    * Uses AutoHotkey's built-in `Pause` command for quick interruption, even during `Sleep`.
    * Reliably resumes and restores the bot's previous state. Not recommended to manually play the game with the bot paused with your intent to resume, as it will get desync'd

* **Automatic Dialogue Handling (`HandleInProgressDialogue`):**
    * Actively checks for and dismisses in-game dialogue boxes (currently identifies a specific "yellow arrow" pattern) by sending `{Esc}`.

* **Detailed Debug Logging:**
    * Provides extensive logging via `Debug.ahk` to both the debugger (e.g., DebugView) and a file (`debug_log.txt`).
    * See exactly what is going on in real time, what config option is being selected, what functions are doing and communicating
    * Logs state transitions, action attempts, cooldown status, function results, and OCR findings.

## Requirements

* AutoHotkey v1 (latest stable recommended)
* `FindText.ahk` library in same directory as Orion
* The following script files in the same directory
    * `Orion V 0.2.5 (Early-Blueprint).ahk` (or your main script file)
    * `Helpers.ahk`
    * `Quest_Logic.ahk`
    * `PVP_Logic.ahk`
    * `Raid_Logic.ahk`
    * `WorldBoss_Logic.ahk`
    * `Patterns.ahk`
    * `Debug.ahk`
* Environment matching the current OCR tuning (4K resolution, 150% browser zoom) OR ability to recapture OCR strings/coordinates in `Patterns.ahk`.

## Usage

1.  **Configure:** Edit the main script file (`Orion V 0.2.5 (Early-Blueprint).ahk`) to:
    * Enable/disable actions in `Bot.actionConfig`.
    * Set the desired `Bot.actionOrder`.
    * Configure specific settings for Quest, PVP, Raid, and World Boss within the `Bot` object (e.g., `Bot.desiredZones`, `Bot.PvpTicketChoice`, `Bot.Raid.Conf.List`, `Bot.WorldBoss.Conf.List` etc.).
2.  **Launch:** Run the main `.ahk` script file. The bot starts in the `NotLoggedIn` state.
3.  **Operation:** The bot waits for the game's main screen, clears pop-ups, and then rotates through enabled actions based on cooldowns and configuration.
4.  **Pause/Resume:** Press `F12` to toggle pause.
5.  **Debug:** Check `debug_log.txt` for detailed operational history.
