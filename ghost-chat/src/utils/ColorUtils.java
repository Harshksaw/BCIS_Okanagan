package utils;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class ColorUtils {
    // ANSI color codes
    public static final String RESET = "\u001B[0m";
    public static final String BLACK = "\u001B[30m";
    public static final String RED = "\u001B[31m";
    public static final String GREEN = "\u001B[32m";
    public static final String YELLOW = "\u001B[33m";
    public static final String BLUE = "\u001B[34m";
    public static final String PURPLE = "\u001B[35m";
    public static final String CYAN = "\u001B[36m";
    public static final String WHITE = "\u001B[37m";
    
    // Background colors
    public static final String BG_BLACK = "\u001B[40m";
    public static final String BG_RED = "\u001B[41m";
    public static final String BG_GREEN = "\u001B[42m";
    public static final String BG_YELLOW = "\u001B[43m";
    public static final String BG_BLUE = "\u001B[44m";
    public static final String BG_PURPLE = "\u001B[45m";
    public static final String BG_CYAN = "\u001B[46m";
    public static final String BG_WHITE = "\u001B[47m";
    
    // Styles
    public static final String BOLD = "\u001B[1m";
    public static final String ITALIC = "\u001B[3m";
    public static final String UNDERLINE = "\u001B[4m";
    
    /**
     * Colors messages by type for the chat
     */
    public static String colorMessage(String message) {
        // User joined
        if (message.contains("appeared")) {
            return GREEN + message + RESET;
        }
        // User left
        else if (message.contains("fled the battle")) {
            return RED + message + RESET;
        }
        // Room messages
        else if (message.startsWith("🏆") || message.startsWith("🚶")) {
            return PURPLE + message + RESET;
        }
        // System messages
        else if (message.startsWith("System:")) {
            return YELLOW + message + RESET;
        }
        // Regular chat messages - color the username part
        else if (message.contains("[") && message.contains("]:")) {
            int start = message.indexOf("[");
            int end = message.indexOf("]:");
            if (start >= 0 && end >= 0) {
                String prefix = message.substring(0, start);
                String username = message.substring(start, end + 2);
                String content = message.substring(end + 2);
                return prefix + CYAN + username + RESET + content;
            }
        }
        
        // Default - return unchanged
        return message;
    }
    
    /**
     * Returns a Pokémon type color based on username
     */
    public static String getPokemonTypeColor(String username) {
        // Simple hashing to consistently assign a color based on username
        // int hash = username.hashCode();
        int hash = (username != null) ? username.hashCode() : 0;
        int colorIndex = Math.abs(hash % 7);
        
        switch (colorIndex) {
            case 0: return RED;     // Fire
            case 1: return BLUE;    // Water
            case 2: return GREEN;   // Grass
            case 3: return YELLOW;  // Electric
            case 4: return PURPLE;  // Psychic
            case 5: return CYAN;    // Ice
            case 6: return WHITE;   // Normal
            default: return RESET;
        }
    }
}