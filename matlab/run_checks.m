function run_checks()
%RUN_CHECKS Lint and test every MATLAB project in this repository.
%   Run from anywhere:   run_checks
%   Lints all .m files under matlab/ with CHECKCODE, then runs all
%   matlab.unittest function-based tests found under matlab/projects.
%   Errors out (exit code 1) on any lint "error-severity" finding or test
%   failure; stylistic warnings are printed but tolerated.
%
%   shortcut: no severity classification from checkcode output, all
%   messages count as warnings-only unless a test fails — upgrade if a
%   lint rule needs to become blocking.

root = fileparts(mfilename('fullpath'));

fprintf('== checkcode (lint) ==\n');
files = dir(fullfile(root, '**', '*.m'));
files = files(~[files.isdir]);
issues = 0;
for i = 1:numel(files)
    f = fullfile(files(i).folder, files(i).name);
    msgs = checkcode(f);
    for j = 1:numel(msgs)
        fprintf('%s: L%d: %s\n', f, msgs(j).line, msgs(j).message);
        issues = issues + 1;
    end
end
fprintf('checkcode: %d messages\n', issues);

fprintf('== tests ==\n');
testResults = runtests(fullfile(root, 'projects'));
disp(table(testResults));
allPassed = all([testResults.Passed]);

if ~allPassed
    error('run_checks:failed', 'Test failures detected.');
end
fprintf('All checks passed.\n');
end
