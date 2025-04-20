import soundfile as sf
import librosa
from flask import jsonify
import torch
from riffusion.riffusion_pipeline import RiffusionPipeline
from riffusion.datatypes import InferenceInput
from PIL import Image
import os

# Globale variabelen
model = None
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
OUTPUT_FOLDER = '/app/output'

# Functie om het model te laden
def load_model_impl():
    global model
    if model is not None:
        return True

    try:
        # Het laden van het model via de RiffusionPipeline
        model = RiffusionPipeline.load_checkpoint(
            checkpoint="riffusion/riffusion-model-v1",  # Zorg ervoor dat dit het juiste checkpoint is
            device=device,
        )
        print("Model loaded successfully.")
        return True
    except Exception as e:
        print(f"Error loading model: {str(e)}")
        return False

# Functie om muziek te genereren
def generate_impl(prompt, output_path):
    global model
    if model is None:
        load_model_impl()

    try:
        # Voorbeeld van het creëren van een InferenceInput-object, pas dit aan afhankelijk van je behoeften
        inference_input = InferenceInput(
            prompt=prompt,
            alpha=0.5,  # voorbeeldwaarde, afhankelijk van de pipelineconfiguratie
            start=None,  # Dit moet worden ingesteld op je specifieke behoeften
            end=None,  # Dit moet ook worden ingesteld
            num_inference_steps=50,
            guidance_scale=7.5,
        )

        # Gebruik de pipeline om audio te genereren
        # Hier kunnen specifieke aanpassingen nodig zijn op basis van de prompt en instellingen
        image = model.riffuse(inference_input, init_image=Image.new('RGB', (512, 512)))

        # Omzetten naar numpy array en opslaan
        audio_numpy = torch.tensor(image).cpu().numpy()  # Dit kan variëren afhankelijk van hoe de output wordt gegenereerd
        sf.write(output_path, audio_numpy, samplerate=32000)

        # Bereken de duur van de gegenereerde audio
        duration = librosa.get_duration(y=audio_numpy, sr=32000)
        return duration
    except Exception as e:
        print(f"Error generating music: {str(e)}")
        return 0

# Functie om een track uit te breiden
def extend_impl(source_track_path, output_path, extend_duration, content_prompt, style_prompt, has_vocals):
    global model
    if model is None:
        load_model_impl()

    try:
        # Laad het originele nummer
        original_audio, sr = librosa.load(source_track_path, sr=32000)

        # Combineer de prompts voor het genereren van de muziek
        combined_prompt = content_prompt
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        # Genereer de aanvullende audio
        inference_input = InferenceInput(prompt=combined_prompt, alpha=0.5, start=None, end=None, num_inference_steps=50, guidance_scale=7.5)
        image = model.riffuse(inference_input, init_image=Image.new('RGB', (512, 512)))  # Aangepast voor de inference pipeline

        # Convert to numpy array and save to file
        extended_audio = torch.tensor(image).cpu().numpy()  # Assuming output is in a format convertible to numpy
        extended_audio = np.concatenate([original_audio, extended_audio])

        # Save to disk
        sf.write(output_path, extended_audio, samplerate=32000)

        # Get the duration of the extended audio
        duration = librosa.get_duration(y=extended_audio, sr=32000)
        return duration
    except Exception as e:
        print(f"Error extending track: {str(e)}")
        return 0

# Functie om een remix van een track te maken
def remix_impl(source_track_path, output_path, content_prompt, style_prompt, has_vocals):
    global model
    if model is None:
        load_model_impl()

    try:
        # Laad een klein gedeelte van de originele track om de stijl te extraheren
        original_audio, sr = librosa.load(source_track_path, sr=32000, duration=10)

        # Combineer de prompts voor de remix
        combined_prompt = f"Remix of: {content_prompt}"
        if style_prompt:
            combined_prompt += f" in the style of {style_prompt}"
        if not has_vocals:
            combined_prompt += ". Instrumental only, no vocals."

        # Genereer de remix audio
        inference_input = InferenceInput(prompt=combined_prompt, alpha=0.5, start=None, end=None, num_inference_steps=50, guidance_scale=7.5)
        image = model.riffuse(inference_input, init_image=Image.new('RGB', (512, 512)))  # Aangepast voor de inference pipeline

        # Convert to numpy array and save to file
        remix_audio = torch.tensor(image).cpu().numpy()
        sf.write(output_path, remix_audio, samplerate=32000)

        # Get the duration of the remix
        duration = librosa.get_duration(y=remix_audio, sr=32000)
        return duration
    except Exception as e:
        print(f"Error remixing track: {str(e)}")
        return 0

# Functie om het model te ontladen (GPU-geheugen vrij te maken)
def unload_model_impl():
    global model
    if model is None:
        return True

    try:
        model = None
        torch.cuda.empty_cache()  # Verwijder GPU-geheugen
        print("Model unloaded successfully.")
        return True
    except Exception as e:
        print(f"Error unloading model: {str(e)}")
        return False

