function tests = test_freq_response()
%TEST_FREQ_RESPONSE Tests for freq_response (project DSP suite).
%   Function-based tests; runnable via the repo-root run_checks.m or
%   locally with runtests('tests'). Each test addpath()s the project root so
%   the suite works from any working directory.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
tests = functiontests(localfunctions);
end

function test_grid_and_dc_gain(tc)
% Grid spans [0, pi]; DC gain of the lowpass is exactly 1 (b is normalized
% so sum(b) = 1, and H(0) = sum(b) for an FIR filter).
b = fir_design_lowpass(0.25, 31, 'hamming');
[h, w] = freq_response(b, 1, 512);
tc.verifyEqual(w(1), 0);
tc.verifyEqual(w(end), pi, 'AbsTol', 1e-12);
tc.verifyEqual(abs(h(1)), 1, 'AbsTol', 1e-9);
end

function test_cutoff_minus6dB(tc)
% Tolerance: an ideal windowed-sinc lowpass sits at -6.02 dB at its cutoff
% (|H(wc)| = 1/2 by construction of the truncated sinc); window ripple and
% FFT-grid scalloping shift the measured peak by at most tenths of a dB,
% hence +/- 1 dB with 10x measured margin.
b = fir_design_lowpass(0.25, 101, 'hamming');
[h, w] = freq_response(b, 1, 4096);
db = interp1(w, 20*log10(abs(h)), 0.25*pi);
tc.verifyEqual(db, -6.02, 'AbsTol', 1);
end
