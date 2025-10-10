import os
from flask import Flask, request

app = Flask(__name__)

# Simple in-memory counter
visitor_count_val = 0

@app.route("/")
def home():
    return "Lab 4 Flask App - Running on AWS Lightsail", 200

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
    global visitor_count_val
    visitor_count_val += 1
    return f"You are visitor number: {visitor_count_val}", 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
