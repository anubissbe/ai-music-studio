import os
import logging
import numpy as np
import torch

class DummyMusicGen:
    def __init__(self, model_name="small"):
        self.model_name = model_name
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.generation_params = {"duration": 30}
        print(f"DummyMusicGen model {model_name} geladen")

    def to(self, device):
        self.device = device
        return self

    def set_generation_params(self, **kwargs):
        self.generation_params.update(kwargs)
        print(f"Generation parameters bijgewerkt: {self.generation_params}")

    def generate(self, descriptions):
        print(f"Zou muziek genereren voor: {descriptions}")
        # Return dummy audio data (stereo audio van opgegeven duur)
        sample_rate = 32000
        duration = self.generation_params.get("duration", 30)
        # Genereer ruis en normaliseer deze
        dummy_audio = torch.randn(len(descriptions), 1, sample_rate * duration) * 0.1
        return dummy_audio

    @classmethod
    def get_pretrained(cls, model_name="melody"):
        return cls(model_name)
