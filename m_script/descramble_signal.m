% ------------------------------------------------------------
%  Pulsar Obfuscation + Leakage: Descramble Signal
%  Emma Stensland
%  MATLAB/Octave
% ------------------------------------------------------------
function y = descramble_signal(x, fs, seed, strength)
    N = length(x);
    % Chunk signal
    chunk_duration = 0.01;
    chunk_len = round(chunk_duration * fs);
    numChunks = ceil(N / chunk_len);

    % Generate the flip, scale, jitter, and phase based on seed
    rng(seed,'twister');

    flips = sign(randn(1, numChunks));
    flips(flips==0) = 1;

    scale  = 0.9 + 0.2*rand(1, numChunks);
    max_jitter = round(0.02 * chunk_len);

    jitter = randi([-max_jitter, max_jitter], 1, numChunks);

    FFT_SIZE = 2^nextpow2(round(0.01 * fs));
    phase = 2*pi*rand(1, FFT_SIZE);

    y = x;

    % Unscramble each chunk
    for k = 1:numChunks
        % Built segment to unscramble
        a = (k-1)*chunk_len + 1;
        b = min(a + chunk_len - 1, N);
        segment = y(a:b);

        % 1. Phase Descramble
        if any(strcmp(strength, {'Strongest'}))
              S = fft(segment, FFT_SIZE);

              % Undo phase scramble
              s_un = abs(S) .* exp(-1i * phase);
              segment = real(ifft(s_un, FFT_SIZE));
        end

        % 1. Reverse Jitter
        if any(strcmp(strength, {'Strong', 'Strongest'}))
            segment = circshift(segment, -jitter(k));
        end

        % 2. Reverse amplitude scaling
        if any(strcmp(strength, {'Medium','Strong', 'Strongest'}))
            segment = segment ./ scale(k);
        end

        % 3. Reverse polarity flipping
        if any(strcmp(strength, {'Weak','Medium','Strong', 'Strongest'}))
            segment = segment .* flips(k);
        end

        % Add segment to scrambled signal
        y(a:b) = segment(1:(b-a+1));
    end
end

