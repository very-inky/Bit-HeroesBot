package orion

import org.opencv.core.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import java.awt.Rectangle
import java.awt.Robot
import java.awt.Toolkit
import java.awt.image.BufferedImage
import java.awt.image.DataBufferByte
import java.io.File
import javax.imageio.ImageIO
import kotlinx.coroutines.*
import orion.utils.PathUtils
import java.awt.event.KeyEvent

/**
 * Bot class that handles the game automation logic using OpenCV
 */
class Bot(private val config: BotConfig, private val configManager: ConfigManager? = null) {
    private val robot = Robot()
    private val screenSize = Toolkit.getDefaultToolkit().screenSize

    private val templateInfo = mutableMapOf<String, TemplateInfo>()
    private var autopilotEngagementAttemptedThisSession = false
    var templateMatchingVerbosity: Boolean = false

    companion object {
        var useCoroutinesForTemplateMatching = false
        var useShapeMatching = false
        var useGrayscale = false
    }

    private data class TemplateWithMask(val bgr: Mat, val mask: Mat?)

    data class TemplateInfo(
        val originalWidth: Int,
        val originalHeight: Int,
        val originalDPI: Double = 96.0
    )

    data class TemplateMatchResult(
        val location: Point?,
        val scale: Double,
        val confidence: Double,
        val screenResolution: Pair<Int, Int>,
        val dpi: Double
    )

    fun initialize() {
        val characterName = configManager?.getCharacter(config.characterId)?.characterName ?: config.configName
        println("Bot initialized for character: $characterName, using config: ${config.configName}")
        println("Screen size: ${screenSize.width}x${screenSize.height}")
    }

    fun captureScreen(): Mat {
        try {
            val screenRect = Rectangle(0, 0, screenSize.width, screenSize.height)
            val mrImage = robot.createMultiResolutionScreenCapture(screenRect)
            val resolutionVariants = mrImage.resolutionVariants
            var physicalPixelImage: java.awt.Image = mrImage.getResolutionVariant(
                screenRect.width.toDouble(),
                screenRect.height.toDouble()
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
            return bufferedImageToBgrMat(bufferedImage)
        } catch (e: Exception) {
            println("Error capturing screen: ${e.message}")
            throw RuntimeException("Failed to capture screen", e)
        }
    }

    private fun bufferedImageToBgrMat(image: BufferedImage): Mat {
        try {
            val bgrImage = BufferedImage(image.width, image.height, BufferedImage.TYPE_3BYTE_BGR)
            bgrImage.createGraphics().apply {
                drawImage(image, 0, 0, null)
                dispose()
            }
            val pixels = (bgrImage.raster.dataBuffer as DataBufferByte).data
            val mat = Mat(bgrImage.height, bgrImage.width, CvType.CV_8UC3)
            mat.put(0, 0, pixels)
            return mat
        } catch (e: Exception) {
            println("Error converting image to BGR Mat: ${e.message}")
            throw RuntimeException("Failed to convert image to BGR Mat", e)
        }
    }

    fun registerTemplate(templatePath: String, dpi: Double = 96.0): Boolean {
        val template = Imgcodecs.imread(templatePath)
        try {
            if (!template.empty()) {
                templateInfo[templatePath] = TemplateInfo(
                    originalWidth = template.width(),
                    originalHeight = template.height(),
                    originalDPI = dpi
                )
                println("Registered template: $templatePath (${template.width()}x${template.height()} at ${dpi}DPI)")
                return true
            } else {
                throw RuntimeException("Could not load template image for registration: $templatePath")
            }
        } finally {
            template.release()
        }
    }

    fun findTemplateMultiScale(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 3.5,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.81,
        verbose: Boolean = false
    ): Pair<Point, Double>? {
        val detailedResult = findTemplateDetailed(templatePath, minScale, maxScale, scaleStep, confidenceThreshold, verbose)
        return if (detailedResult.location != null) {
            Pair(detailedResult.location, detailedResult.scale)
        } else {
            null
        }
    }

    fun findTemplate(templatePath: String, verbose: Boolean = false): Point? {
        return findTemplateMultiScale(templatePath, verbose = verbose)?.first
    }

    fun findTemplateDetailed(
        templatePath: String,
        minScale: Double = 0.5,
        maxScale: Double = 3.5,
        scaleStep: Double = 0.1,
        confidenceThreshold: Double = 0.80,
        verbose: Boolean = false
    ): TemplateMatchResult {
        return if (useCoroutinesForTemplateMatching) {
            runBlocking {
                findTemplateDetailedWithCoroutines(templatePath, minScale, maxScale, scaleStep, confidenceThreshold, verbose)
            }
        } else {
            findTemplateDetailedSequential(templatePath, minScale, maxScale, scaleStep, confidenceThreshold, verbose)
        }
    }

    private fun findTemplateDetailedSequential(
        templatePath: String,
        minScale: Double,
        maxScale: Double,
        scaleStep: Double,
        confidenceThreshold: Double,
        verbose: Boolean
    ): TemplateMatchResult {
        if (verbose || templateMatchingVerbosity) {
            println("Searching for template sequentially: $templatePath")
        }

        val dpi = getSystemDPIScaling()
        val screenRes = Pair(screenSize.width, screenSize.height)

        val templateBGRA = Imgcodecs.imread(templatePath, Imgcodecs.IMREAD_UNCHANGED)
        if (templateBGRA.empty()) throw RuntimeException("Could not load template image: $templatePath")

        val channels = ArrayList<Mat>()
        Core.split(templateBGRA, channels)
        val templateWithMask = if (channels.size == 4) {
            println("Template '$templatePath' has transparency. Applying mask.")
            val bgr = Mat()
            Core.merge(listOf(channels[0], channels[1], channels[2]), bgr)
            TemplateWithMask(bgr, channels[3])
        } else {
            println("Template '$templatePath' has no transparency.")
            TemplateWithMask(templateBGRA.clone(), null)
        }
        templateBGRA.release()

        if (useShapeMatching && templateWithMask.mask != null) {
            println("WARNING: Shape Matching (TM_CCORR_NORMED) is enabled but the template has transparency. Masking is NOT supported by this method and will be ignored. Results may be inaccurate.")
        }

        val screen = captureScreen()
        try {
            if (useGrayscale) {
                Imgproc.cvtColor(screen, screen, Imgproc.COLOR_BGR2GRAY)
                Imgproc.cvtColor(templateWithMask.bgr, templateWithMask.bgr, Imgproc.COLOR_BGR2GRAY)
            }

            if (!templateInfo.containsKey(templatePath)) {
                registerTemplate(templatePath)
            }

            var bestMatch: Point? = null
            var bestScale = 1.0
            var bestConfidence = 0.0
            val bestDebugTemplate = Mat()
            val bestDebugMask = Mat()

            var currentScale = minScale
            while (currentScale <= maxScale) {
                val scaledTemplate = Mat()
                val scaledMask = Mat()
                val result = Mat()
                try {
                    val newSize = Size(templateWithMask.bgr.width() * currentScale, templateWithMask.bgr.height() * currentScale)
                    Imgproc.resize(templateWithMask.bgr, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)
                    templateWithMask.mask?.let {
                        Imgproc.resize(it, scaledMask, newSize, 0.0, 0.0, Imgproc.INTER_NEAREST)
                    }

                    if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                        currentScale += scaleStep
                        continue
                    }

                    val matchMethod: Int
                    val finalMask: Mat
                    if (templateWithMask.mask != null && !useShapeMatching) {
                        matchMethod = Imgproc.TM_CCOEFF_NORMED
                        finalMask = scaledMask
                    } else {
                        matchMethod = if (useShapeMatching) Imgproc.TM_CCORR_NORMED else Imgproc.TM_CCOEFF_NORMED
                        finalMask = Mat()
                    }

                    Imgproc.matchTemplate(screen, scaledTemplate, result, matchMethod, finalMask)
                    val mmr = Core.minMaxLoc(result)
                    var confidence = mmr.maxVal

                    if (confidence.isInfinite() || confidence.isNaN()) {
                        if (verbose || templateMatchingVerbosity) {
                            println("  Scale $currentScale - Invalid confidence value detected: $confidence. Treating as 0.")
                        }
                        confidence = 0.0
                    }

                    if (confidence > bestConfidence) {
                        bestConfidence = confidence
                        bestMatch = mmr.maxLoc
                        bestScale = currentScale
                        scaledTemplate.copyTo(bestDebugTemplate)
                        if (!scaledMask.empty()) {
                            scaledMask.copyTo(bestDebugMask)
                        }
                    }
                } finally {
                    scaledTemplate.release()
                    scaledMask.release()
                    result.release()
                }
                currentScale += scaleStep
            }

            println("DEBUG: Saving images for best match (Scale: $bestScale, Confidence: $bestConfidence)")
            Imgcodecs.imwrite("debug_best_template.png", bestDebugTemplate)
            if (!bestDebugMask.empty()) {
                Imgcodecs.imwrite("debug_best_mask.png", bestDebugMask)
            }
            bestDebugTemplate.release()
            bestDebugMask.release()

            if (bestConfidence < confidenceThreshold) {
                return TemplateMatchResult(null, bestScale, bestConfidence, screenRes, dpi)
            }

            println("Found template '${templatePath.substringAfterLast('\\')}' with confidence: $bestConfidence")
            return TemplateMatchResult(bestMatch, bestScale, bestConfidence, screenRes, dpi)
        } finally {
            screen.release()
            templateWithMask.bgr.release()
            templateWithMask.mask?.release()
        }
    }

    private suspend fun findTemplateDetailedWithCoroutines(
        templatePath: String,
        minScale: Double,
        maxScale: Double,
        scaleStep: Double,
        confidenceThreshold: Double,
        verbose: Boolean
    ): TemplateMatchResult {
        if (verbose || templateMatchingVerbosity) {
            println("Searching for template with coroutines: $templatePath")
        }

        val dpi = getSystemDPIScaling()
        val screenRes = Pair(screenSize.width, screenSize.height)

        val templateBGRA = Imgcodecs.imread(templatePath, Imgcodecs.IMREAD_UNCHANGED)
        if (templateBGRA.empty()) throw RuntimeException("Could not load template image: $templatePath")

        val channels = ArrayList<Mat>()
        Core.split(templateBGRA, channels)
        val templateWithMask = if (channels.size == 4) {
            println("Template '$templatePath' has transparency. Applying mask.")
            val bgr = Mat()
            Core.merge(listOf(channels[0], channels[1], channels[2]), bgr)
            TemplateWithMask(bgr, channels[3])
        } else {
            println("Template '$templatePath' has no transparency.")
            TemplateWithMask(templateBGRA.clone(), null)
        }
        templateBGRA.release()

        if (useShapeMatching && templateWithMask.mask != null) {
            println("WARNING: Shape Matching (TM_CCORR_NORMED) is enabled but the template has transparency. Masking is NOT supported by this method and will be ignored. Results may be inaccurate.")
        }

        val screen = captureScreen()
        try {
            if (useGrayscale) {
                Imgproc.cvtColor(screen, screen, Imgproc.COLOR_BGR2GRAY)
                Imgproc.cvtColor(templateWithMask.bgr, templateWithMask.bgr, Imgproc.COLOR_BGR2GRAY)
            }

            if (!templateInfo.containsKey(templatePath)) {
                registerTemplate(templatePath)
            }

            val scales = generateSequence(minScale) { it + scaleStep }.takeWhile { it <= maxScale }.toList()

            return withContext(Dispatchers.Default) {
                val deferredResults = scales.map { scale ->
                    async {
                        val scaledTemplate = Mat()
                        val scaledMask = Mat()
                        val result = Mat()
                        try {
                            val newSize = Size(templateWithMask.bgr.width() * scale, templateWithMask.bgr.height() * scale)
                            Imgproc.resize(templateWithMask.bgr, scaledTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)
                            templateWithMask.mask?.let {
                                Imgproc.resize(it, scaledMask, newSize, 0.0, 0.0, Imgproc.INTER_NEAREST)
                            }

                            if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                                return@async Triple(null, scale, 0.0)
                            }

                            val matchMethod: Int
                            val finalMask: Mat
                            if (templateWithMask.mask != null && !useShapeMatching) {
                                matchMethod = Imgproc.TM_CCOEFF_NORMED
                                finalMask = scaledMask
                            } else {
                                matchMethod = if (useShapeMatching) Imgproc.TM_CCORR_NORMED else Imgproc.TM_CCOEFF_NORMED
                                finalMask = Mat()
                            }

                            Imgproc.matchTemplate(screen, scaledTemplate, result, matchMethod, finalMask)
                            val mmr = Core.minMaxLoc(result)
                            var confidence = mmr.maxVal

                            if (confidence.isInfinite() || confidence.isNaN()) {
                                if (verbose || templateMatchingVerbosity) {
                                    println("  Scale $scale - Invalid confidence value detected: $confidence. Treating as 0.")
                                }
                                confidence = 0.0
                            }
                            Triple(mmr.maxLoc, scale, confidence)
                        } catch (e: Exception) {
                            println("Error in coroutine at scale $scale: ${e.message}")
                            Triple(null, scale, 0.0)
                        } finally {
                            scaledTemplate.release()
                            scaledMask.release()
                            result.release()
                        }
                    }
                }

                val results = deferredResults.awaitAll()
                val bestResult = results.maxByOrNull { it.third } ?: Triple(null, 1.0, 0.0)
                val (bestMatch, bestScale, bestConfidence) = bestResult

                println("DEBUG: Saving images for best match (Scale: $bestScale, Confidence: $bestConfidence)")
                val bestDebugTemplate = Mat()
                val bestDebugMask = Mat()
                try {
                    val newSize = Size(templateWithMask.bgr.width() * bestScale, templateWithMask.bgr.height() * bestScale)
                    Imgproc.resize(templateWithMask.bgr, bestDebugTemplate, newSize, 0.0, 0.0, Imgproc.INTER_LINEAR)
                    Imgcodecs.imwrite("debug_best_template.png", bestDebugTemplate)
                    templateWithMask.mask?.let {
                        Imgproc.resize(it, bestDebugMask, newSize, 0.0, 0.0, Imgproc.INTER_NEAREST)
                        Imgcodecs.imwrite("debug_best_mask.png", bestDebugMask)
                    }
                } finally {
                    bestDebugTemplate.release()
                    bestDebugMask.release()
                }

                if (bestConfidence < confidenceThreshold) {
                    return@withContext TemplateMatchResult(null, bestScale, bestConfidence, screenRes, dpi)
                }

                println("Found template '${templatePath.substringAfterLast('\\')}' with confidence: $bestConfidence")
                return@withContext TemplateMatchResult(bestMatch, bestScale, bestConfidence, screenRes, dpi)
            }
        } finally {
            screen.release()
            templateWithMask.bgr.release()
            templateWithMask.mask?.release()
        }
    }

    fun click(x: Int, y: Int) {
        robot.mouseMove(x, y)
        robot.mousePress(java.awt.event.InputEvent.BUTTON1_DOWN_MASK)
        robot.delay(100)
        robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_DOWN_MASK)
    }

    fun pressKey(keyCode: Int) {
        try {
            robot.keyPress(keyCode)
            robot.delay(50)
            robot.keyRelease(keyCode)
            println("Sent key press: ${KeyEvent.getKeyText(keyCode)}")
        } catch (e: Exception) {
            println("Error pressing key ${KeyEvent.getKeyText(keyCode)}: ${e.message}")
        }
    }

    suspend fun ensureAutopilotEngagedOnce() {
        if (autopilotEngagementAttemptedThisSession) {
            println("Autopilot check already attempted this session.")
            return
        }
        autopilotEngagementAttemptedThisSession = true

        println("Performing one-time autopilot check for this session...")
        val autopilotOnTemplate = PathUtils.templatePath("ui", "autopiloton.png")
        val autopilotOffTemplate = PathUtils.templatePath("ui", "autopilotoff.png")

        if (findTemplate(autopilotOnTemplate, verbose = false) != null) {
            println("Autopilot is already ON.")
            return
        }

        if (findTemplate(autopilotOffTemplate, verbose = false) != null) {
            println("Autopilot is OFF. Attempting to toggle it ON by pressing SPACE.")
            pressKey(KeyEvent.VK_SPACE)
            delay(1000)
            if (findTemplate(autopilotOnTemplate, verbose = false) != null) {
                println("Autopilot successfully toggled ON.")
            } else {
                println("Failed to verify Autopilot turned ON after pressing SPACE.")
            }
        } else {
            println("Could not determine autopilot state (neither ON nor OFF template found).")
        }
    }

    fun clickOnTemplate(templatePath: String, verbose: Boolean = false): Boolean {
        val result = findTemplateMultiScale(templatePath, verbose = verbose)
        if (result != null) {
            val (location, scale) = result
            val info = templateInfo[templatePath] ?: run {
                registerTemplate(templatePath, getSystemDPIScaling())
                templateInfo[templatePath]
            }

            if (info != null) {
                val x = location.x.toInt() + (info.originalWidth * scale / 2).toInt()
                val y = location.y.toInt() + (info.originalHeight * scale / 2).toInt()
                click(x, y)
                return true
            }
        }
        println("Could not find template: $templatePath")
        return false
    }

    fun getSystemDPIScaling(): Double {
        return Toolkit.getDefaultToolkit().screenResolution / 96.0
    }

    fun getScreenResolution(): Pair<Int, Int> {
        return Pair(screenSize.width, screenSize.height)
    }

    fun run() {
        val characterName = configManager?.getCharacter(config.characterId)?.characterName ?: config.configName
        println("Bot running for character: $characterName ")
        println("Current system DPI scaling: ${getSystemDPIScaling()}")
        println("Screen resolution: ${screenSize.width}x${screenSize.height}")

        val questConfig = config.actionConfigs["Quest"]
        if (questConfig?.enabled == true && questConfig.specificTemplates.isNotEmpty()) {
            println("\n--- Simulating Quest Action ---")
            val firstQuestTemplate = questConfig.specificTemplates.first()
            println("Attempting to find and click: $firstQuestTemplate for Quest action.")
            if (clickOnTemplate(firstQuestTemplate)) {
                println("SUCCESS: Clicked on '$firstQuestTemplate' as part of Quest action.")
            } else {
                println("FAILURE: Could not find or click on '$firstQuestTemplate' for Quest action.")
            }
            println("--- Quest Action Simulation Finished ---")
        }
    }

    fun createTemplateDirectory(directoryPath: String): Boolean {
        val directory = File(directoryPath)
        if (!directory.exists()) {
            return directory.mkdirs()
        }
        return directory.isDirectory
    }

    fun loadTemplatesFromDirectory(directoryPath: String, recursive: Boolean = true): Int {
        val directory = File(directoryPath)
        if (!directory.exists() || !directory.isDirectory) {
            throw RuntimeException("Template directory does not exist or is not a directory: $directoryPath")
        }

        var count = 0
        val currentDPI = getSystemDPIScaling()
        val files = if (recursive) directory.walkTopDown() else directory.listFiles()?.asSequence() ?: emptySequence()

        files.filter { it.isFile && (it.extension.lowercase() in listOf("png", "jpg", "jpeg")) }.forEach { file ->
            try {
                if (!templateInfo.containsKey(file.absolutePath)) {
                    registerTemplate(file.absolutePath, currentDPI)
                    count++
                }
            } catch (e: Exception) {
                println("Error registering template ${file.name}: ${e.message}")
            }
        }
        println("Loaded $count new templates from $directoryPath using system DPI: $currentDPI")
        return count
    }

    fun getTemplatesByCategory(category: String): List<String> {
        val categoryPath = "${File.separatorChar}$category${File.separatorChar}"
        return templateInfo.keys.filter { it.contains(categoryPath, ignoreCase = true) }
    }

    fun getAllTemplates(): List<String> {
        return templateInfo.keys.toList()
    }
}