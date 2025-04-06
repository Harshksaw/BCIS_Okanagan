// src/Server.java
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

public class Server {
    private static final int PORT = 5000;
    private static Set<ClientHandler> clients = ConcurrentHashMap.newKeySet();
    private static Map<String, ChatRoom> rooms = new ConcurrentHashMap<>();
    
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket(PORT);
        System.out.println("GhostChat server running on port " + PORT);
        
        // Create default public room
        ChatRoom publicRoom = new ChatRoom("Public", "");
        rooms.put(publicRoom.getRoomId(), publicRoom);
        System.out.println("Created default public room with ID: " + publicRoom.getRoomId());
        
        while (true) {
            Socket socket = serverSocket.accept();
            System.out.println("New client connected: " + socket.getInetAddress().getHostAddress());
            ClientHandler handler = new ClientHandler(socket, clients);
            clients.add(handler);
            new Thread(handler).start();
        }
    }
    
    public static void addRoom(ChatRoom room) {
        rooms.put(room.getRoomId(), room);
        System.out.println("New room created: " + room.getRoomName() + " (ID: " + room.getRoomId() + ")");
    }
    
    public static void removeRoom(ChatRoom room) {
        rooms.remove(room.getRoomId());
        System.out.println("Room removed: " + room.getRoomName() + " (ID: " + room.getRoomId() + ")");
    }
    
    public static ChatRoom getRoomById(String roomId) {
        return rooms.get(roomId);
    }
    
    public static List<ChatRoom> getPublicRooms() {
        List<ChatRoom> publicRooms = new ArrayList<>();
        for (ChatRoom room : rooms.values()) {
            if (!room.isPrivate()) {
                publicRooms.add(room);
            }
        }
        return publicRooms;
    }
}