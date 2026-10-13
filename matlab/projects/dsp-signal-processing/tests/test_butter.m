function tests = test_butter()
%TEST_BUTTER Tests for butter_lowpass_design (project DSP suite).
%   Function-based tests; runnable via the repo-root run_checks.m or
%   locally with runtests('tests'). Each test addpath()s the project root so
%   the suite works from any working directory.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
tests = functiontests(localfunctions);
end

function test_coefficients_finite_and_normalized(tc)
% Numerator B(z) = Omega_c^N (1+z^-1)^N is palindromic; A(z) is normalized.
[b, a] = butter_lowpass_design(0.3, 4);
tc.verifyTrue(all(isfinite(b)) && all(isfinite(a)));
tc.verifyEqual(b, fliplr(b), 'AbsTol', 1e-9);
tc.verifyEqual(a(1), 1, 'AbsTol', 1e-12);
tc.verifyEqual(numel(b), 5);
tc.verifyEqual(numel(a), 5);
end

function test_cutoff_minus3dB(tc)
% Prewarping puts the analog -3.0103 dB point exactly at w = pi*fc;
% +/- 0.5 dB window absorbs FFT-grid interpolation slop with 25x real margin.
[b, a] = butter_lowpass_design(0.25, 4);
[h, w] = freq_response(b, a, 4096);
db = interp1(w, 20*log10(abs(h)), 0.25*pi);
tc.verifyEqual(db, -3.01, 'AbsTol', 0.5);
end

function test_dc_gain_unity(tc)
% Butterworth analog DC gain is 1 and bilinear maps DC to DC => sum(b)/sum(a) = 1.
[b, a] = butter_lowpass_design(0.4, 3);
tc.verifyEqual(sum(b)/sum(a), 1, 'AbsTol', 1e-9);
end
