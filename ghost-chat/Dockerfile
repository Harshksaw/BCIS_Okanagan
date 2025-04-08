# Use OpenJDK base image
FROM openjdk:17

# Create app directory
WORKDIR /app

# Copy source files
COPY ./src ./src
COPY ./Client.java ./Client.java

# Create output directory
RUN mkdir -p out

# Compile utils first
RUN javac -d out src/utils/*.java

# Compile other src files
RUN javac -d out -cp out src/*.java 



# Expose the server port
EXPOSE 5000

# Start the server
CMD ["java", "-cp", "out", "Server"]