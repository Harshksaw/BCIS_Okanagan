#!/bin/bash

# Check if xhost is available (Linux/macOS)
if command -v xhost &> /dev/null; then
    # Allow X server connections from the Docker container
    xhost +local:docker
fi

# On Linux/macOS with X11:
if [ "$(uname)" = "Linux" ] || [ "$(uname)" = "Darwin" ] && [ -n "$DISPLAY" ]; then
    # Build the GUI client image
    docker build -t tictactoe-gui-client -f Dockerfile.gui-client .

    # Run the GUI client with X11 forwarding
    docker run -it --rm \
        --network network-prog_tictactoe-network \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        tictactoe-gui-client
elif [ "$(uname)" = "Darwin" ] && [ -z "$DISPLAY" ]; then
    # Build and run locally on macOS without X11
    echo "Running locally on macOS..."
    javac -d . src/*.java
    java src.TicTacToeGUIClient
else
    # For Windows or other environments, suggest running locally
    echo "Please run the GUI client locally instead of in Docker:"
    echo "javac -d . src/*.java"
    echo "java src.TicTacToeGUIClient"
fi