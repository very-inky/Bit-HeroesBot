package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class BotConfigTest {

    @Test
    fun testQuestConfigWithDungeonTargets() {
        // Create a QuestActionConfig with dungeon targets
        val questConfig = QuestActionConfig(
            enabled = true,
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true),
                QuestActionConfig.DungeonTarget(zoneNumber = 6, dungeonNumber = 3, enabled = true)
            ),
            repeatCount = 2
        )

        // Verify the configuration
        assertTrue(questConfig.enabled)
        assertEquals(2, questConfig.dungeonTargets.size)
        assertEquals(1, questConfig.dungeonTargets[0].zoneNumber)
        assertEquals(2, questConfig.dungeonTargets[0].dungeonNumber)
        assertTrue(questConfig.dungeonTargets[0].enabled)
        assertEquals(6, questConfig.dungeonTargets[1].zoneNumber)
        assertEquals(3, questConfig.dungeonTargets[1].dungeonNumber)
        assertTrue(questConfig.dungeonTargets[1].enabled)
        assertEquals(2, questConfig.repeatCount)
    }

    @Test
    fun testPvpConfig() {
        // Create a PvpActionConfig
        val pvpConfig = PvpActionConfig(
            enabled = true,
            ticketsToUse = 3,
            opponentRank = 4,
            autoSelectOpponent = false
        )

        // Verify the configuration
        assertTrue(pvpConfig.enabled)
        assertEquals(3, pvpConfig.ticketsToUse)
        assertEquals(4, pvpConfig.opponentRank)
        assertFalse(pvpConfig.autoSelectOpponent)
    }

    @Test
    fun testBotConfigWithMultipleActions() {
        // Create a BotConfig with multiple actions
        val botConfig = BotConfig(
            configId = "test_config",
            characterName = "TestHero",
            actionSequence = listOf("Quest", "PVP"),
            actionConfigs = mapOf(
                "Quest" to QuestActionConfig(
                    enabled = true,
                    dungeonTargets = listOf(
                        QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true)
                    )
                ),
                "PVP" to PvpActionConfig(
                    enabled = true,
                    ticketsToUse = 5,
                    opponentRank = 2
                )
            )
        )

        // Verify the configuration
        assertEquals("test_config", botConfig.configId)
        assertEquals("TestHero", botConfig.characterName)
        assertEquals(2, botConfig.actionSequence.size)
        assertEquals("Quest", botConfig.actionSequence[0])
        assertEquals("PVP", botConfig.actionSequence[1])
        assertEquals(2, botConfig.actionConfigs.size)

        // Verify Quest config
        val questConfig = botConfig.actionConfigs["Quest"] as QuestActionConfig
        assertTrue(questConfig.enabled)
        assertEquals(1, questConfig.dungeonTargets.size)
        assertEquals(1, questConfig.dungeonTargets[0].zoneNumber)
        assertEquals(2, questConfig.dungeonTargets[0].dungeonNumber)

        // Verify PVP config
        val pvpConfig = botConfig.actionConfigs["PVP"] as PvpActionConfig
        assertTrue(pvpConfig.enabled)
        assertEquals(5, pvpConfig.ticketsToUse)
        assertEquals(2, pvpConfig.opponentRank)
    }
}
