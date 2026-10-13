function x = gaussian_solve(A, b)
%GAUSSIAN_SOLVE Gaussian elimination with partial pivoting for A*X = B.
%   X = gaussian_solve(A, B) solves the real linear system A*X = B by
%   Gaussian elimination with partial (row) pivoting followed by back
%   substitution; no inverse is formed. For well-conditioned nonsingular
%   A this agrees with A\B to roundoff. X is N-by-1; B may be a row or
%   column vector.
%
%   Errors instead of returning a failed result:
%   'gaussian_solve:badShape' - A not square, or B has the wrong length,
%   'gaussian_solve:singular' - a pivot at or below EPS*NORM(A,INF) is
%                               encountered (numerically singular A).
%
%   Example:
%       x = gaussian_solve([2 1; 1 3], [5; 10])   % exactly [1; 3]
%
%   See also: mldivide.

narginchk(2, 2);
if ~isnumeric(A) || ~isreal(A) || ~all(isfinite(A(:)))
    error('gaussian_solve:badInput', 'A must be a finite real numeric matrix.');
end
if ~isnumeric(b) || ~isreal(b) || ~all(isfinite(b(:)))
    error('gaussian_solve:badInput', 'B must be a finite real numeric vector.');
end
if size(A, 1) ~= size(A, 2)
    error('gaussian_solve:badShape', 'A must be square.');
end
n = size(A, 1);
if ~isvector(b) || numel(b) ~= n
    error('gaussian_solve:badShape', 'B must have one entry per row of A.');
end

u = [A, b(:)];
tolPivot = eps * norm(A, inf);   % scale-aware singular threshold

for k = 1:n-1
    [~, p] = max(abs(u(k:n, k)));    % partial pivoting: largest column entry
    p = p + k - 1;
    u([k p], :) = u([p k], :);
    if abs(u(k, k)) <= tolPivot
        error('gaussian_solve:singular', ...
            'gaussian_solve: zero pivot in column %d (A is numerically singular).', k);
    end
    m = u(k+1:n, k) ./ u(k, k);
    u(k+1:n, k+1:n+1) = u(k+1:n, k+1:n+1) - m * u(k, k+1:n+1);
    u(k+1:n, k) = 0;
end
if abs(u(n, n)) <= tolPivot
    error('gaussian_solve:singular', ...
        'gaussian_solve: zero pivot in column %d (A is numerically singular).', n);
end

x = zeros(n, 1);
for k = n:-1:1
    x(k) = (u(k, n+1) - u(k, k+1:n) * x(k+1:n)) / u(k, k);
end
end
