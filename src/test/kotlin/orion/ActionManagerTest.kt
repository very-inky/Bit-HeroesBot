package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import java.time.Instant
import java.time.temporal.ChronoUnit
import orion.actions.QuestAction
import orion.actions.RaidAction

/**
 * Test class for ActionManager
 * 
 * Note: These tests focus on the monitoring and resource checking functionality
 * without testing the actual interaction with the Bot class.
 */
class ActionManagerTest {

    private lateinit var bot: Bot
    private lateinit var config: BotConfig
    private lateinit var actionManager: ActionManager
    private lateinit var questAction: QuestAction
    private lateinit var raidAction: RaidAction
    private lateinit var questConfig: QuestActionConfig
    private lateinit var raidConfig: RaidActionConfig

    @BeforeEach
    fun setup() {
        // Create action configs
        questConfig = QuestActionConfig(
            enabled = true,
            repeatCount = 2,
            cooldownDuration = 10
        )

        raidConfig = RaidActionConfig(
            enabled = true,
            runCount = 3,
            cooldownDuration = 15
        )

        // Create a BotConfig with the action configs
        config = BotConfig(
            configId = "test-config",
            configName = "Test Config",
            characterId = "test-character",
            actionSequence = listOf("Quest", "Raid"),
            actionConfigs = mapOf(
                "Quest" to questConfig,
                "Raid" to raidConfig
            )
        )

        // Create a mock Bot with the config
        bot = Bot(config)

        // Create the ActionManager
        actionManager = ActionManager(bot, config)

        // Create action handlers
        questAction = QuestAction()
        raidAction = RaidAction()
    }

    @Test
    fun testActionMonitorWithEnabledAction() {
        // Test that an enabled action with no cooldown and under run limit can be executed
        val result = actionManager.actionMonitor("Quest", questAction, questConfig, false)
        assertTrue(result.first, "Action should be executable")
        assertEquals("", result.second, "No reason should be provided for executable action")
    }

    @Test
    fun testActionMonitorWithDisabledAction() {
        // Disable the action
        val disabledConfig = QuestActionConfig(
            enabled = false,
            repeatCount = 2
        )

        // Test that a disabled action cannot be executed
        val result = actionManager.actionMonitor("Quest", questAction, disabledConfig, false)
        assertFalse(result.first, "Disabled action should not be executable")
        assertTrue(result.second.contains("disabled"), "Reason should mention that action is disabled")
    }

    @Test
    fun testActionMonitorWithRunCountLimit() {
        // Set run count to the limit using the extension function
        actionManager.setRunCountForTest("Quest", 2)

        // Test that an action that has reached its run count limit cannot be executed
        val result = actionManager.actionMonitor("Quest", questAction, questConfig, false)
        assertFalse(result.first, "Action at run count limit should not be executable")
        assertTrue(result.second.contains("run count limit"), "Reason should mention run count limit")
    }

    @Test
    fun testActionMonitorWithResourceCheck() {
        // Create a mock GameAction that always returns false for hasResourcesAvailable
        val mockAction = object : GameAction {
            override fun execute(bot: Bot, config: ActionConfig): Boolean = true
            override fun hasResourcesAvailable(bot: Bot, config: ActionConfig): Boolean = false
        }

        // Test that an action with no resources cannot be executed
        val result = actionManager.actionMonitor("Quest", mockAction, questConfig, true)
        assertFalse(result.first, "Action with no resources should not be executable")
        assertTrue(result.second.contains("out of resources"), "Reason should mention resource depletion")
    }

    @Test
    fun testIsOutOfResources() {
        // Create a test method to access private isOutOfResources method
        val isOutOfResourcesMethod = ActionManager::class.java.getDeclaredMethod("isOutOfResources", GameAction::class.java, ActionConfig::class.java, String::class.java)
        isOutOfResourcesMethod.isAccessible = true

        // Create a mock GameAction that always returns false for hasResourcesAvailable
        val mockAction = object : GameAction {
            override fun execute(bot: Bot, config: ActionConfig): Boolean = true
            override fun hasResourcesAvailable(bot: Bot, config: ActionConfig): Boolean = false
        }

        // Test that isOutOfResources returns true when resources are not available
        val result = isOutOfResourcesMethod.invoke(actionManager, mockAction, questConfig, "Quest") as Boolean
        assertTrue(result, "isOutOfResources should return true when resources are not available")

        // Create a mock GameAction that always returns true for hasResourcesAvailable
        val mockActionWithResources = object : GameAction {
            override fun execute(bot: Bot, config: ActionConfig): Boolean = true
            override fun hasResourcesAvailable(bot: Bot, config: ActionConfig): Boolean = true
        }

        // Test that isOutOfResources returns false when resources are available
        val resultWithResources = isOutOfResourcesMethod.invoke(actionManager, mockActionWithResources, questConfig, "Quest") as Boolean
        assertFalse(resultWithResources, "isOutOfResources should return false when resources are available")
    }
}
