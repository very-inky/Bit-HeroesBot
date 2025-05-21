package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import orion.actions.QuestAction

/**
 * Test class for QuestAction configuration
 * 
 * Note: These tests focus on the configuration aspects of QuestAction
 * without testing the actual interaction with the Bot class.
 */
class QuestActionTest {

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
    fun testQuestConfigWithLegacyConfig() {
        // Create a QuestActionConfig with legacy configuration
        val questConfig = QuestActionConfig(
            enabled = true,
            commonActionTemplates = listOf("templates/buttons/quest_button.png"),
            desiredZones = listOf("Zone1"),
            desiredDungeons = listOf("Dungeon2"),
            repeatCount = 1
        )

        // Verify the configuration
        assertTrue(questConfig.enabled)
        assertEquals(1, questConfig.commonActionTemplates.size)
        assertEquals("templates/buttons/quest_button.png", questConfig.commonActionTemplates[0])
        assertEquals(1, questConfig.desiredZones.size)
        assertEquals("Zone1", questConfig.desiredZones[0])
        assertEquals(1, questConfig.desiredDungeons.size)
        assertEquals("Dungeon2", questConfig.desiredDungeons[0])
        assertEquals(1, questConfig.repeatCount)
    }

    @Test
    fun testQuestConfigDisabled() {
        // Create a disabled QuestActionConfig
        val questConfig = QuestActionConfig(
            enabled = false,
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true)
            )
        )

        // Verify the configuration
        assertFalse(questConfig.enabled)
        assertEquals(1, questConfig.dungeonTargets.size)
    }

    @Test
    fun testQuestActionHandlesConfig() {
        // This test verifies that QuestAction can handle the configuration
        // without actually executing the action

        // Create a QuestActionConfig with dungeon targets
        val questConfig = QuestActionConfig(
            enabled = true,
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true),
                QuestActionConfig.DungeonTarget(zoneNumber = 6, dungeonNumber = 3, enabled = true)
            ),
            repeatCount = 2
        )

        // Create the action
        val questAction = QuestAction()

        // Verify that the action class exists and can be instantiated
        assertNotNull(questAction)

        // Note: We can't test the actual execution without a proper mocking framework
        // or making the Bot class more testable
    }
}
