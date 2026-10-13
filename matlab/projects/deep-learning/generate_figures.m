%GENERATE_FIGURES Regenerate all project figures into images/.
%   Run from anywhere; the script cd's to its own folder (the project root):
%       >> generate_figures
%   Writes: images/spiral_data.png, images/loss_curve.png, images/decision_region.png
%
%   Example:
%       >> generate_figures

this_dir = fileparts(mfilename('fullpath'));
cd(this_dir);
if exist('images', 'dir') ~= 7
    mkdir('images');
end
close all;

% --- 1) the dataset -------------------------------------------------------
[X, Y] = spiral_data(100, 3, 0.15, 0);
[~, cls] = max(Y, [], 1);   % one-hot -> class index per sample
class_colors = lines(3);

figure('Position', [100 100 520 420], 'Color', 'w');
hold on;
for j = 1:3
    scatter(X(1, cls == j), X(2, cls == j), 24, class_colors(j, :), 'filled');
end
axis equal;
xlim([-1.25 1.25]);
ylim([-1.25 1.25]);
grid on;
xlabel('x_1');
ylabel('x_2');
title('Spiral data: 3 classes, 300 points (noise 0.15)');
legend({'class 1', 'class 2', 'class 3'}, 'Location', 'northeastoutside');
exportgraphics(gcf, 'images/spiral_data.png', 'Resolution', 150);

% --- 2) training loss -----------------------------------------------------
params = mlp_init([2 32 3], 1);
[params, loss_hist] = mlp_train(params, X, Y, ...
    struct('lr', 0.5, 'epochs', 300, 'batch_size', 100, 'seed', 1));

figure('Position', [120 140 520 380], 'Color', 'w');
plot(1:numel(loss_hist), loss_hist, 'LineWidth', 1.4);
grid on;
xlabel('epoch');
ylabel('mean cross-entropy loss');
title('Training loss');
exportgraphics(gcf, 'images/loss_curve.png', 'Resolution', 150);

% --- 3) decision region over the plane ------------------------------------
% 60x60 grid keeps this fast while still resolving the spiral arms.
n_grid = 60;
gx = linspace(-1.25, 1.25, n_grid);
gy = linspace(-1.25, 1.25, n_grid);
[Xg, Yg] = meshgrid(gx, gy);
pred = mlp_predict(params, [Xg(:).'; Yg(:).']);
Zg = reshape(pred, size(Xg));

figure('Position', [140 180 520 420], 'Color', 'w');
% Explicit half-step levels: the extra top level ensures the region above the
% last class contour stays filled (pre-R2023a contourf does not "extend").
levels = [0.5 1.5 2.5 3.5];
contourf(Xg, Yg, Zg, levels, 'LineStyle', 'none');
colormap(lines(3));
hold on;
for j = 1:3
    scatter(X(1, cls == j), X(2, cls == j), 18, class_colors(j, :), 'filled');
end
axis equal;
xlim([-1.25 1.25]);
ylim([-1.25 1.25]);
xlabel('x_1');
ylabel('x_2');
title('MLP decision regions (60 x 60 grid)');
exportgraphics(gcf, 'images/decision_region.png', 'Resolution', 150);

close all;
