from flask import Flask, request
import secrets
import os

app = Flask(__name__)


myID = secrets.token_hex(8)

@app.route("/")
def home():
    return "Hello from COSC 360 Lab!,Harsh "

@app.route("/static-page")
def static_page():
    with open("static.html", "r", encoding="utf-8") as f:
        return f.read()

@app.route("/get-request")
def get_request():
    name = request.args.get("name", "Stranger")
    return f"Hello, {name}! 👋"

@app.route("/myid")
def show_myid():
    return myID

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 80))
    app.run(host="0.0.0.0", port=port)
