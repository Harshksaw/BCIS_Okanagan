
import os

import redis
from flask import Flask, request

app = Flask(__name__)

myDB = redis.Redis(host='container-service-1.redis-cont', port=6379, decode_responses=True)
# REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")
# REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))

# myDB = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=0, decode_responses=True)


@app.route('/')
def home():
    return "Welcome to my Flask + Redis App!"


@app.route("/static-page")
def static_page():
    with open("static.html", "r") as f:
        return f.read()

@app.route("/get-request")
def get_request():
    name = request.args.get("name", "Guest")
    return f"Hello, {name}!"

@app.route('/visitor_count')
def visitor_count():
    if not myDB.exists('visitors'):
        myDB.set('visitors', 1)
    else:
        myDB.incrby('visitors', 1)
    count = myDB.get('visitors')
    return "You are visitor number: " + str(count)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=777, debug=True)
