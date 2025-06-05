package orion.actions

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.io.File
import orion.utils.PathUtils

class QuestActionTest {

    @Test
    fun testPathConstruction() {
        // Test that paths are constructed correctly using PathUtils.buildPath

        // Verify that the paths are constructed correctly
        val expectedArrowRightPath = PathUtils.buildPath("templates/quest", "arrowright.png")
        val expectedArrowLeftPath = PathUtils.buildPath("templates/quest", "arrowleft.png")
        val expectedZoneDetPath = PathUtils.buildPath("templates/quest", "zone1det.png")
        val expectedZoneSelectorPath = PathUtils.buildPath("templates/quest", "zonesselector.png")

        // These assertions verify that the paths are constructed correctly
        assertEquals("templates${File.separator}quest${File.separator}arrowright.png", expectedArrowRightPath)
        assertEquals("templates${File.separator}quest${File.separator}arrowleft.png", expectedArrowLeftPath)
        assertEquals("templates${File.separator}quest${File.separator}zone1det.png", expectedZoneDetPath)
        assertEquals("templates${File.separator}quest${File.separator}zonesselector.png", expectedZoneSelectorPath)
    }
}
