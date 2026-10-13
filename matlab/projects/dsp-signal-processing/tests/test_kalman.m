function tests = test_kalman()
%TEST_KALMAN Tests for kalman_filter (project DSP suite).
%   Function-based tests; runnable via the repo-root run_checks.m or
%   locally with runtests('tests'). Each test addpath()s the project root so
%   the suite works from any working directory. All signals are synthetic and
%   generated in-code with fixed rng seeds (deterministic).

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
tests = functiontests(localfunctions);
end

function test_noise_mse_reduction(tc)
% Tracking a slow sine through Gaussian noise: the filter's position estimate
% must have lower MSE than the raw measurements (large margin, seed 7).
rng(7);
M = 400; t = 0:M-1;
clean = sin(2*pi*0.01*t);
meas = clean + 0.4*randn(1, M);
[xhat, ~] = kalman_filter(meas, diag([1e-5, 3e-4]), 0.16, [meas(1); 0], 100*eye(2));
mseRaw = mean((meas - clean).^2);
mseFilt = mean((xhat(1, :) - clean).^2);
tc.verifyLessThan(mseFilt, mseRaw);
end

function test_recovers_constant_velocity(tc)
% A constant-velocity ramp measured through noise (R = sigma^2): the hidden
% velocity state must converge to the true v by the end of the record (seed 11).
rng(11);
M = 600; v = 0.25;
meas = v*(0:M-1) + 0.2*randn(1, M);
[xhat, ~] = kalman_filter(meas, diag([1e-5, 3e-6]), 0.04, [0; 0], diag([100, 100]));
tc.verifyLessThan(abs(xhat(2, end) - v), 0.05);
end
