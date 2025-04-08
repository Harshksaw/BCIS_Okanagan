docker build -t ghostchat .
docker run -p 5001:5000 ghostchat


javac -d out src/utils/*.java
javac -d out -cp out src/*.java
javac -d out -cp out Client.java


javac Client.java
java Client