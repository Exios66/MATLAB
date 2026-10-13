function grads = mlp_backward(params, cache, Y)
%MLP_BACKWARD Backprop: gradients of the mean cross-entropy loss.
%   grads = mlp_backward(params, cache, Y) returns gradients of the
%   sample-averaged cross-entropy loss with respect to every W{i} and b{i}:
%       grads.dW{i} : same shape as params.W{i}
%       grads.db{i} : same shape as params.b{i}
%   Y is the one-hot target matrix ((n_out)-by-N).
%
%   Example:
%       params = mlp_init([2 8 3], 0);
%       [probs, cache] = mlp_forward(params, [0 1; 0 -1]);
%       Y = logical([1 0; 0 0; 0 1]);
%       grads = mlp_backward(params, cache, double(Y));

if ~isstruct(params) || ~isfield(params, 'W') || ~iscell(params.W)
    error('mlp_backward:badParams', 'params must be a struct from mlp_init.');
end
if ~isstruct(cache) || ~isfield(cache, 'A') || ~isfield(cache, 'Z') ...
        || numel(cache.A) ~= numel(params.W) + 1
    error('mlp_backward:badCache', 'cache must come from mlp_forward with the same net.');
end
Y = double(Y);
if ~isequal(size(Y), size(cache.A{end}))
    error('mlp_backward:dimMismatch', ...
        'Y (%dx%d) must match the softmax output (%dx%d).', ...
        size(Y, 1), size(Y, 2), size(cache.A{end}, 1), size(cache.A{end}, 2));
end

n_layers = numel(params.W);
N = size(Y, 2);
% Softmax + cross-entropy simplification: for L = mean CE and P = softmax(Z_L),
% the chain rule through dP_c/dZ_t = P_c (1{c=t} - P_t) collapses the whole
% output jacobian to dL/dZ_L = (P - Y)/N -- one subtraction instead of a
% k-by-k jacobian per sample.
D = (cache.A{end} - Y) / N;

grads = struct();
grads.dW = cell(1, n_layers);
grads.db = cell(1, n_layers);
for i = n_layers:-1:1
    grads.dW{i} = D * cache.A{i}.';      % (n_{i+1}-by-N) * (N-by-n_i)
    grads.db{i} = sum(D, 2);             % column vector
    if i > 1
        D = (params.W{i}.' * D) .* (cache.Z{i - 1} > 0);   % ReLU gate
    end
end
end
