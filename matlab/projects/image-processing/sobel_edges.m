function [mag, orient] = sobel_edges(img)
%SOBEL_EDGES Sobel gradient magnitude and orientation, from scratch.
%   [MAG, ORIENT] = sobel_edges(IMG) convolves the MxN double grayscale image
%   IMG (typically in [0,1]) with the classic 3x3 Sobel kernels
%   Gx = [-1 0 1; -2 0 2; -1 0 1] and Gy = Gx', then returns
%   MAG = sqrt(Gx.^2 + Gy.^2) normalized so that a full-contrast (height 1)
%   ideal step edge gives exactly MAG = 1 (the raw peak response of such a
%   step is 4, so MAG is divided by 4; MAG is in [0,1] for input in [0,1]).
%   ORIENT = atan2(Gy, Gx) is in radians, [-pi, pi]; 0 means brightness
%   increasing along +x (columns), pi/2 along +y (rows).
%
%   Example:
%       [mag, ang] = sobel_edges([zeros(8) ones(8)]);
%
%   See also: gaussian_blur, otsu_threshold.

narginchk(1, 1);
if ~isnumeric(img) || ndims(img) ~= 2
    error('sobel_edges:badInput', 'IMG must be a 2-D numeric array.');
end

gx_kernel = [-1 0 1; -2 0 2; -1 0 1];
gy_kernel = gx_kernel.';
img = double(img);
% conv2 flips its kernel (true convolution); rotating the kernels 180deg
% restores correlation semantics so gx > 0 means brightness increasing
% along +x (columns) and gy > 0 along +y (rows).
gx = conv2(img, rot90(gx_kernel, 2), 'same');
gy = conv2(img, rot90(gy_kernel, 2), 'same');
mag = sqrt(gx.^2 + gy.^2) / 4;
orient = atan2(gy, gx);
end
