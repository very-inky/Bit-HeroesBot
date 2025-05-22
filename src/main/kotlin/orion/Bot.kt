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

/**
 * Bot class that handles the game automation logic using OpenCV
 */
class Bot(private val config: BotConfig, private val configManager: ConfigManager? = null) { // Added ConfigManager parameter
    private val robot = Robot()
    private val screenSize = Toolkit.getDefaultToolkit().screenSize

    // Store information about template images
    private val templateInfo = mutableMapOf<String, TemplateInfo>()

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
    }

    /**
     * Capture a screenshot of the entire screen
     * @return The screenshot as a Mat object
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     */
    fun captureScreen(): Mat {
        try {
            val screenRect = Rectangle(0, 0, screenSize.width, screenSize.height)
            val screenCapture = robot.createScreenCapture(screenRect)
            val mat = bufferedImageToMat(screenCapture)
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
     * @param x The x coordinate of the top-left corner
     * @param y The y coordinate of the top-left corner
     * @param width The width of the region
     * @param height The height of the region
     * @return The screenshot as a Mat object
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     */
    fun captureRegion(x: Int, y: Int, width: Int, height: Int): Mat {
        try {
            val regionRect = Rectangle(x, y, width, height)
            val regionCapture = robot.createScreenCapture(regionRect)
            val mat = bufferedImageToMat(regionCapture)
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
    fun saveImage(mat: Mat, filename: String): Boolean {
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
        try {
            val template = Imgcodecs.imread(templatePath)
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
        maxScale: Double = 2.0,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.66 // Adjusted default threshold
    ): Pair<Point, Double>? {
        try {
            val screen = captureScreen() // This will throw if OpenCV is not available
            val template = Imgcodecs.imread(templatePath)

            if (template.empty()) {
                val errorMsg = "Could not load template image: $templatePath"
                println(errorMsg)
                throw RuntimeException(errorMsg)
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
                try {
                    // Resize the template according to the current scale
                    val scaledTemplate = Mat()
                    val newSize = Size(template.width() * currentScale, template.height() * currentScale)
                    Imgproc.resize(template, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)

                    // Skip if the scaled template is larger than the screen
                    if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                        currentScale += scaleStep
                        continue
                    }

                    val result = Mat()
                    Imgproc.matchTemplate(screen, scaledTemplate, result, Imgproc.TM_CCOEFF_NORMED)

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
                }

                currentScale += scaleStep
            }

            // If the best match confidence is too low, return null
            if (bestConfidence < confidenceThreshold || bestMatch == null) {
                return null
            }

            println("Found template at scale: $bestScale with confidence: $bestConfidence")
            return Pair(bestMatch, bestScale)
        } catch (e: UnsatisfiedLinkError) {
            println("Error: OpenCV functionality not fully available. Cannot find template: ${e.message}")
            throw e
        } catch (e: Exception) {
            println("Error finding template: ${e.message}")
            throw RuntimeException("Failed to find template: $templatePath", e)
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
     * @param minScale The minimum scale to try (default is 0.5)
     * @param maxScale The maximum scale to try (default is 2.0)
     * @param scaleStep The step size between scales (default is 0.1)
     * @param confidenceThreshold The minimum confidence threshold (default is 0.66)
     * @return A TemplateMatchResult containing comprehensive information about the match
     * @throws UnsatisfiedLinkError if OpenCV functionality is not available
     * @throws RuntimeException if there's an error during template matching
     */
    fun findTemplateDetailed(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 2.0,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.66
    ): TemplateMatchResult {
        val dpi = getSystemDPIScaling()
        val screenRes = Pair(screenSize.width, screenSize.height)

        val screen = captureScreen() // This will throw if OpenCV is not available
        val template = Imgcodecs.imread(templatePath)

        if (template.empty()) {
            val errorMsg = "Could not load template image: $templatePath"
            println(errorMsg)
            throw RuntimeException(errorMsg)
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
            try {
                // Resize the template according to the current scale
                val scaledTemplate = Mat()
                val newSize = Size(template.width() * currentScale, template.height() * currentScale)
                Imgproc.resize(template, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)

                // Skip if the scaled template is larger than the screen
                if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                    currentScale += scaleStep
                    continue
                }

                val result = Mat()
                Imgproc.matchTemplate(screen, scaledTemplate, result, Imgproc.TM_CCOEFF_NORMED)

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
            }

            currentScale += scaleStep
        }

        // If the best match confidence is too low, return null for the location
        if (bestConfidence < confidenceThreshold) {
            return TemplateMatchResult(null, bestScale, bestConfidence, screenRes, dpi)
        }

        return TemplateMatchResult(bestMatch, bestScale, bestConfidence, screenRes, dpi)
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
     * Create a template directory if it doesn't exist
     * @param directoryPath The path to the template directory
     * @return True if the directory exists or was created successfully, false otherwise
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
        // Ensure system DPI is fetched once if needed for all templates in this load operation
        val currentDPI = getSystemDPIScaling()
        val files = if (recursive) directory.walkTopDown() else directory.listFiles()?.asSequence() ?: emptySequence()

        files.filter { it.isFile && (it.extension.lowercase() == "png" || it.extension.lowercase() == "jpg" || it.extension.lowercase() == "jpeg") }.forEach { file ->
            try {
                // Pass the fetched DPI to registerTemplate
                // This will throw if registration fails
                registerTemplate(file.absolutePath, currentDPI)
                count++
            } catch (e: UnsatisfiedLinkError) {
                println("Error: OpenCV functionality not fully available. Cannot register template ${file.name}: ${e.message}")
                throw e
            } catch (e: Exception) {
                println("Error registering template ${file.name}: ${e.message}")
                // Continue with other templates instead of failing the entire operation
            }
        }

        println("Loaded $count templates from $directoryPath using system DPI: $currentDPI")
        return count
    }

    /**
     * Get all registered template paths that belong to a specific category (subdirectory).
     * @param category The name of the subdirectory (e.g., "raid", "quest", "pvp", "gvg", "ui").
     * @return A list of template paths matching the category.
     */
    fun getTemplatesByCategory(category: String): List<String> {
        val categoryPath = "${File.separatorChar}$category${File.separatorChar}"
        return templateInfo.keys.filter { templatePath ->
            // Normalize path separators for comparison
            val normalizedTemplatePath = templatePath.replace("\\\\", "/").replace("/", File.separator)
            normalizedTemplatePath.contains(categoryPath, ignoreCase = true) ||
            // Also check if the template is directly in a folder named like the category, relative to a base "templates" dir
            normalizedTemplatePath.contains("templates$categoryPath", ignoreCase = true)

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
