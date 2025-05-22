package orion

import kotlinx.coroutines.*

/**
 * A simple test class to verify that coroutines are working properly.
 */
object CoroutineTest {
    /**
     * Runs a simple coroutine test.
     * 
     * @return True if coroutines are working properly, false otherwise.
     */
    fun runTest(): Boolean {
        println("Starting coroutine test...")
        
        try {
            // Run a simple coroutine
            runBlocking {
                println("Inside runBlocking coroutine")
                
                // Launch a coroutine in the background
                val job = launch {
                    println("Inside launch coroutine")
                    delay(100) // Suspend for 100ms
                    println("After delay in launch coroutine")
                }
                
                // Wait for the job to complete
                job.join()
                
                // Use async/await
                val deferred = async {
                    println("Inside async coroutine")
                    delay(100) // Suspend for 100ms
                    println("After delay in async coroutine")
                    "Async result"
                }
                
                // Wait for the result
                val result = deferred.await()
                println("Async result: $result")
            }
            
            println("Coroutine test completed successfully")
            return true
        } catch (e: Exception) {
            println("Coroutine test failed: ${e.message}")
            e.printStackTrace()
            return false
        }
    }
}