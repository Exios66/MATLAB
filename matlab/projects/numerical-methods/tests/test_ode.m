function tests = test_ode()
%TEST_ODE Function-based tests for integrate_euler and integrate_rk4.
%   Discovered by runtests under matlab/projects. The solvers live in the
%   project root one level up, and run_checks does not set the path, so
%   make that folder reachable at discovery time.

projRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(projRoot);
tests = functiontests(localfunctions);
end

function test_euler_is_first_order(tc)
% Euler error should halve when H halves: measured order near 1.
hs = [0.4 0.2 0.1 0.05];
err = zeros(size(hs));
for i = 1:numel(hs)
    [t, y] = integrate_euler(@(t, y) -y, [0 1], 1, hs(i));
    err(i) = abs(y(end, 1) - exp(-1));
end
order = log(err(1)/err(end)) / log(hs(1)/hs(end));   % 3 halvings: h ratio 8
tc.verifyTrue(order > 0.8 && order < 1.2, ...
    sprintf('measured Euler order %.3f, expected ~1', order));
end

function test_rk4_is_fourth_order(tc)
% RK4 error should scale like H^4: measured order near 4.
hs = [0.4 0.2 0.1 0.05];
err = zeros(size(hs));
for i = 1:numel(hs)
    [t, y] = integrate_rk4(@(t, y) -y, [0 1], 1, hs(i));
    err(i) = abs(y(end, 1) - exp(-1));
end
order = log(err(1)/err(end)) / log(hs(1)/hs(end));
tc.verifyTrue(order > 3.5 && order < 4.5, ...
    sprintf('measured RK4 order %.3f, expected ~4', order));
end

function test_matches_ode45_on_decay(tc)
% Sanity: both fixed-step solvers agree with ODE45 on y' = -y, y(0) = 1.
h = 1/256;
opts = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[~, y45] = ode45(@(t, y) -y, [0 1], 1, opts);
ref = y45(end);
[~, yE] = integrate_euler(@(t, y) -y, [0 1], 1, h);
[~, yR] = integrate_rk4(@(t, y) -y, [0 1], 1, h);
tc.verifyTrue(abs(yE(end) - ref) < 5e-3, 'Euler within O(h) of ODE45');
tc.verifyTrue(abs(yR(end) - ref) < 1e-8, 'RK4 much tighter than ODE45 default');
end

function test_rk4_vector_state_matches_analytic(tc)
% Vector state (harmonic oscillator) plus F returning a column, ode45 style.
fh = @(t, y) [y(2); -y(1)];
[tk, yk] = integrate_rk4(fh, [0 1], [1; 0], 1/256);
tc.verifyTrue(max(abs(yk(:,1) - cos(tk))) < 1e-7, 'first state matches cos');
tc.verifyTrue(max(abs(yk(:,2) + sin(tk))) < 1e-7, 'second state matches -sin');
end
