import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class ChatRoom {
    private String roomId;
    private String roomName;
    private String password;
    private boolean isPrivate;
    private Set<ClientHandler> members = ConcurrentHashMap.newKeySet();
    
    // Pokemon-themed icons for rooms
    private static final String JOIN_ROOM_ICON = "🏆 "; // Trophy for entering a gym/room
    private static final String LEAVE_ROOM_ICON = "🚶 "; // Person walking away
    private static final String ROOM_BROADCAST_ICON = "📣 "; // Announcement megaphone

    public ChatRoom(String roomName, String password) {
        this.roomId = utils.RoomIdGen.generate();
        this.roomName = roomName;
        this.password = password;
        this.isPrivate = (password != null && !password.isEmpty());
    }

    public void addMember(ClientHandler client) {
        members.add(client);
        broadcast(JOIN_ROOM_ICON + client.getUsername() + " entered the " + getPokemonRoomType() + ": " + roomName);
    }

    public void removeMember(ClientHandler client) {
        members.remove(client);
        broadcast(LEAVE_ROOM_ICON + client.getUsername() + " left the " + getPokemonRoomType() + ": " + roomName);
    }

    public void broadcast(String message) {
        for (ClientHandler member : members) {
            member.sendMessage(message);
        }
    }
    
    public void broadcastRoomMessage(String sender, String message) {
        String formattedMessage = ROOM_BROADCAST_ICON + "[" + roomName + "] " + sender + ": " + message;
        broadcast(formattedMessage);
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
    
    // Helper method to get Pokemon-appropriate room type name
    private String getPokemonRoomType() {
        if (isPrivate) {
            return "Secret Base";
        } else {
            return "Pokémon Gym";
        }
    }
    
    // Get room information with Pokemon theming
    public String getRoomInfo() {
        String visibility = isPrivate ? "🔒 Secret Base (password required)" : "🔓 Public Pokémon Gym";
        return roomName + " - " + visibility + " - Trainers: " + members.size();
    }
}