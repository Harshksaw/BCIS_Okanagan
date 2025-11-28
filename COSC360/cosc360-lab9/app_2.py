from flask import Flask, request

app_2 = Flask(__name__)

@app_2.route('/')
def index():
    return 'Hello world, this is my second application!'

if __name__ == "__main__":
    app_2.run()
