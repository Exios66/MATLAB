function out = to_grayscale(rgb)
%TO_GRAYSCALE Convert an RGB stack to grayscale luma, or pass 2-D images through.
%   GRAY = to_grayscale(RGB) converts an MxNx3 array to an MxN double
%   grayscale image using ITU-R BT.601 luma weights (0.2989, 0.5870, 0.1140).
%   GRAY = to_grayscale(IMG) returns an MxN numeric array unchanged (as
%   double).
%
%   Input may be double in [0,1] or uint8 in [0,255]; the output is double in
%   the same numeric scale as the input (no re-scaling is applied). Note the
%   classic 4-digit weights sum to 0.9999, not exactly 1.
%
%   Example:
%       gray = to_grayscale(rand(16,16,3));
%
%   See also: gaussian_blur, run_pipeline.

narginchk(1, 1);
if ~isnumeric(rgb)
    error('to_grayscale:badInput', 'Input must be numeric (double or uint8).');
end
if ndims(rgb) == 3 && size(rgb, 3) == 3
    out = 0.2989*double(rgb(:,:,1)) + 0.5870*double(rgb(:,:,2)) + 0.1140*double(rgb(:,:,3));
elseif ndims(rgb) == 2
    out = double(rgb);
else
    error('to_grayscale:badInput', 'Expected an MxN or MxNx3 array, got a %dx%dx%d array.', ...
        size(rgb,1), size(rgb,2), size(rgb,3));
end
end
