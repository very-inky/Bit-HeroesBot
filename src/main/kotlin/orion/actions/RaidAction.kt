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

            println("\nTarget ${i + 1}: ${target.raidName} (${target.difficulty})")

            // Step 2: Raid Selection - Create a target identifier
            val targetRaidId = target.raidName.lowercase().replace(" ", "_")
            println("Step 2: Raid Selection - Target: $targetRaidId")

            // Step 3: Find and verify the raid template
            println("Step 3: Raid Verification")
            // Look for a specific raid template file like "raid_name.png"
            val raidFileName = "${targetRaidId}.png"

            // First check if the template exists
            if (!File("${config.specificTemplateDirectories.first()}/${raidFileName}").exists() &&
                !File("${config.commonTemplateDirectories.first()}/${raidFileName}").exists()) {
                println("Could not find raid template file for ${target.raidName}, skipping this raid")
                continue
            }

            println("Found raid template file: ${raidFileName}")

            // Step 4: Click on the raid to select it
            println("Step 4: Raid Selection")
            if (!findAndClickSpecificTemplate(bot, config, raidFileName, "raid ${target.raidName} button", delayAfterClick = 1500)) {
                println("Failed to find and click raid ${target.raidName}, skipping this raid")
                continue
            }
            println("Successfully selected raid: ${target.raidName}")

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

            // Add additional delay to ensure UI has time to show resource popup if needed
            println("Waiting for UI to update after clicking start raid button...")
            Thread.sleep(2000)

            // Check for out of resources message
            // Look for a specific out of resources template file like "out_of_resources.png"
            val outOfResourcesPath = "${config.specificTemplateDirectories.first()}/out_of_resources.png"
            if (bot.findTemplate(outOfResourcesPath) != null) {
                println("Out of resources message detected, stopping raid action")
                return true
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
