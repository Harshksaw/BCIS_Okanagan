# FinalProject
 docker cp init.sql flask-db-1:/tmp/


# Ensure old data is removed to trigger initialization scripts
docker-compose down -v

# Start services
docker-compose up

# Copy SQL file to the container
docker cp init.sql flask-db-1:/tmp/

# For regular SQL files
docker exec -it flask-db-1 psql -U postgres -d flaskdb -f /tmp/init.sql

# For PostgreSQL dump files
docker exec -it flask-db-1 pg_restore -U postgres -d flaskdb /tmp/init.sql

 docker-compose down
docker-compose build web
docker-compose up



