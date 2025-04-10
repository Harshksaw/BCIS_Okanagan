docker build -t ghostchat .
docker run -p 5001:5000 ghostchat


javac -d out src/utils/*.java
javac -d out -cp out src/*.java
javac -d out -cp out Client.java


javac Client.java
java Client


docker build -t ghostchat .
docker run -p 5001:5000 ghostchat



Run atleast two of these in two terminal
javac -d out src/*.java src/utils/*.java
java -cp out Client