from flask import Flask, request
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from COSC 360 Lab 2!"

@app.route("/static-page")
def static_page():
    with open("static.html", "r") as f:
        return f.read()

@app.route("/get-request")
def get_request():
    name = request.args.get("name", "Guest")
    return f"Hello, {name}!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
