import os

# Paths for assets
BASE_DIR = "assets"
PROCESSED_IMAGE = os.path.join(BASE_DIR, "processed_image.jpg")
BACKGROUND_MUSIC = os.path.join(BASE_DIR, "voiceover.mp3")
NARRATION_AUDIO = os.path.join(BASE_DIR, "voiceover.mp3")
OUTPUT_VIDEO = os.path.join(BASE_DIR, "final_video.mp4")

# Video settings
DURATION = 5  # seconds
CAPTION_TEXT = "This is an AI-generated video."
FONT_SIZE = 40
FONT_COLOR = "white"
