package orion.actions // Keep actions in a sub-package

import orion.Bot
import orion.GameAction
import orion.ActionConfig
import orion.RaidActionConfig
import orion.BaseGameAction
import java.io.File
import orion.utils.PathUtils
import java.awt.event.KeyEvent

class RaidAction : BaseGameAction() {
    // Track the number of consecutive resource checks
    private var resourceCheckCount = 0

    // Store the last detected raid to optimize future raid detection
    private var lastDetectedRaid = -1

    // Track which raids have already had their in-progress dialogues handled
    private val handledInProgressDialogueRaids = mutableSetOf<Int>()

    override fun execute(bot: Bot, config: ActionConfig): Boolean {
        if (config !is RaidActionConfig) {
            println("Error: Incorrect config type passed to RaidAction.")
            return false
        }

        println("--- Executing Raid Action ---")

        // Load templates for navigation
        val (commonTemplates, specificTemplates) = loadTemplates(bot, config)

        println("Loaded ${commonTemplates.size} common templates and ${specificTemplates.size} specific templates for raid navigation")
        println("Run Count: ${config.runCount}")

        // Step 1: Interface Validation & Navigation - Find and click on raid navigation button
        println("Step 1: Interface Validation & Navigation")
        if (!findAndClickSpecificTemplate(bot, config, "raidicon.png", "raid navigation button", delayAfterClick = 1500)) {
            println("Failed to navigate to raid. Aborting.")
            return false
        }
        println("Successfully navigated to raid interface")

        // Process raid targets using a regular for loop to support continue statements
        for (i in config.raidTargets.indices) {
            val target = config.raidTargets[i]
            if (!target.enabled) continue

            // Determine the raid identifier based on available information
            val raidIdentifier = when {
                target.raidName.isNotBlank() -> target.raidName
                target.raidNumber != null -> "Raid${target.raidNumber}"
                target.tierNumber != null -> "Tier${target.tierNumber}"
                else -> {
                    println("Target ${i + 1}: No raid name, raid number, or tier number specified. Skipping.")
                    continue
                }
            }

            println("\nTarget ${i + 1}: $raidIdentifier (${target.difficulty})")

            // Step 2: Determine target raid number
            val targetRaidNumber = target.getEffectiveRaidNumber()
            if (targetRaidNumber == null) {
                println("Could not determine raid number for $raidIdentifier, skipping this raid")
                continue
            }
            println("Step 2: Raid Selection - Target Raid Number: $targetRaidNumber")

            // Step 3: Determine current raid on screen
            println("Step 3: Determining current raid on screen")
            val currentRaid = determineCurrentRaid(bot, config)
            if (currentRaid == -1) {
                println("Failed to determine current raid on screen. Skipping this raid.")
                continue
            }
            println("Current raid on screen: $currentRaid")

            // Step 4: Navigate to target raid if needed
            if (currentRaid != targetRaidNumber) {
                println("Step 4: Navigating to target raid")
                if (!navigateToRaid(bot, config, currentRaid, targetRaidNumber)) {
                    println("Failed to navigate to raid $targetRaidNumber. Skipping this raid.")
                    continue
                }
                println("Successfully navigated to raid $targetRaidNumber")
            } else {
                println("Step 4: Already on target raid $targetRaidNumber, no navigation needed")
            }

            // Step 5: Raid Initiation & Resource Check
            println("Step 5: Raid Initiation")
            // Look for raidsummon.png to start the raid
            if (findAndClickSpecificTemplate(bot, config, "raidsummon.png", "raid summon button", delayAfterClick = 2000)) {
                println("Found and clicked raid summon button")
            } else {
                println("Failed to find and click raid summon button, skipping this raid")
                continue
            }

            // Step 5.5: Handle in-progress dialogue if present
            println("Step 5.5: Handling In-Progress Dialogue")
            if (!handleInProgressDialogue(bot, config, targetRaidNumber)) {
                println("Failed to handle in-progress dialogue, but continuing anyway")
                // We continue anyway since this is not a critical failure
            }

            // Step 6: Difficulty Selection - Find and click on the difficulty button
            println("Step 6: Difficulty Selection")
            val difficultyId = target.difficulty.lowercase().replace(" ", "_")
            // Look for a specific difficulty template file like "heroic.png"
            val difficultyFileName = "${difficultyId}.png"
            if (findAndClickSpecificTemplate(bot, config, difficultyFileName, "${target.difficulty} difficulty button", delayAfterClick = 1500)) {
                println("Successfully selected ${target.difficulty} difficulty")
            } else {
                println("Failed to select ${target.difficulty} difficulty, continuing with default")
            }

            // Step 7: Team Composition Check (Optional)
            println("Step 7: Team Composition Check")
            // Look for add.png to detect if team needs to be added, but don't click it
            val addPath = "${config.commonTemplateDirectories.first()}/add.png"
            if (File(addPath).exists() && bot.findTemplate(addPath) != null) {
                println("Detected add.png - team needs to be added")
                // If AutoTeam is configured, click autoteam.png
                if (findAndClickSpecificTemplate(bot, config, "autoteam.png", "auto team button", delayAfterClick = 1500)) {
                    println("Successfully clicked auto team button")
                } else {
                    println("No auto team button found or failed to click, continuing")
                }
            } else {
                println("No add button detected, continuing")
            }

            // Step 8: Click accept button
            println("Step 8: Clicking accept button")
            if (findAndClickSpecificTemplate(bot, config, "accept.png", "accept button", delayAfterClick = 2000)) {
                println("Successfully clicked accept button")
            } else {
                println("No accept button found or failed to click, continuing")
            }

            // Check for out of resources message after clicking start raid button
            if (checkForOutOfResources(bot, 2000, "Out of resources message detected, stopping raid action")) {
                return false // Return false to indicate failure due to resource depletion
            }

            // Step 9: Post-Start Actions
            println("Step 9: Post-Start Actions")
            // Autopilot is handled by ActionManager, no need to handle it here
            println("Autopilot will be handled by ActionManager if configured")

            println("Successfully processed raid: ${target.raidName} with difficulty: ${target.difficulty}")

            // Check for rerun button and handle rerun functionality
            println("Checking for rerun button...")
            if (findAndClickSpecificTemplate(bot, config, "rerun.png", "rerun button", delayAfterClick = 2000)) {
                println("Found and clicked rerun button")

                // Check for out of resources message after clicking rerun button
                if (checkForOutOfResources(bot, 2000, "Out of resources message detected after clicking rerun, stopping raid action")) {
                    return false // Return false to indicate failure due to resource depletion
                }

                println("Resources available for rerun, continuing...")
            } else {
                println("No rerun button found or failed to click, continuing with next raid")
            }
        }

        // Check if no raid targets were specified
        if (config.raidTargets.isEmpty()) {
            println("No raid targets specified. Nothing to do.")
        }

        println("--- Raid Action Finished ---")
        return true
    }

    /**
     * Determines the current raid displayed on the raid screen.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return The raid number (1-18) or -1 if unable to determine.
     */
    private fun determineCurrentRaid(bot: Bot, config: ActionConfig): Int {
        if (config !is RaidActionConfig) {
            println("Error: Incorrect config type passed to determineCurrentRaid.")
            return -1
        }

        // If we have a last detected raid, first try to verify it directly
        if (lastDetectedRaid > 0) {
            println("Using last detected raid $lastDetectedRaid as a hint for faster detection")

            // Try to verify the last detected raid directly
            val raidTemplatePath = PathUtils.buildPath(config.specificTemplateDirectories.first(), "raid${lastDetectedRaid}.png")
            if (File(raidTemplatePath).exists() && bot.findTemplate(raidTemplatePath) != null) {
                println("✅ Verified last detected raid $lastDetectedRaid directly")
                return lastDetectedRaid
            } else {
                println("❌ Last detected raid $lastDetectedRaid could not be verified directly")
            }
        }

        // Check all possible raid templates (raid1.png through raid18.png)
        println("Checking all possible raid templates...")
        for (raidNumber in 1..18) {
            val raidTemplatePath = PathUtils.buildPath(config.specificTemplateDirectories.first(), "raid${raidNumber}.png")
            if (File(raidTemplatePath).exists() && bot.findTemplate(raidTemplatePath) != null) {
                println("✅ Detected raid $raidNumber on screen")
                // Update the last detected raid
                lastDetectedRaid = raidNumber
                return raidNumber
            }
        }

        println("❌ Failed to determine current raid on screen")
        return -1
    }

    /**
     * Navigates from the current raid to the target raid using arrow buttons.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param currentRaid The current raid number.
     * @param targetRaid The target raid number.
     * @return True if navigation was successful, false otherwise.
     */
    private fun navigateToRaid(bot: Bot, config: ActionConfig, currentRaid: Int, targetRaid: Int): Boolean {
        if (config !is RaidActionConfig) {
            println("Error: Incorrect config type passed to navigateToRaid.")
            return false
        }

        // If already on the correct raid, no navigation needed
        if (currentRaid == targetRaid) {
            println("Already on raid $targetRaid, no navigation needed")
            return true
        }

        println("Navigating from raid $currentRaid to raid $targetRaid")

        // Determine which arrow to use and how many times to click it
        var arrowTemplate: String
        var clickCount: Int

        if (targetRaid > currentRaid) {
            // Need to go right
            arrowTemplate = PathUtils.buildPath(config.specificTemplateDirectories.first(), "arrowright.png")
            clickCount = targetRaid - currentRaid
            println("Need to click right arrow $clickCount times")
        } else {
            // Need to go left
            arrowTemplate = PathUtils.buildPath(config.specificTemplateDirectories.first(), "arrowleft.png")
            clickCount = currentRaid - targetRaid
            println("Need to click left arrow $clickCount times")
        }

        // Maximum number of attempts to navigate to the correct raid
        val maxAttempts = 2
        var attempts = 0

        while (attempts < maxAttempts) {
            attempts++

            // Find the arrow template once
            val arrowLocation = bot.findTemplate(arrowTemplate)
            if (arrowLocation == null) {
                println("Failed to find arrow template (Attempt $attempts/$maxAttempts)")
                if (attempts >= maxAttempts) {
                    println("Maximum navigation attempts reached.")
                    return false
                }
                // Try again
                Thread.sleep(500)
                continue
            }

            // Click the arrow the required number of times without checking raid after each click
            println("Found arrow. Clicking it $clickCount times...")
            for (i in 1..clickCount) {
                bot.click(arrowLocation.x.toInt(), arrowLocation.y.toInt())
                // Longer delay after each click to allow UI to update
                Thread.sleep(1000)
            }

            // Wait a moment for the screen to fully update after all clicks
            Thread.sleep(1000)

            // Verify we're on the target raid
            val targetRaidPath = PathUtils.buildPath(config.specificTemplateDirectories.first(), "raid${targetRaid}.png")
            if (File(targetRaidPath).exists() && bot.findTemplate(targetRaidPath) != null) {
                println("Successfully navigated to raid $targetRaid")
                return true
            }

            // If verification failed, try to determine current raid
            val currentDetectedRaid = determineCurrentRaid(bot, config)
            if (currentDetectedRaid != -1) {
                println("Expected to be on raid $targetRaid but detected raid $currentDetectedRaid (Attempt $attempts/$maxAttempts)")

                // Update lastDetectedRaid with the current detected raid
                lastDetectedRaid = currentDetectedRaid

                if (attempts >= maxAttempts) {
                    println("Maximum navigation attempts reached.")
                    return false
                }

                // Recalculate clicks needed based on current detected raid
                if (targetRaid > currentDetectedRaid) {
                    // Need to go right
                    arrowTemplate = PathUtils.buildPath(config.specificTemplateDirectories.first(), "arrowright.png")
                    clickCount = targetRaid - currentDetectedRaid
                    println("Retrying: Need to click right arrow $clickCount more times")
                } else if (targetRaid < currentDetectedRaid) {
                    // Need to go left
                    arrowTemplate = PathUtils.buildPath(config.specificTemplateDirectories.first(), "arrowleft.png")
                    clickCount = currentDetectedRaid - targetRaid
                    println("Retrying: Need to click left arrow $clickCount more times")
                } else {
                    // We're actually on the right raid but detection failed earlier
                    println("Actually on correct raid $targetRaid. Continuing.")
                    return true
                }
            } else {
                println("Failed to determine current raid after navigation attempt $attempts/$maxAttempts")
                if (attempts >= maxAttempts) {
                    println("Maximum navigation attempts reached.")
                    return false
                }
            }
        }

        // If we've exhausted all attempts
        println("Failed to navigate to raid $targetRaid after $maxAttempts attempts.")
        return false
    }

    /**
     * Handles the in-progress dialogue that may appear after hitting the summon button.
     * This dialogue appears during setup if you haven't run a raid before or your browser cookies are cleared.
     * Once handled for a specific raid, it doesn't need to be handled again for that raid.
     *
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param raidNumber The current raid number being processed.
     * @return True if the dialogue was handled successfully or not present, false if handling failed.
     */
    private fun handleInProgressDialogue(bot: Bot, config: ActionConfig, raidNumber: Int): Boolean {
        if (config !is RaidActionConfig) {
            println("Error: Incorrect config type passed to handleInProgressDialogue.")
            return false
        }

        // If we've already handled this raid's dialogue, skip the check
        if (handledInProgressDialogueRaids.contains(raidNumber)) {
            println("In-progress dialogue already handled for raid $raidNumber, skipping check")
            return true
        }

        println("Checking for in-progress dialogue...")

        // Path to the in-progress dialogue template
        val dialogueTemplatePath = PathUtils.buildPath(config.commonTemplateDirectories.first(), "handleinprogressdialogue.png")

        // Check if the template file exists
        if (!File(dialogueTemplatePath).exists()) {
            println("Warning: In-progress dialogue template not found at $dialogueTemplatePath")
            // Mark as handled since we can't check for it
            handledInProgressDialogueRaids.add(raidNumber)
            return true
        }

        // Function to check for the dialogue
        fun checkForDialogue(): Boolean {
            return bot.findTemplate(dialogueTemplatePath) != null
        }

        // Initial check for the dialogue
        var dialogueFound = checkForDialogue()

        // If dialogue is found, handle it
        if (dialogueFound) {
            println("In-progress dialogue detected, handling...")

            // Keep track of how many times we've sent space
            var spaceKeyPresses = 0
            val maxSpaceKeyPresses = 10 // Limit to prevent infinite loop

            while (dialogueFound && spaceKeyPresses < maxSpaceKeyPresses) {
                // Send space key to dismiss the dialogue
                println("Sending SPACE key to dismiss dialogue")
                bot.pressKey(KeyEvent.VK_SPACE)
                spaceKeyPresses++

                // Wait for UI to update
                Thread.sleep(900)

                // First check
                dialogueFound = checkForDialogue()

                if (!dialogueFound) {
                    // Wait a bit more and check again to confirm
                    Thread.sleep(900)
                    dialogueFound = checkForDialogue()

                    if (!dialogueFound) {
                        // Dialogue is gone after two consecutive checks
                        println("In-progress dialogue dismissed after $spaceKeyPresses SPACE key presses")
                        // Mark this raid as handled
                        handledInProgressDialogueRaids.add(raidNumber)
                        return true
                    } else {
                        // Dialogue reappeared, continue the loop
                        println("Dialogue reappeared after second check, continuing...")
                    }
                }
            }

            // If we've reached the maximum number of space key presses and the dialogue is still there
            if (spaceKeyPresses >= maxSpaceKeyPresses) {
                println("Warning: Reached maximum number of SPACE key presses ($maxSpaceKeyPresses) but dialogue is still present")
                // We'll still mark it as handled to prevent infinite retries
                handledInProgressDialogueRaids.add(raidNumber)
                return false
            }
        } else {
            // Double-check to make sure the dialogue is really not there
            Thread.sleep(900)
            dialogueFound = checkForDialogue()

            if (!dialogueFound) {
                // Dialogue is not present after two consecutive checks
                println("No in-progress dialogue detected")
                // Mark this raid as handled
                handledInProgressDialogueRaids.add(raidNumber)
                return true
            } else {
                // Dialogue appeared on second check, handle it
                println("In-progress dialogue detected on second check, handling...")
                // Call this method again to handle the dialogue
                return handleInProgressDialogue(bot, config, raidNumber)
            }
        }

        // If we get here, something unexpected happened
        println("Warning: Unexpected state in handleInProgressDialogue")
        return false
    }

    /**
     * Checks if the action has resources available to execute.
     * In a real implementation, this would check for available raid tickets, energy, etc.
     * For this placeholder implementation, we'll simulate resource depletion after a few checks.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return True if resources are available, false if depleted.
     */
    override fun hasResourcesAvailable(bot: Bot, config: ActionConfig): Boolean {
        if (config !is RaidActionConfig) {
            println("Error: Incorrect config type passed to RaidAction.hasResourcesAvailable.")
            return false
        }

        // Increment the resource check count
        resourceCheckCount++

        // For runCount = 0, simulate resource depletion after 3 checks
        if (config.runCount == 0 && resourceCheckCount >= 3) {
            println("RaidAction: Resources depleted after $resourceCheckCount checks.")
            // Reset the counter for next time
            resourceCheckCount = 0
            return false
        }

        println("RaidAction: Resources available. Check count: $resourceCheckCount")
        return true
    }
}
