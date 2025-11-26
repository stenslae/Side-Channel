% ==== TEST PULSAR ====
fs = 1000;                 % sampling rate
t = 0:1/fs:5;              % 5 seconds
x = zeros(size(t));        % init

pulse_width = 10; % samples
for idx = round(0.7*fs:0.7*fs:length(t))
    x(idx:idx+pulse_width-1) = 1;
end

% Add Noise
x_low     =  x + 0.1 * randn(size(x));
x_medium  =  x + 0.3* randn(size(x));
x_high    =  x + 0.5 * randn(size(x));


% ==== TEST PULSAR ====


noisy_sets = {
    'Clean', x;
    'Small Noise', x_low;
    'Medium Noise',x_medium;
    'High Noise',x_high
};

results = struct();

% THEN, CALL THIS FUNCTION
results = main_emma(noisy_sets, fs, t);

