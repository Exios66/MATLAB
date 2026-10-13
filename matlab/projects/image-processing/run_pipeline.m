function result = run_pipeline()
%RUN_PIPELINE Run the full demonstration image-processing pipeline, from scratch.
%   R = run_pipeline() builds a synthetic 256x256 double RGB scene in [0,1]
%   (black canvas with a white rectangle, a green disc and a yellow disc, all
%   drawn in code), then: to_grayscale -> gaussian_blur (sigma 1.2) ->
%   sobel_edges -> otsu_threshold + binarize -> bin_open -> label_components.
%   R is a struct with fields
%     scene        256x256x3 double RGB scene
%     gray         256x256 double grayscale, [0,1]
%     blurred      blurred grayscale
%     edge_mag     Sobel magnitude, [0,1]
%     edge_orient  Sobel orientation, radians
%     threshold    Otsu threshold on edge_mag
%     edges_binary logical edge mask
%     opened       logical mask after opening
%     labels       component labels, 0 = background
%     count        number of labeled components (3 closed outlines)
%
%   Example:
%       r = run_pipeline(); fprintf('%d objects\n', r.count);
%
%   See also: label_components, generate_figures.

result.scene = local_scene();
result.gray = to_grayscale(result.scene);
result.blurred = gaussian_blur(result.gray, 1.2);
[result.edge_mag, result.edge_orient] = sobel_edges(result.blurred);
result.threshold = otsu_threshold(result.edge_mag);
result.edges_binary = binarize(result.edge_mag, result.threshold);
result.opened = bin_open(result.edges_binary);
[result.labels, result.count] = label_components(result.opened);
end

function img = local_scene()
% Shapes are drawn with margin to the frame and to each other so blur and
% opening cannot merge or clip their closed outlines.
img = zeros(256, 256, 3);
img(40:100, 30:80, :) = 1;                          % white rectangle (luma 1.0)
[xx, yy] = meshgrid(1:256, 1:256); % xx = columns, yy = rows
d = sqrt((xx - 190).^2 + (yy - 170).^2);
img(d <= 35, 2) = 1;                                % green disc (luma 0.587)
d = sqrt((xx - 190).^2 + (yy - 60).^2);
img(d <= 25, 1) = 1;
img(d <= 25, 2) = 1;                                % yellow disc (luma 0.886)
end
