from flask import Flask
app = Flask(__name__)

count = 0

@app.route("/")
@app.route("/health")
def home():
    return "Flask App Running on Lightsail!", 200

@app.route("/visitor_count")
def visitor():
    global count
    count += 1
    return f"Visitor #{count}", 200
