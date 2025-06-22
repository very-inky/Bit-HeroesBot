package orion.utils

import orion.RaidActionConfig
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*

class JsonIgnoreTest {
    
    @Test
    fun testTierNumberIsIgnoredInSerialization() {
        // Create a RaidTarget with both raidNumber and tierNumber
        val raidTarget = RaidActionConfig.RaidTarget(
            raidName = "Test Raid",
            raidNumber = 3,
            tierNumber = 6,  // This should be ignored in serialization
            difficulty = "Heroic",
            enabled = true
        )
        
        // Serialize to YAML
        val yaml = YamlUtils.writeToString(raidTarget)
        
        // Print the YAML for debugging
        println("[DEBUG_LOG] Serialized YAML:\n$yaml")
        
        // Check that tierNumber is not in the YAML
        assertNotNull(yaml)
        assertFalse(yaml!!.contains("tierNumber"), "YAML should not contain tierNumber field")
        
        // Check that other fields are in the YAML
        assertTrue(yaml.contains("raidName"), "YAML should contain raidName field")
        assertTrue(yaml.contains("raidNumber"), "YAML should contain raidNumber field")
        assertTrue(yaml.contains("difficulty"), "YAML should contain difficulty field")
        assertTrue(yaml.contains("enabled"), "YAML should contain enabled field")
        
        // Deserialize back to RaidTarget
        val deserializedTarget = YamlUtils.readFromString<RaidActionConfig.RaidTarget>(yaml)
        
        // Check that the tierNumber is still null after deserialization
        assertNotNull(deserializedTarget)
        assertNull(deserializedTarget!!.tierNumber, "Deserialized tierNumber should be null")
        
        // But the effective tier number should still work
        assertEquals(6, deserializedTarget.getEffectiveTierNumber(), "Effective tier number should be calculated from raid number")
    }
}