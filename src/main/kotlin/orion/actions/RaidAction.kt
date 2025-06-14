package orion.actions // Keep actions in a sub-package

import orion.Bot
import orion.GameAction
import orion.ActionConfig
import orion.RaidActionConfig
import orion.BaseGameAction
import java.io.File

class RaidAction : BaseGameAction() {
    // Track the number of consecutive resource checks
    private var resourceCheckCount = 0

    override fun execute(bot: Bot, config: ActionConfig): Boolean {
        if (config !is RaidActionConfig) {
            println("Error: Incorrect config type passed to RaidAction.")
            return false
        }

        println("--- Executing Raid Action ---")

        // Load only common templates for navigation
        val (commonTemplates, _) = loadTemplates(bot, config)

        println("Loaded ${commonTemplates.size} common templates for raid navigation")
        println("Run Count: ${config.runCount}")

        // Step 1: Interface Validation & Navigation - Find and click on raid navigation button
        println("Step 1: Interface Validation & Navigation")
        if (!findAndClickSpecificTemplate(bot, config, "raidicon.png", "raid navigation button", delayAfterClick = 1500)) {
            println("Failed to navigate to raid area. Aborting.")
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

            // Step 2: Raid Selection - Create a target identifier
            val targetRaidId = when {
                target.raidName.isNotBlank() -> target.raidName.lowercase().replace(" ", "_")
                target.raidNumber != null -> "raid${target.raidNumber}"
                target.tierNumber != null -> "tier${target.tierNumber}"
                else -> ""
            }
            println("Step 2: Raid Selection - Target: $targetRaidId")

            // Step 3: Find and verify the raid template
            println("Step 3: Raid Verification")

            // Try different possible template filenames
            val possibleTemplateNames = mutableListOf<String>()

            // Add the primary template name based on the identifier
            possibleTemplateNames.add("${targetRaidId}.png")

            // Add alternative template names based on raid/tier conversion
            if (target.raidNumber != null) {
                val tierNumber = target.getEffectiveTierNumber()
                if (tierNumber != null) {
                    possibleTemplateNames.add("tier${tierNumber}.png")
                }
            } else if (target.tierNumber != null) {
                val raidNumber = target.getEffectiveRaidNumber()
                if (raidNumber != null) {
                    possibleTemplateNames.add("raid${raidNumber}.png")
                }
            }

            // Try each possible template
            var templateFound = false
            var raidFileName = ""

            for (templateName in possibleTemplateNames) {
                if (File("${config.specificTemplateDirectories.first()}/${templateName}").exists() ||
                    File("${config.commonTemplateDirectories.first()}/${templateName}").exists()) {
                    templateFound = true
                    raidFileName = templateName
                    break
                }
            }

            if (!templateFound) {
                println("Could not find raid template file for $raidIdentifier, skipping this raid")
                continue
            }

            println("Found raid template file: ${raidFileName}")

            // Step 4: Click on the raid to select it
            println("Step 4: Raid Selection")
            if (!findAndClickSpecificTemplate(bot, config, raidFileName, "raid $raidIdentifier button", delayAfterClick = 1500)) {
                println("Failed to find and click raid $raidIdentifier, skipping this raid")
                continue
            }
            println("Successfully selected raid: $raidIdentifier")

            // Step 5: Difficulty Selection - Find and click on the difficulty button
            println("Step 5: Difficulty Selection")
            val difficultyId = target.difficulty.lowercase().replace(" ", "_")
            // Look for a specific difficulty template file like "heroic.png"
            val difficultyFileName = "${difficultyId}.png"
            if (findAndClickSpecificTemplate(bot, config, difficultyFileName, "${target.difficulty} difficulty button", delayAfterClick = 1500)) {
                println("Successfully selected ${target.difficulty} difficulty")
            } else {
                println("Failed to select ${target.difficulty} difficulty, continuing with default")
            }

            // Step 6: Team Composition Check (Optional)
            println("Step 6: Team Composition Check")
            // Look for a specific team template file like "add_team.png"
            if (findAndClickSpecificTemplate(bot, config, "add_team.png", "add team button", delayAfterClick = 1500)) {
                println("Successfully clicked add team button")
            } else {
                println("No add team button found or failed to click, continuing")
            }

            // Step 7: Raid Initiation & Resource Check
            println("Step 7: Raid Initiation")
            // Look for a specific start raid template file like "start_raid.png"
            if (findAndClickSpecificTemplate(bot, config, "start_raid.png", "start raid button", delayAfterClick = 2000)) {
                println("Successfully started raid")
            } else {
                // Try generic "start" template if raid-specific one isn't found
                if (!findAndClickSpecificTemplate(bot, config, "start.png", "generic start button", delayAfterClick = 2000)) {
                    println("Failed to find and click start raid button, skipping this raid")
                    continue
                }
                println("Successfully started raid using generic start button")
            }

            // Check for out of resources message after clicking start raid button
            if (checkForOutOfResources(bot, 2000, "Out of resources message detected, stopping raid action")) {
                return false // Return false to indicate failure due to resource depletion
            }

            // Step 8: Post-Start Actions (Optional)
            println("Step 8: Post-Start Actions")
            // Look for a specific autopilot template file like "autopilot.png"
            if (findAndClickSpecificTemplate(bot, config, "autopilot.png", "autopilot button", delayAfterClick = 1500)) {
                println("Successfully enabled autopilot")
            } else {
                println("No autopilot button found or failed to click, continuing")
            }

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
