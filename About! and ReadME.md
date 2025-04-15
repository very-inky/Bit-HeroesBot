===========================================
Bit Heroes Bot (Nickname: ORION)
===========================================

Orion is an automation script designed for the web version of Bit Heroes. It uses OCR (via the FindText.ahk library) to identify game elements and automatically cycles through configured in-game actions.

The script operates using a state machine and includes features like automatic dialogue handling, multi-quest cycling, and a responsive pause system.

Note:
-----
This version is currently tuned for a **4K resolution** monitor with the browser zoomed to **150%**. OCR patterns and UI coordinates are based on this layout. Adjustments would be needed for different resolutions or zoom levels.

Features:
---------

* **State Machine–Based Flow:** Ensures the bot acts appropriately based on the game's current state:
    * `NotLoggedIn`: Waits patiently for the main game screen (specifically the quest icon) to appear.
    * `HandlingPopups`: Automatically dismisses common pop-ups (like daily rewards) by sending `{Esc}` until the main screen is clear.
    * `NormalOperation`: Selects the next available action from the configured rotation (`actionOrder`) based on readiness and cooldowns.
    * `ActionRunning`: Monitors the progress of a long-running action (currently Quest), handling completion, errors, or interruptions.
    * `Paused`: A responsive paused state, toggled by F12.

* **Responsive Pause/Resume (F12 Hotkey):**
    * Pressing F12 now uses AutoHotkey's built-in `Pause` command targeting the main script thread (`Pause, On/Off, 1`).
    * This allows the pause to interrupt the script much more quickly, even during `Sleep` commands.
    * Resuming via F12 is reliable and avoids the hangs experienced with previous methods.

* **Automatic Dialogue Handling:**
    * Includes the `HandleInProgressDialogue` function which actively checks for in-game dialogue boxes during quests (currently identifies a specific "yellow arrow" pattern).
    * If dialogue is detected, it automatically sends `{Esc}` to attempt dismissal, allowing the bot to continue without getting stuck.
    * Includes fixes to reduce potential false dialogue detection and prevent interference with the game's autopilot feature after dismissal.

* **Action Rotation & Cooldown:**
    * Rotates through enabled actions specified in `actionOrder` (`Quest`, `PVP`, etc.).
    * An action only goes on cooldown (currently 20 minutes) if it fails specifically due to lack of resources (e.g., returning `"outofresource"`).
    * Otherwise, after an action attempt (whether successful, failed with retry, or started a long process), the bot moves on to check the *next* action in the `actionOrder` sequence on the following cycle.

* **Multi-Stage Quest Logic (`ActionQuest` & `MonitorActionProgress`):**
    * **Initiation:** Opens the quest window (sending `{Esc}` first if it fails to open), navigates to the configured zone and dungeon (using OCR for zone name and dungeon pattern matching), selects Heroic difficulty, clicks Accept, and checks for immediate resource issues.
    * **Monitoring:** While a quest is running (`ActionRunning` state):
        * Checks for completion (using `IsActionComplete`)
        * Checks for disconnection or player death (placeholders for future implementation).
        * Checks for and handles in-progress dialogue via `HandleInProgressDialogue`.
    * **Completion Handling:**
        * If only one quest is configured (`desiredZones.Length() = 1`), attempts to `ClickRerun` and checks for resource issues *after* clicking.
        * If multiple quests are configured, attempts to exit the completion screen via `ClickTownOnCompletionScreen` to allow cycling to the next configured quest.
        * Returns specific statuses (`rerun`, `outofresource`, `start_next_config`, `error`, `in_progress`) back to `BotMain` for appropriate handling.

* **Detailed Debug Logging:**
    * Provides extensive logging to both the debugger (use DebugView, you can add a filter for Orion to only see those events) and a file (`debug_log.txt`).
    * Logs clearly indicate state transitions, action attempts, cooldown status, results of checks within `MonitorActionProgress`, and reasons for function returns. Logs include the " Orion" suffix for easier filtering.

* **Extensible OCR Integration:**
    * Relies on the included `FindText.ahk` library. OCR patterns are currently hardcoded but could be adapted or expanded.

Requirements:
-------------
* AutoHotkey (latest stable of AHK V1)
* `FindText.ahk` library (included or placed in AHK's Lib folder)
* Environment matching the current OCR tuning (4K resolution, 150% browser zoom) OR ability to recapture OCR strings/coordinates. 4k monitor could likely be virtualized through a VM or using Nvidia 

Usage:
------
1.  **Launch:** Run the `.ahk` script file. Bot starts in `NotLoggedIn` state.
2.  **Operation:** Waits for the game's main screen. Clears pop-ups. Rotates through enabled actions based on cooldowns. Executes quest steps or placeholder actions. Monitors running quests.
3.  **Pause/Resume:** Press F12 to toggle pause.
4.  **Debug:** Check `debug_log.txt` for detailed operational history.

Contributing / License / Contact:
