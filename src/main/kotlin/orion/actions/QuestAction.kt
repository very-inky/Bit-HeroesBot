package orion.actions // Keep actions in a sub-package if desired

import orion.Bot
import orion.GameAction
import orion.ActionConfig
import orion.QuestActionConfig
import orion.BaseGameAction
import java.io.File
import kotlinx.coroutines.*

class QuestAction : BaseGameAction() {
    // Track the number of consecutive resource checks
    private var resourceCheckCount = 0

    // Store the last detected zone to optimize future zone detection
    private var lastDetectedZone = -1

    companion object {
        /**
         * Flag to determine whether to use coroutines for zone detection.
         * When enabled, the determineCurrentZone method will use coroutines to check
         * for zone templates in parallel, which can be significantly faster than
         * the sequential approach, especially when there are many templates to check.
         * 
         * This flag can be enabled by passing the --morethreads command-line argument.
         */
        var useCoroutines = false
    }

    override fun execute(bot: Bot, config: ActionConfig): Boolean {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to QuestAction.")
            return false
        }

        if (!config.enabled) {
            println("QuestAction is disabled in config.")
            return false
        }

        println("--- Executing Quest Action ---")

        // Load templates for navigation
        val (commonTemplates, specificTemplates) = loadTemplates(bot, config)

        println("Loaded ${commonTemplates.size} common templates and ${specificTemplates.size} specific templates for quest navigation")

        // Log dungeon targets configuration
        if (config.dungeonTargets.isNotEmpty()) {
            println("Dungeon Targets:")
            config.dungeonTargets.forEach { target ->
                println("  Zone ${target.zoneNumber}, Dungeon ${target.dungeonNumber} (${if (target.enabled) "Enabled" else "Disabled"})")
            }
        }

        println("Repeat Count: ${config.repeatCount}")

        // Step 1: Confirm quest availability and readiness
        println("Step 1: Confirming quest availability")
        if (!hasResourcesAvailable(bot, config)) {
            println("Quest resources not available or on cooldown. Aborting.")
            return false
        }
        println("Quest resources available and ready")

        // Step 2: Find and click on quest icon
        println("Step 2: Finding and clicking quest icon")
        if (!findAndClickSpecificTemplate(bot, config, "questicon.png", "quest icon")) {
            println("Failed to find and click quest icon. Aborting.")
            return false
        }
        println("Successfully clicked on quest icon")

        // Step 3: Verify map screen with zoneselector.png
        println("Step 3: Verifying map screen")
        // Wait a moment for the screen to load
        Thread.sleep(600)

        // Look for zoneselector.png to verify we're in the quest screen
        val zoneSelectorPath = "${config.specificTemplateDirectories.first()}/zonesselector.png"
        if (bot.findTemplate(zoneSelectorPath) == null) {
            println("Failed to verify quest map screen. Zoneselector not found. Aborting.")
            return false
        }
        println("Successfully verified quest map screen")

        // Process dungeon targets if available
        if (config.dungeonTargets.isNotEmpty()) {
            println("Processing specific dungeon targets...")
            for (target in config.dungeonTargets.filter { it.enabled }) {
                println("\nAttempting to run Zone ${target.zoneNumber}, Dungeon ${target.dungeonNumber}")

                // Step 4: Determine current zone
                println("Step 4: Determining current zone")
                // If we already have a last detected zone, mention it in the logs
                if (lastDetectedZone > 0) {
                    println("Last detected zone was: $lastDetectedZone, attempting to verify or update")
                }

                val currentZone = determineCurrentZone(bot, config)
                if (currentZone == -1) {
                    println("Failed to determine current zone. Aborting.")
                    return false
                }
                println("Current zone: $currentZone")

                // Step 5: Navigate to correct zone using arrow buttons
                println("Step 5: Navigating to zone ${target.zoneNumber}")

                // If multithreading is enabled, skip resetting to zone 1 and navigate directly
                if (useCoroutines) {
                    println("Multithreading enabled. Navigating directly from zone $currentZone to zone ${target.zoneNumber}")
                    if (!navigateToZone(bot, config, currentZone, target.zoneNumber)) {
                        println("Failed to navigate to zone ${target.zoneNumber}. Skipping this dungeon.")
                        continue
                    }
                } else {
                    // Without multithreading, always reset to zone 1 first for more reliable navigation
                    println("Multithreading disabled. Resetting to zone 1 for more reliable navigation.")
                    if (resetToZone1(bot, config)) {
                        println("Successfully reset to zone 1")
                        // After resetting, we need to navigate from zone 1
                        if (!navigateToZone(bot, config, 1, target.zoneNumber)) {
                            println("Failed to navigate to zone ${target.zoneNumber} from zone 1. Skipping this dungeon.")
                            continue
                        }
                    } else {
                        println("Failed to reset to zone 1. Will attempt direct navigation.")
                        if (!navigateToZone(bot, config, currentZone, target.zoneNumber)) {
                            println("Failed to navigate to zone ${target.zoneNumber}. Skipping this dungeon.")
                            continue
                        }
                    }
                }
                println("Successfully navigated to zone ${target.zoneNumber}")

                // Step 6: Select appropriate dungeon
                println("Step 6: Selecting dungeon ${target.dungeonNumber}")
                // First try with the new naming convention (zone1dungeon1.png)
                val dungeonFileName = "zone${target.zoneNumber}dungeon${target.dungeonNumber}.png"
                // Fallback to old naming convention (dungeon_1.png) if needed
                val fallbackDungeonFileName = "dungeon_${target.dungeonNumber}.png"

                if (findAndClickSpecificTemplate(bot, config, dungeonFileName, "dungeon ${target.dungeonNumber}")) {
                    println("Successfully selected dungeon ${target.dungeonNumber}")
                } else if (findAndClickSpecificTemplate(bot, config, fallbackDungeonFileName, "dungeon ${target.dungeonNumber} (fallback)")) {
                    println("Successfully selected dungeon ${target.dungeonNumber} using fallback template")
                } else {
                    println("Failed to find and click dungeon ${target.dungeonNumber}. Skipping this dungeon.")
                    continue
                }

                // Step 7: Select difficulty
                println("Step 7: Selecting difficulty")
                // Get the preferred difficulty from the target
                val preferredDifficulty = target.difficulty.lowercase()
                println("Preferred difficulty: $preferredDifficulty")

                // Try to find and click the preferred difficulty first, then fall back to others
                val difficultySelected = when (preferredDifficulty) {
                    "heroic" -> {
                        // Try heroic first, then fall back to hard, then normal
                        if (findAndClickSpecificTemplate(bot, config, "heroic.png", "heroic difficulty")) {
                            println("Successfully selected heroic difficulty (preferred)")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "hard.png", "hard difficulty")) {
                            println("Heroic not available, selected hard difficulty instead")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "normal.png", "normal difficulty")) {
                            println("Heroic and hard not available, selected normal difficulty instead")
                            true
                        } else {
                            println("Failed to select any difficulty")
                            false
                        }
                    }
                    "hard" -> {
                        // Try hard first, then fall back to heroic, then normal
                        if (findAndClickSpecificTemplate(bot, config, "hard.png", "hard difficulty")) {
                            println("Successfully selected hard difficulty (preferred)")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "heroic.png", "heroic difficulty")) {
                            println("Hard not available, selected heroic difficulty instead")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "normal.png", "normal difficulty")) {
                            println("Hard and heroic not available, selected normal difficulty instead")
                            true
                        } else {
                            println("Failed to select any difficulty")
                            false
                        }
                    }
                    "normal" -> {
                        // Try normal first, then fall back to hard, then heroic
                        if (findAndClickSpecificTemplate(bot, config, "normal.png", "normal difficulty")) {
                            println("Successfully selected normal difficulty (preferred)")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "hard.png", "hard difficulty")) {
                            println("Normal not available, selected hard difficulty instead")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "heroic.png", "heroic difficulty")) {
                            println("Normal and hard not available, selected heroic difficulty instead")
                            true
                        } else {
                            println("Failed to select any difficulty")
                            false
                        }
                    }
                    else -> {
                        // Unknown difficulty, try all options
                        println("Unknown difficulty: $preferredDifficulty, trying all options")
                        if (findAndClickSpecificTemplate(bot, config, "heroic.png", "heroic difficulty")) {
                            println("Selected heroic difficulty")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "hard.png", "hard difficulty")) {
                            println("Selected hard difficulty")
                            true
                        } else if (findAndClickSpecificTemplate(bot, config, "normal.png", "normal difficulty")) {
                            println("Selected normal difficulty")
                            true
                        } else {
                            println("Failed to select any difficulty")
                            false
                        }
                    }
                }

                // Skip this dungeon if no difficulty could be selected
                if (!difficultySelected) {
                    println("Failed to select any difficulty. Skipping this dungeon.")
                    continue
                }

                // Step 8: Click accept
                println("Step 8: Clicking accept button")
                if (!findAndClickSpecificTemplate(bot, config, "accept.png", "accept button")) {
                    println("Failed to find and click accept button. Skipping this dungeon.")
                    continue
                }
                println("Successfully clicked accept button")

                // Check for out of resources message
                val outOfResourcesPath = "${config.commonTemplateDirectories.first()}/outofresourcepopup.png"
                if (bot.findTemplate(outOfResourcesPath) != null) {
                    println("Out of resources message detected, stopping quest action")
                    return true
                }

                println("Successfully processed dungeon ${target.dungeonNumber} in zone ${target.zoneNumber}")
            }
        } else {
            println("No dungeon targets specified. Nothing to do.")
        }

        println("--- Quest Action Finished ---")
        return true
    }

    /**
     * Determines the current zone displayed on the quest map screen.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param lastKnownZone Optional parameter to prioritize checking zones near the last known zone.
     * @return The zone number (1-20) or -1 if unable to determine.
     */
    private fun determineCurrentZone(bot: Bot, config: ActionConfig, lastKnownZone: Int = -1): Int {
        // Use the class-level lastDetectedZone if available and no specific lastKnownZone was provided
        val zoneToCheck = if (lastKnownZone > 0) lastKnownZone else lastDetectedZone

        // If we have a last detected zone, first try to verify it directly
        if (zoneToCheck > 0) {
            println("Using last detected zone $zoneToCheck as a hint for faster detection")

            // Try to verify the last detected zone directly
            val zoneDetPath = "${(config as? QuestActionConfig)?.specificTemplateDirectories?.firstOrNull()}/zone${zoneToCheck}det.png"
            if (File(zoneDetPath).exists()) {
                val checkStartTime = System.currentTimeMillis()
                val result = bot.findTemplateDetailed(zoneDetPath)
                val checkDuration = System.currentTimeMillis() - checkStartTime

                if (result.location != null && result.confidence > 0.8) {
                    println("✅ Verified last detected zone $zoneToCheck directly (check took ${checkDuration}ms) with confidence: ${result.confidence}")
                    // Update the last detected zone
                    lastDetectedZone = zoneToCheck
                    return zoneToCheck
                } else {
                    println("❌ Last detected zone $zoneToCheck could not be verified directly (check took ${checkDuration}ms)")
                    // Continue with full detection
                }
            }
        }

        // Use coroutines if enabled
        val detectedZone = if (useCoroutines) {
            // Use runBlocking to call the suspending function from a non-suspending context
            runBlocking {
                determineCurrentZoneWithCoroutinesOldStyle(bot, config, zoneToCheck)
            }
        } else {
            determineCurrentZoneSequential(bot, config, zoneToCheck)
        }

        // Update the last detected zone if a valid zone was found
        if (detectedZone > 0) {
            lastDetectedZone = detectedZone
        }

        return detectedZone
    }

    /**
     * Sequential implementation of zone detection.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param lastKnownZone Optional parameter to prioritize checking zones near the last known zone.
     * @return The zone number (1-20) or -1 if unable to determine.
     */
    private fun determineCurrentZoneSequential(bot: Bot, config: ActionConfig, lastKnownZone: Int = -1): Int {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to determineCurrentZoneSequential.")
            return -1
        }

        println("Attempting to determine current zone (sequential mode)...")
        val startTime = System.currentTimeMillis()

        // Load all zone detection templates at once
        val zoneDetPaths = mutableListOf<Pair<Int, String>>()
        for (zoneNumber in 1..20) {
            val zoneDetPath = "${config.specificTemplateDirectories.first()}/zone${zoneNumber}det.png"
            if (File(zoneDetPath).exists()) {
                zoneDetPaths.add(Pair(zoneNumber, zoneDetPath))
            }
        }

        if (zoneDetPaths.isEmpty()) {
            println("No zone detection templates found")
            return -1
        }

        println("Loaded ${zoneDetPaths.size} zone detection templates in ${System.currentTimeMillis() - startTime}ms")

        // Sort templates to check the most likely zones first
        val sortedZoneDetPaths = if (lastKnownZone > 0) {
            // If we have a last known zone, prioritize checking that zone and adjacent zones first
            zoneDetPaths.sortedBy { (zoneNumber, _) ->
                Math.abs(zoneNumber - lastKnownZone) // Sort by distance from last known zone
            }
        } else {
            // Otherwise, just use the original order
            zoneDetPaths
        }

        println("Checking zones in order: ${sortedZoneDetPaths.map { it.first }}")

        // Check all templates in the optimized order
        for ((zoneNumber, zoneDetPath) in sortedZoneDetPaths) {
            val checkStartTime = System.currentTimeMillis()
            val result = bot.findTemplate(zoneDetPath)
            val checkDuration = System.currentTimeMillis() - checkStartTime

            if (result != null) {
                println("Detected zone $zoneNumber (check took ${checkDuration}ms)")
                println("Total zone detection time: ${System.currentTimeMillis() - startTime}ms")
                // No need to update lastDetectedZone here as it's already updated in the determineCurrentZone method
                return zoneNumber
            } else {
                println("Zone $zoneNumber not detected (check took ${checkDuration}ms)")
            }
        }

        println("Failed to determine current zone after ${System.currentTimeMillis() - startTime}ms")
        return -1
    }

    /**
     * Coroutine-based implementation of zone detection that checks templates in parallel.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param lastKnownZone Optional parameter to prioritize checking zones near the last known zone.
     * @return The zone number (1-20) or -1 if unable to determine.
     */
    private suspend fun determineCurrentZoneWithCoroutines(bot: Bot, config: ActionConfig, lastKnownZone: Int = -1): Int {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to determineCurrentZoneWithCoroutines.")
            return -1
        }

        println("Attempting to determine current zone (coroutine mode)...")
        val startTime = System.currentTimeMillis()

        // Load all zone detection templates at once
        val zoneDetPaths = mutableListOf<Pair<Int, String>>()
        for (zoneNumber in 1..20) {
            val zoneDetPath = "${config.specificTemplateDirectories.first()}/zone${zoneNumber}det.png"
            if (File(zoneDetPath).exists()) {
                zoneDetPaths.add(Pair(zoneNumber, zoneDetPath))
            }
        }

        if (zoneDetPaths.isEmpty()) {
            println("No zone detection templates found")
            return -1
        }

        println("Loaded ${zoneDetPaths.size} zone detection templates in ${System.currentTimeMillis() - startTime}ms")

        // Sort templates to check the most likely zones first
        val sortedZoneDetPaths = if (lastKnownZone > 0) {
            // If we have a last known zone, prioritize checking that zone and adjacent zones first
            zoneDetPaths.sortedBy { (zoneNumber, _) ->
                Math.abs(zoneNumber - lastKnownZone) // Sort by distance from last known zone
            }
        } else {
            // Otherwise, just use the original order
            zoneDetPaths
        }

        println("Checking zones in parallel, prioritizing: ${sortedZoneDetPaths.map { it.first }}")

        println("Starting parallel zone detection with ${sortedZoneDetPaths.size} templates using coroutines...")
        val parallelStartTime = System.currentTimeMillis()

        // Use withContext to run on the Default dispatcher (optimized for CPU-bound tasks)
        return withContext(Dispatchers.Default) {
            println("Using Dispatchers.Default for CPU-bound template matching")

            // Create a list of deferred results using async
            val deferredResults = sortedZoneDetPaths.map { (zoneNumber, path) ->
                async {
                    val checkStartTime = System.currentTimeMillis()
                    println("Coroutine for zone $zoneNumber started at ${checkStartTime - parallelStartTime}ms")

                    // Use findTemplateDetailed instead of findTemplate to get confidence score
                    val result = bot.findTemplateDetailed(path)
                    val checkDuration = System.currentTimeMillis() - checkStartTime

                    if (result.location != null) {
                        println("✅ Detected zone $zoneNumber (check took ${checkDuration}ms) with confidence: ${result.confidence}")
                        Triple(zoneNumber, true, result.confidence)
                    } else {
                        println("❌ Zone $zoneNumber not detected (check took ${checkDuration}ms)")
                        Triple(zoneNumber, false, 0.0)
                    }
                }
            }

            println("Launched ${deferredResults.size} coroutines for parallel template matching")

            // Wait for all results
            val awaitStartTime = System.currentTimeMillis()
            val results = deferredResults.awaitAll()
            val awaitDuration = System.currentTimeMillis() - awaitStartTime

            // Filter successful detections and find the one with highest confidence
            val successfulDetections = results.filter { it.second }
            val bestMatch = if (successfulDetections.isNotEmpty()) {
                successfulDetections.maxByOrNull { it.third }
            } else {
                null
            }

            val foundZone = bestMatch?.first ?: -1
            val confidence = bestMatch?.third ?: 0.0
            val totalDuration = System.currentTimeMillis() - startTime

            println("All coroutines completed in ${awaitDuration}ms")
            println("Total zone detection time with coroutines: ${totalDuration}ms")

            if (foundZone > 0) {
                println("Successfully detected zone $foundZone with confidence $confidence using parallel processing")
            } else {
                println("Failed to detect any zone using parallel processing")
            }

            foundZone
        }
    }

    /**
     * Coroutine-based implementation of zone detection that checks all zones at a specific scale
     * before moving to the next scale (old style).
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param lastKnownZone Optional parameter to prioritize checking zones near the last known zone.
     * @return The zone number (1-20) or -1 if unable to determine.
     */
    private suspend fun determineCurrentZoneWithCoroutinesOldStyle(bot: Bot, config: ActionConfig, lastKnownZone: Int = -1): Int {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to determineCurrentZoneWithCoroutinesOldStyle.")
            return -1
        }

        println("Attempting to determine current zone (coroutine old style mode)...")
        val startTime = System.currentTimeMillis()

        // Load all zone detection templates at once
        val zoneDetPaths = mutableListOf<Pair<Int, String>>()
        for (zoneNumber in 1..20) {
            val zoneDetPath = "${config.specificTemplateDirectories.first()}/zone${zoneNumber}det.png"
            if (File(zoneDetPath).exists()) {
                zoneDetPaths.add(Pair(zoneNumber, zoneDetPath))
            }
        }

        if (zoneDetPaths.isEmpty()) {
            println("No zone detection templates found")
            return -1
        }

        println("Loaded ${zoneDetPaths.size} zone detection templates in ${System.currentTimeMillis() - startTime}ms")

        // Sort templates to check the most likely zones first
        val sortedZoneDetPaths = if (lastKnownZone > 0) {
            // If we have a last known zone, prioritize checking that zone and adjacent zones first
            zoneDetPaths.sortedBy { (zoneNumber, _) ->
                Math.abs(zoneNumber - lastKnownZone) // Sort by distance from last known zone
            }
        } else {
            // Otherwise, just use the original order
            zoneDetPaths
        }

        println("Checking zones in old style mode, prioritizing: ${sortedZoneDetPaths.map { it.first }}")

        // Define the scales to check
        val minScale = 0.5
        val maxScale = 3.5
        val scaleStep = 0.1
        val scales = generateSequence(minScale) { it + scaleStep }
            .takeWhile { it <= maxScale }
            .toList()

        println("Starting old style zone detection with ${sortedZoneDetPaths.size} templates and ${scales.size} scales...")

        // Capture screen once for all template matching operations
        val screen = bot.captureScreen()

        // For each scale, check all zones at that scale
        for (scale in scales) {
            println("Checking all zones at scale: $scale")
            val scaleStartTime = System.currentTimeMillis()

            // Use withContext to run on the Default dispatcher (optimized for CPU-bound tasks)
            val result = withContext(Dispatchers.Default) {
                // Create a list of deferred results using async for all zones at this scale
                val deferredResults = sortedZoneDetPaths.map { (zoneNumber, path) ->
                    async {
                        val checkStartTime = System.currentTimeMillis()

                        try {
                            // Load the template
                            val template = org.opencv.imgcodecs.Imgcodecs.imread(path)

                            if (template.empty()) {
                                println("Could not load template image: $path")
                                return@async Triple(zoneNumber, false, 0.0)
                            }

                            // Resize the template according to the current scale
                            val scaledTemplate = org.opencv.core.Mat()
                            val newSize = org.opencv.core.Size(template.width() * scale, template.height() * scale)
                            org.opencv.imgproc.Imgproc.resize(template, scaledTemplate, newSize, 0.0, 0.0, org.opencv.imgproc.Imgproc.INTER_LINEAR)

                            // Skip if the scaled template is larger than the screen
                            if (scaledTemplate.width() > screen.width() || scaledTemplate.height() > screen.height()) {
                                return@async Triple(zoneNumber, false, 0.0)
                            }

                            // Perform template matching
                            val result = org.opencv.core.Mat()
                            org.opencv.imgproc.Imgproc.matchTemplate(screen, scaledTemplate, result, org.opencv.imgproc.Imgproc.TM_CCOEFF_NORMED)

                            // Get the best match
                            val mmr = org.opencv.core.Core.minMaxLoc(result)
                            val confidence = mmr.maxVal
                            val location = mmr.maxLoc

                            val checkDuration = System.currentTimeMillis() - checkStartTime

                            // Check if the confidence is high enough
                            if (confidence > 0.73) { // Using the same threshold as in Bot.findTemplateDetailed
                                println("✅ Detected zone $zoneNumber at scale $scale (check took ${checkDuration}ms) with confidence: $confidence")
                                Triple(zoneNumber, true, confidence)
                            } else {
                                println("❌ Zone $zoneNumber not detected at scale $scale (check took ${checkDuration}ms)")
                                Triple(zoneNumber, false, confidence)
                            }
                        } catch (e: Exception) {
                            println("Error checking zone $zoneNumber at scale $scale: ${e.message}")
                            Triple(zoneNumber, false, 0.0)
                        }
                    }
                }

                // Wait for all results at this scale
                val results = deferredResults.awaitAll()

                // Filter successful detections and find the one with highest confidence
                val successfulDetections = results.filter { it.second }
                successfulDetections.maxByOrNull { it.third }
            }

            val scaleDuration = System.currentTimeMillis() - scaleStartTime
            println("Completed checking all zones at scale $scale in ${scaleDuration}ms")

            // If we found a match at this scale, return it
            if (result != null) {
                val (zoneNumber, _, confidence) = result
                val totalDuration = System.currentTimeMillis() - startTime
                println("Successfully detected zone $zoneNumber at scale $scale with confidence $confidence")
                println("Total zone detection time with old style coroutines: ${totalDuration}ms")
                return zoneNumber
            }
        }

        // If we get here, we didn't find any zone at any scale
        val totalDuration = System.currentTimeMillis() - startTime
        println("Failed to detect any zone after checking all scales")
        println("Total zone detection time with old style coroutines: ${totalDuration}ms")
        return -1
    }

    /**
     * Resets to zone 1 by clicking the left arrow multiple times.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return True if successfully reset to zone 1, false otherwise.
     */
    private fun resetToZone1(bot: Bot, config: ActionConfig): Boolean {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to resetToZone1.")
            return false
        }

        println("Resetting to zone 1...")

        // Find the left arrow template once
        val leftArrowTemplate = "${config.commonTemplateDirectories.first()}/arrowleft.png"
        val arrowLocation = bot.findTemplate(leftArrowTemplate)

        if (arrowLocation == null) {
            println("Failed to find left arrow template. Cannot reset to zone 1.")
            return false
        }

        // Click the left arrow multiple times to ensure we reach zone 1
        val maxClicks = 20 // This should be enough to reach zone 1 from any zone
        println("Found left arrow. Clicking it $maxClicks times to reach zone 1...")

        for (i in 1..maxClicks) {
            bot.click(arrowLocation.x.toInt(), arrowLocation.y.toInt())
            // Short delay between clicks to ensure they register
            Thread.sleep(300)
        }

        // Wait a moment for the screen to fully update after all clicks
        Thread.sleep(1000)

        // Verify we're in zone 1
        val zone1DetPath = "${config.specificTemplateDirectories.first()}/zone1det.png"
        if (File(zone1DetPath).exists() && bot.findTemplate(zone1DetPath) != null) {
            println("Successfully reset to zone 1")
            return true
        }

        // If verification failed, try to determine current zone
        // Use 1 as the hint since we're expecting to be in zone 1
        val currentZone = determineCurrentZone(bot, config, 1)
        if (currentZone == 1) {
            println("Successfully reset to zone 1 (verified by zone detection)")
            // Update lastDetectedZone to 1
            lastDetectedZone = 1
            return true
        } else if (currentZone != -1) {
            println("Failed to reset to zone 1. Current zone is $currentZone.")
            // Update lastDetectedZone with the current detected zone
            lastDetectedZone = currentZone
            return false
        } else {
            println("Failed to reset to zone 1. Could not determine current zone.")
            return false
        }
    }

    /**
     * Navigates from the current zone to the target zone using arrow buttons.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param currentZone The current zone number.
     * @param targetZone The target zone number.
     * @return True if navigation was successful, false otherwise.
     */
    private fun navigateToZone(bot: Bot, config: ActionConfig, currentZone: Int, targetZone: Int): Boolean {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to navigateToZone.")
            return false
        }

        // If already in the correct zone, no navigation needed
        if (currentZone == targetZone) {
            println("Already in zone $targetZone, no navigation needed")
            return true
        }

        println("Navigating from zone $currentZone to zone $targetZone")

        // Determine which arrow to use and how many times to click it
        var arrowTemplate: String
        var clickCount: Int

        if (targetZone > currentZone) {
            // Need to go right
            arrowTemplate = "${config.commonTemplateDirectories.first()}/arrowright.png"
            clickCount = targetZone - currentZone
            println("Need to click right arrow $clickCount times")
        } else {
            // Need to go left
            arrowTemplate = "${config.commonTemplateDirectories.first()}/arrowleft.png"
            clickCount = currentZone - targetZone
            println("Need to click left arrow $clickCount times")
        }

        // Maximum number of attempts to navigate to the correct zone
        val maxAttempts = 2
        var attempts = 0

        while (attempts < maxAttempts) {
            attempts++

            // Find the arrow template once
            val arrowLocation = bot.findTemplate(arrowTemplate)
            if (arrowLocation == null) {
                println("Failed to find arrow template (Attempt $attempts/$maxAttempts)")
                if (attempts >= maxAttempts) {
                    println("Maximum navigation attempts reached. Placing action on cooldown.")
                    return false
                }
                // Try again
                Thread.sleep(500)
                continue
            }

            // Click the arrow the required number of times without checking zone after each click
            println("Found arrow. Clicking it $clickCount times...")
            for (i in 1..clickCount) {
                bot.click(arrowLocation.x.toInt(), arrowLocation.y.toInt())
                // Short delay between clicks to ensure they register
                Thread.sleep(300)
            }

            // Wait a moment for the screen to fully update after all clicks
            Thread.sleep(1000)

            // Verify we're in the target zone
            val targetZoneDetPath = "${config.specificTemplateDirectories.first()}/zone${targetZone}det.png"
            if (File(targetZoneDetPath).exists() && bot.findTemplate(targetZoneDetPath) != null) {
                println("Successfully navigated to zone $targetZone")
                return true
            }

            // If verification failed, try to determine current zone
            // Use the current zone as a hint for faster detection
            val currentDetectedZone = determineCurrentZone(bot, config, currentZone)
            if (currentDetectedZone != -1) {
                println("Expected to be in zone $targetZone but detected zone $currentDetectedZone (Attempt $attempts/$maxAttempts)")

                // Update lastDetectedZone with the current detected zone
                lastDetectedZone = currentDetectedZone

                if (attempts >= maxAttempts) {
                    // If this was our last attempt, warn the user and place action on cooldown
                    println("Maximum navigation attempts reached. Placing action on cooldown.")
                    return false
                }

                // Recalculate clicks needed based on current detected zone
                if (targetZone > currentDetectedZone) {
                    // Need to go right
                    arrowTemplate = "${config.commonTemplateDirectories.first()}/arrowright.png"
                    clickCount = targetZone - currentDetectedZone
                    println("Retrying: Need to click right arrow $clickCount more times")
                } else if (targetZone < currentDetectedZone) {
                    // Need to go left
                    arrowTemplate = "${config.commonTemplateDirectories.first()}/arrowleft.png"
                    clickCount = currentDetectedZone - targetZone
                    println("Retrying: Need to click left arrow $clickCount more times")
                } else {
                    // We're actually in the right zone but detection failed earlier
                    println("Actually in correct zone $targetZone. Continuing.")
                    return true
                }
            } else {
                println("Failed to determine current zone after navigation attempt $attempts/$maxAttempts")
                if (attempts >= maxAttempts) {
                    println("Maximum navigation attempts reached. Placing action on cooldown.")
                    return false
                }
            }
        }

        // If we've exhausted all attempts
        println("Failed to navigate to zone $targetZone after $maxAttempts attempts. Placing action on cooldown.")
        return false
    }

    /**
     * Checks if the action has resources available to execute.
     * In a real implementation, this would check for available energy, tickets, etc.
     * For this placeholder implementation, we'll simulate resource depletion after a few checks.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return True if resources are available, false if depleted.
     */
    override fun hasResourcesAvailable(bot: Bot, config: ActionConfig): Boolean {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to QuestAction.hasResourcesAvailable.")
            return false
        }

        // Increment the resource check count
        resourceCheckCount++

        // For repeatCount = 0, simulate resource depletion after 3 checks
        if (config.repeatCount == 0 && resourceCheckCount >= 3) {
            println("QuestAction: Resources depleted after $resourceCheckCount checks.")
            // Reset the counter for next time
            resourceCheckCount = 0
            return false
        }

        println("QuestAction: Resources available. Check count: $resourceCheckCount")
        return true
    }
}
