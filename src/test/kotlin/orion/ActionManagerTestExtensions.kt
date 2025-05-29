package orion

/**
 * Extension functions for testing ActionManager
 */

/**
 * Sets the run count for an action for testing purposes.
 * This is used to test the run count limit functionality.
 * 
 * @param actionName The name of the action.
 * @param count The run count to set.
 */
fun ActionManager.setRunCountForTest(actionName: String, count: Int) {
    val field = ActionManager::class.java.getDeclaredField("actionRunCounts")
    field.isAccessible = true
    val actionRunCounts = field.get(this) as MutableMap<String, Int>
    actionRunCounts[actionName] = count
}