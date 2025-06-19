# Developer Notes

## Current State of the Project

### Core Functionality
- The bot uses OpenCV for image recognition and template matching
- Coroutines are implemented for parallel processing in two key areas:
  - Zone detection in QuestAction (using `--morethreads` flag)
  - Template matching in Bot (using `--opencvthreads` flag)
- The bot can navigate through zones, select dungeons, and run quests
- Resource management system with cooldowns is implemented

### Recent Fixes

#### OpenCV Template Matching Improvements
- **Color Channel Alignment Fix**:
  - Implemented a new `bufferedImageToBgrMat` method in Bot.kt that properly converts screen captures to the BGR format expected by OpenCV
  - This addresses a fundamental color channel mismatch that was limiting match confidence scores to around 0.81 even for perfect matches
  - The new method creates a BufferedImage specifically in the BGR format (TYPE_3BYTE_BGR), transfers the image data, and creates a Mat with the correct format (CV_8UC3)
  - Updated `captureScreen` and `captureRegion` methods to use the new conversion function
  - Marked the old `bufferedImageToMat` method as deprecated
  - This change significantly increases template matching accuracy, with confidence scores potentially approaching 0.95-0.99 for perfect matches

- **Scale Handling Optimization**:
  - Added epsilon checks (using a small value of 1e-9) to prevent unnecessary resizing of templates when the scale is effectively 1.0
  - This eliminates resizing artifacts and improves matching accuracy for unscaled templates
  - Implemented in all three template matching methods:
    - `findTemplateMultiScale` (lines 427-442)
    - `findTemplateDetailedSequential` (lines 660-674)
    - `findTemplateDetailedWithCoroutines` (lines 852-862)
  - The epsilon check ensures that when a scale is very close to 1.0, the original template is used directly without resizing

- **Other Template Matching Improvements**:
  - Fixed an oversight in Bot.kt that now allows ALL findtemplate checks to use coroutines if the user has `--opencvthreads` enabled
  - This improves performance for all template matching operations throughout the application
  - Added shape-based template matching option (`--shapematching` flag) that uses TM_CCORR_NORMED instead of TM_CCOEFF_NORMED
  - Added grayscale template matching option (`--grayscale` flag) that converts images to grayscale before matching
  - Added verbose template matching option (`--verbose` flag) that provides detailed information about template matching operations
  - Reverted from robot.createMultiResolutionScreenCapture to robot.createScreenCapture for better compatibility

#### Other Improvements
- Made action name handling case-insensitive throughout the codebase, improving user experience by allowing any capitalization of action names (e.g., "pvp", "PvP", "PVP")

### Current Issues
- In QuestAction.kt, the bot processes the outofresource check too quickly for the UI to update
  - This causes the bot to potentially miss the out of resources popup
  - A delay needs to be added between clicking the accept button and checking for the out of resources message

### Recent Implementations

1. **YAML-based Configuration System**
   - Implemented a YAML-based configuration system for storing and managing bot configurations
   - Created `YamlUtils` class for serializing and deserializing configuration objects
   - Added YAML file operations to `ConfigManager` for loading and saving configurations
   - Implemented `ConfigCLI` class for command-line management of configurations
   - Added Jackson library dependencies for YAML support
   - Configured polymorphic type handling for ActionConfig sealed class hierarchy
   - Created directory structure for storing configuration files
   - Added documentation in configs/README.md
   - Implemented automatic creation of default configurations if none exist
   - Added command-line flag `--config` for launching the configuration CLI
   - Expected behavior:
     - Users can create, edit, and manage bot configurations through the CLI
     - Configurations are saved to YAML files and can be edited directly
     - The bot loads configurations from YAML files at startup
     - Default configurations are created automatically if none exist
     - The active character and configuration are persisted between runs

2. **State Machine System**
   - Implemented a state machine to manage bot states and transitions
   - Created a `StateMachine` class that handles state transitions and executes state handlers
   - Defined a `BotState` sealed class hierarchy with all possible bot states:
     - `Idle`: Bot is waiting for an action to be started
     - `Starting`: Bot is in the process of starting an action
     - `Running`: Bot is actively running an action
     - `Rerunning`: Bot is rerunning the current action
     - `OutOfResources`: Bot has detected that it's out of resources
     - `PlayerDead`: Bot has detected that the player character has died
     - `Disconnected`: Bot has detected a disconnection from the game
     - `Reconnecting`: Bot is attempting to reconnect to the game
     - `Completed`: Action has been completed successfully
     - `Failed`: Action has failed
   - Created an `ActionData` class to encapsulate action information and pass data between state handlers
   - Added state handlers for each state that perform actions specific to that state
   - Implemented game verification in the Starting state handler
   - Implemented disconnect detection and handling in the monitoring loop
   - Refactored the ActionManager to use the state machine for action execution
   - This makes the code more maintainable, extensible, and easier to reason about
   - Expected behavior:
     - Bot verifies that the game is properly loaded before executing actions
     - Bot transitions between states based on game conditions
     - Bot handles disconnections and attempts to reconnect automatically
     - Bot properly tracks action run counts and resource availability
     - Bot provides detailed logging of state transitions and actions

2. **Game Verification**
   - Added game verification in the Starting state handler
   - Verifies that the game is properly loaded before executing actions
   - Checks for the main screen anchor template to confirm the game is loaded
   - Detects and handles popups that might be blocking the main screen
   - Retries verification multiple times before failing
   - Transitions to Failed state if game verification fails
   - Expected behavior:
     - Bot checks for main screen anchor before executing actions
     - Bot attempts to close popups if main screen anchor is not found
     - Bot retries verification up to 5 times before failing
     - Bot does not execute actions if game verification fails
     - Bot logs detailed information about the verification process

3. **Disconnect Detection and Handling**
   - Added disconnect detection in the monitoring loop
   - Detects disconnections by looking for the reconnect button
   - Performs a second check to confirm disconnection
   - Automatically attempts to reconnect when a disconnection is detected
   - Verifies successful reconnection by checking for the main screen anchor
   - Transitions to Idle state after reconnection to force game verification on next action
   - Expected behavior:
     - Bot detects disconnections during action execution
     - Bot confirms disconnection with a second check to avoid false positives
     - Bot attempts to reconnect by clicking the reconnect button
     - Bot verifies successful reconnection by checking for the main screen anchor
     - Bot transitions to Idle state after reconnection to ensure proper game state
     - Bot logs detailed information about the disconnection and reconnection process

4. **Monitor Function / ActionRunning Loop**
   - Implemented a continuous monitoring system that checks the game state in real-time
   - Added `monitorActionWithStateMachine` method in ActionManager that:
     - Performs a one-time autopilot check at the beginning of monitoring
     - Detects player death and handles recovery
     - Detects and handles in-progress dialogues without interrupting the action
     - Detects when actions are completed
     - Handles unexpected popups and errors
     - Checks for template file availability for robustness
     - Handles rerun functionality internally for appropriate actions
     - Tracks rerun state and consecutive resource checks after rerun
     - Only transitions to OutOfResources after 3 checks in rerun state
     - Uses the state machine to manage state transitions
   - This allows the bot to respond to changes in the game UI in real-time

5. **Rerun Functionality**
   - Implemented the ability to rerun quests or raids without backing out to setup
   - Added detection for the "Rerun" button in the monitoring loop
   - Added logic to use the rerun button when appropriate instead of backing out to setup
   - Implemented proper handling of resource checks after clicking rerun
   - This improves efficiency by eliminating unnecessary navigation
   - Different action types handle completion differently:
     - Quest and Raid actions with a single enabled target use the rerun button to start another run directly
     - Quest and Raid actions with multiple enabled targets use the town button to change configs for the next run
     - Other actions always use the town button to go back to setup for subsequent runs

### Current Development Focus
The main focus is on improving the action system and UI responsiveness:

1. **UI Responsiveness**
   - Need to add appropriate delays to ensure the bot doesn't process checks faster than the UI can update
   - Particularly important for resource checks and completion detection

2. **Template Management**
   - Ensure all required templates are available and properly handled
   - Implement fallback mechanisms for missing templates
   - Add more templates for detecting various game states

## Implementation Priorities

1. **Fix outofresource check in QuestAction.kt**
   - Add a delay between clicking the accept button and checking for the out of resources message
   - This will give the UI time to update and display the popup if needed

2. **Implement Game Inputs for Out-of-Resource Conditions**
   - ✅ Added `handleOutOfResources` method to handle out-of-resource conditions
   - ✅ Implemented logic to press Escape key multiple times to close UI dialogs
   - ✅ Added verification of main screen anchor after handling out-of-resource
   - ✅ Ensured proper state transitions after handling out-of-resource
   - Consider adding option to auto-purchase resources if configured
   - Add support for clicking specific "close" or "ok" buttons on resource popups

3. **Enhance the ActionRunning Monitoring System**
   - ✅ Added one-time autopilot check at the beginning of monitoring
   - ✅ Added player death detection and recovery
   - ✅ Added template file availability checks
   - ✅ Added in-progress dialogue detection and handling
   - ✅ Implemented configurable monitoring intervals with heartbeat logging
   - Add more templates for detecting various game states
   - Improve error handling and recovery mechanisms
   - Add more robust handling of unexpected game states
   - Implement configurable monitoring timeouts

3. **Improve Rerun Functionality**
   - Add support for more complex rerun scenarios
   - Implement better handling of rerun failures
   - Add configurable rerun limits
   - ✅ Differentiate between action types (Quest/Raid use rerun, others use town button)

4. **Implement Logging System**
   - Add comprehensive logging for better debugging
   - Implement log levels (debug, info, warning, error)
   - Add log rotation and archiving

### Current Priorities
- ✅ Implement game input actions for out-of-resource conditions (pressing Escape key to close UI dialogs)
- Add support for clicking specific "close" or "ok" buttons on resource popups
- Add more templates for detecting various game states

## Technical Notes

### Memory Management for OpenCV Mat Objects
- OpenCV's Mat objects use native memory that must be explicitly released
- These objects are not automatically managed by Java's garbage collector
- Recent fixes:
  - Added proper release() calls for all Mat objects in methods that use them internally
  - Updated documentation for methods that return Mat objects to indicate caller responsibility
  - Fixed memory leaks in template matching methods
- Always call `mat.release()` when you're done with a Mat object that was returned from a method

### Coroutines Implementation
- The bot uses Kotlin coroutines for parallel processing
- Two main areas of parallelization:
  1. Zone detection in QuestAction.kt
     - `determineCurrentZoneWithCoroutines` and `determineCurrentZoneWithCoroutinesOldStyle`
     - Enabled with `--morethreads` flag
  2. Template matching in Bot.kt
     - `findTemplateDetailedWithCoroutines`
     - Enabled with `--opencvthreads` flag
- Both optimizations can be used together for maximum performance

### Template Matching System
- Templates are organized in subdirectories by action type
- The bot loads templates from these directories based on the action being executed
- Template matching is performed with scale checking to handle different screen resolutions
- Coroutines can be used to check multiple scales in parallel for better performance
- Enhanced template matching options:
  - Shape-based matching (`--shapematching` flag): 
    - Uses TM_CCORR_NORMED instead of TM_CCOEFF_NORMED for matching
    - Focuses more on shapes and contours rather than exact pixel values
    - Can be more robust to lighting changes and slight variations
  - Grayscale matching (`--grayscale` flag):
    - Converts both screen capture and template images to grayscale before matching
    - Improves results when color variations might affect matching accuracy
    - Can be more robust to lighting changes
  - Verbose output (`--verbose` flag):
    - Provides detailed information about template matching operations
    - Shows what template is being searched for and its dimensions
    - Logs the scales being checked during template matching
    - Reports confidence values for each scale
    - Displays detailed information about matches found
    - Provides a summary of the search results
    - Useful for debugging template matching issues
- Screen capture:
  - Reverted from robot.createMultiResolutionScreenCapture to robot.createScreenCapture
  - The multi-resolution approach was causing compatibility issues on some systems
  - Standard screen capture provides more consistent results across different environments

### State Machine System
- The bot uses a state machine to manage the execution of actions
- The `StateMachine` class handles state transitions and executes state handlers
- The `BotState` sealed class defines all possible states the bot can be in
- The `ActionData` class encapsulates information about an action being executed
- State transitions are defined in the `setupStateMachine` method of the `ActionManager` class
- Each state has a handler function that is executed when the bot enters that state
- The state machine provides a structured way to handle different game states and transitions between them
- Benefits of the state machine approach:
  - Clearer code structure: States and transitions are explicitly defined
  - Easier debugging: State transitions are logged, making it easier to track what's happening
  - More extensible: Adding new states or transitions is straightforward
  - Better separation of concerns: State logic is separated from action execution logic
  - Easier testing: State transitions can be tested independently of the actual game actions

### YAML Configuration System
- The configuration system uses Jackson library for YAML serialization/deserialization
- Polymorphic type handling is configured to support the ActionConfig sealed class hierarchy
- The system follows a directory structure:
  - `configs/` - Main configuration directory
  - `configs/characters/` - Character configuration files
  - `configs/botconfigs/` - Bot configuration files
  - `configs/active_state.yaml` - Stores active character and config IDs
- File operations are handled by the ConfigManager class:
  - `initConfigDirectories()` - Creates the directory structure
  - `saveCharacter()` / `loadCharacter()` - Save/load individual character
  - `saveConfig()` / `loadConfig()` - Save/load individual config
  - `saveActiveState()` / `loadActiveState()` - Save/load active state
  - `saveAllToFiles()` / `loadAllFromFiles()` - Save/load all configurations
- The YamlUtils class provides utility methods for YAML operations:
  - Uses Jackson's ObjectMapper with YAML factory
  - Configures proper indentation and formatting
  - Handles polymorphic types with activateDefaultTyping and registerSubtypes
  - Provides methods for file and string operations
- The ConfigCLI class provides a command-line interface:
  - Interactive command prompt with help system
  - Commands for managing characters and configurations
  - Validation of user input and configuration integrity
  - Detailed output formatting for better readability

### Action System
- Actions are defined in the BotConfig and executed in sequence by the ActionManager
- Each action has its own configuration and resource management
- Actions are placed on cooldown when resources are depleted
- The system tracks run counts and respects configured limits
- The state machine manages the execution of actions and handles state transitions

#### Recent Improvements to Action System
- Implemented a state machine system for managing action execution
  - Clearer code structure: States and transitions are explicitly defined
  - Easier debugging: State transitions are logged, making it easier to track what's happening
  - More extensible: Adding new states or transitions is straightforward
- Added game verification in the Starting state handler
  - Ensures that the game is properly loaded before executing actions
  - Improves reliability by preventing actions from being executed in an invalid game state
- Added disconnect detection and handling in the monitoring loop
  - Detects disconnections and automatically attempts to reconnect
  - Improves reliability by automatically recovering from disconnections
- Improved out-of-resource handling with new `handleOutOfResources` method
  - Presses Escape key multiple times to close UI dialogs
  - Verifies main screen anchor is visible after handling out-of-resource
  - Ensures proper state transitions after handling out-of-resource
  - Improves reliability by properly handling out-of-resource conditions
- Extracted resource availability check to a dedicated function `isOutOfResources`
  - Single responsibility: The function focuses solely on resource checks
  - Reusability: Can be called from anywhere, including the action monitor or directly by actions
  - Testability: Easier to write unit tests for resource logic
- Added an `actionMonitor` function in ActionManager
  - Centralizes monitoring logic (checking cooldowns, run counts, and resource availability)
  - Extensibility: Easy to add more checks (e.g., error states, external conditions)
  - Loose coupling: Actions can delegate monitoring to this function
- Refactored action handlers to use the monitor function
  - Consistency: All actions use the same monitoring logic
  - Maintainability: Changes to monitoring only need to be made in one place
- Added unit tests for the new functions
  - Reliability: Ensures new logic works as intended
  - Regression safety: Prevents future changes from breaking resource/monitoring logic
