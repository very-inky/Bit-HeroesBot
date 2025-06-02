package orion.utils

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.io.TempDir
import java.io.File
import orion.*

class YamlUtilsTest {

    @TempDir
    lateinit var tempDir: File

    @Test
    fun testSerializeAndDeserializeCharacterConfig() {
        // Create a test character config
        val characterId = "test-character-id"
        val characterName = "Test Character"
        val accountId = "test-account"
        val isActive = true

        val character = CharacterConfig(
            characterId = characterId,
            characterName = characterName,
            accountId = accountId,
            isActive = isActive
        )

        // Create a temporary file
        val tempFile = File(tempDir, "character.yaml")

        // Serialize the character to YAML
        val writeSuccess = YamlUtils.writeToFile(character, tempFile)
        assertTrue(writeSuccess, "Writing to file should succeed")
        assertTrue(tempFile.exists(), "File should exist after writing")

        // Deserialize the character from YAML
        val deserializedCharacter = YamlUtils.readFromFile<CharacterConfig>(tempFile)
        assertNotNull(deserializedCharacter, "Deserialized character should not be null")

        // Verify the deserialized character
        assertEquals(characterId, deserializedCharacter?.characterId, "Character ID should match")
        assertEquals(characterName, deserializedCharacter?.characterName, "Character name should match")
        assertEquals(accountId, deserializedCharacter?.accountId, "Account ID should match")
        assertEquals(isActive, deserializedCharacter?.isActive, "Active status should match")
    }

    @Test
    fun testSerializeAndDeserializeBotConfig() {
        // Create a test bot config
        val configId = "test-config-id"
        val configName = "Test Config"
        val characterId = "test-character-id"
        val description = "Test description"
        val actionSequence = listOf("Quest", "Raid")
        val actionConfigs = mapOf(
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

        val botConfig = BotConfig(
            configId = configId,
            configName = configName,
            characterId = characterId,
            description = description,
            actionSequence = actionSequence,
            actionConfigs = actionConfigs
        )

        // Create a temporary file
        val tempFile = File(tempDir, "botconfig.yaml")

        // Serialize the bot config to YAML
        val writeSuccess = YamlUtils.writeToFile(botConfig, tempFile)
        assertTrue(writeSuccess, "Writing to file should succeed")
        assertTrue(tempFile.exists(), "File should exist after writing")

        // Deserialize the bot config from YAML
        val deserializedConfig = YamlUtils.readFromFile<BotConfig>(tempFile)
        assertNotNull(deserializedConfig, "Deserialized config should not be null")

        // Verify the deserialized config
        assertEquals(configId, deserializedConfig?.configId, "Config ID should match")
        assertEquals(configName, deserializedConfig?.configName, "Config name should match")
        assertEquals(characterId, deserializedConfig?.characterId, "Character ID should match")
        assertEquals(description, deserializedConfig?.description, "Description should match")
        assertEquals(actionSequence, deserializedConfig?.actionSequence, "Action sequence should match")
        assertEquals(2, deserializedConfig?.actionConfigs?.size, "Action configs size should match")

        // Verify Quest config
        val questConfig = deserializedConfig?.actionConfigs?.get("Quest") as? QuestActionConfig
        assertNotNull(questConfig, "Quest config should not be null")
        assertTrue(questConfig?.enabled ?: false, "Quest config should be enabled")
        assertEquals(1, questConfig?.dungeonTargets?.size, "Dungeon targets size should match")
        assertEquals(1, questConfig?.dungeonTargets?.get(0)?.zoneNumber, "Zone number should match")
        assertEquals(2, questConfig?.dungeonTargets?.get(0)?.dungeonNumber, "Dungeon number should match")
        assertEquals(3, questConfig?.repeatCount, "Repeat count should match")

        // Verify Raid config
        val raidConfig = deserializedConfig?.actionConfigs?.get("Raid") as? RaidActionConfig
        assertNotNull(raidConfig, "Raid config should not be null")
        assertTrue(raidConfig?.enabled ?: false, "Raid config should be enabled")
        assertEquals(1, raidConfig?.raidTargets?.size, "Raid targets size should match")
        assertEquals("TestBoss", raidConfig?.raidTargets?.get(0)?.raidName, "Raid name should match")
        assertEquals("Heroic", raidConfig?.raidTargets?.get(0)?.difficulty, "Difficulty should match")
        assertEquals(2, raidConfig?.runCount, "Run count should match")
    }

    @Test
    fun testSerializeAndDeserializeMap() {
        // Create a test map
        val map = mapOf(
            "activeCharacterId" to "test-character-id",
            "activeConfigId" to "test-config-id"
        )

        // Create a temporary file
        val tempFile = File(tempDir, "map.yaml")

        // Serialize the map to YAML
        val writeSuccess = YamlUtils.writeToFile(map, tempFile)
        assertTrue(writeSuccess, "Writing to file should succeed")
        assertTrue(tempFile.exists(), "File should exist after writing")

        // Deserialize the map from YAML
        val deserializedMap = YamlUtils.readFromFile<Map<String, String>>(tempFile)
        assertNotNull(deserializedMap, "Deserialized map should not be null")

        // Verify the deserialized map
        assertEquals(2, deserializedMap?.size, "Map size should match")
        assertEquals("test-character-id", deserializedMap?.get("activeCharacterId"), "Active character ID should match")
        assertEquals("test-config-id", deserializedMap?.get("activeConfigId"), "Active config ID should match")
    }
}