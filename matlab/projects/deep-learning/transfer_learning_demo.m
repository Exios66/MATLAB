function stats = transfer_learning_demo(imds, opts)
%TRANSFER_LEARNING_DEMO OPTIONAL: fine-tune a pretrained resnet50.
%   stats = transfer_learning_demo(imds, opts) demonstrates the standard
%   transfer-learning workflow on an image dataset: freeze a pretrained
%   resnet50 as a feature extractor, then train this project's own softmax MLP
%   head on the extracted features (mini-batch SGD from this codebase).
%
%   This function is a BONUS and is deliberately gated: it is the only file
%   allowed to call Deep Learning Toolbox code. If resnet50 is unavailable it
%   errors with a clear message naming the toolbox requirement, and the core
%   project (everything else) stays base MATLAB only.
%
%   imds   : labeled image datastore (must have a Labels property)
%   opts   : optional struct with fields (all optional, defaults shown):
%               validation_fraction  0.2    held-out fraction of samples
%               lr                   0.01   head learning rate
%               epochs               60     head training epochs
%               seed                 0      RNG seed
%   stats  : struct with fields feature_dim, num_classes, epochs, head,
%            train_acc, val_acc.
%
%   Example:
%       imds = imageDatastore('my_images', 'IncludeSubfolders', true, ...
%           'LabelSource', 'foldernames');
%       stats = transfer_learning_demo(imds, struct());

% Gate FIRST, before touching any Deep Learning Toolbox function.
if exist('resnet50', 'file') == 0
    error('deep-learning:noResnet', ...
        ['transfer_learning_demo is optional and requires the Deep Learning Toolbox ' ...
         'plus the resnet50 pretrained-model support package; the core project ' ...
         'is intentionally base MATLAB only, so this demo is not available.']);
end
if nargin < 2 || isempty(opts), opts = struct(); end
if ~isstruct(opts)
    error('transfer_learning_demo:badOpts', 'opts must be a struct (possibly empty).');
end
if ~isfield(opts, 'validation_fraction'), opts.validation_fraction = 0.2; end
if ~isfield(opts, 'lr'), opts.lr = 0.01; end
if ~isfield(opts, 'epochs'), opts.epochs = 60; end
if ~isfield(opts, 'seed'), opts.seed = 0; end
if ~isscalar(opts.validation_fraction) || opts.validation_fraction <= 0 ...
        || opts.validation_fraction >= 0.9
    error('transfer_learning_demo:badFraction', 'validation_fraction must be in (0, 0.9).');
end
if ~isnumeric(opts.lr) || ~isscalar(opts.lr) || opts.lr <= 0
    error('transfer_learning_demo:badLR', 'opts.lr must be a positive scalar.');
end
if ~isnumeric(opts.epochs) || ~isscalar(opts.epochs) || opts.epochs < 1 ...
        || opts.epochs ~= floor(opts.epochs)
    error('transfer_learning_demo:badEpochs', 'opts.epochs must be a positive integer.');
end
if ~isscalar(opts.seed) || opts.seed < 0 || opts.seed ~= floor(opts.seed)
    error('transfer_learning_demo:badSeed', 'opts.seed must be a non-negative integer scalar.');
end
if isa(imds, 'struct') || ~isprop(imds, 'Labels') || isempty(imds.Labels)
    error('transfer_learning_demo:badData', ...
        'imds must be a labeled image datastore with a nonempty Labels property.');
end

try
    net = resnet50;
catch err
    error('deep-learning:weightsMissing', ...
        'resnet50 is present but its pretrained weights are unavailable (%s).', err.message);
end

% Feature layer: fc1000 (fully connected) when present, else the last layer.
names = {net.Layers.Name};
if any(strcmp(names, 'fc1000'))
    feature_layer = 'fc1000';
else
    feature_layer = names{end};
end

labels = double(imds.Labels(:).');           % class index per sample, 1..k
n = numel(labels);
num_classes = numel(categories(imds.Labels));

% ResNet expects 224x224 RGB input; augmentedImageDatastore does the resize.
aug = augmentedImageDatastore([224 224], imds);
F = activations(net, aug, feature_layer, 'OutputAs', 'features');
F = squeeze(F);
% shortcut: activations() returns N-by-D for fully-connected features here, but
% racked layouts have varied across releases; if feature_dim looks wrong,
% reshape/transpose F before the split below.
if size(F, 1) ~= n, F = reshape(F, [], n).'; end

% 80/20-style split, deterministic via the seed.
rng(opts.seed);
perm = randperm(n);
n_val = max(1, floor(opts.validation_fraction * n));
val_idx = perm(1:n_val);
tr_idx = perm(n_val + 1:end);

% One-hot targets, then train the small softmax head with our own backprop.
Y = zeros(num_classes, n);
Y(sub2ind([num_classes, n], labels, 1:n)) = 1;
head = mlp_init([size(F, 2), num_classes], opts.seed);
[head, ~] = mlp_train(head, F(tr_idx, :).', Y(:, tr_idx), ...
    struct('lr', opts.lr, 'epochs', opts.epochs, ...
           'batch_size', min(32, numel(tr_idx)), 'seed', opts.seed));

train_pred = mlp_predict(head, F(tr_idx, :).');
val_pred = mlp_predict(head, F(val_idx, :).');

stats = struct();
stats.feature_dim = size(F, 2);
stats.num_classes = num_classes;
stats.epochs = opts.epochs;
stats.head = 'frozen resnet50 features -> softmax MLP head';
stats.train_acc = mean(train_pred == labels(tr_idx));
stats.val_acc = mean(val_pred == labels(val_idx));
end
