package orion

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
    override val commonTemplateDirectories: List<String> = listOf("templates/ui"),
    override val specificTemplateDirectories: List<String> = listOf("templates/quest"),
    override val useDirectoryBasedTemplates: Boolean = true,
    val dungeonTargets: List<DungeonTarget> = emptyList(), // Specify dungeons with zone and dungeon numbers
    val repeatCount: Int = 1, // How many times to cycle through quests or a specific quest
    override val cooldownDuration: Int = 20 // Cooldown duration in minutes when resources are depleted
) : ActionConfig() {
    // Data class for specifying a dungeon with zone and dungeon number
    data class DungeonTarget(
        val zoneNumber: Int, // e.g., 1, 2, 3, etc.
        val dungeonNumber: Int, // e.g., 1, 2, 3, etc.
        val enabled: Boolean = true
    )
}

data class PvpActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf("templates/ui"),
    override val specificTemplateDirectories: List<String> = listOf("templates/pvp"),
    override val useDirectoryBasedTemplates: Boolean = true,
    val ticketsToUse: Int = 5, // Number of tickets to use (1-5)
    val opponentRank: Int = 2, // Which opponent to fight (1-4)
    val autoSelectOpponent: Boolean = false // Whether to automatically select opponents or use specified rank
) : ActionConfig()

data class GvgActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf("templates/ui"),
    override val specificTemplateDirectories: List<String> = listOf("templates/gvg"),
    override val useDirectoryBasedTemplates: Boolean = true,
    val badgeChoice: Int = 5, // 1-5
    val opponentChoice: Int = 3 // 1-4
) : ActionConfig()

data class WorldBossActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf("templates/ui"),
    override val specificTemplateDirectories: List<String> = listOf("templates/worldboss"),
    override val useDirectoryBasedTemplates: Boolean = true
    // Add specific WorldBoss settings if any, e.g., targetBossName, specificLootFilters
) : ActionConfig()

data class RaidActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(), // For finding raid menu, selecting difficulty etc.
    override val specificTemplates: List<String> = emptyList(),
    override val commonTemplateDirectories: List<String> = listOf("templates/ui"),
    override val specificTemplateDirectories: List<String> = listOf("templates/raid"),
    override val useDirectoryBasedTemplates: Boolean = true,
    val raidTargets: List<RaidTarget> = emptyList(), // Specific raids
    val runCount: Int = 3, // Number of times to run each raid target
    override val cooldownDuration: Int = 20 // Cooldown duration in minutes when resources are depleted
) : ActionConfig() {
    // Data class for specifying details about a raid target
    data class RaidTarget(
        val raidName: String, // Corresponds to legacy Patterns.Raid.RaidName
        val difficulty: String, // e.g., "Normal", "Hard", "Heroic"
        val enabled: Boolean = true
    )
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
                }
            }

            return true
        }

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
}
