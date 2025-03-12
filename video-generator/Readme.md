# Video Generator

This project generates a video from an image, adds a caption, and includes background music and narration using Python.

## Requirements

- Docker
- Python 3.9 (if running locally)

## Running with Docker

1. Build the Docker image:
    ```sh
    docker build -t video-generator .
    ```

2. Run the Docker container:
    ```sh
    docker run --rm -v $(pwd)/video-generator/app:/app video-generator
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

## Environment Variables

- `INPUT_IMAGE`: Path to the input image
- `PROCESSED_IMAGE`: Path to the processed image
- `BACKGROUND_MUSIC`: Path to the background music file
- `NARRATION_AUDIO`: Path to the narration audio file
- `OUTPUT_VIDEO`: Path to the output video file
- `CAPTION_TEXT`: Text to be added as a caption

## Files

- `app/script.py`: Main Python script
- `app/input.jpg`: Sample input image (or provide your own)
- `app/background.mp3`: Background music file
- `app/requirements.txt`: Python dependencies
- `Dockerfile`: Docker configuration
- `docker-compose.yml`: Docker Compose configuration