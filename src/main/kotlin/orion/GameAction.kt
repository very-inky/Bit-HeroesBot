package orion

import orion.state.BotState

interface GameAction {
    /**
     * Executes the specific game action.
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return True if the action was started successfully, false otherwise.
     */
    fun execute(bot: Bot, config: ActionConfig): Boolean

    /**
     * Checks if the action has resources available to execute.
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return True if resources are available, false if depleted.
     */
    fun hasResourcesAvailable(bot: Bot, config: ActionConfig): Boolean = true

    /**
     * Checks the current state of the action.
     * @param bot The Bot instance to use for interacting with the game.
     * @return The current state of the action.
     */
    fun checkState(bot: Bot): BotState {
        // Default implementation can check for common conditions
        return BotState.Running
    }
}
