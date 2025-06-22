package orion.actions

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.io.File
import orion.utils.PathUtils
import orion.RaidActionConfig
import org.junit.jupiter.api.BeforeEach
import org.mockito.Mockito.*
import orion.Bot
import orion.ActionConfig
import org.mockito.Mock
import org.mockito.MockitoAnnotations
import org.opencv.core.Point
import java.lang.reflect.Method
import org.junit.jupiter.api.DisplayName
import org.mockito.ArgumentMatchers.anyString

class RaidActionTest {

    @Mock
    private lateinit var mockBot: Bot

    private lateinit var raidAction: RaidAction

    @BeforeEach
    fun setUp() {
        MockitoAnnotations.openMocks(this)
        raidAction = RaidAction()
    }

    @Test
    fun testPathConstruction() {
        // Test that paths are constructed correctly using PathUtils.buildPath

        // Verify that the paths are constructed correctly
        val expectedRaidIconPath = PathUtils.buildPath("templates/ui", "raidicon.png")
        val expectedArrowRightPath = PathUtils.buildPath("templates/raid", "arrowright.png")
        val expectedArrowLeftPath = PathUtils.buildPath("templates/raid", "arrowleft.png")
        val expectedRaidTemplatePath = PathUtils.buildPath("templates/raid", "raid1.png")
        val expectedRaidSummonPath = PathUtils.buildPath("templates/raid", "raidsummon.png")
        val expectedDialoguePath = PathUtils.buildPath("templates/ui", "handleinprogressdialogue.png")

        // These assertions verify that the paths are constructed correctly
        assertEquals("templates${File.separator}ui${File.separator}raidicon.png", expectedRaidIconPath)
        assertEquals("templates${File.separator}raid${File.separator}arrowright.png", expectedArrowRightPath)
        assertEquals("templates${File.separator}raid${File.separator}arrowleft.png", expectedArrowLeftPath)
        assertEquals("templates${File.separator}raid${File.separator}raid1.png", expectedRaidTemplatePath)
        assertEquals("templates${File.separator}raid${File.separator}raidsummon.png", expectedRaidSummonPath)
        assertEquals("templates${File.separator}ui${File.separator}handleinprogressdialogue.png", expectedDialoguePath)
    }

    @Test
    fun testRaidTargetConversion() {
        // Test the conversion between raid numbers and tier numbers

        // Test raid to tier conversion
        assertEquals(4, RaidActionConfig.RaidTarget.raidToTier(1))
        assertEquals(10, RaidActionConfig.RaidTarget.raidToTier(7))
        assertEquals(21, RaidActionConfig.RaidTarget.raidToTier(18))
        assertNull(RaidActionConfig.RaidTarget.raidToTier(0))  // Invalid raid number
        assertNull(RaidActionConfig.RaidTarget.raidToTier(19)) // Invalid raid number

        // Test tier to raid conversion
        assertEquals(1, RaidActionConfig.RaidTarget.tierToRaid(4))
        assertEquals(7, RaidActionConfig.RaidTarget.tierToRaid(10))
        assertEquals(18, RaidActionConfig.RaidTarget.tierToRaid(21))
        assertNull(RaidActionConfig.RaidTarget.tierToRaid(3))  // Invalid tier number
        assertNull(RaidActionConfig.RaidTarget.tierToRaid(22)) // Invalid tier number
    }

    @Test
    @DisplayName("Test RaidTarget getEffectiveRaidNumber and getEffectiveTierNumber methods")
    fun testRaidTargetGetEffectiveNumbers() {
        // Test getEffectiveRaidNumber and getEffectiveTierNumber methods

        // Create raid targets with different configurations
        val raidTarget1 = RaidActionConfig.RaidTarget(raidNumber = 5, tierNumber = null)
        val raidTarget2 = RaidActionConfig.RaidTarget(raidNumber = null, tierNumber = 10)
        val raidTarget3 = RaidActionConfig.RaidTarget(raidNumber = 8, tierNumber = 15) // Both specified, raid takes precedence
        val raidTarget4 = RaidActionConfig.RaidTarget(raidNumber = null, tierNumber = null) // Neither specified

        // Test getEffectiveRaidNumber
        assertEquals(5, raidTarget1.getEffectiveRaidNumber())
        assertEquals(7, raidTarget2.getEffectiveRaidNumber()) // Tier 10 -> Raid 7
        assertEquals(8, raidTarget3.getEffectiveRaidNumber()) // Raid takes precedence
        assertNull(raidTarget4.getEffectiveRaidNumber()) // Neither specified

        // Test getEffectiveTierNumber
        assertEquals(8, raidTarget1.getEffectiveTierNumber()) // Raid 5 -> Tier 8
        assertEquals(10, raidTarget2.getEffectiveTierNumber())
        assertEquals(15, raidTarget3.getEffectiveTierNumber()) // Tier takes precedence
        assertNull(raidTarget4.getEffectiveTierNumber()) // Neither specified
    }

    @Test
    @DisplayName("Test hasResourcesAvailable method")
    fun testHasResourcesAvailable() {
        // Create a mock RaidActionConfig
        val mockConfig = mock(RaidActionConfig::class.java)

        // Test case 1: runCount = 0, first check
        `when`(mockConfig.runCount).thenReturn(0)

        // First check should return true
        assertTrue(raidAction.hasResourcesAvailable(mockBot, mockConfig), 
            "First resource check should return true")

        // Second check should return true
        assertTrue(raidAction.hasResourcesAvailable(mockBot, mockConfig), 
            "Second resource check should return true")

        // Third check should return false (simulated resource depletion after 3 checks)
        assertFalse(raidAction.hasResourcesAvailable(mockBot, mockConfig), 
            "Third resource check should return false (resources depleted)")

        // Fourth check should return true (counter is reset after returning false)
        assertTrue(raidAction.hasResourcesAvailable(mockBot, mockConfig), 
            "Fourth resource check should return true (counter is reset)")

        // Test case 2: runCount > 0
        `when`(mockConfig.runCount).thenReturn(5)

        // Resource check should always return true when runCount > 0
        assertTrue(raidAction.hasResourcesAvailable(mockBot, mockConfig), 
            "Resource check should return true when runCount > 0")
    }
}
