# Side-Channel Pulsar Analysis

## Table of Contents

1. [Introduction](#introduction)
   - [What is a SCA?](#what-is-a-side-channel-attack)
   - [Project Goals](#project-goals)
2. [Project Overview](#project-overview)
   - [Signal Scrambling and Descrambling Methods](#signal-scrambling-and-descrambling-methods)
   - [Autocorrelation Leakage](#autocorrelation-leakage)
   - [Spectral Fingerprinting](#spectral-fingerprinting)
   - [Envelope Detection](#envelope-detection)
   - [Seed Recovery/Brute-Force Attack](#seed-recovery)
3. [Takeaways](#takeaways)
   - [What techniques can detect data leakage in signals?](#what-techniques-can-detect-data-leakage-in-signals)
   - [How does scrambling level and the SNR affect pulsar data leakage?](#how-does-scrambling-level-and-the-snr-affect-pulsar-data-leakage)
   - [Can an attacker determine the seed used to obfuscate the signal?](#can-an-attacker-determine-the-seed-used-to-obfuscate-the-signal)
4. [References](#references)

## Introduction

### What is a Side-Channel Attack?

- **Side-Channel Attacks (SCA) are noninvasive attacks that target the implementation of a cryptographic algorithm instead of exploiting statistical/mathematical weaknesses.**
	- **Active Attacks** include fault injections such as EM interference, laser glitching, and clock pin tampering. The goal of these attacks is to use side channel techniques to alter the behavior of a device, such as making the device skip instructions or reveal secret information. 
	- **Passive Attacks** observe information a device unintentionally leaks through power usage, timing, or EM signals. The goal of these attacks is to use side channel techniques to expose device secrets.

- This project focuses on passive electromagnetic (EM) SCAs, which measure EM emissions from integrated circuits (ICs) during operation. EM signals are strongest where current switches rapidly, especially during transistor activity.
	- **Intentional EM emanations** come from normal current flow and are observable across full frequency bands. Attackers try to isolate the data path using a small, sensitive EM probes at higher frequencies.
 	- **Unintentional EM emanations** result from electrical/EM coupling between components, which generates modulated signals that may reveal internal behavior.

- There are multiple techniques/strategies used by attackers to determine secrets in EM signals.
	- **Simple EM Analysis** (SEMA) uses one time-domain trace to directly gain knowledge about the device. SEMA can only work when an attacker has prior knowledge about the device. Oftentimes, startup patterns on a device include information about device secret keys.
	- **Differential EM Analysis** (DEMA) extracts non-visible information from the device, which is especially useful for unknown devices. This involves using a self-referencing approach where an analyzed signal is compared with the signal at a different time or location on the device. DEMA exposes how signals propagate and the internal strcutural details of a device, which can assist in reverse engineering devices.

- **EM SCA Countermeasures** include  IC shielding, reducing circuit coupling, and adding noise such as dummy computations to hide real data.

### Project Goals

- **Pulsar signals** are periodic electromagnetic pulses from rotating neutron stars. This behavior displays patterns in high noise environments, and can be an effective model in understanding simple EM side-channel techniques.
- The primary [objectives](#takeaways) of this project are as follows:
	1. What techniques can detect data leakage in signals?
	2. How does scrambling level and the SNR affect pulsar data leakage?
	3. Can an attacker determine the seed used to obfuscate the signal?

---

## Project Overview

### Signal Scrambling and Descrambling Methods

#### Method

#### Results

---

### Autocorrelation Leakage

#### Method

#### Results

---

### Spectral Fingerprinting

#### Method

#### Results

---

### Envelope Detection

#### Results

### Noise and SNR Effects

---

### Seed Recovery

#### Goal

- An attack was simulated where an attacker attempts to recover the scrambling seed using **brute force.**
- **The following assumptions were made:**
  - The attacker has full access to the obfuscated signal.
  - The attacker knows the scrambling/bfuscation methods being used.

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
    - FFT Ratio was scaled loarithmically to normalize it.
    - Descrambled signals with the highest FFT and PSD ratios hinted towards the best reconstruction of the original signal.
      
6. **Noise Thresholding:** 
    - Applied fast pre-filters:
	    - The FFT, PSD, Envelope median were multiplied by a constant for scaling across noises
		- If the envelope, FFT, or PSD values were outside observed sane ranges, seed was skipped or rejected.
	- This reduced false positives by ensuring sure a seed scored well across all tests, and slightly improved runtime.

#### Results

Multiple batches of small sets of seeds (2^12 to 2^16 possible seeds) were tested. The scoring function showed a **consistent bias toward the correct seed** across noise and scrambling changes, until the seed set became too large. Even when collisions occurred (different seed, similar decoded output), **the true seed always appeared in the Top‑5 candidates** in small sets. Sets at or below 2^15 can successfully be brute forced, while sets greater than 2^15 present too many seed collisions.

An interesting note is that before implementing noise thresholding, Top‑1 & Top‑5 accuracy hovered around 50–75%, especially failing under high noise. After thresholding, Top‑5 accuracy reached 100%, showing that **thresholding corrected mis‑weighted spectral scores inflated by noise.**

Additionally, the speed of the brute force mechanism is slow. Some potential improvements would be improving speed by using MATLAB instead of Octave, as a lot of the brute force tasks could be parallelized, and MATLAB's parallelization performance is better. Using `parfor` for the brute force loops would greatly reduce runtime. 

##### Test 1 Results: 2048 Possible Seeds on the Same Signal of Varying Noise

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

##### Test 2 Results: 4096 Possible Seeds on the Same Signal of Varying Noise

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

##### Test 3 Results: 8,192 Possible Seeds on the Same Signal of Varying Noise

```bash

```

##### Test 4 Results: 16,384 Possible Seeds on the Same Signal of Varying Noise

```bash

```

##### Test 5 Results: 32,768 Possible Seeds on the Same Signal of Varying Noise

```bash

```

##### Test 6 Results: 65,536 Possible Seeds on the Same Signal of Varying Noise

```bash

```

##### Test 7 Results: 4096 Possible Seeds on the Varying Pulsar Signals with Low Noise

```bash

```

##### Test 8 Results: 4096 Possible Seeds on the Varying Pulsar Signals with Medium Noise

```bash

```

---

## Takeaways

### What techniques can detect data leakage in signals?



### How does scrambling level and the SNR affect pulsar data leakage?



### Can an attacker determine the seed used to obfuscate the signal?

When the seed space is small, an attacker could often recover the correct seed as the most likely (Top-1) candidate, regardless of the noise and scrambling levels. In some cases, a different seed generated a very similar descrambled output, which lowered Top-1 Accuracy. However, the system still achieved 100% Top‑5 accuracy, meaning the true seed consistently appeared among the five closest matches. With only 5 possible seeds, an attacker could do further analysis using other datasets to conclusively identify the seed.

For a single threaded process, brute forcing 2^16 seeds required approximately 40 minutes. **A more cryptographically significant number, such as 2^128 seeds, would take about 0.4 nonillion years to brute force!** Even if this system was parallelized, that would still be an **computationally infeasible** scale. At this magnitude, the amount of false-positive seed collisions also increases, raising the possiblity that the Top-5 candidates may not include the correct seed. 

In modern cryptography, this same principle is mirrored: **Sufficiently large key sizes make it computationally infeasible to determine the encryption key through brute‑force, even when the attacker has access to the encrypted data.** Once the number of possible keys becomes extremely large, key recovery by exhaustive search is no longer a practical attack vector.

## References

- Bhunia, Swarup, Mark Tehranipoor. *Hardware Security: A Hands On Learning Approach.* Elsevier Incorporated, 2019.
