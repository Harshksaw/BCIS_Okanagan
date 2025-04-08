import java.io.*;
import java.net.*;
import java.util.Random;
import utils.BannerGenerator;
import utils.ColorUtils;
import utils.LoadingAnimation;
import utils.PokemonEmojis;
import utils.TypingEffect;

public class Client {
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

        // Show connecting animation
        LoadingAnimation.playConnectionAnimation(5000);

        try {
            Socket socket = new Socket("localhost", 5001); // <-- Connects to Docker-mapped port
            System.out.println(ColorUtils.GREEN + "Connected to PokéChat server!" + ColorUtils.RESET);

            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
            BufferedReader userIn = new BufferedReader(new InputStreamReader(System.in));

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
            // Remove the username and random variables since we won't use them for typing
            // effects

            while ((input = userIn.readLine()) != null) {
                // Remove the typing indicator code completely

                // Just send the input directly without delay
                out.println(input);

                if (input.equalsIgnoreCase("/exit")) {
                    LoadingAnimation.playPikachuRunningAnimation("See you next time, Trainer!", 2000);
                    break;
                }

                // Remove the username extraction code since we don't need it anymore
            }

            if (input.equalsIgnoreCase("/exit")) {
                LoadingAnimation.playPikachuRunningAnimation("See you next time, Trainer!", 2000);
                break;
            }


            socket.close();

        } catch (

        ConnectException e) {
            System.out.println(ColorUtils.RED + "Could not connect to the server. Is it running?" + ColorUtils.RESET);
            System.out.println(ColorUtils.YELLOW + "Try checking if the server is started and the port is correct."
                    + ColorUtils.RESET);
        }
    }
}