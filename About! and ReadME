# Bit Heroes Bot

**Bit Heroes Bot** (Nickname: ORION) is an automation script designed for Bit Heroes (web). It uses OCR via the FindText.ahk library to detect game UI elements (such as the quest icon and resource warnings) and then rotates through a series of in-game actions. The script is state‐based (waiting for login, handling pop-ups, operating normally, or being paused) and features a custom cooldown mechanism for actions that run out of resources.

> **Note:**  
> This version is currently tuned to work on a 4K resolution with a 150% zoom browser layout. OCR strings and UI coordinates are hard-coded based on that environment. Future improvements may add multi-resolution support.

---

## Features

- **State Machine–Based Flow:**  
  - **NotLoggedIn:** Waits for the quest icon (main screen) to be detected.  
  - **HandlingPopups:** If pop-ups (e.g., with a red “X”) block the UI, the bot automatically clears them by sending `{Esc}` until the quest icon is visible.  
  - **NormalOperation:** The bot rotates through a configured set of actions (e.g. Quest, PVP, WorldBoss, Raid, Trials, Expedition, Gauntlet).  
  - **Paused:** Allows you to pause/resume the bot via a hotkey (F12).

- **Action Rotation & Cooldown:**  
  Each action is subject to a 20‑minute cooldown only when the action returns an "outofresource" status. If an action completes successfully, it is reattempted immediately until a resource shortage is detected.

- **Modular Quest Logic:**  
  The Quest action is broken into several steps:
  1. Click the quest icon if the quest window isn’t already open.
  2. Navigate to the desired dungeon/zone (via left/right arrow clicks and OCR-based zone detection).
  3. Select Heroic difficulty.
  4. Click Accept.
  5. Finally, check for resource shortage. Only if the resource warning is detected does the bot mark the Quest action as “outofresource” and start its cooldown.

- **Debug Logging:**  
  All actions and state transitions are logged both to the debugger (using `OutputDebug`) and to a file (`debug_log.txt`). This aids in troubleshooting and fine-tuning the bot’s operation.

- **Extensible OCR Integration:**  
  The script uses the FindText.ahk library for OCR. All OCR strings are stored as hardcoded patterns for your current layout. Future updates could extend support to more resolutions or dynamic pattern selection.

---

## Requirements

- [AutoHotkey](https://www.autohotkey.com/) (version 1.1.34+ recommended)
- [FindText.ahk](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=17834) – include this library in your project directory.
- A 4K monitor (could be virtualized) with a 150% zoomed browser (for the current configuration)

---

## Installation

1. Clone or download this repository.
2. Ensure that `FindText.ahk` is available in your script’s folder
3. Adjust the OCR strings only if you know what you're doing, and having issues.
4. Run the script with AutoHotkey.

---

## Usage

- **Launch the Bot:**  
  Double-click the script file to launch it. The bot will start in the `NotLoggedIn` state.

- **State Transitions:**  
  The bot monitors the game screen:
  - It waits for the quest icon.
  - If pop-ups block the UI, like daily log in or weekly event rewards, it sends `{Esc}` until the quest icon is visible.
  - Once detected, it rotates through the actions.

- **Quest Action Details:**  
  The Quest logic will:
  1. Open the quest window
  2. Navigate to the desired dungeon/zone
  3. Select the Heroic difficulty.
  4. Click the Accept button
  5. After Accept, check if resources are out (e.g. attempts exhausted)
  
  If resources are insufficient, it returns an “outofresource” state and starts a 20‑minute cooldown for the Quest action, and then will move to the next action that isnt on cooldown.

- **Pause/Resume:**  
  Press `F12` to toggle between Paused and active states.

- **Debug Logs:**  
  Check `debug_log.txt` in your script’s folder to review detailed log messages about state transitions and action statuses.

---

## Contributing

Contributions are welcome! If you have ideas or fixes for enhancing multi-resolution support, additional action logic, or any other feature, please open an issue or submit a pull request.
Discord: VeryInky

---

## License

Check the license file on this repo page for licesning.
---

*Happy coding and good luck automating Bit Heroes!*
