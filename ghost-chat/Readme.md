javac Client.java
java Client


docker build -t ghostchat .
docker run -p 5001:5000 ghostchat



Run atleast two of these in two terminal
javac -d out src/*.java src/utils/*.java
java -cp out Client