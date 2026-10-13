function tests = test_pipeline()
proj_root = fileparts(fileparts(mfilename('fullpath')));
addpath(proj_root);
tests = functiontests(localfunctions);
end

function test_end_to_end_counts_objects(tc)
% The synthetic scene holds a rectangle and two discs; each closed outline
% must survive blur, Otsu binarization and opening as one component.
res = run_pipeline();
tc.verifyEqual(res.count, 3);
end

function test_result_fields(tc)
res = run_pipeline();
expected = {'scene', 'gray', 'blurred', 'edge_mag', 'edge_orient', ...
            'threshold', 'edges_binary', 'opened', 'labels', 'count'};
for k = 1:numel(expected)
    tc.verifyTrue(isfield(res, expected{k}), 'missing field %s', expected{k});
end
end

function test_intermediate_consistency(tc)
res = run_pipeline();
tc.verifyEqual(size(res.gray), [256 256]);
tc.verifyEqual(size(res.labels), [256 256]);
tc.verifyTrue(islogical(res.edges_binary) && islogical(res.opened));
tc.verifyTrue(isa(res.labels, 'double'));
tc.verifyTrue(res.threshold >= 0 && res.threshold <= max(res.edge_mag(:)), ...
    'threshold must sit within the edge-magnitude range');
tc.verifyTrue(all(res.edge_mag(:) >= 0 & res.edge_mag(:) <= 1), 'magnitude must be in [0,1]');
tc.verifyTrue(all(isfinite(res.blurred(:))), 'blur must stay finite');
end
