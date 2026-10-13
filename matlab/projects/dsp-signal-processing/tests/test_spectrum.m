function tests = test_spectrum()
%TEST_SPECTRUM Tests for spectrum_periodogram (project DSP suite).
%   Function-based tests; runnable via the repo-root run_checks.m or
%   locally with runtests('tests'). Each test addpath()s the project root so
%   the suite works from any working directory.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
tests = functiontests(localfunctions);
end

function test_two_tone_peak_frequencies(tc)
% On-bin tones (fs = 8192, N = 8192 => 1 Hz per bin) must be recovered at
% their exact bin centers despite Hann side lobes and noise.
fs = 8192; M = 8192;
rng(3);
n = 0:M-1;
x = sin(2*pi*137*n/fs) + 0.5*sin(2*pi*319*n/fs) + 0.2*randn(1, M);
[f, psd] = spectrum_periodogram(x, fs);

inBand1 = f < 250;
[~, i1] = max(psd(inBand1));
band1 = f(inBand1);
tc.verifyEqual(band1(i1), 137, 'AbsTol', 1);

inBand2 = f > 250 & f < 600;
[~, i2] = max(psd(inBand2));
band2 = f(inBand2);
tc.verifyEqual(band2(i2), 319, 'AbsTol', 1);
end

function test_psd_integrates_to_variance(tc)
% With the sum(w.^2) scaling, the one-sided PSD integrates to the true signal
% power: the on-bin tone contributes amplitude^2/2 = 0.125 and white noise
% contributes sigma^2 = 0.04 => total 0.165, within 15%.
fs = 8192; M = 8192;
rng(3);
n = 0:M-1;
x = 0.5*sin(2*pi*319*n/fs) + 0.2*randn(1, M);
[~, psd] = spectrum_periodogram(x, fs);
total = sum(psd) * fs / M;          % sum * bin width integrates over [0, fs/2]
tc.verifyTrue(all(isfinite(psd)) && all(psd >= 0));
tc.verifyEqual(total, 0.165, 'RelTol', 0.15);
end
