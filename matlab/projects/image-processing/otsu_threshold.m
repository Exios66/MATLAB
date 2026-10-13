function t = otsu_threshold(img)
%OTSU_THRESHOLD Histogram Otsu threshold: maximize between-class variance.
%   T = otsu_threshold(IMG) builds a 256-bin histogram of IMG(:) spanning
%   [min(IMG(:)), max(IMG(:))] and returns the bin edge T (an actual value in
%   IMG's own scale) that maximizes w0*w1*(mu0-mu1)^2 between the two pixel
%   classes. Pixels strictly greater than T belong to class 1 (see binarize).
%   IMG is a finite numeric array in any scale; a constant image returns its
%   own value (class 1 is then empty). Ties always resolve to the lowest
%   winning bin, so T is deterministic.
%
%   Example:
%       t = otsu_threshold([0.2*ones(4,4), 0.8*ones(4,4)]);
%
%   See also: binarize, run_pipeline.

narginchk(1, 1);
if ~isnumeric(img) || ~all(isfinite(img(:)))
    error('otsu_threshold:badInput', 'IMG must be a finite numeric array.');
end

v = double(img(:));
lo = min(v);
hi = max(v);
if lo == hi
    t = lo;
    return
end

edges = linspace(lo, hi, 257);          % 256 bins over the data range
counts = histcounts(v, edges);
p = counts / sum(counts);
c = (edges(1:end-1) + edges(2:end)) / 2;  % bin centers

w0 = cumsum(p);                          % class-0 weight for cut after bin k
m0 = cumsum(p .* c);                     % class-0 weighted center sum
muT = sum(p .* c);
w1 = 1 - w0;

sigma_b = zeros(size(w0));
valid = w0 > 1e-12 & w1 > 1e-12;         % identity: sigB^2 = (muT*w0 - m0)^2/(w0*w1)
sigma_b(valid) = (muT .* w0(valid) - m0(valid)).^2 ./ (w0(valid) .* w1(valid));
[~, k] = max(sigma_b);
t = edges(k+1);
end
