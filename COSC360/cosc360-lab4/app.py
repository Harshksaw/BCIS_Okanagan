import os
from flask import Flask, request
import redis

app = Flask(__name__)


redis_host = os.environ.get("REDIS_HOST", "redis.service.local")
#on prod, lightsail container-server-1.redis-cont
redis_client = redis.Redis(host=redis_host, port=6379, decode_responses=True)

@app.route("/")
def home():
    return "Lab 4 - Express App on Lightsail", 200

@app.route("/health")
def health():
    return "OK", 200

@app.route("/static-page")
def static_page():
    try:
        with open("static.html", "r") as f:
            return f.read(), 200
    except FileNotFoundError:
        return "static.html not found", 404

@app.route("/get-request")
def get_request():
    name = request.args.get("name", "Guest")
    return f"Hello, {name}!", 200

@app.route("/visitor_count")
def visitor_count():
    try:
        count = redis_client.incr("visitor_count")
        return f"You are visitor number: {count}", 200
    except Exception as e:
        return f"Error connecting to Redis: {str(e)}", 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
