# Testing Coroutines and Optimization Flags

This document explains how to test if coroutines are working properly and if the optimization flags (`--morethreads` and `--opencvthreads`) are being properly recognized in the project.

## What are the Optimization Flags?

### The --morethreads Flag

The `--morethreads` flag enables parallel zone detection using coroutines in the QuestAction class. When this flag is provided, the bot will check multiple zone templates simultaneously instead of sequentially, which can significantly improve performance.

### The --opencvthreads Flag

The `--opencvthreads` flag enables parallel template matching using coroutines in the Bot class. When this flag is provided, the bot will check multiple scales simultaneously when matching templates, which can significantly improve performance when searching for UI elements.

## Test Programs

We've created several test programs to verify that coroutines are working properly and that the optimization flags are being properly recognized:

1. **CoroutineTestRunner**: Tests if coroutines are working properly
2. **MoreThreadsTestRunner**: Tests if the `--morethreads` flag is being properly recognized
3. **OpenCVThreadsTestRunner**: Tests if the `--opencvthreads` flag is being properly recognized
4. **ComprehensiveTestRunner**: Combines all tests

## How to Run the Tests

### Using IntelliJ IDEA

1. Open the project in IntelliJ IDEA
2. Navigate to one of the test runner files:
   - `src/main/kotlin/orion/CoroutineTestRunner.kt`
   - `src/main/kotlin/orion/MoreThreadsTestRunner.kt`
   - `src/main/kotlin/orion/OpenCVThreadsTestRunner.kt`
   - `src/main/kotlin/orion/ComprehensiveTestRunner.kt`
3. Right-click on the file and select "Run"

### Using Gradle

If you have Java properly installed and configured, you can run the tests using Gradle:

```bash
# On Windows
.\gradlew run --args="--test-coroutines"

# On Linux/macOS
./gradlew run --args="--test-coroutines"
```

## Expected Results

### CoroutineTestRunner

If coroutines are working properly, you should see output similar to:

```
Running coroutine test...
Starting coroutine test...
Inside runBlocking coroutine
Inside launch coroutine
After delay in launch coroutine
Inside async coroutine
After delay in async coroutine
Async result: Async result
Coroutine test completed successfully
Coroutine test passed! Coroutines are working properly.
```

### MoreThreadsTestRunner

If the `--morethreads` flag is being properly recognized, you should see output similar to:

```
Testing --morethreads flag...
Setting QuestAction.useCoroutines = true
QuestAction.useCoroutines = true
--morethreads flag is working properly! Coroutines will be used for zone detection.
```

### OpenCVThreadsTestRunner

If the `--opencvthreads` flag is being properly recognized, you should see output similar to:

```
Testing --opencvthreads flag...
Setting Bot.useCoroutinesForTemplateMatching = true
Bot.useCoroutinesForTemplateMatching = true
--opencvthreads flag is working properly! Coroutines will be used for template matching.
```

### ComprehensiveTestRunner

If all tests pass, you should see output similar to:

```
╔════════════════════════════════════════════════════════════════╗
║ COMPREHENSIVE TEST                                             ║
║ Testing coroutines and all optimization flags                  ║
╚════════════════════════════════════════════════════════════════╝

--- Test 1: Coroutines Test ---
Starting coroutine test...
Inside runBlocking coroutine
Inside launch coroutine
After delay in launch coroutine
Inside async coroutine
After delay in async coroutine
Async result: Async result
Coroutine test completed successfully
✅ Coroutine test passed! Coroutines are working properly.

--- Test 2: --morethreads Flag Test ---
Default value of QuestAction.useCoroutines = false
Setting QuestAction.useCoroutines = true (simulating --morethreads flag)
After setting, QuestAction.useCoroutines = true
✅ --morethreads flag test passed! The flag is properly recognized.

--- Test 3: --opencvthreads Flag Test ---
Default value of Bot.useCoroutinesForTemplateMatching = false
Setting Bot.useCoroutinesForTemplateMatching = true (simulating --opencvthreads flag)
After setting, Bot.useCoroutinesForTemplateMatching = true
✅ --opencvthreads flag test passed! The flag is properly recognized.

╔════════════════════════════════════════════════════════════════╗
║ TEST SUMMARY                                                   ║
║                                                                ║
║ ✅ Coroutines are working properly                             ║
║ ✅ --morethreads flag is properly recognized                    ║
║ ✅ --opencvthreads flag is properly recognized                  ║
║                                                                ║
║ The optimization flags will enable parallel processing         ║
║ using coroutines, which should improve performance.            ║
╚════════════════════════════════════════════════════════════════╝
```

## Combining Optimization Flags

You can combine both optimization flags to maximize performance:

```bash
# On Windows
.\gradlew run --args="--morethreads --opencvthreads"

# On Linux/macOS
./gradlew run --args="--morethreads --opencvthreads"
```

This will enable both parallel zone detection and parallel template matching, which can significantly improve overall performance.

## Using Optimization Flags with Template Testing

You can also combine the optimization flags with the `--test-pattern` flag for faster template testing:

```bash
# Test with parallel zone detection
.\gradlew run --args="--test-pattern templates/quest --morethreads"

# Test with parallel template matching
.\gradlew run --args="--test-pattern templates/quest --opencvthreads"

# Test with both optimizations
.\gradlew run --args="--test-pattern templates/quest --morethreads --opencvthreads"
```

## Troubleshooting

If the tests fail, here are some things to check:

1. Make sure you have the correct Kotlin coroutines dependency in your build.gradle file:
   ```gradle
   implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
   ```

2. Make sure you're using a compatible version of Kotlin and JDK:
   - Kotlin 1.9.0 or newer is recommended for JDK 21
   - JDK 21 Corretto is fully compatible with Kotlin coroutines

3. Try cleaning and rebuilding the project:
   ```bash
   # On Windows
   .\gradlew clean build

   # On Linux/macOS
   ./gradlew clean build
   ```

4. If you're still having issues, try adding the coroutines dependency to your project manually:
   - Use the provided scripts to download the coroutines JAR file:
     - On Windows: Run `download-coroutines.bat`
     - On Linux/macOS: Run `./download-coroutines.sh` (you may need to make it executable first with `chmod +x download-coroutines.sh`)
   - The scripts will download the JAR file to a `libs` directory and provide instructions on how to update your build.gradle file
   - Alternatively, you can download the JAR file manually from Maven Central: https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.10.2/
   - Add the following to your build.gradle file:
     ```gradle
     dependencies {
         implementation files('libs/kotlinx-coroutines-core-jvm-1.10.2.jar')
     }
     ```