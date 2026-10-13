function tests = test_window()
%TEST_WINDOW Tests for window_hann / window_hamming (project DSP suite).
%   Function-based tests; runnable via the repo-root run_checks.m or
%   locally with runtests('tests'). Each test addpath()s the project root so
%   the suite works from any working directory.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
tests = functiontests(localfunctions);
end

function test_symmetry(tc)
% Symmetric windows: w(n) == w(N+1-n) to numerical precision
% (cos(2*pi - t) == cos(t) up to float roundoff).
for N = [8, 64]
    wh = window_hann(N);
    wm = window_hamming(N);
    tc.verifyLessThan(max(abs(wh - fliplr(wh))), 1e-12);
    tc.verifyLessThan(max(abs(wm - fliplr(wm))), 1e-12);
end
end

function test_known_values_and_sum(tc)
% Hand-derived N = 4 values: hann = 0.5*(1 - [1 cos(2pi/3) cos(4pi/3) cos(2pi)])
% = [0 0.75 0.75 0], sum = (N-1)/2; hamming endpoints 0.54-0.46 = 0.08,
% sum = 0.54*4 - 0.46*sum(cos) = 2.16 - 0.46 = 1.7 (sum of cos over full period is 1).
wh4 = window_hann(4);
tc.verifyEqual(wh4, [0, 0.75, 0.75, 0], 'AbsTol', 1e-12);
tc.verifyEqual(sum(wh4), 1.5, 'AbsTol', 1e-12);
wm4 = window_hamming(4);
tc.verifyEqual(wm4(1), 0.08, 'AbsTol', 1e-12);
tc.verifyEqual(sum(wm4), 1.7, 'AbsTol', 1e-12);
end

function test_length_shape_and_edge(tc)
% Row vector of length N for every valid N; N = 1 degenerate window is 1.
for N = [1, 2, 8, 63]
    tc.verifyEqual(size(window_hann(N)), [1, N]);
    tc.verifyEqual(size(window_hamming(N)), [1, N]);
end
tc.verifyEqual(window_hann(1), 1, 'AbsTol', 1e-15);
tc.verifyEqual(window_hamming(1), 1, 'AbsTol', 1e-15);
end
