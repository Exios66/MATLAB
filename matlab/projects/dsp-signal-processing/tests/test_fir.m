function tests = test_fir()
%TEST_FIR Tests for fir_design_lowpass (project DSP suite).
%   Function-based tests; runnable via the repo-root run_checks.m or
%   locally with runtests('tests'). Each test addpath()s the project root so
%   the suite works from any working directory.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
tests = functiontests(localfunctions);
end

function test_impulse_response_symmetry(tc)
% Symmetry about the center tap => exactly linear phase.
% N = 5, fc = 0.25, hamming — hand-derived values:
% h = fc*sinc(fc*(n-2)) = [0.15915, 0.22508, 0.25, 0.22508, 0.15915],
% window = [0.08 0.54 1.0 0.54 0.08], product sum = 0.51855,
% b(3) = 0.25/0.51855 = 0.4821, b(1) = 0.08*0.15915/0.51855 = 0.02456.
b = fir_design_lowpass(0.25, 5, 'hamming');
tc.verifyEqual(b(1), b(5), 'AbsTol', 1e-12);
tc.verifyEqual(b(2), b(4), 'AbsTol', 1e-12);
tc.verifyEqual(b(3), 0.4821, 'AbsTol', 1e-3);
end

function test_passband_gain(tc)
% Deep inside the passband (0.3*fc vs passband edge ~fc) the gain is ~unity.
b = fir_design_lowpass(0.25, 63, 'hamming');
[h, w] = freq_response(b, 1, 4096);
g = interp1(w, abs(h), 0.3*0.25*pi);
tc.verifyGreaterThan(g, 0.9);
end

function test_stopband_attenuation(tc)
% Deep in the stopband (3*fc vs stopband edge ~fc + mainlobe/2 ~ 0.31) with a
% Hamming window the attenuation exceeds 20 dB by a wide margin (~53 dB).
b = fir_design_lowpass(0.25, 63, 'hamming');
[h, w] = freq_response(b, 1, 4096);
db = interp1(w, 20*log10(abs(h) + eps), 3*0.25*pi);
tc.verifyLessThan(db, -20);
end
