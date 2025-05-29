package orion

import org.opencv.core.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import java.awt.Rectangle
import java.awt.Robot
import java.awt.Toolkit
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlinx.coroutines.*
import orion.utils.PathUtils
import java.awt.event.KeyEvent // Added import for KeyEvent

/**
 * Bot class that handles the game automation logic using OpenCV
 */
class Bot(private val config: BotConfig, private val configManager: ConfigManager? = null) { // Added ConfigManager parameter
    private val robot = Robot()
    private val screenSize = Toolkit.getDefaultToolkit().screenSize

    // Store information about template images
    private val templateInfo = mutableMapOf<String, TemplateInfo>()

    // Flag for session-wide autopilot check
    private var autopilotEngagementAttemptedThisSession = false

    companion object {
        /**
         * Flag to determine whether to use coroutines for template matching with scale checking.
         * When enabled, the findTemplateDetailed method will use coroutines to check
         * multiple scales in parallel, which can be significantly faster than
         * the sequential approach, especially when there are many scales to check.
         */
        var useCoroutinesForTemplateMatching = false

        /**
         * Flag to determine whether to use shape matching instead of standard template matching.
         * When enabled, the template matching will focus more on shapes and contours rather than
         * exact pixel values, which can be more robust to lighting changes and slight variations.
         * This uses TM_CCORR_NORMED instead of TM_CCOEFF_NORMED for matching.
         */
        var useShapeMatching = false

        /**
         * Flag to determine whether to convert images to grayscale before template matching.
         * When enabled, both the screen capture and template images will be converted to grayscale
         * before matching, which can improve matching in situations where color variations
         * might affect the results, and can also be more robust to lighting changes.
         */
        var useGrayscale = false
    }

    /**
     * Class to store information about template images
     */
    data class TemplateInfo(
        val originalWidth: Int,
        val originalHeight: Int,
        val originalDPI: Double = 96.0 // Default DPI for most screens
    )

    /**
     * Class to store comprehensive template matching results
     */
    data class TemplateMatchResult(
        val location: Point?,
        val scale: Double,
        val confidence: Double,
        val screenResolution: Pair<Int, Int>,
        val dpi: Double
    )

    /**
     * Initialize the bot
     */
    fun initialize() {
        // Get character name from ConfigManager if available, otherwise use config name
        val characterName = if (configManager != null) {
            configManager.getCharacter(config.characterId)?.characterName ?: config.configName
        } else {
            config.configName
        }

        println("Bot initialized for character: $characterName, using config: ${config.configName}")
        println("Screen size: ${screenSize.width}x${screenSize.height}")
        //Resolution can appear different if display scaling is utilized. Example, 4k with 150% scaling will appear as 2560x1440.
    }

    /**
     * Capture a screenshot of the entire screen
     * 
     * Note: The caller is responsible for releasing the returned Mat object
     * by calling mat.release() when it's no longer needed.
     * 
     * @return The screenshot as a Mat object
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     */
    fun captureScreen(): Mat {
        try {
            val screenRect = Rectangle(0, 0, screenSize.width, screenSize.height)
            // Use MultiResolutionScreenCapture for HiDPI support
            val mrImage = robot.createMultiResolutionScreenCapture(screenRect)
            // Select the highest resolution variant
            val resolutionVariants = mrImage.resolutionVariants
            var physicalPixelImage: java.awt.Image = mrImage.getResolutionVariant(
                screenRect.width.toDouble(),
                screenRect.height.toDouble()
            )
            if (resolutionVariants.isNotEmpty()) {
                physicalPixelImage = resolutionVariants.maxByOrNull { it.getWidth(null) * it.getHeight(null) } ?: physicalPixelImage
            }
            // Convert to BufferedImage if needed
            val bufferedImage: BufferedImage = if (physicalPixelImage is BufferedImage) {
                physicalPixelImage
            } else {
                val bimg = BufferedImage(
                    physicalPixelImage.getWidth(null),
                    physicalPixelImage.getHeight(null),
                    BufferedImage.TYPE_INT_RGB
                )
                val g = bimg.createGraphics()
                g.drawImage(physicalPixelImage, 0, 0, null)
                g.dispose()
                bimg
            }
            val mat = bufferedImageToMat(bufferedImage)
            if (mat == null) {
                throw UnsatisfiedLinkError("Failed to convert screen capture to Mat. OpenCV functionality may not be fully available.")
            }
            return mat
        } catch (e: UnsatisfiedLinkError) {
            println("Error: OpenCV functionality not fully available. Cannot capture screen: ${e.message}")
            throw e
        } catch (e: Exception) {
            println("Error capturing screen: ${e.message}")
            throw RuntimeException("Failed to capture screen", e)
        }
    }

    /**
     * Capture a screenshot of a specific region
     * 
     * Note: The caller is responsible for releasing the returned Mat object
     * by calling mat.release() when it's no longer needed.
     * 
     * @param x The x coordinate of the top-left corner
     * @param y The y coordinate of the top-left corner
     * @param width The width of the region
     * @param height The height of the region
     * @return The screenshot as a Mat object
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     */
    fun captureRegion(x: Int, y: Int, width: Int, height: Int): Mat { //not used
        try {
            val regionRect = Rectangle(x, y, width, height)
            // Use MultiResolutionScreenCapture for HiDPI support
            val mrImage = robot.createMultiResolutionScreenCapture(regionRect)
            val resolutionVariants = mrImage.resolutionVariants
            var physicalPixelImage: java.awt.Image = mrImage.getResolutionVariant(
                regionRect.width.toDouble(),
                regionRect.height.toDouble()
            )
            if (resolutionVariants.isNotEmpty()) {
                physicalPixelImage = resolutionVariants.maxByOrNull { it.getWidth(null) * it.getHeight(null) } ?: physicalPixelImage
            }
            val bufferedImage: BufferedImage = if (physicalPixelImage is BufferedImage) {
                physicalPixelImage
            } else {
                val bimg = BufferedImage(
                    physicalPixelImage.getWidth(null),
                    physicalPixelImage.getHeight(null),
                    BufferedImage.TYPE_INT_RGB
                )
                val g = bimg.createGraphics()
                g.drawImage(physicalPixelImage, 0, 0, null)
                g.dispose()
                bimg
            }
            val mat = bufferedImageToMat(bufferedImage)
            if (mat == null) {
                throw UnsatisfiedLinkError("Failed to convert region capture to Mat. OpenCV functionality may not be fully available.")
            }
            return mat
        } catch (e: UnsatisfiedLinkError) {
            println("Error: OpenCV functionality not fully available. Cannot capture region: ${e.message}")
            throw e
        } catch (e: Exception) {
            println("Error capturing region: ${e.message}")
            throw RuntimeException("Failed to capture region", e)
        }
    }

    /**
     * Convert a BufferedImage to a Mat object
     * 
     * Note: The caller is responsible for releasing the returned Mat object
     * by calling mat.release() when it's no longer needed.
     * 
     * @param image The BufferedImage to convert
     * @return The converted Mat object
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     */
    private fun bufferedImageToMat(image: BufferedImage): Mat {
        try {
            val mat = Mat(image.height, image.width, CvType.CV_8UC3)
            val data = ByteArray(image.width * image.height * 3)

            var index = 0
            for (y in 0 until image.height) {
                for (x in 0 until image.width) {
                    val rgb = image.getRGB(x, y)
                    data[index++] = (rgb and 0xFF).toByte() // Blue
                    data[index++] = (rgb shr 8 and 0xFF).toByte() // Green
                    data[index++] = (rgb shr 16 and 0xFF).toByte() // Red
                }
            }

            mat.put(0, 0, data)
            return mat
        } catch (e: UnsatisfiedLinkError) {
            println("Error: OpenCV functionality not fully available. Cannot convert image to Mat: ${e.message}")
            throw e
        } catch (e: Exception) {
            println("Error converting image to Mat: ${e.message}")
            throw RuntimeException("Failed to convert image to Mat", e)
        }
    }

    /**
     * Save a Mat object as an image file
     * @param mat The Mat object to save
     * @param filename The filename to save to
     * @return True if the image was saved successfully
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws IllegalArgumentException if mat is null
     * @throws RuntimeException if there's an error saving the image
     */
    fun saveImage(mat: Mat, filename: String): Boolean { //not used
        try {
            val result = Imgcodecs.imwrite(filename, mat)
            if (result) {
                println("Image saved successfully: $filename")
            } else {
                println("Failed to save image: $filename")
                throw RuntimeException("Failed to save image: $filename")
            }
            return result
        } catch (e: UnsatisfiedLinkError) {
            println("Error: OpenCV functionality not fully available. Cannot save image: ${e.message}")
            throw e
        } catch (e: Exception) {
            println("Error saving image: ${e.message}")
            throw RuntimeException("Failed to save image: $filename", e)
        }
    }

    /**
     * Register a template image with its original resolution information
     * @param templatePath The path to the template image
     * @param dpi The DPI of the screen where the template was captured (default is 96.0)
     * @return True if the template was registered successfully
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error registering the template
     */
    fun registerTemplate(templatePath: String, dpi: Double = 96.0): Boolean {
        val template = Mat()
        try {
            Imgcodecs.imread(templatePath).copyTo(template)
            if (!template.empty()) {
                templateInfo[templatePath] = TemplateInfo(
                    originalWidth = template.width(),
                    originalHeight = template.height(),
                    originalDPI = dpi
                )
                println("Registered template: $templatePath (${template.width()}x${template.height()} at ${dpi}DPI)")
                return true
            } else {
                val errorMsg = "Could not load template image for registration: $templatePath"
                println(errorMsg)
                throw RuntimeException(errorMsg)
            }
        } catch (e: UnsatisfiedLinkError) {
            println("Error: OpenCV functionality not fully available. Cannot register template: ${e.message}")
            throw e
        } catch (e: Exception) {
            println("Error registering template: ${e.message}")
            throw RuntimeException("Failed to register template: $templatePath", e)
        } finally {
            // Release Mat object to free native memory
            template.release()
        }
    }

    /**
     * Find a template image within the screen using multiscale matching
     * @param templatePath The path to the template image
     * @param minScale The minimum scale to try (default is 0.5)
     * @param maxScale The maximum scale to try (default is 2.0)
     * @param scaleStep The step size between scales (default is 0.1)
     * @param confidenceThreshold The minimum confidence threshold (default is 0.66)
     * @return The location and scale of the template image, or null if not found with sufficient confidence
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error during template matching
     */
    fun findTemplateMultiScale(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 3.5,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.74 // Adjusted default threshold, was 0.66
    ): Pair<Point, Double>? {
        if (useCoroutinesForTemplateMatching) {
            // Use the coroutine-based detailed finder
            val detailedResult = findTemplateDetailed(templatePath, minScale, maxScale, scaleStep, confidenceThreshold)
            return if (detailedResult.location != null) {
                Pair(detailedResult.location, detailedResult.scale)
            } else {
                null
            }
        } else {
            // Original sequential implementation
            val screen = Mat()
            val template = Mat()
            try {
                captureScreen().copyTo(screen) // This will throw if OpenCV is not available
                Imgcodecs.imread(templatePath).copyTo(template)

                if (template.empty()) {
                    val errorMsg = "Could not load template image: $templatePath"
                    println(errorMsg)
                    throw RuntimeException(errorMsg)
                }

                // Convert to grayscale if enabled
                if (useGrayscale) {
                    val grayScreen = Mat()
                    val grayTemplate = Mat()
                    try {
                        Imgproc.cvtColor(screen, grayScreen, Imgproc.COLOR_BGR2GRAY)
                        Imgproc.cvtColor(template, grayTemplate, Imgproc.COLOR_BGR2GRAY)
                        screen.release()
                        template.release()
                        grayScreen.copyTo(screen)
                        grayTemplate.copyTo(template)
                    } finally {
                        grayScreen.release()
                        grayTemplate.release()
                    }
                }

                // Register the template if it's not already registered
                if (!templateInfo.containsKey(templatePath)) {
                    // This will throw if registration fails
                    registerTemplate(templatePath)
                }

                var bestMatch: Point? = null
                var bestScale = 1.0
                var bestConfidence = 0.0

                // Try different scales
                var currentScale = minScale
                while (currentScale <= maxScale) {
                    val scaledTemplate = Mat()
                    val result = Mat()
                    try {
                        // Resize the template according to the current scale
                        val newSize = Size(template.width() * currentScale, template.height() * currentScale)
                        Imgproc.resize(template, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)

                        // Skip if the scaled template is larger than the screen
                        if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                            currentScale += scaleStep
                            continue
                        }

                        // Use shape matching method if enabled, otherwise use standard method
                        val matchMethod = if (useShapeMatching) Imgproc.TM_CCORR_NORMED else Imgproc.TM_CCOEFF_NORMED
                        Imgproc.matchTemplate(screen, scaledTemplate, result, matchMethod)

                        val mmr = Core.minMaxLoc(result)

                        // If this match is better than our previous best, update it
                        if (mmr.maxVal > bestConfidence) {
                            bestConfidence = mmr.maxVal
                            bestMatch = mmr.maxLoc
                            bestScale = currentScale
                        }
                    } catch (e: UnsatisfiedLinkError) {
                        println("Error: OpenCV functionality not fully available during template matching: ${e.message}")
                        throw e
                    } catch (e: Exception) {
                        println("Error during template matching: ${e.message}")
                        // Continue to the next scale
                    } finally {
                        // Release Mat objects to free native memory
                        scaledTemplate.release()
                        result.release()
                    }

                    currentScale += scaleStep
                }

                // If the best match confidence is too low, return null
                if (bestConfidence < confidenceThreshold || bestMatch == null) {
                    return null
                }

                println("Found template at scale: $bestScale with confidence: $bestConfidence (Sequential)")
                return Pair(bestMatch, bestScale)
            } catch (e: UnsatisfiedLinkError) {
                println("Error: OpenCV functionality not fully available. Cannot find template: ${e.message}")
                throw e
            } catch (e: Exception) {
                println("Error finding template: ${e.message}")
                throw RuntimeException("Failed to find template: $templatePath", e)
            } finally {
                // Release Mat objects to free native memory
                screen.release()
                template.release()
            }
        }
    }

    /**
     * Find a template image within the screen
     * @param templatePath The path to the template image
     * @return The location of the template image, or null if not found with sufficient confidence
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error during template matching
     */
    fun findTemplate(templatePath: String): Point? {
        // Use the multiscale version and return just the point
        // This will throw exceptions if OpenCV is not available
        val result = findTemplateMultiScale(templatePath)
        return result?.first
    }

    /**
     * Find a template image within the screen and return detailed information
     * @param templatePath The path to the template image
     * @param minScale The minimum scale to try (default is 0.25) // Adjusted from 0.5
     * @param maxScale The maximum scale to try (default is 4.0)  // Adjusted from 2.0
     * @param scaleStep The step size between scales (default is 0.1)
     * @param confidenceThreshold The minimum confidence threshold (default is 0.60) // Adjusted from 0.66
     * @return A TemplateMatchResult containing comprehensive information about the match
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error during template matching
     */
    fun findTemplateDetailed(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 3.5,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.73 // Adjusted from 0.66
    ): TemplateMatchResult {
        // Use coroutines if enabled
        return if (useCoroutinesForTemplateMatching) {
            // Use runBlocking to call the suspending function from a non-suspending context
            runBlocking {
                findTemplateDetailedWithCoroutines(templatePath, minScale, maxScale, scaleStep, confidenceThreshold)
            }
        } else {
            findTemplateDetailedSequential(templatePath, minScale, maxScale, scaleStep, confidenceThreshold)
        }
    }

    /**
     * Sequential implementation of template matching with scale checking.
     * This is the original implementation.
     */
    private fun findTemplateDetailedSequential(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 3.5,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.70
    ): TemplateMatchResult {
        val dpi = getSystemDPIScaling()
        val screenRes = Pair(screenSize.width, screenSize.height)

        val screen = Mat()
        val template = Mat()
        try {
            captureScreen().copyTo(screen) // This will throw if OpenCV is not available
            Imgcodecs.imread(templatePath).copyTo(template)

            if (template.empty()) {
                val errorMsg = "Could not load template image: $templatePath"
                println(errorMsg)
                throw RuntimeException(errorMsg)
            }

            // Convert to grayscale if enabled
            if (useGrayscale) {
                val grayScreen = Mat()
                val grayTemplate = Mat()
                try {
                    Imgproc.cvtColor(screen, grayScreen, Imgproc.COLOR_BGR2GRAY)
                    Imgproc.cvtColor(template, grayTemplate, Imgproc.COLOR_BGR2GRAY)
                    screen.release()
                    template.release()
                    grayScreen.copyTo(screen)
                    grayTemplate.copyTo(template)
                } finally {
                    grayScreen.release()
                    grayTemplate.release()
                }
            }

            // Register the template if it's not already registered
            if (!templateInfo.containsKey(templatePath)) {
                // This will throw if registration fails
                registerTemplate(templatePath)
            }

            var bestMatch: Point? = null
            var bestScale = 1.0
            var bestConfidence = 0.0

            // Try different scales
            var currentScale = minScale
            while (currentScale <= maxScale) {
                val scaledTemplate = Mat()
                val result = Mat()
                try {
                    // Resize the template according to the current scale
                    val newSize = Size(template.width() * currentScale, template.height() * currentScale)
                    Imgproc.resize(template, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)

                    // Skip if the scaled template is larger than the screen
                    if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                        currentScale += scaleStep
                        continue
                    }

                    // Use shape matching method if enabled, otherwise use standard method
                    val matchMethod = if (useShapeMatching) Imgproc.TM_CCORR_NORMED else Imgproc.TM_CCOEFF_NORMED
                    Imgproc.matchTemplate(screen, scaledTemplate, result, matchMethod)

                    val mmr = Core.minMaxLoc(result)

                    // If this match is better than our previous best, update it
                    if (mmr.maxVal > bestConfidence) {
                        bestConfidence = mmr.maxVal
                        bestMatch = mmr.maxLoc
                        bestScale = currentScale
                    }
                } catch (e: UnsatisfiedLinkError) {
                    println("Error: OpenCV functionality not fully available during template matching: ${e.message}")
                    throw e
                } catch (e: Exception) {
                    println("Error during template matching: ${e.message}")
                    // Continue to the next scale
                } finally {
                    // Release Mat objects to free native memory
                    scaledTemplate.release()
                    result.release()
                }

                currentScale += scaleStep
            }

            // If the best match confidence is too low, return null for the location
            if (bestConfidence < confidenceThreshold) {
                return TemplateMatchResult(null, bestScale, bestConfidence, screenRes, dpi)
            }

            return TemplateMatchResult(bestMatch, bestScale, bestConfidence, screenRes, dpi)
        } finally {
            // Release Mat objects to free native memory
            screen.release()
            template.release()
        }
    }

    /**
     * Coroutine-based implementation of template matching with scale checking.
     * This version uses coroutines to check multiple scales in parallel.
     */
    private suspend fun findTemplateDetailedWithCoroutines(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 3.5,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.70
    ): TemplateMatchResult {
        val dpi = getSystemDPIScaling()
        val screenRes = Pair(screenSize.width, screenSize.height)

        val screen = Mat()
        val template = Mat()
        try {
            captureScreen().copyTo(screen) // This will throw if OpenCV is not available
            Imgcodecs.imread(templatePath).copyTo(template)

            if (template.empty()) {
                val errorMsg = "Could not load template image: $templatePath"
                println(errorMsg)
                throw RuntimeException(errorMsg)
            }

            // Convert to grayscale if enabled
            if (useGrayscale) {
                val grayScreen = Mat()
                val grayTemplate = Mat()
                try {
                    Imgproc.cvtColor(screen, grayScreen, Imgproc.COLOR_BGR2GRAY)
                    Imgproc.cvtColor(template, grayTemplate, Imgproc.COLOR_BGR2GRAY)
                    screen.release()
                    template.release()
                    grayScreen.copyTo(screen)
                    grayTemplate.copyTo(template)
                } finally {
                    grayScreen.release()
                    grayTemplate.release()
                }
            }

            // Register the template if it's not already registered
            if (!templateInfo.containsKey(templatePath)) {
                // This will throw if registration fails
                registerTemplate(templatePath)
            }

            println("Starting parallel template matching with scale checking using coroutines...")
            val startTime = System.currentTimeMillis()

            // Generate a list of scales to check
            val scales = generateSequence(minScale) { it + scaleStep }
                .takeWhile { it <= maxScale }
                .toList()

            println("Checking ${scales.size} scales in parallel")

            // Use withContext to run on the Default dispatcher (optimized for CPU-bound tasks)
            return withContext(Dispatchers.Default) {
                // Create a list of deferred results using async
                val deferredResults = scales.map { scale ->
                    async {
                        val scaledTemplate = Mat()
                        val result = Mat()
                        try {
                            // Resize the template according to the current scale
                            val newSize = Size(template.width() * scale, template.height() * scale)
                            Imgproc.resize(template, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)

                            // Skip if the scaled template is larger than the screen
                            if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                                return@async Triple(null, scale, 0.0)
                            }

                            // Use shape matching method if enabled, otherwise use standard method
                            val matchMethod = if (useShapeMatching) Imgproc.TM_CCORR_NORMED else Imgproc.TM_CCOEFF_NORMED
                            Imgproc.matchTemplate(screen, scaledTemplate, result, matchMethod)

                            val mmr = Core.minMaxLoc(result)
                            Triple(mmr.maxLoc, scale, mmr.maxVal)
                        } catch (e: UnsatisfiedLinkError) {
                            println("Error: OpenCV functionality not fully available during template matching: ${e.message}")
                            throw e
                        } catch (e: Exception) {
                            println("Error during template matching at scale $scale: ${e.message}")
                            Triple(null, scale, 0.0)
                        } finally {
                            // Release Mat objects to free native memory
                            scaledTemplate.release()
                            result.release()
                        }
                    }
                }

                // Wait for all results
                val results = deferredResults.awaitAll()

                // Find the best match
                val bestResult = results.maxByOrNull { it.third } ?: Triple(null, 1.0, 0.0)
                val (bestMatch, bestScale, bestConfidence) = bestResult

                val totalTime = System.currentTimeMillis() - startTime
                println("Parallel template matching completed in ${totalTime}ms")

                // If the best match confidence is too low, return null for the location
                if (bestConfidence < confidenceThreshold) {
                    return@withContext TemplateMatchResult(null, bestScale, bestConfidence, screenRes, dpi)
                }

                return@withContext TemplateMatchResult(bestMatch, bestScale, bestConfidence, screenRes, dpi)
            }
        } finally {
            // Release Mat objects to free native memory
            screen.release()
            template.release()
        }
    }

    /**
     * Click at a specific location
     * @param x The x coordinate
     * @param y The y coordinate
     */
    fun click(x: Int, y: Int) {
        robot.mouseMove(x, y)
        robot.mousePress(java.awt.event.InputEvent.BUTTON1_DOWN_MASK)
        robot.delay(100)
        robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_DOWN_MASK)
    }

    /**
     * Sends a key press and release.
     * @param keyCode The java.awt.event.KeyEvent constant for the key.
     */
    fun pressKey(keyCode: Int) {
        try {
            robot.keyPress(keyCode)
            robot.delay(50) // Small delay between press and release
            robot.keyRelease(keyCode)
            println("Sent key press: ${KeyEvent.getKeyText(keyCode)}")
        } catch (e: Exception) {
            println("Error pressing key ${KeyEvent.getKeyText(keyCode)}: ${e.message}")
        }
    }

    /**
     * Ensures autopilot is engaged, only attempts once per session.
     * Looks for 'autopiloton.png'. If not found, looks for 'autopilotoff.png'.
     * If 'autopilotoff.png' is found, presses the SPACE key to toggle it.
     */
    suspend fun ensureAutopilotEngagedOnce() {
        if (autopilotEngagementAttemptedThisSession) {
            println("Autopilot check already attempted this session.")
            return
        }
        autopilotEngagementAttemptedThisSession = true // Mark as attempted for this session

        println("Performing one-time autopilot check for this session...")
        val autopilotOnTemplate = PathUtils.templatePath("ui", "autopiloton.png")
        val autopilotOffTemplate = PathUtils.templatePath("ui", "autopilotoff.png")

        // Check if templates exist before trying to find them
        if (!File(autopilotOnTemplate).exists()) {
            println("Warning: Autopilot ON template not found at $autopilotOnTemplate")
            // Decide if you want to proceed or handle this as an error
        }
        if (!File(autopilotOffTemplate).exists()) {
            println("Warning: Autopilot OFF template not found at $autopilotOffTemplate")
            // Decide if you want to proceed or handle this as an error
        }

        if (findTemplate(autopilotOnTemplate) != null) {
            println("Autopilot is already ON.")
            return
        }

        if (findTemplate(autopilotOffTemplate) != null) {
            println("Autopilot is OFF. Attempting to toggle it ON by pressing SPACE.")
            pressKey(KeyEvent.VK_SPACE)
            delay(1000) // Wait a second for the game to react

            // Verify if it turned on
            if (findTemplate(autopilotOnTemplate) != null) {
                println("Autopilot successfully toggled ON.")
            } else {
                println("Failed to verify Autopilot turned ON after pressing SPACE. It might still be off or the template is not found.")
            }
        } else {
            println("Could not determine autopilot state (neither ON nor OFF template found, or templates do not exist). Manual check might be needed.")
        }
    }

    /**
     * Click on a template image if found
     * @param templatePath The path to the template image
     * @return True if the template was found and clicked, false if the template was not found with sufficient confidence
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error during template matching or clicking
     */
    fun clickOnTemplate(templatePath: String): Boolean {
        // This will throw if OpenCV is not available
        val result = findTemplateMultiScale(templatePath)
        if (result != null) {
            val (location, scale) = result

            val info = templateInfo[templatePath]
            if (info == null) {
                // Attempt to register if not found, could be a dynamic template
                // This will throw if registration fails
                registerTemplate(templatePath, getSystemDPIScaling())

                val newInfo = templateInfo[templatePath]
                if (newInfo == null) {
                    println("Template info not found for $templatePath after registration.")
                    // Still try to click at the location even without template info
                    val x = location.x.toInt()
                    val y = location.y.toInt()
                    click(x, y)
                    println("Clicked at template location without dimensions: ($x, $y)")
                    return true
                }

                // Calculate the center of the template, taking scale into account
                val x = location.x.toInt() + (newInfo.originalWidth * scale / 2).toInt()
                val y = location.y.toInt() + (newInfo.originalHeight * scale / 2).toInt()
                click(x, y)
                return true
            }

            // Calculate the center of the template, taking scale into account
            val x = location.x.toInt() + (info.originalWidth * scale / 2).toInt()
            val y = location.y.toInt() + (info.originalHeight * scale / 2).toInt()

            click(x, y)
            return true
        }

        println("Could not find template: $templatePath")
        return false
    }

    /**
     * Get the current system DPI scaling factor
     * @return The DPI scaling factor (1.0 = 100%, 1.5 = 150%, etc.)
     */
    fun getSystemDPIScaling(): Double {
        // This is a simplified approach - in a real implementation, you would use
        // platform-specific APIs to get the actual DPI scaling
        val graphics = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment()
            .defaultScreenDevice.defaultConfiguration.createCompatibleImage(1, 1)
            .createGraphics()

        val dpi = graphics.deviceConfiguration.defaultTransform.scaleX
        graphics.dispose()

        return dpi
    }

    /**
     * Get the current screen resolution
     * @return A Pair containing the width and height of the screen
     */
    fun getScreenResolution(): Pair<Int, Int> {
        return Pair(screenSize.width, screenSize.height)
    }

    /**
     * Run the bot's main loop
     */
    fun run() {
        // Get character name from ConfigManager if available, otherwise use config name
        val characterName = if (configManager != null) {
            configManager.getCharacter(config.characterId)?.characterName ?: config.configName
        } else {
            config.configName
        }

        println("Bot running for character: $characterName with default action: ${config.defaultAction}")
        println("Current system DPI scaling: ${getSystemDPIScaling()}")
        println("Screen resolution: ${screenSize.width}x${screenSize.height}")

        // The main loop and action handling will be managed by a higher-level component
        // or specific action classes based on BotConfig.
        // For example, an ActionHandler might take the bot and config,
        // and then call methods like:
        // performAction(config.defaultAction, bot)

        // Example: If the config for "Quest" is enabled and has specific templates
        val questConfig = config.actionConfigs["Quest"]
        if (questConfig?.enabled == true && questConfig.specificTemplates.isNotEmpty()) {
            println("\n--- Simulating Quest Action ---")
            println("Quest action would look for templates: ${questConfig.specificTemplates.joinToString()}")
            // In a real scenario, you would loop through specificTemplates and call clickOnTemplate or findTemplate
            // For demonstration, let's try to click the first template if specified
            val firstQuestTemplate = questConfig.specificTemplates.first()
            println("Attempting to find and click: $firstQuestTemplate for Quest action.")
            if (clickOnTemplate(firstQuestTemplate)) {
                println("SUCCESS: Clicked on '$firstQuestTemplate' as part of Quest action.")
            } else {
                println("FAILURE: Could not find or click on '$firstQuestTemplate' for Quest action.")
            }
            println("--- Quest Action Simulation Finished ---")
        } else {
            println("\nNo specific action configured to run in this example, or Quest action is disabled/has no templates.")
        }

        println("\nBot run method finished. Further actions would be orchestrated based on the config.")
    }
    /**
     * Create a directory for storing templates
     * @param directoryPath The path to the directory to create
     * @return True if the directory was created successfully, false if it already exists or could not be created
     */
    fun createTemplateDirectory(directoryPath: String): Boolean {
        val directory = File(directoryPath)
        if (!directory.exists()) {
            return directory.mkdirs()
        }
        return directory.isDirectory
    }

    /**
     * Load all template images from a directory
     * @param directoryPath The path to the directory containing template images
     * @param recursive Whether to search subdirectories recursively (default is true)
     * @return The number of templates loaded
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error loading templates
     */
    fun loadTemplatesFromDirectory(directoryPath: String, recursive: Boolean = true): Int {
        val directory = File(directoryPath)
        if (!directory.exists() || !directory.isDirectory) {
            val errorMsg = "Template directory does not exist or is not a directory: $directoryPath"
            println(errorMsg)
            throw RuntimeException(errorMsg)
        }

        var count = 0
        var skippedCount = 0
        // Ensure system DPI is fetched once if needed for all templates in this load operation
        val currentDPI = getSystemDPIScaling()
        val files = if (recursive) directory.walkTopDown() else directory.listFiles()?.asSequence() ?: emptySequence()

        files.filter { it.isFile && (it.extension.lowercase() == "png" || it.extension.lowercase() == "jpg" || it.extension.lowercase() == "jpeg") }.forEach { file ->
            try {
                // Check if template is already registered to avoid duplicate loading
                if (templateInfo.containsKey(file.absolutePath)) {
                    skippedCount++
                    // Skip registration if already loaded
                } else {
                    // Pass the fetched DPI to registerTemplate
                    // This will throw if registration fails
                    registerTemplate(file.absolutePath, currentDPI)
                    count++
                }
            } catch (e: UnsatisfiedLinkError) {
                println("Error: OpenCV functionality not fully available. Cannot register template ${file.name}: ${e.message}")
                throw e
            } catch (e: Exception) {
                println("Error registering template ${file.name}: ${e.message}")
                // Continue with other templates instead of failing the entire operation
            }
        }

        if (skippedCount > 0) {
            println("Loaded $count templates from $directoryPath (skipped $skippedCount already loaded templates) using system DPI: $currentDPI")
        } else {
            println("Loaded $count templates from $directoryPath using system DPI: $currentDPI")
        }
        return count
    }

    /**
     * Get all registered template paths that belong to a specific category (subdirectory).
     * @param category The name of the subdirectory (e.g., "raid", "quest", "pvp", "gvg", "ui").
     * @return A list of template paths matching the category.
     */
    fun getTemplatesByCategory(category: String): List<String> {
        val categoryPath = "${File.separatorChar}$category${File.separatorChar}"
        val templatesPath = PathUtils.buildPath("templates", category)

        return templateInfo.keys.filter { templatePath ->
            // Normalize path separators for comparison using PathUtils
            val normalizedTemplatePath = PathUtils.normalizePath(templatePath)
            normalizedTemplatePath.contains(categoryPath, ignoreCase = true) ||
            // Also check if the template is directly in a folder named like the category, relative to a base "templates" dir
            normalizedTemplatePath.contains(PathUtils.normalizePath(templatesPath), ignoreCase = true)
        }
    }

    /**
     * Get all registered templates
     * @return A list of all registered template paths
     */
    fun getAllTemplates(): List<String> {
        return templateInfo.keys.toList()
    }
}
