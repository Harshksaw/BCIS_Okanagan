package utils;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class PokemonEmojis {
    // Map for Pokemon names and related Unicode symbols
    private static final Map<String, String> POKEMON_EMOJIS = new HashMap<>();
    
    // Map for Pokemon types and related Unicode symbols
    private static final Map<String, String> TYPE_EMOJIS = new HashMap<>();
    
    // Static initializer to populate the maps
    static {
        // Pokemon-related emojis
        POKEMON_EMOJIS.put("pikachu", "⚡🐹");
        POKEMON_EMOJIS.put("bulbasaur", "🌱🦖");
        POKEMON_EMOJIS.put("charmander", "🔥🦎");
        POKEMON_EMOJIS.put("squirtle", "💧🐢");
        POKEMON_EMOJIS.put("eevee", "🦊");
        POKEMON_EMOJIS.put("jigglypuff", "🎤🎵");
        POKEMON_EMOJIS.put("meowth", "😸💰");
        POKEMON_EMOJIS.put("psyduck", "🦆🤕");
        POKEMON_EMOJIS.put("snorlax", "💤🐻");
        POKEMON_EMOJIS.put("gengar", "👻");
        POKEMON_EMOJIS.put("mewtwo", "👽");
        POKEMON_EMOJIS.put("magikarp", "🐟");
        POKEMON_EMOJIS.put("gyarados", "🌊🐉");
        
        // Type emojis
        TYPE_EMOJIS.put("normal", "⚪");
        TYPE_EMOJIS.put("fire", "🔥");
        TYPE_EMOJIS.put("water", "💧");
        TYPE_EMOJIS.put("electric", "⚡");
        TYPE_EMOJIS.put("grass", "🌿");
        TYPE_EMOJIS.put("ice", "❄️");
        TYPE_EMOJIS.put("fighting", "👊");
        TYPE_EMOJIS.put("poison", "☠️");
        TYPE_EMOJIS.put("ground", "🌋");
        TYPE_EMOJIS.put("flying", "🦅");
        TYPE_EMOJIS.put("psychic", "🔮");
        TYPE_EMOJIS.put("bug", "🐛");
        TYPE_EMOJIS.put("rock", "🪨");
        TYPE_EMOJIS.put("ghost", "👻");
        TYPE_EMOJIS.put("dragon", "🐉");
        TYPE_EMOJIS.put("dark", "🌑");
        TYPE_EMOJIS.put("steel", "⚙️");
        TYPE_EMOJIS.put("fairy", "✨");
    }
    
    /**
     * Other useful Pokemon-themed emojis/symbols
     */
    public static final String POKEBALL = "●";
    public static final String GREATBALL = "○";
    public static final String ULTRABALL = "◎";
    public static final String MASTERBALL = "◉";
    
    public static final String[] ITEMS = {
        "🧪", // potion
        "🍎", // berry
        "🔑", // key item
        "💎", // evolution stone
        "📜", // TM/HM
        "🥾", // running shoes
        "🚲", // bicycle
        "🎣", // fishing rod
        "📱"  // pokedex
    };
    
    /**
     * Replace Pokemon keywords in text with emojis
     */
    public static String addEmojis(String message) {
        String result = message;
        
        for (Map.Entry<String, String> entry : POKEMON_EMOJIS.entrySet()) {
            // Case-insensitive replace
            String pattern = "(?i)" + entry.getKey();
            result = result.replaceAll(pattern, entry.getKey() + " " + entry.getValue());
        }
        
        for (Map.Entry<String, String> entry : TYPE_EMOJIS.entrySet()) {
            // Only replace type names when they appear as words
            String pattern = "(?i)\\b" + entry.getKey() + "\\b";
            result = result.replaceAll(pattern, entry.getKey() + " " + entry.getValue());
        }
        
        return result;
    }
    
    /**
     * Get a random Pokemon emoji
     */
    public static String getRandomPokemonEmoji() {
        Random random = new Random();
        Object[] values = POKEMON_EMOJIS.values().toArray();
        return (String) values[random.nextInt(values.length)];
    }
    
    /**
     * Get a random item emoji
     */
    public static String getRandomItemEmoji() {
        Random random = new Random();
        return ITEMS[random.nextInt(ITEMS.length)];
    }
}