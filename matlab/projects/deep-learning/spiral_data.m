function [X, Y] = spiral_data(n_per_class, k, noise, seed)
%SPIRAL_DATA Synthetic k-class 2-D spiral dataset for classification demos.
%   [X, Y] = spiral_data(n_per_class, k, noise, seed) returns:
%       X: 2-by-N point coordinates, N = n_per_class * k
%       Y: k-by-N one-hot class-label matrix
%   Each class is one Archimedean-style arm: radius grows 0..1 while the angle
%   sweeps 4 radians per arm (the classic 3-spiral benchmark layout), plus
%   Gaussian noise on the angle. seed (default 0) makes runs reproducible.
%
%   Example:
%       [X, Y] = spiral_data(40, 3, 0.1, 0);

if nargin < 4 || isempty(seed), seed = 0; end
if ~isscalar(n_per_class) || n_per_class < 1 || n_per_class ~= floor(n_per_class)
    error('spiral_data:badN', 'n_per_class must be a positive integer scalar.');
end
if ~isscalar(k) || k < 2 || k ~= floor(k)
    error('spiral_data:badK', 'k must be an integer >= 2.');
end
if ~isscalar(noise) || noise < 0
    error('spiral_data:badNoise', 'noise must be a non-negative scalar.');
end
if ~isscalar(seed) || seed < 0 || seed ~= floor(seed)
    error('spiral_data:badSeed', 'seed must be a non-negative integer scalar.');
end
rng(seed);

X = zeros(2, n_per_class * k);
Y = zeros(k, n_per_class * k);
for j = 1:k
    % 4 radians of sweep per arm keeps adjacent arms offset by a full turn.
    theta = linspace(4 * (j - 1), 4 * j, n_per_class).' + noise * randn(n_per_class, 1);
    r = linspace(1e-3, 1, n_per_class).';   % start off-origin: r=0 puts all k arms on one identical point
    pts = r * [sin(theta), cos(theta)];   % n_per_class-by-2
    cols = (j - 1) * n_per_class + (1:n_per_class);
    X(:, cols) = pts.';
    Y(j, cols) = 1;
end
end
