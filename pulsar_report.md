# Side-Channel Pulsar Analysis

## Table of Contents

1. [Introduction](#introduction)
   - [Project Goals](#project-goals)
   - [What is a SCA?](#what-is-a-side-channel-attack)
2. [Project Overview](#project-overview)
   - [Autocorrelation Leakage](#autocorrelation-leakage)
   - [Spectral Fingerprinting](#spectral-fingerprinting)
   - [Envelope Detection](#envelope-detection)
   - [Signal Scrambling and Descrambling](#signal-scrambling-and-descrambling)
   - [Seed Recovery/Brute-Force Attack](#seed-recovery)
3. [Takeaways](#takeaways)
   - [What techniques can detect data leakage in signals?](#what-techniques-can-detect-data-leakage-in-signals)
   - [How does scrambling level and the SNR affect pulsar signal leakage?](#how-does-scrambling-level-and-the-snr-affect-pulsar-signal-leakage)
   - [Can an attacker recover the obfuscation seed?](#can-an-attacker-recover-the-obfuscation-seed)
4. [References](#references)

## Introduction

### Project Goals

- **Pulsar signals** are periodic electromagnetic (EM) pulses from rotating neutron stars. Naturally, I decided to attack simulated ones using EM side‑channel analysis and a brute‑force seed recovery approach. Because pulsars are basically beacon signals with absurd periodicity, brute‑forcing them is easier than explaining what neutron stars are.
- **In this project, the side-channel is the simulated pulsar emissions, and the ‘target device’ is the scrambling algorithm applied to it.**
- The primary [objectives](#takeaways) of this project are as follows:
	1. What techniques can detect data leakage in signals?
	2. How does scrambling level and SNR affect pulsar signal leakage?
	3. Can an attacker recover the obfuscation seed?

### What is a Side-Channel Attack?

- **Side-Channel Attacks (SCA) are noninvasive attacks that target how a cryptographic system works, rather than breaking math directly.**
	- **Active Attacks** include fault injections such as EM interference, laser glitching, and clock pin tampering. The goal of these attacks is to use side channel techniques to alter the behavior of a device, such as making the device skip instructions or reveal secret information. 
	- **Passive Attacks** observe information a device unintentionally leaks through power usage, timing, or EM signals. The goal of these attacks is to use side channel techniques to expose device secrets.

- This project focuses on passive electromagnetic (EM) SCAs, which measure EM emissions from integrated circuits (ICs) during operation. EM signals are strongest where current switches rapidly, especially during transistor activity.
	- **Intentional EM emanations** come from normal current flow, visible across frequency bands. Hackers try to isolate the data path using tiny, super-sensitive EM probes.
 	- **Unintentional EM emanations** result from electrical coupling between components, which generate modulated signals that can reveal internal behavior.

- There are multiple techniques/strategies used by attackers to determine secrets in EM signals.
	- **Simple EM Analysis** (SEMA) uses one time-domain trace to directly gain knowledge about the device. SEMA can only work when an attacker has prior knowledge about the device. Oftentimes, startup patterns on a device include information about device secret keys.
	- **Differential EM Analysis** (DEMA) extracts non-visible information from the device, which is especially useful for unknown devices. This involves using a self-referencing approach where an analyzed signal is compared with the signal at a different time or location on the device. DEMA exposes how signals propagate and the internal structural details of a device, which can assist in reverse engineering devices.

- **EM SCA Countermeasures** include IC shielding, reducing circuit coupling, and adding noise such as dummy computations to hide real data.

---

## Project Overview

### Autocorrelation Leakage

#### Method

- **Autocorrelation** measures how similar a signal is to the delayed copy of itself.
- The autocorrelation ratio is defined as the maximum value of the signal’s autocorrelation function divided by the median value of the autocorrelation function, which serves as a typical baseline correlation level across non-periodic lags.
- In this application, the autocorrelation ratio can would reveal periodicity, since strongly periodic signals produce pronounced peaks in autocorrelation, raising the maximum relative to the median background level.
- The lag at which the maximum autocorrelation occurs was defined as **Peak Time,** representing the delay distance where signal values are most similar.

#### Results

- Autocorrelation tried to detect leakage, and failed spectacularly. The autocorrelation peak occurred near zero lag, indicating that the pulsars were not detected. Instead, regions dominated by zeros or noise produced the strongest correlation.
- The extremely high autocorrelation at zero lag artificially inflated the autocorrelation ratio, causing misleadingly high leakage scores.
- For future improvement, being stricter at removing peaks around zero could result in helpful autocorrelation metrics.

<details>
<summary>Show Autocorrelation Leakage Results</summary>
	
```bash
LEAKAGE PER SCRAMBLING:

  --- Weak   Scramble ---
    Autocorr Ratio:  raw 57.6587 → scr 1044.9951
    Peak Time:       raw -0.2297 → scr -0.1298

  --- Medium Scramble ---
    Autocorr Ratio:  raw 57.6587 → scr 1109.3901
    Peak Time:       raw -0.2297 → scr -0.1298

  --- Strong Scramble ---
    Autocorr Ratio:  raw 57.6587 → scr 1109.3901
    Peak Time:       raw -0.2297 → scr -0.1298

LEAKAGE PER SNR:

  --- Clean  Scramble ---
    Autocorr ratio:  raw 124.4321 → scr 4243.4494
    Peak Time:       raw -0.0010 → scr -0.0010

  --- Small Noise Scramble ---
    Autocorr ratio:  raw 89.6477 → scr 90.5435
    Peak Time:       raw -0.0010 → scr -0.0010

  --- Medium Noise Scramble ---
    Autocorr ratio:  raw 9.1464 → scr 8.8272
    Peak Time:       raw -0.7030 → scr -0.0030

  --- Large Noise Scramble ---
    Autocorr ratio:  raw 7.4088 → scr 8.8803
    Peak Time:       raw -0.2140 → scr -0.5140

LEAKAGE PER SIGNAL TYPE:

  --- 1 Pulse Scrambled ---
    Autocorr ratio:  raw 147.2793 → scr 187.7847
    Peak Time:       raw -0.7000 → scr -0.0010

  --- 0.5 Pulse Scrambled ---
    Autocorr ratio:  raw 86.3595 → scr 75.3490
    Peak Time:       raw -0.7000 → scr -0.0010

  --- Closer Pulses Scrambled ---
    Autocorr ratio:  raw 78.7259 → scr 266.4291
    Peak Time:       raw -0.4000 → scr -0.0010

  --- Sparser Pulses Scrambled ---
    Autocorr ratio:  raw 109.2674 → scr 99.2498
    Peak Time:       raw -0.9000 → scr -0.0010
```
</details>

---

### Spectral Fingerprinting

#### Method

- Spectral fingerprinting is when instead of analyzing signals in the time domain, signals are analyzed in the frequency domain.
- The **Fourier Transform** displays peaks of a signal where the signal has frequencies present. The maximum peak within the positive frequencies was divided by the median magnitude results in the FFT Ratio. The FFT Ratio would reveal the level of periodicity at the most common frequency in the signal.
- **Power Spectral Density** describes how the average power of a signal is distributed across frequencies. The maximum peak divided by the median results in the PSD Ratio. The PSD Ratio would reveal at what frequency the signal is most "active" in terms of power, which would point to periodic behavior.

#### Results

- Spectral fingerprinting successfully revealed leakage from pulsar periodicity. Both FFT ratio and PSD ratio increased significantly after scrambling, confirming that periodic structure remained detectable in the frequency domain. As the scrambling was altered within the time domain using linear transformations, scrambling has little effect on the FFT and PSD ratios.

- Noise, unsuprisingly, significantly reduced peak contrast for spectral fingerprinting, which reduced leakage metrics.

- Unlike autocorrelation, these spectral ratios remained stable for pulsars because the median reflects the spectral noise floor, instead of the zero-valued gaps between pulses.

<details>
<summary>Show Spectral Leakage Results</summary>

```bash
LEAKAGE PER SCRAMBLING:

  --- Weak   Scramble ---
    FFT ratio:       raw 21.0289 → scr 35.7219
    PSD ratio:       raw 27.9163 → scr 51.0598

  --- Medium Scramble ---
    FFT ratio:       raw 21.0289 → scr 36.4163
    PSD ratio:       raw 27.9163 → scr 51.6677

  --- Strong Scramble ---
    FFT ratio:       raw 21.0289 → scr 36.4163
    PSD ratio:       raw 27.9163 → scr 51.6677

LEAKAGE PER SNR:

  --- Clean  Scramble ---
    FFT ratio:       raw 65.5754 → scr 104.9585
    PSD ratio:       raw 94.9915 → scr 152.0865

  --- Small Noise Scramble ---
    FFT ratio:       raw 11.6789 → scr 29.0597
    PSD ratio:       raw 13.8907 → scr 48.2311

  --- Medium Noise Scramble ---
    FFT ratio:       raw 3.1430 → scr 5.9951
    PSD ratio:       raw 1.4567 → scr 3.1022

  --- Large Noise Scramble ---
    FFT ratio:       raw 3.7184 → scr 4.7259
    PSD ratio:       raw 1.3264 → scr 2.4405

LEAKAGE PER SIGNAL TYPE:

  --- 1 Pulse Scrambled ---
    FFT ratio:       raw 21.8187 → scr 7.7326
    PSD ratio:       raw 12.7011 → scr 10.0374

  --- 0.5 Pulse Scrambled ---
    FFT ratio:       raw 12.4458 → scr 4.8115
    PSD ratio:       raw 4.3181 → scr 3.6587

  --- Closer Pulses Scrambled ---
    FFT ratio:       raw 39.9514 → scr 8.1480
    PSD ratio:       raw 20.2944 → scr 14.8910

  --- Sparser Pulses Scrambled ---
    FFT ratio:       raw 12.3007 → scr 5.8656
    PSD ratio:       raw 5.2453 → scr 4.3928
```
</details>

![Leakage Heatmap](outputs/leakage_heatmap.jpg)

---

### Envelope Detection

#### Method

- **Enveloping** is a process that smooths signals and outlines its extremes.
- The **Hilbert transform** phase shifts a signal by 90 degrees. When the raw signal is added to the Hilbert transform, this creates the **analytic signal.** The analytic signal quantifies how much the signal rotates over time.
- The amplitude of the analytic signal was used as the envelope, capturing instantaneous amplitude independent from phase.
- This method does not remove noise, but it reduces visible oscillations in the envelope because phase cancels out when calculating magnitude.
- Because peak amplitudes are preserved while phase variations are ignored, periodic energy leakage becomes easier to detect in spectral analysis.

#### Results

- **Applying envelope detection increased spectral leakage detectability** compared to scrambled signals, particularly in low-noise environments.

- The advantage of enveloping the signal was consistent across all scrambling levels, while noise reduced the advantage. But, in high noise environments, spectral analysis effectiveness dropped substantially regardless of envelope processing.

- Autocorrelation was still useless, though. This is due to autocorrelation being less effective in pulsar detection, as pulsars are too sparse for autocorrelation to detect anything.

<details>
<summary>Show Envelope Leakage Results</summary>

```bash
LEAKAGE PER SCRAMBLING:

  --- Weak   Scramble ---
    FFT ratio:       raw 21.0289 → env 35.7219
    Autocorr ratio:  raw 57.6587 → env 60.1267
    PSD ratio:       raw 27.9163 → env 51.0598
    FFT Env advantage:       Δ = 29.4265
    Autocorr Env advantage:  Δ = -984.8684
    PSD Env advantage:       Δ = 42.9061

  --- Medium Scramble ---
    FFT ratio:       raw 21.0289 → env 36.4163
    Autocorr ratio:  raw 57.6587 → env 59.7550
    PSD ratio:       raw 27.9163 → env 51.6677
    FFT Env advantage:       Δ = 30.0338
    Autocorr Env advantage:  Δ = -1049.6350
    PSD Env advantage:       Δ = 43.2114

  --- Strong Scramble ---
    FFT ratio:       raw 21.0289 → env 36.4163
    Autocorr ratio:  raw 57.6587 → env 59.7550
    PSD ratio:       raw 27.9163 → env 51.6677
    FFT Env advantage:       Δ = 30.0338
    Autocorr Env advantage:  Δ = -1049.6350
    PSD Env advantage:       Δ = 43.2114

LEAKAGE PER SNR:

  --- Clean  Scramble ---
    FFT ratio:       raw 65.5754 → env 104.9585
    Autocorr ratio:  raw 124.4321 → env 38.6938
    PSD ratio:       raw 94.9915 → env 152.0865
    FFT Env advantage:       Δ = 93.3915
    Autocorr Env advantage:  Δ = -4204.7556
    PSD Env advantage:       Δ = 129.0851

  --- Small Noise Scramble ---
    FFT ratio:       raw 11.6789 → env 29.0597
    Autocorr ratio:  raw 89.6477 → env 75.4846
    PSD ratio:       raw 13.8907 → env 48.2311
    FFT Env advantage:       Δ = 22.5205
    Autocorr Env advantage:  Δ = -15.0589
    PSD Env advantage:       Δ = 40.5631

  --- Medium Noise Scramble ---
    FFT ratio:       raw 3.1430 → env 5.9951
    Autocorr ratio:  raw 9.1464 → env 63.1983
    PSD ratio:       raw 1.4567 → env 3.1022
    FFT Env advantage:       Δ = 2.3793
    Autocorr Env advantage:  Δ = 54.3711
    PSD Env advantage:       Δ = 1.5891

  --- Large Noise Scramble ---
    FFT ratio:       raw 3.7184 → env 4.7259
    Autocorr ratio:  raw 7.4088 → env 62.1391
    PSD ratio:       raw 1.3264 → env 2.4405
    FFT Env advantage:       Δ = 1.0342
    Autocorr Env advantage:  Δ = 53.2587
    PSD Env advantage:       Δ = 1.2014

ENVELOPE ADVANTAGE PER SIGNAL TYPE:

  --- 1 Pulse Scramble ---
    FFT ratio:       raw 21.8187 → scr 54.6307
    Autocorr ratio:  raw 154.7263 → scr 60.4480
    PSD ratio:       raw 12.7011 → scr 62.7734
    FFT Env advantage:       Δ = 46.8981
    Autocorr Env advantage:  Δ = -140.4959
    PSD Env advantage:       Δ = 52.7360

  --- 0.5 Pulse Scramble ---
    FFT ratio:       raw 12.4458 → scr 24.8449
    Autocorr ratio:  raw 82.7742 → scr 101.9501
    PSD ratio:       raw 4.3181 → scr 15.6295
    FFT Env advantage:       Δ = 20.0334
    Autocorr Env advantage:  Δ = 22.3071
    PSD Env advantage:       Δ = 11.9708

  --- Closer Pulses Scramble ---
    FFT ratio:       raw 39.9514 → scr 95.4196
    Autocorr ratio:  raw 79.4739 → scr 35.3196
    PSD ratio:       raw 20.2944 → scr 82.4980
    FFT Env advantage:       Δ = 87.2716
    Autocorr Env advantage:  Δ = -239.9549
    PSD Env advantage:       Δ = 67.6070

  --- Sparser Pulses Scramble ---
    FFT ratio:       raw 12.3007 → scr 30.6706
    Autocorr ratio:  raw 106.2562 → scr 116.0302
    PSD ratio:       raw 5.2453 → scr 23.7434
    FFT Env advantage:       Δ = 24.8050
    Autocorr Env advantage:  Δ = 18.9280
    PSD Env advantage:       Δ = 19.3506
```
</details>

![Envelope Heatmap](outputs/envelope_advantage.jpg)

- Additionally, direct waveform inspection showed that the enveloped obfuscated signal still had distinguishable pulsar peaks across all tested SNR and scrambling conditions:
  
![All Signal Levels](outputs/signals.jpg)

---

### Signal Scrambling and Descrambling

#### Method

1. **Seeded RNGs:**
   - The implementation uses a **seeded Mersenne Twister PRNG.**
   - Mersenne Twister generators build an internal state array initialized from an input seed. Each successive values in the PRNG stream are deterministically derived from this state. As a result, **re-initializing the generator with the same seed reproduces the same sequence,** provided that random draw functions are called in the same order.
   - In MATLAB/Octave, calling `rng(seed)` sets the **global random stream,** making random values dependent on both the seed and the number of times the stream has been sampled.
   - Calling `rng(seed)` again in the program resets the global stream, which can lead to identical random values being generated if subsequent random function calls occur in the same sequence.
   
2. **Chunking the Signal:**
   - The signal was separated into individual chunks for scrambling.
     
3. **Scrambling Level 1: Flipping**
   - Each chunk was assigned a random probability of being flipped (reversed in time).
   
4. **Scrambling Level 2: Amplitude Shifting**
   - Chunks were multiplied by a randomly generated scale factor.
   
5. **Scrambling Level 3: Time Jitter**
   - A circular time offset (circshift) was applied to each chunk using a random shift value.
     
6. **Descrambling:**
   - Chunks were reconstructed by applying the inverse operations in reverse order:
     	- 1. Undo Time Jitter
     	- 2. Undo Amplitude shifting
     	- 3. Undo Flipping
   - The correlation coefficient between the descrambled signal and the raw input signal was 1.0, confirming lossless reversal of scrambling.

#### Results

- Scrambled signal variants were compared against both raw and enveloped signals:
![Signal Comparisons](outputs/signal_compare2.jpg)

- The scrambling tried its best, but the pulsars were not having it. Even scrambled the signals periodic structure can still be revealed through visual inspection and spectral analysis.

- In the time domain, particularly under high-noise conditions, scrambling more successfully obscured the original signal's structure.

- Although scrambling did not fully mask periodicity, it slightly reduce spectral detection strength, indicating that the method could still serve as a lightweight obfuscation layer in noisy environments.

---

### Seed Recovery

#### Goal

- An attack was simulated where an attacker attempts to recover the scrambling seed using **brute force.**
- **The following assumptions were made:**
  - The attacker has full access to the obfuscated signal.
  - The attacker knows the scrambling/obfuscation methods being used.

#### Method

1. **Leakage Pre-Analysis:**
    - Evaluated leakage metrics on the scrambled signal.
    - The envelope contained the most preserved structure, so envelope correlation became a key scoring component.
    - FFT and PSD ratios were selected as the main spectral fingerprints.
    - Final scoring strategy was defined as: `score = (PSD ratio + log‑scaled FFT ratio) × envelope correlation coefficient`
	
2. **Loop Design:**
    - Nested exhaustive searches: `scrambling levels` × `candidate seeds.`
    
3. **Seed Trials:**
    - The scrambled signal was descrambled with the guessed seed. 
    - Output was normalized.
      
4. **Envelope Matching:**
    - The envelope of the descrambled signal had its correlation coefficient compared to the envelope of the scrambled signal.
    - A value close to `1.0` indicated similar peak structure and helped reject high spectral ratios that were not preserving the original signal's leakage.
    
5. **Spectral Ratio Scoring:** 
    - Computed the `FFT Ratio` and `PSD Ratio`.
    - Ratios were scaled logarithmically to normalize then.
    - Descrambled signals with the highest FFT and PSD ratios hinted towards the best reconstruction of the original signal.
      
6. **Noise Thresholding:** 
    - Applied fast pre-filters:
	    - Envelope median was scaled with its height for a minimum envelope scaled with noise.
      	- PSD and FFT ratios were thresholded to 1.2.
		- If the envelope, FFT, or PSD values were outside observed sane ranges, seed was skipped or rejected.
	- This reduced false positives by ensuring sure a seed scored well across all tests, and slightly improved runtime.
 	- Hardcoded values were originally used based on scoring trend observation. But, more flexible thresholds had to be allowed once expanded to larger signal inputs.

#### Results

Multiple batches of small sets of seeds (2^11 to 2^16 possible seeds) were tested. The scoring function showed a **consistent bias toward the correct seed** across noise and scrambling changes.

An interesting note is that before implementing noise thresholding, Top‑1 & Top‑5 accuracy hovered around 50–75%, especially failing under high noise. After thresholding, Top‑5 accuracy reached 100%, showing that **thresholding corrected mis‑weighted spectral scores inflated by noise.**

Additionally, the speed of the brute force mechanism is slow enough to provide a week-long stress test for your CPU. Some potential improvements would be improving speed by using MATLAB instead of Octave, as a lot of the brute force tasks could be parallelized, and MATLAB's parallelization performance is better. Using `parfor` for the brute force loops would greatly reduce runtime... (Yes, I learned that after doing 90% of my testing)

<details>
<summary>Show Test 1 Results: 2,048 Possible Seeds on the Same Signal of Varying Noise</summary>

```bash
Attack Summary:
Total Sets Brute Forced        : 15
Range of Seeds Guessed         : 1-2048
Successful Recoveries          : 15 (100.00%)
Average Brute-Force Time       : 128.1219 sec

Accuracy Metrics:
Top 1 Accuracy                 : 100.00%
Top 5 Accuracy                 : 100.00%

Seed Recovery Success Rate per Scramble Level:
 Weak   : 100.00%
 Medium : 100.00%
 Strong : 100.00%
Seed Recovery Success Rate per Noise Level:
 Clean  : 100.00%
 Low Noise : 100.00%
 Small Noise : 100.00%
 Medium Noise : 100.00%
 High Noise : 100.00%
 ```
</details>

<details>
<summary>Show Test 2 Results: 4,096 Possible Seeds on the Same Signal of Varying Noise</summary>

```bash
Attack Summary:
Total Sets Brute Forced        : 15
Range of Seeds Guessed         : 1-4096
Successful Recoveries          : 15 (100.00%)
Average Brute-Force Time       : 143.1173 sec

Accuracy Metrics:
Top 1 Accuracy                      : 100.00%
Top 5 Accuracy                      : 100.00%

Seed Recovery Success Rate per Scramble Level:
 Weak   : 100.00%
 Medium : 100.00%
 Strong : 100.00%
Seed Recovery Success Rate per Noise Level:
 Clean  : 100.00%
 Low Noise : 100.00%
 Small Noise : 100.00%
 Medium Noise : 100.00%
 High Noise : 100.00%
 ```
</details>

<details>
<summary>Show Test 3 Results: 8,192 Possible Seeds on the Same Signal of Varying Noise</summary>

```bash
Attack Summary:
Total Sets Brute Forced        : 15
Range of Seeds Guessed         : 1-8192
Successful Recoveries          : 15 (100.00%)
Average Brute-Force Time       : 513.3424 sec

Accuracy/Error Metrics:
Top 1 Accuracy                 : 100.00%
Top 5 Accuracy                 : 100.00%

Seed Recovery Success Rate per Scramble Level:
 Weak   : 100.00%
 Medium : 100.00%
 Strong : 100.00%
Seed Recovery Success Rate per Noise Level:
 Clean  : 100.00%
 Low Noise : 100.00%
 Small Noise : 100.00%
 Medium Noise : 100.00%
 High Noise : 100.00%
```
</details>

<details>
<summary>Show Test 4 Results: 32,768 Possible Seeds on the Same Signal of Varying Noise</summary>

```bash
Attack Summary:
Total Sets Brute Forced        : 15
Range of Seeds Guessed         : 1-32768
Successful Recoveries          : 15 (100.00%)
Average Brute-Force Time       : 2048.3212 sec

Accuracy/Error Metrics:
Top 1 Accuracy                 : 100.00%
Top 5 Accuracy                 : 100.00%

Seed Recovery Success Rate per Scramble Level:
 Weak   : 100.00%
 Medium : 100.00%
 Strong : 100.00%
Seed Recovery Success Rate per Noise Level:
 Clean  : 100.00%
 Low Noise : 100.00%
 Small Noise : 100.00%
 Medium Noise : 100.00%
 High Noise : 100.00%
```
</details>

<details>
<summary>Show Test 6 Results: 4,096 Possible Seeds on the Varying Pulsar Signals with Low Noise</summary>

```bash
Attack Summary:
Total Sets Brute Forced        : 12
Range of Seeds Guessed         : 1-4096
Successful Recoveries          : 12 (100.00%)
Average Brute-Force Time       : 624.5926 sec

Accuracy/Error Metrics:
Top 1 Accuracy                 : 100.00%
Top 5 Accuracy                 : 100.00%

Seed Recovery Success Rate per Scramble Level:
 Weak   : 100.00%
 Medium : 100.00%
 Strong : 100.00%
Seed Recovery Success Rate per Noise Level:
 1 Pulse : 100.00%
 0.5 Pulse : 100.00%
 Closer Pulses : 100.00%
 Sparser Pulses : 100.00%
```
</details>

<details>
<summary>Show Test 7 Results: 4,096 Possible Seeds on the Varying Pulsar Signals with Medium Noise</summary>

```bash
Attack Summary:
Total Sets Brute Forced        : 12
Range of Seeds Guessed         : 1-4096
Successful Recoveries          : 12 (100.00%)
Average Brute-Force Time       : 627.8566 sec

Accuracy/Error Metrics:
Top 1 Accuracy                 : 100.00%
Top 5 Accuracy                 : 100.00%

Seed Recovery Success Rate per Scramble Level:
 Weak   : 100.00%
 Medium : 100.00%
 Strong : 100.00%
Seed Recovery Success Rate per Noise Level:
 1 Pulse : 100.00%
 0.5 Pulse : 100.00%
 Closer Pulses : 100.00%
 Sparser Pulses : 100.00%
```
</details>

---

## Takeaways

### What techniques can detect data leakage in signals?

Time-domain inspection is the simplest method. In low-noise environments, periodic signals such as pulsars are often clearly visible, even when obfuscated. When block-based scrambling is applied, blocks containing repeated or highly similar content can leave distinct visual patterns, which an observer may exploit to infer structure.

Autocorrelation analysis aims to detect periodicity, but in sparse signals such as the pulsars analyzed, autocorrelation performs poorly and produced unstable metrics. This means it may fail to reveal meaningful leakage. On the other hand, frequency-domain techniques were extremely effective in this application, due to the periodic nature of these signals. By examining the Fourier Tranform and Power Spectral Density, it was possible to identify dominant frequency components that would often persist after time-based scrambling. This would allow attackers to detect leakage if time-domain methods fail.

Lastly, by computing the analytic signal of a pulsar-like waveform using the Hilbert transform and obtaining signal’s envelope, amplitude variations were highlighted over time. The envelope essentially smoothed out the signal, which improved metrics of other signal analysis techniques within this application.

Side-channel analysis can extend these ideas to cases where the attacker has limited knowledge of the system. Without access to internal device architecture, observation of signal patterns in the time-domain, correlations and envelopes, or frequency signatures can reveal exploitable structures.

### How does scrambling level and the SNR affect pulsar signal leakage?

Increasing the amount of scrambling only slightly reduced detectable leakage in the pulsar signals. Even with the strongest scrambling, the underlying periodic structure was visible. As the scrambling was based in the time domain, and the signal was scrambled in small chunks, the signal's structure was not modified significantly enough to reduce detectable leakage. By implementing stronger scrambling that modifies the true shape of the signal, there would be less signal information leakage.

Interestingly, the signal-to-noise ratio (SNR) had a more significant effect on leakage detection. Low SNR pulsar signals suppressed peak contrast across time and frequency domain metrics, which reduced the effectiveness of brute-force seed matching and leakage metrics.

This is where good circuit design comes into play as a defense against SCAs. By reducing ambient SNR for side-channels, there is a reduced risk in exposing sensitive information on devices.

### Can an attacker recover the obfuscation seed?

When the seed space is small, an attacker could often recover the correct seed as the most likely (Top-1) candidate, regardless of the noise and scrambling levels. In some cases, a different seed generated a very similar descrambled output, which lowered Top-1 Accuracy. However, the system still achieved 100% Top‑5 accuracy, meaning the true seed consistently appeared among the five closest matches. With only 5 possible seeds, an attacker could do further analysis using other datasets to conclusively identify the seed.

For a single threaded process, brute-forcing 2^16 seeds took ~40 minutes. Not bad for a confused undergraduate. **Scaling to 2^128 seeds, however, would take ~0.4 nonillion years.** That's kind of a long time. Even if this system was parallelized, that would still be a *computationally infeasible* scale. 

In modern cryptography, this same principle is mirrored: *Sufficiently large key sizes make it computationally infeasible to determine the encryption key through brute‑force, even when the attacker has access to the encrypted data.* Once the number of possible keys becomes extremely large, key recovery by exhaustive search is no longer a practical attack vector.

## References

- Bhunia, Swarup, Mark Tehranipoor. *Hardware Security: A Hands On Learning Approach.* Elsevier Incorporated, 2019.
- Wikipedia & Mathworks Documentation.
