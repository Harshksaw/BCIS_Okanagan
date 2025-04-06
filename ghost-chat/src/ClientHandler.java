// src/ClientHandler.java
import java.io.*;
import java.net.*;
import java.util.Set;

public class ClientHandler implements Runnable {
    private Socket socket;
    private BufferedReader in;
    private PrintWriter out;
    private String username;
    private Set<ClientHandler> clients;
    private boolean anonymousMode = false;
    private ChatRoom currentRoom;

    public ClientHandler(Socket socket, Set<ClientHandler> clients) throws IOException {
        this.socket = socket;
        this.clients = clients;
        this.in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        this.out = new PrintWriter(socket.getOutputStream(), true);
        
        // Display welcome menu
        displayWelcomeMenu();
        
        // Process user selection
        String selection = in.readLine();
        processMenuSelection(selection);
        
        // Only broadcast join message if not in anonymous mode
        if (!anonymousMode) {
            broadcast("🔔 " + username + " joined.");
        }
    }

    private void displayWelcomeMenu() {
        out.println("Welcome to GhostChat!");
        out.println("----------------------");
        out.println("1. Join Public Chat");
        out.println("2. Create Private Room");
        out.println("3. Join Private Room");
        out.println("4. Anonymous Mode");
        out.println("----------------------");
        out.println("Enter your choice (1-4):");
    }

    private void processMenuSelection(String selection) throws IOException {
        switch (selection) {
            case "1":
                // Public chat - use default username generator
                this.username = utils.UsernameGen.generate();
                break;
            case "2":
                // Create private room
                createPrivateRoom();
                break;
            case "3":
                // Join private room
                joinPrivateRoom();
                break;
            case "4":
                // Anonymous mode
                enableAnonymousMode();
                break;
            default:
                // Default to public chat
                out.println("Invalid selection. Joining public chat.");
                this.username = utils.UsernameGen.generate();
                break;
        }
    }

    private void enableAnonymousMode() throws IOException {
        this.anonymousMode = true;
        this.username = "Ghost";
        out.println("Anonymous mode enabled. Your messages will be displayed as from 'Ghost'.");
        out.println("No joining/leaving notifications will be shown for you.");
    }

    private void createPrivateRoom() throws IOException {
        out.println("Enter room name:");
        String roomName = in.readLine();
        
        out.println("Enter password (leave empty for public room):");
        String password = in.readLine();
        
        // Get username
        out.println("Enter your username:");
        this.username = in.readLine();
        if (this.username == null || this.username.trim().isEmpty()) {
            this.username = utils.UsernameGen.generate();
        }
        
        ChatRoom room = new ChatRoom(roomName, password);
        Server.addRoom(room);
        
        // Join the room
        this.currentRoom = room;
        room.addMember(this);
        
        out.println("Room created! Room ID: " + room.getRoomId());
        out.println("Share this ID with friends to let them join your room.");
    }

    private void joinPrivateRoom() throws IOException {
        out.println("Enter room ID:");
        String roomId = in.readLine();
        
        ChatRoom room = Server.getRoomById(roomId);
        if (room == null) {
            out.println("Room not found. Joining public chat instead.");
            this.username = utils.UsernameGen.generate();
            return;
        }
        
        if (room.isPrivate()) {
            out.println("Enter room password:");
            String password = in.readLine();
            
            if (!room.authenticate(password)) {
                out.println("Incorrect password. Joining public chat instead.");
                this.username = utils.UsernameGen.generate();
                return;
            }
        }
        
        // Get username
        out.println("Enter your username:");
        this.username = in.readLine();
        if (this.username == null || this.username.trim().isEmpty()) {
            this.username = utils.UsernameGen.generate();
        }
        
        // Join the room
        this.currentRoom = room;
        room.addMember(this);
    }

    public void run() {
        try {
            String msg;
            while ((msg = in.readLine()) != null) {
                if (msg.equalsIgnoreCase("/exit")) break;
                
                if (msg.startsWith("/")) {
                    handleCommand(msg);
                } else {
                    String formattedMsg;
                    if (anonymousMode) {
                        formattedMsg = "[Ghost]: " + msg;
                    } else {
                        formattedMsg = "[" + username + "]: " + msg;
                    }
                    
                    broadcast(formattedMsg);
                }
            }
        } catch (IOException e) {
            System.out.println("Client disconnected.");
        } finally {
            try { socket.close(); } catch (IOException e) {}
            clients.remove(this);
            
            if (!anonymousMode) {
                if (currentRoom != null) {
                    currentRoom.removeMember(this);
                    // Remove empty rooms
                    if (currentRoom.getMemberCount() == 0) {
                        Server.removeRoom(currentRoom);
                    }
                } else {
                    broadcast("❌ " + username + " left.");
                }
            }
        }
    }

    private void handleCommand(String cmd) {
        String[] parts = cmd.split("\\s+", 3);
        String command = parts[0].toLowerCase();
        
        switch (command) {
            case "/help":
                displayHelp();
                break;
            case "/list":
                listRooms();
                break;
            case "/whisper":
                if (parts.length < 3) {
                    sendMessage("Usage: /whisper <username> <message>");
                } else {
                    whisper(parts[1], parts[2]);
                }
                break;
            case "/name":
            case "/change_name":
                if (parts.length < 2) {
                    sendMessage("Usage: /name <new_name>");
                } else {
                    changeName(parts[1]);
                }
                break;
            case "/rooms":
                listRooms();
                break;
            default:
                sendMessage("Unknown command. Type /help for available commands.");
                break;
        }
    }

    private void displayHelp() {
        sendMessage("Available commands:");
        sendMessage("/help - Display this help message");
        sendMessage("/list - List all public rooms");
        sendMessage("/whisper <username> <message> - Send a private message");
        sendMessage("/name <new_name> - Change your username");
        sendMessage("/rooms - List available public rooms");
        sendMessage("/exit - Leave the chat");
    }

    private void listRooms() {
        sendMessage("Available public rooms:");
        for (ChatRoom room : Server.getPublicRooms()) {
            sendMessage("- " + room.getRoomName() + " (ID: " + room.getRoomId() + ", Members: " + room.getMemberCount() + ")");
        }
    }

    private void whisper(String targetUsername, String message) {
        boolean found = false;
        for (ClientHandler client : clients) {
            if (client.username.equals(targetUsername)) {
                client.sendMessage("[Private from " + username + "]: " + message);
                sendMessage("[Private to " + targetUsername + "]: " + message);
                found = true;
                break;
            }
        }
        
        if (!found) {
            sendMessage("User " + targetUsername + " not found.");
        }
    }

    private void changeName(String newName) {
        String oldName = this.username;
        this.username = newName;
        broadcast("🔄 " + oldName + " changed their name to " + newName);
    }

    public void sendMessage(String message) {
        out.println(message);
    }

    public String getUsername() {
        return username;
    }

    private void broadcast(String msg) {
        // Only broadcast join/leave messages for non-anonymous users
        if ((msg.startsWith("🔔") || msg.startsWith("❌")) && anonymousMode) {
            return; // Don't announce anonymous users joining/leaving
        }
        
        if (currentRoom != null) {
            currentRoom.broadcast(msg);
        } else {
            // Fall back to global broadcast
            for (ClientHandler client : clients) {
                client.sendMessage(msg);
            }
        }
    }
}