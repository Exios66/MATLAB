function tests = test_gradient()
%TEST_GRADIENT Numerical-vs-analytic gradient check for mlp_backward.
%   tests = test_gradient() collects the unit tests in this file.
%
%   Example:
%       >> runtests('tests/test_gradient.m')

% make project functions visible no matter how runtests discovered this file
addpath(fileparts(fileparts(mfilename('fullpath'))));
tests = functiontests(localfunctions);
end

function test_numerical_gradient_matches_backward(tc)
utils_check_gradient(tc, [3 4 2], 6, 7);
end

function test_gradient_two_hidden_layers(tc)
utils_check_gradient(tc, [3 4 3 2], 5, 9);
end

function utils_check_gradient(tc, sizes, n_samples, seed)
% Compare every analytic gradient (mlp_backward) against central finite
% differences of the same loss mlp_train minimizes.
rng(seed);
params0 = mlp_init(sizes, seed + 1);
X = randn(sizes(1), n_samples);
cls = randi(sizes(end), 1, n_samples);
Y = zeros(sizes(end), n_samples);
Y(sub2ind(size(Y), cls, 1:n_samples)) = 1;

[~, cache] = mlp_forward(params0, X);
grads = mlp_backward(params0, cache, Y);

h = 1e-5;
max_rel = 0;
n_checked = 0;
for l = 1:numel(sizes) - 1
    for r = 1:size(params0.W{l}, 1)
        for c = 1:size(params0.W{l}, 2)
            rel = relative_error_at(params0, X, Y, grads, 'W', l, r, c, h);
            if rel >= 0
                max_rel = max(max_rel, rel);
                n_checked = n_checked + 1;
            end
        end
    end
    for r2 = 1:size(params0.b{l}, 1)
        rel = relative_error_at(params0, X, Y, grads, 'b', l, r2, 1, h);
        if rel >= 0
            max_rel = max(max_rel, rel);
            n_checked = n_checked + 1;
        end
    end
end
tc.verifyGreaterThan(n_checked, 0, 'No parameters were actually checked.');
tc.verifyLessThan(max_rel, 1e-4, ...
    sprintf('Max relative gradient error %.3g over %d sampled params (h = %.0e).', ...
            max_rel, n_checked, h));
end

function rel = relative_error_at(params, X, Y, grads, kind, l, r, c, h)
% rel >= 0 means "checked"; rel == -2 means both grads are ~0 (skipped as
% agreeing, e.g. a ReLU-dead unit whose gradient is exactly zero both ways).
pl = bumped(params, kind, l, r, c, h);
pm = bumped(params, kind, l, r, c, -h);
num = (loss_value(pl, X, Y) - loss_value(pm, X, Y)) / (2 * h);
if kind == 'W', ana = grads.dW{l}(r, c); else, ana = grads.db{l}(r); end
den = max(abs(ana), abs(num));
if den < 1e-10
    % both effectively zero: finite differences carry no information there
    rel = -2;
    return;
end
rel = abs(num - ana) / den;
end

function p = bumped(params, kind, l, r, c, h)
p = params;
if kind == 'W'
    p.W{l}(r, c) = p.W{l}(r, c) + h;
else
    p.b{l}(r) = p.b{l}(r) + h;
end
end

function loss = loss_value(params, X, Y)
[probs, ~] = mlp_forward(params, X);
loss = -sum(sum(Y .* log(max(probs, 1e-12)))) / size(Y, 2);
end
