# Use official Python image as base
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y ffmpeg

# Set working directory
WORKDIR /app

# Copy requirements file first to leverage Docker caching
COPY video-generator/app/requirements.txt /app/requirements.txt

# Upgrade pip and install dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the application files
COPY video-generator/app/ /app/

# Set environment variables (can be overridden in docker-compose)
ENV INPUT_IMAGE="/app/input.jpg"
ENV PROCESSED_IMAGE="/app/processed.jpg"
ENV BACKGROUND_MUSIC="/app/background.mp3"
ENV NARRATION_AUDIO="/app/voiceover.mp3"
ENV OUTPUT_VIDEO="/app/output.mp4"
ENV CAPTION_TEXT="This is a sample video."

# Expose the port the app runs on
EXPOSE 5000

# Run the Flask application
CMD ["python", "app.py"]
