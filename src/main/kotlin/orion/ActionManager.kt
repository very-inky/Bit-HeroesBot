package orion

import orion.actions.*
import java.time.Instant
import java.time.temporal.ChronoUnit

// Imports for Bot, BotConfig, GameAction, ActionConfig from the 'orion' package are not needed
// if ActionManager is correctly declared in 'package orion'.

class ActionManager(private val bot: Bot, private val config: BotConfig, private val configManager: ConfigManager? = null) {
    // Map to track cooldowns for actions
    private val actionCooldowns = mutableMapOf<String, Instant>()
    // Map to track run counts for actions
    private val actionRunCounts = mutableMapOf<String, Int>()

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
            // Check if action can be executed (including resource check)
            val canExecute = actionMonitor(actionName, actionHandler, actionConfig)
            if (!canExecute.first) {
                println(canExecute.second)
                return
            }

            val success = actionHandler.execute(bot, actionConfig)
            if (success) {
                println("Action '$actionName' completed successfully.")
                // Increment run count
                actionRunCounts[actionName] = (actionRunCounts[actionName] ?: 0) + 1

                // Check if we need to set cooldown after execution due to resource depletion
                val postExecutionCheck = actionMonitor(actionName, actionHandler, actionConfig)
                if (!postExecutionCheck.first && postExecutionCheck.second.contains("out of resources")) {
                    println(postExecutionCheck.second)
                }
            } else {
                println("Action '$actionName' failed or did not complete fully.")
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
}
