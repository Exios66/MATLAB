function tests = test_softmax()
%TEST_SOFTMAX Softmax correctness and numerical overflow safety.
%   tests = test_softmax() collects the unit tests in this file.
%
%   Example:
%       >> runtests('tests/test_softmax.m')

addpath(fileparts(fileparts(mfilename('fullpath'))));
tests = functiontests(localfunctions);
end

function test_rows_sum_to_one(tc)
rng(31);
params = mlp_init([2 5 3], 5);
probs = mlp_forward(params, randn(2, 50));
tc.verifyLessThan(max(abs(sum(probs, 1) - 1), [], 'all'), 1e-9, ...
    'Every softmax row must sum to 1.');
tc.verifyEqual(all(isfinite(probs(:))), true);
end

function test_matches_hand_computed_value(tc)
% Hand-built 1-2 net (no hidden layers): W = [1; -1], X = 2 gives logits
% (2, -2), so P(1) = exp(2) / (exp(2) + exp(-2)); X = 0 gives (0.5, 0.5).
p = struct();
p.sizes = [1 2];
p.W = {[1; -1]};
p.b = {[0; 0]};
probs0 = mlp_forward(p, 0);
probs2 = mlp_forward(p, 2);
tc.verifyEqual(probs0, [0.5; 0.5]);
tc.verifyEqual(probs2(1), exp(2) / (exp(2) + exp(-2)), 'AbsTol', 1e-12);
end

function test_extreme_inputs_do_not_overflow(tc)
% Logits of +-5e6: exp without the max-shift trick is already Inf at ~709,
% so a finite result proves the overflow protection works. Both directions
% (large positive and large negative winning class) are probed.
p = struct();
p.sizes = [1 3];
p.W = {[5e3; -5e3; 0]};
p.b = {[0; 0; 0]};
probs_pos = mlp_forward(p, 1e3);    % logits [5e6, -5e6, 0]
probs_neg = mlp_forward(p, -1e3);   % logits [-5e6, 5e6, 0]
tc.verifyEqual(all(isfinite(probs_pos(:))), true);
tc.verifyEqual(all(isfinite(probs_neg(:))), true);
tc.verifyLessThan(abs(sum(probs_pos) - 1), 1e-12);
tc.verifyLessThan(abs(sum(probs_neg) - 1), 1e-12);
tc.verifyGreaterThan(probs_pos(1), 1 - 1e-12);
tc.verifyGreaterThan(probs_neg(2), 1 - 1e-12);
end
