package src;
import java.io.*;
import java.net.*;
import java.util.UUID;

/**
 * Represents a single game session between two players.
 * Each game session runs in its own thread.
 */
public class GameSession implements Runnable {
    private final String gameId;
    private Socket playerXSocket;
    private Socket playerOSocket;
    private PrintWriter playerXOutput;
    private BufferedReader playerXInput;
    private PrintWriter playerOOutput;
    private BufferedReader playerOInput;
    private TicTacToeGame game;
    private boolean gameActive;
    
    /**
     * Creates a new game session.
     */
    public GameSession() {
        this.gameId = UUID.randomUUID().toString().substring(0, 8);
        this.game = new TicTacToeGame();
        this.gameActive = true;
    }
    
    /**
     * Returns the unique game ID.
     */
    public String getGameId() {
        return gameId;
    }
    
    /**
     * Sets the socket for player X.
     */
    public void setPlayerX(Socket socket) throws IOException {
        this.playerXSocket = socket;
        this.playerXOutput = new PrintWriter(socket.getOutputStream(), true);
        this.playerXInput = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        this.playerXOutput.println("WELCOME X");
        this.playerXOutput.println("GAME_ID " + gameId);
        this.playerXOutput.println("MESSAGE Waiting for opponent to join...");
    }
    
    /**
     * Sets the socket for player O.
     */
    public void setPlayerO(Socket socket) throws IOException {
        this.playerOSocket = socket;
        this.playerOOutput = new PrintWriter(socket.getOutputStream(), true);
        this.playerOInput = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        this.playerOOutput.println("WELCOME O");
        this.playerOOutput.println("GAME_ID " + gameId);
        
        // Both players are now connected, start the game
        startGame();
    }
    
    /**
     * Checks if the game has both players.
     */
    public boolean isReady() {
        return playerXSocket != null && playerOSocket != null;
    }
    
    /**
     * Checks if the game is active.
     */
    public boolean isActive() {
        return gameActive;
    }
    
    /**
     * Starts the game by notifying both players and sending the initial board.
     */
    private void startGame() {
        playerXOutput.println("MESSAGE Game is starting! You are Player X. You go first.");
        playerOOutput.println("MESSAGE Game is starting! You are Player O. Wait for your turn.");
        
        // Send initial board state
        updateBoardForBothPlayers();
        
        // Player X goes first
        playerXOutput.println("YOUR_TURN");
    }
    
    /**
     * Updates the board for both players.
     */
    private void updateBoardForBothPlayers() {
        String boardStr = game.getBoardString();
        playerXOutput.println("BOARD " + boardStr);
        playerOOutput.println("BOARD " + boardStr);
    }
    
    /**
     * Notifies the opponent when a player disconnects.
     */
    private void handleDisconnect(char playerMark) {
        if (playerMark == 'X' && playerOOutput != null) {
            playerOOutput.println("OPPONENT_DISCONNECTED");
        } else if (playerMark == 'O' && playerXOutput != null) {
            playerXOutput.println("OPPONENT_DISCONNECTED");
        }
        endGame();
    }
    
    /**
     * Ends the game session.
     */
    private void endGame() {
        gameActive = false;
        try {
            if (playerXSocket != null && !playerXSocket.isClosed()) {
                playerXSocket.close();
            }
            if (playerOSocket != null && !playerOSocket.isClosed()) {
                playerOSocket.close();
            }
        } catch (IOException e) {
            System.out.println("Error closing connections in game " + gameId + ": " + e.getMessage());
        }
    }
    
    /**
     * Processes a move from a player.
     */
    private void processMove(int position, char playerMark) {
        if (game.makeMove(position, playerMark)) {
            updateBoardForBothPlayers();
            
            if (game.isGameOver()) {
                char winner = game.getWinner();
                if (winner != ' ') {
                    playerXOutput.println("GAME_OVER Player " + winner + " wins!");
                    playerOOutput.println("GAME_OVER Player " + winner + " wins!");
                } else {
                    playerXOutput.println("GAME_OVER It's a draw!");
                    playerOOutput.println("GAME_OVER It's a draw!");
                }
                
                // End the game after a short delay to ensure messages are sent
                new Thread(() -> {
                    try {
                        Thread.sleep(2000);
                        endGame();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }).start();
            } else {
                // Switch turns
                if (playerMark == 'X') {
                    playerOOutput.println("YOUR_TURN");
                } else {
                    playerXOutput.println("YOUR_TURN");
                }
            }
        } else {
            // Invalid move
            if (playerMark == 'X') {
                playerXOutput.println("INVALID_MOVE");
                playerXOutput.println("YOUR_TURN");
            } else {
                playerOOutput.println("INVALID_MOVE");
                playerOOutput.println("YOUR_TURN");
            }
        }
    }
    
    /**
     * The main game loop, handles player input and game logic.
     */
    @Override
    public void run() {
        System.out.println("Game " + gameId + " started");
        
        // Create threads to handle player inputs
        Thread playerXThread = new Thread(() -> {
            try {
                String input;
                while ((input = playerXInput.readLine()) != null && gameActive) {
                    if (input.startsWith("MOVE")) {
                        try {
                            int position = Integer.parseInt(input.substring(5));
                            processMove(position, 'X');
                        } catch (NumberFormatException e) {
                            playerXOutput.println("INVALID_MOVE");
                            playerXOutput.println("YOUR_TURN");
                        }
                    }
                }
            } catch (IOException e) {
                System.out.println("Player X disconnected from game " + gameId);
            } finally {
                handleDisconnect('X');
            }
        });
        
        Thread playerOThread = new Thread(() -> {
            try {
                String input;
                while ((input = playerOInput.readLine()) != null && gameActive) {
                    if (input.startsWith("MOVE")) {
                        try {
                            int position = Integer.parseInt(input.substring(5));
                            processMove(position, 'O');
                        } catch (NumberFormatException e) {
                            playerOOutput.println("INVALID_MOVE");
                            playerOOutput.println("YOUR_TURN");
                        }
                    }
                }
            } catch (IOException e) {
                System.out.println("Player O disconnected from game " + gameId);
            } finally {
                handleDisconnect('O');
            }
        });
        
        playerXThread.start();
        playerOThread.start();
        
        // Wait for both threads to finish
        try {
            playerXThread.join();
            playerOThread.join();
        } catch (InterruptedException e) {
            System.out.println("Game " + gameId + " interrupted: " + e.getMessage());
        }
        
        System.out.println("Game " + gameId + " ended");
    }
}