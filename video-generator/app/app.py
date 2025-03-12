import streamlit as st
from moviepy import ImageClip, AudioFileClip, TextClip, CompositeVideoClip

st.title("🎬 Video Generator with Streamlit")

st.write("Upload an image and an audio file to generate a video.")

# Upload input files
image_file = st.file_uploader("📸 Upload Image", type=["jpg", "jpeg", "png"])
audio_file = st.file_uploader("🎵 Upload Audio", type=["mp3", "wav"])
caption_text = st.text_input("📝 Enter Caption Text")

if st.button("🚀 Generate Video"):
    if image_file and audio_file and caption_text:
        # Save files locally
        image_path = "uploaded_image.png"
        audio_path = "uploaded_audio.mp3"
        output_video_path = "output_video.mp4"

        with open(image_path, "wb") as f:
            f.write(image_file.getbuffer())

        with open(audio_path, "wb") as f:
            f.write(audio_file.getbuffer())

        st.success("Files uploaded successfully! Processing...")

        # Load image as video
        image_clip = ImageClip(image_path, duration=10)

        # ✅ Fix: Use `set_duration()` Instead of `subclip()`
        audio_clip = AudioFileClip(audio_path).subclipped(0, 10)

        # Fix TextClip
        text_clip = (
            TextClip(
                text=caption_text,
                font_size=70,
                font="./assets/Roboto-Black.ttf",
                color="white",
                size=image_clip.size,  # Match image size for better fit
            )
            .with_position(("center", 0.25), relative=True)
            .with_duration(10)
        )

        # Combine image, text, and audio
        video = CompositeVideoClip([image_clip, text_clip])
        # video = video.set_audio(audio_clip)

        # Save video
        video.write_videofile(output_video_path, fps=24, codec="libx264")

        # Show output video
        st.video(output_video_path)

    else:
        st.error("Please upload all files and enter a caption.")
