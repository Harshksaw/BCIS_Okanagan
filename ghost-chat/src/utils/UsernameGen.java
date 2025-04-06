package utils;
import java.util.Random;

public class UsernameGen {
    public static String generate() {
        return "Anon" + (new Random().nextInt(900) + 100);
    }
}
