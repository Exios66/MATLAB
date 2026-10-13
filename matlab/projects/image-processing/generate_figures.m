%GENERATE_FIGURES Render this project's demonstration PNGs into images/.
%   Run from the project folder (or anywhere):   generate_figures
%   Writes images/pipeline_stages.png, a 2x3 panel of the run_pipeline stages,
%   and images/final_labels.png, the grayscale scene with each labeled object
%   colorized and its outline overlaid. Both are exported at Resolution 150.
%   Images only exist after this script has run; nothing else in the project
%   depends on them.

this_dir = fileparts(mfilename('fullpath'));
img_dir = fullfile(this_dir, 'images');
if ~exist(img_dir, 'dir')
    mkdir(img_dir);
end

res = run_pipeline();

% Figure 1: the six pipeline stages.
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1250 780]);
stages = {res.scene, '1. synthetic scene'; ...
          res.gray, '2. to\_grayscale'; ...
          res.blurred, '3. gaussian\_blur'; ...
          res.edge_mag, '4. sobel\_edges magnitude'; ...
          res.edges_binary, '5. otsu + binarize'; ...
          res.opened, '6. bin\_open'};
for k = 1:6
    subplot(2, 3, k);
    imagesc(stages{k, 1});
    axis image off;
    title(stages{k, 2}, 'FontSize', 10);
    if k > 1
        colormap(gca, gray);
    end
end
exportgraphics(fig, fullfile(img_dir, 'pipeline_stages.png'), 'Resolution', 150);

% Figure 2: final labels, colorized per component, with white outlines.
overlay = repmat(res.gray, 1, 1, 3);
colors = lines(max(res.count, 1));
outline = false(size(res.gray));
for k = 1:res.count
    member = res.labels == k;
    overlay(member, :) = colors(k, :);   % fill each object with its class color
    outline = outline | (member & ~bin_erode(member));
end
overlay(repmat(outline, 1, 1, 3)) = 1;

fig2 = figure('Visible', 'off', 'Color', 'w', 'Position', [140 140 620 620]);
imagesc(overlay);
axis image off;
title(sprintf('label\\_components: %d objects', res.count), 'FontSize', 11);
exportgraphics(fig2, fullfile(img_dir, 'final_labels.png'), 'Resolution', 150);

close([fig fig2]);
