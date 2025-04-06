// src/utils/MessageFormatter.java
package utils;

public class MessageFormatter {
    // ANSI color codes
    private static final String RESET = "\u001B[0m";
    private static final String RED = "\u001B[31m";
    private static final String GREEN = "\u001B[32m";
    private static final String YELLOW = "\u001B[33m";
    private static final String BLUE = "\u001B[34m";
    private static final String PURPLE = "\u001B[35m";
    private static final String CYAN = "\u001B[36m";
    private static final String BOLD = "\u001B[1m";
    
    /**
     * Format a system message
     */
    public static String formatSystemMessage(String message) {
        return YELLOW + "[System] " + message + RESET;
    }
    
    /**
     * Format a game message
     */
    public static String formatGameMessage(String message) {
        return PURPLE + "[GAME] " + message + RESET;
    }
    
    /**
     * Format join notification
     */
    public static String formatJoinMessage(String username, String roomName) {
        return GREEN + "🔔 " + username + " joined " + roomName + RESET;
    }
    
    /**
     * Format leave notification
     */
    public static String formatLeaveMessage(String username) {
        return RED + "❌ " + username + " left" + RESET;
    }
}