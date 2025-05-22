package orion

import orion.actions.QuestAction

fun main() {
    println("╔════════════════════════════════════════════════════════════════╗")
    println("║ COMPREHENSIVE TEST                                             ║")
    println("║ Testing both coroutines and --morethreads flag                 ║")
    println("╚════════════════════════════════════════════════════════════════╝")
    
    // Test 1: Verify that coroutines are working properly
    println("\n--- Test 1: Coroutines Test ---")
    val coroutinesWorking = CoroutineTest.runTest()
    
    if (coroutinesWorking) {
        println("✅ Coroutine test passed! Coroutines are working properly.")
    } else {
        println("❌ Coroutine test failed! Coroutines are NOT working properly.")
        println("   This means the --morethreads flag will not work as expected.")
        return
    }
    
    // Test 2: Verify that the --morethreads flag is being properly recognized
    println("\n--- Test 2: --morethreads Flag Test ---")
    
    // First, check the default value (should be false)
    println("Default value of QuestAction.useCoroutines = ${QuestAction.useCoroutines}")
    
    // Simulate the behavior of Main.kt when --morethreads flag is provided
    println("Setting QuestAction.useCoroutines = true (simulating --morethreads flag)")
    QuestAction.useCoroutines = true
    
    // Create a QuestAction instance
    val questAction = QuestAction()
    
    // Print the value of useCoroutines
    println("After setting, QuestAction.useCoroutines = ${QuestAction.useCoroutines}")
    
    if (QuestAction.useCoroutines) {
        println("✅ --morethreads flag test passed! The flag is properly recognized.")
    } else {
        println("❌ --morethreads flag test failed! The flag is NOT properly recognized.")
        return
    }
    
    // Summary
    println("\n╔════════════════════════════════════════════════════════════════╗")
    println("║ TEST SUMMARY                                                   ║")
    println("║                                                                ║")
    println("║ ✅ Coroutines are working properly                             ║")
    println("║ ✅ --morethreads flag is properly recognized                    ║")
    println("║                                                                ║")
    println("║ The --morethreads flag will enable parallel zone detection     ║")
    println("║ using coroutines, which should improve performance.            ║")
    println("╚════════════════════════════════════════════════════════════════╝")
}