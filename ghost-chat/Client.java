import java.io.*;
import java.net.*;

public class Client {
    public static void main(String[] args) {
        String serverAddress = "localhost"; // Change this to the server's IP if connecting remotely
        int serverPort = 5001;              // This should match your Docker port mapping

        // If command line arguments are provided, use them for server address and port
        if (args.length >= 1) {
            serverAddress = args[0];
        }
        if (args.length >= 2) {
            try {
                serverPort = Integer.parseInt(args[1]);
            } catch (NumberFormatException e) {
                System.out.println("Invalid port number. Using default port 5001.");
            }
        }

        try {
            System.out.println("Connecting to " + serverAddress + ":" + serverPort + "...");
            Socket socket = new Socket(serverAddress, serverPort);
            System.out.println("Connected to the chat server!");

            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
            BufferedReader userIn = new BufferedReader(new InputStreamReader(System.in));

            // Read from server
            new Thread(() -> {
                String msg;
                try {
                    while ((msg = in.readLine()) != null) {
                        System.out.println(msg);
                    }
                } catch (IOException e) {
                    System.out.println("Disconnected from server.");
                }
            }).start();

            // Send to server
            String input;
            while ((input = userIn.readLine()) != null) {
                out.println(input);
                if (input.equalsIgnoreCase("/exit")) break;
            }

            socket.close();
        } catch (UnknownHostException e) {
            System.err.println("Can't find server at " + serverAddress + ":" + serverPort);
        } catch (IOException e) {
            System.err.println("Couldn't connect to " + serverAddress + ":" + serverPort);
            System.err.println("Error: " + e.getMessage());
        }
    }
}