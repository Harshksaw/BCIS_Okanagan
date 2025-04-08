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
    
    // Pokémon-themed icons
    private static final String JOIN_ICON = "⚡ ";      // Trainer appeared
    private static final String LEAVE_ICON = "💨 ";     // Trainer fled
    private static final String CHANGE_ICON = "✨ ";    // Evolution
    private static final String WHISPER_ICON = "👂 ";   // Secret message
    private static final String SYSTEM_ICON = "🏆 ";    // System messages

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
            broadcast(JOIN_ICON + username + " appeared!");
        }
    }

    private void displayWelcomeMenu() {
        out.println("Welcome to PokéChat!");
        out.println("----------------------");
        out.println("1. Join Pokémon Center (Public Chat)");
        out.println("2. Create Private Battle Arena");
        out.println("3. Join Private Battle Arena");
        out.println("4. Ghost Type Mode (Anonymous)");
        out.println("----------------------");
        out.println("Enter your choice (1-4):");
    }

    private void processMenuSelection(String selection) throws IOException {
        switch (selection) {
            case "1":
                // Public chat - use Pokémon username generator
                this.username = utils.PokemonUsernameGen.generate();
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
                out.println("Invalid selection. Joining the Pokémon Center.");
                this.username = utils.PokemonUsernameGen.generate();
                break;
        }
    }

    private void enableAnonymousMode() throws IOException {
        this.anonymousMode = true;
        this.username = "GhostType";
        out.println("Ghost Type mode enabled. Your messages will be displayed as from 'GhostType'.");
        out.println("You'll move silently like a Gengar - no joining/leaving notifications will be shown.");
    }

    private void createPrivateRoom() throws IOException {
        out.println("Enter your Battle Arena name:");
        String roomName = in.readLine();
        
        out.println("Enter password (leave empty for public arena):");
        String password = in.readLine();
        
        // Get username
        out.println("Choose your Trainer name:");
        String userInput = in.readLine();
        if (userInput == null || userInput.trim().isEmpty()) {
            this.username = utils.PokemonUsernameGen.generate();
        } else {
            this.username = userInput;
        }
        
        ChatRoom room = new ChatRoom(roomName, password);
        Server.addRoom(room);
        
        // Join the room
        this.currentRoom = room;
        room.addMember(this);
        
        out.println("Battle Arena created! Arena ID: " + room.getRoomId());
        out.println("Share this ID with other Trainers to invite them to your arena.");
    }

    private void joinPrivateRoom() throws IOException {
        out.println("Enter Battle Arena ID:");
        String roomId = in.readLine();
        
        ChatRoom room = Server.getRoomById(roomId);
        if (room == null) {
            out.println("Battle Arena not found. Joining the Pokémon Center instead.");
            this.username = utils.PokemonUsernameGen.generate();
            return;
        }
        
        if (room.isPrivate()) {
            out.println("Enter Battle Arena password:");
            String password = in.readLine();
            
            if (!room.authenticate(password)) {
                out.println("Incorrect password. Joining the Pokémon Center instead.");
                this.username = utils.PokemonUsernameGen.generate();
                return;
            }
        }
        
        // Get username
        out.println("Choose your Trainer name:");
        String userInput = in.readLine();
        if (userInput == null || userInput.trim().isEmpty()) {
            this.username = utils.PokemonUsernameGen.generate();
        } else {
            this.username = userInput;
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
                        formattedMsg = "🌑 [GhostType]: " + msg;
                    } else {
                        formattedMsg = "🎯 [" + username + "]: " + msg;
                    }
                    
                    broadcast(formattedMsg);
                }
            }
        } catch (IOException e) {
            System.out.println("Trainer disconnected.");
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
                    broadcast(LEAVE_ICON + username + " fled the battle!");
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
                    sendMessage("Usage: /whisper <trainer_name> <message>");
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
            case "/pokemon":
                sendMessage("Generating a new random Pokémon name...");
                changeName(utils.PokemonUsernameGen.generate());
                break;
            default:
                sendMessage("Unknown command. Type /help for available commands.");
                break;
        }
    }

    private void displayHelp() {
        sendMessage(SYSTEM_ICON + "Available Trainer commands:");
        sendMessage("/help - Open your Pokédex for help");
        sendMessage("/list - View all public Battle Arenas");
        sendMessage("/whisper <trainer_name> <message> - Send a private message");
        sendMessage("/name <new_name> - Change your Trainer name");
        sendMessage("/pokemon - Get a new random Pokémon Trainer name");
        sendMessage("/rooms - List available Battle Arenas");
        sendMessage("/exit - Return to the real world");
    }

    private void listRooms() {
        sendMessage(SYSTEM_ICON + "Available Battle Arenas:");
        for (ChatRoom room : Server.getPublicRooms()) {
            sendMessage("- " + room.getRoomName() + " (ID: " + room.getRoomId() + ", Trainers: " + room.getMemberCount() + ")");
        }
    }

    private void whisper(String targetUsername, String message) {
        boolean found = false;
        for (ClientHandler client : clients) {
            if (client.username.equals(targetUsername)) {
                client.sendMessage(WHISPER_ICON + "[Private from " + username + "]: " + message);
                sendMessage(WHISPER_ICON + "[Private to " + targetUsername + "]: " + message);
                found = true;
                break;
            }
        }
        
        if (!found) {
            sendMessage("Trainer " + targetUsername + " not found.");
        }
    }

    private void changeName(String newName) {
        String oldName = this.username;
        this.username = newName;
        broadcast(CHANGE_ICON + oldName + " evolved into " + newName + "!");
    }

    public void sendMessage(String message) {
        out.println(message);
    }

    public String getUsername() {
        return username;
    }

    private void broadcast(String msg) {
        // Only broadcast join/leave messages for non-anonymous users
        if ((msg.startsWith(JOIN_ICON) || msg.startsWith(LEAVE_ICON)) && anonymousMode) {
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