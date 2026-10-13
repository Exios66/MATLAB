function [t, y] = integrate_rk4(f, tspan, y0, h)
%INTEGRATE_RK4 Fixed-step classic 4th-order Runge-Kutta ODE solver.
%   [T, Y] = integrate_rk4(F, TSPAN, Y0, H) integrates dY/dt = F(T, Y) with
%   the classical RK4 scheme (four derivative evaluations per step) over
%   TSPAN = [T0 TF] with constant step H. T is the vector of time points
%   and Y is NUMEL(T)-by-NUMEL(Y0), one state row per time point (same
%   orientation as ODE45 output). Global error is O(H^4). If TF - T0 is
%   not an integer multiple of H, the last step is shortened so the
%   integration lands exactly on TF.
%
%   F must accept F(T, Y) and return the derivative; row or column
%   orientation of the state and derivative are both accepted.
%
%   Example:
%       [t, y] = integrate_rk4(@(t, y) -y, [0 1], 1, 0.1);
%       abs(y(end) - exp(-1))   % ~1e-8, fourth-order accuracy
%
%   See also: integrate_euler, ode45.

narginchk(4, 4);
if ~isa(f, 'function_handle')
    error('integrate_rk4:badInput', 'F must be a function handle.');
end
if ~isnumeric(tspan) || numel(tspan) ~= 2 || ~all(isfinite(tspan))
    error('integrate_rk4:badInput', 'TSPAN must be a finite 2-element vector [T0 TF].');
end
if ~isnumeric(y0) || ~all(isfinite(y0))
    error('integrate_rk4:badInput', 'Y0 must be a finite numeric vector.');
end
if ~isscalar(h) || ~isnumeric(h) || ~isfinite(h) || h <= 0
    error('integrate_rk4:badInput', 'H must be a finite positive scalar.');
end

t0 = tspan(1);
tf = tspan(end);
if tf < t0
    error('integrate_rk4:badTspan', 'TSPAN must satisfy T0 <= TF.');
end

t = t0:h:tf;
t = t(t <= tf);                 % floating-point guard: never step past TF
if t(end) < tf
    t(end+1) = tf;              % shortened final step lands on TF
end

y = zeros(numel(t), numel(y0));
y(1,:) = reshape(y0, 1, []);

for k = 1:numel(t)-1
    tk = t(k);
    dt = t(k+1) - t(k);
    yk = y(k,:).';
    k1 = reshape(f(tk, yk), [], 1);
    k2 = reshape(f(tk + dt/2, yk + (dt/2)*k1), [], 1);
    k3 = reshape(f(tk + dt/2, yk + (dt/2)*k2), [], 1);
    k4 = reshape(f(tk + dt, yk + dt*k3), [], 1);
    y(k+1,:) = (yk + (dt/6) * (k1 + 2*k2 + 2*k3 + k4)).';
end
end
