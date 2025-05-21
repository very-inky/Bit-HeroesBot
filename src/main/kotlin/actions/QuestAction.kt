package orion.actions // Keep actions in a sub-package if desired

import orion.Bot
import orion.GameAction
import orion.ActionConfig
import orion.QuestActionConfig

class QuestAction : GameAction {
    override fun execute(bot: Bot, config: ActionConfig): Boolean {
        if (config !is QuestActionConfig) {
            println("Error: Incorrect config type passed to QuestAction.")
            return false
        }

        if (!config.enabled) {
            println("QuestAction is disabled in config.")
            return false
        }

        println("--- Executing Quest Action ---")

        // Log legacy configuration if present
        if (config.desiredZones.isNotEmpty() || config.desiredDungeons.isNotEmpty()) {
            println("Legacy Configuration:")
            println("  Desired Zones: ${config.desiredZones.joinToString()}")
            println("  Desired Dungeons: ${config.desiredDungeons.joinToString()}")
        }

        // Log new dungeon targets configuration
        if (config.dungeonTargets.isNotEmpty()) {
            println("Dungeon Targets:")
            config.dungeonTargets.forEach { target ->
                println("  Zone ${target.zoneNumber}, Dungeon ${target.dungeonNumber} (${if (target.enabled) "Enabled" else "Disabled"})")
            }
        }

        println("Repeat Count: ${config.repeatCount}")

        // Placeholder logic:
        // In a real scenario, you would:
        // 1. Use bot.findTemplate and bot.clickOnTemplate with config.commonActionTemplates to navigate to the quest area.
        // 2. Loop based on repeatCount.
        // 3. For each dungeon target in dungeonTargets (or legacy zones/dungeons if dungeonTargets is empty):
        //    - Try to find and click templates specific to that zone/dungeon.
        //    - Use bot.clickOnTemplate for quest start, complete, etc. buttons.

        // Process dungeon targets if available
        if (config.dungeonTargets.isNotEmpty()) {
            println("Processing specific dungeon targets...")
            for (target in config.dungeonTargets.filter { it.enabled }) {
                println("Attempting to run Zone ${target.zoneNumber}, Dungeon ${target.dungeonNumber}")
                // Here you would implement the actual logic to navigate to and run the dungeon
                // This is placeholder code
            }
        } 
        // Fall back to legacy configuration if no dungeon targets
        else if (config.commonActionTemplates.isNotEmpty()) {
            val firstTemplate = config.commonActionTemplates.first()
            println("Attempting to find and click a common quest template: $firstTemplate")
            if (bot.clickOnTemplate(firstTemplate)) {
                println("Clicked on common quest template: $firstTemplate")
            } else {
                println("Failed to find or click common quest template: $firstTemplate")
            }
        } else {
            println("No quest targets or templates specified. Nothing to do.")
        }

        println("--- Quest Action Finished (Placeholder) ---")
        return true // Placeholder
    }
}
