function tests = test_linear()
%TEST_LINEAR Function-based tests for gaussian_solve.
%   The solver lives in the project root one level up; run_checks does not
%   set the path, so make that folder reachable at discovery time.

projRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projRoot);
tests = functiontests(localfunctions);
end

function test_exact_small_system(tc)
% 2x + y = 5, x + 3y = 10 has solution [1; 3]; all dyadic, exact in FP.
tc.verifyEqual(gaussian_solve([2 1; 1 3], [5; 10]), [1; 3]);
end

function test_row_b_is_accepted(tc)
% B may be a row vector; internal augmentation normalizes it.
tc.verifyEqual(gaussian_solve([2 1; 1 3], [5 10]), [1; 3]);
end

function test_random_system_matches_backslash(tc)
% Seeded, well-conditioned random system must agree with A\b.
rng(1234);
n = 20;
A = randn(n) + n * eye(n);   % diagonally dominant: error stays at roundoff
xTrue = randn(n, 1);
x = gaussian_solve(A, A * xTrue);
tc.verifyTrue(norm(x - xTrue) / norm(xTrue) < 1e-8, ...
    sprintf('relative error %.3g', norm(x - xTrue) / norm(xTrue)));
end

function test_singular_matrix_raises(tc)
% Row 2 of A is twice row 1: elimination yields an exact zero pivot.
tc.verifyError(@() gaussian_solve([1 2; 2 4], [3; 6]), ...
    'gaussian_solve:singular');
end

function test_bad_shapes_raise(tc)
% Nonsquare A and size-mismatched B must both raise badShape.
tc.verifyError(@() gaussian_solve(ones(2, 3), ones(2, 1)), ...
    'gaussian_solve:badShape');
tc.verifyError(@() gaussian_solve(ones(2, 2), ones(3, 1)), ...
    'gaussian_solve:badShape');
end
