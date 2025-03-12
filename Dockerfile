# Use official Python image as base
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y ffmpeg

# Set working directory
WORKDIR /app

# Copy necessary files
COPY app/ /app/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variables (can be overridden in docker-compose)
ENV INPUT_IMAGE="/app/input.jpg"
ENV PROCESSED_IMAGE="/app/processed.jpg"
ENV BACKGROUND_MUSIC="/app/background.mp3"
ENV NARRATION_AUDIO="/app/voiceover.mp3"
ENV OUTPUT_VIDEO="/app/output.mp4"
ENV CAPTION_TEXT="This is a sample video."

# Run the script
CMD ["python", "script.py"]
