import os
from flask import Flask, request, render_template, send_from_directory
from generatevoice import generate_voiceover
from createvideo import create_video

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['OUTPUT_FOLDER'] = 'output'

os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No file part'
    file = request.files['file']
    if file.filename == '':
        return 'No selected file'
    if file:
        input_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(input_path)
        os.environ['INPUT_IMAGE'] = input_path
        os.environ['PROCESSED_IMAGE'] = os.path.join(app.config['OUTPUT_FOLDER'], 'processed.jpg')
        os.environ['OUTPUT_VIDEO'] = os.path.join(app.config['OUTPUT_FOLDER'], 'output.mp4')
        
        process_image()
        generate_voiceover()
        create_video()
        
        return send_from_directory(app.config['OUTPUT_FOLDER'], 'output.mp4')

@app.route('/test', methods=['GET'])
def test_with_existing_image():
    print("Test route called")
    input_path = os.path.join(app.config['UPLOAD_FOLDER'], 'test_image.jpg')
    os.environ['INPUT_IMAGE'] = input_path
    # os.environ['PROCESSED_IMAGE'] = os.path.join(app.config['OUTPUT_FOLDER'], 'processed.jpg')
    os.environ['OUTPUT_VIDEO'] = os.path.join(app.config['OUTPUT_FOLDER'], 'output.mp4')
    print("Input Image Path:", os.environ['INPUT_IMAGE'])
    # process_image()
    generate_voiceover()
    create_video()
    
    return send_from_directory(app.config['OUTPUT_FOLDER'], 'output.mp4')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)
