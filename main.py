from flask import Flask, render_template, request, jsonify
import speech_recognition as sr
import json
from utils import extract_info

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('record.html')

@app.route('/record', methods=['POST'])
def record():
    duration = 5  # seconds
    recognizer = sr.Recognizer()
    
    try:
        with sr.Microphone() as source:
            print("🎙️ Listening...")
            audio = recognizer.record(source, duration=duration)
            text = recognizer.recognize_google(audio)
            print("📝 Recognized:", text)
            
            info = extract_info(text)
            with open("patient_data.json", "a") as f:
                f.write(json.dumps(info) + "\n")
            
            return jsonify({
                'status': 'success',
                'data': info
            })
            
    except Exception as e:
        print("❌ Error:", e)
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 400

if __name__ == '__main__':
    app.run(debug=True)