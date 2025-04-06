# Use OpenJDK base image
FROM openjdk:17

# Create app directory
WORKDIR /app

# Make src/utils directory if it doesn't exist
RUN mkdir -p src/utils

# Copy source files
COPY ./src ./src

# Ensure output directory exists
RUN mkdir -p out

# Compile Java code
RUN javac -d out src/*.java src/utils/*.java

# Expose the server port
EXPOSE 5000

# Start the server
CMD ["java", "-cp", "out", "Server"]