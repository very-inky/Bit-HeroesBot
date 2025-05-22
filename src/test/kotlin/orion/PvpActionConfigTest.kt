package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

/**
 * Test class for PvpActionConfig
 * 
 * These tests verify that the PvpActionConfig class works as expected.
 */
class PvpActionConfigTest {

    @Test
    fun testPvpConfigDefaults() {
        // Create a PvpActionConfig with default values
        val pvpConfig = PvpActionConfig()

        // Verify the default values
        assertTrue(pvpConfig.enabled)
        assertTrue(pvpConfig.commonActionTemplates.isEmpty())
        assertTrue(pvpConfig.specificTemplates.isEmpty())
        assertEquals(5, pvpConfig.ticketsToUse)
        assertEquals(2, pvpConfig.opponentRank)
        assertFalse(pvpConfig.autoSelectOpponent)
    }

    @Test
    fun testPvpConfigCustomValues() {
        // Create a PvpActionConfig with custom values
        val pvpConfig = PvpActionConfig(
            enabled = true,
            commonActionTemplates = listOf("templates/ui/pvp_button.png"),
            specificTemplates = listOf("templates/ui/pvp_opponent_1.png"),
            ticketsToUse = 3,
            opponentRank = 4,
            autoSelectOpponent = true
        )

        // Verify the custom values
        assertTrue(pvpConfig.enabled)
        assertEquals(1, pvpConfig.commonActionTemplates.size)
        assertEquals("templates/ui/pvp_button.png", pvpConfig.commonActionTemplates[0])
        assertEquals(1, pvpConfig.specificTemplates.size)
        assertEquals("templates/ui/pvp_opponent_1.png", pvpConfig.specificTemplates[0])
        assertEquals(3, pvpConfig.ticketsToUse)
        assertEquals(4, pvpConfig.opponentRank)
        assertTrue(pvpConfig.autoSelectOpponent)
    }

    @Test
    fun testPvpConfigDisabled() {
        // Create a disabled PvpActionConfig
        val pvpConfig = PvpActionConfig(
            enabled = false,
            ticketsToUse = 1,
            opponentRank = 1
        )

        // Verify the configuration
        assertFalse(pvpConfig.enabled)
        assertEquals(1, pvpConfig.ticketsToUse)
        assertEquals(1, pvpConfig.opponentRank)
    }

    @Test
    fun testPvpConfigInBotConfig() {
        // Create a BotConfig with a PvpActionConfig
        val botConfig = BotConfig(
            configId = "test_config",
            configName = "Test Config",
            characterId = "test-hero",
            actionSequence = listOf("PVP"),
            actionConfigs = mapOf(
                "PVP" to PvpActionConfig(
                    enabled = true,
                    ticketsToUse = 5,
                    opponentRank = 2,
                    autoSelectOpponent = false
                )
            )
        )

        // Verify the configuration
        assertEquals("test_config", botConfig.configId)
        assertEquals("Test Config", botConfig.configName)
        assertEquals("test-hero", botConfig.characterId)
        assertEquals(1, botConfig.actionSequence.size)
        assertEquals("PVP", botConfig.actionSequence[0])
        assertEquals(1, botConfig.actionConfigs.size)

        // Verify PVP config
        val pvpConfig = botConfig.actionConfigs["PVP"] as PvpActionConfig
        assertTrue(pvpConfig.enabled)
        assertEquals(5, pvpConfig.ticketsToUse)
        assertEquals(2, pvpConfig.opponentRank)
        assertFalse(pvpConfig.autoSelectOpponent)
    }
}
