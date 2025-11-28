from flask import Flask, request

app_1 = Flask(__name__)

@app_1.route('/')
def index():
    return 'Hello world, this is my first application!'

if __name__ == "__main__":
    app_1.run()
