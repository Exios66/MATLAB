function [probs, cache] = mlp_forward(params, X)
%MLP_FORWARD Forward pass: ReLU hidden layers, softmax output.
%   [probs, cache] = mlp_forward(params, X) runs a mini-batch X ((n_in)-by-N)
%   through the net and returns:
%       probs : (n_out)-by-N softmax class probabilities (rows sum to 1)
%       cache : struct with cache.Z{i} (pre-activations) and cache.A{i}
%               (activations, A{1} == input, A{end} == softmax output),
%               everything mlp_backward needs.
%
%   Example:
%       params = mlp_init([2 8 3], 0);
%       [probs, cache] = mlp_forward(params, [0; 0]);

if ~isstruct(params) || ~isfield(params, 'W') || ~iscell(params.W) || ~isfield(params, 'sizes')
    error('mlp_forward:badParams', 'params must be a struct from mlp_init.');
end
if ~isnumeric(X) || ~ismatrix(X)
    error('mlp_forward:badX', 'X must be a numeric matrix ((n_in)-by-N).');
end
if size(X, 1) ~= params.sizes(1)
    error('mlp_forward:dimMismatch', ...
        'X has %d rows but the net expects an input size of %d.', size(X, 1), params.sizes(1));
end

n_layers = numel(params.W);
cache.Z = cell(1, n_layers);
cache.A = cell(1, n_layers + 1);
cache.A{1} = X;
A = X;
for i = 1:n_layers
    Z = params.W{i} * A + params.b{i};
    cache.Z{i} = Z;
    if i < n_layers
        A = max(Z, 0);        % ReLU
    else
        A = softmax_columns(Z);
    end
    cache.A{i + 1} = A;
end
probs = A;
end

function P = softmax_columns(Z)
% Column-wise softmax with the max-shift trick: exp(x) overflows above ~709,
% so subtract each column's max first (softmax is invariant to that shift).
Zmax = max(Z, [], 1);
P = exp(Z - Zmax);
P = P ./ sum(P, 1);
end
