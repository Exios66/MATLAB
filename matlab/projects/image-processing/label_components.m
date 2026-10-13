function [labels, count] = label_components(mask)
%LABEL_COMPONENTS Label 4-connected components of a logical image via BFS.
%   [LABELS, COUNT] = label_components(MASK) numbers each 4-connected group of
%   foreground pixels in the 2-D logical (or numeric, nonzero = foreground)
%   array MASK using breadth-first flood fill. LABELS is MxN double with
%   0 = background and 1..COUNT = component ids, assigned in raster scan order
%   of each component's first (top-left) pixel. Connectivity is 4-connected:
%   pixels that touch only diagonally belong to different components.
%
%   Example:
%       [lab, n] = label_components(eye(8) > 0);  % n = 8 single-pixel blobs
%
%   See also: bin_open, run_pipeline.

narginchk(1, 1);
if ~((islogical(mask) || isnumeric(mask)) && ndims(mask) == 2)
    error('label_components:badInput', 'MASK must be a 2-D logical or numeric array.');
end

% Pad by one false ring so BFS neighbors never need bounds checks.
m2 = false(size(mask, 1) + 2, size(mask, 2) + 2);
m2(2:end-1, 2:end-1) = logical(mask);
lab2 = zeros(size(m2));

queue = zeros(nnz(m2), 2);   % BFS frontier, preallocated, head/tail pointers
head = 0;
tail = 0;
count = 0;
offsets = [-1 0; 1 0; 0 -1; 0 1];

for ii = 2:size(m2, 1) - 1
    for jj = 2:size(m2, 2) - 1
        if m2(ii, jj) && lab2(ii, jj) == 0
            count = count + 1;
            tail = tail + 1;
            queue(tail, :) = [ii, jj];
            lab2(ii, jj) = count;
            while head < tail
                head = head + 1;
                cur = queue(head, :);
                for q = 1:4
                    nb = cur + offsets(q, :);
                    if m2(nb(1), nb(2)) && lab2(nb(1), nb(2)) == 0
                        lab2(nb(1), nb(2)) = count;
                        tail = tail + 1;
                        queue(tail, :) = nb;
                    end
                end
            end
        end
    end
end

labels = lab2(2:end-1, 2:end-1);
end
