package orion.utils

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.io.File

class PathUtilsTest {

    @Test
    fun testBuildPath() {
        // Test with a simple path
        val path1 = PathUtils.buildPath("templates", "quest")
        assertEquals("templates${File.separator}quest", path1)

        // Test with a file name
        val path2 = PathUtils.buildPath("templates", "quest", "arrowleft.png")
        assertEquals("templates${File.separator}quest${File.separator}arrowleft.png", path2)

        // Test with multiple components
        val path3 = PathUtils.buildPath("templates", "quest", "zone", "1", "dungeon.png")
        assertEquals("templates${File.separator}quest${File.separator}zone${File.separator}1${File.separator}dungeon.png", path3)
    }

    @Test
    fun testTemplatePath() {
        // Test with just a category
        val path1 = PathUtils.templatePath("quest")
        assertEquals("templates${File.separator}quest", path1)

        // Test with a category and filename
        val path2 = PathUtils.templatePath("quest", "arrowleft.png")
        assertEquals("templates${File.separator}quest${File.separator}arrowleft.png", path2)
    }

    @Test
    fun testNormalizePath() {
        // Test with Windows-style path
        val windowsPath = "templates\\quest\\arrowleft.png"
        val normalizedWindowsPath = PathUtils.normalizePath(windowsPath)
        
        // Test with Unix-style path
        val unixPath = "templates/quest/arrowleft.png"
        val normalizedUnixPath = PathUtils.normalizePath(unixPath)
        
        // Both should be normalized to the system's separator
        val expectedPath = "templates${File.separator}quest${File.separator}arrowleft.png"
        assertEquals(expectedPath, normalizedWindowsPath)
        assertEquals(expectedPath, normalizedUnixPath)
    }
}