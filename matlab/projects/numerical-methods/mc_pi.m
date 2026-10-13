function estimate = mc_pi(n, seed)
%MC_PI Monte Carlo estimate of pi by uniform darts in the unit square.
%   EST = mc_pi(N) draws N uniform points in [0,1]^2 and returns
%   4 * (fraction of points inside the quarter unit circle) as an
%   estimate of PI. Standard error is about 1.642/sqrt(N).
%
%   est = mc_pi(N, SEED) calls RNG(SEED) first for reproducibility
%   (default SEED = 0).
%
%   Example:
%       est = mc_pi(200000, 42);
%       abs(est - pi)   % typically a few times 1e-3
%
%   See also: monte_carlo_integrate, rng.

narginchk(1, 2);
if ~isscalar(n) || ~isnumeric(n) || n < 1 || mod(n, 1) ~= 0
    error('mc_pi:badInput', 'N must be a positive integer.');
end
if nargin < 2 || isempty(seed)
    seed = 0;
end
if ~isscalar(seed) || ~isnumeric(seed) || seed < 0 || mod(seed, 1) ~= 0
    error('mc_pi:badInput', 'SEED must be a nonnegative integer.');
end

rng(seed);                                   % deterministic by default
pts = rand(n, 2);                            % N darts in the unit square
inside = sum(pts(:,1).^2 + pts(:,2).^2 <= 1);
estimate = 4 * inside / n;
end
