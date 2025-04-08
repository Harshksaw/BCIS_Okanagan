package utils;

public class LoadingAnimation {
    private static final String[] POKEBALL_FRAMES = {
        "  ○  ", 
        " (○) ", 
        "((○))", 
        "(⚪)", 
        "((⚪))", 
        " (⚪) ", 
        "  ⚪  ", 
        " (⚪) ", 
        "((⚪))",
        "(⚫)",
        "((⚫))",
        " (⚫) ",
        "  ⚫  "
    };
    
    public static void playPokeballAnimation(String message, int durationMs) {
        try {
            int framesCount = POKEBALL_FRAMES.length;
            long frameTimeMs = durationMs / (framesCount * 3); // Show animation 3 times
            
            for (int i = 0; i < framesCount * 3; i++) {
                // Clear line and print current frame
                System.out.print("\r" + ColorUtils.RED + 
                                POKEBALL_FRAMES[i % framesCount] + 
                                ColorUtils.RESET + " " + message);
                
                Thread.sleep(frameTimeMs);
            }
            System.out.println(); // Move to next line when done
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
    
    public static void playPikachuRunningAnimation(String message, int durationMs) {
        try {
            String[] frames = {
                "  (･ω･)  ", 
                " (･ω･)   ", 
                "(･ω･)    ", 
                " (･ω･)   ", 
                "  (･ω･)  ", 
                "   (･ω･) ", 
                "    (･ω･)", 
                "   (･ω･) "
            };
            
            int framesCount = frames.length;
            long frameTimeMs = durationMs / (framesCount * 3);
            
            for (int i = 0; i < framesCount * 3; i++) {
                System.out.print("\r" + ColorUtils.YELLOW + 
                                frames[i % framesCount] + 
                                ColorUtils.RESET + " " + message);
                
                Thread.sleep(frameTimeMs);
            }
            System.out.println();
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
    
    public static void playConnectionAnimation(int durationMs) {
        String[] messages = {
            "Connecting to Pokémon Center...",
            "Starting up Pokédex systems...", 
            "Establishing connection to trainers...",
            "Synchronizing with Professor Oak...", 
            "Loading Pokémon data..."
        };
        
        try {
            for (String message : messages) {
                playPokeballAnimation(message, durationMs / messages.length);
            }
            
            System.out.println(ColorUtils.GREEN + "✓ Connection established! Welcome to PokéChat!" + ColorUtils.RESET);
        } catch (Exception e) {
            System.err.println("Error during animation: " + e.getMessage());
        }
    }
}