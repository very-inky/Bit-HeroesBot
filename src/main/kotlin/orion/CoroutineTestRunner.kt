package orion

fun main() {
    println("Running coroutine test...")
    val result = CoroutineTest.runTest()
    if (result) {
        println("Coroutine test passed! Coroutines are working properly.")
    } else {
        println("Coroutine test failed! Coroutines are NOT working properly.")
    }
}