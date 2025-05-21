package orion

import orion.actions.QuestAction // Updated import
import orion.actions.RaidAction  // Updated import
// BotConfig, QuestActionConfig, PvpActionConfig, RaidActionConfig, RaidTarget, ActionManager
// are now expected to be available if they are in the 'orion' package or subpackages.
// Ensure their package declarations are also 'orion' or 'orion.something'
import org.opencv.core.Core
import java.io.File
import java.nio.file.Paths
import java.util.UUID

fun main() {
    println("Starting OpenCV Bot...")

    // Load OpenCV native library
    loadOpenCVNativeLibrary()

    // --- Configuration Setup ---
    // Create a configuration manager to handle multiple configurations
    val configManager = ConfigManager()

    // Create a character
    val heroCharacterId = UUID.randomUUID().toString()
    val heroCharacter = CharacterConfig(
        characterId = heroCharacterId,
        characterName = "MyAwesomeHero"
    )
    configManager.addCharacter(heroCharacter)
    println("Added character: ${heroCharacter.characterName} (ID: ${heroCharacter.characterId})")

    // Create multiple configurations for the character

    // Daily Farming Configuration
    val dailyFarmingConfigId = UUID.randomUUID().toString()
    val dailyFarmingConfig = BotConfig(
        configId = dailyFarmingConfigId,
        configName = "Daily Farming",
        characterId = heroCharacterId,
        description = "Configuration for daily farming tasks",
        actionSequence = listOf("Quest", "Raid"),
        actionConfigs = mapOf(
            "Quest" to QuestActionConfig(
                enabled = true,
                commonActionTemplates = listOf("templates/buttons/Untitled.png"),
                dungeonTargets = listOf(
                    QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true),
                    QuestActionConfig.DungeonTarget(zoneNumber = 6, dungeonNumber = 3, enabled = true)
                ),
                repeatCount = 0, // Run until out of resources
                cooldownDuration = 1 // 1 minute cooldown for testing
            ),
            "Raid" to RaidActionConfig(
                enabled = true,
                commonActionTemplates = emptyList(),
                raidTargets = listOf(
                    RaidActionConfig.RaidTarget(raidName = "SomeRaidBoss", difficulty = "Heroic", enabled = true)
                ),
                runCount = 0, // Run until out of resources
                cooldownDuration = 1 // 1 minute cooldown for testing
            )
        )
    )
    configManager.addConfig(dailyFarmingConfig)
    println("Added configuration: ${dailyFarmingConfig.configName} (ID: ${dailyFarmingConfig.configId})")

    // PvP Focus Configuration
    val pvpFocusConfigId = UUID.randomUUID().toString()
    val pvpFocusConfig = BotConfig(
        configId = pvpFocusConfigId,
        configName = "PvP Focus",
        characterId = heroCharacterId,
        description = "Configuration focused on PvP activities",
        actionSequence = listOf("PvP", "GvG", "Quest"),
        actionConfigs = mapOf(
            "PvP" to PvpActionConfig(
                enabled = true,
                commonActionTemplates = listOf("templates/buttons/pvp_button.png"),
                ticketsToUse = 5,
                opponentRank = 3
            ),
            "GvG" to GvgActionConfig(
                enabled = true,
                commonActionTemplates = listOf("templates/buttons/gvg_button.png"),
                badgeChoice = 4,
                opponentChoice = 2
            ),
            "Quest" to QuestActionConfig(
                enabled = true,
                commonActionTemplates = listOf("templates/buttons/Untitled.png"),
                dungeonTargets = listOf(
                    QuestActionConfig.DungeonTarget(zoneNumber = 10, dungeonNumber = 1, enabled = true)
                ),
                repeatCount = 3 // Only run 3 times
            )
        )
    )
    configManager.addConfig(pvpFocusConfig)
    println("Added configuration: ${pvpFocusConfig.configName} (ID: ${pvpFocusConfig.configId})")

    // --- Demonstrate Character Activation and Account Switching ---
    println("\n=== Character Activation and Account Management ===")

    // Activate the hero character
    try {
        configManager.setActiveCharacter(heroCharacterId)
        println("Activated character: ${configManager.getActiveCharacter()?.characterName}")
    } catch (e: IllegalStateException) {
        println("Error activating character: ${e.message}")
    }

    // Set the active configuration
    try {
        configManager.setActiveConfig(dailyFarmingConfig.configId)
        println("Set active configuration to: ${dailyFarmingConfig.configName}")
    } catch (e: IllegalStateException) {
        println("Error setting active configuration: ${e.message}")
    }

    // Validate the configuration
    try {
        configManager.validateConfiguration()
        println("Configuration validated successfully.")
    } catch (e: IllegalStateException) {
        println("Configuration validation failed: ${e.message}")
    }

    // Create a second account with a character
    println("\n--- Creating Second Account ---")
    val secondAccountId = "account2"
    val altCharacterId = UUID.randomUUID().toString()
    val altCharacter = CharacterConfig(
        characterId = altCharacterId,
        characterName = "AltHero",
        accountId = secondAccountId,
        isActive = false // Not active by default
    )

    try {
        configManager.addCharacter(altCharacter)
        println("Added character: ${altCharacter.characterName} (ID: ${altCharacter.characterId}) to account: $secondAccountId")
    } catch (e: IllegalStateException) {
        println("Error adding character: ${e.message}")
    }

    // Create a configuration for the alt character
    val altConfigId = UUID.randomUUID().toString()
    val altConfig = BotConfig(
        configId = altConfigId,
        configName = "Alt Farming",
        characterId = altCharacterId,
        description = "Configuration for alt character farming",
        actionSequence = listOf("Quest"),
        actionConfigs = mapOf(
            "Quest" to QuestActionConfig(
                enabled = true,
                commonActionTemplates = listOf("templates/buttons/Untitled.png"),
                dungeonTargets = listOf(
                    QuestActionConfig.DungeonTarget(zoneNumber = 5, dungeonNumber = 1, enabled = true)
                ),
                repeatCount = 5
            )
        )
    )

    configManager.addConfig(altConfig)
    println("Added configuration: ${altConfig.configName} (ID: ${altConfig.configId}) for character: ${altCharacter.characterName}")

    // Demonstrate account switching
    println("\n--- Switching Accounts ---")
    println("Current active character: ${configManager.getActiveCharacter()?.characterName}")
    println("Current active config: ${configManager.getActiveConfig()?.configName}")

    try {
        // Switch to the second account
        configManager.switchAccount(secondAccountId)
        println("Switched to account: $secondAccountId")
        println("New active character: ${configManager.getActiveCharacter()?.characterName}")
        println("New active config: ${configManager.getActiveConfig()?.configName}")

        // Switch back to the first account
        configManager.switchAccount("default", heroCharacterId, pvpFocusConfig.configId)
        println("Switched back to default account with specific character and config")
        println("Active character: ${configManager.getActiveCharacter()?.characterName}")
        println("Active config: ${configManager.getActiveConfig()?.configName}")
    } catch (e: IllegalStateException) {
        println("Error switching accounts: ${e.message}")
    }

    // Demonstrate error handling for multiple active characters
    println("\n--- Error Handling for Multiple Active Characters ---")
    try {
        // Try to add a character that's already active when another character is active
        val conflictCharacter = CharacterConfig(
            characterId = UUID.randomUUID().toString(),
            characterName = "ConflictHero",
            isActive = true
        )
        configManager.addCharacter(conflictCharacter)
        println("Added character: ${conflictCharacter.characterName}")
    } catch (e: IllegalStateException) {
        println("Expected error caught: ${e.message}")
    }

    // Get the active configuration for running the bot
    val activeConfig = configManager.getActiveConfig()
    if (activeConfig != null) {
        println("\n=== Running Bot with Active Configuration ===")
        println("Active configuration: ${activeConfig.configName} for character: ${configManager.getCharacter(activeConfig.characterId)?.characterName}")

        // Create and initialize the bot with the active configuration and ConfigManager
        val bot = Bot(activeConfig, configManager)
        bot.initialize()

        // Check if templates directory exists and load templates
        val templatesDir = "templates"
        if (bot.createTemplateDirectory(templatesDir)) {
            if (File(templatesDir).exists()) {
                println("Loading all available templates from directory: $templatesDir")
                val count = bot.loadTemplatesFromDirectory(templatesDir)
                println("Registered $count template images with the bot.")

                val categories = listOf("buttons", "menus", "characters", "items", "common")
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
 */
fun loadOpenCVNativeLibrary() {
    try {
        // First try to load from the resources folder
        val resourcePath = "natives/windows/x64/opencv_java490.dll"
        val resourceUrl = Thread.currentThread().contextClassLoader.getResource(resourcePath)

        if (resourceUrl != null) {
            println("Loading OpenCV from resources: $resourcePath")
            System.load(resourceUrl.path.substring(1)) // Remove leading '/' from path
            println("OpenCV loaded successfully from resources")
        } else {
            // If not found in resources, try to load from the system path
            println("OpenCV not found in resources, trying to load from system library...")
            System.loadLibrary(Core.NATIVE_LIBRARY_NAME)
            println("OpenCV loaded successfully from system library")
        }

        // Print OpenCV version to confirm it's loaded
        println("OpenCV Version: ${Core.VERSION}")
    } catch (e: UnsatisfiedLinkError) {
        println("Failed to load OpenCV native library: ${e.message}")
        println("Make sure the OpenCV native library is in the correct location")
        println("Current directory: ${Paths.get("").toAbsolutePath()}")
        System.exit(1)
    } catch (e: Exception) {
        println("Error loading OpenCV: ${e.message}")
        e.printStackTrace()
        System.exit(1)
    }
}
