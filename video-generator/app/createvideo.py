from moviepy import ImageClip, AudioFileClip, TextClip, CompositeVideoClip
import os
import logging
from config import PROCESSED_IMAGE, BACKGROUND_MUSIC, NARRATION_AUDIO, OUTPUT_VIDEO, DURATION, CAPTION_TEXT, FONT_SIZE, FONT_COLOR

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def check_file_exists(file_path, file_description):
    """Check if a file exists, otherwise log an error and return False."""
    if not os.path.exists(file_path):
        logging.error(f"❌ Error: {file_description} '{file_path}' not found.")
        return False
    return True

def create_video():
    """Creates a short video with captions, music, and narration."""
    logging.info("Starting video creation process.")

    if not (check_file_exists(PROCESSED_IMAGE, "Processed image") and
            check_file_exists(BACKGROUND_MUSIC, "Background music") and
            check_file_exists(NARRATION_AUDIO, "Narration audio")):
        logging.error("❌ Exiting due to missing files.")
        return

    # Load image
    logging.info(f"Loading image: {PROCESSED_IMAGE}")
    image_clip = ImageClip(PROCESSED_IMAGE, duration=DURATION)

    # Load audio files
    logging.info(f"Loading background music: {BACKGROUND_MUSIC}")
    audio_clip = AudioFileClip(BACKGROUND_MUSIC).with_duration(DURATION)


    logging.info(f"🎙 Loading narration audio: {NARRATION_AUDIO}")
    narration_clip = AudioFileClip(NARRATION_AUDIO).with_duration(DURATION)

    # Adjust volume
    logging.info("🎛 Adjusting narration volume.")
    narration_clip = narration_clip.multiply_volume(1.5)

    # Merge narration and background music
    logging.info("🎵 Merging narration and background music.")
    final_audio = concatenate_audioclips([audio_clip, narration_clip]) #Add narration clip to the final audio.

    # Adjust volume and mix audio
    logging.info("Adjusting narration volume and mixing audio.")
    #narration_clip = narration_clip.multiply_volume(1.5) #No longer needed here.


    # Create text caption
    logging.info(f"Creating text caption: {CAPTION_TEXT}")
    text_clip = TextClip(CAPTION_TEXT, fontsize=FONT_SIZE, color=FONT_COLOR).set_position(("center", "bottom")).set_duration(DURATION)

    # Create final video
    logging.info("Creating final video.")
    final_video = CompositeVideoClip([image_clip, text_clip])
    final_video.audio = final_audio

    logging.info(f"Writing video file: {OUTPUT_VIDEO}")
    final_video.write_videofile(OUTPUT_VIDEO, fps=24, codec="libx264")

    logging.info(f"✅ Video successfully saved: {OUTPUT_VIDEO}")

if __name__ == "__main__":
    try:
        create_video()
    except Exception as e:
        logging.error(f"❌ Video generation failed: {e}")
