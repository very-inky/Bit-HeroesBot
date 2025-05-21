package orion

import orion.actions.*

// Imports for Bot, BotConfig, GameAction, ActionConfig from the 'orion' package are not needed
// if ActionManager is correctly declared in 'package orion'.

class ActionManager(private val bot: Bot, private val config: BotConfig) {

    fun runActionSequence() {
        println("ActionManager: Starting action sequence for ${config.characterName} using config '${config.configId}'.")
        println("Action sequence: ${config.actionSequence.joinToString(" -> ")}")

        for (actionName in config.actionSequence) {
            val actionConfig = config.actionConfigs[actionName]

            if (actionConfig == null) {
                println("Warning: No configuration found for action '$actionName'. Skipping.")
                continue
            }

            if (!actionConfig.enabled) {
                println("Action '$actionName' is disabled in configuration. Skipping.")
                continue
            }

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

            actionHandler?.let {
                try {
                    val success = it.execute(bot, actionConfig)
                    if (success) {
                        println("Action '$actionName' completed successfully.")
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
        }
        println("\nActionManager: Finished processing action sequence for ${config.characterName}.")
    }
}

