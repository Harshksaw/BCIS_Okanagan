package utils;
import java.util.Random;

public class PokemonUsernameGen {
    private static final String[] POKEMON = {
        "Pikachu", "Bulbasaur", "Charmander", "Squirtle", "Eevee", 
        "Jigglypuff", "Meowth", "Psyduck", "Snorlax", "Gengar",
        "Dragonite", "Gyarados", "Lapras", "Vaporeon", "Flareon",
        "Jolteon", "Mew", "Mewtwo", "Articuno", "Zapdos",
        "Moltres", "Ditto", "Magikarp", "Charizard", "Blastoise",
        "Venusaur", "Alakazam", "Machamp", "Golem", "Rapidash"
    };
    
    private static final String[] ADJECTIVES = {
        "Mighty", "Sleepy", "Brave", "Shy", "Speedy",
        "Clever", "Jolly", "Calm", "Wild", "Gentle",
        "Fierce", "Dreamy", "Quick", "Merry", "Sneaky"
    };
    
    public static String generate() {
        Random random = new Random();
        String adjective = ADJECTIVES[random.nextInt(ADJECTIVES.length)];
        String pokemon = POKEMON[random.nextInt(POKEMON.length)];
        int number = random.nextInt(100);
        
        return adjective + pokemon + number;
    }
}