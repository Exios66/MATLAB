function out = bin_open(mask)
%BIN_OPEN Binary opening (erode, then dilate) with a 3x3 structuring element.
%   OUT = bin_open(MASK) removes structures thinner than the 3x3 element
%   (specks, thin protrusions) while leaving larger objects their original
%   size. MASK is a logical or numeric 2-D array (nonzero = foreground), and
%   OUT is logical.
%
%   Example:
%       o = bin_open([true(4,4) false(4,4); false(8,4)]); % keeps the 4x4 block
%
%   See also: bin_close, bin_erode, bin_dilate.

narginchk(1, 1);
if ~((islogical(mask) || isnumeric(mask)) && ndims(mask) == 2)
    error('bin_open:badInput', 'MASK must be a 2-D logical or numeric array.');
end
out = bin_dilate(bin_erode(mask));
end
