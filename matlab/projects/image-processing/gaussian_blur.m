function out = gaussian_blur(img, sigma)
%GAUSSIAN_BLUR Blur a grayscale image with a hand-built Gaussian kernel.
%   OUT = gaussian_blur(IMG, SIGMA) convolves the MxN double image IMG with an
%   odd-sized (2*ceil(2*SIGMA)+1)^2 Gaussian kernel and returns an MxN image.
%   Kernel weights are exp(-(dx^2+dy^2)/(2*SIGMA^2)), normalized to sum to 1;
%   the convolution uses conv2 with 'same', i.e. edges are zero-padded (darken
%   slightly). IMG is a double grayscale array in any numeric scale (typically
%   [0,1]); SIGMA > 0, default 1.
%
%   Example:
%       blurred = gaussian_blur(zeros(32,32), 1.5);
%
%   See also: sobel_edges, run_pipeline.

narginchk(1, 2);
if nargin < 2
    sigma = 1;
end
if ~isnumeric(img) || ndims(img) ~= 2
    error('gaussian_blur:badInput', 'IMG must be a 2-D numeric array.');
end
if ~isscalar(sigma) || ~isnumeric(sigma) || ~isfinite(sigma) || sigma <= 0
    error('gaussian_blur:badSigma', 'SIGMA must be a finite scalar > 0.');
end

r = ceil(2*sigma);
[dx, dy] = meshgrid(-r:r, -r:r);
k = exp(-(dx.^2 + dy.^2) / (2*sigma^2));
k = k / sum(k(:));
out = conv2(double(img), k, 'same');
end
