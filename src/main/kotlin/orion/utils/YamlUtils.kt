package orion.utils

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.databind.jsontype.NamedType
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import java.io.File
import orion.*

/**
 * Utility class for YAML serialization and deserialization
 */
object YamlUtils {
    // Create and configure the ObjectMapper with YAML factory
    private val mapper = ObjectMapper(YAMLFactory()).apply {
        registerModule(KotlinModule.Builder().build())
        enable(SerializationFeature.INDENT_OUTPUT)
        disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)

        // Enable default typing for polymorphic types
        activateDefaultTyping(polymorphicTypeValidator, ObjectMapper.DefaultTyping.NON_FINAL)

        // Register subtypes of ActionConfig
        registerSubtypes(
            NamedType(QuestActionConfig::class.java, "QuestActionConfig"),
            NamedType(PvpActionConfig::class.java, "PvpActionConfig"),
            NamedType(GvgActionConfig::class.java, "GvgActionConfig"),
            NamedType(WorldBossActionConfig::class.java, "WorldBossActionConfig"),
            NamedType(RaidActionConfig::class.java, "RaidActionConfig")
        )
    }

    /**
     * Serialize an object to a YAML file
     * 
     * @param obj The object to serialize
     * @param file The file to write to
     * @return True if successful, false otherwise
     */
    fun <T : Any> writeToFile(obj: T, file: File): Boolean {
        return try {
            // Create parent directories if they don't exist
            file.parentFile?.mkdirs()

            // Write the object to the file
            mapper.writeValue(file, obj)
            true
        } catch (e: Exception) {
            println("Error writing YAML to file ${file.path}: ${e.message}")
            false
        }
    }

    /**
     * Serialize an object to a YAML file
     * 
     * @param obj The object to serialize
     * @param filePath The path to the file to write to
     * @return True if successful, false otherwise
     */

    fun <T : Any> writeToFile(obj: T, filePath: String): Boolean {
        return writeToFile(obj, File(filePath))
    }

    /**
     * Deserialize an object from a YAML file
     * 
     * @param file The file to read from
     * @param clazz The class of the object to deserialize
     * @return The deserialized object, or null if an error occurred
     */
    fun <T : Any> readFromFile(file: File, clazz: Class<T>): T? {
        return try {
            if (!file.exists()) {
                println("File does not exist: ${file.path}")
                return null
            }

            mapper.readValue(file, clazz)
        } catch (e: Exception) {
            println("Error reading YAML from file ${file.path}: ${e.message}")
            null
        }
    }

    /**
     * Deserialize an object from a YAML file
     * 
     * @param filePath The path to the file to read from
     * @param clazz The class of the object to deserialize
     * @return The deserialized object, or null if an error occurred
     */
    @Suppress("unused")
    fun <T : Any> readFromFile(filePath: String, clazz: Class<T>): T? {
        return readFromFile(File(filePath), clazz)
    }

    /**
     * Deserialize an object from a YAML string
     * 
     * @param yaml The YAML string to deserialize
     * @param clazz The class of the object to deserialize
     * @return The deserialized object, or null if an error occurred
     */
    @Suppress("unused")
    fun <T : Any> readFromString(yaml: String, clazz: Class<T>): T? {
        return try {
            mapper.readValue(yaml, clazz)
        } catch (e: Exception) {
            println("Error reading YAML from string: ${e.message}")
            null
        }
    }

    /**
     * Serialize an object to a YAML string
     * 
     * @param obj The object to serialize
     * @return The YAML string, or null if an error occurred
     */
    fun <T : Any> writeToString(obj: T): String? {
        return try {
            mapper.writeValueAsString(obj)
        } catch (e: Exception) {
            println("Error writing object to YAML string: ${e.message}")
            null
        }
    }

    /**
     * Reified extension function to read from a file
     */
    inline fun <reified T : Any> readFromFile(file: File): T? {
        return readFromFile(file, T::class.java)
    }

    /**
     * Reified extension function to read from a file path
     */
    inline fun <reified T : Any> readFromFile(filePath: String): T? {
        return readFromFile(filePath, T::class.java)
    }

    /**
     * Reified extension function to read from a YAML string
     */
    inline fun <reified T : Any> readFromString(yaml: String): T? {
        return readFromString(yaml, T::class.java)
    }
}
