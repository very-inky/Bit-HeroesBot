
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

## Template Matching System

The bot uses OpenCV for template matching:

1. Template images are stored in the `templates` directory with subdirectories organized by action type:
   - `raid`: Templates for raid-related actions
   - `quest`: Templates for quest-related actions
   - `pvp`: Templates for PvP-related actions
   - `gvg`: Templates for GvG-related actions
   - `worldboss`: Templates for world boss-related actions
   - `invasion`: Templates for invasion-related actions
   - `expedition`: Templates for expedition-related actions
   - `ui`: Common UI elements and home screen templates
2. The `Bot` class loads templates and provides methods to:
   - Find templates on the screen with configurable matching thresholds
   - Click on matched templates
   - Perform other screen interactions
   - Scale templates based on screen resolution and DPI
   - Get detailed matching information (scale, confidence, etc.)
3. Template registration system tracks original dimensions and DPI for proper scaling

### Pattern Test Mode

The bot includes a pattern test mode that allows testing template matching without running the full automation:

1. Run the bot with the `--test-pattern` argument to enter pattern test mode:
   ```
   java -jar your-bot.jar --test-pattern [template-path]
   ```

2. If a specific template path is provided, the bot will test only that template:
   ```
   java -jar your-bot.jar --test-pattern templates/quest/Untitled.png
   ```

3. If a directory path is provided, the bot will test all templates in that directory:
   ```
   java -jar your-bot.jar --test-pattern templates/quest
   ```

4. The pattern test mode displays comprehensive information about each match:
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
7. ✅ Quest action implementation (placeholder)
8. ✅ Raid action implementation (placeholder)
9. ✅ Account switching functionality

### Partially Implemented

1. ⚠️ Resource checking (currently simulated, needs real screen recognition)
2. ⚠️ Error handling and recovery
3. ⚠️ PvP and GvG action configurations (defined but handlers not implemented)

### Pending Implementation

1. ❌ PvP action implementation
2. ❌ GvG action implementation
3. ❌ World Boss action implementation
4. ❌ Trials action implementation
5. ❌ Expedition action implementation
6. ❌ Gauntlet action implementation
7. ❌ Logging system
8. ❌ UI for configuration

## Current Priorities

1. **Complete Action Implementations**: Implement the remaining game actions (PvP, GvG, etc.)
2. **Improve Resource Detection**: Replace simulated resource checking with actual screen recognition
3. **Error Handling**: Enhance error recovery mechanisms
4. **Testing Framework**: Develop a testing framework for actions
5. **Configuration UI**: Create a user interface for configuration management
6. **Multi-Account Automation**: Enhance account switching with automatic login

## Usage

1. Create characters and configurations using the ConfigManager
2. Set the active character and configuration
3. Place template images in the `templates` directory
4. Run the application to start the bot with the active configuration

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
            commonActionTemplates = listOf("templates/quest/Untitled.png"),
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true),
                QuestActionConfig.DungeonTarget(zoneNumber = 6, dungeonNumber = 3, enabled = true)
            ),
            repeatCount = 0, // Run until out of resources
            cooldownDuration = 20 // 20 minute cooldown when resources are depleted
        ),
        "Raid" to RaidActionConfig(
            enabled = true,
            commonActionTemplates = emptyList(),
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
            commonActionTemplates = listOf("templates/quest/quest_button.png"),
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 7, dungeonNumber = 3, enabled = true),
                QuestActionConfig.DungeonTarget(zoneNumber = 8, dungeonNumber = 5, enabled = true)
            ),
            repeatCount = 0, // Run until resources are depleted
            cooldownDuration = 30 // 30 minute cooldown
        ),
        "Raid" to RaidActionConfig(
            enabled = true,
            commonActionTemplates = listOf("templates/raid/raid_button.png"),
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
            commonActionTemplates = listOf("templates/pvp/pvp_button.png"),
            ticketsToUse = 5, // Use all 5 tickets
            opponentRank = 3 // Target rank 3 opponents
        ),
        "GvG" to GvgActionConfig(
            enabled = true,
            commonActionTemplates = listOf("templates/gvg/gvg_button.png"),
            badgeChoice = 4, // Use badge type 4
            opponentChoice = 2 // Target opponent 2
        ),
        "Quest" to QuestActionConfig(
            enabled = true,
            commonActionTemplates = listOf("templates/quest/quest_button.png"),
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 10, dungeonNumber = 1, enabled = true)
            ),
            repeatCount = 3, // Only run 3 times
            cooldownDuration = 15 // 15 minute cooldown
        )
    )
)
```
