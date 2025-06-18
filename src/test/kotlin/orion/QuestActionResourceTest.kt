package orion

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import orion.actions.QuestAction

/**
 * Test class for QuestAction resource depletion behavior
 * 
 * This test verifies that the QuestAction.hasResourcesAvailable method
 * correctly simulates resource depletion after 3 checks, regardless of
 * the repeatCount value in the configuration.
 */
class QuestActionResourceTest {

    private lateinit var questAction: QuestAction
    private lateinit var bot: Bot
    
    @BeforeEach
    fun setup() {
        questAction = QuestAction()
        
        // Create a simple BotConfig for testing
        val config = BotConfig(
            configId = "test-config",
            configName = "Test Config",
            characterId = "test-character",
            actionSequence = listOf("Quest"),
            actionConfigs = mapOf()
        )
        
        // Create a mock Bot with the config
        bot = Bot(config)
    }
    
    @Test
    fun testResourceDepletionWithZeroRepeatCount() {
        // Create a QuestActionConfig with repeatCount = 0
        val questConfig = QuestActionConfig(
            enabled = true,
            repeatCount = 0
        )
        
        // First check should return true
        assertTrue(questAction.hasResourcesAvailable(bot, questConfig), 
            "First resource check should return true")
        
        // Second check should return true
        assertTrue(questAction.hasResourcesAvailable(bot, questConfig), 
            "Second resource check should return true")
        
        // Third check should return false (resources depleted)
        assertFalse(questAction.hasResourcesAvailable(bot, questConfig), 
            "Third resource check should return false (resources depleted)")
        
        // Fourth check should return true again (counter reset)
        assertTrue(questAction.hasResourcesAvailable(bot, questConfig), 
            "Fourth resource check should return true (counter reset)")
    }
    
    @Test
    fun testResourceDepletionWithNonZeroRepeatCount() {
        // Create a QuestActionConfig with repeatCount > 0
        val questConfig = QuestActionConfig(
            enabled = true,
            repeatCount = 5
        )
        
        // First check should return true
        assertTrue(questAction.hasResourcesAvailable(bot, questConfig), 
            "First resource check should return true")
        
        // Second check should return true
        assertTrue(questAction.hasResourcesAvailable(bot, questConfig), 
            "Second resource check should return true")
        
        // Third check should return false (resources depleted), regardless of repeatCount
        assertFalse(questAction.hasResourcesAvailable(bot, questConfig), 
            "Third resource check should return false (resources depleted)")
        
        // Fourth check should return true again (counter reset)
        assertTrue(questAction.hasResourcesAvailable(bot, questConfig), 
            "Fourth resource check should return true (counter reset)")
    }
}