package orion

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
}