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

### Screen Capture Method

The bot uses Java's Robot.createScreenCapture method for capturing the screen. This approach was chosen for better compatibility across different systems after testing showed that the multi-resolution screen capture method (Robot.createMultiResolutionScreenCapture) caused issues on some configurations. The standard screen capture method provides more consistent results across different environments.

### Memory Management for OpenCV Mat Objects

OpenCV's Mat objects use native memory that must be explicitly released:

- Mat objects are not automatically managed by Java's garbage collector
- The bot handles memory management in two ways:
  - Methods that use Mat objects internally release them before returning
  - Methods that return Mat objects document that the caller is responsible for releasing them
- Always call `mat.release()` when you're done with a Mat object that was returned from a method
- Failure to release Mat objects will result in memory leaks


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

#### Command-Line Arguments

##### Coroutine Optimization Flags

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

##### Template Matching Enhancement Flags

To enable shape-based template matching, use the `--shapematching` command-line argument:

```bash
# On Windows
gradlew run --args="--shapematching"

# On Linux/macOS
./gradlew run --args="--shapematching"
```

This uses a different matching algorithm (TM_CCORR_NORMED instead of TM_CCOEFF_NORMED) that focuses more on shapes and contours rather than exact pixel values, which can be more robust to lighting changes and slight variations.

To enable grayscale template matching, use the `--grayscale` command-line argument:

```bash
# On Windows
gradlew run --args="--grayscale"

# On Linux/macOS
./gradlew run --args="--grayscale"
```

This converts both the screen capture and template images to grayscale before matching, which can improve results when color variations might affect matching accuracy.

##### Combining Multiple Flags

You can combine multiple optimization and enhancement flags:

```bash
# On Windows
gradlew run --args="--morethreads --opencvthreads --shapematching --grayscale"

# On Linux/macOS
./gradlew run --args="--morethreads --opencvthreads --shapematching --grayscale"
```

#### Configuring Thread Count for `--opencvthreads`

By default, the `--opencvthreads` flag uses a thread pool with a size equal to the number of available processors. On systems with many cores/threads (e.g., 16 cores/32 threads), you might want to limit the number of threads used to reduce CPU usage.

When configuring thread count, it's important to understand the difference between:
- **Program arguments**: Passed directly to the application (e.g., `--opencvthreads`)
- **VM arguments**: JVM system properties that configure the Java Virtual Machine (e.g., `-Dkotlinx.coroutines.scheduler.max.pool.size=8`)

You can configure the thread count by setting JVM system properties:

```bash
# On Windows - Limit to 8 threads
# Program argument: --opencvthreads
# VM arguments: -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
gradlew run --args="--opencvthreads" -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8

# On Linux/macOS - Limit to 8 threads
# Program argument: --opencvthreads
# VM arguments: -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
./gradlew run --args="--opencvthreads" -Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
```

In IntelliJ IDEA run configurations:
- Add `--opencvthreads` to the **Program arguments** field
- Add the following to the **VM options** field:
```
-Dkotlinx.coroutines.scheduler.max.pool.size=8 -Dkotlinx.coroutines.scheduler.core.pool.size=8
```

**Important**: Both VM properties must be set, and the max pool size must be greater than or equal to the core pool size.

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

### Recent Improvements
The following improvements have been implemented:

1. **Action Monitoring System**: 
   - Added an `actionMonitor` function in ActionManager that centralizes monitoring logic
   - Checks for cooldowns, run counts, and resource availability
   - Provides a consistent interface for all actions
   - Makes it easier to add more checks in the future

2. **Resource Management**:
   - Extracted resource availability check to a dedicated `isOutOfResources` function
   - Improved separation of concerns with single-responsibility functions
   - Enhanced testability with unit tests for resource logic
   - Allows resource checks to be called from anywhere in the codebase

3. **Action Handler Refactoring**:
   - Updated action handlers to use the new monitoring system
   - Removed duplicate code for checking if actions are enabled
   - Improved consistency across different action types
   - Enhanced maintainability by centralizing monitoring logic

4. **ActionRunning Loop**:
   - Implemented a continuous monitoring system that checks the game state in real-time
   - Added `monitorRunningAction` method in ActionManager that:
     - Performs a one-time autopilot check at the beginning of monitoring
     - Detects player death and handles recovery
     - Detects player disconnection and handles reconnection
     - Detects and handles in-progress dialogues without interrupting the action
     - Uses town.png as the primary indicator of action completion
     - Checks for template file availability for robustness
     - Provides configurable monitoring intervals for performance tuning
     - Includes heartbeat logging to confirm monitoring is active
     - Returns detailed results about the action's status
   - This allows the bot to respond to changes in the game UI in real-time

5. **Rerun Functionality**:
   - Implemented the ability to rerun quests or raids without backing out to setup
   - Added detection for the "Rerun" button in the monitoring loop
   - Added logic to use the rerun button when appropriate instead of backing out to setup
   - Implemented proper handling of resource checks after clicking rerun
   - Implemented smart config handling:
     - Quest and Raid actions with a single enabled target use the rerun button
     - Quest and Raid actions with multiple enabled targets use the town button to change configs
     - Other actions always use the town button to go back to setup
   - This improves efficiency by eliminating unnecessary navigation

### Ongoing Development
The current development focus is on improving the action system and UI responsiveness:

1. **UI Responsiveness**:
   - Ensuring the bot doesn't process checks faster than the UI can update
   - Adding appropriate delays for resource checks and completion detection

2. **Enhanced Monitoring System**:
   - Adding more templates for detecting various game states
   - Improving error handling and recovery mechanisms
   - Adding more robust handling of unexpected game states
   - Implementing configurable monitoring timeouts

3. **Improved Rerun Functionality**:
   - Adding support for more complex rerun scenarios
   - Implementing better handling of rerun failures
   - Adding configurable rerun limits

For more detailed information on the current state of the project and development priorities, see [devnotes.md](devnotes.md).

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0) - see the [LICENSE](LICENSE) file for details.

The GPL-3.0 is a strong copyleft license that requires anyone who distributes your code or a derivative work to make the source available under the same terms. This is particularly suitable for libraries and applications where you want to ensure that all modifications and derived works remain open source.
