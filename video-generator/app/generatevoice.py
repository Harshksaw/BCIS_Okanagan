from gtts import gTTS
import pyttsx3
import os
import logging
from config import CAPTION_TEXT, NARRATION_AUDIO

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def generate_voiceover():
    """Generates voiceover using gTTS (fallback to pyttsx3 if offline)."""
    try:
        logging.info("Generating voiceover using gTTS...")
        tts = gTTS(text=CAPTION_TEXT, lang="en")
        tts.save(NARRATION_AUDIO)
        logging.info(f"Voiceover saved: {NARRATION_AUDIO}")
    except Exception as e:
        logging.warning(f"gTTS failed: {e} - Using offline pyttsx3 instead.")
        generate_narration_pyttsx3(CAPTION_TEXT, NARRATION_AUDIO)

def generate_narration_pyttsx3(text, output_path):
    """Generates voiceover narration using offline pyttsx3."""
    engine = pyttsx3.init()
    engine.save_to_file(text, output_path)
    engine.runAndWait()
    logging.info(f"Offline narration saved: {output_path}")

if __name__ == "__main__":
    generate_voiceover()
