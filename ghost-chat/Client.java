import java.io.*;
import java.net.*;
import java.util.Random;
import utils.BannerGenerator;
import utils.ColorUtils;
import utils.LoadingAnimation;
import utils.PokemonEmojis;
import utils.TypingEffect;

public class Client {
    private static final int SERVER_PORT = 5000; // Correct port to match server

    public static void main(String[] args) throws IOException {
        // Display the Pokemon-themed banner with typing effect
        System.out.println(BannerGenerator.getPokeChatBanner());
        System.out.println(BannerGenerator.getRandomPokemonAscii());
        System.out.println(BannerGenerator.getPokeballSeparator());

        // Print welcome message with typing effect
        TypingEffect.typeColoredText("Welcome to PokéChat! Chat with other Pokémon trainers", ColorUtils.CYAN, 30);
        TypingEffect.typeText(ColorUtils.YELLOW + "Type " + ColorUtils.BOLD + "/exit" +
                ColorUtils.RESET + ColorUtils.YELLOW + " to leave the chat" + ColorUtils.RESET, 20);
        System.out.println(BannerGenerator.getPokeballSeparator());

        BufferedReader userIn = new BufferedReader(new InputStreamReader(System.in));

        // Ask for server address
        System.out.println(ColorUtils.CYAN + "Enter server IP address (or leave blank for localhost):" + ColorUtils.RESET);
        String serverAddress = userIn.readLine().trim();
        
        // Use localhost if no address provided
        if (serverAddress.isEmpty()) {
            serverAddress = "localhost";
        }
        
        // Show connecting animation
        LoadingAnimation.playConnectionAnimation(5000);

        try {
            Socket socket = new Socket(serverAddress, SERVER_PORT);
            System.out.println(ColorUtils.GREEN + "Connected to PokéChat server at " + serverAddress + "!" + ColorUtils.RESET);

            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

            // Read from server
            new Thread(() -> {
                String msg;
                try {
                    while ((msg = in.readLine()) != null) {
                        // Apply color coding and emoji enhancement
                        String enhancedMsg = ColorUtils.colorMessage(PokemonEmojis.addEmojis(msg));
                        System.out.println(enhancedMsg);
                    }
                } catch (IOException e) {
                    System.out.println(ColorUtils.RED + "Lost connection to the PokéChat server!" + ColorUtils.RESET);
                }
            }).start();

            String input;
            while ((input = userIn.readLine()) != null) {
                // Send input to server
                out.println(input);

                if (input.equalsIgnoreCase("/exit")) {
                    LoadingAnimation.playPikachuRunningAnimation("See you next time, Trainer!", 2000);
                    break;
                }
            }

            socket.close();

        } catch (ConnectException e) {
            System.out.println(ColorUtils.RED + "Could not connect to the server at " + serverAddress + ":" + SERVER_PORT + ColorUtils.RESET);
            System.out.println(ColorUtils.YELLOW + "Make sure the server is running and the address/port are correct." + ColorUtils.RESET);
            System.out.println(ColorUtils.YELLOW + "If connecting from another PC, ensure the server PC's firewall allows connections." + ColorUtils.RESET);
        }
    }
}