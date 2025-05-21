package orion

// Sealed class for action configurations
sealed class ActionConfig {
    abstract val enabled: Boolean
    // Common templates for general entry/exit/navigation for this action type
    abstract val commonActionTemplates: List<String>
    // Specific templates for this action type
    abstract val specificTemplates: List<String>
}

data class QuestActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    val desiredZones: List<String> = emptyList(), // Legacy support: e.g., ["Zone5Pattern"]
    val desiredDungeons: List<String> = emptyList(), // Legacy support: e.g., ["Dungeon3"]
    val dungeonTargets: List<DungeonTarget> = emptyList(), // New way to specify dungeons with zone and dungeon numbers
    val repeatCount: Int = 1 // How many times to cycle through quests or a specific quest
) : ActionConfig() {
    // Data class for specifying a dungeon with zone and dungeon number
    data class DungeonTarget(
        val zoneNumber: Int, // e.g., 1, 2, 3, etc.
        val dungeonNumber: Int, // e.g., 1, 2, 3, etc.
        val enabled: Boolean = true
    )
}

data class PvpActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    val ticketsToUse: Int = 5, // Number of tickets to use (1-5)
    val opponentRank: Int = 2, // Which opponent to fight (1-4)
    val autoSelectOpponent: Boolean = false // Whether to automatically select opponents or use specified rank
) : ActionConfig()

data class GvgActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList(),
    val badgeChoice: Int = 5, // 1-5
    val opponentChoice: Int = 3 // 1-4
) : ActionConfig()

data class WorldBossActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(),
    override val specificTemplates: List<String> = emptyList()
    // Add specific WorldBoss settings if any, e.g., targetBossName, specificLootFilters
) : ActionConfig()

data class RaidActionConfig(
    override val enabled: Boolean = true,
    override val commonActionTemplates: List<String> = emptyList(), // For finding raid menu, selecting difficulty etc.
    override val specificTemplates: List<String> = emptyList(),
    val raidTargets: List<RaidTarget> = emptyList(), // Specific raids
    val runCount: Int = 3 // Number of times to run each raid target
) : ActionConfig() {
    // Data class for specifying details about a raid target
    data class RaidTarget(
        val raidName: String, // Corresponds to legacy Patterns.Raid.RaidName
        val difficulty: String, // e.g., "Normal", "Hard", "Heroic"
        val enabled: Boolean = true
    )
}

// Main configuration class for the bot
data class BotConfig(
    val configId: String,
    val characterName: String,
    val actionSequence: List<String>,
    val actionConfigs: Map<String, ActionConfig>,
    val defaultAction: String = "Quest" // Default action if none specified
)
