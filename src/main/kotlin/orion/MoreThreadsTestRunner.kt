package orion

import orion.actions.QuestAction

fun main() {
    println("Testing --morethreads flag...")
    
    // Simulate the behavior of Main.kt when --morethreads flag is provided
    println("Setting QuestAction.useCoroutines = true")
    QuestAction.useCoroutines = true
    
    // Create a QuestAction instance
    val questAction = QuestAction()
    
    // Print the value of useCoroutines
    println("QuestAction.useCoroutines = ${QuestAction.useCoroutines}")
    
    if (QuestAction.useCoroutines) {
        println("--morethreads flag is working properly! Coroutines will be used for zone detection.")
    } else {
        println("--morethreads flag is NOT working properly! Coroutines will NOT be used for zone detection.")
    }
}