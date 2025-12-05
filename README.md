# ⚡ Pulsar Side‑Channels

A MATLAB/Octave framework for experimenting with signal leakage, scrambling, and side‑channel attacks on simulated pulsar‑like repeated pulse signals: [Full Report](pulsar_report.md)

## System Overview

| Feature | Implementation |
|---|---|
| **Platform** | GNU Octave |
| **Languages** | MATLAB / Octave |
| **Signal Analysis Methods** | FFT, Autocorrelation, Power Spectral Density (PSD) |
| **Obfuscation Techniques** | Bit flipping, Amplitude shifting, Timing jitter |
| **Attack Method** | Brute‑force seed scoring via combined spectral + temporal leakage + envelope correlation |

## Basic Usage

- Use the pre-made [driver.m](m_script/driver.m), or use it as below:

```matlab
% noisy_sets: cell array {label, signal}
% fs: sampling frequency
% t: optional time vector for plotting/analysis

results = main_emma(noisy_sets, fs, t);
```

## Acknowledgements

- MATLAB/Octave Content was developed for a final project in EELE308 at MSU Bozeman.
