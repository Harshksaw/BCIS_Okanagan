package utils;

public class BannerGenerator {
    
    public static String getPokeChatBanner() {
        return 
            "\n\u001B[33m" +
            "  ____    _    _         ____ _           _   \n" +
            " |  _ \\  / \\  | | _____ / ___| |__   __ _| |_ \n" +
            " | |_) |/ _ \\ | |/ / _ \\ |   | '_ \\ / _` | __|\n" +
            " |  __// ___ \\|   < (_) |___ | | | | (_| | |_ \n" +
            " |_|  /_/   \\_\\_|\\_\\___/\\____|_| |_|\\__,_|\\__|\n" +
            "                                               \n" +
            "\u001B[36m         -- Gotta Chat 'Em All! --\u001B[0m\n";
    }
    
    public static String getPokeballSeparator() {
        return "\n\u001B[31m●\u001B[30m▬▬▬\u001B[37m◎\u001B[30m▬▬▬\u001B[31m●\u001B[0m\n";
    }
    
    public static String getRandomPokemonAscii() {
        // Select a random pokemon ASCII art
        int selection = (int)(Math.random() * 3);
        
        switch(selection) {
            case 0:
                return getPikachuAscii();
            case 1:
                return getCharmanderAscii();
            default:
                return getBulbasaurAscii();
        }
    }
    
    private static String getPikachuAscii() {
        return 
            "\u001B[33m" +
            "  \\.\\    /,/\n" +
            "   \\ )  ( /\n" +
            "   /`-._'-\\\n" +
            "  /-._/|\\._\\\n" +
            "  \\   \\|/   /\n" +
            "   `-.__.-'\n" +
            "     /_|_\\\n" +
            "      | |\n" +
            "      ^ ^\u001B[0m";
    }
    
    private static String getCharmanderAscii() {
        return 
            "\u001B[31m" +
            "  _.--\"\"\"\"--.._\n" +
            " .'             '.\n" +
            "/                 \\\n" +
            "|                 ;\n" +
            "|                 |\n" +
            "\\                 /\n" +
            " `,.         ,.'\n" +
            "  |:         ;|\n" +
            "  |:         ;|\n" +
            "  |:         ;|\n" +
            "  |:         ;|\n" +
            "  ':         ;'\n" +
            "   \\.       ,/\n" +
            "    \"--..--\"\u001B[0m";
    }
    
    private static String getBulbasaurAscii() {
        return 
            "\u001B[32m" +
            "               ____\n" +
            "              /   /\\\n" +
            "             /   /:|\n" +
            "            /   /:/:\n" +
            "           /   /:/:|\n" +
            "          /   /:/::|\n" +
            "         /___/:/:::|\n" +
            "         \\__/:/::/:/\n" +
            "          /:/::/:/\n" +
            "         /:/::/:/\n" +
            "        /:/::/:/\n" +
            "    ___/:/::/:/___\n" +
            "   /___/:/::/:/___/\\\n" +
            "   \\__/:/::/:/___/:|\n" +
            "     /:/::/:/:/:/::/\n" +
            "    /:/::/:/:/:/:/\n" +
            "   /:/::/:/:/:/:/\n" +
            "  /:/:/:/:/:/:/\n" +
            " /:/::/:/:/:/\n" +
            " \\__/:/:/:/\n" +
            "    \\/::/\n" +
            "     \\/:|\n" +
            "      \\|\u001B[0m";
    }
}