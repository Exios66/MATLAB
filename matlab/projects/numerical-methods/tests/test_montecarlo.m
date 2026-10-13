function tests = test_montecarlo()
%TEST_MONTECARLO Function-based tests for monte_carlo_integrate and mc_pi.
%   The samplers live in the project root one level up; run_checks does
%   not set the path, so make that folder reachable at discovery time.

projRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projRoot);
tests = functiontests(localfunctions);
end

function test_mc_pi_within_wide_band(tc)
% Standard error at n = 2e5 is ~0.0037, so the band is ~14 sigma.
est = mc_pi(200000, 7);
tc.verifyTrue(abs(est - pi) < 0.05, sprintf('pi estimate = %.6f', est));
end

function test_integrate_estimate_bounded(tc)
% Exact value of integral_0^1 x^2 dx is 1/3; tolerance ~15 sigma, and the
% reported stderr must be positive and far below the band.
[est, se] = monte_carlo_integrate(@(x) x.^2, 0, 1, 200000, 42);
tc.verifyTrue(abs(est - 1/3) < 0.01, sprintf('estimate = %.6f', est));
tc.verifyTrue(se > 0 && se < 0.01, sprintf('stderr = %.6f', se));
end

function test_stderr_shrinks_with_n(tc)
% Same seed, 100x more samples: stderr far smaller (~10x expected).
[~, seCoarse] = monte_carlo_integrate(@(x) x.^2, 0, 1, 1000, 5);
[~, seFine] = monte_carlo_integrate(@(x) x.^2, 0, 1, 100000, 5);
tc.verifyTrue(seFine < seCoarse, ...
    sprintf('stderr n=1000: %.3g, n=1e5: %.3g', seCoarse, seFine));
end

function test_same_seed_reproduces(tc)
% Fixed seed must give bit-identical results across calls.
tc.verifyEqual(mc_pi(1000, 11), mc_pi(1000, 11));
tc.verifyEqual(monte_carlo_integrate(@(x) x.^2, 0, 1, 1000, 11), ...
    monte_carlo_integrate(@(x) x.^2, 0, 1, 1000, 11));
end

function test_nonvectorized_integrand_raises(tc)
% SUM collapses the sample vector to a scalar: must raise, not mislead.
tc.verifyError(@() monte_carlo_integrate(@(x) sum(x), 0, 1, 100, 1), ...
    'monte_carlo_integrate:notVectorized');
end
