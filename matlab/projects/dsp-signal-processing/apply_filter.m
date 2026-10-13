function y = apply_filter(b, x, a)
%APPLY_FILTER Filter a signal with FIR (or IIR) coefficients using filter().
%   y = apply_filter(b, x) applies the FIR filter with coefficient vector b to
%   the real vector x, equivalent to filter(b, 1, x).
%   y = apply_filter(b, x, a) applies the IIR filter H(z) = B(z)/A(z).
%
%   Why filter() and not conv(): for causal FIR use both give identical
%   numbers, but filter() is the direct-form recursion the project also needs
%   for IIR (Butterworth) designs, so one O(numel(x)*numel(b)) streaming API
%   covers both; conv() additionally materializes the full padded result
%   (numel(x)+numel(b)-1) that callers here would have to trim.
%
%   Example:
%       b = fir_design_lowpass(0.25, 11, 'hamming');
%       rng(0); x = randn(1, 1000);
%       y = apply_filter(b, x);

narginchk(2, 3);
if nargin < 3
    a = 1;
end
if ~isnumeric(b) || ~isvector(b) || ~isfinite(b) || ~isreal(b) || isempty(b)
    error('apply_filter:badB', 'B must be a nonempty finite real numeric vector.');
end
if ~isnumeric(x) || ~isvector(x) || ~isfinite(x) || ~isreal(x) || isempty(x)
    error('apply_filter:badX', 'X must be a nonempty finite real numeric vector.');
end
if ~isnumeric(a) || ~isvector(a) || ~isfinite(a) || ~isreal(a) || isempty(a) || a(1) == 0
    error('apply_filter:badA', 'A must be a finite real numeric vector with A(1) ~= 0.');
end

y = filter(b, a, x);
end
