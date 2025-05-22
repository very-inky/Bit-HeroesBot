package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import orion.actions.QuestAction
import orion.actions.RaidAction

/**
 * Test class for directory-based template loading functionality
 * 
 * Note: These tests focus on the configuration aspects of directory-based template loading
 * without testing the actual interaction with the Bot class.
 */
class DirectoryBasedTemplateTest {

    @Test
    fun testQuestConfigWithDirectoryBasedTemplates() {
        // Create a QuestActionConfig with directory-based template loading
        val questConfig = QuestActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/quest"),
            useDirectoryBasedTemplates = true,
            dungeonTargets = listOf(
                QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 2, enabled = true)
            ),
            repeatCount = 2
        )

        // Verify the configuration
        assertTrue(questConfig.enabled)
        assertEquals(1, questConfig.commonTemplateDirectories.size)
        assertEquals("templates/ui", questConfig.commonTemplateDirectories[0])
        assertEquals(1, questConfig.specificTemplateDirectories.size)
        assertEquals("templates/quest", questConfig.specificTemplateDirectories[0])
        assertTrue(questConfig.useDirectoryBasedTemplates)
        assertEquals(1, questConfig.dungeonTargets.size)
        assertEquals(2, questConfig.repeatCount)
    }

    @Test
    fun testRaidConfigWithDirectoryBasedTemplates() {
        // Create a RaidActionConfig with directory-based template loading
        val raidConfig = RaidActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/raid"),
            useDirectoryBasedTemplates = true,
            raidTargets = listOf(
                RaidActionConfig.RaidTarget(raidName = "Dragon", difficulty = "Hard", enabled = true)
            ),
            runCount = 3
        )

        // Verify the configuration
        assertTrue(raidConfig.enabled)
        assertEquals(1, raidConfig.commonTemplateDirectories.size)
        assertEquals("templates/ui", raidConfig.commonTemplateDirectories[0])
        assertEquals(1, raidConfig.specificTemplateDirectories.size)
        assertEquals("templates/raid", raidConfig.specificTemplateDirectories[0])
        assertTrue(raidConfig.useDirectoryBasedTemplates)
        assertEquals(1, raidConfig.raidTargets.size)
        assertEquals("Dragon", raidConfig.raidTargets[0].raidName)
        assertEquals("Hard", raidConfig.raidTargets[0].difficulty)
        assertTrue(raidConfig.raidTargets[0].enabled)
        assertEquals(3, raidConfig.runCount)
    }

    @Test
    fun testMixedTemplateApproach() {
        // Create a QuestActionConfig with both directory-based and individual templates
        val questConfig = QuestActionConfig(
            enabled = true,
            commonTemplateDirectories = listOf("templates/ui"),
            specificTemplateDirectories = listOf("templates/quest"),
            useDirectoryBasedTemplates = true,
            commonActionTemplates = listOf("templates/ui/specific_button.png"),
            specificTemplates = listOf("templates/quest/specific_dungeon.png"),
            repeatCount = 1
        )

        // Verify the configuration
        assertTrue(questConfig.enabled)
        assertEquals(1, questConfig.commonTemplateDirectories.size)
        assertEquals("templates/ui", questConfig.commonTemplateDirectories[0])
        assertEquals(1, questConfig.specificTemplateDirectories.size)
        assertEquals("templates/quest", questConfig.specificTemplateDirectories[0])
        assertTrue(questConfig.useDirectoryBasedTemplates)
        assertEquals(1, questConfig.commonActionTemplates.size)
        assertEquals("templates/ui/specific_button.png", questConfig.commonActionTemplates[0])
        assertEquals(1, questConfig.specificTemplates.size)
        assertEquals("templates/quest/specific_dungeon.png", questConfig.specificTemplates[0])
        assertEquals(1, questConfig.repeatCount)
    }

    @Test
    fun testDefaultDirectoryValues() {
        // Create a QuestActionConfig with default values
        val questConfig = QuestActionConfig()

        // Verify the default values for directory-based template loading
        assertTrue(questConfig.enabled)
        assertEquals(1, questConfig.commonTemplateDirectories.size)
        assertEquals("templates/ui", questConfig.commonTemplateDirectories[0])
        assertEquals(1, questConfig.specificTemplateDirectories.size)
        assertEquals("templates/quest", questConfig.specificTemplateDirectories[0])
        assertTrue(questConfig.useDirectoryBasedTemplates)
        assertTrue(questConfig.commonActionTemplates.isEmpty())
        assertTrue(questConfig.specificTemplates.isEmpty())
    }
}
