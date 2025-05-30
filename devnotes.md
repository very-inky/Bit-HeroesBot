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
- Fixed an oversight in Bot.kt that now allows ALL findtemplate checks to use coroutines if the user has `--opencvthreads` enabled
- This improves performance for all template matching operations throughout the application
- Added shape-based template matching option (`--shapematching` flag) that uses TM_CCORR_NORMED instead of TM_CCOEFF_NORMED
- Added grayscale template matching option (`--grayscale` flag) that converts images to grayscale before matching
- Reverted from robot.createMultiResolutionScreenCapture to robot.createScreenCapture for better compatibility

### Current Issues
- In QuestAction.kt, the bot processes the outofresource check too quickly for the UI to update
  - This causes the bot to potentially miss the out of resources popup
  - A delay needs to be added between clicking the accept button and checking for the out of resources message

### Recent Implementations

1. **Monitor Function / ActionRunning Loop**
   - Implemented a continuous monitoring system that checks the game state in real-time
   - Added `monitorRunningAction` method in ActionManager that:
     - Performs a one-time autopilot check at the beginning of monitoring
     - Detects player death and handles recovery
     - Detects and handles in-progress dialogues without interrupting the action
     - Detects when actions are completed
     - Handles unexpected popups and errors
     - Checks for template file availability for robustness
     - Handles rerun functionality internally for appropriate actions
     - Tracks rerun state and consecutive resource checks after rerun
     - Only returns out-of-resources after 3 checks in rerun state
     - Returns detailed results about the action's status including rerun information
   - This allows the bot to respond to changes in the game UI in real-time

2. **Rerun Functionality**
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
   - Currently, the system detects out-of-resource conditions but doesn't perform any game inputs in response
   - Need to implement logic to handle out-of-resource popups by clicking appropriate buttons
   - Add template for "close" or "ok" button on resource popups
   - Implement click action when out-of-resource popup is detected
   - Consider adding option to auto-purchase resources if configured
   - Add proper error handling and recovery if resource-related actions fail

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
- Implement game input actions for out-of-resource conditions (e.g., clicking 'close' or 'ok' on resource popups)

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
- Screen capture:
  - Reverted from robot.createMultiResolutionScreenCapture to robot.createScreenCapture
  - The multi-resolution approach was causing compatibility issues on some systems
  - Standard screen capture provides more consistent results across different environments

### Action System
- Actions are defined in the BotConfig and executed in sequence by the ActionManager
- Each action has its own configuration and resource management
- Actions are placed on cooldown when resources are depleted
- The system tracks run counts and respects configured limits

#### Recent Improvements to Action System
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
