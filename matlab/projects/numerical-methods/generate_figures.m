function generate_figures()
%GENERATE_FIGURES Create the three showcase PNGs in images/.
%   generate_figures writes ode_order.png, newton_trace.png and
%   mc_convergence.png into an images/ folder next to this file, creating
%   the folder if missing, at 150 dpi via exportgraphics. It runs from any
%   working directory and with no display: figures are created invisible.
%   Deterministic: every Monte Carlo call uses a fixed seed.
%
%   Example:
%       generate_figures
%
%   See also: integrate_euler, integrate_rk4, newton_raphson, mc_pi.

here = fileparts(mfilename('fullpath'));
imgDir = fullfile(here, 'images');
if ~isfolder(imgDir)
    mkdir(imgDir);
end

% ---- Figure 1: solver error vs step size (log-log, slopes 1 and 4) ----
f = @(t, y) -y;
exact = @(t) exp(-t);
hs = 1 ./ 2.^(1:8);                  % every step divides [0, 1] evenly
errE = zeros(size(hs));
errR = zeros(size(hs));
for i = 1:numel(hs)
    [tk, yk] = integrate_euler(f, [0 1], 1, hs(i));
    errE(i) = max(abs(yk(:,1) - exact(tk)));
    [tk, yk] = integrate_rk4(f, [0 1], 1, hs(i));
    errR(i) = max(abs(yk(:,1) - exact(tk)));
end
figure('Visible', 'off', 'Color', 'w');
loglog(hs, errE, 'o-', hs, errR, 's-', ...
       hs, errE(1) .* (hs/hs(1)).^1, 'k--', hs, errR(1) .* (hs/hs(1)).^4, 'k:');
grid on;
xlabel('step size h');
ylabel('max |error|');
title('Euler (slope 1) vs RK4 (slope 4): y'' = -y on [0, 1]');
legend({'Euler', 'RK4', 'slope 1', 'slope 4'}, 'Location', 'southeast');
exportgraphics(gcf, fullfile(imgDir, 'ode_order.png'), 'Resolution', 150);
close(gcf);

% ---- Figure 2: Newton-Raphson convergence trace ----
fun = @(x) x.^3 - 2*x - 5;
dfun = @(x) 3*x.^2 - 2;
xk = 2;
maxIter = 10;
res = zeros(1, maxIter + 1);         % |f(x_k)| at iteration k
res(1) = abs(fun(xk));
for k = 1:maxIter
    xk = xk - fun(xk)/dfun(xk);
    res(k+1) = abs(fun(xk));
    if res(k+1) < 1e-14
        break;                        % quadratic convergence hits eps fast
    end
end
figure('Visible', 'off', 'Color', 'w');
semilogy(0:k, res(1:k+1), 'o-');
grid on;
xlabel('Newton iteration k');
ylabel('|f(x_k)|');
title('Newton-Raphson: quadratic convergence on x^3 - 2x - 5 (x_0 = 2)');
exportgraphics(gcf, fullfile(imgDir, 'newton_trace.png'), 'Resolution', 150);
close(gcf);

% ---- Figure 3: Monte Carlo convergence with error bars ----
g = @(x) x.^2;
ns = unique(round(logspace(1, 5, 21)));   % 10 .. 100000 samples
est = zeros(size(ns));
se = zeros(size(ns));
for i = 1:numel(ns)
    [est(i), se(i)] = monte_carlo_integrate(g, 0, 1, ns(i), 42);
end
figure('Visible', 'off', 'Color', 'w');
errorbar(ns, est, se, 'o-', 'MarkerSize', 4);
hold on;
yline(1/3, 'k--', 'exact 1/3');
hold off;
set(gca, 'XScale', 'log');
grid on;
xlabel('samples n');
ylabel('estimate +/- stderr');
title('Monte Carlo integration of x^2 on [0, 1], seed 42');
exportgraphics(gcf, fullfile(imgDir, 'mc_convergence.png'), 'Resolution', 150);
close(gcf);

fprintf('generate_figures: wrote 3 PNGs to %s\n', imgDir);
end
