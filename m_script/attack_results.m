% ------------------------------------------------------------
%  Pulsar Obfuscation + Leakage: Results Analysis
%  Emma Stensland
%  MATLAB/Octave
% ------------------------------------------------------------

function attack_results(results, noisy_sets, t)

    fprintf("\n============================================================\n");
    fprintf("                   ATTACK RESULTS SUMMARY\n");
    fprintf("============================================================\n");

    % ============================================
    % UNPACK RESULTS
    % ============================================

    % Dimensions

    LEVELS  = {'Weak','Medium','Strong'};
    SNRs = noisy_sets(:,1);

    num_snr = length(SNRs);
    num_levels = length(LEVELS);
    total_sets = num_snr*num_levels;

    % Alloc Metrics (SNR index, Scramble Level index)

    fft_raw   = nan(num_snr, num_levels);
    fft_scr   = nan(num_snr, num_levels);
    fft_env   = nan(num_snr, num_levels);

    ac_raw    = nan(num_snr, num_levels);
    ac_scr    = nan(num_snr, num_levels);
    ac_env    = nan(num_snr, num_levels);

    psd_raw   = nan(num_snr, num_levels);
    psd_scr   = nan(num_snr, num_levels);
    psd_env   = nan(num_snr, num_levels);

    fft_freq_raw = nan(num_snr, num_levels);
    fft_freq_scr = nan(num_snr, num_levels);
    fft_freq_env = nan(num_snr, num_levels);

    auto_peak_raw = nan(num_snr, num_levels);
    auto_peak_scr = nan(num_snr, num_levels);
    auto_peak_env = nan(num_snr, num_levels);

    fft_adv  = nan(num_snr,num_levels);
    ac_adv   = nan(num_snr,num_levels);
    psd_adv  = nan(num_snr,num_levels);

    top5_hits  = false(num_snr,num_levels);
    seed_err  = nan(num_snr,num_levels);

    % Seed success tracking
    seed_success  = nan(num_snr, num_levels);
    seed_correct = 0;
    seed_time = 0;

    all_seed_time = [];

    % Sort Results into Matrices
    for i = 1:total_sets
        r = results(i);

        % Map SNR label to index
        snr_idx = find(strcmp(SNRs, r.label));
        lvl_idx = find(strcmp(LEVELS, r.level));

        % Store Leakage Metrics
        fft_raw(snr_idx, lvl_idx) = r.raw.fft_ratio;
        fft_scr(snr_idx, lvl_idx) = r.scr.fft_ratio;
        fft_env(snr_idx, lvl_idx) = r.env.fft_ratio;

        ac_raw(snr_idx, lvl_idx) = r.raw.autocorr_ratio;
        ac_scr(snr_idx, lvl_idx) = r.scr.autocorr_ratio;
        ac_env(snr_idx, lvl_idx) = r.env.autocorr_ratio;

        psd_raw(snr_idx, lvl_idx) = r.raw.psd_ratio;
        psd_scr(snr_idx, lvl_idx) = r.scr.psd_ratio;
        psd_env(snr_idx, lvl_idx) = r.env.psd_ratio;

        fft_freq_raw(snr_idx, lvl_idx) = r.raw.fft_peak_freq;
        fft_freq_scr(snr_idx, lvl_idx) = r.scr.fft_peak_freq;
        fft_freq_env(snr_idx, lvl_idx) = r.env.fft_peak_freq;

        auto_peak_raw(snr_idx, lvl_idx) = r.raw.autocorr_peak_time;
        auto_peak_scr(snr_idx, lvl_idx) = r.scr.autocorr_peak_time;
        auto_peak_env(snr_idx, lvl_idx)= r.env.autocorr_peak_time;

        fft_adv(snr_idx, lvl_idx)  = fft_env(snr_idx, lvl_idx) - fft_scr(snr_idx, lvl_idx);
        ac_adv(snr_idx, lvl_idx)   = ac_env(snr_idx, lvl_idx) - ac_scr(snr_idx, lvl_idx);
        psd_adv(snr_idx, lvl_idx)  = psd_env(snr_idx, lvl_idx) - psd_scr(snr_idx, lvl_idx);

        seed_err(snr_idx, lvl_idx) = r.seed_error;

        % Seed Success Metrics
        if any(r.seed_top5 == r.seed_true)
              top5_hits(snr_idx,lvl_idx) = true;
        end

        if r.seed_guess == r.seed_true
            seed_success(snr_idx, lvl_idx) = 1;
            seed_correct = seed_correct + 1;
        else
            seed_success(snr_idx, lvl_idx) = 0;
        end

        seed_time = seed_time + r.seed_time;
    end

    seed_time = seed_time/total_sets;

    % ============================================
    % PRINTED RESULTS
    % ============================================

    fprintf("\n------------------------------------------------------------\n");
    fprintf("                SCRAMBLED LEAKAGE SUMMARY\n");
    fprintf("------------------------------------------------------------\n");


    fprintf("\nLEAKAGE PER SCRAMBLING:\n");
    for i = 1:num_levels
        lvl = LEVELS{i};

        fprintf("\n  --- %-6s Scramble ---\n", lvl);
        fprintf("    FFT Ratio:       raw %.4f → scr %.4f\n", mean(fft_raw(:,i)), mean(fft_scr(:,i)));
        fprintf("    Autocorr Ratio:  raw %.4f → scr %.4f\n", mean(ac_raw(:,i)), mean(ac_scr(:,i)));
        fprintf("    PSD Ratio:       raw %.4f → scr %.4f\n", mean(psd_raw(:,i)), mean(psd_scr(:,i)));
        fprintf("    Peak Frequency:  raw %.4f → scr %.4f\n", mean(fft_freq_raw(:,i)), mean(fft_freq_scr(:,i)));
        fprintf("    Peak Time:       raw %.4f → scr %.4f\n", mean(auto_peak_raw(:,i)), mean(auto_peak_scr(:,i)));
    end

    fprintf("\nLEAKAGE PER SNR:\n");
    for i = 1:num_snr
        lvl = SNRs{i};

        fprintf("\n  --- %-6s Scramble ---\n", lvl);
        fprintf("    FFT ratio:       raw %.4f → scr %.4f\n", mean(fft_raw(i,:)), mean(fft_scr(i,:)));
        fprintf("    Autocorr ratio:  raw %.4f → scr %.4f\n", mean(ac_raw(i,:)), mean(ac_scr(i,:)));
        fprintf("    PSD ratio:       raw %.4f → scr %.4f\n", mean(psd_raw(i,:)), mean(psd_scr(i,:)));
        fprintf("    Peak Frequency:  raw %.4f → scr %.4f\n", mean(fft_freq_raw(i,:)), mean(fft_freq_scr(i,:)));
        fprintf("    Peak Time:       raw %.4f → scr %.4f\n", mean(auto_peak_raw(i,:)), mean(auto_peak_scr(i,:)));
    end


    fprintf("\n------------------------------------------------------------\n");
    fprintf("                ENVELOPE LEAKAGE SUMMARY\n");
    fprintf("------------------------------------------------------------\n");

    fprintf("\nLEAKAGE PER SCRAMBLING:\n");
    for i = 1:num_levels
        lvl = LEVELS{i};

        fprintf("\n  --- %-6s Scramble ---\n", lvl);
        fprintf("    FFT ratio:       raw %.4f → scr %.4f\n", mean(fft_raw(:,i)), mean(fft_env(:,i)));
        fprintf("    Autocorr ratio:  raw %.4f → scr %.4f\n", mean(ac_raw(:,i)), mean(ac_env(:,i)));
        fprintf("    PSD ratio:       raw %.4f → scr %.4f\n", mean(psd_raw(:,i)), mean(psd_env(:,i)));
        fprintf("    Peak Frequency:  raw %.4f → scr %.4f\n", mean(fft_freq_raw(:,i)), mean(fft_freq_env(:,i)));
        fprintf("    Peak Time:       raw %.4f → scr %.4f\n", mean(auto_peak_raw(:,i)), mean(auto_peak_env(:,i)));
    end

    fprintf("\nLEAKAGE PER SNR:\n");
    for i = 1:num_snr
        lvl = SNRs{i};

        fprintf("\n  --- %-6s Scramble ---\n", lvl);
        fprintf("    FFT ratio:       raw %.4f → scr %.4f\n", mean(fft_raw(i,:)), mean(fft_env(i,:)));
        fprintf("    Autocorr ratio:  raw %.4f → scr %.4f\n", mean(ac_raw(i,:)), mean(ac_env(i,:)));
        fprintf("    PSD ratio:       raw %.4f → scr %.4f\n", mean(psd_raw(i,:)), mean(psd_env(i,:)));
        fprintf("    Peak Frequency:  raw %.4f → scr %.4f\n", mean(fft_freq_raw(i,:)), mean(fft_freq_env(i,:)));
        fprintf("    Peak Time:       raw %.4f → scr %.4f\n", mean(auto_peak_raw(i,:)), mean(auto_peak_env(i,:)));
    end

    fprintf("\n------------------------------------------------------------\n");
    fprintf("                ENVELOPE ADVANTAGE\n");
    fprintf("------------------------------------------------------------\n");

    fprintf("\nENVELOPE ADVANTAGE PER SCRAMBLING:\n");
    for i = 1:num_levels
        lvl = LEVELS{i};

        fprintf("\n  --- %-6s Scramble ---\n", lvl);
        fprintf("    FFT Env advantage:       Δ = %.4f\n", mean(fft_adv(:,i)));
        fprintf("    Autocorr Env advantage:  Δ = %.4f\n", mean(ac_adv(:,i)));
        fprintf("    PSD Env advantage:       Δ = %.4f\n", mean(psd_adv(:,i)));
    end

    fprintf("\nENVELOPE ADVANTAGE PER SNR:\n");
    for i = 1:num_snr
        lvl = SNRs{i};

        fprintf("\n  --- %-6s Scramble ---\n", lvl);
        fprintf("    FFT Env advantage:       Δ = %.4f\n", mean(fft_adv(i,:)));
        fprintf("    Autocorr Env advantage:  Δ = %.4f\n", mean(ac_adv(i,:)));
        fprintf("    PSD Env advantage:       Δ = %.4f\n", mean(psd_adv(i,:)));
    end

    fprintf("\n------------------------------------------------------------\n");
    fprintf("                   SEED RECOVERY SUMMARY\n");
    fprintf("------------------------------------------------------------\n");

    MAE      = mean(mean(abs(seed_err)));
    RMSE     = sqrt(mean(mean(seed_err.^2)));
    top1_acc = 100 * mean(mean(seed_success));
    top5_acc = 100 * mean(mean(top5_hits));

    %  ==== Seed Recovery Stats ====

    fprintf("Attack Summary:\n");
    fprintf("%-30s : %d\n",   "Total Sets Brute Forced", total_sets);
    fprintf("%-30s : 1-%d\n", "Range of Seeds Guessed", results(1).seed_max);
    fprintf("%-30s : %d (%.2f%%)\n", "Successful Recoveries", seed_correct, 100*seed_correct/total_sets);
    fprintf("%-30s : %.4f sec\n\n", "Average Brute-Force Time", seed_time);

    fprintf("Accuracy/Error Metrics:\n");
    fprintf("%-35s : %.2f%%\n", "Top 1 Accuracy", top1_acc);
    fprintf("%-35s : %.2f%%\n", "Top 5 Accuracy", top5_acc);
    fprintf("%-35s : %.3f\n", "Mean Absolute Error (MAE)", MAE);
    fprintf("%-35s : %.3f\n\n", "Root Mean Square Error (RMSE)", RMSE);

    % ==== Per Scramble Level ====
    fprintf("Seed Recovery Success Rate per Scramble Level:\n");
    for i = 1:num_levels
        fprintf(" %-6s : %.2f%%\n", LEVELS{i}, 100*mean(seed_success(:,i)));
    end

    % ==== Per Noise Level ====
    fprintf("Seed Recovery Success Rate per Noise Level:\n");
    for i = 1:num_snr
        fprintf(" %-6s : %.2f%%\n", SNRs{i}, 100*mean(seed_success(i,:)));
    end

    % ============================================
    % PLOTTED RESULTS
    % ============================================

    %  ==== Raw, Scrambled, Enveloped Signal ====

    figure('Name','Signals');
    idx = 0;
    for i = 1:num_levels
        for j = 1:num_snr
            % Index into results
            idx = idx + 1;
            r = results(idx);

            % Plot raw, scrambled, enveloped
            subplot(num_levels, num_snr, idx);
            hold on;
            h2 = plot(t, r.scr_sig, 'r', 'LineWidth', 1);
            h1 = plot(t, r.raw_sig, 'b', 'LineWidth', 1);
            h3 = plot(t, r.env_sig, 'g', 'LineWidth', 1);
            hold off;

            if j == 1
                ylabel(sprintf('%s Scramble', LEVELS{i}), 'FontWeight', 'bold');
            end
            if i == 1
                title(sprintf('%s SNR', SNRs{j}));
            end
            if j == num_snr
                xlabel('Time [s]');
            end

            grid on;
        end
    end
    legend([h1 h2 h3], {'Raw', 'Scrambled' ,'Enveloped'}, 'location', 'northeastoutside');

    %  ==== Leakage Heatmaps ====

    figure('Name','Leakage Heatmap');
    subplot(3,1,1);
    imagesc(fft_scr); colorbar;
    xticks(1:num_levels); xticklabels(LEVELS);
    yticks(1:num_snr); yticklabels(SNRs);
    title('FFT Ratio Leakage'); xlabel('Scramble Level'); ylabel('SNR Level');

    subplot(3,1,2);
    imagesc(ac_scr); colorbar;
    xticks(1:num_levels); xticklabels(LEVELS);
    yticks(1:num_snr); yticklabels(SNRs);
    title('Autocorr Ratio Leakage'); xlabel('Scramble Level'); ylabel('SNR Level');

    subplot(3,1,3);
    imagesc(psd_scr); colorbar;
    xticks(1:num_levels); xticklabels(LEVELS);
    yticks(1:num_snr); yticklabels(SNRs);
    title('PSD Ratio Leakage'); xlabel('Scramble Level'); ylabel('SNR Level');

    %  ==== Envelope Advantage ====

    figure('Name','Envelope Advantage');
    subplot(3,1,1);
    imagesc(fft_adv); colorbar;
    xticks(1:num_levels); xticklabels(LEVELS);
    yticks(1:num_snr); yticklabels(SNRs);
    title('FFT Envelope Advantage'); xlabel('Scramble Level'); ylabel('SNR Level');

    subplot(3,1,2);
    imagesc(ac_adv); colorbar;
    xticks(1:num_levels); xticklabels(LEVELS);
    yticks(1:num_snr); yticklabels(SNRs);
    title('Autocorr Envelope Advantage'); xlabel('Scramble Level'); ylabel('SNR Level');

    subplot(3,1,3);
    imagesc(psd_adv); colorbar;
    xticks(1:num_levels); xticklabels(LEVELS);
    yticks(1:num_snr); yticklabels(SNRs);
    title('PSD Envelope Advantage'); xlabel('Scramble Level'); ylabel('SNR Level');

    % ==== Seed Plots ====

    % Bar: Top-1 vs Top-5 Accuracy per Scramble Level
    figure;
    bar([mean(seed_success(:,1)), mean(seed_success(:,2)), mean(seed_success(:,3));
         mean(top5_hits(:,1)), mean(top5_hits(:,2)), mean(top5_hits(:,3))]');
    legend({'Top-1','Top-5'});
    xticklabels({'Weak','Medium','Strong'});
    ylabel('Accuracy'); title('Seed Recovery Accuracy per Scramble Level');

    % Bar: Accuracy per Noise/SNR Level
    figure;
    bar(mean(seed_success,2));
    xticklabels(SNRs);
    ylabel('Accuracy'); title('Seed Recovery Accuracy vs Noise Level'); xlabel('SNR Level');

    % Heatmap of success grid
    figure;
    imagesc(seed_success); colorbar;
    xticks(1:3); xticklabels({'Weak','Medium','Strong'});
    yticks(1:num_snr); yticklabels(SNRs);
    xlabel('Scramble Level'); ylabel('SNR Level'); title('Top-1 Seed Recovery Heatmap');

    % Scatter: seed error
    figure;
    scatter(1:total_sets, seed_err(:));
    xlabel('Set index'); ylabel('Seed Error'); title('Seed Error across All Sets'); grid on;

    fprintf("\n============================================================\n");
    fprintf("                     END OF SUMMARY\n");
    fprintf("============================================================\n\n");

end
