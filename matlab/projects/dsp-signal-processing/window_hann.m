function w = window_hann(N)
%WINDOW_HANN Symmetric Hann window computed from the closed-form formula.
%   w = window_hann(N) returns the N-point symmetric Hann window as a 1-by-N
%   row vector, built sample-by-sample from
%       w(n) = 0.5*(1 - cos(2*pi*(n-1)/(N-1))),  n = 1..N (MATLAB indexing).
%   For N == 1 the formula would divide by zero, so the window is defined as 1.
%
%   Example:
%       w = window_hann(64);
%       plot(w); title('Symmetric Hann window');
%
%   Base-MATLAB-only showcase: replaces toolbox hamming/hann window functions.

narginchk(1, 1);
if ~isnumeric(N) || ~isscalar(N) || ~isfinite(N) || N < 1 || N ~= fix(N)
    error('window_hann:badLength', 'N must be a positive integer.');
end

w = ones(1, N);                     % N == 1 guard: formula would divide by (N-1) = 0
if N > 1
    n = 0:N-1;
    w = 0.5 * (1 - cos(2*pi*n/(N-1)));
end
end
