function [params, loss_history] = mlp_train(params, X, Y, opts)
%MLP_TRAIN Mini-batch SGD on the MLP from mlp_init.
%   [params, loss_history] = mlp_train(params, X, Y, opts) runs opts.epochs
%   epochs of shuffled mini-batch gradient descent and returns the updated
%   params plus loss_history (1-by-epochs): running mean cross-entropy over
%   each epoch's mini-batch losses (params update between batches, so this
%   is a moving average, not a fixed-point evaluation).
%   opts fields, all optional:
%       lr          learning rate      (default 0.1)
%       epochs      passes over data   (default 300)
%       batch_size  samples per step   (default 32)
%       seed        RNG seed           (default 0; reseeds at start)
%
%   Example:
%       [X, Y] = spiral_data(40, 3, 0.1, 0);
%       params = mlp_init([2 32 3], 1);
%       [params, loss_history] = mlp_train(params, X, Y, struct('lr', 0.1, 'epochs', 50));

if nargin < 4 || isempty(opts), opts = struct(); end
if ~isstruct(params) || ~isfield(params, 'W')
    error('mlp_train:badParams', 'params must be a struct from mlp_init.');
end
if ~isnumeric(X) || ~ismatrix(X) || size(X, 1) ~= params.sizes(1)
    error('mlp_train:badX', 'X must be numeric ((n_in)-by-N) matching the net input size.');
end
if size(Y, 1) ~= params.sizes(end) || size(Y, 2) ~= size(X, 2)
    error('mlp_train:badY', 'Y must be one-hot ((n_out)-by-N) with one column per X column.');
end
if ~isstruct(opts)
    error('mlp_train:badOpts', 'opts must be a struct (possibly empty).');
end
if ~isfield(opts, 'lr'), opts.lr = 0.1; end
if ~isfield(opts, 'epochs'), opts.epochs = 300; end
if ~isfield(opts, 'batch_size'), opts.batch_size = 32; end
if ~isfield(opts, 'seed'), opts.seed = 0; end
if ~isscalar(opts.lr) || opts.lr <= 0
    error('mlp_train:badLR', 'opts.lr must be a positive scalar.');
end
if ~isscalar(opts.epochs) || opts.epochs < 1 || opts.epochs ~= floor(opts.epochs)
    error('mlp_train:badEpochs', 'opts.epochs must be a positive integer.');
end
if ~isscalar(opts.batch_size) || opts.batch_size < 1 ...
        || opts.batch_size ~= floor(opts.batch_size) || opts.batch_size > size(X, 2)
    error('mlp_train:badBatch', 'opts.batch_size must be an integer in 1..N.');
end
if ~isscalar(opts.seed) || opts.seed < 0 || opts.seed ~= floor(opts.seed)
    error('mlp_train:badSeed', 'opts.seed must be a non-negative integer scalar.');
end
rng(opts.seed);

N = size(X, 2);
loss_history = zeros(1, opts.epochs);
for t = 1:opts.epochs
    perm = randperm(N);
    total_ce = 0;
    for s = 1:opts.batch_size:N
        idx = perm(s:min(s + opts.batch_size - 1, N));
        [probs, cache] = mlp_forward(params, X(:, idx));
        % unnormalized CE over this batch; batches tile the epoch exactly once
        total_ce = total_ce - sum(sum(Y(:, idx) .* log(max(probs, 1e-12))));
        grads = mlp_backward(params, cache, Y(:, idx));
        for i = 1:numel(params.W)
            params.W{i} = params.W{i} - opts.lr * grads.dW{i};
            params.b{i} = params.b{i} - opts.lr * grads.db{i};
        end
    end
    loss_history(t) = total_ce / N;
end
end
