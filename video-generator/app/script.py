import os
from PIL import Image, ImageDraw, ImageFont
from gtts import gTTS
from moviepy import *
# from generatevoice import generate_voiceover
# from createvideo import create_video


INPUT_IMAGE = os.getenv("INPUT_IMAGE", "app/input.jpg")
PROCESSED_IMAGE = os.getenv("PROCESSED_IMAGE", "app/processed.jpg")
BACKGROUND_MUSIC = os.getenv("BACKGROUND_MUSIC", "app/background.mp3")
NARRATION_AUDIO = os.getenv("NARRATION_AUDIO", "app/voiceover.mp3")
OUTPUT_VIDEO = os.getenv("OUTPUT_VIDEO", "app/output.mp4")
CAPTION_TEXT = os.getenv("CAPTION_TEXT", "This is a sample video.")

def process_image():
    """Loads an image, applies transformations, and overlays text."""
    if not os.path.exists(INPUT_IMAGE):
        print(f"Error: Input image '{INPUT_IMAGE}' not found.")
        return
    
    image = Image.open(INPUT_IMAGE).convert("L")  # Convert to grayscale
    draw = ImageDraw.Draw(image)

    try:
        font = ImageFont.truetype("arial.ttf", 40)  # Use Arial font
    except IOError:
        font = ImageFont.load_default()

    draw.text((50, 50), CAPTION_TEXT, font=font, fill="white")
    image.save(PROCESSED_IMAGE)
    print(f"✅ Processed image saved as {PROCESSED_IMAGE}")


def main():
    # process_image()
    # generate_voiceover()
    # create_video()

if __name__ == "__main__":
    main()
