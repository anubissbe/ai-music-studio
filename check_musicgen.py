#!/usr/bin/env python3
"""
Script to check the musicgen model implementation.
"""
import os
import sys
import requests
import json

def get_musicgen_app_code():
    try:
        r = requests.get('http://musicgen:5000/source', timeout=10)
        if r.status_code == 404:
            print("Source endpoint not available. Let's check directly in the container.")
            return None
        return r.text
    except:
        print("Failed to fetch source code from endpoint.")
        return None

def debug_musicgen():
    # First try to send a simple request to check if the service is working
    try:
        r = requests.get('http://musicgen:5000/', timeout=5)
        print(f"Musicgen service response: {r.status_code}")
        print(f"Response text: {r.text[:100]}...")  # Only print the start to avoid huge output
    except Exception as e:
        print(f"Failed to connect to musicgen service: {e}")
    
    # Try loading the model
    try:
        r = requests.post('http://musicgen:5000/load', timeout=60)
        print(f"Model load response: {r.status_code}")
        print(f"Response text: {r.text}")
    except Exception as e:
        print(f"Failed to load musicgen model: {e}")
    
    # Try a test generation request
    try:
        data = {
            'contentPrompt': 'simple test melody',
            'stylePrompt': '',
            'hasVocals': True,
            'outputPath': 'test-musicgen.wav'
        }
        
        r = requests.post('http://musicgen:5000/generate', json=data, timeout=180)
        print(f"Generation response status: {r.status_code}")
        try:
            resp_json = r.json()
            print(f"Generation response: {json.dumps(resp_json, indent=2)}")
        except:
            print(f"Non-JSON response: {r.text[:100]}...")
    except Exception as e:
        print(f"Failed to generate with musicgen: {e}")

if __name__ == "__main__":
    print("=== Running Musicgen Debug ===")
    debug_musicgen()
    
    print("\n=== Suggested Fixes ===")
    print("1. Ensure the /app/output or /opt/ai-music-studio/output directory exists in the musicgen container")
    print("2. Ensure the output directory has write permissions for the container user")
    print("3. Modify the musicgen app.py to properly return the outputPath in the response")
    print("4. Add explicit error handling in the musicgen app.py to log file save errors")
