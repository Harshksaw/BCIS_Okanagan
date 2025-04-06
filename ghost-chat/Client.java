import java.io.*;
import java.net.*;

public class Client {
    public static void main(String[] args) throws IOException {
        Socket socket = new Socket("localhost", 5001); // <-- Connects to Docker-mapped port

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
            } catch (IOException e) {}
        }).start();

        // Send to server
        String input;
        while ((input = userIn.readLine()) != null) {
            out.println(input);
            if (input.equalsIgnoreCase("/exit")) break;
        }

        socket.close();
    }
}
