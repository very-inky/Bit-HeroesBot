package orion

import orion.actions.QuestAction // Updated import
import orion.actions.RaidAction  // Updated import
// BotConfig, QuestActionConfig, PvpActionConfig, RaidActionConfig, RaidTarget, ActionManager
// are now expected to be available if they are in the 'orion' package or subpackages.
// Ensure their package declarations are also 'orion' or 'orion.something'
import org.opencv.core.Core
import java.io.File
import java.nio.file.Paths

fun main() {
    println("Starting OpenCV Bot...")

    // Load OpenCV native library
    loadOpenCVNativeLibrary()

    // --- Configuration Setup ---
    val botConfig = BotConfig(
        configId = "my_hero_daily_grind", // Config identifier
        characterName = "MyAwesomeHero", // Hero name
        actionSequence = listOf("Quest", "PVP", "Raid"), // Using actionSequence with all actions
        actionConfigs = mapOf(
            "Quest" to QuestActionConfig( // Using specific QuestActionConfig
                enabled = true,
                commonActionTemplates = listOf("templates/buttons/Untitled.png"),
                // Using the new dungeonTargets configuration
                dungeonTargets = listOf(
                    QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true),
                    QuestActionConfig.DungeonTarget(zoneNumber = 6, dungeonNumber = 3, enabled = true)
                ),
                repeatCount = 1
            ),
            "PVP" to PvpActionConfig( // Using specific PvpActionConfig
                enabled = true, // Enable PVP
                commonActionTemplates = listOf("templates/buttons/pvp_start_button.png"),
                ticketsToUse = 5, // Use 5 tickets
                opponentRank = 2, // Fight opponent rank 2
                autoSelectOpponent = false // Don't auto-select opponents
            ),
            "Raid" to RaidActionConfig( // Using specific RaidActionConfig
                enabled = true,
                commonActionTemplates = emptyList(),
                raidTargets = listOf(
                    RaidActionConfig.RaidTarget(raidName = "SomeRaidBoss", difficulty = "Heroic", enabled = true)
                ),
                runCount = 0
            )
            // Define other actions like "WorldBoss", "Invasion" here using their specific ActionConfig classes
        )
    )
    println("Bot configuration loaded for character: ${botConfig.characterName}, config ID: ${botConfig.configId}")
    // --- End Configuration Setup ---

    // Create and initialize the bot with the configuration
    val bot = Bot(botConfig)
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

    // Use ActionManager to run the sequence
    val actionManager = ActionManager(bot, botConfig)
    actionManager.runActionSequence()

    println("\\nMain function finished.")
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
