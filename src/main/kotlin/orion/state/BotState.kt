package orion.state

/**
 * Represents the possible states of the bot during operation.
 * This sealed class hierarchy defines all valid states for the state machine.
 */
sealed class BotState {
    /** Bot is idle, waiting for an action to be started */
    object Idle : BotState()
    
    /** Bot is in the process of starting an action */
    object Starting : BotState()
    
    /** Bot is actively running an action */
    object Running : BotState()
    
    /** Bot is rerunning the current action */
    object Rerunning : BotState()
    
    /** Bot has detected that it's out of resources for the current action */
    object OutOfResources : BotState()
    
    /** Bot has detected that the player character has died */
    object PlayerDead : BotState()
    
    /** Bot has detected a disconnection from the game */
    object Disconnected : BotState()
    
    /** Bot is attempting to reconnect to the game */
    object Reconnecting : BotState()
    
    /** The current action has been completed successfully */
    object Completed : BotState()
    
    /** The current action has failed */
    object Failed : BotState()
    
    /** Returns a string representation of the state */
    override fun toString(): String = this::class.simpleName ?: "Unknown"
}