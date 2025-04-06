// src/utils/BombTagGame.java
package utils;

import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;

public class BombTagGame {
    // Use a set instead of a map to avoid null issues
    private Set<String> players = ConcurrentHashMap.newKeySet();
    private String bombHolder = null;
    private ScheduledExecutorService scheduler;
    private ScheduledFuture<?> timerTask;
    private final int gameTime = 30; // seconds
    private final Random random = new Random();
    private AtomicBoolean gameActive = new AtomicBoolean(false);
    private String roomId;
    
    // Interface for game callbacks
    public interface GameCallback {
        void sendMessageToPlayer(String username, String message);
        void sendMessageToRoom(String message);
        void playerExploded(String username);
    }
    
    private GameCallback gameCallback;
    
    public BombTagGame(String roomId, GameCallback callback) {
        this.roomId = roomId;
        this.gameCallback = callback;
        this.scheduler = Executors.newScheduledThreadPool(1);
    }
    
    public synchronized boolean startGame(Set<String> participants) {
        // Extra debug output
        System.out.println("Starting BombTag game in room: " + roomId);
        System.out.println("Participants: " + (participants != null ? participants.size() : "null"));
        
        if (gameActive.get()) {
            System.out.println("Game already active");
            return false;
        }
        
        if (participants == null || participants.size() < 2) {
            System.out.println("Not enough participants");
            return false;
        }
        
        // Clear any existing players to start fresh
        players.clear();
        
        // Add all participants - with null check
        for (String player : participants) {
            if (player != null && !player.trim().isEmpty()) {
                System.out.println("Adding player: " + player);
                players.add(player);
            }
        }
        
        // Check if we have at least 2 players after filtering nulls
        if (players.size() < 2) {
            System.out.println("Not enough valid players after filtering");
            return false;
        }
        
        // Select random player to start with the bomb
        List<String> playerList = new ArrayList<>(players);
        bombHolder = playerList.get(random.nextInt(playerList.size()));
        System.out.println("Assigned bomb to: " + bombHolder);
        
        gameActive.set(true);
        
        // Announce game start
        gameCallback.sendMessageToRoom("🎮 BOMB TAG GAME STARTED! 🎮");
        gameCallback.sendMessageToRoom("The bomb has been randomly assigned...");
        gameCallback.sendMessageToRoom("Pass it quickly with /pass <username> before time runs out!");
        
        // Notify bomb holder
        gameCallback.sendMessageToPlayer(bombHolder, "💣 YOU HAVE THE BOMB! 💣 Pass it quickly with /pass <username>!");
        gameCallback.sendMessageToRoom("💣 " + bombHolder + " has the bomb! They have " + gameTime + " seconds to pass it!");
        
        // Start countdown
        startCountdown();
        
        return true;
    }
    
    private void startCountdown() {
        timerTask = scheduler.schedule(() -> {
            if (gameActive.get()) {
                // Game over - bomb explodes
                gameCallback.sendMessageToRoom("💥 BOOM! 💥 Time's up!");
                gameCallback.sendMessageToRoom("💀 " + bombHolder + " couldn't pass the bomb in time and exploded!");
                
                // Notify the exploded player
                gameCallback.playerExploded(bombHolder);
                
                // End game
                endGame();
            }
        }, gameTime, TimeUnit.SECONDS);
        
        // Send warnings
        if (gameTime > 10) {
            scheduler.schedule(() -> {
                if (gameActive.get()) {
                    gameCallback.sendMessageToRoom("⚠️ 10 SECONDS REMAINING! ⚠️");
                    gameCallback.sendMessageToPlayer(bombHolder, "⚠️ 10 SECONDS LEFT! HURRY! ⚠️");
                }
            }, gameTime - 10, TimeUnit.SECONDS);
        }
        
        if (gameTime > 5) {
            scheduler.schedule(() -> {
                if (gameActive.get()) {
                    gameCallback.sendMessageToRoom("⚠️ 5 SECONDS REMAINING! ⚠️");
                    gameCallback.sendMessageToPlayer(bombHolder, "⚠️ 5 SECONDS LEFT! HURRY! ⚠️");
                }
            }, gameTime - 5, TimeUnit.SECONDS);
        }
    }
    
    public synchronized boolean passBomb(String from, String to) {
        if (!gameActive.get() || from == null || to == null) {
            return false;
        }
        
        // Check if 'from' is the current bomb holder
        if (!from.equals(bombHolder)) {
            return false;
        }
        
        // Check if 'to' is a valid player
        if (!players.contains(to)) {
            return false;
        }
        
        // Pass the bomb
        bombHolder = to;
        
        // Announce the pass
        gameCallback.sendMessageToRoom("💣 " + from + " passed the bomb to " + to + "!");
        gameCallback.sendMessageToPlayer(bombHolder, "💣 YOU HAVE THE BOMB! 💣 Pass it quickly with /pass <username>!");
        
        // Reset the timer
        resetCountdown();
        
        return true;
    }
    
    private void resetCountdown() {
        // Cancel current timer
        if (timerTask != null) {
            timerTask.cancel(false);
        }
        
        // Start a new countdown
        startCountdown();
    }
    
    public synchronized void playerLeft(String username) {
        if (username == null) return;
        
        players.remove(username);
        System.out.println("Player left: " + username + ". Remaining players: " + players.size());
        
        // If the bomb holder left, assign to someone else
        if (username.equals(bombHolder) && gameActive.get()) {
            if (players.size() > 0) {
                // Select random player to get the bomb
                List<String> playerList = new ArrayList<>(players);
                bombHolder = playerList.get(random.nextInt(playerList.size()));
                
                gameCallback.sendMessageToRoom("💥 " + username + " left while holding the bomb!");
                gameCallback.sendMessageToRoom("💣 The bomb bounced to " + bombHolder + "!");
                gameCallback.sendMessageToPlayer(bombHolder, "💣 YOU HAVE THE BOMB! 💣 Pass it quickly with /pass <username>!");
                
                // Reset the timer
                resetCountdown();
            } else {
                // End game if no players left
                gameCallback.sendMessageToRoom("Game ended: Not enough players.");
                endGame();
            }
        }
        
        // End game if less than 2 players
        if (players.size() < 2 && gameActive.get()) {
            gameCallback.sendMessageToRoom("Game ended: Not enough players.");
            endGame();
        }
    }
    
    public synchronized void playerJoined(String username) {
        if (username == null) return;
        
        if (gameActive.get()) {
            players.add(username);
            System.out.println("Player joined: " + username + ". Total players: " + players.size());
            gameCallback.sendMessageToPlayer(username, "🎮 You joined an ongoing Bomb Tag game!");
            if (username.equals(bombHolder)) {
                gameCallback.sendMessageToPlayer(username, "💣 YOU HAVE THE BOMB! 💣 Pass it quickly with /pass <username>!");
            }
        }
    }
    
    public synchronized void endGame() {
        gameActive.set(false);
        
        if (timerTask != null) {
            timerTask.cancel(false);
        }
        
        players.clear();
        bombHolder = null;
        
        gameCallback.sendMessageToRoom("🎮 The Bomb Tag game has ended!");
        System.out.println("BombTag game ended in room: " + roomId);
    }
    
    public boolean isActive() {
        return gameActive.get();
    }
    
    public String getBombHolder() {
        return bombHolder;
    }
    
    public Set<String> getPlayers() {
        return new HashSet<>(players);
    }
    
    public String getRoomId() {
        return roomId;
    }
}