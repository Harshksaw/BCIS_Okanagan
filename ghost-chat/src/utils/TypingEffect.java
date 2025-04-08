package utils;

public class TypingEffect {
    /**
     * Displays text with a typewriter effect
     * @param text The text to display
     * @param speedMs Milliseconds per character (lower = faster)
     */
    public static void typeText(String text, int speedMs) {
        try {
            for (char c : text.toCharArray()) {
                System.out.print(c);
                Thread.sleep(speedMs);
            }
            System.out.println();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            // If interrupted, just print the text normally
            System.out.println(text);
        }
    }
    
    /**
     * Display colored text with typewriter effect
     * @param text Text to display
     * @param color ANSI color code to use
     * @param speedMs Milliseconds per character
     */
    public static void typeColoredText(String text, String color, int speedMs) {
        try {
            System.out.print(color); // Set color
            for (char c : text.toCharArray()) {
                System.out.print(c);
                Thread.sleep(speedMs);
            }
            System.out.println(ColorUtils.RESET); // Reset color
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            // If interrupted, just print the text normally
            System.out.println(color + text + ColorUtils.RESET);
        }
    }
    
    /**
     * Simulate someone typing with "..." appearing
     * @param username The username that's typing
     */
    public static void showTypingIndicator(String username, String color) {
        try {
            // Get the console width if possible, default to 80
            int width = 80;
            try {
                width = Integer.parseInt(System.getenv("COLUMNS"));
            } catch (Exception e) {
                // Use default if can't get terminal width
            }
            
            // Create typing indicator with color
            String typingMessage = color + username + " is typing";
            
            // Show the dots appearing one by one
            for (int i = 0; i < 3; i++) {
                // Move cursor to beginning of line and clear
                System.out.print("\r" + " ".repeat(width));
                System.out.print("\r" + typingMessage);
                for (int j = 0; j <= i; j++) {
                    System.out.print(".");
                }
                Thread.sleep(500);
            }
            
            // Clear the typing indicator
            System.out.print("\r" + " ".repeat(width) + "\r");
            System.out.print(ColorUtils.RESET);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}