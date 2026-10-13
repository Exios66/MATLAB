function out = bin_erode(mask)
%BIN_ERODE Erode a binary image with a full 3x3 structuring element.
%   OUT = bin_erode(MASK) keeps pixels whose entire 3x3 neighborhood (center
%   included) is true: true-neighbor counts are computed with conv2 over
%   ones(3) and must equal 9. Edges are treated as background (conv2 'same'
%   zero-pads), so objects touching the frame erode away from it.
%   MASK is a logical or numeric 2-D array (nonzero = foreground); OUT is
%   logical.
%
%   Example:
%       e = bin_erode(true(5));   % keeps only the 3x3 interior
%
%   See also: bin_dilate, bin_open, label_components.

narginchk(1, 1);
if ~((islogical(mask) || isnumeric(mask)) && ndims(mask) == 2)
    error('bin_erode:badInput', 'MASK must be a 2-D logical or numeric array.');
end
n_true = conv2(double(logical(mask)), ones(3), 'same');
out = n_true == 9;
end
