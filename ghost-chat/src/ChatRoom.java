// src/ChatRoom.java
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class ChatRoom {
    private String roomId;
    private String roomName;
    private String password;
    private boolean isPrivate;
    private Set<ClientHandler> members = ConcurrentHashMap.newKeySet();

    public ChatRoom(String roomName, String password) {
        this.roomId = utils.RoomIdGen.generate();
        this.roomName = roomName;
        this.password = password;
        this.isPrivate = (password != null && !password.isEmpty());
    }

    public void addMember(ClientHandler client) {
        members.add(client);
        broadcast("🔔 " + client.getUsername() + " joined room: " + roomName);
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
}