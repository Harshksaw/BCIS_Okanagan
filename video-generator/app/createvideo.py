import streamlit as st
from moviepy import ImageClip, AudioFileClip, TextClip, CompositeVideoClip

import os

# Ensure ImageMagick is properly set up (for Windows users)
# Streamlit UI
st.title("🎬 Image to Video Creator")

# Upload image
image_file = st.file_uploader("📸 Upload an image", type=["jpg", "jpeg", "png"])

# Upload audio
audio_file = st.file_uploader("🎵 Upload an audio file", type=["mp3", "wav"])

# Input text
text_input = st.text_input("📝 Enter text to display on the image")

# Button to create video
if st.button("🚀 Create Video"):
    if image_file and audio_file and text_input:
        # Save uploaded files locally
        image_path = "uploaded_image.png"
        audio_path = "uploaded_audio.mp3"
        output_video_path = "output_video.mp4"

        with open(image_path, "wb") as f:
            f.write(image_file.getbuffer())

        with open(audio_path, "wb") as f:
            f.write(audio_file.getbuffer())

        # Load image as video
        image_clip = ImageClip(image_path, duration=10)

        # Load audio
        audio_clip = AudioFileClip(audio_path).subclip(0, 10)

        # **Fix Font Issue in Docker & Windows**
        custom_font_path = "./assets/Roboto-Black.ttf"  # Ensure this font exists

        # **Fix TextClip Issue (use correct params)**
        text_clip = (
            TextClip(
                text=text_input,
                fontsize=70,
                font=custom_font_path,  # Uses custom font
                color="white",
                size=image_clip.size,  # Match image size for better fit
            )
            .set_position(("center", "bottom"))
            .set_duration(10)
        )

        # Combine image, text, and audio
        video = CompositeVideoClip([image_clip, text_clip])
        video = video.set_audio(audio_clip)

        # Save video
        video.write_videofile(output_video_path, fps=24, codec="libx264")

        # Display video in Streamlit
        st.video(output_video_path)

    else:
        st.error("❌ Please upload an image, an audio file, and enter text.")
