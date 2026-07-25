#!/usr/bin/env python3
"""Alinea un clip PCM corto dentro de una fuente PCM larga mediante correlación FFT.
Ambos ficheros deben ser mono int16 a 8000 Hz.
"""
import sys
import numpy as np

if len(sys.argv) != 4:
    raise SystemExit("Uso: audio_align.py CLIP_PCM SRC_PCM SRC_WINDOW_OFFSET_S")
clip = np.fromfile(sys.argv[1], dtype=np.int16).astype(np.float32)
src = np.fromfile(sys.argv[2], dtype=np.int16).astype(np.float32)
if clip.size == 0 or src.size == 0:
    raise SystemExit("ERROR: entrada PCM vacía")
if clip.size > src.size:
    raise SystemExit("ERROR: el clip es más largo que la ventana fuente")
window_off = float(sys.argv[3])
clip = (clip - clip.mean()) / (clip.std() + 1e-9)
src = (src - src.mean()) / (src.std() + 1e-9)
n = len(src) + len(clip)
p = 1
while p < n:
    p *= 2
corr = np.fft.irfft(np.fft.rfft(src, p) * np.fft.rfft(clip[::-1], p), p)[:n-1]
peak = int(np.argmax(corr))
offset = (peak - (len(clip) - 1)) / 8000
print(f"{window_off + offset:.3f}")
