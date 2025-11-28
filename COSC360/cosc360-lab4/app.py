import os
import uuid
from flask import Flask
import redis

app = Flask(__name__)


CONTAINER_ID = str(uuid.uuid4())

@app.route("/")
def home():
    return """
    Home Page 
    """, 200

@app.route("/myid")
def myid():
    return f"Container ID: {CONTAINER_ID}", 200


@app.route("/health")
def health():
    return "OK", 200

@app.route("/sidecar_visitor")
def sidecar_visitor():

    redis_host = os.environ.get("REDIS_HOST", "localhost")
    myDB = redis.Redis(host=redis_host, port=6379, decode_responses=True)
    count = myDB.incr("visitor_count")
    return f"You are visitor number: {count}", 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
