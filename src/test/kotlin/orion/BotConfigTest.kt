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
            pvpOpponentChoice = 4,
            autoSelectOpponent = false
        )

        // Verify the configuration
        assertTrue(pvpConfig.enabled)
        assertEquals(3, pvpConfig.ticketsToUse)
        assertEquals(4, pvpConfig.pvpOpponentChoice)
        assertFalse(pvpConfig.autoSelectOpponent)
    }

    @Test
    fun testBotConfigWithMultipleActions() {
        // Create a BotConfig with multiple actions
        val botConfig = BotConfig(
            configId = "test_config",
            configName = "Test Config",
            characterId = "test_hero_id",
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
                    pvpOpponentChoice = 2
                )
            )
        )

        // Verify the configuration
        assertEquals("test_config", botConfig.configId)
        assertEquals("Test Config", botConfig.configName)
        assertEquals("test_hero_id", botConfig.characterId)
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
        assertEquals(2, pvpConfig.pvpOpponentChoice)
    }

    @Test
    fun testDefaultValues() {
        // Test default values for QuestActionConfig
        val questConfig = QuestActionConfig()
        assertEquals(0, questConfig.repeatCount, "QuestActionConfig.repeatCount should default to 0")

        // Test default values for RaidActionConfig
        val raidConfig = RaidActionConfig()
        assertEquals(0, raidConfig.runCount, "RaidActionConfig.runCount should default to 0")

        // Test default values for RaidTarget
        val raidTarget = RaidActionConfig.RaidTarget()
        assertEquals("Heroic", raidTarget.difficulty, "RaidTarget.difficulty should default to Heroic")

        // Test default values for DungeonTarget
        val dungeonTarget = QuestActionConfig.DungeonTarget(zoneNumber = 1, dungeonNumber = 1)
        assertEquals("heroic", dungeonTarget.difficulty, "DungeonTarget.difficulty should default to heroic")

        // Test default values for PvpActionConfig
        val pvpConfig = PvpActionConfig()
        assertEquals(5, pvpConfig.ticketsToUse, "PvpActionConfig.ticketsToUse should default to 5")
    }

    @Test
    fun testRaidTierMapping() {
        // Test raid to tier mapping
        assertEquals(4, RaidActionConfig.RaidTarget.raidToTier(1), "Raid 1 should map to Tier 4")
        assertEquals(5, RaidActionConfig.RaidTarget.raidToTier(2), "Raid 2 should map to Tier 5")
        assertEquals(6, RaidActionConfig.RaidTarget.raidToTier(3), "Raid 3 should map to Tier 6")
        assertEquals(7, RaidActionConfig.RaidTarget.raidToTier(4), "Raid 4 should map to Tier 7")
        assertEquals(8, RaidActionConfig.RaidTarget.raidToTier(5), "Raid 5 should map to Tier 8")
        assertEquals(9, RaidActionConfig.RaidTarget.raidToTier(6), "Raid 6 should map to Tier 9")
        assertEquals(10, RaidActionConfig.RaidTarget.raidToTier(7), "Raid 7 should map to Tier 10")
        assertEquals(11, RaidActionConfig.RaidTarget.raidToTier(8), "Raid 8 should map to Tier 11")
        assertEquals(12, RaidActionConfig.RaidTarget.raidToTier(9), "Raid 9 should map to Tier 12")
        assertEquals(13, RaidActionConfig.RaidTarget.raidToTier(10), "Raid 10 should map to Tier 13")
        assertEquals(14, RaidActionConfig.RaidTarget.raidToTier(11), "Raid 11 should map to Tier 14")
        assertEquals(15, RaidActionConfig.RaidTarget.raidToTier(12), "Raid 12 should map to Tier 15")
        assertEquals(16, RaidActionConfig.RaidTarget.raidToTier(13), "Raid 13 should map to Tier 16")
        assertEquals(17, RaidActionConfig.RaidTarget.raidToTier(14), "Raid 14 should map to Tier 17")
        assertEquals(18, RaidActionConfig.RaidTarget.raidToTier(15), "Raid 15 should map to Tier 18")
        assertEquals(19, RaidActionConfig.RaidTarget.raidToTier(16), "Raid 16 should map to Tier 19")
        assertEquals(20, RaidActionConfig.RaidTarget.raidToTier(17), "Raid 17 should map to Tier 20")
        assertEquals(21, RaidActionConfig.RaidTarget.raidToTier(18), "Raid 18 should map to Tier 21")

        // Test tier to raid mapping
        assertEquals(1, RaidActionConfig.RaidTarget.tierToRaid(4), "Tier 4 should map to Raid 1")
        assertEquals(2, RaidActionConfig.RaidTarget.tierToRaid(5), "Tier 5 should map to Raid 2")
        assertEquals(3, RaidActionConfig.RaidTarget.tierToRaid(6), "Tier 6 should map to Raid 3")
        assertEquals(4, RaidActionConfig.RaidTarget.tierToRaid(7), "Tier 7 should map to Raid 4")
        assertEquals(5, RaidActionConfig.RaidTarget.tierToRaid(8), "Tier 8 should map to Raid 5")
        assertEquals(6, RaidActionConfig.RaidTarget.tierToRaid(9), "Tier 9 should map to Raid 6")
        assertEquals(7, RaidActionConfig.RaidTarget.tierToRaid(10), "Tier 10 should map to Raid 7")
        assertEquals(8, RaidActionConfig.RaidTarget.tierToRaid(11), "Tier 11 should map to Raid 8")
        assertEquals(9, RaidActionConfig.RaidTarget.tierToRaid(12), "Tier 12 should map to Raid 9")
        assertEquals(10, RaidActionConfig.RaidTarget.tierToRaid(13), "Tier 13 should map to Raid 10")
        assertEquals(11, RaidActionConfig.RaidTarget.tierToRaid(14), "Tier 14 should map to Raid 11")
        assertEquals(12, RaidActionConfig.RaidTarget.tierToRaid(15), "Tier 15 should map to Raid 12")
        assertEquals(13, RaidActionConfig.RaidTarget.tierToRaid(16), "Tier 16 should map to Raid 13")
        assertEquals(14, RaidActionConfig.RaidTarget.tierToRaid(17), "Tier 17 should map to Raid 14")
        assertEquals(15, RaidActionConfig.RaidTarget.tierToRaid(18), "Tier 18 should map to Raid 15")
        assertEquals(16, RaidActionConfig.RaidTarget.tierToRaid(19), "Tier 19 should map to Raid 16")
        assertEquals(17, RaidActionConfig.RaidTarget.tierToRaid(20), "Tier 20 should map to Raid 17")
        assertEquals(18, RaidActionConfig.RaidTarget.tierToRaid(21), "Tier 21 should map to Raid 18")

        // Test invalid mappings
        assertNull(RaidActionConfig.RaidTarget.raidToTier(0), "Raid 0 should not map to any tier")
        assertNull(RaidActionConfig.RaidTarget.raidToTier(19), "Raid 19 should not map to any tier")
        assertNull(RaidActionConfig.RaidTarget.tierToRaid(3), "Tier 3 should not map to any raid")
        assertNull(RaidActionConfig.RaidTarget.tierToRaid(22), "Tier 22 should not map to any raid")
    }
}
