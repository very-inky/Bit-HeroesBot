/*
 * Orion / Bit-HeroesBot
 * By VeryInky
 * A free and open-source bot for Bit Heroes
 * Copyright (C) 2023-2024
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package orion

import orion.actions.QuestAction
import orion.actions.RaidAction
// BotConfig, QuestActionConfig, PvpActionConfig, RaidActionConfig, RaidTarget, ActionManager
// are now expected to be available if they are in the 'orion' package or subpackages.
// Ensure their package declarations are also 'orion' or 'orion.something'
import org.opencv.core.Core
import java.io.File
import java.nio.file.Paths
import java.util.UUID
import java.util.Vector //unused
import orion.utils.PathUtils
import orion.utils.YamlUtils
import java.awt.Robot
import java.awt.event.InputEvent

fun main(args: Array<String>) {
    println("Starting OpenCV Bot...")

    // Process command-line arguments
    val isPatternTestMode = args.contains("--test-pattern")
    val isCoroutineTestMode = args.contains("--test-coroutines")
    val isConfigMode = args.contains("--config")

    // Check if we should use coroutines for zone detection
    val useMoreThreads = args.contains("--morethreads")
    if (useMoreThreads) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ OPTIMIZATION: Using coroutines for parallel zone detection     ║")
        println("║ (--morethreads flag detected)                                  ║")
        println("║                                                                ║")
        println("║ This should improve performance when determining the current   ║")
        println("║ zone in quest actions by checking multiple zone templates      ║")
        println("║ simultaneously instead of sequentially.                        ║")
        println("╚════════════════════════════════════════════════════════════════╝")
        orion.actions.QuestAction.useCoroutines = true
    } else {
        println("Using sequential zone detection (use --morethreads flag to enable parallel processing)")
    }

    // Check if we should use coroutines for OpenCV template matching
    val useOpenCVThreads = args.contains("--opencvthreads")
    if (useOpenCVThreads) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ OPTIMIZATION: Using coroutines for parallel template matching  ║")
        println("║ (--opencvthreads flag detected)                                ║")
        println("║                                                                ║")
        println("║ This should improve performance when matching templates with   ║")
        println("║ multiple scales by checking all scales simultaneously instead  ║")
        println("║ of sequentially.                                               ║")
        println("╚════════════════════════════════════════════════════════════════╝")
        orion.Bot.useCoroutinesForTemplateMatching = true

        // Display thread pool size configuration
        val maxPoolSize = System.getProperty("kotlinx.coroutines.scheduler.max.pool.size") ?: "default"
        val corePoolSize = System.getProperty("kotlinx.coroutines.scheduler.core.pool.size") ?: "default"
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ THREAD POOL CONFIGURATION                                      ║")
        println("║ Max pool size: $maxPoolSize                                    ".padEnd(72) + "║")
        println("║ Core pool size: $corePoolSize                                   ".padEnd(72) + "║")
        println("╚════════════════════════════════════════════════════════════════╝")
    } else {
        println("Using sequential template matching (use --opencvthreads flag to enable parallel processing)")
    }

    // Check if we should use shape matching for template detection
    val useShapeMatching = args.contains("--shapematching")
    if (useShapeMatching) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ EXPERIMENTAL: Using shape-based template matching              ║")
        println("║ (--shapematching flag detected)                                ║")
        println("║                                                                ║")
        println("║ This uses a different matching algorithm that focuses more on  ║")
        println("║ shapes and contours rather than exact pixel values, which can  ║")
        println("║ be more robust to lighting changes and slight variations.      ║")
        println("╚════════════════════════════════════════════════════════════════╝")
        orion.Bot.useShapeMatching = true
    } else {
        println("Using standard template matching (use --shapematching flag to enable shape-based matching)")
    }

    // Check if we should use grayscale mode for template detection
    val useGrayscale = args.contains("--grayscale")
    if (useGrayscale) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ EXPERIMENTAL: Using grayscale template matching                ║")
        println("║ (--grayscale flag detected)                                    ║")
        println("║                                                                ║")
        println("║ This converts both the screen capture and template images to   ║")
        println("║ grayscale before matching, which can improve results when      ║")
        println("║ color variations might affect matching accuracy.               ║")
        println("╚════════════════════════════════════════════════════════════════╝")
        orion.Bot.useGrayscale = true
    } else {
        println("Using color template matching (use --grayscale flag to enable grayscale matching)")
    }

    // Check if we should enable verbose template matching output
    val useVerbose = args.contains("--verbose")
    if (useVerbose) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ VERBOSE: Enabling detailed template matching output            ║")
        println("║ (--verbose flag detected)                                      ║")
        println("║                                                                ║")
        println("║ This provides detailed information about template matching     ║")
        println("║ operations, including what is being searched for and the       ║")
        println("║ details of matches found.                                      ║")
        println("╚════════════════════════════════════════════════════════════════╝")
    } else {
        println("Using standard output (use --verbose flag to enable detailed template matching output)")
    }

    // Test if coroutines are working properly
    if (isCoroutineTestMode) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ COROUTINE TEST MODE                                            ║")
        println("║ Testing if coroutines are working properly...                  ║")
        println("╚════════════════════════════════════════════════════════════════╝")

        val coroutinesWorking = CoroutineTest.runTest()

        if (coroutinesWorking) {
            println("╔════════════════════════════════════════════════════════════════╗")
            println("║ COROUTINE TEST PASSED                                          ║")
            println("║ Coroutines are working properly!                               ║")
            println("╚════════════════════════════════════════════════════════════════╝")
        } else {
            println("╔════════════════════════════════════════════════════════════════╗")
            println("║ COROUTINE TEST FAILED                                          ║")
            println("║ Coroutines are NOT working properly!                           ║")
            println("╚════════════════════════════════════════════════════════════════╝")
        }

        // Exit after the test
        return
    }

    // Launch configuration CLI if requested
    if (isConfigMode) {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ CONFIGURATION MODE                                             ║")
        println("║ Launching configuration manager...                             ║")
        println("╚════════════════════════════════════════════════════════════════╝")

        val configManager = ConfigManager()
        val configCLI = ConfigCLI(configManager)
        configCLI.start()

        // Exit after configuration management
        return
    }

    // Load OpenCV native library - full functionality is required
    loadOpenCVNativeLibrary()

    if (isPatternTestMode) {
        // Get the template path from arguments or use a default
        val templatePath = if (args.contains("--test-pattern")) {
            val testPatternIndex = args.indexOf("--test-pattern")
            if (testPatternIndex < args.size - 1 && !args[testPatternIndex + 1].startsWith("--")) {
                args[testPatternIndex + 1]
            } else {
                "templates"
            }
        } else {
            "templates"
        }

        // Create a simple bot instance without full configuration
        val bot = Bot(BotConfig(
            configId = "test-config",
            configName = "Test Config",
            characterId = "test-character",
            description = "Configuration for pattern testing",
            actionSequence = emptyList(),
            actionConfigs = emptyMap()
        ))

        // Set template matching verbosity if --verbose flag is detected
        if (useVerbose) {
            bot.templateMatchingVerbosity = true
        }

        bot.initialize()

        // Display screen information
        val screenSize = bot.getScreenResolution()
        val dpi = bot.getSystemDPIScaling()
        println("Screen Resolution: ${screenSize.first}x${screenSize.second}")
        println("System DPI Scaling: ${dpi * 100}%")

        // Check if we're testing a specific template or a directory
        val file = File(templatePath)
        if (file.isFile) {
            // Test a specific template
            println("Testing specific template: $templatePath")
            val result = bot.findTemplateDetailed(templatePath)

            if (result.location != null) {
                println("✅ Found template at position: ${result.location}")
                println("   Scale: ${result.scale}")
                println("   Confidence: ${result.confidence}")
                println("   Screen Resolution: ${result.screenResolution.first}x${result.screenResolution.second}")
                println("   DPI Scaling: ${result.dpi * 100}%")
                // Move mouse cursor to found location
                val x = result.location.x.toInt()
                val y = result.location.y.toInt()
                try {
                    val robot = Robot()
                    robot.mouseMove(x, y)
                    println("Moved mouse cursor to: ($x, $y)")
                } catch (e: Exception) {
                    println("Failed to move mouse cursor: ${e.message}")
                }
            } else {
                println("❌ Could not find template")
                println("   Best scale attempted: ${result.scale}")
                println("   Best confidence: ${result.confidence}")
                println("   Screen Resolution: ${result.screenResolution.first}x${result.screenResolution.second}")
                println("   DPI Scaling: ${result.dpi * 100}%")
            }
        } else {
            // Load templates from directory
            println("Loading templates from: $templatePath")
            val count = bot.loadTemplatesFromDirectory(templatePath)
            println("Loaded $count templates")

            // Get all templates
            val allTemplates = bot.getAllTemplates()
            println("Available templates: ${allTemplates.joinToString("\n")}")

            // Test each template
            println("\nTesting templates on current screen:")
            allTemplates.forEach { template ->
                val result = bot.findTemplateDetailed(template)

                if (result.location != null) {
                    println("✅ Found template: $template")
                    println("   Position: ${result.location}")
                    println("   Scale: ${result.scale}")
                    println("   Confidence: ${result.confidence}")
                    // Move mouse cursor to found location
                    val x = result.location.x.toInt()
                    val y = result.location.y.toInt()
                    try {
                        val robot = Robot()
                        robot.mouseMove(x, y)
                        println("Moved mouse cursor to: ($x, $y)")
                    } catch (e: Exception) {
                        println("Failed to move mouse cursor: ${e.message}")
                    }
                } else {
                    println("❌ Could not find template: $template")
                    println("   Best scale attempted: ${result.scale}")
                    println("   Best confidence: ${result.confidence}")
                }
            }

            // Print screen information once for all templates
            println("\nScreen Resolution: ${screenSize.first}x${screenSize.second}")
            println("System DPI Scaling: ${dpi * 100}%")
        }

        println("\nPattern test completed")
        return
    }

    // --- Configuration Setup ---
    // Create a configuration manager to handle multiple configurations
    val configManager = ConfigManager()

    // Initialize configuration directories
    configManager.initConfigDirectories()

    // Try to load existing configurations from YAML files
    println("Checking for existing configurations...")
    val configsLoaded = configManager.loadAllFromFiles()

    if (configsLoaded) {
        println("Loaded existing configurations from YAML files.")

        // Show active character and config if any
        val activeCharacter = configManager.getActiveCharacter()
        val activeConfig = configManager.getActiveConfig()

        if (activeCharacter != null) {
            println("Active character: ${activeCharacter.characterName} (${activeCharacter.characterId})")
        } else {
            println("No active character.")
        }

        if (activeConfig != null) {
            println("Active configuration: ${activeConfig.configName} (${activeConfig.configId})")
        } else {
            println("No active configuration.")
        }
    } else {
        println("No existing configurations found. Creating default configurations...")

        // Create a default character
        val heroCharacterId = UUID.randomUUID().toString()
        val heroCharacter = CharacterConfig(
            characterId = heroCharacterId,
            characterName = "DefaultHero"
        )
        configManager.addCharacter(heroCharacter)
        println("Added default character: ${heroCharacter.characterName} (ID: ${heroCharacter.characterId})")

        // Create a default configuration for the character
        val defaultConfigId = UUID.randomUUID().toString()
        val defaultConfig = BotConfig(
            configId = defaultConfigId,
            configName = "Default Configuration",
            characterId = heroCharacterId,
            description = "Default configuration created automatically",
            actionSequence = listOf("Quest"),
            actionConfigs = mapOf(
                "Quest" to QuestActionConfig(
                    enabled = true,
                    commonActionTemplates = listOf(PathUtils.templatePath("quest", "Untitled.png")),
                    dungeonTargets = listOf(
                        QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 1, enabled = true)
                    ),
                    repeatCount = 3
                )
            )
        )
        configManager.addConfig(defaultConfig)
        println("Added default configuration: ${defaultConfig.configName} (ID: ${defaultConfig.configId})")

        // Activate the default character and configuration
        try {
            configManager.setActiveCharacter(heroCharacterId)
            configManager.setActiveConfig(defaultConfigId)
            println("Activated default character and configuration.")

            // Save the default configurations to YAML files
            configManager.saveAllToFiles()
            println("Saved default configurations to YAML files.")
        } catch (e: IllegalStateException) {
            println("Error activating default character or configuration: ${e.message}")
        }
    }

    // Validate the configuration
    try {
        configManager.validateConfiguration()
        println("Configuration validated successfully.")
    } catch (e: IllegalStateException) {
        println("Configuration validation failed: ${e.message}")
    }

    // Get the active configuration for running the bot
    val activeConfig = configManager.getActiveConfig()
    if (activeConfig != null) {
        println("\n=== Running Bot with Active Configuration ===")
        println("Active configuration: ${activeConfig.configName} for character: ${configManager.getCharacter(activeConfig.characterId)?.characterName}")

        // Create and initialize the bot with the active configuration and ConfigManager
        val bot = Bot(activeConfig, configManager)

        // Set template matching verbosity if --verbose flag is detected
        if (useVerbose) {
            bot.templateMatchingVerbosity = true
        }

        bot.initialize()

        // Check if templates directory exists and load templates
        val templatesDir = "templates"
        if (bot.createTemplateDirectory(templatesDir)) {
            if (File(templatesDir).exists()) {
                println("Loading all available templates from directory: $templatesDir")
                val count = bot.loadTemplatesFromDirectory(templatesDir)
                println("Registered $count template images with the bot.")

                val categories = listOf("raid", "quest", "pvp", "gvg", "worldboss", "invasion", "expedition", "ui")
                categories.forEach { category ->
                    val templates = bot.getTemplatesByCategory(category)
                    if (templates.isNotEmpty()) {
                        println("Category '$category' contains: ${templates.size} templates: ${templates.joinToString()}")
                    }
                }
            }
        } else {
            println("Could not create or access templates directory: $templatesDir. Bot may not find templates.")
        }

        // Use ActionManager to run the sequence with ConfigManager
        val actionManager = ActionManager(bot, activeConfig, configManager)
        actionManager.runActionSequence()
    } else {
        println("No active configuration found. Cannot start the bot.")
    }

    println("\nMain function finished.")
}

/**
 * Load the OpenCV native library
 * 
 * This function ensures that the full OpenCV native library is loaded with all functionality.
 * If the library is not present or only partially loaded, it will download the complete library
 * and store it in the appropriate resources folder for future use.
 * 
 * The function will throw an exception if full functionality is not available, as the bot
 * requires full OpenCV functionality to work properly.
 */
fun loadOpenCVNativeLibrary() {
    try {
        // Get system information for debugging
        val osName = System.getProperty("os.name")
        val osArch = System.getProperty("os.arch")
        println("Operating System: $osName")
        println("Architecture: $osArch")
        println("Current directory: ${Paths.get("").toAbsolutePath()}")

        // Determine the appropriate library path based on OS and architecture
        val osDirectory = when {
            osName.contains("Windows", ignoreCase = true) -> "windows"
            osName.contains("Linux", ignoreCase = true) -> "linux"
            osName.contains("Mac", ignoreCase = true) -> "macos"
            else -> throw UnsatisfiedLinkError("Unsupported operating system: $osName")
        }

        val archDirectory = when {
            osArch.contains("64") && osDirectory != "macos" -> "x64"
            osDirectory != "macos" -> "x86"
            else -> "" // macOS doesn't have separate architecture directories
        }

        val libraryFileName = when {
            osDirectory == "windows" -> "opencv_java4110.dll"
            osDirectory == "linux" -> "libopencv_java4110.so"
            osDirectory == "macos" -> "libopencv_java4110.dylib"
            else -> throw UnsatisfiedLinkError("Unsupported operating system: $osName")
        }

        // Create the full path to where the library should be stored
        val resourcesPath = if (archDirectory.isEmpty()) {
            PathUtils.buildPath("src", "main", "resources", "natives", osDirectory)
        } else {
            PathUtils.buildPath("src", "main", "resources", "natives", osDirectory, archDirectory)
        }

        val libraryPath = PathUtils.buildPath(resourcesPath, libraryFileName)
        val libraryFile = File(libraryPath)

        // Check if the library already exists in the resources folder
        var fullFunctionality = false
        if (libraryFile.exists()) {
            println("Found existing OpenCV library in resources: $libraryPath")
            try {
                // Try to load the library from resources
                System.load(libraryFile.absolutePath)

                // Verify that we have full functionality
                try {
                    val buildInfo = Core.getBuildInformation()
                    println("OpenCV fully loaded with all functionality from resources")
                    fullFunctionality = true

                    // Check OpenCL status
                    val openCLInfo = if (buildInfo.contains("OpenCL:") || buildInfo.contains("OpenCL")) {
                        val openCLLine = buildInfo.lines().find { it.contains("OpenCL:") || it.contains("OpenCL") }
                        openCLLine ?: "OpenCL information not found in build info"
                    } else {
                        "OpenCL information not found in build info"
                    }
                    println("OpenCL status: $openCLInfo")
                    // OpenCL status reporting YES (NVD3D11) is not indicative of what vendor you are using.
                    // openCV uses Nvidia's openCL implementation, but this is vendor neutral
                    // Successfully loaded with full functionality, return
                    return
                } catch (e: UnsatisfiedLinkError) {
                    println("Warning: OpenCV is partially loaded from resources. Full functionality is not available.")
                    println("Error: ${e.message}")
                    println("Will attempt to download a complete version...")

                    // Delete the existing library file since it doesn't provide full functionality
                    libraryFile.delete()
                    println("Deleted existing library file that didn't provide full functionality")
                }
            } catch (e: UnsatisfiedLinkError) {
                println("Failed to load existing OpenCV library from resources: ${e.message}")
                println("Will attempt to download a fresh copy...")

                // Delete the existing library file since it couldn't be loaded
                libraryFile.delete()
                println("Deleted existing library file that couldn't be loaded")
            }
        }

        // If we get here, we need to download the library
        println("Attempting to download and install OpenCV with full functionality...")

        // First, ensure the resources directory structure exists
        val resourcesDir = File(resourcesPath)
        if (!resourcesDir.exists()) {
            println("Creating resources directory structure: ${resourcesDir.absolutePath}")
            try {
                // Create parent directories first
                val parentDir = resourcesDir.parentFile
                if (parentDir != null && !parentDir.exists()) {
                    val parentCreated = parentDir.mkdirs()
                    println("Created parent directory: $parentCreated")
                }

                // Now create the resources directory
                val created = resourcesDir.mkdirs()
                if (created) {
                    println("Successfully created resources directory")
                } else {
                    println("Failed to create resources directory. Will try alternative approach.")
                    // Try to create each directory in the path individually
                    val path = PathUtils.normalizePath(resourcesPath)
                    val dirs = path.split(File.separatorChar)
                    var currentPath = ""
                    for (dir in dirs) {
                        if (dir.isEmpty()) continue
                        currentPath = if (currentPath.isEmpty()) {
                            dir
                        } else {
                            PathUtils.buildPath(currentPath, dir)
                        }
                        val currentDir = File(currentPath)
                        if (!currentDir.exists()) {
                            val success = currentDir.mkdir()
                            println("Creating directory $currentPath: $success")
                        }
                    }
                }
            } catch (e: Exception) {
                println("ERROR: Failed to create resources directory: ${e.message}")
                e.printStackTrace()
            }
        }

        // Verify that the resources directory exists
        if (!resourcesDir.exists()) {
            println("WARNING: Resources directory does not exist and could not be created: ${resourcesDir.absolutePath}")
            println("Will attempt to continue with download and use alternative storage location if needed.")
        } else {
            println("Resources directory exists: ${resourcesDir.absolutePath}")
        }

        // Clear any previous OpenPnP properties
        System.clearProperty("org.openpnp.opencv.forceDownload")
        System.clearProperty("org.openpnp.opencv.cacheDirectory")

        // Force a fresh download using OpenPnP
        System.setProperty("org.openpnp.opencv.forceDownload", "true")

        // Set up the OpenPnP cache directory
        val userHome = System.getProperty("user.home")
        val openpnpDir = File("$userHome/.openpnp/opencv")
        if (openpnpDir.exists()) {
            println("OpenPnP cache directory exists at: ${openpnpDir.absolutePath}")
            println("Contents:")
            openpnpDir.listFiles()?.forEach { file ->
                println("  - ${file.name} (${file.length()} bytes)")
            }

            // Clean the OpenPnP cache directory to ensure a fresh download
            println("Cleaning OpenPnP cache directory...")
            openpnpDir.listFiles()?.forEach { file ->
                file.delete()
            }
        } else {
            println("OpenPnP cache directory does not exist at: ${openpnpDir.absolutePath}")
            println("Creating directory...")
            openpnpDir.mkdirs()
        }

        // Use a dedicated directory for the download
        val downloadDir = File("${System.getProperty("user.home")}/.opencv_download")
        if (downloadDir.exists()) {
            println("Cleaning existing download directory: ${downloadDir.absolutePath}")
            downloadDir.listFiles()?.forEach { file ->
                file.delete()
            }
        } else {
            println("Creating download directory: ${downloadDir.absolutePath}")
            downloadDir.mkdirs()
        }
        System.setProperty("org.openpnp.opencv.cacheDirectory", downloadDir.absolutePath)

        println("Using download directory: ${downloadDir.absolutePath}")

        // Directly download the OpenCV library from the Maven repository
        val mavenUrl = when {
            osDirectory == "windows" && archDirectory == "x64" -> 
                "https://repo1.maven.org/maven2/org/openpnp/opencv/4.9.0-0/opencv-4.9.0-0.jar"
            osDirectory == "windows" && archDirectory == "x86" -> 
                "https://repo1.maven.org/maven2/org/openpnp/opencv/4.9.0-0/opencv-4.9.0-0.jar"
            osDirectory == "linux" && archDirectory == "x64" -> 
                "https://repo1.maven.org/maven2/org/openpnp/opencv/4.7.0-0/opencv-4.9.0-0.jar"
            osDirectory == "linux" && archDirectory == "x86" -> 
                "https://repo1.maven.org/maven2/org/openpnp/opencv/4.9.0-0/opencv-4.9.0-0.jar"
            osDirectory == "macos" -> 
                "https://repo1.maven.org/maven2/org/openpnp/opencv/4.9.0-0/opencv-4.9.0-0.jar"
            else -> throw UnsatisfiedLinkError("Unsupported operating system/architecture: $osName/$osArch")
        }

        println("Downloading OpenCV library from Maven repository: $mavenUrl")
        val jarFile = File(downloadDir, "opencv-4.11.0-0.jar")

        try {
            // Download the JAR file
            val connection = java.net.URI(mavenUrl).toURL().openConnection()
            connection.connect()
            val inputStream = connection.getInputStream()
            val outputStream = jarFile.outputStream()
            inputStream.copyTo(outputStream)
            inputStream.close()
            outputStream.close()

            println("Successfully downloaded OpenCV library: ${jarFile.absolutePath}")
            println("File size: ${jarFile.length()} bytes")

            // Extract the native library from the JAR file
            val jarInputStream = java.util.jar.JarInputStream(jarFile.inputStream())
            var entry = jarInputStream.nextJarEntry
            var foundLibrary = false

            while (entry != null) {
                // Check if this entry is the correct native library for our architecture
                val isCorrectLibrary = when {
                    osDirectory == "windows" && archDirectory == "x64" && 
                    entry.name.contains("windows/x86_64") && entry.name.contains(libraryFileName) -> true
                    osDirectory == "windows" && archDirectory == "x86" && 
                    entry.name.contains("windows/x86_32") && entry.name.contains(libraryFileName) -> true
                    osDirectory == "linux" && archDirectory == "x64" && 
                    entry.name.contains("linux/x86_64") && entry.name.contains(libraryFileName) -> true
                    osDirectory == "linux" && archDirectory == "x86" && 
                    entry.name.contains("linux/x86_32") && entry.name.contains(libraryFileName) -> true
                    osDirectory == "macos" && 
                    entry.name.contains("macosx") && entry.name.contains(libraryFileName) -> true
                    else -> false
                }

                if (isCorrectLibrary) {
                    println("Found native library in JAR: ${entry.name}")
                    val nativeLibFile = File(downloadDir, libraryFileName)
                    val entryInputStream = jarInputStream
                    val entryOutputStream = nativeLibFile.outputStream()
                    entryInputStream.copyTo(entryOutputStream)
                    entryOutputStream.close()

                    println("Extracted native library: ${nativeLibFile.absolutePath}")
                    println("File size: ${nativeLibFile.length()} bytes")

                    // Copy the native library to the resources folder
                    println("Copying library to resources: $libraryPath")
                    try {
                        // Create a backup of the file first
                        val backupFile = File("${nativeLibFile.absolutePath}.backup")
                        nativeLibFile.copyTo(backupFile, overwrite = true)
                        println("Created backup of library file: ${backupFile.absolutePath}")

                        // Now copy to the resources folder
                        nativeLibFile.copyTo(libraryFile, overwrite = true)
                        println("Successfully copied library to resources")

                        // Verify that the library file exists in the resources folder
                        if (libraryFile.exists()) {
                            println("Verified that library file exists in resources: ${libraryFile.absolutePath}")
                            println("File size: ${libraryFile.length()} bytes")

                            // Try to load the library from resources to verify it works
                            try {
                                println("Loading library from resources to verify it works...")
                                System.load(libraryFile.absolutePath)
                                println("Successfully loaded library from resources")

                                // Verify that we have full functionality
                                try {
                                    val buildInfo = Core.getBuildInformation()
                                    println("OpenCV fully loaded with all functionality from resources")
                                    fullFunctionality = true

                                    // Check OpenCL status
                                    val openCLInfo = if (buildInfo.contains("OpenCL:") || buildInfo.contains("OpenCL")) {
                                        val openCLLine = buildInfo.lines().find { it.contains("OpenCL:") || it.contains("OpenCL") }
                                        openCLLine ?: "OpenCL information not found in build info"
                                    } else {
                                        "OpenCL information not found in build info"
                                    }
                                    println("OpenCL status: $openCLInfo")

                                    // Successfully loaded with full functionality, return
                                    foundLibrary = true
                                    break
                                } catch (e: UnsatisfiedLinkError) {
                                    println("Warning: OpenCV is partially loaded from resources. Full functionality is not available.")
                                    println("Error: ${e.message}")
                                }
                            } catch (e: Exception) {
                                println("ERROR: Failed to load library from resources: ${e.message}")
                                e.printStackTrace()
                                println("Will try to use the original extracted file")

                                // Try to load the library from the original extracted file
                                println("Loading library from original extracted file...")
                                System.load(nativeLibFile.absolutePath)
                                println("Successfully loaded library from original extracted file")

                                // Verify that we have full functionality
                                try {
                                    val buildInfo = Core.getBuildInformation()
                                    println("OpenCV fully loaded with all functionality from original extracted file")
                                    fullFunctionality = true

                                    // Successfully loaded with full functionality, return
                                    foundLibrary = true
                                    break
                                } catch (e: UnsatisfiedLinkError) {
                                    println("Warning: OpenCV is partially loaded from original extracted file. Full functionality is not available.")
                                    println("Error: ${e.message}")
                                }
                            }
                        } else {
                            println("ERROR: Library file does not exist in resources after copy: ${libraryFile.absolutePath}")
                            println("Will try to use the original extracted file")

                            // Try to load the library from the original extracted file
                            println("Loading library from original extracted file...")
                            System.load(nativeLibFile.absolutePath)
                            println("Successfully loaded library from original extracted file")

                            // Verify that we have full functionality
                            try {
                                val buildInfo = Core.getBuildInformation()
                                println("OpenCV fully loaded with all functionality from original extracted file")
                                fullFunctionality = true

                                // Successfully loaded with full functionality, return
                                foundLibrary = true
                                break
                            } catch (e: UnsatisfiedLinkError) {
                                println("Warning: OpenCV is partially loaded from original extracted file. Full functionality is not available.")
                                println("Error: ${e.message}")
                            }
                        }
                    } catch (e: Exception) {
                        println("ERROR: Failed to copy library to resources: ${e.message}")
                        e.printStackTrace()
                        println("Will try to use the original extracted file")

                        // Try to load the library from the original extracted file
                        println("Loading library from original extracted file...")
                        System.load(nativeLibFile.absolutePath)
                        println("Successfully loaded library from original extracted file")

                        // Verify that we have full functionality
                        try {
                            val buildInfo = Core.getBuildInformation()
                            println("OpenCV fully loaded with all functionality from original extracted file")
                            fullFunctionality = true

                            // Successfully loaded with full functionality, return
                            foundLibrary = true
                            break
                        } catch (e: UnsatisfiedLinkError) {
                            println("Warning: OpenCV is partially loaded from original extracted file. Full functionality is not available.")
                            println("Error: ${e.message}")
                        }
                    }
                }
                entry = jarInputStream.nextJarEntry
            }

            jarInputStream.close()

            if (!foundLibrary) {
                println("ERROR: Could not find native library in downloaded JAR file")
            }
        } catch (e: Exception) {
            println("ERROR: Failed to download or extract OpenCV library: ${e.message}")
            e.printStackTrace()
        }

        // If direct download failed, try using OpenPnP's automatic loading mechanism
        if (!fullFunctionality) {
            println("Direct download failed or didn't provide full functionality. Trying OpenPnP's automatic loading...")

            try {
                val openCvVersion = Core.VERSION
                println("OpenCV Version: $openCvVersion")

                // Verify that we have full functionality
                try {
                    val buildInfo = Core.getBuildInformation()
                    println("OpenCV fully loaded with all functionality after OpenPnP automatic loading")
                    fullFunctionality = true

                    // Now we need to copy the downloaded library to our resources folder
                    // First, find the downloaded library file
                    val downloadedFiles = downloadDir.listFiles()
                    if (downloadedFiles != null && downloadedFiles.isNotEmpty()) {
                        println("OpenPnP downloaded ${downloadedFiles.size} files:")
                        downloadedFiles.forEach { file ->
                            println("  - ${file.name} (${file.length()} bytes)")
                        }

                        // Look for the native library file
                        val nativeLibFile = downloadedFiles.find { file -> 
                            file.name.contains("opencv_java", ignoreCase = true) && 
                            (file.name.endsWith(".dll") || file.name.endsWith(".so") || file.name.endsWith(".dylib")) 
                        }

                        if (nativeLibFile != null) {
                            println("Found downloaded native library: ${nativeLibFile.absolutePath}")

                            // Check if the resources directory exists again (it might have been created by OpenPnP)
                            if (!resourcesDir.exists()) {
                                println("Resources directory still does not exist. Attempting to create it again...")
                                try {
                                    // Create the full directory path
                                    val created = resourcesDir.mkdirs()
                                    if (created) {
                                        println("Successfully created resources directory on second attempt")
                                    } else {
                                        println("Failed to create resources directory on second attempt")
                                    }
                                } catch (e: Exception) {
                                    println("ERROR: Failed to create resources directory on second attempt: ${e.message}")
                                    e.printStackTrace()
                                }
                            }

                            // Verify that the resources directory exists
                            if (!resourcesDir.exists()) {
                                println("ERROR: Resources directory does not exist and could not be created: ${resourcesDir.absolutePath}")
                                println("Will try to use the OpenPnP cache directory instead")

                                // Try to copy the library to the OpenPnP cache directory
                                val openpnpLibFile = File(openpnpDir, libraryFileName)
                                println("Copying library to OpenPnP cache: ${openpnpLibFile.absolutePath}")
                                try {
                                    nativeLibFile.copyTo(openpnpLibFile, overwrite = true)
                                    println("Successfully copied library to OpenPnP cache")

                                    // Try to load the library from the OpenPnP cache
                                    println("Loading library from OpenPnP cache...")
                                    System.load(openpnpLibFile.absolutePath)
                                    println("Successfully loaded library from OpenPnP cache")

                                    return
                                } catch (e: Exception) {
                                    println("ERROR: Failed to copy library to OpenPnP cache: ${e.message}")
                                    e.printStackTrace()
                                    println("Will try to use the original downloaded file")

                                    // Try to load the library from the original downloaded file
                                    println("Loading library from original downloaded file...")
                                    System.load(nativeLibFile.absolutePath)
                                    println("Successfully loaded library from original downloaded file")

                                    return
                                }
                            }

                            // Copy the library file to the resources folder
                            println("Copying library to resources: $libraryPath")
                            try {
                                // Create a backup of the file first
                                val backupFile = File("${nativeLibFile.absolutePath}.backup")
                                nativeLibFile.copyTo(backupFile, overwrite = true)
                                println("Created backup of library file: ${backupFile.absolutePath}")

                                // Now copy to the resources folder
                                nativeLibFile.copyTo(libraryFile, overwrite = true)
                                println("Successfully copied library to resources")

                                // Verify that the library file exists in the resources folder
                                if (libraryFile.exists()) {
                                    println("Verified that library file exists in resources: ${libraryFile.absolutePath}")
                                    println("File size: ${libraryFile.length()} bytes")

                                    // Try to load the library from resources to verify it works
                                    try {
                                        println("Loading library from resources to verify it works...")
                                        System.load(libraryFile.absolutePath)
                                        println("Successfully loaded library from resources")
                                    } catch (e: Exception) {
                                        println("ERROR: Failed to load library from resources: ${e.message}")
                                        e.printStackTrace()
                                        println("Will try to use the original downloaded file")

                                        // Try to load the library from the original downloaded file
                                        println("Loading library from original downloaded file...")
                                        System.load(nativeLibFile.absolutePath)
                                        println("Successfully loaded library from original downloaded file")
                                    }
                                } else {
                                    println("ERROR: Library file does not exist in resources after copy: ${libraryFile.absolutePath}")
                                    println("Will try to use the original downloaded file")

                                    // Try to load the library from the original downloaded file
                                    println("Loading library from original downloaded file...")
                                    System.load(nativeLibFile.absolutePath)
                                    println("Successfully loaded library from original downloaded file")
                                }

                                // Check OpenCL status
                                val openCLInfo = if (buildInfo.contains("OpenCL:") || buildInfo.contains("OpenCL")) {
                                    val openCLLine = buildInfo.lines().find { it.contains("OpenCL:") || it.contains("OpenCL") }
                                    openCLLine ?: "OpenCL information not found in build info"
                                } else {
                                    "OpenCL information not found in build info"
                                }
                                println("OpenCL status: $openCLInfo")

                                // Successfully loaded with full functionality, return
                                return
                            } catch (e: Exception) {
                                println("ERROR: Failed to copy library to resources: ${e.message}")
                                e.printStackTrace()
                                println("Will try to use the original downloaded file")

                                // Try to load the library from the original downloaded file
                                println("Loading library from original downloaded file...")
                                System.load(nativeLibFile.absolutePath)
                                println("Successfully loaded library from original downloaded file")

                                return
                            }
                        } else {
                            println("ERROR: No native library file found in the download directory")
                        }
                    } else {
                        println("ERROR: No files were downloaded by OpenPnP")
                    }
                } catch (e: UnsatisfiedLinkError) {
                    println("ERROR: OpenCV is partially loaded. Full functionality is not available.")
                    println("Error: ${e.message}")
                }
            } catch (e: Exception) {
                println("ERROR: Failed to download and load OpenCV: ${e.message}")
                e.printStackTrace()
            }
        }

        // If we get here, we failed to load OpenCV with full functionality
        if (!fullFunctionality) {
            throw UnsatisfiedLinkError("Failed to load OpenCV with full functionality. The bot requires full OpenCV functionality to work properly.")
        }
    } catch (e: UnsatisfiedLinkError) {
        println("ERROR: Failed to load OpenCV native library: ${e.message}")
        println("Make sure the OpenCV native library is in the correct location")
        println("Current directory: ${Paths.get("").toAbsolutePath()}")
        e.printStackTrace()
        throw e // Rethrow to allow tests to fail properly
    } catch (e: Exception) {
        println("ERROR: Error loading OpenCV: ${e.message}")
        e.printStackTrace()
        throw e // Rethrow to allow tests to fail properly
    }
}
