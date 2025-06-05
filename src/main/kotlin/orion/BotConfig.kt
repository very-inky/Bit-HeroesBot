package orion

import orion.utils.PathUtils
import orion.utils.YamlUtils
import java.io.File
import com.fasterxml.jackson.annotation.JsonIgnore

// Sealed class for action configurations
sealed class ActionConfig {
    abstract val enabled: Boolean
    // Common templates for general entry/exit/navigation for this action type
    abstract val commonActionTemplates: List<String>
    // Specific templates for this action type
    abstract val specificTemplates: List<String>
    // Template directories for automatic loading
    abstract val commonTemplateDirectories: List<String>
    // Action-specific template directories
    abstract val specificTemplateDirectories: List<String>
    // Whether to use directory-based template loading (true) or individual templates (false)
    abstract val useDirectoryBasedTemplates: Boolean
    // Cooldown duration in minutes when resources are depleted
    open val cooldownDuration: Int = 20
}

data class QuestActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf(PathUtils.templatePath("ui")),
    override val specificTemplateDirectories: List<String> = listOf(PathUtils.templatePath("quest")),
    override val useDirectoryBasedTemplates: Boolean = true,
    val dungeonTargets: List<DungeonTarget> = emptyList(), // Specify dungeons with zone and dungeon numbers
    val repeatCount: Int = 0, // How many times to cycle through quests or a specific quest (0 = infinite runs until out of resources)
    override val cooldownDuration: Int = 20 // Cooldown duration in minutes when resources are depleted
) : ActionConfig() {
    // Data class for specifying a dungeon with zone and dungeon number
    data class DungeonTarget(
        val zoneNumber: Int, // e.g., 1, 2, 3, etc.
        val dungeonNumber: Int, // e.g., 1, 2, 3, etc.
        val difficulty: String = "heroic", // Preferred difficulty: "heroic", "hard", or "normal"
        val enabled: Boolean = true
    )
}

data class PvpActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf(PathUtils.templatePath("ui")),
    override val specificTemplateDirectories: List<String> = listOf(PathUtils.templatePath("pvp")),
    override val useDirectoryBasedTemplates: Boolean = true,
    val ticketsToUse: Int = 5, // Number of tickets to use (1-5)
    val pvpOpponentChoice: Int = 2, // Which opponent to fight (1-4)
    val autoSelectOpponent: Boolean = false // Whether to automatically select opponents or use specified rank
) : ActionConfig()

data class GvgActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf(PathUtils.templatePath("ui")),
    override val specificTemplateDirectories: List<String> = listOf(PathUtils.templatePath("gvg")),
    override val useDirectoryBasedTemplates: Boolean = true,
    val badgeChoice: Int = 5, // 1-5
    val opponentChoice: Int = 1 // 1-4
) : ActionConfig()

data class WorldBossActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf(PathUtils.templatePath("ui")),
    override val specificTemplateDirectories: List<String> = listOf(PathUtils.templatePath("worldboss")),
    override val useDirectoryBasedTemplates: Boolean = true
    // Add specific WorldBoss settings if any, e.g., targetBossName, specificLootFilters
) : ActionConfig()

data class RaidActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(), // For finding raid menu, selecting difficulty etc.
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf(PathUtils.templatePath("ui")),
    override val specificTemplateDirectories: List<String> = listOf(PathUtils.templatePath("raid")),
    override val useDirectoryBasedTemplates: Boolean = true,
    val raidTargets: List<RaidTarget> = emptyList(), // Specific raids
    val runCount: Int = 0, // Number of times to run each raid target (0 = infinite runs until out of resources)
    override val cooldownDuration: Int = 20 // Cooldown duration in minutes when resources are depleted
) : ActionConfig() {
    // Data class for specifying details about a raid target
    data class RaidTarget(
        val raidName: String = "", // Corresponds to legacy Patterns.Raid.RaidName
        val raidNumber: Int? = null, // Raid number (e.g., 1, 2, 3, 4)
        val tierNumber: Int? = null, // Tier number (e.g., 4, 5, 6, 7)
        val difficulty: String = "Heroic", // e.g., "Normal", "Hard", "Heroic"
        val enabled: Boolean = true
    ) {
        // Mapping between raid numbers and tier numbers
        companion object {
            // Constants for valid raid and tier ranges
            private const val MIN_RAID_NUMBER = 1
            private const val MAX_RAID_NUMBER = 18
            private const val MIN_TIER_NUMBER = 4
            private const val MAX_TIER_NUMBER = 21

            /**
             * Convert a raid number to a tier number
             * @param raidNumber The raid number to convert
             * @return The corresponding tier number, or null if the raid number is invalid
             */
            fun raidToTier(raidNumber: Int): Int? {
                return when {
                    raidNumber !in MIN_RAID_NUMBER..MAX_RAID_NUMBER -> null
                    else -> raidNumber + 3
                }
            }

            /**
             * Convert a tier number to a raid number
             * @param tierNumber The tier number to convert
             * @return The corresponding raid number, or null if the tier number is invalid
             */
            fun tierToRaid(tierNumber: Int): Int? {
                return when {
                    tierNumber !in MIN_TIER_NUMBER..MAX_TIER_NUMBER -> null
                    else -> {
                        val raidNumber = tierNumber - 3
                        if (raidNumber !in MIN_RAID_NUMBER..MAX_RAID_NUMBER) null else raidNumber
                    }
                }
            }
        }

        /**
         * Get the effective raid number, converting from tier if necessary
         * @return The raid number, or null if neither raid nor tier is specified
         */
        @JsonIgnore
        fun getEffectiveRaidNumber(): Int? {
            return when {
                raidNumber != null -> raidNumber
                tierNumber != null -> tierToRaid(tierNumber)
                else -> null
            }
        }

        /**
         * Get the effective tier number, converting from raid if necessary
         * @return The tier number, or null if neither raid nor tier is specified
         */
        @JsonIgnore
        fun getEffectiveTierNumber(): Int? {
            return when {
                tierNumber != null -> tierNumber
                raidNumber != null -> raidToTier(raidNumber)
                else -> null
            }
        }
    }
}

/**
 * Configuration profile for a specific task or farming goal
 * Each character can have multiple configuration profiles
 */
data class BotConfig(
    val configId: String, // Unique identifier for this configuration
    val configName: String, // User-friendly name for this configuration
    val characterId: String, // Reference to the character this config belongs to
    val actionSequence: List<String>, // Sequence of actions to perform
    val actionConfigs: Map<String, ActionConfig>, // Configuration for each action
    val defaultAction: String = "Quest", // Default action if none specified
    val description: String = "" // Optional description of what this config is for
)

/**
 * Character configuration containing character-specific settings
 */
data class CharacterConfig(
    val characterId: String, // Unique identifier for this character
    val characterName: String, // Character name
    val accountId: String = "default", // For future multi-account support
    val isActive: Boolean = false // Whether this character is currently active
)

/**
 * Configuration manager to handle multiple bot configurations
 * and ensure only one is active at a time
 */
class ConfigManager {
    private val characters = mutableMapOf<String, CharacterConfig>()
    private val configs = mutableMapOf<String, BotConfig>()
    private var activeConfigId: String? = null
    private var activeCharacterId: String? = null

    companion object {
        // Default directories for configuration files
        const val DEFAULT_CONFIG_DIR = "configs"
        const val CHARACTERS_DIR = "characters"
        const val BOT_CONFIGS_DIR = "botconfigs"

        // File extensions
        const val YAML_EXTENSION = ".yaml"
    }

    /**
     * Add a character configuration
     * @param character The character configuration to add
     * @param forceActivate Whether to force activation if the character is active and another character is already active
     * @return True if added successfully, false if a character with the same ID already exists
     * @throws IllegalStateException if the character is active and another character is already active
     */
    fun addCharacter(character: CharacterConfig, forceActivate: Boolean = false): Boolean {
        if (characters.containsKey(character.characterId)) {
            return false
        }

        // If the character is active, check if another character is already active
        if (character.isActive) {
            val activeCharacters = characters.values.filter { it.isActive }
            if (activeCharacters.isNotEmpty() && !forceActivate) {
                val activeIds = activeCharacters.map { it.characterId }
                throw IllegalStateException("Cannot add active character ${character.characterId} because another character is already active: $activeIds. Use forceActivate=true to override.")
            }

            // Deactivate all other characters if this one is active
            if (forceActivate) {
                characters.forEach { (id, char) ->
                    if (char.isActive) {
                        characters[id] = char.copy(isActive = false)
                    }
                }
            }

            // Set this character as the active character
            activeCharacterId = character.characterId
        }

        characters[character.characterId] = character
        return true
    }

    /**
     * Add a bot configuration
     * @param config The bot configuration to add
     * @return True if added successfully, false if a config with the same ID already exists
     */
    fun addConfig(config: BotConfig): Boolean {
        if (configs.containsKey(config.configId)) {
            return false
        }

        // Verify that the character exists
        if (!characters.containsKey(config.characterId)) {
            return false
        }

        configs[config.configId] = config
        return true
    }

    /**
     * Set the active configuration
     * @param configId The ID of the configuration to activate
     * @return True if activated successfully, false if the config doesn't exist
     * @throws IllegalStateException if another configuration is already active and forceActivate is false
     */
    fun setActiveConfig(configId: String, forceActivate: Boolean = false): Boolean {
        if (!configs.containsKey(configId)) {
            return false
        }

        // Check if another configuration is already active
        if (activeConfigId != null && activeConfigId != configId && !forceActivate) {
            throw IllegalStateException("Another configuration (ID: $activeConfigId) is already active. Use forceActivate=true to override.")
        }

        activeConfigId = configId
        saveActiveState() // Add this line
        return true
    }

    /**
     * Check if a configuration is active
     * @param configId The ID of the configuration to check
     * @return True if the configuration is active, false otherwise
     */
    fun isConfigActive(configId: String): Boolean {
        return activeConfigId == configId
    }

    /**
     * Get the active configuration
     * @return The active configuration, or null if none is active
     */
    fun getActiveConfig(): BotConfig? {
        return activeConfigId?.let { configs[it] }
    }

    /**
     * Deactivate the current active configuration
     * @return True if a configuration was deactivated, false if no configuration was active
     */
    fun deactivateActiveConfig(): Boolean {
        if (activeConfigId != null) {
            activeConfigId = null
            saveActiveState() // Add this line
            return true
        }
        return false
    }

    /**
     * Get all configurations for a specific character
     * @param characterId The ID of the character
     * @return List of configurations for the character
     */
    fun getConfigsForCharacter(characterId: String): List<BotConfig> {
        return configs.values.filter { it.characterId == characterId }
    }

    /**
     * Get a character by ID
     * @param characterId The ID of the character
     * @return The character configuration, or null if not found
     */
    fun getCharacter(characterId: String): CharacterConfig? {
        return characters[characterId]
    }

    /**
     * Get a configuration by ID
     * @param configId The ID of the configuration
     * @return The bot configuration, or null if not found
     */
    fun getConfig(configId: String): BotConfig? {
        return configs[configId]
    }

    /**
     * Get all characters
     * @return List of all character configurations
     */
    fun getAllCharacters(): List<CharacterConfig> {
        return characters.values.toList()
    }

    /**
     * Get all configurations
     * @return List of all bot configurations
     */
    fun getAllConfigs(): List<BotConfig> {
        return configs.values.toList()
    }

    /**
     * Set the active character
     * @param characterId The ID of the character to activate
     * @param forceActivate Whether to force activation if another character is already active
     * @return True if activated successfully, false if the character doesn't exist
     * @throws IllegalStateException if another character is already active and forceActivate is false
     */
    fun setActiveCharacter(characterId: String, forceActivate: Boolean = false): Boolean {
        if (!characters.containsKey(characterId)) {
            return false
        }

        // Check if another character is already active
        if (activeCharacterId != null && activeCharacterId != characterId && !forceActivate) {
            throw IllegalStateException("Another character (ID: $activeCharacterId) is already active. Use forceActivate=true to override.")
        }

        // Deactivate the current active character if different
        if (activeCharacterId != null && activeCharacterId != characterId) {
            val currentActiveCharacter = characters[activeCharacterId]
            if (currentActiveCharacter != null) {
                characters[activeCharacterId!!] = currentActiveCharacter.copy(isActive = false)
            }
        }

        // Activate the new character
        val character = characters[characterId]!!
        characters[characterId] = character.copy(isActive = true)
        activeCharacterId = characterId
        saveActiveState() // Add this line
        return true
    }

    /**
     * Check if a character is active
     * @param characterId The ID of the character to check
     * @return True if the character is active, false otherwise
     */
    fun isCharacterActive(characterId: String): Boolean {
        return activeCharacterId == characterId
    }

    /**
     * Get the active character
     * @return The active character, or null if none is active
     */
    fun getActiveCharacter(): CharacterConfig? {
        return activeCharacterId?.let { characters[it] }
    }

    /**
     * Deactivate the current active character
     * @return True if a character was deactivated, false if no character was active
     */
    fun deactivateActiveCharacter(): Boolean {
        if (activeCharacterId != null) {
            val character = characters[activeCharacterId]
            if (character != null) {
                characters[activeCharacterId!!] = character.copy(isActive = false)
            }
            activeCharacterId = null
            saveActiveState() // Add this line
            return true
        }
        return false
    }

    /**
     * Get all configurations for the active character
     * @return List of configurations for the active character, or empty list if no character is active
     */
    fun getConfigsForActiveCharacter(): List<BotConfig> {
        return activeCharacterId?.let { getConfigsForCharacter(it) } ?: emptyList()
    }

    /**
     * Validate that only one character is active
     * @return True if only one character is active, false otherwise
     * @throws IllegalStateException if multiple characters are active
     */
    fun validateActiveCharacter(): Boolean {
        val activeCharacters = characters.values.filter { it.isActive }

        if (activeCharacters.isEmpty()) {
            return false
        }

        if (activeCharacters.size > 1) {
            val activeIds = activeCharacters.map { it.characterId }
            throw IllegalStateException("Multiple characters are active: $activeIds. Only one character should be active at a time.")
        }

        // Ensure activeCharacterId is set correctly
        if (activeCharacterId == null || activeCharacterId != activeCharacters.first().characterId) {
            activeCharacterId = activeCharacters.first().characterId
        }

        return true
    }

    /**
     * Get all characters for a specific account
     * @param accountId The ID of the account
     * @return List of characters for the account
     */
    fun getCharactersForAccount(accountId: String): List<CharacterConfig> {
        return characters.values.filter { it.accountId == accountId }
    }

    /**
     * Switch to a different account
     * @param accountId The ID of the account to switch to
     * @param characterId Optional ID of the character to activate (if null, the first character for the account will be activated)
     * @param configId Optional ID of the configuration to activate (if null, the first config for the character will be activated)
     * @return True if switched successfully, false if the account has no characters
     */
    fun switchAccount(accountId: String, characterId: String? = null, configId: String? = null): Boolean {
        // Get all characters for the account
        val accountCharacters = getCharactersForAccount(accountId)
        if (accountCharacters.isEmpty()) {
            return false
        }

        // Deactivate all characters
        characters.forEach { (id, char) ->
            if (char.isActive) {
                characters[id] = char.copy(isActive = false)
            }
        }
        // Also clear current active config if the character is changing
        if (activeCharacterId != (characterId ?: accountCharacters.first().characterId)) {
            activeConfigId = null
        }


        // Determine which character to activate
        val targetCharacterId = characterId ?: accountCharacters.first().characterId

        // Activate the character
        val character = characters[targetCharacterId]
        if (character != null) {
            characters[targetCharacterId] = character.copy(isActive = true)
            activeCharacterId = targetCharacterId

            // Determine which configuration to activate
            val characterConfigs = getConfigsForCharacter(targetCharacterId)
            if (characterConfigs.isNotEmpty()) {
                val targetConfigId = configId ?: characterConfigs.first().configId
                if (configs.containsKey(targetConfigId)) {
                    activeConfigId = targetConfigId
                } else {
                    // If specified configId doesn't exist, clear activeConfigId or set to first available
                    activeConfigId = if (characterConfigs.isNotEmpty()) characterConfigs.first().configId else null
                }
            } else {
                activeConfigId = null // No configs for this character
            }
            saveActiveState() // Add this line
            return true
        }
        saveActiveState() // Also save state if character activation fails but changes were made (e.g. deactivations)
        return false
    }

    /**
     * Validate the entire configuration system
     * @return True if the configuration is valid, false otherwise
     * @throws IllegalStateException if the configuration is invalid
     */
    fun validateConfiguration(): Boolean {
        // Validate that only one character is active
        validateActiveCharacter()

        // Validate that the active configuration belongs to the active character
        val activeConfig = getActiveConfig()
        val activeCharacter = getActiveCharacter()

        if (activeConfig != null && activeCharacter != null) {
            if (activeConfig.characterId != activeCharacter.characterId) {
                throw IllegalStateException("Active configuration (ID: ${activeConfig.configId}) belongs to character ${activeConfig.characterId}, but the active character is ${activeCharacter.characterId}.")
            }
        }

        return true
    }

    // ===== YAML Configuration File Methods =====

    /**
     * Initialize the configuration directory structure
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if the directories were created or already exist, false otherwise
     */
    fun initConfigDirectories(baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        val configDir = File(baseDir)
        val charactersDir = File(configDir, CHARACTERS_DIR)
        val botConfigsDir = File(configDir, BOT_CONFIGS_DIR)

        return try {
            configDir.mkdirs()
            charactersDir.mkdirs()
            botConfigsDir.mkdirs()
            true
        } catch (e: Exception) {
            println("Error creating configuration directories: ${e.message}")
            false
        }
    }

    /**
     * Save a character configuration to a YAML file
     * @param character The character configuration to save
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if saved successfully, false otherwise
     */
    fun saveCharacter(character: CharacterConfig, baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        val charactersDir = File(baseDir, CHARACTERS_DIR)
        if (!charactersDir.exists() && !charactersDir.mkdirs()) {
            println("Failed to create characters directory: ${charactersDir.absolutePath}")
            return false
        }

        val fileName = "${character.characterId}${YAML_EXTENSION}"
        val file = File(charactersDir, fileName)

        return YamlUtils.writeToFile(character, file)
    }

    /**
     * Save a bot configuration to a YAML file
     * @param config The bot configuration to save
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if saved successfully, false otherwise
     */
    fun saveConfig(config: BotConfig, baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        val botConfigsDir = File(baseDir, BOT_CONFIGS_DIR)
        if (!botConfigsDir.exists() && !botConfigsDir.mkdirs()) {
            println("Failed to create bot configs directory: ${botConfigsDir.absolutePath}")
            return false
        }

        val fileName = "${config.configId}${YAML_EXTENSION}"
        val file = File(botConfigsDir, fileName)

        return YamlUtils.writeToFile(config, file)
    }

    /**
     * Save all characters to YAML files
     * @param baseDir The base directory for configurations (default: "configs")
     * @return The number of characters successfully saved
     */
    fun saveAllCharacters(baseDir: String = DEFAULT_CONFIG_DIR): Int {
        var savedCount = 0

        characters.values.forEach { character ->
            if (saveCharacter(character, baseDir)) {
                savedCount++
            }
        }

        return savedCount
    }

    /**
     * Save all configurations to YAML files
     * @param baseDir The base directory for configurations (default: "configs")
     * @return The number of configurations successfully saved
     */
    fun saveAllConfigs(baseDir: String = DEFAULT_CONFIG_DIR): Int {
        var savedCount = 0

        configs.values.forEach { config ->
            if (saveConfig(config, baseDir)) {
                savedCount++
            }
        }

        return savedCount
    }

    /**
     * Save the active state (which character and config are active)
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if saved successfully, false otherwise
     */
    fun saveActiveState(baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        val configDir = File(baseDir)
        if (!configDir.exists() && !configDir.mkdirs()) {
            println("Failed to create config directory: ${configDir.absolutePath}")
            return false
        }

        val activeState = mapOf(
            "activeCharacterId" to activeCharacterId,
            "activeConfigId" to activeConfigId
        )

        val file = File(configDir, "active_state${YAML_EXTENSION}")

        return YamlUtils.writeToFile(activeState, file)
    }

    /**
     * Load a character configuration from a YAML file
     * @param characterId The ID of the character to load
     * @param baseDir The base directory for configurations (default: "configs")
     * @return The loaded character configuration, or null if not found or an error occurred
     */
    fun loadCharacter(characterId: String, baseDir: String = DEFAULT_CONFIG_DIR): CharacterConfig? {
        val charactersDir = File(baseDir, CHARACTERS_DIR)
        val file = File(charactersDir, "${characterId}${YAML_EXTENSION}")

        if (!file.exists()) {
            println("Character file does not exist: ${file.absolutePath}")
            return null
        }

        return YamlUtils.readFromFile<CharacterConfig>(file)
    }

    /**
     * Load a bot configuration from a YAML file
     * @param configId The ID of the configuration to load
     * @param baseDir The base directory for configurations (default: "configs")
     * @return The loaded bot configuration, or null if not found or an error occurred
     */
    fun loadConfig(configId: String, baseDir: String = DEFAULT_CONFIG_DIR): BotConfig? {
        val botConfigsDir = File(baseDir, BOT_CONFIGS_DIR)
        val file = File(botConfigsDir, "${configId}${YAML_EXTENSION}")

        if (!file.exists()) {
            println("Configuration file does not exist: ${file.absolutePath}")
            return null
        }

        return YamlUtils.readFromFile<BotConfig>(file)
    }

    /**
     * Load all character configurations from YAML files
     * @param baseDir The base directory for configurations (default: "configs")
     * @return The number of characters successfully loaded
     */
    fun loadAllCharacters(baseDir: String = DEFAULT_CONFIG_DIR): Int {
        val charactersDir = File(baseDir, CHARACTERS_DIR)
        if (!charactersDir.exists()) {
            println("Characters directory does not exist: ${charactersDir.absolutePath}")
            return 0
        }

        var loadedCount = 0

        charactersDir.listFiles { file -> file.isFile && file.name.endsWith(YAML_EXTENSION) }?.forEach { file ->
            val character = YamlUtils.readFromFile<CharacterConfig>(file)
            if (character != null) {
                // Don't force activate when loading from files
                if (addCharacter(character, false)) {
                    loadedCount++
                }
            }
        }

        return loadedCount
    }

    /**
     * Load all bot configurations from YAML files
     * @param baseDir The base directory for configurations (default: "configs")
     * @return The number of configurations successfully loaded
     */
    fun loadAllConfigs(baseDir: String = DEFAULT_CONFIG_DIR): Int {
        val botConfigsDir = File(baseDir, BOT_CONFIGS_DIR)
        if (!botConfigsDir.exists()) {
            println("Bot configs directory does not exist: ${botConfigsDir.absolutePath}")
            return 0
        }

        var loadedCount = 0

        botConfigsDir.listFiles { file -> file.isFile && file.name.endsWith(YAML_EXTENSION) }?.forEach { file ->
            val config = YamlUtils.readFromFile<BotConfig>(file)
            if (config != null) {
                if (addConfig(config)) {
                    loadedCount++
                }
            }
        }

        return loadedCount
    }

    /**
     * Load the active state (which character and config are active)
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if loaded successfully, false otherwise
     */
    fun loadActiveState(baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        val configDir = File(baseDir)
        val file = File(configDir, "active_state${YAML_EXTENSION}")

        if (!file.exists()) {
            println("Active state file does not exist: ${file.absolutePath}")
            return false
        }

        val activeState = YamlUtils.readFromFile<Map<String, String?>>(file)
        if (activeState != null) {
            val characterId = activeState["activeCharacterId"]
            val configId = activeState["activeConfigId"]

            if (characterId != null) {
                try {
                    setActiveCharacter(characterId, true)
                } catch (e: IllegalStateException) {
                    println("Warning: Could not set active character: ${e.message}")
                }
            }

            if (configId != null) {
                try {
                    setActiveConfig(configId, true)
                } catch (e: IllegalStateException) {
                    println("Warning: Could not set active config: ${e.message}")
                }
            }

            return true
        }

        return false
    }

    /**
     * Load all configurations and characters from YAML files
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if any configurations or characters were loaded, false otherwise
     */
    fun loadAllFromFiles(baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        // Initialize directories if they don't exist
        initConfigDirectories(baseDir)

        // Load characters first
        val charactersLoaded = loadAllCharacters(baseDir)

        // Then load configurations
        val configsLoaded = loadAllConfigs(baseDir)

        // Finally, load active state
        loadActiveState(baseDir)

        return charactersLoaded > 0 || configsLoaded > 0
    }

    /**
     * Save all configurations and characters to YAML files
     * @param baseDir The base directory for configurations (default: "configs")
     * @return True if any configurations or characters were saved, false otherwise
     */
    fun saveAllToFiles(baseDir: String = DEFAULT_CONFIG_DIR): Boolean {
        // Initialize directories if they don't exist
        initConfigDirectories(baseDir)

        // Save characters
        val charactersSaved = saveAllCharacters(baseDir)

        // Save configurations
        val configsSaved = saveAllConfigs(baseDir)

        // Save active state
        saveActiveState(baseDir)

        return charactersSaved > 0 || configsSaved > 0
    }

    /**
     * Remove a character from the ConfigManager
     * @param characterId The ID of the character to remove
     * @return True if the character was removed, false if the character doesn't exist
     */
    fun removeCharacter(characterId: String): Boolean {
        // Check if character exists
        if (!characters.containsKey(characterId)) {
            return false
        }

        // If character is active, deactivate it
        if (activeCharacterId == characterId) {
            activeCharacterId = null
        }

        // Remove any configurations associated with this character
        val characterConfigs = getConfigsForCharacter(characterId)
        characterConfigs.forEach { config ->
            removeConfig(config.configId)
        }

        // Remove the character from the map
        characters.remove(characterId)

        return true
    }

    /**
     * Remove a configuration from the ConfigManager
     * @param configId The ID of the configuration to remove
     * @return True if the configuration was removed, false if the configuration doesn't exist
     */
    fun removeConfig(configId: String): Boolean {
        // Check if config exists
        if (!configs.containsKey(configId)) {
            return false
        }

        // If config is active, deactivate it
        if (activeConfigId == configId) {
            activeConfigId = null
        }

        // Remove the config from the map
        configs.remove(configId)

        return true
    }
}
