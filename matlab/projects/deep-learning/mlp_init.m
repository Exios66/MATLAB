function params = mlp_init(layer_sizes, seed)
%MLP_INIT Build an MLP parameter struct with He-initialized weights.
%   params = mlp_init(layer_sizes, seed) creates a feed-forward net with the
%   given layer sizes, e.g. [n_in, n_hidden, ..., k] where k is #classes.
%   params is a struct:
%       params.sizes : the layer sizes, as a row vector
%       params.W{i}  : weight matrix for layer i  ((n_{i+1})-by-(n_i))
%       params.b{i}  : bias column vector for layer i ((n_{i+1})-by-1)
%   Weights use He initialization: randn * sqrt(2 / n_in), which keeps the
%   variance of activations stable across ReLU layers. seed (default 0) seeds
%   the RNG so initialization is reproducible.
%
%   Example:
%       params = mlp_init([2 32 3], 1);

if nargin < 2 || isempty(seed), seed = 0; end
if ~isnumeric(layer_sizes) || ~isvector(layer_sizes) || numel(layer_sizes) < 2 ...
        || any(layer_sizes < 1) || any(layer_sizes ~= floor(layer_sizes))
    error('mlp_init:badSizes', 'layer_sizes must be a vector of >= 2 positive integers.');
end
if ~isscalar(seed) || seed < 0 || seed ~= floor(seed)
    error('mlp_init:badSeed', 'seed must be a non-negative integer scalar.');
end
rng(seed);

layer_sizes = layer_sizes(:).';
n_layers = numel(layer_sizes) - 1;
params = struct();
params.sizes = layer_sizes;
params.W = cell(1, n_layers);
params.b = cell(1, n_layers);
for i = 1:n_layers
    n_in = layer_sizes(i);
    % He: Var(W) = 2/n_in keeps forward activation variance near 1 through ReLU.
    params.W{i} = randn(layer_sizes(i + 1), n_in) * sqrt(2 / n_in);
    params.b{i} = zeros(layer_sizes(i + 1), 1);
end
end
