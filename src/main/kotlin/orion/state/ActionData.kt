package orion.state

import orion.ActionConfig
import orion.Bot
import orion.GameAction

/**
 * Data class to encapsulate information about an action being executed.
 * This class is used to pass data between state handlers in the state machine.
 *
 * @property actionName The name of the action being executed
 * @property actionHandler The handler for the action
 * @property actionConfig The configuration for the action
 * @property bot The bot instance executing the action
 * @property runCount The current run count for the action
 * @property maxRunCount The maximum number of runs allowed for the action (0 for unlimited)
 * @property additionalData Any additional data that might be needed by state handlers
 */
data class ActionData(
    val actionName: String,
    val actionHandler: GameAction,
    val actionConfig: ActionConfig,
    val bot: Bot,
    var runCount: Int = 0,
    val maxRunCount: Int = 0,
    val additionalData: MutableMap<String, Any> = mutableMapOf()
) {
    /**
     * Checks if the action has reached its maximum run count.
     * 
     * @return True if the action has reached its maximum run count, false otherwise
     */
    fun hasReachedMaxRunCount(): Boolean {
        return maxRunCount > 0 && runCount >= maxRunCount
    }
    
    /**
     * Increments the run count for the action.
     */
    fun incrementRunCount() {
        runCount++
    }
    
    /**
     * Gets a value from the additional data map.
     * 
     * @param key The key to get the value for
     * @return The value, or null if the key doesn't exist
     */
    fun <T> getData(key: String): T? {
        @Suppress("UNCHECKED_CAST")
        return additionalData[key] as? T
    }
    
    /**
     * Sets a value in the additional data map.
     * 
     * @param key The key to set the value for
     * @param value The value to set
     */
    fun setData(key: String, value: Any) {
        additionalData[key] = value
    }
}