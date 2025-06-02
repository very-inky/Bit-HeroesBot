package orion

import orion.utils.YamlUtils
import java.io.File
import java.util.Scanner
import java.util.UUID

/**
 * Command-line interface for managing bot configurations
 */
class ConfigCLI(private val configManager: ConfigManager) {
    private val scanner = Scanner(System.`in`)
    
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
            println("║ $activeMarker${character.characterName.padEnd(30)} | ${character.characterId} ║")
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
        
        print("Enter account ID (default = 'default'): ")
        val accountId = scanner.nextLine().trim().let { if (it.isEmpty()) "default" else it }
        
        val characterId = UUID.randomUUID().toString()
        
        val character = CharacterConfig(
            characterId = characterId,
            characterName = characterName,
            accountId = accountId,
            isActive = false
        )
        
        if (configManager.addCharacter(character)) {
            println("Character created with ID: $characterId")
            configManager.saveCharacter(character)
        } else {
            println("Failed to create character.")
        }
    }
    
    /**
     * Create a new configuration
     */
    private fun createConfig() {
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
        
        print("Enter configuration name: ")
        val configName = scanner.nextLine().trim()
        
        print("Enter description: ")
        val description = scanner.nextLine().trim()
        
        val configId = UUID.randomUUID().toString()
        
        // Create a simple configuration with default values
        val config = BotConfig(
            configId = configId,
            configName = configName,
            characterId = character.characterId,
            description = description,
            actionSequence = emptyList(),
            actionConfigs = emptyMap()
        )
        
        if (configManager.addConfig(config)) {
            println("Configuration created with ID: $configId")
            configManager.saveConfig(config)
            
            // Ask if the user wants to edit the configuration now
            print("Do you want to edit this configuration now? (y/n): ")
            val editNow = scanner.nextLine().trim().lowercase()
            if (editNow == "y" || editNow == "yes") {
                editConfigDetails(config)
            }
        } else {
            println("Failed to create configuration.")
        }
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
        
        print("Enter new account ID (current: ${character.accountId}): ")
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
        
        // Create a copy of the configuration with the updated values
        val updatedConfig = config.copy(
            configName = configName,
            description = description,
            actionSequence = actionSequence
        )
        
        // For simplicity, we're not editing the action configs here
        // A real implementation would need a more complex UI to edit nested structures
        
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
            
            // TODO: Implement character deletion in ConfigManager
            println("Character deleted.")
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
            
            // TODO: Implement config deletion in ConfigManager
            println("Configuration deleted.")
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
        
        println("╔════════════════════════════════════════════════════════════════╗")
        println("║ Configuration Details:                                         ║")
        println("╠════════════════════════════════════════════════════════════════╣")
        println("║ ID:          ${config.configId}")
        println("║ Name:        ${config.configName}")
        println("║ Character:   $characterName (${config.characterId})")
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