package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.io.TempDir
import java.io.File
import java.util.UUID

class ConfigManagerTest {

    @TempDir
    lateinit var tempDir: File
    
    private lateinit var configManager: ConfigManager
    private lateinit var testConfigDir: String
    
    @BeforeEach
    fun setUp() {
        // Create a test config directory inside the temp directory
        testConfigDir = File(tempDir, "test-configs").absolutePath
        
        // Create a new ConfigManager instance
        configManager = ConfigManager()
    }
    
    @Test
    fun testInitConfigDirectories() {
        // Initialize the config directories
        val result = configManager.initConfigDirectories(testConfigDir)
        
        // Verify the result
        assertTrue(result, "initConfigDirectories should return true")
        
        // Verify the directories were created
        val configDir = File(testConfigDir)
        val charactersDir = File(configDir, ConfigManager.CHARACTERS_DIR)
        val botConfigsDir = File(configDir, ConfigManager.BOT_CONFIGS_DIR)
        
        assertTrue(configDir.exists(), "Config directory should exist")
        assertTrue(configDir.isDirectory, "Config directory should be a directory")
        assertTrue(charactersDir.exists(), "Characters directory should exist")
        assertTrue(charactersDir.isDirectory, "Characters directory should be a directory")
        assertTrue(botConfigsDir.exists(), "Bot configs directory should exist")
        assertTrue(botConfigsDir.isDirectory, "Bot configs directory should be a directory")
    }
    
    @Test
    fun testSaveAndLoadCharacter() {
        // Initialize the config directories
        configManager.initConfigDirectories(testConfigDir)
        
        // Create a test character
        val characterId = UUID.randomUUID().toString()
        val character = CharacterConfig(
            characterId = characterId,
            characterName = "Test Character",
            accountId = "test-account",
            isActive = false
        )
        
        // Add the character to the ConfigManager
        val addResult = configManager.addCharacter(character)
        assertTrue(addResult, "addCharacter should return true")
        
        // Save the character to a file
        val saveResult = configManager.saveCharacter(character, testConfigDir)
        assertTrue(saveResult, "saveCharacter should return true")
        
        // Verify the file was created
        val charactersDir = File(testConfigDir, ConfigManager.CHARACTERS_DIR)
        val characterFile = File(charactersDir, "$characterId${ConfigManager.YAML_EXTENSION}")
        assertTrue(characterFile.exists(), "Character file should exist")
        
        // Create a new ConfigManager instance to load the character
        val newConfigManager = ConfigManager()
        
        // Load the character from the file
        val loadedCharacter = newConfigManager.loadCharacter(characterId, testConfigDir)
        assertNotNull(loadedCharacter, "loadCharacter should return a non-null character")
        
        // Verify the loaded character
        assertEquals(characterId, loadedCharacter?.characterId, "Character ID should match")
        assertEquals("Test Character", loadedCharacter?.characterName, "Character name should match")
        assertEquals("test-account", loadedCharacter?.accountId, "Account ID should match")
        assertEquals(false, loadedCharacter?.isActive, "Active status should match")
    }
    
    @Test
    fun testSaveAndLoadConfig() {
        // Initialize the config directories
        configManager.initConfigDirectories(testConfigDir)
        
        // Create a test character
        val characterId = UUID.randomUUID().toString()
        val character = CharacterConfig(
            characterId = characterId,
            characterName = "Test Character",
            accountId = "test-account",
            isActive = false
        )
        
        // Add the character to the ConfigManager
        configManager.addCharacter(character)
        
        // Create a test config
        val configId = UUID.randomUUID().toString()
        val config = BotConfig(
            configId = configId,
            configName = "Test Config",
            characterId = characterId,
            description = "Test description",
            actionSequence = listOf("Quest", "Raid"),
            actionConfigs = mapOf(
                "Quest" to QuestActionConfig(
                    enabled = true,
                    dungeonTargets = listOf(
                        QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true)
                    ),
                    repeatCount = 3
                ),
                "Raid" to RaidActionConfig(
                    enabled = true,
                    raidTargets = listOf(
                        RaidActionConfig.RaidTarget(raidName = "TestBoss", difficulty = "Heroic", enabled = true)
                    ),
                    runCount = 2
                )
            )
        )
        
        // Add the config to the ConfigManager
        val addResult = configManager.addConfig(config)
        assertTrue(addResult, "addConfig should return true")
        
        // Save the config to a file
        val saveResult = configManager.saveConfig(config, testConfigDir)
        assertTrue(saveResult, "saveConfig should return true")
        
        // Verify the file was created
        val botConfigsDir = File(testConfigDir, ConfigManager.BOT_CONFIGS_DIR)
        val configFile = File(botConfigsDir, "$configId${ConfigManager.YAML_EXTENSION}")
        assertTrue(configFile.exists(), "Config file should exist")
        
        // Create a new ConfigManager instance to load the config
        val newConfigManager = ConfigManager()
        
        // Add the character to the new ConfigManager (required for loading the config)
        newConfigManager.addCharacter(character)
        
        // Load the config from the file
        val loadedConfig = newConfigManager.loadConfig(configId, testConfigDir)
        assertNotNull(loadedConfig, "loadConfig should return a non-null config")
        
        // Verify the loaded config
        assertEquals(configId, loadedConfig?.configId, "Config ID should match")
        assertEquals("Test Config", loadedConfig?.configName, "Config name should match")
        assertEquals(characterId, loadedConfig?.characterId, "Character ID should match")
        assertEquals("Test description", loadedConfig?.description, "Description should match")
        assertEquals(listOf("Quest", "Raid"), loadedConfig?.actionSequence, "Action sequence should match")
        assertEquals(2, loadedConfig?.actionConfigs?.size, "Action configs size should match")
    }
    
    @Test
    fun testSaveAndLoadActiveState() {
        // Initialize the config directories
        configManager.initConfigDirectories(testConfigDir)
        
        // Create a test character
        val characterId = UUID.randomUUID().toString()
        val character = CharacterConfig(
            characterId = characterId,
            characterName = "Test Character",
            accountId = "test-account",
            isActive = false
        )
        
        // Add the character to the ConfigManager
        configManager.addCharacter(character)
        
        // Create a test config
        val configId = UUID.randomUUID().toString()
        val config = BotConfig(
            configId = configId,
            configName = "Test Config",
            characterId = characterId,
            description = "Test description",
            actionSequence = listOf("Quest"),
            actionConfigs = mapOf(
                "Quest" to QuestActionConfig(
                    enabled = true,
                    dungeonTargets = listOf(
                        QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true)
                    ),
                    repeatCount = 3
                )
            )
        )
        
        // Add the config to the ConfigManager
        configManager.addConfig(config)
        
        // Set the active character and config
        configManager.setActiveCharacter(characterId, true)
        configManager.setActiveConfig(configId, true)
        
        // Save the active state
        val saveResult = configManager.saveActiveState(testConfigDir)
        assertTrue(saveResult, "saveActiveState should return true")
        
        // Verify the file was created
        val activeStateFile = File(testConfigDir, "active_state${ConfigManager.YAML_EXTENSION}")
        assertTrue(activeStateFile.exists(), "Active state file should exist")
        
        // Create a new ConfigManager instance to load the active state
        val newConfigManager = ConfigManager()
        
        // Add the character and config to the new ConfigManager
        newConfigManager.addCharacter(character)
        newConfigManager.addConfig(config)
        
        // Load the active state
        val loadResult = newConfigManager.loadActiveState(testConfigDir)
        assertTrue(loadResult, "loadActiveState should return true")
        
        // Verify the active character and config
        val activeCharacter = newConfigManager.getActiveCharacter()
        val activeConfig = newConfigManager.getActiveConfig()
        
        assertNotNull(activeCharacter, "Active character should not be null")
        assertEquals(characterId, activeCharacter?.characterId, "Active character ID should match")
        
        assertNotNull(activeConfig, "Active config should not be null")
        assertEquals(configId, activeConfig?.configId, "Active config ID should match")
    }
    
    @Test
    fun testSaveAndLoadAll() {
        // Initialize the config directories
        configManager.initConfigDirectories(testConfigDir)
        
        // Create test characters
        val character1Id = UUID.randomUUID().toString()
        val character1 = CharacterConfig(
            characterId = character1Id,
            characterName = "Character 1",
            accountId = "account1",
            isActive = false
        )
        
        val character2Id = UUID.randomUUID().toString()
        val character2 = CharacterConfig(
            characterId = character2Id,
            characterName = "Character 2",
            accountId = "account2",
            isActive = false
        )
        
        // Add the characters to the ConfigManager
        configManager.addCharacter(character1)
        configManager.addCharacter(character2)
        
        // Create test configs
        val config1Id = UUID.randomUUID().toString()
        val config1 = BotConfig(
            configId = config1Id,
            configName = "Config 1",
            characterId = character1Id,
            description = "Config 1 description",
            actionSequence = listOf("Quest"),
            actionConfigs = mapOf(
                "Quest" to QuestActionConfig(
                    enabled = true,
                    dungeonTargets = listOf(
                        QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 1, enabled = true)
                    ),
                    repeatCount = 1
                )
            )
        )
        
        val config2Id = UUID.randomUUID().toString()
        val config2 = BotConfig(
            configId = config2Id,
            configName = "Config 2",
            characterId = character2Id,
            description = "Config 2 description",
            actionSequence = listOf("Raid"),
            actionConfigs = mapOf(
                "Raid" to RaidActionConfig(
                    enabled = true,
                    raidTargets = listOf(
                        RaidActionConfig.RaidTarget(raidName = "Boss", difficulty = "Normal", enabled = true)
                    ),
                    runCount = 1
                )
            )
        )
        
        // Add the configs to the ConfigManager
        configManager.addConfig(config1)
        configManager.addConfig(config2)
        
        // Set the active character and config
        configManager.setActiveCharacter(character1Id, true)
        configManager.setActiveConfig(config1Id, true)
        
        // Save all to files
        val saveResult = configManager.saveAllToFiles(testConfigDir)
        assertTrue(saveResult, "saveAllToFiles should return true")
        
        // Create a new ConfigManager instance to load everything
        val newConfigManager = ConfigManager()
        
        // Load all from files
        val loadResult = newConfigManager.loadAllFromFiles(testConfigDir)
        assertTrue(loadResult, "loadAllFromFiles should return true")
        
        // Verify all characters were loaded
        val characters = newConfigManager.getAllCharacters()
        assertEquals(2, characters.size, "Should have loaded 2 characters")
        
        // Verify all configs were loaded
        val configs = newConfigManager.getAllConfigs()
        assertEquals(2, configs.size, "Should have loaded 2 configs")
        
        // Verify the active character and config
        val activeCharacter = newConfigManager.getActiveCharacter()
        val activeConfig = newConfigManager.getActiveConfig()
        
        assertNotNull(activeCharacter, "Active character should not be null")
        assertEquals(character1Id, activeCharacter?.characterId, "Active character ID should match")
        
        assertNotNull(activeConfig, "Active config should not be null")
        assertEquals(config1Id, activeConfig?.configId, "Active config ID should match")
    }
}