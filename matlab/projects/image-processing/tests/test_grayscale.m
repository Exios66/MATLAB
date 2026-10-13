function tests = test_grayscale()
proj_root = fileparts(fileparts(mfilename('fullpath')));
addpath(proj_root);
tests = functiontests(localfunctions);
end

function test_constant_image(tc)
% Constant RGB maps to one constant luma; the classic 4-digit weights sum
% to 0.9999, so 0.5 everywhere becomes 0.5*0.9999 = 0.49995 (hand-computed).
img = 0.5 * ones(8, 11, 3);
tc.verifyEqual(to_grayscale(img), 0.49995 * ones(8, 11), 'AbsTol', 1e-12);
end

function test_luma_weights(tc)
% Pure-channel images give the exact known weights.
red = zeros(4, 4, 3); red(:,:,1) = 1;
green = zeros(4, 4, 3); green(:,:,2) = 1;
blue = zeros(4, 4, 3); blue(:,:,3) = 1;
tc.verifyEqual(to_grayscale(red), 0.2989*ones(4, 4), 'AbsTol', 1e-12);
tc.verifyEqual(to_grayscale(green), 0.5870*ones(4, 4), 'AbsTol', 1e-12);
tc.verifyEqual(to_grayscale(blue), 0.1140*ones(4, 4), 'AbsTol', 1e-12);
end

function test_two_d_passthrough(tc)
m = repmat((1:7)/7, 6, 1);
tc.verifyEqual(to_grayscale(m), m);
end

function test_rejects_wrong_shape(tc)
tc.verifyError(@() to_grayscale(zeros(3, 3, 4)), 'to_grayscale:badInput');
tc.verifyError(@() to_grayscale(true(3, 3, 3)), 'to_grayscale:badInput');
end
