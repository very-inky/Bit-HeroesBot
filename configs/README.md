# Orion Bot Configuration System

This directory contains the YAML configuration files for the Orion Bot. The configuration system allows you to create, edit, and manage bot configurations through a command-line interface or by directly editing the YAML files.

## Directory Structure

- `configs/` - The main configuration directory
  - `characters/` - Contains character configuration files
  - `botconfigs/` - Contains bot configuration files
  - `active_state.yaml` - Stores which character and configuration are currently active

## Using the Configuration CLI

To launch the configuration CLI, run the bot with the `--config` flag:

```
java -jar orion.jar --config
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
actionConfigs:
  Quest:
    enabled: true
    commonActionTemplates:
    - "templates/quest/Untitled.png"
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
    repeatCount: 0
    cooldownDuration: 1
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
      difficulty: "Heroic"
      enabled: true
    runCount: 0
    cooldownDuration: 1
```

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