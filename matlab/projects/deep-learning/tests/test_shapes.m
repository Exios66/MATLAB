function tests = test_shapes()
%TEST_SHAPES Forward/backward shape invariants and valid predictions.
%   tests = test_shapes() collects the unit tests in this file.
%
%   Example:
%       >> runtests('tests/test_shapes.m')

addpath(fileparts(fileparts(mfilename('fullpath'))));
tests = functiontests(localfunctions);
end

function test_forward_backward_shapes_arbitrary_layers(tc)
sizes = [4 6 5 3];
n_samples = 11;
k = sizes(end);
rng(11);
params = mlp_init(sizes, 3);
X = randn(sizes(1), n_samples);

[probs, cache] = mlp_forward(params, X);
tc.verifyEqual(size(probs), [k, n_samples]);
tc.verifyEqual(size(cache.A{1}), [sizes(1), n_samples]);
tc.verifyEqual(size(cache.A{2}), [sizes(2), n_samples]);
tc.verifyEqual(size(cache.A{end}), [k, n_samples]);
tc.verifyEqual(numel(cache.Z), numel(sizes) - 1);
tc.verifyEqual(numel(cache.A), numel(sizes));

cls = randi(k, 1, n_samples);
Y = zeros(k, n_samples);
Y(sub2ind(size(Y), cls, 1:n_samples)) = 1;
grads = mlp_backward(params, cache, Y);
for i = 1:numel(sizes) - 1
    tc.verifyEqual(size(grads.dW{i}), size(params.W{i}));
    tc.verifyEqual(size(grads.db{i}), [sizes(i + 1), 1]);
end

labels = mlp_predict(params, X);
tc.verifyEqual(size(labels), [1, n_samples]);
tc.verifyEqual(all(labels >= 1 & labels <= k), true);
end

function test_single_hidden_unit_and_zero_hidden_layers(tc)
% degenerate nets must still produce consistent shapes
params = mlp_init([2 1 3], 5);
X = randn(2, 4);
[probs, cache] = mlp_forward(params, X);
tc.verifyEqual(size(probs), [3, 4]);
tc.verifyEqual(size(cache.A{2}), [1, 4]);
grads = mlp_backward(params, cache, ones(3, 4));
tc.verifyEqual(size(grads.dW{2}), [3, 1]);

% zero hidden layers: softmax directly on the input projection
p1 = mlp_init([1 3], 5);
[p1_probs, p1_cache] = mlp_forward(p1, randn(1, 2));
tc.verifyEqual(size(p1_probs), [3, 2]);
tc.verifyEqual(numel(p1_cache.Z), 1);
end

function test_train_history_and_predict_on_trained_net(tc)
rng(21);
[X, Y] = spiral_data(6, 3, 0.2, 0);
params = mlp_init([2 8 3], 2);
[params, loss_hist] = mlp_train(params, X, Y, ...
    struct('lr', 0.1, 'epochs', 2, 'batch_size', 6, 'seed', 0));
tc.verifyEqual(size(loss_hist), [1, 2]);
labels = mlp_predict(params, X);
tc.verifyEqual(size(labels), [1, 18]);
tc.verifyEqual(all(labels >= 1 & labels <= 3), true);
end
