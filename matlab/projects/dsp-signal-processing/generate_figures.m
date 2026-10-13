function generate_figures(seed)
%GENERATE_FIGURES Generate all project figures as PNGs into images/ (R2020a+).
%   generate_figures() regenerates every PNG referenced by README.md from
%   deterministic synthetic signals, writing:
%       images/fig1_fir_vs_butter_magnitude.png
%       images/fig2_filtering_overlay.png
%       images/fig3_periodogram_two_tones.png
%       images/fig4_window_functions.png
%   generate_figures(SEED) uses a different rng seed (default 0).
%   Run from this project's root directory (paths are relative on purpose).
%
%   Example:
%       generate_figures()

narginchk(0, 1);
if nargin < 1
    seed = 0;
end
if ~isnumeric(seed) || ~isscalar(seed) || ~isfinite(seed) || seed < 0
    error('generate_figures:badSeed', 'SEED must be a nonnegative scalar.');
end
rng(seed);                          % reproducible figures

outdir = 'images';
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% ---- Figure 1: FIR (windowed-sinc) vs Butterworth magnitude responses
fc = 0.25;
bFir = fir_design_lowpass(fc, 63, 'hamming');
[bBut, aBut] = butter_lowpass_design(fc, 4);
[hFir, wFir] = freq_response(bFir, 1, 2048);
[hBut, wBut] = freq_response(bBut, aBut, 2048);

figure(1); clf; hold on; grid on;
plot(wFir/pi, 20*log10(abs(hFir) + eps), 'LineWidth', 1.4);
plot(wBut/pi, 20*log10(abs(hBut) + eps), 'LineWidth', 1.4);
yline(-3.01, '--');
yline(-6.02, ':');
xlim([0 1]); ylim([-90 5]);
xlabel('Normalized frequency (f / f_{Nyquist})');
ylabel('Magnitude (dB)');
title(sprintf('Magnitude responses at f_c = %.2f', fc));
legend({'FIR windowed-sinc (N=63, Hamming)', 'Butterworth (order 4)', ...
        '-3.01 dB: Butterworth cutoff', '-6.02 dB: windowed-sinc cutoff'}, ...
        'Location', 'southwest');
exportgraphics(gcf, fullfile(outdir, 'fig1_fir_vs_butter_magnitude.png'), 'Resolution', 150);

% ---- Figure 2: noisy signal vs FIR-filtered vs Kalman-smoothed overlay
M = 400; t = 0:M-1;
clean = sin(2*pi*0.02*t);
meas = clean + 0.6*randn(1, M);
yFir = apply_filter(bFir, meas);    % passes the 0.02 tone, kills broadband noise
delay = (numel(bFir) - 1)/2;
yFirAligned = [yFir(1+delay:end), nan(1, delay)];  % shift back its linear-phase delay
[xhat, ~] = kalman_filter(meas, diag([1e-3, 1e-2]), 0.36, [meas(1); 0], diag([100, 10]));

figure(2); clf; hold on; grid on;
plot(t, meas, 'Color', [0.75 0.75 0.75]);
plot(t, clean, 'k--', 'LineWidth', 1.2);
plot(t, yFirAligned, 'LineWidth', 1.4);
plot(t, xhat(1, :), 'LineWidth', 1.4);
xlabel('Sample'); ylabel('Amplitude');
title('Time domain: noisy signal vs FIR lowpass vs Kalman smoothing');
legend({'noisy measurement', 'clean', 'FIR lowpass (delay-aligned)', ...
        'Kalman position'}, 'Location', 'northeast');
exportgraphics(gcf, fullfile(outdir, 'fig2_filtering_overlay.png'), 'Resolution', 150);

% ---- Figure 3: periodogram of synthetic two-tone + noise
fs = 8192; Ns = 8192;
n = 0:Ns-1;
x = sin(2*pi*137*n/fs) + 0.5*sin(2*pi*319*n/fs) + 0.2*randn(1, Ns);
[f3, psd] = spectrum_periodogram(x, fs);

figure(3); clf; hold on; grid on;
plot(f3, 10*log10(psd + eps), 'LineWidth', 1.1);
xline(137, 'r--');
xline(319, 'r--');
xlim([0 fs/2]);
xlabel('Frequency (Hz)'); ylabel('PSD (10 log_{10}, units^2/Hz)');
title('Hann periodogram: tones 1.0 @ 137 Hz and 0.5 @ 319 Hz, \sigma = 0.2 noise');
exportgraphics(gcf, fullfile(outdir, 'fig3_periodogram_two_tones.png'), 'Resolution', 150);

% ---- Figure 4: the two windows the FIR design uses
Nw = 64;
figure(4); clf; hold on; grid on;
plot(window_hann(Nw), 'LineWidth', 1.4);
plot(window_hamming(Nw), 'LineWidth', 1.4);
xlabel('Tap'); ylabel('Weight');
title('Symmetric windows implemented from formulas (N = 64)');
legend({'Hann: 0.5(1 - cos(2\pin/(N-1)))', 'Hamming: 0.54 - 0.46cos(2\pin/(N-1))'}, ...
        'Location', 'north');
exportgraphics(gcf, fullfile(outdir, 'fig4_window_functions.png'), 'Resolution', 150);

close all;
end
