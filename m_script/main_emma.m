% ------------------------------------------------------------
%  Pulsar Obfuscation + Leakage: Main
%  Emma Stensland
%  MATLAB/Octave
% ------------------------------------------------------------

function results = main_emma(noisy_sets, fs, t)
    results = struct();

    %  Three scramble strengths for all SNR: weak, medium, strong
    scr_level = {'Weak','Medium','Strong','Strongest'};

    % Generate random seed from 1 to 1000
    max_seed = 1000;
    seed = randi(max_seed);

    iteration = 0;

    for si = 1:length(scr_level)
        level = scr_level{si};

        for ni = 1:length(noisy_sets(:,1))
           iteration = iteration + 1;
            label = noisy_sets{ni,1};
            x = noisy_sets{ni,2};

            % ==== SCRAMBLE SIGNAL ====
            x_scr = scramble_signal(x, fs, seed, level);

            % ==== DETERMINING SCRAMBLED SIGNAL PATTERNS ====
            % Analyze raw to quantify sucess
            titles_raw = sprintf('Raw Signal, %s SNR',label);
            raw_metrics = analyze_leakage(x, fs, titles_raw);

            % Autocorrelation Leakage and Spectral Fingerprinting
            titles_scr = sprintf('Leakage and Fingerprinting, %s SNR & %s Scrambling',label,level);
            scr_metrics = analyze_leakage(x_scr, fs, titles_scr);

            % Pulse Repetition Detection
            env = abs(hilbert(x_scr));
            % Autocorrelation Leakage and Spectral Fingerprinting on Enveloped Pulse
            titles_env = sprintf('Enveloped, %s SNR & %s Scrambling',label,level);
            env_metrics = analyze_leakage(env, fs, titles_env);

            % Store Results
            results(iteration).label = label;
            results(iteration).level = level;
            results(iteration).raw   = raw_metrics;
            results(iteration).scr   = scr_metrics;
            results(iteration).env   = env_metrics;
            results(iteration).raw_sig   = x;
            results(iteration).scr_sig  = x_scr;
            results(iteration).env_sig  = env;

            % ==== EXPOSING SEED USED TO OBFUSCATE SIGNAL ====
            tic
            best_score = -Inf;
            best_seed = 0;
            for test_seed = 1:max_seed
                   for si = 1:1%length(scr_level)
                        test_level = scr_level{si};
                        % Try descrambling with seed and guessed level
                        y = descramble_signal(x_scr, fs, test_seed, test_level);

                        % Normalize signal
                        y = y / std(y);

                        % FFT score
                        Y = abs(fft(y));
                        N = length(Y);
                        Y = Y(1:N/2);
                        fft_score = max(Y)/median(Y);

                        % Autocorr score
                        [r, lags] = xcorr(y, 'normalized');
                        r(lags == 0) = 0;
                        ac_score = max(r);

                        % Combined score
                        score = fft_score * ac_score;

                        % Save high score
                        if score > best_score
                            best_score = score;
                            best_seed = test_seed;
                        end
                  end
             end

            % Store Results
            results(iteration).seed_max = max_seed;
            results(iteration).seed_time = toc;
            results(iteration).seed_true  = seed;
            results(iteration).seed_guess = best_seed;

            % ==== DESCRAMBLE SIGNAL ====
            fieldname = sprintf('snr_%s_scramble_%s', label, level);
            results(iteration).descrambled = descramble_signal(x_scr, fs, seed,level);

        end
    end

    % Compare results across scrambling metrics
    attack_results(results, noisy_sets, t);
end

