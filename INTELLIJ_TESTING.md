# Running Tests in IntelliJ IDEA

This guide provides instructions for running tests for the Orion Bot directly in IntelliJ IDEA.

## Prerequisites

1. Make sure you have IntelliJ IDEA installed. The Community Edition is sufficient for running tests.
2. Ensure you have the Kotlin plugin installed and enabled in IntelliJ IDEA.
3. Make sure you have Java 23 or higher installed and configured in IntelliJ IDEA.

## Opening the Project

1. Open IntelliJ IDEA.
2. Select "Open" from the welcome screen or "File > Open" from the menu.
3. Navigate to the Orion Bot project directory and select it.
4. Wait for IntelliJ IDEA to import the project and resolve dependencies.

## Running All Tests

To run all tests in the project:

1. Right-click on the `src/test/kotlin` directory in the Project view.
2. Select "Run 'All Tests'" from the context menu.
3. IntelliJ IDEA will compile the project and run all tests.
4. The test results will be displayed in the "Run" tool window.

## Running a Specific Test Class

To run a specific test class:

1. Navigate to the test class in the Project view or open the test file.
2. Right-click on the class name in the editor or in the Project view.
3. Select "Run 'TestClassName'" from the context menu.
4. The test results will be displayed in the "Run" tool window.

## Running a Specific Test Method

To run a specific test method:

1. Open the test file containing the method.
2. Right-click on the test method name in the editor.
3. Select "Run 'TestMethodName'" from the context menu.
4. The test results will be displayed in the "Run" tool window.

## Running Coroutine Tests

To run the coroutine tests specifically:

1. Navigate to the `src/test/kotlin/orion/CoroutineTest.kt` file.
2. Right-click on the file in the Project view or on the class name in the editor.
3. Select "Run 'CoroutineTest'" from the context menu.
4. The test results will be displayed in the "Run" tool window.

Alternatively, you can use the Gradle task:

1. Open the Gradle tool window (View > Tool Windows > Gradle).
2. Navigate to Tasks > verification > testCoroutines.
3. Double-click on the "testCoroutines" task to run it.

## Creating a Run Configuration

For tests you run frequently, you can create a permanent run configuration:

1. Select "Run > Edit Configurations" from the menu.
2. Click the "+" button and select "JUnit" from the dropdown.
3. Configure the test:
   - Name: Give your configuration a descriptive name
   - Test kind: Choose "Class" for a test class or "Method" for a specific test method
   - Class/Method: Select the test class or method to run
   - Use classpath of module: Select the main module of the project
4. Click "OK" to save the configuration.
5. You can now run this configuration from the run configuration dropdown in the toolbar.

## Debugging Tests

To debug a test:

1. Set breakpoints in your code by clicking in the gutter next to the line numbers.
2. Right-click on the test class or method and select "Debug" instead of "Run".
3. The test will run in debug mode and pause at your breakpoints.
4. Use the Debug tool window to inspect variables, step through code, etc.

## Viewing Test Results

After running tests, you can view detailed results:

1. The "Run" tool window shows a summary of test results.
2. Green checkmarks indicate passed tests, red X marks indicate failed tests.
3. For failed tests, you can see the error message and stack trace.
4. You can navigate to the source code of a test by double-clicking on it in the results.

## Troubleshooting

### Tests Not Running

If tests are not running or are failing to compile:

1. Make sure the Kotlin plugin is installed and enabled.
2. Ensure you have the correct JDK configured (Java 23 or higher).
3. Try rebuilding the project (Build > Rebuild Project).
4. Check that all dependencies are resolved correctly.
5. Verify that the test classes are in the correct source set (`src/test/kotlin`).

### Coroutine Tests Failing

If coroutine tests are failing:

1. Make sure you have the kotlinx-coroutines-core dependency in your build.gradle file.
2. Ensure you're using a compatible version of Kotlin and JDK.
3. Try cleaning and rebuilding the project.
4. Check the error messages for specific issues.

## Additional Resources

- [IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/getting-started.html)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Kotlin Testing Documentation](https://kotlinlang.org/docs/jvm-test-using-junit.html)
- [Kotlin Coroutines Testing](https://kotlinlang.org/docs/coroutines-and-channels.html#testing-coroutines)