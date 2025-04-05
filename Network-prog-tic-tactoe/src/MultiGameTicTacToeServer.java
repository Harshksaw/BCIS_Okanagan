package src;
import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

/**
 * Server that supports multiple concurrent Tic-Tac-Toe games.
 */
public class MultiGameTicTacToeServer {
    private ServerSocket serverSocket;
    private final int port;
    private boolean running;
    private final List<GameSession> waitingGames;
    private final List<GameSession> activeGames;
    private final ExecutorService gameThreadPool;
    
    /**
     * Creates a new server on the specified port.
     */
    public MultiGameTicTacToeServer(int port) {
        this.port = port;
        this.waitingGames = new ArrayList<>();
        this.activeGames = new ArrayList<>();
        // Create a thread pool for handling game sessions
        this.gameThreadPool = Executors.newCachedThreadPool();
    }
    
    /**
     * Starts the server.
     */
    public void start() {
        try {
            serverSocket = new ServerSocket(port);
            running = true;
            System.out.println("Server started on port " + port);
            System.out.println("Waiting for players to connect...");
            
            // Start a background thread to clean up finished games
            startCleanupThread();
            
            // Main server loop
            while (running) {
                try {
                    Socket clientSocket = serverSocket.accept();
                    handleNewConnection(clientSocket);
                } catch (IOException e) {
                    if (running) {
                        System.out.println("Error accepting connection: " + e.getMessage());
                    }
                }
            }
        } catch (IOException e) {
            System.out.println("Could not start server: " + e.getMessage());
        } finally {
            shutdown();
        }
    }
    
    /**
     * Handles a new client connection.
     */
    private void handleNewConnection(Socket clientSocket) {
        try {
            System.out.println("New connection from " + clientSocket.getInetAddress());
            
            // Send game options to the client
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
            
            // If there are waiting games, list them
            if (!waitingGames.isEmpty()) {
                out.println("AVAILABLE_GAMES " + waitingGames.size());
                for (int i = 0; i < waitingGames.size(); i++) {
                    GameSession game = waitingGames.get(i);
                    out.println("GAME " + i + " " + game.getGameId());
                }
            } else {
                out.println("NO_GAMES_AVAILABLE");
            }
            
            // Wait for client to choose an option
            String choice = in.readLine();
            
            if (choice != null) {
                if (choice.startsWith("JOIN ")) {
                    // Join an existing game
                    int gameIndex;
                    try {
                        gameIndex = Integer.parseInt(choice.substring(5));
                        if (gameIndex >= 0 && gameIndex < waitingGames.size()) {
                            GameSession game = waitingGames.get(gameIndex);
                            waitingGames.remove(gameIndex);
                            
                            // Add player O to the game
                            game.setPlayerO(clientSocket);
                            
                            // Move to active games and start the game
                            activeGames.add(game);
                            gameThreadPool.submit(game);
                        } else {
                            // Invalid game index
                            out.println("INVALID_GAME");
                            clientSocket.close();
                        }
                    } catch (NumberFormatException e) {
                        out.println("INVALID_CHOICE");
                        clientSocket.close();
                    }
                } else if (choice.equals("CREATE")) {
                    // Create a new game
                    GameSession newGame = new GameSession();
                    newGame.setPlayerX(clientSocket);
                    waitingGames.add(newGame);
                    System.out.println("New game created: " + newGame.getGameId());
                } else {
                    // Invalid choice
                    out.println("INVALID_CHOICE");
                    clientSocket.close();
                }
            }
        } catch (IOException e) {
            System.out.println("Error handling connection: " + e.getMessage());
            try {
                clientSocket.close();
            } catch (IOException ex) {
                // Ignore
            }
        }
    }
    
    /**
     * Starts a background thread to clean up finished games.
     */
    private void startCleanupThread() {
        Thread cleanupThread = new Thread(() -> {
            while (running) {
                try {
                    // Remove inactive games
                    Iterator<GameSession> iterator = activeGames.iterator();
                    while (iterator.hasNext()) {
                        GameSession game = iterator.next();
                        if (!game.isActive()) {
                            iterator.remove();
                            System.out.println("Removed finished game: " + game.getGameId());
                        }
                    }
                    
                    // Sleep for a bit
                    Thread.sleep(10000); // Check every 10 seconds
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });
        cleanupThread.setDaemon(true);
        cleanupThread.start();
    }
    
    /**
     * Shuts down the server.
     */
    public void shutdown() {
        running = false;
        gameThreadPool.shutdown();
        
        try {
            if (!gameThreadPool.awaitTermination(5, TimeUnit.SECONDS)) {
                gameThreadPool.shutdownNow();
            }
        } catch (InterruptedException e) {
            gameThreadPool.shutdownNow();
            Thread.currentThread().interrupt();
        }
        
        try {
            if (serverSocket != null && !serverSocket.isClosed()) {
                serverSocket.close();
            }
        } catch (IOException e) {
            System.out.println("Error closing server: " + e.getMessage());
        }
        
        System.out.println("Server shutdown complete");
    }
    
    /**
     * Main method to start the server.
     */
    public static void main(String[] args) {
        int port = 5007; // Default port
        if (args.length > 0) {
            try {
                port = Integer.parseInt(args[0]);
            } catch (NumberFormatException e) {
                System.out.println("Invalid port number. Using default port 5007.");
            }
        }
        
        MultiGameTicTacToeServer server = new MultiGameTicTacToeServer(port);
        
        // Add shutdown hook to handle CTRL+C gracefully
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("Shutting down server...");
            server.shutdown();
        }));
        
        server.start();
    }
}