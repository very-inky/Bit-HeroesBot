
# Game Automation Bot Documentation

## Project Overview

This project is a game automation bot built in Kotlin using OpenCV for image recognition. The bot is designed to automate repetitive tasks in a game by identifying screen elements through template matching and simulating user interactions. It supports multiple characters and configurations, allowing users to create different automation profiles for various gameplay goals.

## Architecture

### Core Components

1. **Bot**: The central component that handles screen capture, image recognition, and user input simulation.
2. **ActionManager**: Manages the execution sequence of game actions, handles cooldowns, and tracks action run counts.
3. **GameAction Interface**: Defines the contract for all game actions, with methods for execution and resource checking.
4. **ConfigManager**: Manages multiple characters and configurations, ensuring only one is active at a time.
5. **CharacterConfig**: Contains character-specific settings and account information.
6. **BotConfig**: Contains configuration settings for a specific task or farming goal, linked to a character.
7. **ActionConfig**: A sealed class hierarchy that defines configurations for different types of game actions.

### Component Relationships

```
                                 ┌─────────────┐
                                 │    Main     │
                                 └──────┬──────┘
                                        │
                                        ▼
                               ┌──────────────────┐
                               │  ConfigManager   │
                               └────────┬─────────┘
                                        │
                 ┌────────────────────┬─┴───────────────────┐
                 │                    │                     │
                 ▼                    ▼                     ▼
        ┌─────────────────┐  ┌─────────────────┐   ┌─────────────────┐
        │ CharacterConfig │  │    BotConfig    │   │ Other Characters│
        │  (Active User)  │  │  (Active Config)│   │   and Configs   │
        └─────────────────┘  └────────┬────────┘   └─────────────────┘
                                      │
                      ┌───────────────┴───────────────┐
                      │                               │
                      ▼                               ▼
             ┌─────────────────┐             ┌─────────────────┐
             │       Bot       │◄────────────┤  ActionManager  │
             └─────────────────┘             └────────┬────────┘
                                                      │
                                                      ▼
                                              ┌─────────────────┐
                                              │   GameAction    │
                                              └────────┬────────┘
                                                       │
                  ┌────────────────┬────────────┬─────┴─────┬────────────────┐
                  ▼                ▼            ▼           ▼                ▼
           ┌──────────┐     ┌──────────┐  ┌──────────┐ ┌──────────┐   ┌──────────┐
           │QuestAction│     │RaidAction│  │PvpAction │ │GvgAction │   │   ...    │
           └──────────┘     └──────────┘  └──────────┘ └──────────┘   └──────────┘
```

### Detailed Component Interactions

#### Main Component Call Flow

The following diagram illustrates the detailed call flow between components during bot initialization and execution:

```
┌─────────┐          ┌───────────────┐          ┌────────────────┐          ┌─────────────┐          ┌────────────┐
│  Main   │          │ ConfigManager │          │      Bot       │          │ActionManager│          │ GameAction │
└────┬────┘          └───────┬───────┘          └────────┬───────┘          └──────┬──────┘          └──────┬─────┘
     │                       │                           │                          │                        │
     │ 1. Initialize         │                           │                          │                        │
     │ ConfigManager         │                           │                          │                        │
     │─────────────────────>│                           │                          │                        │
     │                       │                           │                          │                        │
     │ 2. Add Characters     │                           │                          │                        │
     │ and Configs           │                           │                          │                        │
     │─────────────────────>│                           │                          │                        │
     │                       │                           │                          │                        │
     │ 3. Set Active         │                           │                          │                        │
     │ Character & Config    │                           │                          │                        │
     │─────────────────────>│                           │                          │                        │
     │                       │                           │                          │                        │
     │ 4. Get Active Config  │                           │                          │                        │
     │─────────────────────>│                           │                          │                        │
     │<─────────────────────│                           │                          │                        │
     │                       │                           │                          │                        │
     │ 5. Create Bot with    │                           │                          │                        │
     │ Active Config         │                           │                          │                        │
     │───────────────────────────────────────────────────>                          │                        │
     │                       │                           │                          │                        │
     │ 6. Initialize Bot     │                           │                          │                        │
     │───────────────────────────────────────────────────>                          │                        │
     │                       │                           │                          │                        │
     │ 7. Create ActionManager                           │                          │                        │
     │ with Bot and Config   │                           │                          │                        │
     │─────────────────────────────────────────────────────────────────────────────>│                        │
     │                       │                           │                          │                        │
     │ 8. Run Action Sequence│                           │                          │                        │
     │─────────────────────────────────────────────────────────────────────────────>│                        │
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9. For each action     │
     │                       │                           │                          │ in sequence:           │
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.1 Check if action    │
     │                       │                           │                          │ can be executed        │
     │                       │                           │                          │─┐                      │
     │                       │                           │                          │ │                      │
     │                       │                           │                          │<┘                      │
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.2 Create action      │
     │                       │                           │                          │ handler                │
     │                       │                           │                          │─────────────────────────>
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.3 Check resources    │
     │                       │                           │                          │─────────────────────────>
     │                       │                           │                          │<─────────────────────────
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.4 Execute action     │
     │                       │                           │                          │─────────────────────────>
     │                       │                           │                          │                        │
     │                       │                           │                          │                        │
     │                       │                           │ 9.4.1 Load templates     │                        │
     │                       │                           │<───────────────────────────────────────────────────
     │                       │                           │                          │                        │
     │                       │                           │ 9.4.2 Find templates     │                        │
     │                       │                           │<───────────────────────────────────────────────────
     │                       │                           │                          │                        │
     │                       │                           │ 9.4.3 Click on templates │                        │
     │                       │                           │<───────────────────────────────────────────────────
     │                       │                           │                          │                        │
     │                       │                           │                          │<─────────────────────────
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.5 Update run counts  │
     │                       │                           │                          │─┐                      │
     │                       │                           │                          │ │                      │
     │                       │                           │                          │<┘                      │
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.6 Check resources    │
     │                       │                           │                          │ again                  │
     │                       │                           │                          │─────────────────────────>
     │                       │                           │                          │<─────────────────────────
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.7 Set cooldown if    │
     │                       │                           │                          │ resources depleted     │
     │                       │                           │                          │─┐                      │
     │                       │                           │                          │ │                      │
     │                       │                           │                          │<┘                      │
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.8 Repeat for next    │
     │                       │                           │                          │ action in sequence     │
     │                       │                           │                          │─┐                      │
     │                       │                           │                          │ │                      │
     │                       │                           │                          │<┘                      │
     │                       │                           │                          │                        │
```

#### Specific Action Execution Flow

The following diagram shows the detailed execution flow for a specific action (using QuestAction as an example):

```
┌─────────────┐          ┌────────────┐          ┌─────────────┐          ┌────────────────┐
│ActionManager│          │QuestAction │          │    Bot      │          │ BaseGameAction │
└──────┬──────┘          └──────┬─────┘          └──────┬──────┘          └────────┬───────┘
       │                        │                       │                          │
       │ 1. executeAction()     │                       │                          │
       │─────────────────────────>                      │                          │
       │                        │                       │                          │
       │ 2. hasResourcesAvailable()                     │                          │
       │─────────────────────────>                      │                          │
       │                        │                       │                          │
       │                        │ 2.1 Check resources   │                          │
       │                        │ using Bot             │                          │
       │                        │──────────────────────>│                          │
       │                        │<──────────────────────│                          │
       │<─────────────────────────                      │                          │
       │                        │                       │                          │
       │ 3. execute()           │                       │                          │
       │─────────────────────────>                      │                          │
       │                        │                       │                          │
       │                        │ 3.1 Load templates    │                          │
       │                        │───────────────────────────────────────────────────>
       │                        │<───────────────────────────────────────────────────
       │                        │                       │                          │
       │                        │ 3.2 Determine current │                          │
       │                        │ zone                  │                          │
       │                        │──────────────────────>│                          │
       │                        │                       │                          │
       │                        │                       │ 3.2.1 Capture screen     │
       │                        │                       │─┐                        │
       │                        │                       │ │                        │
       │                        │                       │<┘                        │
       │                        │                       │                          │
       │                        │                       │ 3.2.2 Find templates     │
       │                        │                       │─┐                        │
       │                        │                       │ │                        │
       │                        │                       │<┘                        │
       │                        │<──────────────────────│                          │
       │                        │                       │                          │
       │                        │ 3.3 Navigate to       │                          │
       │                        │ target zone           │                          │
       │                        │──────────────────────>│                          │
       │                        │                       │                          │
       │                        │                       │ 3.3.1 Find and click     │
       │                        │                       │ navigation buttons       │
       │                        │                       │─┐                        │
       │                        │                       │ │                        │
       │                        │                       │<┘                        │
       │                        │<──────────────────────│                          │
       │                        │                       │                          │
       │                        │ 3.4 Select and enter  │                          │
       │                        │ dungeon               │                          │
       │                        │──────────────────────>│                          │
       │                        │                       │                          │
       │                        │                       │ 3.4.1 Find and click     │
       │                        │                       │ dungeon buttons          │
       │                        │                       │─┐                        │
       │                        │                       │ │                        │
       │                        │                       │<┘                        │
       │                        │<──────────────────────│                          │
       │                        │                       │                          │
       │                        │ 3.5 Complete dungeon  │                          │
       │                        │ run                   │                          │
       │                        │──────────────────────>│                          │
       │                        │<──────────────────────│                          │
       │<─────────────────────────                      │                          │
       │                        │                       │                          │
       │ 4. hasResourcesAvailable()                     │                          │
       │ (check again after run)│                       │                          │
       │─────────────────────────>                      │                          │
       │                        │                       │                          │
       │                        │ 4.1 Check resources   │                          │
       │                        │ using Bot             │                          │
       │                        │──────────────────────>│                          │
       │                        │<──────────────────────│                          │
       │<─────────────────────────                      │                          │
       │                        │                       │                          │
```

## Configuration System

The bot uses a multi-level configuration system:

1. **ConfigManager**: Top-level manager that:
   - Maintains multiple characters and configurations
   - Ensures only one character is active at a time
   - Manages account switching
   - Validates configuration integrity

2. **CharacterConfig**: Character-specific settings:
   - `characterId`: Unique identifier for the character
   - `characterName`: Name of the character
   - `accountId`: Identifier for the account this character belongs to
   - `isActive`: Whether this character is currently active

3. **BotConfig**: Configuration profile for a specific task or farming goal:
   - `configId`: Unique identifier for this configuration
   - `configName`: User-friendly name for this configuration
   - `characterId`: Reference to the character this config belongs to
   - `description`: Description of what this config is for
   - `actionSequence`: Ordered list of actions to execute
   - `actionConfigs`: Map of action-specific configurations
   - `defaultAction`: Default action if none specified

4. **ActionConfig**: Base class for all action configurations with common properties:
   - `enabled`: Whether the action is enabled
   - `commonActionTemplates`: List of template images for common UI elements
   - `specificTemplates`: List of template images specific to this action
   - `cooldownDuration`: Duration in minutes for action cooldown when resources are depleted

5. **Specific Action Configs**: Extend ActionConfig with action-specific properties:
   - `QuestActionConfig`: For quest/dungeon actions
   - `RaidActionConfig`: For raid actions
   - `PvpActionConfig`: For PvP actions
   - etc.

## Action System

### Action Workflow

1. The `ActionManager` processes actions in the sequence defined in the active `BotConfig`.
2. For each action:
   - Check if the action can be executed (not on cooldown, has resources, not reached run limit)
   - If executable, create the appropriate action handler
   - Check resources before execution
   - Execute the action if resources are available
   - Update run counts after successful execution
   - Check resources again after execution
   - Set cooldown if resources are depleted

### Action Rotation Logic

The bot implements a sophisticated rotation system that:
1. Cycles through all actions in the configured sequence
2. Skips actions that are disabled, on cooldown, or have reached their run limit
3. Continues cycling until all actions are either completed or on cooldown
4. For actions with unlimited runs (repeatCount/runCount = 0), executes until resources are depleted
5. Tracks cooldowns for each action independently
6. Automatically resumes actions when their cooldown expires

### Resource Management

Each action implements a `hasResourcesAvailable` method that checks if the action has the necessary resources (energy, tickets, etc.) to execute. The resource management system:

1. Checks resources before attempting to execute an action
2. Places actions on cooldown when resources are depleted
3. Uses configurable cooldown durations for each action type
4. Continues with other available actions while waiting for resources to replenish
5. Automatically resumes actions when their cooldown expires

### Character and Account Management

The bot supports multiple characters and accounts:

1. Each account can have multiple characters
2. Each character can have multiple configuration profiles
3. Only one character can be active at a time
4. The active character determines which configurations are available
5. Account switching functionality allows for automated alt account management
6. Configuration validation ensures integrity of the active setup

## OpenCV Integration and Template Matching System

The bot requires OpenCV with full functionality for image recognition and template matching:

1. **OpenCV Loading Mechanism**:
   - The bot automatically loads the OpenCV native library at startup
   - If the library is not present or only partially loaded, it will download the complete library
   - The bot requires full OpenCV functionality and will not run in partial functionality mode
   - If full functionality cannot be loaded, the bot will throw an exception and exit
   - OpenCL should enable by default. This requires you have GPU drivers propely installed. This is easy on Windows but Linux users should make sure they have necessary openCL functionality working.

2. **Memory Management for OpenCV Mat Objects**:
   - OpenCV's Mat objects are native resources that must be explicitly released when no longer needed
   - These objects are not automatically managed by Java's garbage collector since they use native memory
   - The bot handles memory management in two ways:
     - Methods that use Mat objects internally release them before returning
     - Methods that return Mat objects document that the caller is responsible for releasing them
   - Always call `mat.release()` when you're done with a Mat object that was returned from a method
   - Failure to release Mat objects will result in memory leaks and eventual performance degradation
   - Key methods that return Mat objects and require caller to release:
     - `captureScreen()`
     - `captureRegion()`
     - `bufferedImageToMat()`

3. **Template Matching System**:
   - Template images are stored in the `templates` directory with subdirectories organized by action type:
     - `raid`: Templates for raid-related actions
     - `quest`: Templates for quest-related actions
     - `pvp`: Templates for PvP-related actions
     - `gvg`: Templates for GvG-related actions
     - `worldboss`: Templates for world boss-related actions
     - `invasion`: Templates for invasion-related actions
     - `expedition`: Templates for expedition-related actions
     - `ui`: Common UI elements used across all actions
     - `characters`: Character-specific templates
   - The `Bot` class loads templates and provides methods to:
     - Find templates on the screen with configurable matching thresholds
     - Click on matched templates
     - Perform other screen interactions
     - Scale templates based on screen resolution and DPI
     - Get detailed matching information (scale, confidence, etc.)
   - Template registration system tracks original dimensions and DPI for proper scaling

3. **Template Loading Process**:
   - Each action configuration specifies which template directories to use:
     - `commonTemplateDirectories`: Directories containing common UI elements (default: `templates/ui`)
     - `specificTemplateDirectories`: Directories containing action-specific templates (e.g., `templates/quest`)
   - The `BaseGameAction.loadTemplates()` method:
     - Loads common templates from `commonTemplateDirectories`
     - Loads specific templates from `specificTemplateDirectories`
     - Adds any explicitly specified templates from `commonActionTemplates` and `specificTemplates`
     - Returns a pair of (common templates, specific templates) for the action to use
   - Templates are loaded recursively from directories, including all subdirectories
   - The bot uses `getTemplatesByCategory()` to filter templates by category based on directory names

### Pattern Test Mode

The bot includes a pattern test mode that allows testing template matching without running the full automation:

1. Run the bot with the `--test-pattern` argument to enter pattern test mode:
   ```
   # Using Gradle
   gradlew run --args="--test-pattern [template-path]"

   # Using JAR file
   java -jar your-bot.jar --test-pattern [template-path]
   ```
   Note: Omit the template-path to test all detected templates!

2. If a specific template path is provided, the bot will test only that template:
   ```
   gradlew run --args="--test-pattern templates/quest/questicon.png"
   ```

3. If a directory path is provided, the bot will test all templates in that directory:
   ```
   gradlew run --args="--test-pattern templates/quest"
   ```

4. You can combine the `--test-pattern` flag with optimization flags for faster template testing:
   ```
   # Test with parallel zone detection
   gradlew run --args="--test-pattern templates/quest --morethreads"

   # Test with parallel template matching
   gradlew run --args="--test-pattern templates/quest --opencvthreads"

   # Test with both optimizations
   gradlew run --args="--test-pattern templates/quest --morethreads --opencvthreads"
   ```

5. You can configure the number of threads used by the `--opencvthreads` flag by setting JVM system properties. Note the difference between:
   - **Program arguments**: Passed directly to the application (e.g., `--opencvthreads`)
   - **VM arguments**: JVM system properties that configure the Java Virtual Machine (e.g., `-Dkotlinx.coroutines.scheduler.max.pool.size=8`)

   ```
   # Limit to 8 threads (using Gradle)
   # Program argument: --opencvthreads
   # VM arguments: -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
   gradlew run --args="--opencvthreads" -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8

   # Limit to 8 threads (using Java)
   # Program argument: --opencvthreads
   # VM arguments: -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
   java -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8 -jar your-bot.jar --opencvthreads

   # Limit to 8 threads (using PowerShell)
   # Program argument: --opencvthreads
   # VM arguments: Set via JAVA_OPTS environment variable
   $env:JAVA_OPTS="-Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8"
   gradlew run --args="--opencvthreads"

   # In IntelliJ IDEA run configuration
   # Program arguments field: --opencvthreads
   # VM options field: -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
   ```

   Note: Both VM properties must be set, and the max pool size must be greater than or equal to the core pool size. By default, the thread pool size equals the number of available processors, when the additional threads options are enabled, this is not ideal.

6. The pattern test mode displays comprehensive information about each match:
   - Whether the template was found
   - The position where it was found
   - The scale at which it was found
   - The confidence value of the match
   - The current screen resolution
   - The system DPI scaling

## Current Implementation Status

### Implemented Features

1. ✅ Basic bot framework with OpenCV integration
2. ✅ Multi-character and multi-account configuration system
3. ✅ ConfigManager for managing multiple configurations
4. ✅ Action manager with cooldown and rotation logic
5. ✅ Resource checking with cooldown management
6. ✅ Template matching for screen recognition
   - ✅ Multi-scale template matching with DPI awareness
   - ✅ Detailed template matching results (scale, confidence, etc.)
   - ✅ Pattern test mode for testing templates without running the bot
   - ✅ Coroutines for parallel template matching with `--opencvthreads` flag
7. ✅ Quest action implementation with zone navigation and dungeon selection
   - ✅ Coroutines for parallel zone detection with `--morethreads` flag
   - ✅ Optimized zone navigation based on current zone detection
8. ✅ Raid action implementation (placeholder)
9. ✅ Account switching functionality

### Partially Implemented

1. ⚠️ Resource checking (currently simulated, needs real screen recognition)
2. ⚠️ Error handling and recovery
3. ⚠️ PvP and GvG action configurations (defined but handlers not implemented)
4. ⚠️ UI responsiveness (some checks process too quickly for the UI to update)

### Pending Implementation

1. ❌ Monitor function / ActionRunning loop for continuous game state monitoring
2. ❌ Rerun functionality for quests and raids without backing out to setup
3. ❌ PvP action implementation
4. ❌ GvG action implementation
5. ❌ World Boss action implementation
6. ❌ Trials action implementation
7. ❌ Expedition action implementation
8. ❌ Gauntlet action implementation
9. ❌ Logging system
10. ❌ UI for configuration

## Detailed Component Descriptions

### Main Components

#### 1. Bot
The Bot class is the central component responsible for screen capture, image recognition, and user input simulation:

- **Key Responsibilities**:
  - Screen capture and image processing
  - Template registration and management
  - Template matching with various methods (sequential and parallel)
  - User input simulation (mouse clicks, key presses)
  - System information retrieval (DPI scaling, screen resolution)

- **Key Methods**:
  - `initialize()`: Sets up the bot, loads OpenCV, and initializes resources
  - `captureScreen()`: Captures the entire screen as a Mat object
  - `findTemplateDetailed()`: Finds a template on the screen with detailed match information
  - `clickOnTemplate()`: Finds and clicks on a template
  - `loadTemplatesFromDirectory()`: Loads all templates from a directory

- **Nested Classes**:
  - `TemplateInfo`: Stores information about a template (original dimensions, DPI)
  - `TemplateMatchResult`: Stores the result of a template match (location, scale, confidence)

#### 2. ActionManager
The ActionManager class manages the execution sequence of game actions:

- **Key Responsibilities**:
  - Processing actions in the sequence defined in the active BotConfig
  - Tracking cooldowns for actions
  - Tracking run counts for actions
  - Checking if actions can be executed
  - Creating appropriate action handlers
  - Executing actions and handling results

- **Key Methods**:
  - `runActionSequence()`: Runs the action sequence defined in the config
  - `canExecuteAction()`: Checks if an action can be executed
  - `executeAction()`: Executes an action and handles the result
  - `getRunCountLimit()`: Gets the run count limit for an action

#### 3. GameAction Interface
The GameAction interface defines the contract for all game actions:

- **Key Methods**:
  - `execute(bot: Bot, config: ActionConfig)`: Executes the specific game action
  - `hasResourcesAvailable(bot: Bot, config: ActionConfig)`: Checks if resources are available

#### 4. BaseGameAction
The BaseGameAction class provides common functionality for all game actions:

- **Key Responsibilities**:
  - Template loading and management
  - Template finding and interaction
  - Common UI interaction patterns

- **Key Methods**:
  - `loadTemplates()`: Loads templates for an action from specified directories
  - `findAnyTemplate()`: Searches for any template from a list on the screen
  - `findAndClickTemplate()`: Finds a template on the screen and clicks it
  - `findAndClickAnyTemplate()`: Finds and clicks any template from a list
  - `findAndClickSpecificTemplate()`: Finds and clicks a specific template by name

#### 5. Specific Action Implementations
Specific action implementations (QuestAction, RaidAction, etc.) extend BaseGameAction and implement the GameAction interface:

- **QuestAction**:
  - Handles quest/dungeon actions
  - Determines current zone
  - Navigates between zones
  - Selects and enters dungeons
  - Checks for quest resources

- **RaidAction**:
  - Handles raid actions
  - Selects raid bosses
  - Chooses difficulty levels
  - Executes raid battles
  - Checks for raid resources

#### 6. ConfigManager
The ConfigManager class manages multiple characters and configurations:

- **Key Responsibilities**:
  - Maintaining multiple characters and configurations
  - Ensuring only one character is active at a time
  - Managing account switching
  - Validating configuration integrity

- **Key Methods**:
  - `addCharacter()`: Adds a character to the manager
  - `addConfig()`: Adds a configuration to the manager
  - `setActiveCharacter()`: Sets the active character
  - `setActiveConfig()`: Sets the active configuration
  - `getActiveConfig()`: Gets the active configuration

### Configuration Classes

#### 1. CharacterConfig
The CharacterConfig class contains character-specific settings:

- **Key Properties**:
  - `characterId`: Unique identifier for the character
  - `characterName`: Name of the character
  - `accountId`: Identifier for the account this character belongs to
  - `isActive`: Whether this character is currently active

#### 2. BotConfig
The BotConfig class contains configuration settings for a specific task or farming goal:

- **Key Properties**:
  - `configId`: Unique identifier for this configuration
  - `configName`: User-friendly name for this configuration
  - `characterId`: Reference to the character this config belongs to
  - `description`: Description of what this config is for
  - `actionSequence`: Ordered list of actions to execute
  - `actionConfigs`: Map of action-specific configurations
  - `defaultAction`: Default action if none specified

#### 3. ActionConfig
The ActionConfig class is the base class for all action configurations:

- **Key Properties**:
  - `enabled`: Whether the action is enabled
  - `commonTemplateDirectories`: Directories containing common UI elements
  - `specificTemplateDirectories`: Directories containing action-specific templates
  - `commonActionTemplates`: List of template images for common UI elements
  - `specificTemplates`: List of template images specific to this action
  - `cooldownDuration`: Duration in minutes for action cooldown when resources are depleted

## Current Priorities

1. **Implement Monitor Function / ActionRunning Loop**: Create a continuous monitoring system that checks for various game states and responds to changes in the game UI in real-time
2. **Implement Rerun Functionality**: Add the ability to rerun quests or raids without backing out to setup, improving efficiency by eliminating unnecessary navigation
3. **Improve UI Responsiveness**: Add appropriate delays to ensure the bot doesn't process checks faster than the UI can update, particularly for resource checks
4. **Fix OutOfResource Check**: Address the issue in QuestAction.kt where the bot processes the outofresource check too quickly for the UI to update
5. **Improve Error Handling**: Enhance error detection and recovery mechanisms
6. **Complete Action Implementations**: Implement the remaining game actions (PvP, GvG, etc.)
7. **Improve Resource Detection**: Replace simulated resource checking with actual screen recognition
8. **Testing Framework**: Develop a testing framework for actions
9. **Configuration UI**: Create a user interface for configuration management
10. **Multi-Account Automation**: Enhance account switching with automatic login

For more detailed information on the current state of the project and development priorities, see [devnotes.md](devnotes.md).

## Usage

1. Create characters and configurations using the ConfigManager
2. Set the active character and configuration
3. Organize template images in the `templates` directory:
   - Place common UI elements in `templates/ui/`
   - Place action-specific templates in their respective directories:
     - Quest templates in `templates/quest/`
     - Raid templates in `templates/raid/`
     - PvP templates in `templates/pvp/`
     - GvG templates in `templates/gvg/`
     - etc.
   - Use PNG format for best results
   - Name templates descriptively (e.g., `quest_button.png`, `raid_heroic_button.png`)
4. Configure actions to use the appropriate template directories:
   ```kotlin
   QuestActionConfig(
       commonTemplateDirectories = listOf("templates/ui"),
       specificTemplateDirectories = listOf("templates/quest"),
       useDirectoryBasedTemplates = true
   )
   ```
5. Run the application to start the bot with the active configuration

## Example Configuration

```kotlin
// Create a configuration manager
val configManager = ConfigManager()

// Create a character
val heroCharacterId = UUID.randomUUID().toString()
val heroCharacter = CharacterConfig(
    characterId = heroCharacterId,
    characterName = "MyAwesomeHero"
)
configManager.addCharacter(heroCharacter)

// Create a configuration for the character
val dailyFarmingConfig = BotConfig(
    configId = UUID.randomUUID().toString(),
    configName = "Daily Farming",
    characterId = heroCharacterId,
    description = "Configuration for daily farming tasks",
    actionSequence = listOf("Quest", "Raid"),
    actionConfigs = mapOf(
        "Quest" to QuestActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/quest"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/quest_button.png"),
            specificTemplates = listOf("templates/quest/dungeon_enter.png"),
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true),
                QuestActionConfig.DungeonTarget(zoneNumber = 6, dungeonNumber = 3, enabled = true)
            ),
            repeatCount = 0, // Run until out of resources
            cooldownDuration = 20 // 20 minute cooldown when resources are depleted
        ),
        "Raid" to RaidActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/raid"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/raid_button.png"),
            specificTemplates = listOf("templates/raid/heroic_difficulty.png"),
            raidTargets = listOf(
                RaidActionConfig.RaidTarget(raidName = "SomeRaidBoss", difficulty = "Heroic", enabled = true)
            ),
            runCount = 0, // Run until out of resources
            cooldownDuration = 30 // 30 minute cooldown when resources are depleted
        )
    )
)
configManager.addConfig(dailyFarmingConfig)

// Activate the character and configuration
configManager.setActiveCharacter(heroCharacterId)
configManager.setActiveConfig(dailyFarmingConfig.configId)

// Create and run the bot with the active configuration
val activeConfig = configManager.getActiveConfig()
if (activeConfig != null) {
    val bot = Bot(activeConfig, configManager)
    bot.initialize()

    // Run the action sequence
    val actionManager = ActionManager(bot, activeConfig, configManager)
    actionManager.runActionSequence()
}
```

## Future Enhancements

1. **Scheduling**: Add time-based scheduling for actions
2. **Reporting**: Generate reports on action execution and resource usage
3. **Advanced Pattern Recognition**: Implement more sophisticated image recognition techniques
4. **Machine Learning**: Add learning capabilities to improve action success rates
5. **Auto-Login**: Implement automatic login for account switching
6. **Configuration Presets**: Create shareable configuration presets for common farming strategies
7. **Remote Control**: Add remote monitoring and control capabilities
8. **Performance Optimization**: Improve template matching performance and resource usage
9. **Backup and Restore**: Add configuration backup and restore functionality

## Multiple Character Configuration Examples

### PvE-Focused Character

```kotlin
// Create a PvE-focused character configuration
val pveCharacterConfig = BotConfig(
    configId = UUID.randomUUID().toString(),
    configName = "PvE Farmer",
    characterId = heroCharacterId,
    description = "Configuration for PvE content farming",
    actionSequence = listOf("Quest", "Raid", "WorldBoss"),
    actionConfigs = mapOf(
        "Quest" to QuestActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/quest"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/quest_button.png"),
            specificTemplates = listOf("templates/quest/zone_7.png", "templates/quest/zone_8.png"),
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 7, dungeonNumber = 3, enabled = true),
                QuestActionConfig.DungeonTarget(zoneNumber = 8, dungeonNumber = 5, enabled = true)
            ),
            repeatCount = 0, // Run until resources are depleted
            cooldownDuration = 30 // 30 minute cooldown
        ),
        "Raid" to RaidActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/raid"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/raid_button.png"),
            specificTemplates = listOf("templates/raid/dragonlord.png", "templates/raid/heroic_difficulty.png"),
            raidTargets = listOf(
                RaidActionConfig.RaidTarget(raidName = "DragonLord", difficulty = "Heroic", enabled = true)
            ),
            runCount = 5, // Run 5 times
            cooldownDuration = 60 // 1 hour cooldown
        )
    )
)
```

### PvP-Focused Character

```kotlin
// Create a PvP-focused character configuration
val pvpCharacterConfig = BotConfig(
    configId = UUID.randomUUID().toString(),
    configName = "PvP Champion",
    characterId = heroCharacterId,
    description = "Configuration for PvP content",
    actionSequence = listOf("PvP", "GvG", "Quest"),
    actionConfigs = mapOf(
        "PvP" to PvpActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/pvp"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/pvp_button.png"),
            specificTemplates = listOf("templates/pvp/opponent_rank_3.png"),
            ticketsToUse = 5, // Use all 5 tickets
            opponentRank = 3 // Target rank 3 opponents
        ),
        "GvG" to GvgActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/gvg"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/gvg_button.png"),
            specificTemplates = listOf("templates/gvg/badge_4.png", "templates/gvg/opponent_2.png"),
            badgeChoice = 4, // Use badge type 4
            opponentChoice = 2 // Target opponent 2
        ),
        "Quest" to QuestActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/quest"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/quest_button.png"),
            specificTemplates = listOf("templates/quest/zone_10.png"),
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 10, dungeonNumber = 1, enabled = true)
            ),
            repeatCount = 3, // Only run 3 times
            cooldownDuration = 15 // 15 minute cooldown
        )
    )
)
```
