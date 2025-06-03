# Orion Bot Configuration System

This directory contains the YAML configuration files for the Orion Bot. The configuration system allows you to create, edit, and manage bot configurations through a command-line interface or by directly editing the YAML files.

## Directory Structure

- `configs/` - The main configuration directory
  - `characters/` - Contains character configuration files
  - `botconfigs/` - Contains bot configuration files
  - `active_state.yaml` - Stores which character and configuration are currently active

## Using the Configuration CLI

To launch the configuration CLI, run the bot with the `--config` flag:

```bash
# On Windows
gradlew run --args="--config"

# On Linux/macOS
./gradlew run --args="--config"
```

The CLI provides the following commands:

- `help` - Show help information
- `exit`, `quit` - Exit the configuration manager
- `list-characters` - List all characters
- `list-configs` - List all configurations
- `create-character` - Create a new character
- `create-config` - Create a new configuration
- `edit-character <id>` - Edit a character
- `edit-config <id>` - Edit a configuration
- `delete-character <id>` - Delete a character
- `delete-config <id>` - Delete a configuration
- `activate-character <id>` - Set the active character
- `activate-config <id>` - Set the active configuration
- `save` - Save all configurations to files
- `load` - Load all configurations from files
- `show-character <id>` - Show details of a character
- `show-config <id>` - Show details of a configuration
- `validate` - Validate the current configuration

## YAML Configuration Format

### Character Configuration

Character configurations are stored in the `characters/` directory with the character ID as the filename.

Example character configuration:

```yaml
---
characterId: "550e8400-e29b-41d4-a716-446655440000"
characterName: "MyHero"
accountId: "default"
isActive: true
```

### Bot Configuration

Bot configurations are stored in the `botconfigs/` directory with the configuration ID as the filename.

Example bot configuration:

```yaml
---
configId: "550e8400-e29b-41d4-a716-446655440001"
configName: "Daily Farming"
characterId: "550e8400-e29b-41d4-a716-446655440000"
description: "Configuration for daily farming tasks"
actionSequence:
- "Quest"
- "Raid"
- "PvP"
- "GvG"
- "WorldBoss"
actionConfigs:
  Quest:
    enabled: true
    commonActionTemplates: []
    specificTemplates: []
    commonTemplateDirectories:
    - "templates/ui"
    specificTemplateDirectories:
    - "templates/quest"
    useDirectoryBasedTemplates: true
    dungeonTargets:
    - zoneNumber: 1
      dungeonNumber: 2
      difficulty: "heroic"
      enabled: true
    - zoneNumber: 6
      dungeonNumber: 3
      difficulty: "heroic"
      enabled: true
    repeatCount: 3
    cooldownDuration: 20
  Raid:
    enabled: true
    commonActionTemplates: []
    specificTemplates: []
    commonTemplateDirectories:
    - "templates/ui"
    specificTemplateDirectories:
    - "templates/raid"
    useDirectoryBasedTemplates: true
    raidTargets:
    - raidName: "SomeRaidBoss"
      raidNumber: 3
      tierNumber: 6
      difficulty: "Heroic"
      enabled: true
    runCount: 3
    cooldownDuration: 20
  PvP:
    enabled: true
    commonActionTemplates: []
    specificTemplates: []
    commonTemplateDirectories:
    - "templates/ui"
    specificTemplateDirectories:
    - "templates/pvp"
    useDirectoryBasedTemplates: true
    ticketsToUse: 5
    pvpOpponentChoice: 2
    autoSelectOpponent: false
  GvG:
    enabled: true
    commonActionTemplates: []
    specificTemplates: []
    commonTemplateDirectories:
    - "templates/ui"
    specificTemplateDirectories:
    - "templates/gvg"
    useDirectoryBasedTemplates: true
    badgeChoice: 5
    opponentChoice: 1
  WorldBoss:
    enabled: true
    commonActionTemplates: []
    specificTemplates: []
    commonTemplateDirectories:
    - "templates/ui"
    specificTemplateDirectories:
    - "templates/worldboss"
    useDirectoryBasedTemplates: true
```

## Template System

The bot uses a directory-based template system for image recognition. Templates are organized in the `templates` directory with the following structure:

```
templates/
├── ui/             # Common UI elements used across all actions
├── quest/          # Quest-specific templates
├── raid/           # Raid-specific templates
├── pvp/            # PvP-specific templates
├── gvg/            # GvG-specific templates
├── worldboss/      # World Boss-specific templates
├── invasion/       # Invasion-specific templates
├── expedition/     # Expedition-specific templates
└── blueprint/      # Blueprint-specific templates
```

Each action configuration can specify:
- `commonTemplateDirectories`: Directories containing common UI templates (usually `templates/ui`)
- `specificTemplateDirectories`: Directories containing action-specific templates (e.g., `templates/quest`)
- `useDirectoryBasedTemplates`: Whether to load all templates from the specified directories
- `commonActionTemplates`: Specific template files for common UI elements
- `specificTemplates`: Specific template files for this action type

When `useDirectoryBasedTemplates` is set to `true`, the bot will automatically load all template files from the specified directories. This is the recommended approach as it simplifies configuration and ensures all necessary templates are available.

## Editing YAML Files Directly

You can edit the YAML files directly with a text editor. After editing, restart the bot or use the `load` command in the CLI to reload the configurations.

When editing YAML files, be careful to maintain the correct indentation and structure. YAML is sensitive to whitespace.

## Default Configurations

If no configurations are found when the bot starts, it will create default configurations automatically. You can use these as a starting point for your own configurations.

## Troubleshooting

If you encounter issues with your configurations:

1. Use the `validate` command in the CLI to check for configuration errors
2. Check the YAML syntax for errors (indentation, missing quotes, etc.)
3. Make sure character IDs referenced in bot configurations exist
4. Ensure template paths are correct and the templates exist

## Notes

- **Action Names**: Action names in the `actionSequence` and `actionConfigs` are case-insensitive. For example, "pvp", "PvP", and "PVP" are all treated as the same action. However, for consistency, it's recommended to use the standard capitalization in your configurations (e.g., "Quest", "Raid", "PvP").
- **Difficulty Levels**: Difficulty levels for Quest and Raid actions are also case-insensitive. For example, "heroic", "Heroic", and "HEROIC" are all treated as the same difficulty. Quest difficulty is stored in lowercase (e.g., "heroic"), while Raid difficulty is stored with the first letter capitalized (e.g., "Heroic").
- **Other Inputs**: Most other inputs in the configuration system are also case-insensitive, including yes/no responses and action-specific inputs. The only things that are case-sensitive are IDs (e.g., character IDs, config IDs).
