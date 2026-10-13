function [root, iter, converged] = newton_raphson(fun, dfun, x0, tol, maxiter)
%NEWTON_RAPHSON Scalar root finding by the Newton-Raphson method.
%   [R, IT, OK] = newton_raphson(FUN, DFUN, X0) iterates
%   x_{k+1} = x_k - FUN(x_k)/DFUN(x_k) from the scalar starting point X0
%   until ABS(FUN(x)) <= TOL (default 1e-8) or MAXITER Newton steps
%   (default 100) have been taken. IT is the number of steps taken and OK
%   is true iff the residual criterion was met.
%
%   newton_raphson(FUN, DFUN, X0, TOL, MAXITER) overrides both defaults.
%
%   Errors instead of returning a failed guess:
%   'newton_raphson:zeroDerivative' - DFUN vanishes at some iterate,
%   'newton_raphson:maxiter'        - MAXITER reached without convergence.
%
%   Example:
%       [r, it, ok] = newton_raphson(@(x) x^3 - 2*x - 5, @(x) 3*x^2 - 2, 2);
%
%   See also: fzero.

narginchk(3, 5);
if ~isa(fun, 'function_handle') || ~isa(dfun, 'function_handle')
    error('newton_raphson:badInput', 'FUN and DFUN must be function handles.');
end
if ~isscalar(x0) || ~isnumeric(x0) || ~isfinite(x0)
    error('newton_raphson:badInput', 'X0 must be a finite numeric scalar.');
end
if nargin < 4 || isempty(tol)
    tol = 1e-8;
end
if nargin < 5 || isempty(maxiter)
    maxiter = 100;
end
if ~isscalar(tol) || ~isnumeric(tol) || ~isfinite(tol) || tol <= 0
    error('newton_raphson:badInput', 'TOL must be a finite positive scalar.');
end
if ~isscalar(maxiter) || ~isnumeric(maxiter) || maxiter < 1 || mod(maxiter, 1) ~= 0
    error('newton_raphson:badInput', 'MAXITER must be a positive integer.');
end

root = x0;
iter = 0;
fx = fun(root);
while abs(fx) > tol && iter < maxiter
    dfx = dfun(root);
    if dfx == 0
        error('newton_raphson:zeroDerivative', ...
            'Newton step divides by DFUN = 0 at x = %.6g.', root);
    end
    root = root - fx/dfx;
    iter = iter + 1;
    fx = fun(root);
end
converged = abs(fx) <= tol;
if ~converged
    error('newton_raphson:maxiter', ...
        'No root within %d iterations: |FUN(x)| = %.3g at x = %.6g.', ...
        maxiter, abs(fx), root);
end
end
