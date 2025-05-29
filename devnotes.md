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

### Current Development Focus
The main focus is on full quest action automation, specifically:

1. **Monitor Function / ActionRunning Loop**
   - Need to implement a monitoring system that continuously checks the game state
   - This will allow the bot to respond to changes in the game UI in real-time
   - Will help with detecting completion of actions and handling unexpected popups

2. **Rerun Functionality**
   - Need to implement the ability to rerun quests or raids without backing out to setup
   - For single dungeon or raid runs, the bot should hit the "Rerun" button
   - This will improve efficiency by eliminating unnecessary navigation

3. **UI Responsiveness**
   - Need to add appropriate delays to ensure the bot doesn't process checks faster than the UI can update
   - Particularly important for resource checks and completion detection

## Implementation Priorities

1. **Fix outofresource check in QuestAction.kt**
   - Add a delay between clicking the accept button and checking for the out of resources message
   - This will give the UI time to update and display the popup if needed

2. **Implement Monitor Function / ActionRunning Loop**
   - Create a continuous monitoring system that checks for various game states
   - Handle unexpected popups, errors, and completion states
   - Implement proper state transitions based on detected UI elements

3. **Implement Rerun Functionality**
   - Add detection for the "Rerun" button in quest and raid screens
   - Implement logic to use the rerun button when appropriate instead of backing out to setup
   - Handle cases where rerun is not available or not appropriate

4. **Improve Error Handling and Recovery**
   - Enhance error detection and recovery mechanisms
   - Add more robust handling of unexpected game states
   - Implement logging for better debugging

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
