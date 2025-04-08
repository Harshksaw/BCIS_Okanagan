package utils;
import java.util.Random;
import java.util.UUID;

public class RoomIdGen {
    // Pokemon cities and locations to use in room IDs
    private static final String[] POKEMON_LOCATIONS = {
        "Pallet", "Viridian", "Pewter", "Cerulean", "Vermilion", 
        "Lavender", "Celadon", "Fuchsia", "Saffron", "Cinnabar",
        "Indigo", "Olivine", "Ecruteak", "Goldenrod", "Azalea",
        "Rustboro", "Petalburg", "Mauville", "Fortree", "Lavaridge",
        "Jubilife", "Hearthome", "Snowpoint", "Sunyshore", "Oreburgh"
    };
    

    public static String generate() {
        Random random = new Random();
        String location = POKEMON_LOCATIONS[random.nextInt(POKEMON_LOCATIONS.length)];
        String uniqueId = UUID.randomUUID().toString().substring(0, 6);
        
        return location + "-" + uniqueId;
    }
}