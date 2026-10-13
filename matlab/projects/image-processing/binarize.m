function out = binarize(img, threshold)
%BINARIZE Threshold an image into a logical foreground mask.
%   MASK = binarize(IMG, T) returns an MxN logical mask that is true where
%   IMG > T. IMG is a numeric array; T is a finite scalar in IMG's value
%   scale (e.g. the output of otsu_threshold).
%
%   Example:
%       mask = binarize([0.1 0.9], 0.5);   % mask = [false true]
%
%   See also: otsu_threshold, bin_open.

narginchk(2, 2);
if ~isnumeric(img)
    error('binarize:badInput', 'IMG must be a numeric array.');
end
if ~isscalar(threshold) || ~isnumeric(threshold) || ~isfinite(threshold)
    error('binarize:badThreshold', 'THRESHOLD must be a finite numeric scalar.');
end
out = img > threshold;
end
