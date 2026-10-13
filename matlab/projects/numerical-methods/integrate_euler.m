function [t, y] = integrate_euler(f, tspan, y0, h)
%INTEGRATE_EULER Fixed-step explicit (forward) Euler ODE solver.
%   [T, Y] = integrate_euler(F, TSPAN, Y0, H) numerically integrates the
%   initial-value problem dY/dt = F(T, Y), Y(T0) = Y0 over TSPAN = [T0 TF]
%   with constant step H. T is the vector of time points and Y is
%   NUMEL(T)-by-NUMEL(Y0), one state row per time point (same orientation
%   as ODE45 output). If TF - T0 is not an integer multiple of H, the last
%   step is shortened so the integration lands exactly on TF.
%
%   F must accept F(T, Y) and return the derivative; row or column
%   orientation of the state and derivative are both accepted.
%
%   Example:
%       [t, y] = integrate_euler(@(t, y) -y, [0 1], 1, 0.01);
%       abs(y(end) - exp(-1))   % ~3e-3, first-order accuracy
%
%   See also: integrate_rk4, ode45.

narginchk(4, 4);
if ~isa(f, 'function_handle')
    error('integrate_euler:badInput', 'F must be a function handle.');
end
if ~isnumeric(tspan) || numel(tspan) ~= 2 || ~all(isfinite(tspan))
    error('integrate_euler:badInput', 'TSPAN must be a finite 2-element vector [T0 TF].');
end
if ~isnumeric(y0) || ~all(isfinite(y0))
    error('integrate_euler:badInput', 'Y0 must be a finite numeric vector.');
end
if ~isscalar(h) || ~isnumeric(h) || ~isfinite(h) || h <= 0
    error('integrate_euler:badInput', 'H must be a finite positive scalar.');
end

t0 = tspan(1);
tf = tspan(end);
if tf < t0
    error('integrate_euler:badTspan', 'TSPAN must satisfy T0 <= TF.');
end

t = t0:h:tf;
t = t(t <= tf);                 % floating-point guard: never step past TF
if t(end) < tf
    t(end+1) = tf;              % shortened final step lands on TF
end

y = zeros(numel(t), numel(y0));
y(1,:) = reshape(y0, 1, []);

for k = 1:numel(t)-1
    dt = t(k+1) - t(k);
    dy = reshape(f(t(k), y(k,:).'), [], 1);   % normalize F's orientation
    y(k+1,:) = y(k,:) + dt * dy.';
end
end
