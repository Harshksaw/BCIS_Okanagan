# Video Generator

This project generates a video from an image, adds a caption, and includes background music and narration using Python.

## Requirements

- Docker
- Python 3.9 (if running locally)


## Running Streamlit with Docker
1.
    In the Folder video-generator open in terminal ->

2. Build the Docker image (if not already built):
    ```sh
    docker build -t video-generator .
    ```

3. Run the Docker container with Streamlit (exposing port 8501):
    ```sh
    docker compose up -d 
    ```
4. open localhost 
    ```
        sh
        http://0.0.0.0:8501
    ```    

## Running Locally

1. Install the dependencies:
    ```sh
    pip install -r video-generator/app/requirements.txt
    ```

2. Run the script:
    ```sh
    python video-generator/app/script.py
    ```
