package src;


/**
 * TicTacToeGame.java
 * 
 * This class handles the game logic for a Tic-Tac-Toe game.
 * It maintains the board state, validates moves, and checks for win conditions.
 */
public class TicTacToeGame {
    private char[] board;
    private char currentPlayer;
    private boolean gameOver;
    private char winner;

    /**
     * Creates a new Tic-Tac-Toe game with an empty board.
     */
    public TicTacToeGame() {
        board = new char[9];
        resetGame();
    }

    /**
     * Resets the game to initial state.
     */
    public void resetGame() {
        for (int i = 0; i < 9; i++) {
            board[i] = ' ';
        }
        currentPlayer = 'X'; // X always starts
        gameOver = false;
        winner = ' ';
    }

    /**
     * Attempts to make a move for the specified player.
     * 
     * @param position The board position (0-8)
     * @param playerMark The player's mark (X or O)
     * @return true if the move was successful, false otherwise
     */
    public boolean makeMove(int position, char playerMark) {
        if (!isValidMove(position) || gameOver || playerMark != currentPlayer) {
            return false;
        }

        board[position] = playerMark;

        // Check if this move wins the game
        if (checkWin(playerMark)) {
            gameOver = true;
            winner = playerMark;
            return true;
        }

        // Check if the board is full (draw)
        if (isBoardFull()) {
            gameOver = true;
            return true;
        }

        // Switch player
        currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
        return true;
    }

    /**
     * Checks if a move is valid.
     * 
     * @param position The board position to check (0-8)
     * @return true if the move is valid, false otherwise
     */
    public boolean isValidMove(int position) {
        return position >= 0 && position < 9 && board[position] == ' ';
    }

    /**
     * Checks if the specified player has won the game.
     * 
     * @param playerMark The player's mark (X or O)
     * @return true if the player has won, false otherwise
     */
    public boolean checkWin(char playerMark) {
        // Check rows
        for (int i = 0; i < 9; i += 3) {
            if (board[i] == playerMark && board[i + 1] == playerMark && board[i + 2] == playerMark) {
                return true;
            }
        }
        
        // Check columns
        for (int i = 0; i < 3; i++) {
            if (board[i] == playerMark && board[i + 3] == playerMark && board[i + 6] == playerMark) {
                return true;
            }
        }
        
        // Check diagonals
        if (board[0] == playerMark && board[4] == playerMark && board[8] == playerMark) {
            return true;
        }
        if (board[2] == playerMark && board[4] == playerMark && board[6] == playerMark) {
            return true;
        }
        
        return false;
    }

    /**
     * Checks if the board is full.
     * 
     * @return true if the board is full, false otherwise
     */
    public boolean isBoardFull() {
        for (char cell : board) {
            if (cell == ' ') {
                return false;
            }
        }
        return true;
    }

    /**
     * Gets a copy of the current board state.
     * 
     * @return A copy of the board array
     */
    public char[] getBoard() {
        return board.clone();
    }

    /**
     * Gets the board state as a string.
     * 
     * @return A string representation of the board
     */
    public String getBoardString() {
        return new String(board);
    }

    /**
     * Gets the current player.
     * 
     * @return The current player's mark (X or O)
     */
    public char getCurrentPlayer() {
        return currentPlayer;
    }

    /**
     * Checks if the game is over.
     * 
     * @return true if the game is over, false otherwise
     */
    public boolean isGameOver() {
        return gameOver;
    }

    /**
     * Gets the winner of the game.
     * 
     * @return The winning player's mark, or ' ' if there is no winner
     */
    public char getWinner() {
        return winner;
    }

    /**
     * Gets a description of the current game status.
     * 
     * @return A string describing the game status
     */
    public String getGameStatus() {
        if (!gameOver) {
            return "Game in progress. Player " + currentPlayer + "'s turn.";
        } else if (winner != ' ') {
            return "Game over. Player " + winner + " wins!";
        } else {
            return "Game over. It's a draw!";
        }
    }
    
    /**
     * Prints a formatted representation of the board to the console.
     * This is primarily for debugging purposes.
     */
    public void printBoard() {
        System.out.println(" " + board[0] + " | " + board[1] + " | " + board[2] + " ");
        System.out.println("---+---+---");
        System.out.println(" " + board[3] + " | " + board[4] + " | " + board[5] + " ");
        System.out.println("---+---+---");
        System.out.println(" " + board[6] + " | " + board[7] + " | " + board[8] + " ");
    }
}