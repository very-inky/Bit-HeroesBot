package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.opencv.core.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import java.io.File

/**
 * Test class for OpenCV loading functionality
 *
 * This test verifies that OpenCV can be loaded correctly.
 * It tests both basic and advanced OpenCV functionality.
 * 
 * The bot requires full OpenCV functionality to operate correctly.
 * These tests verify that the OpenCV library is loaded with all required functionality.
 */
class OpenCVLoadingTest {

    @Test
    fun testOpenCVLoading() {
        // Call the loadOpenCVNativeLibrary function to load OpenCV with full functionality
        println("[DEBUG_LOG] Starting OpenCV loading test")
        loadOpenCVNativeLibrary()

        // If we get here without exceptions, the loading was successful with full functionality
        // Let's verify we can access OpenCV functionality
        val openCvVersion = Core.VERSION
        println("[DEBUG_LOG] OpenCV Version: $openCvVersion")

        // Print system information for debugging
        val osName = System.getProperty("os.name")
        val osArch = System.getProperty("os.arch")
        println("[DEBUG_LOG] Operating System: $osName")
        println("[DEBUG_LOG] Architecture: $osArch")

        // Verify OpenCV version is not empty
        assertNotNull(openCvVersion, "OpenCV version should not be null")
        assertTrue(openCvVersion.isNotEmpty(), "OpenCV version should not be empty")

        // Test Core functionality - this might not work if we only have partial functionality
        try {
            val buildInfo = Core.getBuildInformation()
            assertNotNull(buildInfo, "OpenCV build information should not be null")
            assertTrue(buildInfo.isNotEmpty(), "OpenCV build information should not be empty")
            println("[DEBUG_LOG] OpenCV build information available: ${buildInfo.length} characters")

            // Test Mat creation and manipulation (used in bufferedImageToMat)
            val mat = Mat(100, 100, CvType.CV_8UC3)
            assertFalse(mat.empty(), "Created Mat should not be empty")

            // Test Imgproc functionality (used in findTemplateMultiScale)
            val resizedMat = Mat()
            Imgproc.resize(mat, resizedMat, Size(50.0, 50.0))
            assertEquals(50, resizedMat.width(), "Resized Mat width should be 50")
            assertEquals(50, resizedMat.height(), "Resized Mat height should be 50")

            // Test Core.minMaxLoc (used in findTemplateMultiScale)
            val testMat = Mat(1, 5, CvType.CV_32F)
            testMat.put(0, 0, 1.0, 2.0, 3.0, 4.0, 5.0)
            val mmr = Core.minMaxLoc(testMat)
            assertEquals(1.0, mmr.minVal, 0.001, "Min value should be 1.0")
            assertEquals(5.0, mmr.maxVal, 0.001, "Max value should be 5.0")

            // Release Mat objects to free native memory
            mat.release()
            resizedMat.release()
            testMat.release()

            println("[DEBUG_LOG] Full OpenCV functionality is available and working correctly")
        } catch (e: UnsatisfiedLinkError) {
            println("[DEBUG_LOG] ERROR: OpenCV is not fully loaded. Full functionality is required.")
            println("[DEBUG_LOG] Error: ${e.message}")
            e.printStackTrace()
            fail("OpenCV is not fully loaded. Full functionality is required: ${e.message}")
        } catch (e: Exception) {
            println("[DEBUG_LOG] ERROR: Exception while testing OpenCV functionality: ${e.message}")
            e.printStackTrace()
            fail("Exception while testing OpenCV functionality: ${e.message}")
        }

        // Check if the library is stored in the resources folder
        // The library should be stored in the resources folder for production use
        val resourcesPath = when {
            osName.contains("Windows", ignoreCase = true) -> {
                if (osArch.contains("64")) "src/main/resources/natives/windows/x64"
                else "src/main/resources/natives/windows/x86"
            }
            osName.contains("Linux", ignoreCase = true) -> {
                if (osArch.contains("64")) "src/main/resources/natives/linux/x64"
                else "src/main/resources/natives/linux/x86"
            }
            osName.contains("Mac", ignoreCase = true) -> {
                "src/main/resources/natives/macos"
            }
            else -> {
                throw IllegalArgumentException("Unsupported operating system: $osName")
            }
        }

        val libraryFileName = when {
            osName.contains("Windows", ignoreCase = true) -> "opencv_java490.dll"
            osName.contains("Linux", ignoreCase = true) -> "libopencv_java490.so"
            osName.contains("Mac", ignoreCase = true) -> "libopencv_java490.dylib"
            else -> {
                throw IllegalArgumentException("Unsupported operating system: $osName")
            }
        }

        val libraryFile = File("$resourcesPath/$libraryFileName")
        if (libraryFile.exists()) {
            println("[DEBUG_LOG] Verified that OpenCV library is stored in resources: ${libraryFile.absolutePath}")
        } else {
            println("[DEBUG_LOG] OpenCV library is not stored in resources: $resourcesPath/$libraryFileName")
            println("[DEBUG_LOG] WARNING: The bot requires the library to be stored in resources for proper operation.")
        }

        // If we get here, the test passed, but we should warn if the library is not in the expected location
        if (!libraryFile.exists()) {
            println("[DEBUG_LOG] WARNING: OpenCV library is not stored in resources: $resourcesPath/$libraryFileName")
            println("[DEBUG_LOG] The bot requires the library to be stored in resources for proper operation.")
        }

        println("[DEBUG_LOG] OpenCV loading test completed successfully")
    }

    @Test
    fun testBotFunctionality() {
        // This test simulates what the Bot class does with OpenCV
        println("[DEBUG_LOG] Starting Bot functionality test")

        // Make sure OpenCV is loaded with full functionality
        loadOpenCVNativeLibrary()

        try {
            // Create a simple test Mat
            val mat = Mat(100, 100, CvType.CV_8UC3, Scalar(0.0, 0.0, 0.0))

            // Test template matching (similar to what findTemplateMultiScale does)
            val template = Mat(10, 10, CvType.CV_8UC3, Scalar(0.0, 0.0, 0.0))
            val result = Mat()

            // This requires full OpenCV functionality
            Imgproc.matchTemplate(mat, template, result, Imgproc.TM_CCOEFF_NORMED)

            // Test minMaxLoc
            val mmr = Core.minMaxLoc(result)

            // Verify the result
            assertNotNull(mmr, "MinMaxLocResult should not be null")

            // Release Mat objects to free native memory
            mat.release()
            template.release()
            result.release()

            println("[DEBUG_LOG] Bot functionality test passed with full OpenCV functionality")
        } catch (e: UnsatisfiedLinkError) {
            println("[DEBUG_LOG] ERROR: Bot functionality test failed. OpenCV is not fully loaded.")
            println("[DEBUG_LOG] Error: ${e.message}")
            e.printStackTrace()
            fail("Bot functionality test failed. OpenCV is not fully loaded: ${e.message}")
        } catch (e: Exception) {
            println("[DEBUG_LOG] ERROR: Bot functionality test failed with exception")
            println("[DEBUG_LOG] Error: ${e.message}")
            e.printStackTrace()
            fail("Bot functionality test failed with exception: ${e.message}")
        }

        // Check if the library is stored in the resources folder
        // The library should be stored in the resources folder for production use
        val osName = System.getProperty("os.name")
        val osArch = System.getProperty("os.arch")

        val resourcesPath = when {
            osName.contains("Windows", ignoreCase = true) -> {
                if (osArch.contains("64")) "src/main/resources/natives/windows/x64"
                else "src/main/resources/natives/windows/x86"
            }
            osName.contains("Linux", ignoreCase = true) -> {
                if (osArch.contains("64")) "src/main/resources/natives/linux/x64"
                else "src/main/resources/natives/linux/x86"
            }
            osName.contains("Mac", ignoreCase = true) -> {
                "src/main/resources/natives/macos"
            }
            else -> {
                throw IllegalArgumentException("Unsupported operating system: $osName")
            }
        }

        val libraryFileName = when {
            osName.contains("Windows", ignoreCase = true) -> "opencv_java490.dll"
            osName.contains("Linux", ignoreCase = true) -> "libopencv_java490.so"
            osName.contains("Mac", ignoreCase = true) -> "libopencv_java490.dylib"
            else -> {
                throw IllegalArgumentException("Unsupported operating system: $osName")
            }
        }

        val libraryFile = File("$resourcesPath/$libraryFileName")
        if (libraryFile.exists()) {
            println("[DEBUG_LOG] Verified that OpenCV library is stored in resources: ${libraryFile.absolutePath}")
        } else {
            println("[DEBUG_LOG] OpenCV library is not stored in resources: $resourcesPath/$libraryFileName")
            println("[DEBUG_LOG] WARNING: The bot requires the library to be stored in resources for proper operation.")
        }
    }
}
