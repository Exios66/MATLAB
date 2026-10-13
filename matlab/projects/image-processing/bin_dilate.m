function out = bin_dilate(mask)
%BIN_DILATE Dilate a binary image with a full 3x3 structuring element.
%   OUT = bin_dilate(MASK) turns a pixel true when any pixel of its 3x3
%   neighborhood (center included) is true: true-neighbor counts are computed
%   with conv2 over ones(3) and must be > 0. Edges are treated as background
%   (conv2 'same' zero-pads), so objects never grow beyond the frame.
%   MASK is a logical or numeric 2-D array (nonzero = foreground); OUT is
%   logical.
%
%   Example:
%       d = bin_dilate(false(5)); % still empty
%
%   See also: bin_erode, bin_close, label_components.

narginchk(1, 1);
if ~((islogical(mask) || isnumeric(mask)) && ndims(mask) == 2)
    error('bin_dilate:badInput', 'MASK must be a 2-D logical or numeric array.');
end
n_true = conv2(double(logical(mask)), ones(3), 'same');
out = n_true > 0;
end
