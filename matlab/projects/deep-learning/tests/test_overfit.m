function tests = test_overfit()
%TEST_OVERFIT Spiral memorization: the training pipeline learns, not just runs.
%   tests = test_overfit() collects the unit tests in this file.
%
%   Example:
%       >> runtests('tests/test_overfit.m')

addpath(fileparts(fileparts(mfilename('fullpath'))));
tests = functiontests(localfunctions);
end

function test_memorizes_clean_spiral(tc)
% 75 clean points, tiny 2-32-3 net, few hundred full-batch steps must reach
% > 95% training accuracy.
[X, Y] = spiral_data(25, 3, 0, 0);
params = mlp_init([2 32 3], 1);
[params, loss_hist] = mlp_train(params, X, Y, ...
    struct('lr', 1.0, 'epochs', 400, 'batch_size', 75, 'seed', 1));

[~, true_cls] = max(Y, [], 1);
acc = mean(mlp_predict(params, X) == true_cls);

tc.verifyGreaterThan(acc, 0.95, ...
    sprintf('Training accuracy %.3f on 75 clean spiral points should exceed 0.95.', acc));
tc.verifyLessThan(loss_hist(end), loss_hist(1), 'Loss must decrease over training.');
end
