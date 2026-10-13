function tests = test_sobel()
proj_root = fileparts(fileparts(mfilename('fullpath')));
addpath(proj_root);
tests = functiontests(localfunctions);
end

function test_vertical_step_edge(tc)
% img is 0 for columns 1..32 and 1 for columns 33..64.
% Hand-computed: gx = 4 at columns 32 and 33 (all rows), 0 elsewhere;
% mag = 4/4 = 1 exactly there, gy = 0, so orient = 0 at the step.
img = zeros(64, 64); img(:, 33:end) = 1;
[mag, orient] = sobel_edges(img);
tc.verifyEqual(max(mag(:)), 1.0, 'AbsTol', 1e-12);   % full-contrast step -> 1
active = mag > 0.5;
expected = false(64, 64); expected(:, [32 33]) = true;
tc.verifyEqual(active, expected);                     % high mag only at edge columns
tc.verifyEqual(orient(10, 32), 0.0, 'AbsTol', 1e-12); % +x gradient direction
tc.verifyEqual(mag(10, 31), 0.0, 'AbsTol', 1e-12);    % one past the edge: flat
end

function test_horizontal_step_edge(tc)
img = zeros(64, 64); img(33:end, :) = 1;
[mag, orient] = sobel_edges(img);
tc.verifyEqual(max(mag(:)), 1.0, 'AbsTol', 1e-12);
tc.verifyEqual(orient(32, 10), pi/2, 'AbsTol', 1e-12);  % +y gradient direction
end

function test_flat_image_is_zero(tc)
img = ones(20, 30) * 0.3;
[mag, orient] = sobel_edges(img);
tc.verifyEqual(max(mag(:)), 0.0, 'AbsTol', 1e-12);
tc.verifyEqual(orient(5, 5), 0.0, 'AbsTol', 1e-12);
end
