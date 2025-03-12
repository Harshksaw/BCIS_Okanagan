# Use official Python image
FROM python:3.9

# Install system dependencies
RUN apt update && apt install -y \
    ffmpeg \
    imagemagick \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Ensure ImageMagick policy allows MoviePy to work
RUN sed -i 's|.*policy domain="path" rights="none".*|  <policy domain="path" rights="read" pattern="**" />|' /etc/ImageMagick-6/policy.xml

# Set working directory
WORKDIR /app

# Copy only requirements first (Docker caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# Expose Streamlit port
EXPOSE 8501

# Run Streamlit (Container startup command is set in `docker-compose.yml`)
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
