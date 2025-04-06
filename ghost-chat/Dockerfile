# Use OpenJDK base image
FROM openjdk:17

# Create app directory
WORKDIR /app

# Copy source files
COPY ./src ./src

# Compile Java code
RUN javac src/*.java src/utils/*.java -d out

# Expose the server port
EXPOSE 5000

# Start the server
CMD ["java", "-cp", "out", "Server"]
