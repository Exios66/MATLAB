function labels = mlp_predict(params, X)
%MLP_PREDICT Class predictions from the MLP.
%   labels = mlp_predict(params, X) returns the predicted class index
%   (1..n_out) for every column of X as a 1-by-N row vector. Ties break to the
%   lowest index, so predictions are deterministic. Accuracy is computed by the
%   caller, e.g. mean(labels == true_class).
%
%   Example:
%       params = mlp_init([2 8 3], 0);
%       labels = mlp_predict(params, [0 1 2; 0 -1 2]);

if ~isstruct(params) || ~isfield(params, 'W') || ~isfield(params, 'sizes')
    error('mlp_predict:badParams', 'params must be a struct from mlp_init.');
end
if ~isnumeric(X) || ~ismatrix(X) || size(X, 1) ~= params.sizes(1)
    error('mlp_predict:badX', 'X must be numeric ((n_in)-by-N) matching the net input size.');
end
probs = mlp_forward(params, X);
[~, labels] = max(probs, [], 1);
end
