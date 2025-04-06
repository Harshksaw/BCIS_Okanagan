package src;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.net.*;
import java.util.*;

/**
 * A GUI client for the Tic-Tac-Toe network game.
 * Allows users to connect to a server, create or join games, and play with a
 * graphical interface.
 * 
 * @author Kartik
 */
public class TicTacToeGUIClient extends JFrame {
    private static final long serialVersionUID = 1L;

    // Colors
    private static final Color BACKGROUND_COLOR = new Color(240, 248, 255); // Alice Blue
    private static final Color PANEL_COLOR = new Color(230, 240, 250);
    private static final Color BUTTON_COLOR = new Color(70, 130, 180); // Steel Blue
    private static final Color BUTTON_TEXT_COLOR = Color.WHITE;
    private static final Color X_COLOR = new Color(0, 102, 204); // Blue
    private static final Color O_COLOR = new Color(204, 51, 0); // Red
    private static final Color HIGHLIGHT_COLOR = new Color(255, 215, 0); // Gold
    private static final Color BOARD_BUTTON_COLOR = new Color(230, 230, 230);
    private static final Color BOARD_BORDER_COLOR = new Color(100, 100, 100);

    private void styleButton(JButton button) {
        button.setBackground(BUTTON_COLOR);
        button.setForeground(BUTTON_TEXT_COLOR);
        button.setFocusPainted(false);
        button.setOpaque(true);
        button.setBorderPainted(false);
    }
    // Network components
    private Socket socket;
    private PrintWriter out;
    private BufferedReader in;
    private String serverAddress = "localhost";
    private int serverPort = 5007;

    // Game state
    private char playerMark;
    private char[] board = new char[9];
    private boolean gameActive = false;
    private String gameId = "";
    private boolean myTurn = false;
    private String playerName = "Kartik";
    private String opponentName = "Opponent";

    // Debug mode
    private boolean debugMode = true;

    // GUI components
    private JPanel mainPanel;
    private JPanel connectionPanel;
    private JPanel gameListPanel;
    private JPanel boardPanel;
    private JPanel statusPanel;
    private JPanel playerInfoPanel;

    private JTextField serverField;
    private JTextField portField;
    private JTextField nameField;
    private JButton connectButton;

    private JButton[] boardButtons = new JButton[9];
    private JButton createGameButton;
    private JLabel statusLabel;
    private JList<String> gameList;
    private DefaultListModel<String> gameListModel;
    private JButton joinGameButton;
    private JScrollPane gameScrollPane;
    private JTextArea debugTextArea;

    // Player info labels
    private JLabel playerXLabel;
    private JLabel playerOLabel;

    // Maps to store game information
    private Map<String, Integer> gameIndices = new HashMap<>();

    /**
     * Creates a new GUI client.
     */
    public TicTacToeGUIClient() {
        for (int i = 0; i < 9; i++) board[i] = ' ';
        setTitle("Tic-Tac-Toe Network Game - Made by Kartik");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(950, 650);
        setLocationRelativeTo(null);
        setBackground(BACKGROUND_COLOR);

        mainPanel = new JPanel(new BorderLayout(10, 10));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        mainPanel.setBackground(BACKGROUND_COLOR);

        createConnectionPanel();
        createPlayerInfoPanel();
        createGameListPanel();
        createBoardPanel();
        createStatusPanel();
        if (debugMode) createDebugPanel();

        JLabel signatureLabel = new JLabel("Made by Kartik", JLabel.RIGHT);
        signatureLabel.setForeground(new Color(50, 50, 150));
        signatureLabel.setFont(new Font("Arial", Font.ITALIC, 12));
        signatureLabel.setBorder(new EmptyBorder(10, 0, 10, 10));
        mainPanel.add(signatureLabel, BorderLayout.SOUTH);

        add(mainPanel);
        setComponentsEnabled(false);
        setVisible(true);
    }
    /**
     * Creates the connection panel with server address and port inputs.
     */
    private void createConnectionPanel() {
        connectionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        connectionPanel.setBackground(PANEL_COLOR);
        connectionPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                "Connection Settings", TitledBorder.LEFT, TitledBorder.TOP,
                new Font("Arial", Font.BOLD, 12)));

        JLabel serverLabel = new JLabel("Server:");
        serverField = new JTextField(serverAddress, 10);

        JLabel portLabel = new JLabel("Port:");
        portField = new JTextField(String.valueOf(serverPort), 5);

        JLabel nameLabel = new JLabel("Your Name:");
        nameField = new JTextField(playerName, 10);

        connectButton = new JButton("Connect");
        styleButton(connectButton);
        // connectButton.setBackground(BUTTON_COLOR);
        // connectButton.setForeground(BUTTON_TEXT_COLOR);
        // connectButton.setFocusPainted(false);
        connectButton.addActionListener(e -> connectToServer());

        connectionPanel.add(serverLabel);
        connectionPanel.add(serverField);
        connectionPanel.add(portLabel);
        connectionPanel.add(portField);
        connectionPanel.add(nameLabel);
        connectionPanel.add(nameField);
        connectionPanel.add(connectButton);

        JPanel topPanel = new JPanel(new BorderLayout());
        topPanel.setBackground(BACKGROUND_COLOR);
        topPanel.add(connectionPanel, BorderLayout.NORTH);

        mainPanel.add(topPanel, BorderLayout.NORTH);
    }

    /**
     * Creates the player info panel.
     */
    private void createPlayerInfoPanel() {
        playerInfoPanel = new JPanel(new GridLayout(1, 2, 20, 0));
        playerInfoPanel.setBackground(PANEL_COLOR);
        playerInfoPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                "Players", TitledBorder.LEFT, TitledBorder.TOP,
                new Font("Arial", Font.BOLD, 12)));

        playerXLabel = new JLabel("Player X: " + playerName, JLabel.CENTER);
        playerXLabel.setForeground(X_COLOR);
        playerXLabel.setFont(new Font("Arial", Font.BOLD, 14));

        playerOLabel = new JLabel("Player O: Waiting...", JLabel.CENTER);
        playerOLabel.setForeground(O_COLOR);
        playerOLabel.setFont(new Font("Arial", Font.BOLD, 14));

        playerInfoPanel.add(playerXLabel);
        playerInfoPanel.add(playerOLabel);

        JPanel topPanel = (JPanel) mainPanel.getComponent(0);
        topPanel.add(playerInfoPanel, BorderLayout.CENTER);
    }

    /**
     * Creates the game list panel with available games and options to create/join.
     */
    private void createGameListPanel() {
        gameListPanel = new JPanel(new BorderLayout(5, 5));
        gameListPanel.setBackground(PANEL_COLOR);
        gameListPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                "Available Games", TitledBorder.LEFT, TitledBorder.TOP,
                new Font("Arial", Font.BOLD, 12)));

        gameListModel = new DefaultListModel<>();
        gameList = new JList<>(gameListModel);
        gameList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        gameList.setBackground(new Color(255, 255, 240));
        gameList.setFont(new Font("Arial", Font.PLAIN, 14));
        gameScrollPane = new JScrollPane(gameList);

        JPanel buttonPanel = new JPanel(new GridLayout(2, 1, 5, 5));
        buttonPanel.setBackground(PANEL_COLOR);

        createGameButton = new JButton("Create New Game");
        styleButton(createGameButton);
   
        createGameButton.addActionListener(e -> createGame());

        joinGameButton = new JButton("Join Selected Game");
        styleButton(joinGameButton);
       
        joinGameButton.addActionListener(e -> joinSelectedGame());

        buttonPanel.add(createGameButton);
        buttonPanel.add(joinGameButton);
        gameListPanel.add(gameScrollPane, BorderLayout.CENTER);
        gameListPanel.add(buttonPanel, BorderLayout.SOUTH);
        gameListPanel.setPreferredSize(new Dimension(200, 300));
        mainPanel.add(gameListPanel, BorderLayout.WEST);
    
    }

    /**
     * Creates the game board panel with the 3x3 grid of buttons.
     */
    private void createBoardPanel() {
        boardPanel = new JPanel(new GridLayout(3, 3, 8, 8));
boardPanel.setBackground(new Color(153, 204, 255));
        boardPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                "Game Board", TitledBorder.LEFT, TitledBorder.TOP,
                new Font("Arial", Font.BOLD, 12)));
                for (int i = 0; i < 9; i++) {
                    final int position = i;
                    boardButtons[i] = new JButton("");
                    boardButtons[i].setFont(new Font("Arial", Font.BOLD, 70));
                    boardButtons[i].setFocusPainted(false);
                    boardButtons[i].setBackground(new Color(230, 230, 230)); // Light gray for buttons instead of white
                    boardButtons[i].setBorder(BorderFactory.createLineBorder(new Color(100, 100, 100), 2)); // Darker border
                    boardButtons[i].addActionListener(e -> makeMove(position));
                    boardPanel.add(boardButtons[i]);
                }

        JPanel centerPanel = new JPanel(new BorderLayout());
        centerPanel.setBackground(BACKGROUND_COLOR);
        centerPanel.add(boardPanel, BorderLayout.CENTER);

        mainPanel.add(centerPanel, BorderLayout.CENTER);
    }

    /**
     * Creates the status panel with game status information.
     */
    private void createStatusPanel() {
        statusPanel = new JPanel(new BorderLayout());
        statusPanel.setBackground(PANEL_COLOR);
        statusPanel.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                        "Game Status", TitledBorder.LEFT, TitledBorder.TOP,
                        new Font("Arial", Font.BOLD, 12)),
                BorderFactory.createEmptyBorder(5, 5, 5, 5)));

        statusLabel = new JLabel("Not connected to server", JLabel.CENTER);
        statusLabel.setHorizontalAlignment(JLabel.CENTER);
        statusLabel.setFont(new Font("Arial", Font.BOLD, 16));

        statusPanel.add(statusLabel, BorderLayout.CENTER);

        // Create a bottom panel to hold status and signature
        JPanel bottomPanel = new JPanel(new BorderLayout());
        bottomPanel.setBackground(BACKGROUND_COLOR);
        bottomPanel.add(statusPanel, BorderLayout.CENTER);

        JLabel signatureLabel = new JLabel("© Developed by Kartik", JLabel.RIGHT);
        signatureLabel.setFont(new Font("Arial", Font.ITALIC, 12));
        signatureLabel.setForeground(new Color(100, 100, 100));
        signatureLabel.setBorder(new EmptyBorder(5, 0, 5, 10));

        bottomPanel.add(signatureLabel, BorderLayout.SOUTH);
        mainPanel.add(bottomPanel, BorderLayout.SOUTH);
    }

    /**
     * Creates a debug panel to show server messages.
     */
    private void createDebugPanel() {
        JPanel debugPanel = new JPanel(new BorderLayout(5, 5));
        debugPanel.setBackground(PANEL_COLOR);
        debugPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(),
                "Debug Log", TitledBorder.LEFT, TitledBorder.TOP,
                new Font("Arial", Font.BOLD, 12)));

        debugTextArea = new JTextArea();
        debugTextArea.setEditable(false);
        debugTextArea.setFont(new Font("Monospaced", Font.PLAIN, 12));
        debugTextArea.setBackground(new Color(240, 240, 240));

        JScrollPane scrollPane = new JScrollPane(debugTextArea);
        scrollPane.setPreferredSize(new Dimension(250, 300));

        debugPanel.add(scrollPane, BorderLayout.CENTER);

        JButton clearButton = new JButton("Clear Log");
        clearButton.setBackground(BUTTON_COLOR);
        clearButton.setForeground(BUTTON_TEXT_COLOR);
        clearButton.setFocusPainted(false);
        clearButton.addActionListener(e -> debugTextArea.setText(""));

        debugPanel.add(clearButton, BorderLayout.SOUTH);

        mainPanel.add(debugPanel, BorderLayout.EAST);
    }

    /**
     * Adds a message to the debug log.
     */
    private void logDebug(String message) {
        if (debugMode && debugTextArea != null) {
            debugTextArea.append(message + "\n");
            debugTextArea.setCaretPosition(debugTextArea.getDocument().getLength());
        }
    }

    /**
     * Enables or disables game components based on connection status.
     */
    private void setComponentsEnabled(boolean enabled) {
        createGameButton.setEnabled(enabled);
        joinGameButton.setEnabled(enabled);
        gameList.setEnabled(enabled);

        for (JButton button : boardButtons) {
            button.setEnabled(enabled && myTurn && gameActive && button.getText().isEmpty());
        }
    }

    /**
     * Updates player information in the UI.
     */
    private void updatePlayerInfo() {
        if (playerMark == 'X') {
            playerXLabel.setText("Player X: " + playerName + " (YOU)");
            playerXLabel.setFont(new Font("Arial", Font.BOLD, 16)); // Larger font
            playerOLabel.setText("Player O: " + opponentName);
        } else if (playerMark == 'O') {
            playerXLabel.setText("Player X: " + opponentName);
            playerOLabel.setText("Player O: " + playerName + " (YOU)");
            playerOLabel.setFont(new Font("Arial", Font.BOLD, 16)); // Larger font
        } else {
            playerXLabel.setText("Player X: Waiting...");
            playerOLabel.setText("Player O: Waiting...");
        }
    }

    /**
     * Connects to the server using the provided address and port.
     */
    private void connectToServer() {
        try {
            // Get server address and port from text fields
            serverAddress = serverField.getText();
            playerName = nameField.getText();
            if (playerName == null || playerName.trim().isEmpty()) {
                playerName = "Player";
            }

            try {
                serverPort = Integer.parseInt(portField.getText());
            } catch (NumberFormatException e) {
                JOptionPane.showMessageDialog(this, "Invalid port number", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }

            // Update status
            statusLabel.setText("Connecting to server...");

            // Create socket connection
            socket = new Socket(serverAddress, serverPort);
            out = new PrintWriter(socket.getOutputStream(), true);
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

            // Update UI
            connectButton.setEnabled(false);
            serverField.setEnabled(false);
            portField.setEnabled(false);
            nameField.setEnabled(false);
            statusLabel.setText("Connected to server");

            // Enable game components
            setComponentsEnabled(true);

            // Start the server listener thread
            new Thread(this::listenToServer).start();

        } catch (IOException e) {
            JOptionPane.showMessageDialog(this,
                    "Could not connect to server: " + e.getMessage(),
                    "Connection Error",
                    JOptionPane.ERROR_MESSAGE);
            statusLabel.setText("Connection failed");
        }
    }

    /**
     * Listens for messages from the server.
     */
    private void listenToServer() {
        try {
            String message;
            while ((message = in.readLine()) != null) {
                final String msg = message;
                logDebug("RECV: " + msg);
                SwingUtilities.invokeLater(() -> processServerMessage(msg));
            }
        } catch (IOException e) {
            if (gameActive) {
                SwingUtilities.invokeLater(() -> {
                    statusLabel.setText("Connection to server lost");
                    JOptionPane.showMessageDialog(this,
                            "Lost connection to server: " + e.getMessage(),
                            "Connection Error",
                            JOptionPane.ERROR_MESSAGE);
                    resetGame();
                });
            }
        }
    }

    /**
     * Processes messages received from the server.
     */
    private void processServerMessage(String message) {
        try {
            if (message.startsWith("AVAILABLE_GAMES")) {
                // Clear the current list
                gameListModel.clear();
                gameIndices.clear();

                int numGames = Integer.parseInt(message.substring(16));
                statusLabel.setText("Available games: " + numGames);

                if (numGames == 0) {
                    statusLabel.setText("No games available. Create a new game.");
                }
            } else if (message.startsWith("GAME ")) {
                try {
                    // Format: "GAME <index> <gameId>"
                    String[] parts = message.split(" ", 3);
                    logDebug("Game parts: " + Arrays.toString(parts));

                    if (parts.length >= 3) {
                        int index = Integer.parseInt(parts[1]);
                        String gameId = parts[2];

                        // Store both game info and display in list
                        String displayText = "Game " + index;
                        gameListModel.addElement(displayText);
                        gameIndices.put(displayText, index);
                        logDebug("Added game: " + displayText + " with index " + index);
                    }
                } catch (NumberFormatException e) {
                    logDebug("Error parsing game index: " + e.getMessage() + " in message: " + message);
                }
            } else if (message.equals("NO_GAMES_AVAILABLE")) {
                statusLabel.setText("No games available. Create a new game.");
            } else if (message.startsWith("WELCOME")) {
                playerMark = message.charAt(8);
                statusLabel.setText("You are player " + playerMark);
                updatePlayerInfo();
            } else if (message.startsWith("GAME_ID")) {
                gameId = message.substring(8);
                statusLabel.setText("Game ID: " + gameId);
            } else if (message.startsWith("MESSAGE")) {
                String serverMsg = message.substring(8);
                statusLabel.setText(serverMsg);
            } else if (message.startsWith("BOARD")) {
                statusLabel.setForeground(Color.BLACK); 
                // Update board state
                String boardStr = message.substring(6);
                updateBoard(boardStr);
            } else if (message.startsWith("YOUR_TURN")) {
                myTurn = true;
                statusLabel.setText("Your turn (Player " + playerMark + ")");
                // Enable board buttons
                statusLabel.setForeground(Color.BLACK); // Green color
                for (int i = 0; i < 9; i++) {
                    boardButtons[i].setEnabled(board[i] == ' ' && gameActive);
                }
            } else if (message.startsWith("INVALID_MOVE")) {
                statusLabel.setText("Invalid move, try again");
            } else if (message.startsWith("GAME_OVER")) {
                String result = message.substring(10);
                statusLabel.setText(result);
                gameActive = false;
                myTurn = false;

                // Highlight winning line if it's a win
                if (result.contains("wins")) {
                    char winner = ' ';
                    if (result.contains("X wins")) {
                        winner = 'X';
                    } else if (result.contains("O wins")) {
                        winner = 'O';
                    }

                    if (winner != ' ') {
                        highlightWinningLine(winner);
                    }
                }

                // Create a custom winner dialog
                createWinnerDialog(result);

                // Disable the board
                for (JButton button : boardButtons) {
                    button.setEnabled(false);
                }
            } else if (message.startsWith("OPPONENT_DISCONNECTED")) {
                statusLabel.setText("Your opponent has disconnected");
                JOptionPane.showMessageDialog(this,
                        "Your opponent has disconnected from the game.",
                        "Opponent Left",
                        JOptionPane.INFORMATION_MESSAGE);
                gameActive = false;
                myTurn = false;

                // Disable the board
                for (JButton button : boardButtons) {
                    button.setEnabled(false);
                }
            } else if (message.startsWith("INVALID_CHOICE") || message.equals("INVALID_GAME")) {
                statusLabel.setText("Invalid selection");
                JOptionPane.showMessageDialog(this,
                        "Invalid selection. Please try again.",
                        "Error",
                        JOptionPane.ERROR_MESSAGE);
            } else {
                // Handle any other messages - just log them for debugging
                logDebug("Unhandled message: " + message);
            }
        } catch (Exception e) {
            logDebug("Error processing message: " + message);
            logDebug("Exception: " + e);
            e.printStackTrace(new PrintStream(new OutputStream() {
                @Override
                public void write(int b) {
                    // Redirect to debug log
                    logDebug(String.valueOf((char) b));
                }
            }));
        }
    }

    /**
     * Updates the board display based on the server's board state.
     */
    private void updateBoard(String boardStr) {
        for (int i = 0; i < 9 && i < boardStr.length(); i++) {
            board[i] = boardStr.charAt(i);
          if (board[i] == 'X') {
    boardButtons[i].setText("X");
    boardButtons[i].setForeground(new Color(0, 0, 150)); // Deep blue for X
    boardButtons[i].setFont(new Font("Arial", Font.BOLD, 70));
} else if (board[i] == 'O') {
    boardButtons[i].setText("O");
    boardButtons[i].setForeground(new Color(150, 0, 0)); // Deep red for O
    boardButtons[i].setFont(new Font("Arial", Font.BOLD, 70));
} else {
    boardButtons[i].setText("");
}
        }
    }

    /**
     * Highlights the winning line on the board.
     */
    private void highlightWinningLine(char winner) {
        // Check rows
        for (int i = 0; i < 9; i += 3) {
            if (board[i] == winner && board[i + 1] == winner && board[i + 2] == winner) {
                highlightButtons(i, i + 1, i + 2);
                return;
            }
        }

        // Check columns
        for (int i = 0; i < 3; i++) {
            if (board[i] == winner && board[i + 3] == winner && board[i + 6] == winner) {
                highlightButtons(i, i + 3, i + 6);
                return;
            }
        }

        // Check diagonals
        if (board[0] == winner && board[4] == winner && board[8] == winner) {
            highlightButtons(0, 4, 8);
            return;
        }
        if (board[2] == winner && board[4] == winner && board[6] == winner) {
            highlightButtons(2, 4, 6);
            return;
        }
    }

    /**
     * Highlights the specified buttons to show the winning line.
     */
    private void highlightButtons(int... positions) {
        for (int pos : positions) {
            boardButtons[pos].setBackground(HIGHLIGHT_COLOR);
            boardButtons[pos].setOpaque(true);
            boardButtons[pos].setBorderPainted(false);
        }
    }

    /**
     * Creates a custom winner dialog with animation.
     */
    private void createWinnerDialog(String result) {
        JDialog winnerDialog = new JDialog(this, "Game Over!", true);
        winnerDialog.setLayout(new BorderLayout());
        winnerDialog.getContentPane().setBackground(BACKGROUND_COLOR);

        JPanel contentPanel = new JPanel(new BorderLayout(0, 20));
        contentPanel.setBackground(BACKGROUND_COLOR);
        contentPanel.setBorder(BorderFactory.createEmptyBorder(20, 30, 20, 30));

        JLabel resultLabel = new JLabel(result, JLabel.CENTER);
        resultLabel.setFont(new Font("Arial", Font.BOLD, 20));
        resultLabel.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createEmptyBorder(5, 5, 5, 5),
                BorderFactory.createCompoundBorder(
                        BorderFactory.createLineBorder(new Color(200, 200, 200), 1),
                        BorderFactory.createEmptyBorder(10, 10, 10, 10))));

        // Set color based on winner
        if (result.contains("X wins")) {
            resultLabel.setForeground(X_COLOR);
        } else if (result.contains("O wins")) {
            resultLabel.setForeground(O_COLOR);
        }

        contentPanel.add(resultLabel, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel();
        buttonPanel.setBackground(BACKGROUND_COLOR);

        JButton newGameButton = new JButton("New Game");
        newGameButton.setBackground(BUTTON_COLOR);
        newGameButton.setForeground(Color.BLACK);
        newGameButton.setFocusPainted(false);
        newGameButton.setOpaque(true);
        newGameButton.setBorderPainted(false);
        newGameButton.addActionListener(e -> {
            winnerDialog.dispose();
            int option = JOptionPane.showConfirmDialog(
                    this,
                    "Would you like to start a new game?",
                    "New Game",
                    JOptionPane.YES_NO_OPTION);
            if (option == JOptionPane.YES_OPTION) {
                createGame();
            }
        });

        buttonPanel.add(newGameButton);

        contentPanel.add(buttonPanel, BorderLayout.SOUTH);

        // Add a signature at the bottom
        JLabel signatureLabel = new JLabel("Made by Kartik", JLabel.RIGHT);
        signatureLabel.setFont(new Font("Arial", Font.ITALIC, 12));
        signatureLabel.setForeground(new Color(100, 100, 100));
        contentPanel.add(signatureLabel, BorderLayout.NORTH);

        winnerDialog.add(contentPanel);

        // Add a simple animation effect
        javax.swing.Timer timer = new javax.swing.Timer(100, null);
        final int[] size = { 20 };

        timer.addActionListener(e -> {
            if (size[0] < 30) {
                size[0]++;
                resultLabel.setFont(new Font("Arial", Font.BOLD, size[0]));
            } else {
                timer.stop();
            }
        });

        winnerDialog.setSize(400, 250);
        winnerDialog.setLocationRelativeTo(this);
        timer.start();
        winnerDialog.setVisible(true);
    }

    /**
     * Creates a new game on the server.
     */
    private void createGame() {
        if (out != null) {
            logDebug("SEND: CREATE");
            out.println("CREATE");
            gameActive = true;
            statusLabel.setText("Creating new game...");

            // Clear the board
            resetBoardDisplay();
        }
    }

    /**
     * Joins the selected game from the game list.
     */
    private void joinSelectedGame() {
        String selectedGame = gameList.getSelectedValue();
        if (selectedGame != null) {
            // Get the index associated with this display string
            Integer gameIndex = gameIndices.get(selectedGame);

            logDebug("Selected game: " + selectedGame);
            logDebug("Game indices map: " + gameIndices);
            logDebug("Game index to join: " + gameIndex);

            if (gameIndex != null && out != null) {
                String joinCommand = "JOIN " + gameIndex;
                logDebug("SEND: " + joinCommand);
                out.println(joinCommand);
                gameActive = true;
                statusLabel.setText("Joining game...");

                // Clear the board
                resetBoardDisplay();
            } else {
                logDebug("Cannot join game: gameIndex=" + gameIndex + ", out=" + (out != null));
            }
        } else {
            JOptionPane.showMessageDialog(this,
                    "Please select a game to join",
                    "No Game Selected",
                    JOptionPane.WARNING_MESSAGE);
        }
    }

    /**
     * Makes a move at the specified position on the board.
     */
    private void makeMove(int position) {
        if (gameActive && myTurn && board[position] == ' ') {
            String moveCommand = "MOVE " + position;
            logDebug("SEND: " + moveCommand);
            out.println(moveCommand);
            myTurn = false;

            // Disable all board buttons until our turn again
            for (JButton button : boardButtons) {
                button.setEnabled(false);
            }

            statusLabel.setText("Waiting for opponent's move...");
        }
    }

    /**
     * Resets the board display.
     */
    private void resetBoardDisplay() {
        for (int i = 0; i < 9; i++) {
            board[i] = ' ';
            boardButtons[i].setText("");
            boardButtons[i].setEnabled(false);
            boardButtons[i].setBackground(Color.WHITE);
            boardButtons[i].setOpaque(true);
            boardButtons[i].setBorderPainted(true);
        }
    }

    /**
     * Resets the game state.
     */

    private void resetGame() {
        gameActive = false;
        myTurn = false;
        resetBoardDisplay();

        // Re-enable connection controls
        connectButton.setEnabled(true);
        serverField.setEnabled(true);
        portField.setEnabled(true);
        nameField.setEnabled(true);

        // Reset player info
        playerXLabel.setText("Player X: Waiting...");
        playerOLabel.setText("Player O: Waiting...");

        // Disable game components
        setComponentsEnabled(false);
    }

    /**
     * Main method to start the client.
     */
    public static void main(String[] args) {
        // Set the look and feel to the system look and feel
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Create and display the GUI on the EDT
        SwingUtilities.invokeLater(() -> new TicTacToeGUIClient());
    }
}