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
     */
    fun captureScreen(): Mat {
        val screenRect = Rectangle(0, 0, screenSize.width, screenSize.height)
        val screenCapture = robot.createScreenCapture(screenRect)
        return bufferedImageToMat(screenCapture)
    }

    /**
     * Capture a screenshot of a specific region
     * @param x The x coordinate of the top-left corner
     * @param y The y coordinate of the top-left corner
     * @param width The width of the region
     * @param height The height of the region
     * @return The screenshot as a Mat object
     */
    fun captureRegion(x: Int, y: Int, width: Int, height: Int): Mat {
        val regionRect = Rectangle(x, y, width, height)
        val regionCapture = robot.createScreenCapture(regionRect)
        return bufferedImageToMat(regionCapture)
    }

    /**
     * Convert a BufferedImage to a Mat object
     * @param image The BufferedImage to convert
     * @return The converted Mat object
     */
    private fun bufferedImageToMat(image: BufferedImage): Mat {
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
    }

    /**
     * Save a Mat object as an image file
     * @param mat The Mat object to save
     * @param filename The filename to save to
     */
    fun saveImage(mat: Mat, filename: String) {
        Imgcodecs.imwrite(filename, mat)
    }

    /**
     * Register a template image with its original resolution information
     * @param templatePath The path to the template image
     * @param dpi The DPI of the screen where the template was captured (default is 96.0)
     */
    fun registerTemplate(templatePath: String, dpi: Double = 96.0) {
        val template = Imgcodecs.imread(templatePath)
        if (!template.empty()) {
            templateInfo[templatePath] = TemplateInfo(
                originalWidth = template.width(),
                originalHeight = template.height(),
                originalDPI = dpi
            )
            println("Registered template: $templatePath (${template.width()}x${template.height()} at ${dpi}DPI)")
        } else {
            println("Could not load template image for registration: $templatePath")
        }
    }

    /**
     * Find a template image within the screen using multiscale matching
     * @param templatePath The path to the template image
     * @param minScale The minimum scale to try (default is 0.5)
     * @param maxScale The maximum scale to try (default is 2.0)
     * @param scaleStep The step size between scales (default is 0.1)
     * @param confidenceThreshold The minimum confidence threshold (default is 0.66)
     * @return The location and scale of the template image, or null if not found
     */
    fun findTemplateMultiScale(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 2.0,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.66 // Adjusted default threshold
    ): Pair<Point, Double>? {
        val screen = captureScreen()
        val template = Imgcodecs.imread(templatePath)

        if (template.empty()) {
            println("Could not load template image: $templatePath")
            return null
        }

        // Register the template if it's not already registered
        if (!templateInfo.containsKey(templatePath)) {
            registerTemplate(templatePath)
        }

        var bestMatch: Point? = null
        var bestScale = 1.0
        var bestConfidence = 0.0

        // Try different scales
        var currentScale = minScale
        while (currentScale <= maxScale) {
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

            currentScale += scaleStep
        }

        // If the best match confidence is too low, return null
        if (bestConfidence < confidenceThreshold) {
            return null
        }

        println("Found template at scale: $bestScale with confidence: $bestConfidence")
        return Pair(bestMatch!!, bestScale)
    }

    /**
     * Find a template image within the screen
     * @param templatePath The path to the template image
     * @return The location of the template image, or null if not found
     */
    fun findTemplate(templatePath: String): Point? {
        // Use the multiscale version and return just the point
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
     */
    fun findTemplateDetailed(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 2.0,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.66
    ): TemplateMatchResult {
        val screen = captureScreen()
        val template = Imgcodecs.imread(templatePath)
        val dpi = getSystemDPIScaling()
        val screenRes = Pair(screenSize.width, screenSize.height)

        if (template.empty()) {
            println("Could not load template image: $templatePath")
            return TemplateMatchResult(null, 1.0, 0.0, screenRes, dpi)
        }

        // Register the template if it's not already registered
        if (!templateInfo.containsKey(templatePath)) {
            registerTemplate(templatePath)
        }

        var bestMatch: Point? = null
        var bestScale = 1.0
        var bestConfidence = 0.0

        // Try different scales
        var currentScale = minScale
        while (currentScale <= maxScale) {
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

            currentScale += scaleStep
        }

        // If the best match confidence is too low, return result with null location
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
     * @return True if the template was found and clicked, false otherwise
     */
    fun clickOnTemplate(templatePath: String): Boolean {
        val result = findTemplateMultiScale(templatePath)
        if (result != null) {
            val (location, scale) = result
            // val template = Imgcodecs.imread(templatePath) // No need to reload

            val info = templateInfo[templatePath]
            if (info == null) {
                // Attempt to register if not found, could be a dynamic template
                registerTemplate(templatePath, getSystemDPIScaling())
                val newInfo = templateInfo[templatePath]
                if (newInfo == null) {
                    println("Template info not found for $templatePath and could not register.")
                    return false
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
     */
    fun loadTemplatesFromDirectory(directoryPath: String, recursive: Boolean = true): Int {
        val directory = File(directoryPath)
        if (!directory.exists() || !directory.isDirectory) {
            println("Template directory does not exist or is not a directory: $directoryPath")
            return 0
        }

        var count = 0
        // Ensure system DPI is fetched once if needed for all templates in this load operation
        val currentDPI = getSystemDPIScaling()
        val files = if (recursive) directory.walkTopDown() else directory.listFiles()?.asSequence() ?: emptySequence()

        files.filter { it.isFile && (it.extension.lowercase() == "png" || it.extension.lowercase() == "jpg" || it.extension.lowercase() == "jpeg") }.forEach { file ->
            // Pass the fetched DPI to registerTemplate
            registerTemplate(file.absolutePath, currentDPI)
            count++
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
