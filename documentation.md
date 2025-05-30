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
     │                       │                           │                         
