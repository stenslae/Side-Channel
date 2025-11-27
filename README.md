# ⚡ Side‑Channel Analysis

A MATLAB/Octave framework for experimenting with signal leakage, scrambling, and side‑channel attacks on simulated pulsar‑like repeated pulse signals: [Full Report](pulsar_report.md)

## 🎯 Project Purpose

- Analyze vulnerabilities in **repeated pulse signals**
- Evaluate **obfuscation and scrambling** techniques
- Measure **spectral and temporal leakage**
- Perform **brute‑force seed recovery** using side‑channel scoring

## 🧠 System Overview

| Feature | Implementation |
|---|---|
| **Platform** | GNU Octave |
| **Languages** | MATLAB / Octave |
| **Signal Analysis Methods** | FFT, Autocorrelation, Power Spectral Density (PSD) |
| **Obfuscation Techniques** | Bit flipping, Amplitude shifting, Timing jitter |
| **Attack Method** | Brute‑force seed scoring via combined spectral + temporal leakage + envelope correlation |

## 📝 Framework Components

### 🔀 1. Scrambling / Obfuscation

#### Overview
The system scrambles signals at three strengths:

| Strength | Description |
|---|---|
| **Weak** | Bit flip only |
| **Medium** | Bit flip + amplitude shift |
| **Strong** | Bit flip + amplitude shift + timing jitter |

### 📡 2. Leakage Analysis

#### Overview
Each signal variant (raw, scrambled, enveloped) is evaluated using:

| Metric | Purpose |
|---|---|
| **FFT Peak Ratio** | Measures dominant spectral peaks vs noise floor |
| **Autocorrelation Ratio** | Quantifies pulse repetition detectability |
| **PSD Ratio** | Highlights structured signal content relative to noise |

### 🧩 3. Seed Recovery Attack

#### Overview
A brute‑force side‑channel attack attempts seed recovery by:

1. Iterating over possible seeds **(1–16384)**
2. Testing all possible **scrambling strengths**
3. Descrambling the signal using each seed guess
5. Scoring leakage using **(combined FFT + autocorrelation ratios) * envelope correlation**
6. Discarding bad individual scores.
7. Selecting the **highest‑scoring seed** as the recovered seed.

## 🚀 Basic Usage

- Use the pre-made [driver.m](m_script/driver.m), or use it as below:

```matlab
% noisy_sets: cell array {label, signal}
% fs: sampling frequency
% t: optional time vector for plotting/analysis

results = main_emma(noisy_sets, fs, t);
```

## 💡 Acknowledgements

- MATLAB/Octave Content was developed for a final project in EELE308 at MSU Bozeman.
