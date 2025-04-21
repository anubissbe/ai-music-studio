#!/usr/bin/env python3
"""
Debug script to test a model's ability to generate and save files correctly.
Place this in the /opt/ai-music-studio/ directory.
"""
import os
import sys
import requests
import argparse
import time

def test_model(model_name, prompt="energetic electronic dance music with a strong beat"):
    # Make sure output directory exists and has correct permissions
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'output')
    os.makedirs(output_dir, exist_ok=True)
    os.chmod(output_dir, 0o777)  # Give full permissions for testing
    
    print(f"Testing model: {model_name}")
    print(f"Output directory: {output_dir}")
    print(f"Directory permissions: {oct(os.stat(output_dir).st_mode)[-3:]}")
    
    # Test that we can write to the output directory
    test_file = os.path.join(output_dir, f"test_{int(time.time())}.txt")
    try:
        with open(test_file, 'w') as f:
            f.write("Test file created by debug script")
        print(f"Successfully created test file: {test_file}")
        os.remove(test_file)
        print(f"Successfully removed test file")
    except Exception as e:
        print(f"ERROR: Failed to write to output directory: {e}")
        return
    
    # Load the model
    try:
        r = requests.post(f'http://{model_name}:5000/load', timeout=60)
        r.raise_for_status()
        print(f"Model loaded: {r.text}")
    except Exception as e:
        print(f"ERROR: Failed to load model: {e}")
        return
    
    # Generate audio with the model
    filename = f"{model_name}-debug-{int(time.time())}.wav"
    output_path = os.path.join(output_dir, filename)
    
    try:
        data = {
            'contentPrompt': prompt,
            'stylePrompt': '',
            'hasVocals': True,
            'outputPath': filename
        }
        
        print(f"Sending generation request with data: {data}")
        r = requests.post(f'http://{model_name}:5000/generate', json=data, timeout=180)
        r.raise_for_status()
        
        response_data = r.json()
        print(f"Generation response: {response_data}")
        
        # Check if file was created
        time.sleep(2)  # Give some time for file to be written
        
        # Check response output path if provided
        if 'outputPath' in response_data:
            actual_file = os.path.join(output_dir, response_data['outputPath'])
            if os.path.exists(actual_file):
                file_size = os.path.getsize(actual_file)
                print(f"SUCCESS: Output file created at {actual_file} (size: {file_size} bytes)")
            else:
                print(f"ERROR: Output file not found at {actual_file}")
        
        # Also check the expected path based on our request
        if os.path.exists(output_path):
            file_size = os.path.getsize(output_path)
            print(f"SUCCESS: Output file created at {output_path} (size: {file_size} bytes)")
        else:
            print(f"ERROR: Output file not found at {output_path}")
        
        # List all files in output directory
        all_files = os.listdir(output_dir)
        print(f"All files in output directory: {all_files}")
        
    except Exception as e:
        print(f"ERROR: Generation failed: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Debug AI music generation models")
    parser.add_argument("model", help="Name of the model to test (e.g., musicgen)")
    parser.add_argument("--prompt", help="Text prompt for generation", default="energetic dance music with vocals")
    
    args = parser.parse_args()
    test_model(args.model, args.prompt)
