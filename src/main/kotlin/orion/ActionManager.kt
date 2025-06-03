package orion

import orion.actions.*
import orion.state.ActionData
import orion.state.BotState
import orion.state.StateMachine
import java.time.Instant
import java.time.temporal.ChronoUnit
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.delay
import java.io.File
import java.awt.event.KeyEvent

// Imports for Bot, BotConfig, GameAction, ActionConfig from the 'orion' package are not needed
// if ActionManager is correctly declared in 'package orion'.

class ActionManager(private val bot: Bot, private val config: BotConfig, private val configManager: ConfigManager? = null) {
    // Map to track cooldowns for actions
    private val actionCooldowns = mutableMapOf<String, Instant>()
    // Map to track run counts for actions
    private val actionRunCounts = mutableMapOf<String, Int>()
    // Flag to track if we're in a rerun state
    private var isRerunning = false

    // State machine for managing bot states
    private val stateMachine = StateMachine()

    init {
        // Set up the state machine with transitions and handlers
        setupStateMachine()
    }

    /**
     * Sets up the state machine with transitions and handlers.
     * This defines all possible state transitions and what happens when entering each state.
     */
    private fun setupStateMachine() {
        // Define state transitions
        with(stateMachine) {
            // From Idle state
            addTransition(BotState.Idle, "start_action", BotState.Starting)

            // From Starting state
            addTransition(BotState.Starting, "action_started", BotState.Running)
            addTransition(BotState.Starting, "start_failed", BotState.Failed)

            // From Running state
            addTransition(BotState.Running, "rerun_detected", BotState.Rerunning)
            addTransition(BotState.Running, "out_of_resources", BotState.OutOfResources)
            addTransition(BotState.Running, "player_dead", BotState.PlayerDead)
            addTransition(BotState.Running, "disconnected", BotState.Disconnected)
            addTransition(BotState.Running, "completed", BotState.Completed)

            // From Rerunning state
            addTransition(BotState.Rerunning, "out_of_resources", BotState.OutOfResources)
            addTransition(BotState.Rerunning, "player_dead", BotState.PlayerDead)
            addTransition(BotState.Rerunning, "disconnected", BotState.Disconnected)
            addTransition(BotState.Rerunning, "completed", BotState.Completed)

            // From Disconnected state
            addTransition(BotState.Disconnected, "reconnect", BotState.Reconnecting)

            // From Reconnecting state
            addTransition(BotState.Reconnecting, "reconnected", BotState.Running)
            addTransition(BotState.Reconnecting, "failed", BotState.Failed)

            // From PlayerDead state
            addTransition(BotState.PlayerDead, "return_to_town", BotState.Completed)

            // From all terminal states back to Idle
            addTransition(BotState.Completed, "next_action", BotState.Idle)
            addTransition(BotState.Failed, "next_action", BotState.Idle)
            addTransition(BotState.OutOfResources, "next_action", BotState.Idle)

            // Define state handlers
            addStateHandler(BotState.Idle) { data ->
                println("Bot is idle, ready for next action")
            }

            addStateHandler(BotState.Starting) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    println("Starting action: ${actionData.actionName}")

                    // Verify that the game is properly loaded before proceeding
                    val mainScreenAnchorPath = "templates/ui/mainscreenanchor.png"
                    val popupPath = "templates/ui/popup.png"

                    // Check if template files exist
                    val mainScreenAnchorExists = File(mainScreenAnchorPath).exists()
                    val popupExists = File(popupPath).exists()

                    if (!mainScreenAnchorExists) {
                        println("Warning: Main screen anchor template not found at $mainScreenAnchorPath. Game verification will be skipped.")
                    }

                    if (!popupExists) {
                        println("Warning: Popup template not found at $popupPath. Popup detection will be skipped.")
                    }

                    // Only proceed with verification if templates exist
                    if (mainScreenAnchorExists) {
                        println("Verifying game is properly loaded...")

                        // Maximum number of retries
                        val maxRetries = 5
                        var retryCount = 0
                        var gameLoaded = false

                        while (retryCount < maxRetries && !gameLoaded) {
                            // Check for main screen anchor
                            val mainScreenFound = actionData.bot.findTemplate(mainScreenAnchorPath, verbose = false) != null

                            if (mainScreenFound) {
                                println("Main screen anchor found. Game is properly loaded.")
                                gameLoaded = true
                            } else {
                                // Check for popup if main screen anchor not found
                                val popupFound = popupExists && actionData.bot.findTemplate(popupPath, verbose = false) != null

                                if (popupFound) {
                                    println("Popup detected. Attempting to close it...")
                                    // Try to click on the popup to close it
                                    if (actionData.bot.clickOnTemplate(popupPath)) {
                                        println("Clicked on popup. Waiting for main screen...")
                                    } else {
                                        println("Failed to click on popup.")
                                    }
                                }

                                // Increment retry count and wait before next attempt
                                retryCount++
                                if (retryCount < maxRetries) {
                                    println("Game not properly loaded. Retrying ($retryCount/$maxRetries)...")
                                    Thread.sleep(2000) // Wait 2 seconds before retrying
                                }
                            }
                        }

                        // If game is not loaded after all retries, transition to Failed state
                        if (!gameLoaded) {
                            println("Failed to verify game is properly loaded after $maxRetries attempts.")
                            // Store failure reason in action data for the Failed state handler
                            actionData.setData("failureReason", "Game not properly loaded")
                            // Transition to Failed state
                            stateMachine.processEvent("start_failed", actionData)
                        }
                    }
                }
            }

            addStateHandler(BotState.Running) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    println("Running action: ${actionData.actionName}")
                    // Reset the rerun state when entering Running state
                    isRerunning = false
                }
            }

            addStateHandler(BotState.Rerunning) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    println("Rerunning action: ${actionData.actionName}")
                    // Set the rerun state when entering Rerunning state
                    isRerunning = true
                    // Increment run count
                    actionData.incrementRunCount()
                    actionRunCounts[actionData.actionName] = actionData.runCount
                }
            }

            addStateHandler(BotState.OutOfResources) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    println("Action '${actionData.actionName}' is out of resources. Setting on cooldown.")
                    actionCooldowns[actionData.actionName] = Instant.now().plus(
                        actionData.actionConfig.cooldownDuration.toLong(), ChronoUnit.MINUTES)
                }
            }

            addStateHandler(BotState.PlayerDead) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    println("Player died during action: ${actionData.actionName}")
                }
            }

            addStateHandler(BotState.Disconnected) { data ->
                println("Disconnected from game. Attempting to reconnect...")
            }

            addStateHandler(BotState.Reconnecting) { data ->
                println("Attempting to reconnect to game...")
            }

            addStateHandler(BotState.Completed) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    println("Action '${actionData.actionName}' completed successfully.")
                    // Increment run count if not already incremented in Rerunning state
                    if (!isRerunning) {
                        actionData.incrementRunCount()
                        actionRunCounts[actionData.actionName] = actionData.runCount
                    }
                }
            }

            addStateHandler(BotState.Failed) { data ->
                val actionData = data as? ActionData
                if (actionData != null) {
                    // Check if there's a specific failure reason
                    val failureReason = actionData.getData<String>("failureReason")
                    if (failureReason != null) {
                        println("Action '${actionData.actionName}' failed: $failureReason")
                    } else {
                        println("Action '${actionData.actionName}' failed.")
                    }
                }
            }
        }
    }

    /**
     * Runs the sequence of actions defined in the configuration.
     * Uses the state machine to manage the action sequence.
     */
    fun runActionSequence() {
        // Get character name from ConfigManager if available, otherwise use config name
        val characterName = if (configManager != null) {
            configManager.getCharacter(config.characterId)?.characterName ?: config.configName
        } else {
            config.configName
        }

        println("ActionManager: Starting action sequence for $characterName using config '${config.configName}' (ID: ${config.configId}).")
        println("Action sequence: ${config.actionSequence.joinToString(" -> ")}")
        println("Using state machine for action management")

        // Initialize run counts for all actions
        for (actionName in config.actionSequence) {
            actionRunCounts[actionName] = 0
        }

        // Reset the state machine to Idle state
        stateMachine.reset(BotState.Idle)

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

                // Get the action config (case-insensitive lookup)
                val actionConfigKey = config.actionConfigs.keys.find { it.equals(actionName, ignoreCase = true) }
                    ?: throw IllegalStateException("Action config not found for $actionName")
                val actionConfig = config.actionConfigs[actionConfigKey]!!

                println("\nAttempting to execute action: $actionName")
                val actionHandler: GameAction? = createActionHandler(actionName)

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
     * Creates an action handler for the specified action name.
     * 
     * @param actionName The name of the action
     * @return The action handler, or null if no handler is defined for the action
     */
    private fun createActionHandler(actionName: String): GameAction? {
        return when (actionName.lowercase()) {
            "quest" -> QuestAction()
            "raid" -> RaidAction()
            // "pvp" -> PvpAction() // Placeholder for when PvpAction.kt is created
            // "gvg" -> GvgAction()
            // "worldboss" -> WorldBossAction()
            // "trials" -> TrialsAction()
            // "expedition" -> ExpeditionAction()
            // "gauntlet" -> GauntletAction()
            else -> {
                println("Warning: Unknown action type '$actionName' in sequence. No handler defined. Skipping.")
                null
            }
        }
    }

    /**
     * Checks if an action can be executed.
     * @param actionName The name of the action.
     * @return A pair of (canExecute, reason) where canExecute is true if the action can be executed,
     * and reason is a message explaining why it cannot be executed if canExecute is false.
     */
    private fun canExecuteAction(actionName: String): Pair<Boolean, String> {
        // Case-insensitive lookup for action config
        val actionConfigKey = config.actionConfigs.keys.find { it.equals(actionName, ignoreCase = true) }
        val actionConfig = actionConfigKey?.let { config.actionConfigs[it] }

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
     * Executes an action and handles the result using the state machine.
     * @param actionName The name of the action.
     * @param actionHandler The action handler.
     * @param actionConfig The action configuration.
     */
    internal fun executeAction(actionName: String, actionHandler: GameAction, actionConfig: ActionConfig) {
        try {
            // Reset the state machine to Idle state
            stateMachine.reset(BotState.Idle)

            // Check if action can be executed (including resource check)
            val canExecute = actionMonitor(actionName, actionHandler, actionConfig)
            if (!canExecute.first) {
                println(canExecute.second)
                return
            }

            // Create ActionData object to pass to state handlers
            val runCount = getRunCountLimit(actionConfig)
            val currentRunCount = actionRunCounts[actionName] ?: 0
            val actionData = ActionData(
                actionName = actionName,
                actionHandler = actionHandler,
                actionConfig = actionConfig,
                bot = bot,
                runCount = currentRunCount,
                maxRunCount = runCount
            )

            // Transition to Starting state
            stateMachine.processEvent("start_action", actionData)

            // Check if we're still in Starting state (not Failed)
            if (stateMachine.getCurrentState() == BotState.Starting) {
                // Start the action
                val success = actionHandler.execute(bot, actionConfig)
                if (success) {
                    // Transition to Running state
                    stateMachine.processEvent("action_started", actionData)

                    // Monitor the action using the state machine
                    monitorActionWithStateMachine(actionData)

                    // After monitoring completes, handle town button if in Completed state
                    if (stateMachine.getCurrentState() == BotState.Completed) {
                        handleTownButton(actionData)
                    }
                } else {
                    // Transition to Failed state
                    stateMachine.processEvent("start_failed", actionData)
                }
            } else {
                // We're no longer in Starting state, likely transitioned to Failed during game verification
                println("Action '${actionData.actionName}' will not be executed because game verification failed.")
            }

            // Transition back to Idle state for the next action
            if (stateMachine.getCurrentState() != BotState.Idle) {
                stateMachine.processEvent("next_action", actionData)
            }
        } catch (e: Exception) {
            println("Error executing action '$actionName': ${e.message}")
            e.printStackTrace()
            // Reset state machine to Idle for next action
            stateMachine.reset(BotState.Idle)
        }
    }

    /**
     * Monitors an action using the state machine.
     * This method continuously checks the game state and triggers appropriate state transitions.
     * 
     * @param actionData The action data
     */
    private fun monitorActionWithStateMachine(actionData: ActionData) {
        val actionName = actionData.actionName
        println("Starting continuous monitoring for action: $actionName using state machine")

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

        // Log warnings for missing templates
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
                actionData.bot.ensureAutopilotEngagedOnce()
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
                println("Current state: ${stateMachine.getCurrentState()}")
            }

            // Check for out of resources if template exists
            if (outOfResourcesExists && actionData.bot.findTemplate(outOfResourcesPath, verbose = false) != null) {
                println("Out of resources detected during monitoring")

                // If we're in a rerun state, increment the resource check count
                if (stateMachine.getCurrentState() == BotState.Rerunning) {
                    rerunResourceCheckCount++
                    println("Rerun resource check count: $rerunResourceCheckCount")

                    // If we've reached 3 resource checks after rerun, handle out of resources
                    if (rerunResourceCheckCount >= 3) {
                        println("Reached 3 out-of-resource checks after rerun. Action is out of resources.")
                        handleOutOfResources(actionData, mainScreenAnchorPath)
                        return
                    }
                } else {
                    // If not in rerun state, handle out of resources immediately
                    handleOutOfResources(actionData, mainScreenAnchorPath)
                    return
                }
            }

            // Check for player disconnected using the reusable function
            if (checkForDisconnect(actionData, reconnectPath, mainScreenAnchorPath)) {
                // If disconnect was handled, return from monitoring
                return
            }

            // Check for player death if template exists
            if (playerDeadExists && actionData.bot.findTemplate(playerDeadPath, verbose = false) != null) {
                println("Player death detected during monitoring")

                // Transition to PlayerDead state
                stateMachine.processEvent("player_dead", actionData)

                // Check if town button is available
                if (townButtonExists && actionData.bot.findTemplate(townButtonPath, verbose = false) != null) {
                    println("Town button detected after player death")

                    // Transition to Completed state via return_to_town event
                    stateMachine.processEvent("return_to_town", actionData)
                }

                return
            }

            // Check for in-progress dialogue if template exists
            if (inProgressDialogueExists && actionData.bot.findTemplate(inProgressDialoguePath, verbose = false) != null) {
                println("In-progress dialogue detected during monitoring")

                // Wait 800ms to ensure dialogue is clickable
                println("Waiting 800ms to ensure in-progress dialogue is clickable...")
                Thread.sleep(800) // 800 milliseconds

                // Click on the dialogue to handle it
                if (actionData.bot.clickOnTemplate(inProgressDialoguePath)) {
                    println("Successfully clicked on in-progress dialogue")
                } else {
                    println("Failed to click on in-progress dialogue")
                }

                // Continue monitoring after handling the dialogue
                // No need to change state, as this is a regular part of gameplay
            }

            // Check for rerun button if we're in Running state
            if (stateMachine.getCurrentState() == BotState.Running && 
                File(rerunButtonPath).exists() && 
                actionData.bot.findTemplate(rerunButtonPath, verbose = false) != null) {

                println("Rerun button detected during monitoring")

                // Check if this is a Quest or Raid action that supports rerun
                val supportsRerun = actionData.actionConfig is QuestActionConfig || actionData.actionConfig is RaidActionConfig

                // Determine if we need to change configs for Quest/Raid actions
                val needToChangeConfigs = when (actionData.actionConfig) {
                    is QuestActionConfig -> actionData.actionConfig.dungeonTargets.filter { it.enabled }.size > 1
                    is RaidActionConfig -> actionData.actionConfig.raidTargets.filter { it.enabled }.size > 1
                    else -> true // For other action types, always assume we need to change configs
                }

                // For Quest/Raid actions with single config, use rerun if available
                if (supportsRerun && !needToChangeConfigs && !actionData.hasReachedMaxRunCount()) {
                    println("Rerun button available for action '${actionData.actionName}'. Attempting to rerun.")

                    // Wait 800ms to ensure button is clickable
                    println("Waiting 800ms to ensure rerun button is clickable...")
                    Thread.sleep(800) // 800 milliseconds

                    // Click the rerun button
                    if (actionData.bot.clickOnTemplate(rerunButtonPath)) {
                        println("Clicked rerun button. Continuing monitoring.")

                        // Transition to Rerunning state
                        stateMachine.processEvent("rerun_detected", actionData)

                        // Reset the resource check count for this rerun
                        rerunResourceCheckCount = 0

                        // Continue monitoring after clicking rerun
                        continue
                    } else {
                        println("Failed to click rerun button. Continuing monitoring.")
                    }
                } else if (actionData.hasReachedMaxRunCount()) {
                    println("Action '${actionData.actionName}' has reached its run count limit (${actionData.runCount}/${actionData.maxRunCount}). Not rerunning.")
                }
            }

            // Check for town button (primary indicator of action completion)
            if (townButtonExists && actionData.bot.findTemplate(townButtonPath, verbose = false) != null) {
                println("Town button detected - action is complete (win or lose)")

                // If we're in Rerunning state and the action still has runs left, check for rerun button
                if (stateMachine.getCurrentState() == BotState.Rerunning && !actionData.hasReachedMaxRunCount()) {
                    // Check if this is a Quest or Raid action that supports rerun
                    val supportsRerun = actionData.actionConfig is QuestActionConfig || actionData.actionConfig is RaidActionConfig

                    // Determine if we need to change configs for Quest/Raid actions
                    val needToChangeConfigs = when (actionData.actionConfig) {
                        is QuestActionConfig -> actionData.actionConfig.dungeonTargets.filter { it.enabled }.size > 1
                        is RaidActionConfig -> actionData.actionConfig.raidTargets.filter { it.enabled }.size > 1
                        else -> true // For other action types, always assume we need to change configs
                    }

                    // For Quest/Raid actions with single config, check if we should continue rerunning
                    if (supportsRerun && !needToChangeConfigs) {
                        // Check if rerun button is available
                        if (File(rerunButtonPath).exists() && actionData.bot.findTemplate(rerunButtonPath, verbose = false) != null) {
                            println("Town button detected during rerun, but action '${actionData.actionName}' still has runs left. Checking for rerun button.")

                            // Wait 800ms to ensure button is clickable
                            println("Waiting 800ms to ensure rerun button is clickable...")
                            Thread.sleep(800) // 800 milliseconds

                            // Click the rerun button
                            if (actionData.bot.clickOnTemplate(rerunButtonPath)) {
                                println("Clicked rerun button after town button detection. Continuing monitoring.")

                                // Reset the resource check count for this rerun
                                rerunResourceCheckCount = 0

                                // Continue monitoring after clicking rerun
                                continue
                            } else {
                                println("Failed to click rerun button after town button detection. Returning to town.")
                            }
                        } else {
                            println("Rerun button not found after town button detection. Returning to town.")
                        }
                    }
                }

                // Transition to Completed state
                stateMachine.processEvent("completed", actionData)

                // Store rerun button availability in action data for later use
                val rerunAvailable = File(rerunButtonPath).exists() && 
                                     actionData.bot.findTemplate(rerunButtonPath, verbose = false) != null
                actionData.setData("rerunAvailable", rerunAvailable)

                return
            }

            // Sleep to prevent CPU overuse
            Thread.sleep(3000)
        }

        // If we reach here, monitoring timed out
        println("Monitoring timed out for action: ${actionData.actionName}")

        // Transition to Failed state
        stateMachine.processEvent("failed", actionData)
    }

    /**
     * Checks for player disconnect and handles reconnection if needed.
     * 
     * @param actionData The action data
     * @param reconnectPath The path to the reconnect button template
     * @param mainScreenAnchorPath The path to the main screen anchor template
     * @return True if a disconnect was detected and handled, false otherwise
     */
    private fun checkForDisconnect(actionData: ActionData, reconnectPath: String, mainScreenAnchorPath: String): Boolean {
        // Check if template files exist
        val reconnectExists = File(reconnectPath).exists()
        val mainScreenAnchorExists = File(mainScreenAnchorPath).exists()

        if (!reconnectExists) {
            return false
        }

        // First check for disconnect
        if (actionData.bot.findTemplate(reconnectPath, verbose = false) == null) {
            return false
        }

        println("Potential player disconnect detected - checking again to confirm...")

        // Wait a moment before checking again
        Thread.sleep(1000)

        // Second check to confirm disconnect
        if (actionData.bot.findTemplate(reconnectPath, verbose = false) == null) {
            println("Disconnect not confirmed on second check")
            return false
        }

        println("Player disconnect confirmed after second check")

        // Transition to Disconnected state
        stateMachine.processEvent("disconnected", actionData)

        // Wait 800ms to ensure button is clickable
        println("Waiting 800ms to ensure reconnect button is clickable...")
        Thread.sleep(800) // 800 milliseconds

        // Click the reconnect button
        if (actionData.bot.clickOnTemplate(reconnectPath)) {
            println("Clicked reconnect button after disconnect")

            // Transition to Reconnecting state
            stateMachine.processEvent("reconnect", actionData)

            // Wait for reconnection (up to 30 seconds)
            val reconnectStartTime = System.currentTimeMillis()
            val maxReconnectTimeMs = 30 * 1000L
            var reconnected = false

            while (System.currentTimeMillis() - reconnectStartTime < maxReconnectTimeMs) {
                // Check for main screen anchor to confirm reconnection
                if (mainScreenAnchorExists && actionData.bot.findTemplate(mainScreenAnchorPath, verbose = false) != null) {
                    println("Successfully reconnected to game")
                    reconnected = true

                    // Transition to Idle state to force game verification on next action
                    stateMachine.processEvent("reconnected", actionData)
                    stateMachine.processEvent("next_action", actionData)
                    break
                }
                Thread.sleep(1000)
            }

            if (!reconnected) {
                println("Failed to reconnect within timeout period")

                // Transition to Failed state
                stateMachine.processEvent("failed", actionData)
            }

            return true
        } else {
            println("Failed to click reconnect button")

            // Transition to Failed state
            stateMachine.processEvent("failed", actionData)
            return true
        }
    }

    /**
     * Handles out-of-resource conditions by pressing Escape key multiple times,
     * verifying the main screen anchor is visible, and then transitioning to OutOfResources state.
     * 
     * @param actionData The action data
     * @param mainScreenAnchorPath The path to the main screen anchor template
     */
    private fun handleOutOfResources(actionData: ActionData, mainScreenAnchorPath: String) {
        println("Handling out-of-resource condition for action: ${actionData.actionName}")

        // Press Escape key multiple times to close any UI dialogs
        val maxEscapePresses = 5
        println("Pressing Escape key $maxEscapePresses times to close UI dialogs...")

        for (i in 1..maxEscapePresses) {
            println("Pressing Escape key (${i}/$maxEscapePresses)...")
            actionData.bot.pressKey(KeyEvent.VK_ESCAPE)
            Thread.sleep(500)
        }


        println("Verifying main screen anchor is visible after handling out-of-resource...")
        var mainScreenVisible = false
        val maxRetries = 2
        var retryCount = 0

        while (retryCount < maxRetries && !mainScreenVisible) {
            // Check if main screen anchor template exists
            if (File(mainScreenAnchorPath).exists()) {
                // Check if main screen anchor is visible
                if (actionData.bot.findTemplate(mainScreenAnchorPath, verbose = false) != null) {
                    println("Main screen anchor is visible after handling out-of-resource.")
                    mainScreenVisible = true
                } else {
                    println("Main screen anchor not visible. Retrying (${retryCount + 1}/$maxRetries)...")
                    retryCount++
                    Thread.sleep(1000) // Wait a bit before retrying
                }
            } else {
                println("Warning: Main screen anchor template not found at $mainScreenAnchorPath. Skipping verification.")
                break
            }
        }

        if (!mainScreenVisible && File(mainScreenAnchorPath).exists()) {
            println("Warning: Failed to verify main screen anchor is visible after handling out-of-resource.")
        }

        // Transition to OutOfResources state
        println("Transitioning to OutOfResources state...")
        stateMachine.processEvent("out_of_resources", actionData)
    }

    /**
     * Handles the town button click based on action configuration.
     * 
     * @param actionData The action data
     */
    private fun handleTownButton(actionData: ActionData) {
        val actionName = actionData.actionName
        val actionConfig = actionData.actionConfig

        // Check if town button is available
        if (File("templates/ui/town.png").exists() && bot.findTemplate("templates/ui/town.png", verbose = false) != null) {
            // Check if this is a Quest or Raid action that supports rerun
            val supportsRerun = actionConfig is QuestActionConfig || actionConfig is RaidActionConfig

            // Determine if we need to change configs for Quest/Raid actions
            val needToChangeConfigs = when (actionConfig) {
                is QuestActionConfig -> actionConfig.dungeonTargets.filter { it.enabled }.size > 1
                is RaidActionConfig -> actionConfig.raidTargets.filter { it.enabled }.size > 1
                else -> true // For other action types, always assume we need to change configs
            }

            // Check if rerun button is available
            val rerunButtonPath = "templates/ui/rerun.png"
            val rerunAvailable = File(rerunButtonPath).exists() && 
                                 bot.findTemplate(rerunButtonPath, verbose = false) != null

            // For Quest/Raid actions with single config, the monitor function handles rerun
            // For Quest/Raid actions with multiple configs or other actions, we need to click town button
            if (!supportsRerun || needToChangeConfigs) {
                if (supportsRerun && needToChangeConfigs && rerunAvailable) {
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

                    if (actionData.hasReachedMaxRunCount()) {
                        println("Action '$actionName' has reached its run count limit (${actionData.runCount}/${actionData.maxRunCount}).")
                    }
                } else {
                    println("Failed to click town button. Continuing with next action.")
                }
            }
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
