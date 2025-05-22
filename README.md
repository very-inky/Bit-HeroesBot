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

## Coroutines for Parallel Processing

This project uses Kotlin coroutines for parallel processing in two key areas:

1. **Zone Detection**: In the QuestAction class, coroutines allow the bot to check multiple zone templates simultaneously, which can significantly improve performance when determining the current zone.

2. **Template Matching**: In the Bot class, coroutines allow the bot to check multiple scales simultaneously when matching templates, which can significantly improve performance when searching for UI elements.

### Optimized Zone Navigation

The quest action uses different navigation strategies depending on whether the `--morethreads` optimization flag is enabled:

#### With `--morethreads` enabled:
1. Quickly determines the current zone using parallel processing
2. Always navigates directly from the current zone to the target zone
3. Never resets to zone 1, regardless of distance

#### Without `--morethreads`:
1. Determines the current zone sequentially
2. Always resets to zone 1 first for more reliable navigation
3. Navigates from zone 1 to the target zone

Using the `--morethreads` flag provides the most efficient navigation by eliminating unnecessary resets to zone 1.

### Running the Application with Command-Line Arguments

#### Coroutine Optimization Flags

To enable coroutines for zone detection, use the `--morethreads` command-line argument:

```bash
# On Windows
gradlew run --args="--morethreads"

# On Linux/macOS
./gradlew run --args="--morethreads"
```

To enable coroutines for template matching, use the `--opencvthreads` command-line argument:

```bash
# On Windows
gradlew run --args="--opencvthreads"

# On Linux/macOS
./gradlew run --args="--opencvthreads"
```

You can enable both optimizations at once:

```bash
# On Windows
gradlew run --args="--morethreads --opencvthreads"

# On Linux/macOS
./gradlew run --args="--morethreads --opencvthreads"
```

#### Template Testing Mode

To test template matching without running the full automation, use the `--test-pattern` flag:

```bash
# On Windows
gradlew run --args="--test-pattern"

# On Linux/macOS
./gradlew run --args="--test-pattern"
```

You can specify a specific template or directory to test:

```bash
# Test a specific template
gradlew run --args="--test-pattern templates/quest/questicon.png"

# Test all templates in a directory
gradlew run --args="--test-pattern templates/quest"
```

You can combine the `--test-pattern` flag with optimization flags:

```bash
# Test templates with both optimizations enabled
gradlew run --args="--test-pattern templates/quest --morethreads --opencvthreads"
```

### Troubleshooting Coroutines

If the coroutine test fails, here are some things to check:

1. Make sure you have the correct Kotlin coroutines dependency in your build.gradle file:
   ```gradle
   implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:[version]")
   ```

2. Make sure you're using a compatible version of Kotlin and JDK:
   - Kotlin 1.9.0 or newer is recommended for JDK 23
   - JDK 23 or greater

3. Try cleaning and rebuilding the project:
   ```bash
   # On Windows
   gradlew clean build

   # On Linux/macOS
   ./gradlew clean build
   ```

4. If you're still having issues, try adding the coroutines dependency to your project manually:
   - Use the provided scripts to download the coroutines JAR file:
     - On Windows: Run `download-coroutines.bat`
     - On Linux/macOS: Run `./download-coroutines.sh` (you may need to make it executable first with `chmod +x download-coroutines.sh`)
   - The scripts will download the JAR file to a `libs` directory and provide instructions on how to update your build.gradle file
   - Alternatively, you can download the JAR file manually from Maven Central: https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.7.3/
   - Add the following to your build.gradle file:
     ```gradle
     dependencies {
         implementation files('libs/kotlinx-coroutines-core-jvm-1.7.3.jar')
     }
     ```
## Getting Started

1. Ensure you have Java 23 or higher installed (Amazon Corretto JDK 23 recommended)
   - **Windows users**: You can run the included `setup-java.bat` script for automatic installation
   - Or download from [Amazon Corretto 23](https://docs.aws.amazon.com/corretto/latest/corretto-23-ug/downloads-list.html)
   - Run the installer and follow the instructions
   - Make sure to check the option to set JAVA_HOME environment variable
   - Verify installation by opening a new command prompt and typing `java -version`
   - For detailed installation instructions, see [JAVA_INSTALLATION.md](JAVA_INSTALLATION.md)

2. Clone this repository

3. Run the application using Gradle:
   ```
   # On Windows
   .\gradlew run

   # On Linux/macOS
   ./gradlew run
   ```

4. To run with coroutines enabled for parallel processing:
   ```
   # On Windows
   .\gradlew run --args="--morethreads"

   # On Linux/macOS
   ./gradlew run --args="--morethreads"
   ```

5. To test if coroutines are working properly:
   ```
   # On Windows
   .\gradlew testCoroutines

   # On Linux/macOS
   ./gradlew testCoroutines
   ```

   You can also run the tests directly in IntelliJ IDEA. See [INTELLIJ_TESTING.md](INTELLIJ_TESTING.md) for instructions.

6. The first run will automatically download and install OpenCV if needed

7. Place your template images in the appropriate subdirectories of the `templates` folder

## Configuration

See the [documentation](documentation.md) for detailed information on:
- Creating character configurations
- Setting up action sequences
- Managing multiple accounts
- Template matching system
- Testing templates

## Current Development Focus

The current development focus is on full quest action automation, specifically:

1. **Monitor Function / ActionRunning Loop**: Implementing a monitoring system that continuously checks the game state
2. **Rerun Functionality**: Adding the ability to rerun quests or raids without backing out to setup
3. **UI Responsiveness**: Ensuring the bot doesn't process checks faster than the UI can update

For more detailed information on the current state of the project and development priorities, see [devnotes.md](devnotes.md).

## License

[License information]
