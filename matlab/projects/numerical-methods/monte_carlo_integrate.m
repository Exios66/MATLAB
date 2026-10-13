function [estimate, stderr] = monte_carlo_integrate(f, a, b, n, seed)
%MONTE_CARLO_INTEGRATE Plain Monte Carlo estimate of a 1-D integral.
%   [EST, SE] = monte_carlo_integrate(F, A, B, N) draws N uniform samples
%   on [A, B], evaluates the integrand at each, and returns the estimate
%   EST = (B - A) * mean(F(X)) together with the estimated standard error
%   SE = (B - A) * std(F(X)) / sqrt(N).
%
%   monte_carlo_integrate(F, A, B, N, SEED) calls RNG(SEED) first so the
%   result is reproducible (default SEED = 0).
%
%   F must be vectorized: F(X) on an N-by-1 vector must return one value
%   per sample (any orientation is normalized internally).
%
%   Example:
%       [est, se] = monte_carlo_integrate(@(x) x.^2, 0, 1, 1e5, 42);
%       fprintf('%.6f +/- %.6f (exact: %.6f)\n', est, se, 1/3);
%
%   See also: mc_pi, rng.

narginchk(4, 5);
if ~isa(f, 'function_handle')
    error('monte_carlo_integrate:badInput', 'F must be a function handle.');
end
if ~isscalar(a) || ~isnumeric(a) || ~isfinite(a) || ...
        ~isscalar(b) || ~isnumeric(b) || ~isfinite(b)
    error('monte_carlo_integrate:badInput', 'A and B must be finite numeric scalars.');
end
if ~isscalar(n) || ~isnumeric(n) || n < 1 || mod(n, 1) ~= 0
    error('monte_carlo_integrate:badInput', 'N must be a positive integer.');
end
if nargin < 5 || isempty(seed)
    seed = 0;
end
if ~isscalar(seed) || ~isnumeric(seed) || seed < 0 || mod(seed, 1) ~= 0
    error('monte_carlo_integrate:badInput', 'SEED must be a nonnegative integer.');
end

rng(seed);
x = a + (b - a) * rand(n, 1);
vals = reshape(f(x), [], 1);
if numel(vals) ~= n
    error('monte_carlo_integrate:notVectorized', ...
        'F must return one value per sample: got %d values for %d samples.', ...
        numel(vals), n);
end

estimate = (b - a) * mean(vals);
stderr = (b - a) * std(vals) / sqrt(n);
end
