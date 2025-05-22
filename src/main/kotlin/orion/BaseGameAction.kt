package orion

import java.io.File

/**
 * Base implementation of GameAction that provides common functionality for all game actions.
 * This includes template loading and management.
 */
abstract class BaseGameAction : GameAction {
    /**
     * Loads templates from the directories specified in the action configuration.
     * This method should be called at the beginning of the execute method.
     *
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @return A pair of (common templates, specific templates) loaded from the directories.
     */
    protected fun loadTemplates(bot: Bot, config: ActionConfig): Pair<List<String>, List<String>> {
        val commonTemplates = mutableListOf<String>()
        val specificTemplates = mutableListOf<String>()

        // If directory-based template loading is enabled, load templates from directories
        if (config.useDirectoryBasedTemplates) {
            // Load common templates from directories
            for (directory in config.commonTemplateDirectories) {
                println("Loading common templates from directory: $directory")
                val count = bot.loadTemplatesFromDirectory(directory, true)
                println("Loaded $count templates from $directory")

                // Get the templates from this category
                val categoryTemplates = bot.getTemplatesByCategory(directory.substringAfterLast('/'))
                commonTemplates.addAll(categoryTemplates)
            }

            // Load specific templates from directories
            for (directory in config.specificTemplateDirectories) {
                println("Loading specific templates from directory: $directory")
                val count = bot.loadTemplatesFromDirectory(directory, true)
                println("Loaded $count templates from $directory")

                // Get the templates from this category
                val categoryTemplates = bot.getTemplatesByCategory(directory.substringAfterLast('/'))
                specificTemplates.addAll(categoryTemplates)
            }

            println("Total common templates loaded: ${commonTemplates.size}")
            println("Total specific templates loaded: ${specificTemplates.size}")
        }

        // Add any explicitly specified templates
        commonTemplates.addAll(config.commonActionTemplates)
        specificTemplates.addAll(config.specificTemplates)

        return Pair(commonTemplates.distinct(), specificTemplates.distinct())
    }

    /**
     * Loads specific templates for a target (e.g., a specific dungeon or raid)
     * This method should be called when you need to find templates for a specific target
     * rather than all templates for the action.
     *
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The specific configuration for this action.
     * @param targetName The name or identifier of the target (e.g., dungeon name, raid name).
     * @return A list of template paths that match the target.
     */
    protected fun loadTargetSpecificTemplates(bot: Bot, config: ActionConfig, targetName: String): List<String> {
        val targetTemplates = mutableListOf<String>()

        // First, ensure all templates are loaded
        val (_, allSpecificTemplates) = loadTemplates(bot, config)

        // Filter templates that match the target name
        val matchingTemplates = allSpecificTemplates.filter { templatePath ->
            val templateFileName = File(templatePath).nameWithoutExtension.lowercase()
            templateFileName.contains(targetName.lowercase())
        }

        println("Found ${matchingTemplates.size} templates matching target: $targetName")
        targetTemplates.addAll(matchingTemplates)

        return targetTemplates.distinct()
    }

    /**
     * Attempts to find a template from the provided list without clicking it.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param templates The list of template paths to try.
     * @param description A description of what we're trying to find (for logging).
     * @param maxAttempts The maximum number of attempts to find a template.
     * @return The path of the template that was found, or null if no template was found.
     */
    protected fun findAnyTemplate(
        bot: Bot, 
        templates: List<String>, 
        description: String,
        maxAttempts: Int = 3
    ): String? {
        if (templates.isEmpty()) {
            println("No templates provided to findAnyTemplate for $description")
            return null
        }

        println("Attempting to find $description (${templates.size} templates available)")

        var attempts = 0
        while (attempts < maxAttempts) {
            for (template in templates) {
                val location = bot.findTemplate(template)
                if (location != null) {
                    println("Successfully found template: $template for $description")
                    return template
                }
            }
            attempts++
            if (attempts < maxAttempts) {
                println("Attempt $attempts failed. Waiting before retry...")
                Thread.sleep(1000) // Wait 1 second before retrying
            }
        }

        println("Failed to find any template for $description after $maxAttempts attempts")
        return null
    }

    /**
     * Attempts to find a template from the provided list and click it if found.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param templates The list of template paths to try.
     * @param description A description of what we're trying to find and click (for logging).
     * @param maxAttempts The maximum number of attempts to find a template.
     * @return A Pair containing the template path that was found (or null if none was found) and 
     *         a boolean indicating whether the template was successfully clicked.
     */
    protected fun findAndClickTemplate(
        bot: Bot, 
        templates: List<String>, 
        description: String,
        maxAttempts: Int = 3
    ): Pair<String?, Boolean> {
        if (templates.isEmpty()) {
            println("No templates provided to findAndClickTemplate for $description")
            return Pair(null, false)
        }

        println("Attempting to find and click $description (${templates.size} templates available)")

        var attempts = 0
        while (attempts < maxAttempts) {
            for (template in templates) {
                val location = bot.findTemplate(template)
                if (location != null) {
                    println("Found template: $template for $description")

                    // Now try to click it
                    if (bot.clickOnTemplate(template)) {
                        println("Successfully clicked on template: $template for $description")
                        return Pair(template, true)
                    } else {
                        println("Found template: $template but failed to click it")
                        return Pair(template, false)
                    }
                }
            }
            attempts++
            if (attempts < maxAttempts) {
                println("Attempt $attempts failed. Waiting before retry...")
                Thread.sleep(1000) // Wait 1 second before retrying
            }
        }

        println("Failed to find any template for $description after $maxAttempts attempts")
        return Pair(null, false)
    }

    /**
     * Attempts to find and click on a template from the provided list.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param templates The list of template paths to try.
     * @param description A description of what we're trying to click (for logging).
     * @param maxAttempts The maximum number of attempts to find and click a template.
     * @return True if a template was found and clicked, false otherwise.
     */
    protected fun findAndClickAnyTemplate(
        bot: Bot, 
        templates: List<String>, 
        description: String,
        maxAttempts: Int = 3
    ): Boolean {
        if (templates.isEmpty()) {
            println("No templates provided to findAndClickAnyTemplate for $description")
            return false
        }

        println("Attempting to find and click $description (${templates.size} templates available)")

        var attempts = 0
        while (attempts < maxAttempts) {
            for (template in templates) {
                if (bot.clickOnTemplate(template)) {
                    println("Successfully clicked on template: $template for $description")
                    return true
                }
            }
            attempts++
            if (attempts < maxAttempts) {
                println("Attempt $attempts failed. Waiting before retry...")
                Thread.sleep(1000) // Wait 1 second before retrying
            }
        }

        println("Failed to find and click any template for $description after $maxAttempts attempts")
        return false
    }

    /**
     * Finds and clicks a specific template by name, checking both action-specific and common folders.
     * 
     * @param bot The Bot instance to use for interacting with the game.
     * @param config The action configuration containing template directories.
     * @param templateName The name of the template file to look for (e.g., "questicon.png").
     * @param description A description of what we're trying to click (for logging).
     * @param maxAttempts The maximum number of attempts to find and click the template.
     * @return True if the template was found and clicked, false otherwise.
     */
    protected fun findAndClickSpecificTemplate(
        bot: Bot,
        config: ActionConfig,
        templateName: String,
        description: String,
        maxAttempts: Int = 3
    ): Boolean {
        println("Looking for specific template: $templateName for $description")

        // First, check action-specific directories
        for (directory in config.specificTemplateDirectories) {
            val specificPath = "$directory/$templateName"
            println("Checking action-specific path: $specificPath")

            if (File(specificPath).exists()) {
                println("Found template in action-specific directory: $specificPath")
                if (bot.clickOnTemplate(specificPath)) {
                    println("Successfully clicked on template: $specificPath for $description")
                    return true
                }
            }
        }

        // If not found in action-specific directories, check common directories
        for (directory in config.commonTemplateDirectories) {
            val commonPath = "$directory/$templateName"
            println("Checking common path: $commonPath")

            if (File(commonPath).exists()) {
                println("Found template in common directory: $commonPath")
                if (bot.clickOnTemplate(commonPath)) {
                    println("Successfully clicked on template: $commonPath for $description")
                    return true
                }
            }
        }

        // If still not found, try to find it in all loaded templates
        val allTemplates = bot.getAllTemplates()
        val matchingTemplates = allTemplates.filter { it.endsWith(templateName) }

        if (matchingTemplates.isNotEmpty()) {
            println("Found ${matchingTemplates.size} matching templates for $templateName")

            var attempts = 0
            while (attempts < maxAttempts) {
                for (template in matchingTemplates) {
                    if (bot.clickOnTemplate(template)) {
                        println("Successfully clicked on template: $template for $description")
                        return true
                    }
                }
                attempts++
                if (attempts < maxAttempts) {
                    println("Attempt $attempts failed. Waiting before retry...")
                    Thread.sleep(1000) // Wait 1 second before retrying
                }
            }
        }

        println("Failed to find and click template: $templateName for $description after $maxAttempts attempts")
        return false
    }
}
