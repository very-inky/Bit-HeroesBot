package orion.state

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import java.io.ByteArrayOutputStream
import java.io.PrintStream

/**
 * Tests for the StateMachine class.
 */
class StateMachineTest {
    
    /**
     * Test that the state machine initializes with the correct state.
     */
    @Test
    fun testInitialState() {
        val stateMachine = StateMachine()
        assertEquals(BotState.Idle, stateMachine.getCurrentState())
        
        val customStateMachine = StateMachine(BotState.Running)
        assertEquals(BotState.Running, customStateMachine.getCurrentState())
    }
    
    /**
     * Test that the state machine transitions correctly.
     */
    @Test
    fun testStateTransition() {
        val stateMachine = StateMachine()
        
        // Add transitions
        stateMachine.addTransition(BotState.Idle, "start", BotState.Running)
        stateMachine.addTransition(BotState.Running, "complete", BotState.Completed)
        
        // Process events
        assertTrue(stateMachine.processEvent("start"))
        assertEquals(BotState.Running, stateMachine.getCurrentState())
        
        assertTrue(stateMachine.processEvent("complete"))
        assertEquals(BotState.Completed, stateMachine.getCurrentState())
    }
    
    /**
     * Test that the state machine rejects invalid transitions.
     */
    @Test
    fun testInvalidTransition() {
        val stateMachine = StateMachine()
        
        // Add transitions
        stateMachine.addTransition(BotState.Idle, "start", BotState.Running)
        
        // Try an invalid event
        assertFalse(stateMachine.processEvent("invalid_event"))
        assertEquals(BotState.Idle, stateMachine.getCurrentState())
        
        // Try a valid event from the wrong state
        assertTrue(stateMachine.processEvent("start"))
        assertEquals(BotState.Running, stateMachine.getCurrentState())
        
        assertFalse(stateMachine.processEvent("start"))
        assertEquals(BotState.Running, stateMachine.getCurrentState())
    }
    
    /**
     * Test that state handlers are executed.
     */
    @Test
    fun testStateHandlers() {
        val stateMachine = StateMachine()
        
        // Track handler execution
        var idleHandlerExecuted = false
        var runningHandlerExecuted = false
        var handlerData: String? = null
        
        // Add transitions and handlers
        stateMachine.addTransition(BotState.Idle, "start", BotState.Running)
        
        stateMachine.addStateHandler(BotState.Idle) { data ->
            idleHandlerExecuted = true
        }
        
        stateMachine.addStateHandler(BotState.Running) { data ->
            runningHandlerExecuted = true
            handlerData = data as? String
        }
        
        // Initial state handler should be executed
        assertTrue(idleHandlerExecuted)
        assertFalse(runningHandlerExecuted)
        
        // Process event with data
        stateMachine.processEvent("start", "test_data")
        
        // Running state handler should be executed with data
        assertTrue(runningHandlerExecuted)
        assertEquals("test_data", handlerData)
    }
    
    /**
     * Test that the state machine can be reset.
     */
    @Test
    fun testReset() {
        val stateMachine = StateMachine()
        
        // Add transitions
        stateMachine.addTransition(BotState.Idle, "start", BotState.Running)
        stateMachine.addTransition(BotState.Running, "complete", BotState.Completed)
        
        // Process events
        stateMachine.processEvent("start")
        assertEquals(BotState.Running, stateMachine.getCurrentState())
        
        // Reset to default state (Idle)
        stateMachine.reset()
        assertEquals(BotState.Idle, stateMachine.getCurrentState())
        
        // Reset to specific state
        stateMachine.reset(BotState.Completed)
        assertEquals(BotState.Completed, stateMachine.getCurrentState())
    }
    
    /**
     * Test that the canProcessEvent method works correctly.
     */
    @Test
    fun testCanProcessEvent() {
        val stateMachine = StateMachine()
        
        // Add transitions
        stateMachine.addTransition(BotState.Idle, "start", BotState.Running)
        stateMachine.addTransition(BotState.Running, "complete", BotState.Completed)
        
        // Check valid and invalid events
        assertTrue(stateMachine.canProcessEvent("start"))
        assertFalse(stateMachine.canProcessEvent("complete"))
        assertFalse(stateMachine.canProcessEvent("invalid_event"))
        
        // Process event and check again
        stateMachine.processEvent("start")
        assertFalse(stateMachine.canProcessEvent("start"))
        assertTrue(stateMachine.canProcessEvent("complete"))
    }
}