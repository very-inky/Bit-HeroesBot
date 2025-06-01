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
7. **ConfigManager**: Manages multiple characters and configurations, ensuring only one is active at a time.
8. **CharacterConfig**: Contains character-specific settings and account information.
9. **BotConfig**: Contains configuration settings for a specific task or farming goal, linked to a character.
10. **ActionConfig**: A sealed class hierarchy that defines configurations for different types of game actions.

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
