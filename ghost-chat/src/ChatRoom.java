// src/ChatRoom.java
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.HashSet;
import utils.BombTagGame;

public class ChatRoom {
    private String roomId;
    private String roomName;
    private String password;
    private boolean isPrivate;
    private Set<ClientHandler> members = ConcurrentHashMap.newKeySet();
    private BombTagGame bombTagGame = null;

    public ChatRoom(String roomName, String password) {
        this.roomId = utils.RoomIdGen.generate();
        this.roomName = roomName;
        this.password = password;
        this.isPrivate = (password != null && !password.isEmpty());
    }

    public void addMember(ClientHandler client) {
        members.add(client);
        broadcast("🔔 " + client.getUsername() + " joined room: " + roomName);
        
        // Notify game if one is in progress
        playerJoinedGame(client.getUsername());
    }

    public void removeMember(ClientHandler client) {
        members.remove(client);
        broadcast("❌ " + client.getUsername() + " left room: " + roomName);
    }

    public void broadcast(String message) {
        for (ClientHandler member : members) {
            member.sendMessage(message);
        }
    }

    public boolean authenticate(String enteredPassword) {
        if (!isPrivate) return true;
        return password.equals(enteredPassword);
    }

    public String getRoomId() {
        return roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public boolean isPrivate() {
        return isPrivate;
    }
    
    public int getMemberCount() {
        return members.size();
    }
    
    // BombTag Game Methods
   // Update this method in your ChatRoom.java file


    // Update this method in ChatRoom.java

public void startBombTagGame() {
    System.out.println("Attempting to start BombTag game in room: " + roomId);
    
    if (bombTagGame != null && bombTagGame.isActive()) {
        System.out.println("Game already in progress in room: " + roomId);
        broadcast(utils.MessageFormatter.formatSystemMessage("A game of Bomb Tag is already in progress!"));
        return;
    }
    
    if (members.size() < 2) {
        System.out.println("Not enough members to start game in room: " + roomId);
        broadcast(utils.MessageFormatter.formatSystemMessage("You need at least 2 players to start Bomb Tag!"));
        return;
    }
    
    System.out.println("Creating BombTag game callbacks");
    // Create a new game with callback functions
    bombTagGame = new BombTagGame(roomId, new BombTagGame.GameCallback() {
        @Override
        public void sendMessageToPlayer(String username, String message) {
            if (username == null) {
                System.out.println("Attempted to send message to null username");
                return;
            }
            
            for (ClientHandler member : members) {
                if (member != null && username.equals(member.getUsername())) {
                    member.sendMessage(utils.MessageFormatter.formatGameMessage(message));
                    break;
                }
            }
        }
        
        @Override
        public void sendMessageToRoom(String message) {
            broadcast(utils.MessageFormatter.formatGameMessage(message));
        }
        
        @Override
        public void playerExploded(String username) {
            // Find the player and notify them
            if (username == null) {
                System.out.println("Null username exploded");
                return;
            }
            
            for (ClientHandler member : members) {
                if (member != null && username.equals(member.getUsername())) {
                    member.sendMessage(utils.MessageFormatter.formatGameMessage("💥 YOU EXPLODED! 💥"));
                    break;
                }
            }
        }
    });
    
    // Get all player usernames with strict null checks
    Set<String> players = new HashSet<>();
    System.out.println("Collecting player usernames for game in room: " + roomId);
    
    for (ClientHandler member : members) {
        if (member != null) {
            String username = member.getUsername();
            if (username != null && !username.trim().isEmpty()) {
                System.out.println("Adding player to game: " + username);
                players.add(username);
            } else {
                System.out.println("Skipping player with null/empty username");
            }
        } else {
            System.out.println("Skipping null member");
        }
    }
    
    // Log collected players
    System.out.println("Collected " + players.size() + " valid players for BombTag");
    
    // Check if we have at least 2 valid players
    if (players.size() < 2) {
        System.out.println("Not enough valid players after filtering");
        broadcast(utils.MessageFormatter.formatSystemMessage("Not enough valid players to start Bomb Tag!"));
        bombTagGame = null;
        return;
    }
    
    // Start the game
    System.out.println("Starting game with " + players.size() + " players");
    try {
        if (!bombTagGame.startGame(players)) {
            System.out.println("Failed to start BombTag game");
            broadcast(utils.MessageFormatter.formatSystemMessage("Failed to start Bomb Tag game."));
            bombTagGame = null;
        } else {
            System.out.println("BombTag game started successfully");
            broadcast(utils.MessageFormatter.formatSystemMessage("Bomb Tag game has started!"));
        }
    } catch (Exception e) {
        System.out.println("Exception starting BombTag game: " + e.getMessage());
        e.printStackTrace();
        broadcast(utils.MessageFormatter.formatSystemMessage("Error starting Bomb Tag game: " + e.getMessage()));
        bombTagGame = null;
    }
}
}