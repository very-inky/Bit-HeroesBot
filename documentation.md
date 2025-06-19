# Game Automation Bot Documentation

## Project Overview

This project is a game automation bot built in Kotlin using OpenCV for image recognition. The bot is designed to automate repetitive tasks in a game by identifying screen elements through template matching and simulating user interactions. It supports multiple characters and configurations, allowing users to create different automation profiles for various gameplay goals.

## Architecture

### Core Components

1. **Bot**: The central component that handles screen capture, image recognition, and user input simulation.
2. **ActionManager**: Manages the execution sequence of game actions, handles cooldowns, and tracks action run counts.
3. **StateMachine**: Manages the state transitions of the bot during action execution, providing a structured way to handle different game states.
4. **BotState**: Defines all possible states the bot can be in during operation (Idle, Starting, Running, Rerunning, etc.).
5. **ActionData**: Encapsulates information about an action being executed, used to pass data between state handlers.
6. **GameAction Interface**: Defines the contract for all game actions, with methods for execution and resource checking.
7. **ConfigManager**: Manages multiple characters and configurations, ensuring only one is active at a time. Handles loading and saving configurations to/from YAML files.
8. **CharacterConfig**: Contains character-specific settings and account information.
9. **BotConfig**: Contains configuration settings for a specific task or farming goal, linked to a character.
10. **ActionConfig**: A sealed class hierarchy that defines configurations for different types of game actions.
11. **ConfigCLI**: Provides a command-line interface for managing bot configurations.
12. **YamlUtils**: Utility class for serializing and deserializing configuration objects to/from YAML format.

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
             │       Bot       │◄────────────┤  ActionManager  │──────┐
             └─────────────────┘             └────────┬────────┘      │
                      ▲                               │                │
                      │                               │                │
                      │                               ▼                │
                      │                       ┌─────────────────┐     │
                      │                       │   GameAction    │     │
                      │                       └────────┬────────┘     │
                      │                                │               │
                      │  ┌────────────┬────────────┬───┴─────┬────────┴───┐
                      │  │            │            │         │            │
                      │  ▼            ▼            ▼         ▼            ▼
             ┌────────┴─────┐  ┌──────────┐  ┌──────────┐ ┌──────────┐ ┌──────────┐
             │  ActionData  │  │QuestAction│  │RaidAction│ │PvpAction │ │StateMachine│
             └──────────────┘  └──────────┘  └──────────┘ └──────────┘ └─────┬────┘
                                                                             │
                                                                             ▼
                                                                      ┌──────────┐
                                                                      │ BotState │
                                                                      └──────────┘
```

### OpenCV Template Matching System

The bot uses OpenCV for image recognition and template matching. This system is responsible for identifying game elements on the screen and is a critical component of the automation process.

#### Template Matching Process

1. **Screen Capture**: The bot captures the screen using Java's Robot class.
2. **Color Space Conversion**: The screen capture is converted to the BGR color format expected by OpenCV.
3. **Template Loading**: Template images are loaded from the file system.
4. **Scale Checking**: The bot checks multiple scales to handle different screen resolutions.
5. **Template Matching**: OpenCV's matchTemplate function is used to find the template in the screen capture.
6. **Result Processing**: The best match is determined based on confidence scores.

#### Recent Improvements

1. **Color Channel Alignment Fix**:
   - **Problem**: Screen captures from Java (in ARGB format) were being converted to OpenCV's Mat format without proper color channel alignment, resulting in lower confidence scores (around 0.81) even for perfect matches.
   - **Solution**: Implemented a new `bufferedImageToBgrMat` method that properly converts screen captures to the BGR format expected by OpenCV.
   - **Implementation**: The method creates a new BufferedImage specifically in the BGR format, transfers the image data, and then creates a Mat object with the correct format (CV_8UC3).
   - **Result**: Significantly higher confidence scores for matching templates, potentially approaching 0.95-0.99 for perfect matches.

2. **Scale Handling Optimization**:
   - **Problem**: Due to floating-point arithmetic, a scale value that should be exactly 1.0 might be represented as 0.9999999 or 1.0000001, triggering unnecessary resizing that introduced artifacts.
   - **Solution**: Added epsilon checks (using a small value of 1e-9) to prevent unnecessary resizing of templates when the scale is effectively 1.0.
   - **Implementation**: Before resizing, the code checks if `Math.abs(currentScale - 1.0) < epsilon`. If true, it uses the original template directly without resizing.
   - **Result**: Better accuracy at the original scale (1.0) without any resizing artifacts.

3. **Implementation Consistency**:
   - The fixes were applied consistently across all template matching methods:
     - `findTemplateMultiScale`: The main method for finding templates with scale checking.
     - `findTemplateDetailedSequential`: A sequential implementation that provides more detailed results.
     - `findTemplateDetailedWithCoroutines`: A coroutine-based implementation that checks multiple scales in parallel.

#### Template Matching Methods

The bot provides several methods for template matching:

1. **findTemplate**: A simple method that returns the location of a template if found.
2. **findTemplateMultiScale**: Checks multiple scales to handle different screen resolutions.
3. **findTemplateDetailed**: Returns comprehensive information about the match, including scale, confidence, and screen resolution.
4. **clickOnTemplate**: Finds a template and clicks on it if found.

#### Optimization Options

The bot supports several optimization options for template matching:

1. **Coroutine-based Parallel Processing** (`--opencvthreads` flag):
   - Uses Kotlin coroutines to check multiple scales in parallel.
   - Significantly faster than the sequential approach, especially with many scales.
   - Thread pool size can be configured with JVM system properties.

2. **Shape-based Matching** (`--shapematching` flag):
   - Uses TM_CCORR_NORMED instead of TM_CCOEFF_NORMED for matching.
   - Focuses more on shapes and contours rather than exact pixel values.
   - More robust to lighting changes and slight variations.

3. **Grayscale Matching** (`--grayscale` flag):
   - Converts both screen capture and template images to grayscale before matching.
   - Improves results when color variations might affect matching accuracy.
   - More robust to lighting changes.

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
     │                       │                           │                          │ can be executed       │
     │                       │                           │                          │                        │
     │                       │                           │                          │ 9.2 Create ActionData │
     │                       │                           │                          │ and use StateMachine  │
     │                       │                           │                          │ to manage action      │
     │                       │                           │                          │ execution             │
```

#### State Machine System

The bot uses a state machine system to manage the execution of actions. This provides a structured way to handle different game states and transitions between them.

##### Bot States

The bot can be in one of the following states:

1. **Idle**: The bot is idle, waiting for an action to be started.
2. **Starting**: The bot is in the process of starting an action. This includes verifying that the game is properly loaded.
3. **Running**: The bot is actively running an action.
4. **Rerunning**: The bot is rerunning the current action (e.g., after clicking a "rerun" button).
5. **OutOfResources**: The bot has detected that it's out of resources for the current action.
6. **PlayerDead**: The bot has detected that the player character has died.
7. **Disconnected**: The bot has detected a disconnection from the game.
8. **Reconnecting**: The bot is attempting to reconnect to the game.
9. **Completed**: The current action has been completed successfully.
10. **Failed**: The current action has failed.

##### State Transitions

The state machine defines valid transitions between states. For example:
- From **Idle** to **Starting** when an action is started
- From **Starting** to **Running** when the action has been successfully started
- From **Running** to **Rerunning** when a rerun button is detected
- From **Running** to **Completed** when the action is completed

##### State Handlers

Each state has a handler function that is executed when the bot enters that state. These handlers perform actions specific to each state, such as:
- **Starting**: Verifies that the game is properly loaded
- **Running**: Monitors the game for various conditions
- **OutOfResources**: Sets the action on cooldown
- **Reconnecting**: Attempts to reconnect to the game

##### ActionData

The ActionData class encapsulates information about an action being executed, including:
- The action name
- The action handler
- The action configuration
- The bot instance
- The current run count
- The maximum run count

This data is passed between state handlers to maintain context during state transitions.

#### Configuration System

The bot uses a YAML-based configuration system that allows users to create, edit, and manage bot configurations through a command-line interface or by directly editing YAML files.

##### Configuration Classes

1. **CharacterConfig**: Contains character-specific settings
   - `characterId`: Unique identifier for the character
   - `characterName`: Display name for the character
   - `accountId`: Identifier for the account this character belongs to
   - `isActive`: Whether this character is currently active

2. **BotConfig**: Contains configuration settings for a specific task or farming goal
   - `configId`: Unique identifier for this configuration
   - `configName`: Display name for this configuration
   - `characterId`: Reference to the character this config belongs to
   - `description`: Description of what this config is for
   - `actionSequence`: List of action names to execute in order (case-insensitive)
   - `actionConfigs`: Map of action names to their configurations (case-insensitive lookup)
   - `defaultAction`: Default action if none specified

3. **ActionConfig**: A sealed class hierarchy that defines configurations for different types of game actions
   - Base properties:
     - `enabled`: Whether this action is enabled
     - `commonActionTemplates`: Templates for general entry/exit/navigation
     - `specificTemplates`: Templates specific to this action
     - `commonTemplateDirectories`: Directories for automatic template loading
     - `specificTemplateDirectories`: Action-specific template directories
     - `useDirectoryBasedTemplates`: Whether to use directory-based template loading
     - `cooldownDuration`: Cooldown duration in minutes when resources are depleted
   - Subclasses:
     - `QuestActionConfig`: Configuration for quest actions
     - `PvpActionConfig`: Configuration for PvP actions
     - `GvgActionConfig`: Configuration for GvG actions
     - `WorldBossActionConfig`: Configuration for World Boss actions
     - `RaidActionConfig`: Configuration for raid actions

##### Configuration Management

The `ConfigManager` class manages all aspects of the configuration system:

1. **Character Management**:
   - Add, edit, and remove characters
   - Set the active character
   - Get character details
   - List all characters

2. **Configuration Management**:
   - Add, edit, and remove configurations
   - Set the active configuration
   - Get configuration details
   - List all configurations
   - Get configurations for a specific character

3. **File Operations**:
   - Initialize configuration directories
   - Save characters and configurations to YAML files
   - Load characters and configurations from YAML files
   - Save and load the active state (which character and config are active)

##### Command-Line Interface

The `ConfigCLI` class provides a command-line interface for managing configurations:

1. **Commands**:
   - `help`: Show help information
   - `list-characters`: List all characters
   - `list-configs`: List all configurations
   - `create-character`: Create a new character
   - `create-config`: Create a new configuration
   - `edit-character <id>`: Edit a character
   - `edit-config <id>`: Edit a configuration
   - `delete-character <id>`: Delete a character
   - `delete-config <id>`: Delete a configuration
   - `activate-character <id>`: Set the active character
   - `activate-config <id>`: Set the active configuration
   - `save`: Save all configurations to files
   - `load`: Load all configurations from files
   - `show-character <id>`: Show details of a character
   - `show-config <id>`: Show details of a configuration
   - `validate`: Validate the current configuration

2. **Usage**:
   - Launch with `--config` flag: `gradlew run --args="--config"`
   - Follow the interactive prompts to manage configurations

##### YAML Serialization

The `YamlUtils` class handles serialization and deserialization of configuration objects:

1. **Features**:
   - Serialize objects to YAML files
   - Deserialize objects from YAML files
   - Serialize objects to YAML strings
   - Deserialize objects from YAML strings
   - Handle polymorphic types (ActionConfig and its subclasses)

2. **Implementation**:
   - Uses Jackson library with YAML factory
   - Configures ObjectMapper for proper YAML formatting
   - Registers subtypes for polymorphic serialization
   - Provides utility methods for file and string operations
