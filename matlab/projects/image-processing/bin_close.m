function out = bin_close(mask)
%BIN_CLOSE Binary closing (dilate, then erode) with a 3x3 structuring element.
%   OUT = bin_close(MASK) fills gaps and holes smaller than the 3x3 element
%   while leaving larger objects their original size. MASK is a logical or
%   numeric 2-D array (nonzero = foreground), and OUT is logical.
%
%   Example:
%       block = true(5,5); block(3,3) = false;
%       c = bin_close(block);   % hole filled
%
%   See also: bin_open, bin_erode, bin_dilate.

narginchk(1, 1);
if ~((islogical(mask) || isnumeric(mask)) && ndims(mask) == 2)
    error('bin_close:badInput', 'MASK must be a 2-D logical or numeric array.');
end
out = bin_erode(bin_dilate(mask));
end
