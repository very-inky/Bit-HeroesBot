package orion

import orion.utils.YamlUtils
import orion.utils.PathUtils
import java.io.File
import java.util.Scanner
import java.util.UUID

/**
 * Command-line interface for managing bot configurations
 */
class ConfigCLI(private val configManager: ConfigManager) {
    private val scanner = Scanner(System.`in`)

    /**
     * Generates a random ID consisting of a 3-digit number and 1 uppercase letter
     * Format: "000A" to "999Z"
     * @return A string in the format "NNNL" where N is a digit and L is an uppercase letter
     */
    private fun generateShortId(): String {
        val number = (100..999).random()
        val letter = ('A'..'Z').random()
        return "$number$letter"
    }

    /**
     * Generates a unique short ID that doesn't exist in the given set of IDs
     * @param existingIds Set of existing IDs to avoid duplicates
     * @return A unique short ID
     */
    private fun generateUniqueShortId(existingIds: Set<String>): String {
        var id = generateShortId()
        while (existingIds.contains(id)) {
            id = generateShortId()
        }
        return id
    }

    /**
     * Start the CLI interface
     */
    fun start() {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Orion Bot Configuration Manager                                ║")
        println("║ Type 'help' for a list of commands                             ║")
        println("╚════════════════════════════════════════════════════════════════╝")

        // Initialize configuration directories
        configManager.initConfigDirectories()

        // Try to load existing configurations
        val loaded = configManager.loadAllFromFiles()
        if (loaded) {
            println("Loaded existing configurations.")

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
            println("No existing configurations found. Use 'create-character' to create a new character.")
        }

        var running = true
        while (running) {
            print("\nEnter command: ")
            val input = scanner.nextLine().trim()
            val parts = input.split(" ")
            val command = parts[0].lowercase()

            try {
                when (command) {
                    "help" -> showHelp()
                    "exit", "quit" -> running = false
                    "list-characters" -> listCharacters()
                    "list-configs" -> listConfigs()
                    "create-character" -> createCharacter()
                    "create-config" -> createConfig()
                    "edit-character" -> editCharacter(parts)
                    "edit-config" -> editConfig(parts)
                    "delete-character" -> deleteCharacter(parts)
                    "delete-config" -> deleteConfig(parts)
                    "activate-character" -> activateCharacter(parts)
                    "activate-config" -> activateConfig(parts)
                    "save" -> saveConfigurations()
                    "load" -> loadConfigurations()
                    "show-character" -> showCharacter(parts)
                    "show-config" -> showConfig(parts)
                    "validate" -> validateConfiguration()
                    else -> println("Unknown command: $command. Type 'help' for a list of commands.")
                }
            } catch (e: Exception) {
                println("Error: ${e.message}")
            }
        }

        println("Configuration manager exiting. Saving configurations...")
        configManager.saveAllToFiles()
        println("Configurations saved.")
    }

    /**
     * Show help information
     */
    private fun showHelp() {
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Available Commands:                                            ║")
        println("╠════════════════════════════════════════════════════════════════╣")
        println("║ help                   - Show this help message                ║")
        println("║ exit, quit             - Exit the configuration manager        ║")
        println("║ list-characters        - List all characters                   ║")
        println("║ list-configs           - List all configurations               ║")
        println("║ create-character       - Create a new character                ║")
        println("║ create-config          - Create a new configuration            ║")
        println("║ edit-character <id>    - Edit a character                      ║")
        println("║ edit-config <id>       - Edit a configuration                  ║")
        println("║ delete-character <id>  - Delete a character                    ║")
        println("║ delete-config <id>     - Delete a configuration                ║")
        println("║ activate-character <id>- Set the active character              ║")
        println("║ activate-config <id>   - Set the active configuration          ║")
        println("║ save                   - Save all configurations to files      ║")
        println("║ load                   - Load all configurations from files    ║")
        println("║ show-character <id>    - Show details of a character           ║")
        println("║ show-config <id>       - Show details of a configuration       ║")
        println("║ validate               - Validate the current configuration    ║")
        println("╚════════════════════════════════════════════════════════════════╝")
    }

    /**
     * List all characters
     */
    private fun listCharacters() {
        val characters = configManager.getAllCharacters()
        if (characters.isEmpty()) {
            println("No characters found.")
            return
        }

        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Characters:                                                    ║")
        println("╠════════════════════════════════════════════════════════════════╣")

        characters.forEach { character ->
            val activeMarker = if (configManager.isCharacterActive(character.characterId)) "* " else "  "
            println("║ $activeMarker${character.characterName.padEnd(25)} | ${character.accountId.padEnd(10)} | ${character.characterId} ║")
        }

        println("╚════════════════════════════════════════════════════════════════╝")
        println("* = Active character")
    }

    /**
     * List all configurations
     */
    private fun listConfigs() {
        val configs = configManager.getAllConfigs()
        if (configs.isEmpty()) {
            println("No configurations found.")
            return
        }

        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Configurations:                                                ║")
        println("╠════════════════════════════════════════════════════════════════╣")

        configs.forEach { config ->
            val activeMarker = if (configManager.isConfigActive(config.configId)) "* " else "  "
            val character = configManager.getCharacter(config.characterId)
            val characterName = character?.characterName ?: "Unknown"
            println("║ $activeMarker${config.configName.padEnd(25)} | ${characterName.padEnd(15)} | ${config.configId} ║")
        }

        println("╚════════════════════════════════════════════════════════════════╝")
        println("* = Active configuration")
    }

    /**
     * Create a new character
     */
    private fun createCharacter() {
        println("Creating a new character:")

        print("Enter character name: ")
        val characterName = scanner.nextLine().trim()

        print("Enter account name (for multi-account support, default = 'default'): ")
        val accountId = scanner.nextLine().trim().let { if (it.isEmpty()) "default" else it }

        // Generate a short ID instead of UUID
        val existingIds = configManager.getAllCharacters().map { it.characterId }.toSet()
        val characterId = generateUniqueShortId(existingIds)

        val character = CharacterConfig(
            characterId = characterId,
            characterName = characterName,
            accountId = accountId,
            isActive = false
        )

        if (configManager.addCharacter(character)) {
            println("Character created with ID: $characterId")
            configManager.saveCharacter(character)

            // Ask if the user wants to create a config for this character
            print("Do you want to create a configuration for this character now? (y/n): ")
            val createConfig = scanner.nextLine().trim().lowercase()
            if (createConfig == "y" || createConfig == "yes") {
                // Activate this character first
                configManager.setActiveCharacter(characterId, true)
                // Create a config for this character
                createConfigForCharacter(character)
            }
        } else {
            println("Failed to create character.")
        }
    }

    /**
     * Create a new configuration for a specific character
     */
    private fun createConfigForCharacter(character: CharacterConfig) {
        println("Creating a new configuration for character: ${character.characterName}")

        print("Enter configuration name: ")
        val configName = scanner.nextLine().trim()

        print("Enter description: ")
        val description = scanner.nextLine().trim()

        // Prompt for action sequence
        println("Enter action sequence (comma-separated, e.g., 'Quest,Raid,PvP'): ")
        val actionSequenceInput = scanner.nextLine().trim()
        val actionSequence = if (actionSequenceInput.isEmpty()) {
            listOf("Quest") // Default to Quest if no sequence provided
        } else {
            actionSequenceInput.split(",").map { it.trim() }
        }

        // Generate a short ID instead of UUID
        val existingIds = configManager.getAllConfigs().map { it.configId }.toSet()
        val configId = generateUniqueShortId(existingIds)

        // Create action configs map with default values for each action in the sequence
        val actionConfigs = mutableMapOf<String, ActionConfig>()

        // Initialize action configs with default values
        for (action in actionSequence) {
            when (action.lowercase()) {
                "quest" -> {
                    println("\nSetting up Quest configuration:")

                    // Prompt for dungeon targets
                    val dungeonTargets = mutableListOf<QuestActionConfig.DungeonTarget>()

                    println("Do you want to add dungeon targets? (y/n): ")
                    val addDungeons = scanner.nextLine().trim().lowercase()
                    if (addDungeons == "y" || addDungeons == "yes") {
                        var addMore = true
                        while (addMore) {
                            print("Enter zone number: ")
                            val zoneNumber = scanner.nextLine().trim().toIntOrNull()
                            if (zoneNumber == null || zoneNumber < 1) {
                                println("Invalid zone number. Please enter a positive integer.")
                                continue
                            }

                            print("Enter dungeon number: ")
                            val dungeonNumber = scanner.nextLine().trim().toIntOrNull()
                            if (dungeonNumber == null || dungeonNumber < 1) {
                                println("Invalid dungeon number. Please enter a positive integer.")
                                continue
                            }

                            print("Enter difficulty (heroic, hard, normal) [default: heroic]: ")
                            val difficulty = scanner.nextLine().trim().let { 
                                if (it.isEmpty()) "heroic" 
                                else it.lowercase() 
                            }

                            dungeonTargets.add(QuestActionConfig.DungeonTarget(
                                zoneNumber = zoneNumber,
                                dungeonNumber = dungeonNumber,
                                difficulty = difficulty,
                                enabled = true
                            ))

                            print("Add another dungeon target? (y/n): ")
                            val response = scanner.nextLine().trim().lowercase()
                            addMore = response == "y" || response == "yes"
                        }
                    }

                    print("Enter repeat count (0 = infinite runs until out of resources) [default: 0]: ")
                    val repeatCount = scanner.nextLine().trim().toIntOrNull() ?: 0

                    actionConfigs[action] = QuestActionConfig(
                        enabled = true,
                        dungeonTargets = dungeonTargets,
                        repeatCount = repeatCount,
                        commonTemplateDirectories = listOf(PathUtils.templatePath("ui")),
                        specificTemplateDirectories = listOf(PathUtils.templatePath("quest")),
                        useDirectoryBasedTemplates = true
                    )
                }
                "pvp" -> {
                    println("\nSetting up PvP configuration:")

                    print("Enter number of tickets to use (1-5): ")
                    val ticketsToUse = scanner.nextLine().trim().toIntOrNull()
                    if (ticketsToUse == null || ticketsToUse < 1 || ticketsToUse > 5) {
                        println("Invalid number of tickets. Using default (5).")
                    }

                    print("Enter opponent choice (1-4) [default: 2]: ")
                    val opponentChoice = scanner.nextLine().trim().toIntOrNull()
                    if (opponentChoice == null || opponentChoice < 1 || opponentChoice > 4) {
                        println("Invalid opponent choice. Using default (2).")
                    }

                    print("Auto-select opponent? (y/n) [default: n]: ")
                    val autoSelectResponse = scanner.nextLine().trim().lowercase()
                    val autoSelect = autoSelectResponse == "y" || autoSelectResponse == "yes"

                    actionConfigs[action.lowercase()] = PvpActionConfig(
                        enabled = true,
                        ticketsToUse = ticketsToUse ?: 5,
                        pvpOpponentChoice = opponentChoice ?: 2,
                        autoSelectOpponent = autoSelect,
                        commonTemplateDirectories = listOf(PathUtils.templatePath("ui")),
                        specificTemplateDirectories = listOf(PathUtils.templatePath("pvp")),
                        useDirectoryBasedTemplates = true
                    )
                }
                "raid" -> {
                    println("\nSetting up Raid configuration:")

                    // Prompt for raid targets
                    val raidTargets = mutableListOf<RaidActionConfig.RaidTarget>()

                    println("Do you want to add raid targets? (y/n): ")
                    val addRaids = scanner.nextLine().trim().lowercase()
                    if (addRaids == "y" || addRaids == "yes") {
                        var addMore = true
                        while (addMore) {
                            println("Enter raid identifier (e.g., 'Raid 1' or 'T4'): ")
                            val raidInput = scanner.nextLine().trim()

                            // Parse raid input to determine raid number or tier number
                            var raidNumber: Int? = null
                            var tierNumber: Int? = null

                            if (raidInput.startsWith("Raid", ignoreCase = true)) {
                                // Format: "Raid X"
                                val number = raidInput.substring(4).trim().toIntOrNull()
                                if (number != null && number in 1..18) {
                                    raidNumber = number
                                    tierNumber = RaidActionConfig.RaidTarget.raidToTier(number)
                                } else {
                                    println("Invalid raid number. Please enter a number between 1 and 18.")
                                    continue
                                }
                            } else if (raidInput.startsWith("T", ignoreCase = true)) {
                                // Format: "TX"
                                val number = raidInput.substring(1).trim().toIntOrNull()
                                if (number != null && number in 4..21) {
                                    tierNumber = number
                                    raidNumber = RaidActionConfig.RaidTarget.tierToRaid(number)
                                } else {
                                    println("Invalid tier number. Please enter a number between 4 and 21.")
                                    continue
                                }
                            } else {
                                // Try to parse as a direct number (raid number)
                                val number = raidInput.toIntOrNull()
                                if (number != null && number in 1..18) {
                                    raidNumber = number
                                    tierNumber = RaidActionConfig.RaidTarget.raidToTier(number)
                                } else {
                                    println("Invalid raid format. Please use 'Raid X', 'TX', or a number between 1 and 18.")
                                    continue
                                }
                            }

                            print("Enter difficulty (Normal, Hard, Heroic) [default: Heroic]: ")
                            val difficulty = scanner.nextLine().trim().let { 
                                if (it.isEmpty()) "Heroic" 
                                else it.replaceFirstChar { char -> char.uppercase() } 
                            }

                            raidTargets.add(RaidActionConfig.RaidTarget(
                                raidNumber = raidNumber,
                                tierNumber = tierNumber,
                                difficulty = difficulty,
                                enabled = true
                            ))

                            print("Add another raid target? (y/n): ")
                            val raidResponse = scanner.nextLine().trim().lowercase()
                            addMore = raidResponse == "y" || raidResponse == "yes"
                        }
                    }

                    print("Enter run count (0 = infinite runs until out of resources) [default: 0]: ")
                    val runCount = scanner.nextLine().trim().toIntOrNull() ?: 0

                    actionConfigs[action] = RaidActionConfig(
                        enabled = true,
                        raidTargets = raidTargets,
                        runCount = runCount,
                        commonTemplateDirectories = listOf(PathUtils.templatePath("ui")),
                        specificTemplateDirectories = listOf(PathUtils.templatePath("raid")),
                        useDirectoryBasedTemplates = true
                    )
                }
                // Add other action types as needed
                else -> {
                    println("\nSkipping configuration for unknown action type: $action")
                }
            }
        }

        // Create the configuration with the action sequence and action configs
        val config = BotConfig(
            configId = configId,
            configName = configName,
            characterId = character.characterId,
            description = description,
            actionSequence = actionSequence,
            actionConfigs = actionConfigs
        )

        if (configManager.addConfig(config)) {
            println("Configuration created with ID: $configId")
            configManager.saveConfig(config)

            // Automatically activate this config
            configManager.setActiveConfig(configId, true)
            println("Activated configuration: $configName")

            // Ask if the user wants to edit the configuration further
            print("Do you want to edit this configuration further? (y/n): ")
            val editNow = scanner.nextLine().trim().lowercase()
            if (editNow == "y" || editNow == "yes") {
                editConfigDetails(config)
            }
        } else {
            println("Failed to create configuration.")
        }
    }

    /**
     * Create a new configuration
     */
    private fun createConfig() {
        // Check if there's an active character
        val activeCharacter = configManager.getActiveCharacter()

        if (activeCharacter != null) {
            // Use the active character
            createConfigForCharacter(activeCharacter)
            return
        }

        // No active character, show list of characters
        val characters = configManager.getAllCharacters()
        if (characters.isEmpty()) {
            println("No characters found. Please create a character first.")
            return
        }

        println("Creating a new configuration:")
        println("Available characters:")
        characters.forEachIndexed { index, character ->
            println("${index + 1}. ${character.characterName} (${character.characterId})")
        }

        print("Select character (1-${characters.size}): ")
        val characterIndex = scanner.nextLine().trim().toIntOrNull()?.minus(1)

        if (characterIndex == null || characterIndex < 0 || characterIndex >= characters.size) {
            println("Invalid character selection.")
            return
        }

        val character = characters[characterIndex]
        createConfigForCharacter(character)
    }

    /**
     * Edit a character
     */
    private fun editCharacter(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: edit-character <id>")
            return
        }

        val characterId = parts[1]
        val character = configManager.getCharacter(characterId)

        if (character == null) {
            println("Character not found with ID: $characterId")
            return
        }

        println("Editing character: ${character.characterName} (${character.characterId})")

        print("Enter new character name (current: ${character.characterName}): ")
        val characterName = scanner.nextLine().trim().let { if (it.isEmpty()) character.characterName else it }

        print("Enter new account name (for multi-account support, current: ${character.accountId}): ")
        val accountId = scanner.nextLine().trim().let { if (it.isEmpty()) character.accountId else it }

        val updatedCharacter = character.copy(
            characterName = characterName,
            accountId = accountId
        )

        // Remove the old character and add the updated one
        configManager.addCharacter(updatedCharacter, true)
        println("Character updated.")
        configManager.saveCharacter(updatedCharacter)
    }

    /**
     * Edit a configuration
     */
    private fun editConfig(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: edit-config <id>")
            return
        }

        val configId = parts[1]
        val config = configManager.getConfig(configId)

        if (config == null) {
            println("Configuration not found with ID: $configId")
            return
        }

        editConfigDetails(config)
    }

    /**
     * Edit the details of a configuration
     */
    private fun editConfigDetails(config: BotConfig) {
        println("Editing configuration: ${config.configName} (${config.configId})")

        print("Enter new configuration name (current: ${config.configName}): ")
        val configName = scanner.nextLine().trim().let { if (it.isEmpty()) config.configName else it }

        print("Enter new description (current: ${config.description}): ")
        val description = scanner.nextLine().trim().let { if (it.isEmpty()) config.description else it }

        // Edit action sequence
        println("Current action sequence: ${config.actionSequence.joinToString(", ")}")
        println("Enter new action sequence (comma-separated, e.g., 'Quest,Raid,PvP'): ")
        val actionSequenceInput = scanner.nextLine().trim()
        val actionSequence = if (actionSequenceInput.isEmpty()) {
            config.actionSequence
        } else {
            actionSequenceInput.split(",").map { it.trim() }
        }

        // Create a mutable map of action configs that we'll update
        val actionConfigs = config.actionConfigs.toMutableMap()

        // Edit action-specific configurations
        println("\nDo you want to edit action-specific configurations? (y/n): ")
        val editActionConfigs = scanner.nextLine().trim().lowercase()
        if (editActionConfigs == "y" || editActionConfigs == "yes") {
            // For each action in the sequence, prompt for configuration
            for (action in actionSequence) {
                when (action.lowercase()) {
                    "quest" -> {
                        println("\nEditing Quest configuration:")
                        val existingConfig = actionConfigs.entries.find { it.key.equals(action, ignoreCase = true) }?.value as? QuestActionConfig

                        // Prompt for dungeon targets
                        val dungeonTargets = mutableListOf<QuestActionConfig.DungeonTarget>()

                        println("Do you want to add dungeon targets? (y/n): ")
                        val addDungeons = scanner.nextLine().trim().lowercase()
                        if (addDungeons == "y" || addDungeons == "yes") {
                            var addMore = true
                            while (addMore) {
                                print("Enter zone number: ")
                                val zoneNumber = scanner.nextLine().trim().toIntOrNull()
                                if (zoneNumber == null || zoneNumber < 1) {
                                    println("Invalid zone number. Please enter a positive integer.")
                                    continue
                                }

                                print("Enter dungeon number: ")
                                val dungeonNumber = scanner.nextLine().trim().toIntOrNull()
                                if (dungeonNumber == null || dungeonNumber < 1) {
                                    println("Invalid dungeon number. Please enter a positive integer.")
                                    continue
                                }

                                print("Enter difficulty (heroic, hard, normal) [default: heroic]: ")
                                val difficulty = scanner.nextLine().trim().let { 
                                    if (it.isEmpty()) "heroic" 
                                    else it.lowercase() 
                                }

                                dungeonTargets.add(QuestActionConfig.DungeonTarget(
                                    zoneNumber = zoneNumber,
                                    dungeonNumber = dungeonNumber,
                                    difficulty = difficulty,
                                    enabled = true
                                ))

                                print("Add another dungeon target? (y/n): ")
                                val response = scanner.nextLine().trim().lowercase()
                                addMore = response == "y" || response == "yes"
                            }
                        } else if (existingConfig != null) {
                            // Keep existing dungeon targets
                            dungeonTargets.addAll(existingConfig.dungeonTargets)
                        }

                        print("Enter repeat count (0 = infinite runs until out of resources) [default: 0]: ")
                        val repeatCount = scanner.nextLine().trim().toIntOrNull() ?: 
                                          existingConfig?.repeatCount ?: 0

                        // Find the original key with case preserved
                        val originalKey = actionConfigs.keys.find { it.equals(action, ignoreCase = true) } ?: action
                        actionConfigs[originalKey] = QuestActionConfig(
                            enabled = true,
                            dungeonTargets = dungeonTargets,
                            repeatCount = repeatCount,
                            commonTemplateDirectories = existingConfig?.commonTemplateDirectories ?: 
                                                       listOf(PathUtils.templatePath("ui")),
                            specificTemplateDirectories = existingConfig?.specificTemplateDirectories ?: 
                                                        listOf(PathUtils.templatePath("quest")),
                            useDirectoryBasedTemplates = existingConfig?.useDirectoryBasedTemplates ?: true,
                            commonActionTemplates = existingConfig?.commonActionTemplates ?: emptyList(),
                            specificTemplates = existingConfig?.specificTemplates ?: emptyList(),
                            cooldownDuration = existingConfig?.cooldownDuration ?: 20
                        )
                    }
                    "pvp" -> {
                        println("\nEditing PvP configuration:")
                        val existingConfig = actionConfigs.entries.find { it.key.equals(action, ignoreCase = true) }?.value as? PvpActionConfig

                        print("Enter number of tickets to use (1-5): ")
                        val ticketsToUse = scanner.nextLine().trim().toIntOrNull()
                        if (ticketsToUse == null || ticketsToUse < 1 || ticketsToUse > 5) {
                            println("Invalid number of tickets. Using default (${existingConfig?.ticketsToUse ?: 5}).")
                        }

                        print("Enter opponent choice (1-4) [default: 2]: ")
                        val opponentChoice = scanner.nextLine().trim().toIntOrNull()
                        if (opponentChoice == null || opponentChoice < 1 || opponentChoice > 4) {
                            println("Invalid opponent choice. Using default (${existingConfig?.pvpOpponentChoice ?: 2}).")
                        }

                        print("Auto-select opponent? (y/n) [default: n]: ")
                        val autoSelectResponse = scanner.nextLine().trim().lowercase()
                        val autoSelect = autoSelectResponse == "y" || autoSelectResponse == "yes"

                        // Find the original key with case preserved
                        val originalKey = actionConfigs.keys.find { it.equals(action, ignoreCase = true) } ?: action
                        actionConfigs[originalKey] = PvpActionConfig(
                            enabled = true,
                            ticketsToUse = ticketsToUse ?: existingConfig?.ticketsToUse ?: 5,
                            pvpOpponentChoice = opponentChoice ?: existingConfig?.pvpOpponentChoice ?: 2,
                            autoSelectOpponent = autoSelect,
                            commonTemplateDirectories = existingConfig?.commonTemplateDirectories ?: 
                                                      listOf(PathUtils.templatePath("ui")),
                            specificTemplateDirectories = existingConfig?.specificTemplateDirectories ?: 
                                                        listOf(PathUtils.templatePath("pvp")),
                            useDirectoryBasedTemplates = existingConfig?.useDirectoryBasedTemplates ?: true,
                            commonActionTemplates = existingConfig?.commonActionTemplates ?: emptyList(),
                            specificTemplates = existingConfig?.specificTemplates ?: emptyList()
                        )
                    }
                    "raid" -> {
                        println("\nEditing Raid configuration:")
                        val existingConfig = actionConfigs.entries.find { it.key.equals(action, ignoreCase = true) }?.value as? RaidActionConfig

                        // Prompt for raid targets
                        val raidTargets = mutableListOf<RaidActionConfig.RaidTarget>()

                        println("Do you want to add raid targets? (y/n): ")
                        val addRaids = scanner.nextLine().trim().lowercase()
                        if (addRaids == "y" || addRaids == "yes") {
                            var addMore = true
                            while (addMore) {
                                println("Enter raid identifier (e.g., 'Raid 1' or 'T4'): ")
                                val raidInput = scanner.nextLine().trim()

                                // Parse raid input to determine raid number or tier number
                                var raidNumber: Int? = null
                                var tierNumber: Int? = null

                                if (raidInput.startsWith("Raid", ignoreCase = true)) {
                                    // Format: "Raid X"
                                    val number = raidInput.substring(4).trim().toIntOrNull()
                                    if (number != null && number in 1..18) {
                                        raidNumber = number
                                        tierNumber = RaidActionConfig.RaidTarget.raidToTier(number)
                                    } else {
                                        println("Invalid raid number. Please enter a number between 1 and 18.")
                                        continue
                                    }
                                } else if (raidInput.startsWith("T", ignoreCase = true)) {
                                    // Format: "TX"
                                    val number = raidInput.substring(1).trim().toIntOrNull()
                                    if (number != null && number in 4..21) {
                                        tierNumber = number
                                        raidNumber = RaidActionConfig.RaidTarget.tierToRaid(number)
                                    } else {
                                        println("Invalid tier number. Please enter a number between 4 and 21.")
                                        continue
                                    }
                                } else {
                                    // Try to parse as a direct number (raid number)
                                    val number = raidInput.toIntOrNull()
                                    if (number != null && number in 1..18) {
                                        raidNumber = number
                                        tierNumber = RaidActionConfig.RaidTarget.raidToTier(number)
                                    } else {
                                        println("Invalid raid format. Please use 'Raid X', 'TX', or a number between 1 and 18.")
                                        continue
                                    }
                                }

                                print("Enter difficulty (Normal, Hard, Heroic) [default: Heroic]: ")
                                val difficulty = scanner.nextLine().trim().let { 
                                    if (it.isEmpty()) "Heroic" 
                                    else it.replaceFirstChar { char -> char.uppercase() } 
                                }

                                raidTargets.add(RaidActionConfig.RaidTarget(
                                    raidNumber = raidNumber,
                                    tierNumber = tierNumber,
                                    difficulty = difficulty,
                                    enabled = true
                                ))

                                print("Add another raid target? (y/n): ")
                                val raidResponse = scanner.nextLine().trim().lowercase()
                                addMore = raidResponse == "y" || raidResponse == "yes"
                            }
                        } else if (existingConfig != null) {
                            // Keep existing raid targets
                            raidTargets.addAll(existingConfig.raidTargets)
                        }

                        print("Enter run count (0 = infinite runs until out of resources) [default: 0]: ")
                        val runCount = scanner.nextLine().trim().toIntOrNull() ?: 
                                       existingConfig?.runCount ?: 0

                        // Find the original key with case preserved
                        val originalKey = actionConfigs.keys.find { it.equals(action, ignoreCase = true) } ?: action
                        actionConfigs[originalKey] = RaidActionConfig(
                            enabled = true,
                            raidTargets = raidTargets,
                            runCount = runCount,
                            commonTemplateDirectories = existingConfig?.commonTemplateDirectories ?: 
                                                       listOf(PathUtils.templatePath("ui")),
                            specificTemplateDirectories = existingConfig?.specificTemplateDirectories ?: 
                                                        listOf(PathUtils.templatePath("raid")),
                            useDirectoryBasedTemplates = existingConfig?.useDirectoryBasedTemplates ?: true,
                            commonActionTemplates = existingConfig?.commonActionTemplates ?: emptyList(),
                            specificTemplates = existingConfig?.specificTemplates ?: emptyList(),
                            cooldownDuration = existingConfig?.cooldownDuration ?: 20
                        )
                    }
                    // Add other action types as needed
                    else -> {
                        println("\nSkipping configuration for unknown action type: $action")
                    }
                }
            }
        }

        // Create a copy of the configuration with the updated values
        val updatedConfig = config.copy(
            configId = config.configId,
            configName = configName,
            characterId = config.characterId,
            description = description,
            actionSequence = actionSequence,
            actionConfigs = actionConfigs
        )

        // Update the configuration
        configManager.addConfig(updatedConfig)
        println("Configuration updated.")
        configManager.saveConfig(updatedConfig)
    }

    /**
     * Delete a character
     */
    private fun deleteCharacter(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: delete-character <id>")
            return
        }

        val characterId = parts[1]
        val character = configManager.getCharacter(characterId)

        if (character == null) {
            println("Character not found with ID: $characterId")
            return
        }

        print("Are you sure you want to delete character '${character.characterName}'? (y/n): ")
        val confirm = scanner.nextLine().trim().lowercase()

        if (confirm == "y" || confirm == "yes") {
            // Delete the character file
            val charactersDir = File(ConfigManager.DEFAULT_CONFIG_DIR, ConfigManager.CHARACTERS_DIR)
            val file = File(charactersDir, "${characterId}${ConfigManager.YAML_EXTENSION}")
            if (file.exists()) {
                file.delete()
            }

            // Remove the character from ConfigManager
            if (configManager.removeCharacter(characterId)) {
                println("Character deleted.")
            } else {
                println("Failed to delete character from memory.")
            }
        } else {
            println("Deletion cancelled.")
        }
    }

    /**
     * Delete a configuration
     */
    private fun deleteConfig(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: delete-config <id>")
            return
        }

        val configId = parts[1]
        val config = configManager.getConfig(configId)

        if (config == null) {
            println("Configuration not found with ID: $configId")
            return
        }

        print("Are you sure you want to delete configuration '${config.configName}'? (y/n): ")
        val confirm = scanner.nextLine().trim().lowercase()

        if (confirm == "y" || confirm == "yes") {
            // Delete the config file
            val botConfigsDir = File(ConfigManager.DEFAULT_CONFIG_DIR, ConfigManager.BOT_CONFIGS_DIR)
            val file = File(botConfigsDir, "${configId}${ConfigManager.YAML_EXTENSION}")
            if (file.exists()) {
                file.delete()
            }

            // Remove the config from ConfigManager
            if (configManager.removeConfig(configId)) {
                println("Configuration deleted.")
            } else {
                println("Failed to delete configuration from memory.")
            }
        } else {
            println("Deletion cancelled.")
        }
    }

    /**
     * Activate a character
     */
    private fun activateCharacter(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: activate-character <id>")
            return
        }

        val characterId = parts[1]

        try {
            if (configManager.setActiveCharacter(characterId, true)) {
                val character = configManager.getCharacter(characterId)
                println("Activated character: ${character?.characterName}")
                configManager.saveActiveState()
            } else {
                println("Failed to activate character. Character not found.")
            }
        } catch (e: IllegalStateException) {
            println("Error: ${e.message}")
        }
    }

    /**
     * Activate a configuration
     */
    private fun activateConfig(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: activate-config <id>")
            return
        }

        val configId = parts[1]

        try {
            if (configManager.setActiveConfig(configId, true)) {
                val config = configManager.getConfig(configId)
                println("Activated configuration: ${config?.configName}")
                configManager.saveActiveState()
            } else {
                println("Failed to activate configuration. Configuration not found.")
            }
        } catch (e: IllegalStateException) {
            println("Error: ${e.message}")
        }
    }

    /**
     * Save all configurations to files
     */
    private fun saveConfigurations() {
        if (configManager.saveAllToFiles()) {
            println("Configurations saved successfully.")
        } else {
            println("No configurations to save or an error occurred.")
        }
    }

    /**
     * Load all configurations from files
     */
    private fun loadConfigurations() {
        if (configManager.loadAllFromFiles()) {
            println("Configurations loaded successfully.")
        } else {
            println("No configurations found or an error occurred.")
        }
    }

    /**
     * Show details of a character
     */
    private fun showCharacter(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: show-character <id>")
            return
        }

        val characterId = parts[1]
        val character = configManager.getCharacter(characterId)

        if (character == null) {
            println("Character not found with ID: $characterId")
            return
        }

        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Character Details:                                             ║")
        println("╠════════════════════════════════════════════════════════════════╣")
        println("║ ID:          ${character.characterId}")
        println("║ Name:        ${character.characterName}")
        println("║ Account ID:  ${character.accountId}")
        println("║ Active:      ${character.isActive}")
        println("╚════════════════════════════════════════════════════════════════╝")

        // Show configurations for this character
        val configs = configManager.getConfigsForCharacter(characterId)
        if (configs.isNotEmpty()) {
            println("Configurations for this character:")
            configs.forEach { config ->
                val activeMarker = if (configManager.isConfigActive(config.configId)) "* " else "  "
                println("$activeMarker${config.configName} (${config.configId})")
            }
        } else {
            println("No configurations found for this character.")
        }
    }

    /**
     * Show details of a configuration
     */
    private fun showConfig(parts: List<String>) {
        if (parts.size < 2) {
            println("Usage: show-config <id>")
            return
        }

        val configId = parts[1]
        val config = configManager.getConfig(configId)

        if (config == null) {
            println("Configuration not found with ID: $configId")
            return
        }

        val character = configManager.getCharacter(config.characterId)
        val characterName = character?.characterName ?: "Unknown"
        val accountId = character?.accountId ?: "Unknown"

        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Configuration Details:                                         ║")
        println("╠════════════════════════════════════════════════════════════════╣")
        println("║ ID:          ${config.configId}")
        println("║ Name:        ${config.configName}")
        println("║ Character:   $characterName (${config.characterId})")
        println("║ Account:     $accountId")
        println("║ Description: ${config.description}")
        println("║ Actions:     ${config.actionSequence.joinToString(", ")}")
        println("╚════════════════════════════════════════════════════════════════╝")

        // Show YAML representation
        println("YAML Representation:")
        val yaml = YamlUtils.writeToString(config)
        if (yaml != null) {
            println(yaml)
        } else {
            println("Error generating YAML representation.")
        }
    }

    /**
     * Validate the current configuration
     */
    private fun validateConfiguration() {
        try {
            if (configManager.validateConfiguration()) {
                println("Configuration is valid.")

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
                println("Configuration is not valid.")
            }
        } catch (e: IllegalStateException) {
            println("Validation error: ${e.message}")
        }
    }
}
