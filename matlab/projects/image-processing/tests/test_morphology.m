function tests = test_morphology()
proj_root = fileparts(fileparts(mfilename('fullpath')));
addpath(proj_root);
tests = functiontests(localfunctions);
end

function test_erode_full_square(tc)
% Hand-computed: only pixels with a full in-bounds 3x3 block survive a
% 5x5 all-true square, i.e. the centered 3x3 interior.
e = bin_erode(true(5, 5));
expected = false(5, 5); expected(2:4, 2:4) = true;
tc.verifyEqual(e, expected);
end

function test_erode_plus_sign(tc)
% Hand-computed: the plus sign has 1px-wide arms, so no pixel has an
% all-true 3x3 neighborhood -> erosion removes everything.
plus = false(5, 5); plus(3, :) = true; plus(:, 3) = true;
tc.verifyEqual(bin_erode(plus), false(5, 5));
end

function test_dilate_plus_sign(tc)
% Hand-computed: dilation thickens every arm by 1 on each side; rows 2-4
% fill completely (windows reach the row-3 arm), rows 1/5 keep cols 2-4.
plus = false(5, 5); plus(3, :) = true; plus(:, 3) = true;
expected = [false true true true false;
            true  true  true  true  true;
            true  true  true  true  true;
            true  true  true  true  true;
            false true  true  true  false];
tc.verifyEqual(bin_dilate(plus), expected);
end

function test_open_removes_speck(tc)
% A 4x4 blob (open-stable under the 3x3 element) plus a 1px speck:
% opening must recover the blob exactly and kill the speck.
canvas = false(9, 9); canvas(3:6, 3:6) = true; canvas(1, 1) = true;
expected = false(9, 9); expected(3:6, 3:6) = true;
tc.verifyEqual(bin_open(canvas), expected);
end

function test_close_fills_hole(tc)
% A 5x5 block with a single-pixel hole at its center: dilation fills the
% hole, erosion restores the outer 5x5 shape -> hole gone.
canvas = false(9, 9); canvas(3:7, 3:7) = true; canvas(5, 5) = false;
expected = false(9, 9); expected(3:7, 3:7) = true;
tc.verifyEqual(bin_close(canvas), expected);
end
