import os
from PIL import Image, ImageDraw, ImageFont
from gtts import gTTS

from moviepy import ImageClip, AudioFileClip, TextClip, CompositeVideoClip


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
    print(f"Processed image saved: {PROCESSED_IMAGE}")

def generate_voiceover():
    """Generates a voiceover using gTTS."""
    tts = gTTS(text=CAPTION_TEXT, lang="en")
    tts.save(NARRATION_AUDIO)
    print(f"Voiceover saved: {NARRATION_AUDIO}")

def create_video():
    """Creates a short video with the processed image, captions, music, and narration."""
    if not os.path.exists(PROCESSED_IMAGE):
        print(f"Error: Processed image '{PROCESSED_IMAGE}' not found.")
        return
    if not os.path.exists(BACKGROUND_MUSIC):
        print(f"Error: Background music '{BACKGROUND_MUSIC}' not found.")
        return
    if not os.path.exists(NARRATION_AUDIO):
        print(f"Error: Narration audio '{NARRATION_AUDIO}' not found.")
        return
    
    image_clip = ImageClip(PROCESSED_IMAGE, duration=5)
    audio_clip = AudioFileClip(BACKGROUND_MUSIC).set_duration(5)
    narration_clip = AudioFileClip(NARRATION_AUDIO).set_duration(5)

    final_audio = narration_clip.volumex(1.5).fx(audio_clip.audio_fadeout, 1)
    text_clip = TextClip(CAPTION_TEXT, fontsize=40, color="white").set_position(("center", "bottom")).set_duration(5)

    final_video = CompositeVideoClip([image_clip, text_clip])
    final_video.audio = final_audio
    final_video.write_videofile(OUTPUT_VIDEO, fps=24, codec="libx264")
    print(f"Video saved: {OUTPUT_VIDEO}")

def main():
    process_image()
    generate_voiceover()
    create_video()

if __name__ == "__main__":
    main()
