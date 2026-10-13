function [xhat, Phist] = kalman_filter(z, Q, R, x0, P0, seed)
%KALMAN_FILTER 2-state constant-velocity Kalman filter (position + velocity).
%   [xhat, Phist] = kalman_filter(z, Q, R, x0, P0) filters the scalar
%   measurement sequence z (any orientation, length M) with the standard
%   constant-velocity model (dt = 1 sample, no control input):
%       state x = [position; velocity]
%       predict: x = F x,  P = F P F' + Q        with F = [1 1; 0 1]
%       update:  K = P H' (H P H' + R)^-1,  x = x + K (z - H x),
%                P = (I - K H) P                 with H = [1 0]
%   and returns xhat (2-by-M, posterior state per sample) and Phist
%   (2-by-2-by-M, posterior covariance per sample). x0 (2-by-1) and P0
%   (2-by-2, symmetric) seed the recursion; Q must be 2-by-2 symmetric and
%   R a positive scalar (single measurement channel). Standard textbook
%   equations; the Joseph form is more numerically robust but unnecessary
%   at this scale.
%
%   kalman_filter(z, Q, R, x0, P0, seed) calls rng(seed) first; the filter is
%   itself fully deterministic, the seed only follows the portfolio's
%   reproducibility convention (default 0).
%
%   Example:
%       rng(0); z = sin(2*pi*0.02*(0:299)) + 0.4*randn(1, 300);
%       [xhat, ~] = kalman_filter(z, diag([1e-4, 1e-3]), 0.16, [z(1); 0], 100*eye(2));

narginchk(5, 6);
if nargin < 6
    seed = 0;
end
if ~isnumeric(z) || ~isvector(z) || ~isfinite(z) || ~isreal(z) || isempty(z)
    error('kalman_filter:badZ', 'Z must be a nonempty finite real numeric vector.');
end
if ~isnumeric(Q) || ~isequal(size(Q), [2, 2]) || ~isfinite(Q) || ~isreal(Q) || ~issymmetric(Q)
    error('kalman_filter:badQ', 'Q must be a 2-by-2 finite real symmetric matrix.');
end
if ~isnumeric(R) || ~isscalar(R) || ~isfinite(R) || ~isreal(R) || R <= 0
    error('kalman_filter:badR', 'R must be a finite real scalar > 0.');
end
if ~isnumeric(x0) || ~isvector(x0) || numel(x0) ~= 2 || ~isfinite(x0) || ~isreal(x0)
    error('kalman_filter:badX0', 'X0 must be a finite real numeric vector of length 2.');
end
if ~isnumeric(P0) || ~isequal(size(P0), [2, 2]) || ~isfinite(P0) || ~isreal(P0) || ~issymmetric(P0)
    error('kalman_filter:badP0', 'P0 must be a 2-by-2 finite real symmetric matrix.');
end
rng(seed);

F = [1 1; 0 1];                     % constant-velocity transition, dt = 1
H = [1 0];                          % position is measured, velocity hidden
I = eye(2);
z = z(:).';                         % force 1-by-M measurement row
M = numel(z);

x = x0(:);                          % work with column state vectors
P = P0;
xhat = zeros(2, M);
Phist = zeros(2, 2, M);
for k = 1:M
    x = F*x;                        % predict
    P = F*P*F.' + Q;
    S = H*P*H.' + R;                % innovation covariance (scalar here)
    K = P*H.'/S;                    % Kalman gain (2-by-1)
    x = x + K*(z(k) - H*x);         % update with measurement z(k)
    P = (I - K*H)*P;
    xhat(:, k) = x;
    Phist(:, :, k) = P;
end
end
