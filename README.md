# Game Automation Bot

A Kotlin-based automation bot for games using OpenCV for image recognition. The bot automates repetitive tasks by identifying screen elements through template matching and simulating user interactions.

## Features

- **Multi-character support**: Manage multiple characters and accounts
- **Configurable action sequences**: Create custom automation profiles for different gameplay goals
- **Template-based recognition**: Identify game elements using template images
- **Resource management**: Automatically handle cooldowns and resource depletion
- **Automatic dependency management**: OpenCV libraries are automatically downloaded and installed if needed

## Template System

Templates are organized in the `templates` directory with the following structure:

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
└── characters/     # Character-specific templates --currently unused but this will be utilized for NFT handoff functionality later
```

The bot loads templates from these directories based on the action being executed:
- Common UI elements are loaded from the `templates/ui` directory
- Action-specific templates are loaded from their respective directories (e.g., `templates/quest` for quest actions)

## Auto Dependency Functionality

The bot requires OpenCV for image recognition and template matching. The application automatically:

1. Checks if the OpenCV native library is present in the correct location
2. If not found or only partially loaded, downloads the complete library
3. Installs the library in the appropriate resources folder for future use
4. Verifies that full functionality is available before running

The bot will not run in partial functionality mode - it requires full OpenCV functionality to operate correctly.
OpenCV should enable OpenCL by default (GPU hardware acceleration). This requires that you have drivers properly installed and openCL drivers properly working (Linux systems)
## Getting Started

1. Ensure you have Java 11 or higher installed
2. Clone this repository
3. Run the application using Gradle:
   ```
   ./gradlew run
   ```
4. The first run will automatically download and install OpenCV if needed
5. Place your template images in the appropriate subdirectories of the `templates` folder

## Configuration

See the [documentation](documentation.md) for detailed information on:
- Creating character configurations
- Setting up action sequences
- Managing multiple accounts
- Template matching system
- Testing templates

## License

[License information]
