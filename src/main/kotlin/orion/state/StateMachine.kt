package orion.state

/**
 * A state machine implementation for managing bot states and transitions.
 * 
 * @param initialState The initial state of the state machine (default is Idle)
 * @param initialData Optional data to pass to the initial state handler
 */
class StateMachine(initialState: BotState = BotState.Idle, initialData: Any? = null) {
    /** The current state of the state machine */
    private var currentState: BotState = initialState

    /** Map of valid transitions from state+event to new state */
    private val transitions = mutableMapOf<Pair<BotState, String>, BotState>()

    /** Map of state handlers that are executed when entering a state */
    private val stateHandlers = mutableMapOf<BotState, (Any?) -> Unit>()

    // Store the initial data for use when the handler is added
    private var storedInitialData: Any? = initialData

    /** 
     * Adds a valid transition to the state machine.
     * 
     * @param fromState The state from which the transition can occur
     * @param event The event that triggers the transition
     * @param toState The state to transition to
     */
    fun addTransition(fromState: BotState, event: String, toState: BotState) {
        transitions[Pair(fromState, event)] = toState
    }

    /**
     * Adds a handler for a specific state.
     * 
     * @param state The state to add a handler for
     * @param handler The handler function to execute when entering the state
     */
    fun addStateHandler(state: BotState, handler: (Any?) -> Unit) {
        stateHandlers[state] = handler

        // If this is the handler for the current state, execute it immediately
        if (state == currentState) {
            handler(storedInitialData)
        }
    }

    /**
     * Gets the current state of the state machine.
     * 
     * @return The current state
     */
    fun getCurrentState(): BotState = currentState

    /**
     * Processes an event and transitions to a new state if a valid transition exists.
     * 
     * @param event The event to process
     * @param data Optional data to pass to the state handler
     * @return True if the transition was successful, false otherwise
     */
    fun processEvent(event: String, data: Any? = null): Boolean {
        val transition = transitions[Pair(currentState, event)]
        if (transition != null) {
            val oldState = currentState
            currentState = transition
            println("State transition: $oldState -> $currentState (Event: $event)")

            // Execute the handler for the new state
            stateHandlers[currentState]?.invoke(data)
            return true
        }
        println("No valid transition found from state $currentState for event '$event'")
        return false
    }

    /**
     * Checks if a transition is valid from the current state.
     * 
     * @param event The event to check
     * @return True if the transition is valid, false otherwise
     */
    fun canProcessEvent(event: String): Boolean {
        return transitions.containsKey(Pair(currentState, event))
    }

    /**
     * Resets the state machine to the initial state.
     * 
     * @param initialState The state to reset to (default is Idle)
     * @param data Optional data to pass to the state handler
     */
    fun reset(initialState: BotState = BotState.Idle, data: Any? = null) {
        currentState = initialState
        println("State machine reset to $initialState")

        // Execute the handler for the new state if one exists
        stateHandlers[currentState]?.invoke(data)
    }
}
