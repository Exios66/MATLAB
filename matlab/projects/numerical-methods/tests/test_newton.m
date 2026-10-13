function tests = test_newton()
%TEST_NEWTON Function-based tests for newton_raphson.
%   The solver lives in the project root one level up; run_checks does not
%   set the path, so make that folder reachable at discovery time.

projRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projRoot);
tests = functiontests(localfunctions);
end

function test_finds_known_root(tc)
% x^3 - 2x - 5 has the famous real root 2.0945514815423265.
[r, it, ok] = newton_raphson(@(x) x.^3 - 2*x - 5, @(x) 3*x.^2 - 2, 2, 1e-12, 50);
tc.verifyTrue(ok, 'converged flag should be true');
tc.verifyTrue(abs(r - 2.0945514815423265) < 1e-9, sprintf('root = %.15g', r));
tc.verifyTrue(it > 0 && it <= 50, sprintf('iter = %d', it));
end

function test_default_arguments_work(tc)
% Same problem with default TOL/MAXITER still converges.
r = newton_raphson(@(x) x.^3 - 2*x - 5, @(x) 3*x.^2 - 2, 2);
tc.verifyTrue(abs(r - 2.0945514815423265) < 1e-6, sprintf('root = %.15g', r));
end

function test_errors_on_zero_derivative(tc)
% From x0 = 1 the first Newton step of x^2 + 1 lands exactly on 0,
% where DFUN = 0: the solver must raise, never divide silently.
tc.verifyError(@() newton_raphson(@(x) x.^2 + 1, @(x) 2*x, 1, 1e-12, 10), ...
    'newton_raphson:zeroDerivative');
end

function test_errors_on_maxiter_no_root(tc)
% exp(x) + 1 >= 1 everywhere, so no real root exists: MAXITER must raise.
tc.verifyError(@() newton_raphson(@(x) exp(x) + 1, @(x) exp(x), 5, 1e-12, 40), ...
    'newton_raphson:maxiter');
end
