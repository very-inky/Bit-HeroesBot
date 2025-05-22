package orion.utils

import java.io.File
import java.nio.file.Path
import java.nio.file.Paths

/**
 * Utility class for handling file paths in a platform-independent way
 */
object PathUtils {
    /**
     * Constructs a platform-independent path by joining path components with the system's file separator
     * @param first The first component of the path
     * @param more Additional components of the path
     * @return A platform-independent path string
     */
    fun buildPath(first: String, vararg more: String): String {
        return Paths.get(first, *more).toString()
    }

    /**
     * Constructs a platform-independent path for template files
     * @param category The template category (e.g., "ui", "quest", "raid")
     * @param filename Optional filename within the category
     * @return A platform-independent path string
     */
    fun templatePath(category: String, filename: String? = null): String {
        return if (filename != null) {
            buildPath("templates", category, filename)
        } else {
            buildPath("templates", category)
        }
    }

    /**
     * Normalizes a path string to use the system's file separator
     * @param path The path string to normalize
     * @return A normalized path string using the system's file separator
     */
    fun normalizePath(path: String): String {
        // Replace both Windows and Unix separators with the system separator
        return path.replace('\\', '/').replace('/', File.separatorChar)
    }
}