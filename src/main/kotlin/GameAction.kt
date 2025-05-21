package orion

interface GameAction {
    /**
     * Executes the specific game action.
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return True if the action was completed successfully, false otherwise.
     */
    fun execute(bot: Bot, config: ActionConfig): Boolean
}

