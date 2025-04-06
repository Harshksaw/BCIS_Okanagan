# GhostChat with BombTag Game

A Java-based chat application with public and private rooms, anonymous mode, and an exciting BombTag game!

## Features

- Public and private chat rooms
- Username customization
- Anonymous mode for private chatting
- Private messaging between users
- BombTag hot-potato style game

## Getting Started

### Running the Server

```bash
# Build the Docker image
docker build -t ghostchat .

# Run the server (use port 5002 if 5001 is already in use)
docker run -p 5002:5000 ghostchat
```

### Running the Client

```bash
# Compile the client
javac Client.java

# Connect to localhost on port 5002
java Client localhost 5002

# Connect to a different server
java Client server_ip port_number
```

## Basic Chat Commands

- `/help` - Show available commands
- `/list` or `/rooms` - List available rooms
- `/whisper <username> <message>` - Send private message
- `/name <new_name>` - Change your username
- `/players` - List players in current room
- `/exit` - Leave the chat

## BombTag Game

BombTag is an exciting hot-potato style game where players pass a virtual "bomb" before time runs out.

### Game Commands

- `/bombtag` - Start a new game (requires 2+ players)
- `/pass <username>` - Pass the bomb to another player
- `/endgame` - End the current game

### How to Play

1. Start the game with `/bombtag`
2. A random player gets the bomb with a 30-second timer
3. The bomb holder must pass it with `/pass <username>` before time expires
4. If time runs out, the holder "explodes" and loses
5. Warnings appear at 10 and 5 seconds remaining
6. Game continues until manually ended or too few players remain

### Game Rules

- At least 2 players must be in the room to start
- Only the bomb holder can pass the bomb
- The timer resets to 30 seconds after each pass
- If a bomb holder leaves, the bomb randomly goes to another player

## Troubleshooting

- **Port already in use**: Change the port mapping in Docker run command
- **Connection issues**: Verify the server is running and port is correct
- **Game not starting**: Ensure at least 2 players are in the same room

## File Structure

```
ghost-chat/
├── src/
│   ├── Server.java
│   ├── ClientHandler.java
│   ├── ChatRoom.java
│   └── utils/
│       ├── UsernameGen.java
│       ├── RoomIdGen.java
│       ├── MessageFormatter.java
│       └── BombTagGame.java
├── Client.java
├── Dockerfile
└── README.md
```

Enjoy your enhanced chat experience with BombTag!