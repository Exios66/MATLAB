function tests = test_label_components()
proj_root = fileparts(fileparts(mfilename('fullpath')));
addpath(proj_root);
tests = functiontests(localfunctions);
end

function test_three_shapes(tc)
% Three well-separated 4-connected shapes; ids come from raster scan order
% of each component's first pixel: block at (2,2) -> 1, pixel at (2,10) -> 2,
% block at (6,6) -> 3.
m = false(10, 12);
m(2:3, 2:3) = true;
m(2, 10) = true;
m(6:7, 6:9) = true;
[labels, count] = label_components(m);
tc.verifyEqual(count, 3);
tc.verifyEqual(unique(labels(:)).', [0 1 2 3]);
tc.verifyEqual(labels(2, 2), 1);
tc.verifyEqual(labels(2, 10), 2);
tc.verifyEqual(labels(6, 6), 3);
end

function test_diagonal_touch_is_separate(tc)
% Two pixels touching diagonally only: 4-connectivity keeps them distinct.
m = false(4, 4); m(1, 1) = true; m(2, 2) = true;
[labels, count] = label_components(m);
tc.verifyEqual(count, 2);
tc.verifyEqual(labels(1, 1), 1);
tc.verifyEqual(labels(2, 2), 2);
end

function test_empty_image(tc)
[labels, count] = label_components(false(5, 5));
tc.verifyEqual(count, 0);
tc.verifyEqual(labels, zeros(5, 5));
end
