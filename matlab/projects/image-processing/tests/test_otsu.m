function tests = test_otsu()
proj_root = fileparts(fileparts(mfilename('fullpath')));
addpath(proj_root);
tests = functiontests(localfunctions);
end

function test_bimodal_split(tc)
% Left half of the image is 0.2, right half 0.8: the threshold must land
% strictly between the two modes and split the pixels into the two classes.
img = [0.2 * ones(8, 32), 0.8 * ones(8, 32)];
t = otsu_threshold(img);
tc.verifyTrue(t > 0.2 && t < 0.8, 'Otsu threshold must lie strictly between the modes');
mask = binarize(img, t);
tc.verifyEqual(nnz(mask), 8*32);        % exactly the high half
tc.verifyEqual(mask(1, 1), false);      % low mode -> class 0
tc.verifyEqual(mask(1, end), true);     % high mode -> class 1
end

function test_threshold_in_input_scale(tc)
img = [zeros(4, 4); ones(4, 4) * 0.9];
t = otsu_threshold(img);
tc.verifyTrue(t >= min(img(:)) && t <= max(img(:)), 'Threshold must stay in the image value range');
end

function test_constant_image(tc)
t = otsu_threshold(0.5 * ones(4, 4));
tc.verifyEqual(t, 0.5);   % constant image: threshold = its own value
end
