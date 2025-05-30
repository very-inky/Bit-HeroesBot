package orion

import orion.actions.*
import java.time.Instant
import java.time.temporal.ChronoUnit
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.delay
import java.io.File

// Imports for Bot, BotConfig, GameAction, ActionConfig from the 'orion' package are not needed
// if ActionManager is correctly declared in 'package orion'.

class ActionManager(private val bot: Bot, private val config: BotConfig, private val configManager: ConfigManager? = null) {
    // Map to track cooldowns for actions
    private val actionCooldowns = mutableMapOf<String, Instant>()
    // Map to track run counts for actions
    private val actionRunCounts = mutableMapOf<String, Int>()
    // Flag to track if we're in a rerun state
    private var isRerunning = false

    fun runActionSequence() {
        // Get character name from ConfigManager if available, otherwise use config name
        val characterName = if (configManager != null) {
            configManager.getCharacter(config.characterId)?.characterName ?: config.configName
        } else {
            config.configName
        }

        println("ActionManager: Starting action sequence for $characterName using config '${config.configName}' (ID: ${config.configId}).")
        println("Action sequence: ${config.actionSequence.joinToString(" -> ")}")

        // Initialize run counts for all actions
        for (actionName in config.actionSequence) {
            actionRunCounts[actionName] = 0
        }

        // Continue running actions until all are completed or on cooldown
        var allActionsCompleted = false
        while (!allActionsCompleted) {
            allActionsCompleted = true // Assume all actions are completed until proven otherwise

            for (actionName in config.actionSequence) {
                // Check if this action can be executed
                val canExecute = canExecuteAction(actionName)

                if (!canExecute.first) {
                    // Action cannot be executed, print the reason
                    println(canExecute.second)
                    continue
                }

                // At this point, at least one action is still eligible to run
                allActionsCompleted = false

                // Get the action config
                val actionConfig = config.actionConfigs[actionName]!!

                println("\nAttempting to execute action: $actionName")
                val actionHandler: GameAction? = when (actionName) {
                    "Quest" -> QuestAction()
                    "Raid" -> RaidAction()
                    // "PVP" -> PvpAction() // Placeholder for when PvpAction.kt is created
                    // "GVG" -> GvgAction()
                    // "WorldBoss" -> WorldBossAction()
                    // "Trials" -> TrialsAction()
                    // "Expedition" -> ExpeditionAction()
                    // "Gauntlet" -> GauntletAction()
                    else -> {
                        println("Warning: Unknown action type '$actionName' in sequence. No handler defined. Skipping.")
                        null
                    }
                }

                if (actionHandler != null) {
                    executeAction(actionName, actionHandler, actionConfig)
                }
            }

            // If all actions are completed or on cooldown, break the loop
            if (allActionsCompleted) {
                println("All actions have been completed or are on cooldown.")
                break
            }
        }

        println("\nActionManager: Finished processing action sequence for $characterName.")
    }

    /**
     * Checks if an action can be executed.
     * @param actionName The name of the action.
     * @return A pair of (canExecute, reason) where canExecute is true if the action can be executed,
     * and reason is a message explaining why it cannot be executed if canExecute is false.
     */
    private fun canExecuteAction(actionName: String): Pair<Boolean, String> {
        val actionConfig = config.actionConfigs[actionName]

        if (actionConfig == null) {
            return Pair(false, "Warning: No configuration found for action '$actionName'. Skipping.")
        }

        // We don't have an action handler at this point, so we can't check resources
        // Just check other conditions (enabled, cooldown, run count)
        return actionMonitor(actionName, null, actionConfig, false)
    }

    /**
     * Checks if an action is out of resources.
     * @param actionHandler The action handler.
     * @param actionConfig The action configuration.
     * @param actionName The name of the action.
     * @return True if the action is out of resources, false otherwise.
     */
    private fun isOutOfResources(actionHandler: GameAction, actionConfig: ActionConfig, actionName: String): Boolean {
        val hasResources = actionHandler.hasResourcesAvailable(bot, actionConfig)
        if (!hasResources) {
            println("Action '$actionName' is out of resources. Setting on cooldown for ${actionConfig.cooldownDuration} minutes.")
            actionCooldowns[actionName] = Instant.now().plus(actionConfig.cooldownDuration.toLong(), ChronoUnit.MINUTES)
            return true
        }
        return false
    }

    /**
     * Monitors an action for cooldowns, run counts, and resource availability.
     * @param actionName The name of the action.
     * @param actionHandler The action handler (optional if checkResources is false).
     * @param actionConfig The action configuration.
     * @param checkResources Whether to check for resource availability.
     * @return A pair of (canExecute, reason) where canExecute is true if the action can be executed,
     * and reason is a message explaining why it cannot be executed if canExecute is false.
     */
    fun actionMonitor(actionName: String, actionHandler: GameAction?, actionConfig: ActionConfig, checkResources: Boolean = true): Pair<Boolean, String> {
        // Check if action is enabled
        if (!actionConfig.enabled) {
            return Pair(false, "Action '$actionName' is disabled in configuration. Skipping.")
        }

        // Check if action is on cooldown
        val cooldownEnd = actionCooldowns[actionName]
        if (cooldownEnd != null && Instant.now().isBefore(cooldownEnd)) {
            val remainingMinutes = ChronoUnit.MINUTES.between(Instant.now(), cooldownEnd)
            return Pair(false, "Action '$actionName' is on cooldown for $remainingMinutes more minutes. Skipping.")
        }

        // Check if action has reached its run count limit
        val runCount = getRunCountLimit(actionConfig)
        if (runCount > 0 && (actionRunCounts[actionName] ?: 0) >= runCount) {
            return Pair(false, "Action '$actionName' has reached its run count limit (${actionRunCounts[actionName]}/$runCount). Skipping.")
        }

        // Check for resource availability if requested and actionHandler is provided
        if (checkResources && actionHandler != null && isOutOfResources(actionHandler, actionConfig, actionName)) {
            return Pair(false, "Action '$actionName' is out of resources. Skipping.")
        }

        return Pair(true, "")
    }

    /**
     * Executes an action and handles the result.
     * @param actionName The name of the action.
     * @param actionHandler The action handler.
     * @param actionConfig The action configuration.
     */
    private fun executeAction(actionName: String, actionHandler: GameAction, actionConfig: ActionConfig) {
        try {
            // Reset the rerun state when starting a new action
            isRerunning = false
            // Check if action can be executed (including resource check)
            val canExecute = actionMonitor(actionName, actionHandler, actionConfig)
            if (!canExecute.first) {
                println(canExecute.second)
                return
            }

            // Start the action
            val success = actionHandler.execute(bot, actionConfig)
            if (success) {
                println("Action '$actionName' started successfully.")

                // Monitor the running action
                val monitorResult = monitorRunningAction(actionName, actionHandler, actionConfig, true)

                if (monitorResult.success) {
                    println("Action '$actionName' completed successfully.")

                    // Note: Run count is now incremented in the monitorRunningAction method when rerunning
                    // We only need to increment it here for the initial completion
                    if (!monitorResult.wasRerun) {
                        actionRunCounts[actionName] = (actionRunCounts[actionName] ?: 0) + 1
                    }

                    // Handle town button if available
                    if (monitorResult.townButtonAvailable) {
                        // Check if this is a Quest or Raid action that supports rerun
                        val supportsRerun = actionConfig is QuestActionConfig || actionConfig is RaidActionConfig

                        // Determine if we need to change configs for Quest/Raid actions
                        val needToChangeConfigs = when (actionConfig) {
                            is QuestActionConfig -> actionConfig.dungeonTargets.filter { it.enabled }.size > 1
                            is RaidActionConfig -> actionConfig.raidTargets.filter { it.enabled }.size > 1
                            else -> true // For other action types, always assume we need to change configs
                        }

                        // For Quest/Raid actions with single config, the monitor function handles rerun
                        // For Quest/Raid actions with multiple configs or other actions, we need to click town button
                        if (!supportsRerun || needToChangeConfigs) {
                            if (supportsRerun && needToChangeConfigs && monitorResult.rerunAvailable) {
                                println("Rerun button available for action '$actionName', but using town button instead because multiple targets are configured.")
                                println("This action has multiple enabled targets and needs to change configs for the next run.")
                            } else {
                                println("Town button available for action '$actionName'. Clicking to return to town.")
                            }

                            // Wait 800ms to ensure town button is clickable
                            println("Waiting 800ms to ensure town button is clickable...")
                            Thread.sleep(800) // 800 milliseconds

                            // Click the town button
                            if (bot.clickOnTemplate("templates/ui/town.png")) {
                                println("Clicked town button. Action will need to go through setup for next run.")
                                // Reset the rerun state when clicking town button
                                isRerunning = false

                                val runCount = getRunCountLimit(actionConfig)
                                val currentRunCount = actionRunCounts[actionName] ?: 0

                                if (runCount > 0 && currentRunCount >= runCount) {
                                    println("Action '$actionName' has reached its run count limit ($currentRunCount/$runCount).")
                                }
                            } else {
                                println("Failed to click town button. Continuing with next action.")
                            }
                        }
                    }
                } else {
                    println("Action '$actionName' ${monitorResult.message}")

                    // If the action failed due to resource depletion, set cooldown
                    if (monitorResult.outOfResources) {
                        println("Action '$actionName' is out of resources. Setting on cooldown for ${actionConfig.cooldownDuration} minutes.")
                        actionCooldowns[actionName] = Instant.now().plus(actionConfig.cooldownDuration.toLong(), ChronoUnit.MINUTES)
                    }

                    // Handle town button click if available (e.g., after player death)
                    if (monitorResult.townButtonAvailable) {
                        println("Town button available after action failure. Clicking to return to town.")
                        println("Waiting 800ms to ensure town button is clickable...")
                        Thread.sleep(800) // 800 milliseconds

                        if (bot.clickOnTemplate("templates/ui/town.png")) {
                            println("Clicked town button after action failure.")
                            // Reset the rerun state when clicking town button
                            isRerunning = false
                        } else {
                            println("Failed to click town button after action failure.")
                        }
                    }
                }
            } else {
                println("Action '$actionName' failed to start or did not complete setup.")
                // Decide if sequence should stop on failure, or continue
                // For now, we'll continue
            }
        } catch (e: Exception) {
            println("Error executing action '$actionName': ${e.message}")
            e.printStackTrace()
            // Decide on error handling, e.g., stop sequence or log and continue
        }
    }

    /**
     * Gets the run count limit for an action based on its configuration.
     * @param config The action configuration.
     * @return The run count limit, or 0 if unlimited.
     */
    private fun getRunCountLimit(config: ActionConfig): Int {
        return when (config) {
            is QuestActionConfig -> config.repeatCount
            is RaidActionConfig -> config.runCount
            is PvpActionConfig -> config.ticketsToUse
            else -> 1 // Default to 1 for other action types
        }
    }

    /**
     * Result class for the monitorRunningAction method.
     * Contains information about the monitoring result.
     */
    data class MonitorResult(
        val success: Boolean,
        val message: String,
        val outOfResources: Boolean = false,
        val rerunAvailable: Boolean = false,
        val townButtonAvailable: Boolean = false,
        val errorDetected: Boolean = false,
        val wasRerun: Boolean = false
    )

    /**
     * Monitors a running action and handles various conditions.
     * This function implements the ActionRunning loop that continuously checks
     * the game state while an action is running.
     * 
     * It checks for:
     * - Out of resources (with special handling for rerun state)
     * - Player death
     * - Player disconnected (with reconnect functionality)
     * - In-progress dialogues (handles them without interrupting the action)
     * - Rerun button (for Quest and Raid actions with single config)
     * - Town button (primary indicator of action completion)
     * 
     * Special handling for rerun:
     * - Detects and clicks the rerun button for appropriate actions
     * - Tracks if we're in a rerun state
     * - Counts consecutive resource checks after rerun
     * - Only returns out-of-resources after 3 checks in rerun state
     * - Sets wasRerun flag in the result to indicate if action was rerun
     * 
     * @param actionName The name of the action.
     * @param actionHandler The action handler.
     * @param actionConfig The action configuration.
     * @param isRunning Whether the action is currently running.
     * @param loopIntervalMs The interval in milliseconds between monitoring loop iterations (default is 1000ms).
     * @return A MonitorResult containing information about the monitoring result.
     */
    private fun monitorRunningAction(
        actionName: String,
        actionHandler: GameAction,
        actionConfig: ActionConfig,
        isRunning: Boolean,
        loopIntervalMs: Long = 3000
    ): MonitorResult {
        if (!isRunning) {
            return MonitorResult(false, "not running")
        }

        println("Starting continuous monitoring for action: $actionName")

        // Define templates to check for various conditions
        val playerDeadPath = "templates/ui/playerdead.png"
        val townButtonPath = "templates/ui/town.png"
        val rerunButtonPath = "templates/ui/rerun.png"
        val inProgressDialoguePath = "templates/ui/handleinprogressdialogue.png"
        val reconnectPath = "templates/ui/reconnect.png"
        val mainScreenAnchorPath = "templates/ui/mainscreenanchor.png"
        val outOfResourcesPath = "templates/ui/outofresourcepopup.png"

        // Check if template files exist
        val playerDeadExists = File(playerDeadPath).exists()
        val townButtonExists = File(townButtonPath).exists()
        val inProgressDialogueExists = File(inProgressDialoguePath).exists()
        val reconnectExists = File(reconnectPath).exists()
        val mainScreenAnchorExists = File(mainScreenAnchorPath).exists()
        val outOfResourcesExists = File(outOfResourcesPath).exists()

        if (!playerDeadExists) {
            println("Warning: Player death template not found at $playerDeadPath. Player death detection will be skipped.")
        }

        if (!townButtonExists) {
            println("Warning: Town button template not found at $townButtonPath. Town button detection will be skipped.")
        }

        if (!inProgressDialogueExists) {
            println("Warning: In-progress dialogue template not found at $inProgressDialoguePath. In-progress dialogue detection will be skipped.")
        }

        if (!reconnectExists) {
            println("Warning: Reconnect button template not found at $reconnectPath. Disconnect detection will be skipped.")
        }

        if (!mainScreenAnchorExists) {
            println("Warning: Main screen anchor template not found at $mainScreenAnchorPath. Main screen detection will be skipped.")
        }

        if (!outOfResourcesExists) {
            println("Warning: Out of resources template not found at $outOfResourcesPath. Out of resources detection will be skipped.")
        }

        // Maximum monitoring time (5 minutes) to prevent infinite loops
        val maxMonitoringTimeMs = 5 * 60 * 1000L
        val startTime = System.currentTimeMillis()

        // One-time autopilot check at the beginning of monitoring
        try {
            runBlocking {
                bot.ensureAutopilotEngagedOnce()
            }
        } catch (e: Exception) {
            println("Error during autopilot check: ${e.message}")
            // Continue monitoring even if autopilot check fails
        }

        // Counter for loop iterations (for heartbeat logging)
        var iterations = 0

        // Track the number of consecutive resource checks after rerun
        var rerunResourceCheckCount = 0

        // Monitoring loop
        while (System.currentTimeMillis() - startTime < maxMonitoringTimeMs) {
            // Increment iteration counter
            iterations++

            // Log heartbeat message every 3 iterations
            if (iterations % 3 == 0) {
                println("Monitor heartbeat: Still monitoring action '$actionName' (${System.currentTimeMillis() - startTime}ms elapsed)")
            }

            // Check for out of resources if template exists
            if (outOfResourcesExists && bot.findTemplate(outOfResourcesPath, verbose = false) != null) {
                println("Out of resources detected during monitoring")

                // If we're in a rerun state, increment the resource check count
                if (isRerunning) {
                    rerunResourceCheckCount++
                    println("Rerun resource check count: $rerunResourceCheckCount")

                    // If we've reached 3 resource checks after rerun, return out of resources
                    if (rerunResourceCheckCount >= 3) {
                        println("Reached 3 out-of-resource checks after rerun. Action is out of resources.")
                        return MonitorResult(false, "failed due to resource depletion after rerun", outOfResources = true)
                    }
                } else {
                    // If not in rerun state, return out of resources immediately
                    return MonitorResult(false, "failed due to resource depletion", outOfResources = true)
                }
            }

            // Check for player disconnected if template exists
            if (reconnectExists && bot.findTemplate(reconnectPath, verbose = false) != null) {
                println("Player disconnected detected during monitoring")

                // Wait 800ms to ensure button is clickable
                println("Waiting 800ms to ensure reconnect button is clickable...")
                Thread.sleep(800) // 800 milliseconds

                // Click the reconnect button
                if (bot.clickOnTemplate(reconnectPath)) {
                    println("Clicked reconnect button after disconnect")

                    // Wait for reconnection (up to 30 seconds)
                    val reconnectStartTime = System.currentTimeMillis()
                    val maxReconnectTimeMs = 30 * 1000L
                    var reconnected = false

                    while (System.currentTimeMillis() - reconnectStartTime < maxReconnectTimeMs) {
                        // Check for main screen anchor to confirm reconnection
                        if (mainScreenAnchorExists && bot.findTemplate(mainScreenAnchorPath, verbose = false) != null) {
                            println("Successfully reconnected to game")
                            reconnected = true
                            break
                        }
                        Thread.sleep(1000)
                    }

                    if (!reconnected) {
                        println("Failed to reconnect within timeout period")
                        return MonitorResult(false, "failed to reconnect after disconnect")
                    }

                    // Continue monitoring after successful reconnection
                    continue
                } else {
                    println("Failed to click reconnect button")
                    return MonitorResult(false, "failed to click reconnect button")
                }
            }

            // Check for player death if template exists
            if (playerDeadExists && bot.findTemplate(playerDeadPath, verbose = false) != null) {
                println("Player death detected during monitoring")

                // Check if town button is available but don't click it
                // Let the executeAction method handle the clicking based on the result
                val townButtonAvailable = townButtonExists && bot.findTemplate(townButtonPath, verbose = false) != null
                if (townButtonAvailable) {
                    println("Town button detected after player death")
                } else {
                    println("Town button not found after player death")
                }

                return MonitorResult(false, "failed due to player death", townButtonAvailable = townButtonAvailable)
            }

            // Check for in-progress dialogue if template exists
            if (inProgressDialogueExists && bot.findTemplate(inProgressDialoguePath, verbose = false) != null) {
                println("In-progress dialogue detected during monitoring")

                // Wait 800ms to ensure dialogue is clickable
                println("Waiting 800ms to ensure in-progress dialogue is clickable...")
                Thread.sleep(800) // 800 milliseconds

                // Click on the dialogue to handle it
                if (bot.clickOnTemplate(inProgressDialoguePath)) {
                    println("Successfully clicked on in-progress dialogue")
                } else {
                    println("Failed to click on in-progress dialogue")
                }

                // Continue monitoring after handling the dialogue
                // No need to return, as this is a regular part of gameplay
            }

            // Check for rerun button if we're not already in a rerun state
            if (!isRerunning && File(rerunButtonPath).exists() && bot.findTemplate(rerunButtonPath, verbose = false) != null) {
                println("Rerun button detected during monitoring")

                // Check if this is a Quest or Raid action that supports rerun
                val supportsRerun = actionConfig is QuestActionConfig || actionConfig is RaidActionConfig

                // Determine if we need to change configs for Quest/Raid actions
                val needToChangeConfigs = when (actionConfig) {
                    is QuestActionConfig -> actionConfig.dungeonTargets.filter { it.enabled }.size > 1
                    is RaidActionConfig -> actionConfig.raidTargets.filter { it.enabled }.size > 1
                    else -> true // For other action types, always assume we need to change configs
                }

                // For Quest/Raid actions with single config, use rerun if available
                if (supportsRerun && !needToChangeConfigs) {
                    val runCount = getRunCountLimit(actionConfig)
                    val currentRunCount = actionRunCounts[actionName] ?: 0

                    if (runCount == 0 || currentRunCount < runCount) {
                        println("Rerun button available for action '$actionName'. Attempting to rerun.")

                        // Wait 800ms to ensure button is clickable
                        println("Waiting 800ms to ensure rerun button is clickable...")
                        Thread.sleep(800) // 800 milliseconds

                        // Click the rerun button
                        if (bot.clickOnTemplate(rerunButtonPath)) {
                            println("Clicked rerun button. Continuing monitoring.")

                            // Set the rerun state to true
                            isRerunning = true

                            // Reset the resource check count for this rerun
                            rerunResourceCheckCount = 0

                            // Increment run count
                            actionRunCounts[actionName] = (actionRunCounts[actionName] ?: 0) + 1

                            // Continue monitoring after clicking rerun
                            continue
                        } else {
                            println("Failed to click rerun button. Continuing monitoring.")
                        }
                    } else {
                        println("Action '$actionName' has reached its run count limit ($currentRunCount/$runCount). Not rerunning.")
                    }
                }
            }

            // Check for town button (primary indicator of action completion)
            if (townButtonExists && bot.findTemplate(townButtonPath, verbose = false) != null) {
                println("Town button detected - action is complete (win or lose)")

                // Check if we're in a rerun state and if the action still has runs left
                if (isRerunning) {
                    // Check if this is a Quest or Raid action that supports rerun
                    val supportsRerun = actionConfig is QuestActionConfig || actionConfig is RaidActionConfig

                    // Determine if we need to change configs for Quest/Raid actions
                    val needToChangeConfigs = when (actionConfig) {
                        is QuestActionConfig -> actionConfig.dungeonTargets.filter { it.enabled }.size > 1
                        is RaidActionConfig -> actionConfig.raidTargets.filter { it.enabled }.size > 1
                        else -> true // For other action types, always assume we need to change configs
                    }

                    // For Quest/Raid actions with single config, check if we should continue rerunning
                    if (supportsRerun && !needToChangeConfigs) {
                        val runCount = getRunCountLimit(actionConfig)
                        val currentRunCount = actionRunCounts[actionName] ?: 0

                        if (runCount == 0 || currentRunCount < runCount) {
                            // Check if rerun button is available
                            if (File(rerunButtonPath).exists() && bot.findTemplate(rerunButtonPath, verbose = false) != null) {
                                println("Town button detected during rerun, but action '$actionName' still has runs left. Checking for rerun button.")

                                // Wait 800ms to ensure button is clickable
                                println("Waiting 800ms to ensure rerun button is clickable...")
                                Thread.sleep(800) // 800 milliseconds

                                // Click the rerun button
                                if (bot.clickOnTemplate(rerunButtonPath)) {
                                    println("Clicked rerun button after town button detection. Continuing monitoring.")

                                    // Reset the resource check count for this rerun
                                    rerunResourceCheckCount = 0

                                    // Increment run count
                                    actionRunCounts[actionName] = (actionRunCounts[actionName] ?: 0) + 1

                                    // Continue monitoring after clicking rerun
                                    continue
                                } else {
                                    println("Failed to click rerun button after town button detection. Returning to town.")
                                }
                            } else {
                                println("Rerun button not found after town button detection. Returning to town.")
                            }
                        } else {
                            println("Action '$actionName' has reached its run count limit ($currentRunCount/$runCount). Not rerunning after town button detection.")
                        }
                    }
                }

                // Check if rerun is available
                val rerunAvailable = File(rerunButtonPath).exists() && bot.findTemplate(rerunButtonPath, verbose = false) != null

                // Return result without clicking the town button
                // Let the executeAction method handle the clicking based on the result
                return MonitorResult(
                    success = true, 
                    message = "completed successfully", 
                    rerunAvailable = rerunAvailable, 
                    townButtonAvailable = true,
                    wasRerun = isRerunning // Set wasRerun to true if we're in a rerun state
                )
            }

            // Sleep to prevent CPU overuse (using configurable interval)
            Thread.sleep(loopIntervalMs)
        }

        // If we reach here, monitoring timed out
        println("Monitoring timed out for action: $actionName")
        return MonitorResult(false, "monitoring timed out")
    }
}
