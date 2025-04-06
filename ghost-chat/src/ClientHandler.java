
import java.io.*;
import java.net.*;
import java.util.Set;

public class ClientHandler implements Runnable {
    private Socket socket;
    private BufferedReader in;
    private PrintWriter out;
    private String username;
    private Set<ClientHandler> clients;

    public ClientHandler(Socket socket, Set<ClientHandler> clients) throws IOException {
        this.socket = socket;
        this.clients = clients;
        this.in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        this.out = new PrintWriter(socket.getOutputStream(), true);
        this.username = utils.UsernameGen.generate();
        broadcast("🔔 " + username + " joined.");
    }

    public void run() {
        try {
            String msg;
            while ((msg = in.readLine()) != null) {
                if (msg.equalsIgnoreCase("/exit")) break;
                broadcast("[" + username + "]: " + msg);
            }
        } catch (IOException e) {
            System.out.println("Client disconnected.");
        } finally {
            try { socket.close(); } catch (IOException e) {}
            clients.remove(this);
            broadcast("❌ " + username + " left.");
        }
    }

    private void broadcast(String msg) {
        for (ClientHandler client : clients) {
            client.out.println(msg);
        }
    }
}
