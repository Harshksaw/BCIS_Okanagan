// src/utils/RoomIdGen.java
package utils;
import java.util.Random;

public class RoomIdGen {
    private static final String CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    public static String generate() {
        StringBuilder sb = new StringBuilder();
        Random random = new Random();
        
        // Create a 6-character room ID
        for (int i = 0; i < 6; i++) {
            int index = random.nextInt(CHARS.length());
            sb.append(CHARS.charAt(index));
        }
        
        return sb.toString();
    }
}