package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Timeout
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.concurrent.TimeUnit
import orion.state.BotState
import orion.state.StateMachine
import java.lang.reflect.Field

/**
 * Test class for ActionManager idle state transition
 * 
 * This test verifies that the ActionManager correctly transitions to the idle state
 * when all actions are on cooldown, and periodically checks for available actions.
 */
class ActionManagerIdleStateTest {

    private lateinit var bot: Bot
    private lateinit var config: BotConfig
    private lateinit var actionManager: ActionManager
    private lateinit var questConfig: QuestActionConfig
    private lateinit var raidConfig: RaidActionConfig
    private lateinit var stateMachine: StateMachine

    @BeforeEach
    fun setup() {
        // Create action configs
        questConfig = QuestActionConfig(
            enabled = true,
            repeatCount = 2,
            cooldownDuration = 1 // Short cooldown for testing
        )

        raidConfig = RaidActionConfig(
            enabled = true,
            runCount = 3,
            cooldownDuration = 1 // Short cooldown for testing
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

        // Get access to the stateMachine field
        val stateMachineField = ActionManager::class.java.getDeclaredField("stateMachine")
        stateMachineField.isAccessible = true
        stateMachine = stateMachineField.get(actionManager) as StateMachine
    }

    /**
     * Test that the ActionManager correctly sets actions on cooldown
     * and can detect when they come off cooldown.
     */
    @Test
    fun testActionCooldownAndRecovery() {
        // Set both actions on cooldown
        setCooldownForTest("Quest", 1)
        setCooldownForTest("Raid", 1)

        // Verify both actions are on cooldown
        val questResult = actionManager.actionMonitor("Quest", null, questConfig, false)
        assertFalse(questResult.first, "Quest action should be on cooldown")
        assertTrue(questResult.second.contains("cooldown"), "Reason should mention cooldown")

        val raidResult = actionManager.actionMonitor("Raid", null, raidConfig, false)
        assertFalse(raidResult.first, "Raid action should be on cooldown")
        assertTrue(raidResult.second.contains("cooldown"), "Reason should mention cooldown")

        // Simulate cooldown expiration by setting cooldowns to a past time
        val field = ActionManager::class.java.getDeclaredField("actionCooldowns")
        field.isAccessible = true
        val actionCooldowns = field.get(actionManager) as MutableMap<String, Instant>
        actionCooldowns["Quest"] = Instant.now().minus(1, ChronoUnit.MINUTES)
        actionCooldowns["Raid"] = Instant.now().minus(1, ChronoUnit.MINUTES)

        // Verify both actions are now available
        val questResultAfter = actionManager.actionMonitor("Quest", null, questConfig, false)
        assertTrue(questResultAfter.first, "Quest action should be available after cooldown")

        val raidResultAfter = actionManager.actionMonitor("Raid", null, raidConfig, false)
        assertTrue(raidResultAfter.first, "Raid action should be available after cooldown")
    }

    /**
     * Test that the ActionManager correctly transitions to the idle state
     * when all actions are on cooldown.
     */
    @Test
    @Timeout(value = 10, unit = TimeUnit.SECONDS) // Limit test execution time
    fun testIdleStateTransition() {
        // Create a test thread to run the action sequence
        val thread = Thread {
            try {
                // This would normally run indefinitely, but we'll interrupt it after our test
                actionManager.runActionSequence()
            } catch (e: InterruptedException) {
                // Expected when we interrupt the thread
            }
        }

        // Start the thread
        thread.start()

        // Set both actions on cooldown
        setCooldownForTest("Quest", 5)
        setCooldownForTest("Raid", 5)

        // Wait a moment for the idle state transition to occur
        Thread.sleep(2000)

        // Verify the state machine is in the Idle state
        assertEquals(BotState.Idle, stateMachine.getCurrentState(), 
            "State machine should be in Idle state when all actions are on cooldown")

        // Interrupt the thread to stop the action sequence
        thread.interrupt()

        // Wait for the thread to terminate
        thread.join(5000)

        // Verify the thread has terminated
        assertFalse(thread.isAlive, "Action sequence thread should have terminated")
    }

    /**
     * Sets the cooldown for an action for testing purposes.
     * 
     * @param actionName The name of the action.
     * @param minutes The cooldown duration in minutes.
     */
    private fun setCooldownForTest(actionName: String, minutes: Int) {
        val field = ActionManager::class.java.getDeclaredField("actionCooldowns")
        field.isAccessible = true
        val actionCooldowns = field.get(actionManager) as MutableMap<String, Instant>
        actionCooldowns[actionName] = Instant.now().plus(minutes.toLong(), ChronoUnit.MINUTES)
    }
}
