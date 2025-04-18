import os
import json
import uuid
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import requests

app = Flask(__name__)
CORS(app)

# Connect to MongoDB
client = MongoClient(os.environ.get("MONGO_URI", "mongodb://mongodb:27017/"))
db = client.music_generation
tracks_collection = db.tracks
models_collection = db.models

# Constants
UPLOAD_FOLDER = '/app/uploads'
OUTPUT_FOLDER = '/app/output'
MODELS_FOLDER = '/app/models'

# Create directories if they don't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
os.makedirs(MODELS_FOLDER, exist_ok=True)

# Model definitions
AI_MODELS = [
    {
        'id': 'musicgen',
        'name': 'MusicGen (Meta AI)',
        'description': 'Text-to-music model that can generate high-quality music from text descriptions',
        'api_url': 'http://musicgen:5000/generate',
        'loaded': False,
        'port': 5001
    },
    {
        'id': 'musicgpt',
        'name': 'MusicGPT',
        'description': 'GPT-based music generation model with strong melody composition',
        'api_url': 'http://musicgpt:5000/generate',
        'loaded': False,
        'port': 5002
    },
    {
        'id': 'jukebox',
        'name': 'OpenAI Jukebox',
        'description': 'Neural network that generates music with singing in various genres and styles',
        'api_url': 'http://jukebox:5000/generate',
        'loaded': False,
        'port': 5003
    },
    {
        'id': 'audioldm',
        'name': 'AudioLDM',
        'description': 'Latent diffusion model for high-quality audio generation from text',
        'api_url': 'http://audioldm:5000/generate',
        'loaded': False,
        'port': 5004
    },
    {
        'id': 'riffusion',
        'name': 'Riffusion',
        'description': 'Diffusion-based model that creates music from text prompts using spectrograms',
        'api_url': 'http://riffusion:5000/generate',
        'loaded': False,
        'port': 5005
    },
    {
        'id': 'bark',
        'name': 'Bark Audio',
        'description': 'Text-guided audio generation model with versatile sound production',
        'api_url': 'http://bark:5000/generate',
        'loaded': False,
        'port': 5006
    },
    {
        'id': 'musiclm',
        'name': 'MusicLM',
        'description': 'Generate high-fidelity music from text descriptions',
        'api_url': 'http://musiclm:5000/generate',
        'loaded': False,
        'port': 5007
    },
    {
        'id': 'mousai',
        'name': 'Moûsai',
        'description': 'Text-to-music model with expressive sound synthesis capabilities',
        'api_url': 'http://mousai:5000/generate',
        'loaded': False,
        'port': 5008
    },
    {
        'id': 'stable_audio',
        'name': 'Stable Audio',
        'description': 'High-fidelity audio generation with precise style control',
        'api_url': 'http://stable_audio:5000/generate',
        'loaded': False,
        'port': 5009
    },
    {
        'id': 'dance_diffusion',
        'name': 'Dance Diffusion',
        'description': 'Specialized electronic music generation using diffusion techniques',
        'api_url': 'http://dance_diffusion:5000/generate',
        'loaded': False,
        'port': 5010
    }
]

# Initialize models in the database
def init_models():
    # Clear existing models
    models_collection.delete_many({})
    
    # Insert models
    for model in AI_MODELS:
        models_collection.insert_one(model)
    
    print("Models initialized in database")

# Routes
@app.route('/api/models', methods=['GET'])
def get_models():
    models = list(models_collection.find({}, {'_id': 0}))
    return jsonify({'models': models})

@app.route('/api/models/load', methods=['POST'])
def load_model():
    data = request.json
    model_id = data.get('modelId')
    
    if not model_id:
        return jsonify({'success': False, 'error': 'Model ID is required'}), 400
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    # Simulate loading the model (in a real scenario, you would call the model container's API)
    try:
        # Call the model container to load the model
        response = requests.post(f"http://{model_id}:5000/load")
        
        if response.status_code == 200:
            # Update the model status in the database
            models_collection.update_one(
                {'id': model_id},
                {'$set': {'loaded': True}}
            )
            
            return jsonify({'success': True, 'message': f'Model {model_id} loaded successfully'})
        else:
            return jsonify({'success': False, 'error': 'Failed to load model'}), 500
            
    except requests.exceptions.RequestException as e:
        print(f"Error loading model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/models/unload', methods=['POST'])
def unload_model():
    data = request.json
    model_id = data.get('modelId')
    
    if not model_id:
        return jsonify({'success': False, 'error': 'Model ID is required'}), 400
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    # Simulate unloading the model
    try:
        # Call the model container to unload the model
        response = requests.post(f"http://{model_id}:5000/unload")
        
        if response.status_code == 200:
            # Update the model status in the database
            models_collection.update_one(
                {'id': model_id},
                {'$set': {'loaded': False}}
            )
            
            return jsonify({'success': True, 'message': f'Model {model_id} unloaded successfully'})
        else:
            return jsonify({'success': False, 'error': 'Failed to unload model'}), 500
            
    except requests.exceptions.RequestException as e:
        print(f"Error unloading model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/generate', methods=['POST'])
def generate_music():
    data = request.json
    model_id = data.get('modelId')
    content_prompt = data.get('contentPrompt', '')
    style_prompt = data.get('stylePrompt', '')
    has_vocals = data.get('hasVocals', True)
    is_remix = data.get('isRemix', False)
    source_track_id = data.get('sourceTrackId')
    
    if not model_id:
        return jsonify({'success': False, 'error': 'Model ID is required'}), 400
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    if not model.get('loaded', False):
        return jsonify({'success': False, 'error': 'Model is not loaded'}), 400
    
    # Generate a unique ID for the track
    track_id = str(uuid.uuid4())
    output_filename = f"{track_id}.mp3"
    output_path = os.path.join(OUTPUT_FOLDER, output_filename)
    
    # Prepare request payload for the model container
    payload = {
        'contentPrompt': content_prompt,
        'stylePrompt': style_prompt,
        'hasVocals': has_vocals,
        'outputPath': output_path
    }
    
    # If it's a remix, add the source track
    if is_remix and source_track_id:
        source_track = tracks_collection.find_one({'id': source_track_id})
        if source_track:
            payload['sourceTrackPath'] = source_track.get('filePath')
            payload['isRemix'] = True
    
    try:
        # In a real implementation, you would send this to the model container
        # For this example, we'll simulate the model generating music
        
        # Call the model container's API
        response = requests.post(model.get('api_url'), json=payload)
        
        if response.status_code != 200:
            return jsonify({'success': False, 'error': 'Model failed to generate music'}), 500
        
        response_data = response.json()
        
        # In a real implementation, the model container would save the file
        # Here, we'll just assume it was saved
        
        # Create a record in the database
        track = {
            'id': track_id,
            'name': f"Generated Track - {datetime.now().strftime('%Y-%m-%d %H:%M')}",
            'model': model.get('name'),
            'modelId': model_id,
            'contentPrompt': content_prompt,
            'stylePrompt': style_prompt,
            'hasVocals': has_vocals,
            'isRemix': is_remix,
            'sourceTrackId': source_track_id if is_remix else None,
            'filePath': output_path,
            'url': f"/api/tracks/{track_id}/audio",
            'duration': response_data.get('duration', 60),  # Default to 60 seconds
            'createdAt': datetime.now().isoformat()
        }
        
        tracks_collection.insert_one(track)
        
        # Remove _id field for the response
        track.pop('_id', None)
        
        return jsonify({'success': True, 'track': track})
        
    except requests.exceptions.RequestException as e:
        print(f"Error generating music with model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/extend', methods=['POST'])
def extend_track():
    data = request.json
    track_id = data.get('trackId')
    model_id = data.get('modelId')
    duration = data.get('duration', 30)  # Default to extending by 30 seconds
    
    if not track_id or not model_id:
        return jsonify({'success': False, 'error': 'Track ID and Model ID are required'}), 400
    
    # Find the track
    track = tracks_collection.find_one({'id': track_id})
    
    if not track:
        return jsonify({'success': False, 'error': 'Track not found'}), 404
    
    # Find the model
    model = models_collection.find_one({'id': model_id})
    
    if not model:
        return jsonify({'success': False, 'error': 'Model not found'}), 404
    
    if not model.get('loaded', False):
        return jsonify({'success': False, 'error': 'Model is not loaded'}), 400
    
    # Generate a new unique ID for the extended track
    new_track_id = str(uuid.uuid4())
    output_filename = f"{new_track_id}.mp3"
    output_path = os.path.join(OUTPUT_FOLDER, output_filename)
    
    # Prepare request payload for the model container
    payload = {
        'sourceTrackPath': track.get('filePath'),
        'outputPath': output_path,
        'extendDuration': duration,
        'contentPrompt': track.get('contentPrompt', ''),
        'stylePrompt': track.get('stylePrompt', ''),
        'hasVocals': track.get('hasVocals', True)
    }
    
    try:
        # Call the model container's API to extend the track
        response = requests.post(f"{model.get('api_url')}/extend", json=payload)
        
        if response.status_code != 200:
            return jsonify({'success': False, 'error': 'Model failed to extend track'}), 500
        
        response_data = response.json()
        
        # Create a new record in the database for the extended track
        extended_track = {
            'id': new_track_id,
            'name': f"{track.get('name')} (Extended)",
            'model': model.get('name'),
            'modelId': model_id,
            'contentPrompt': track.get('contentPrompt'),
            'stylePrompt': track.get('stylePrompt'),
            'hasVocals': track.get('hasVocals'),
            'isRemix': track.get('isRemix', False),
            'sourceTrackId': track.get('sourceTrackId'),
            'filePath': output_path,
            'url': f"/api/tracks/{new_track_id}/audio",
            'duration': track.get('duration', 60) + duration,
            'createdAt': datetime.now().isoformat()
        }
        
        tracks_collection.insert_one(extended_track)
        
        # Remove _id field for the response
        extended_track.pop('_id', None)
        
        return jsonify({'success': True, 'track': extended_track})
        
    except requests.exceptions.RequestException as e:
        print(f"Error extending track {track_id} with model {model_id}: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'success': False, 'error': 'No file part'}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({'success': False, 'error': 'No selected file'}), 400
    
    if file:
        # Generate a unique file name
        file_id = str(uuid.uuid4())
        file_extension = os.path.splitext(file.filename)[1]
        filename = f"{file_id}{file_extension}"
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        
        # Save the file
        file.save(file_path)
        
        # Create a record in the database
        file_record = {
            'id': file_id,
            'name': file.filename,
            'path': file_path,
            'size': os.path.getsize(file_path),
            'type': file.content_type,
            'uploadedAt': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True, 
            'file': {
                'id': file_id,
                'name': file.filename,
                'size': os.path.getsize(file_path),
                'type': file.content_type
            }
        })
    
    return jsonify({'success': False, 'error': 'Failed to upload file'}), 500

@app.route('/api/tracks/<track_id>/audio', methods=['GET'])
def get_track_audio(track_id):
    # Find the track
    track = tracks_collection.find_one({'id': track_id})
    
    if not track:
        return jsonify({'success': False, 'error': 'Track not found'}), 404
    
    file_path = track.get('filePath')
    
    if not os.path.exists(file_path):
        return jsonify({'success': False, 'error': 'Audio file not found'}), 404
    
    # In a real implementation, you would serve the file
    # For this example, we'll return a placeholder
    
    return jsonify({
        'success': True,
        'message': 'This endpoint would serve the actual audio file in a real implementation'
    })

# Initializing models at startup instead of using before_first_request decorator
init_models()

if __name__ == '__main__':
    # Initialize the models at startup
    app.run(host='0.0.0.0', port=5000)
