# Deep Learning from Scratch — hand-written MLP (MATLAB)

A from-scratch multi-layer perceptron with **manual backpropagation**, written in
**base MATLAB only — no toolboxes** in the core path. It is initialized (He),
forward-propagated (ReLU hidden layers + overflow-safe softmax), differentiated
analytically (softmax+cross-entropy simplification), and trained with shuffled
mini-batch SGD — then verified by a numerical gradient check, an overfit-
memorization test, shape tests, and softmax numerical-stability tests.

## Quick start (interactive)

```matlab
cd <this project dir>                 % or addpath it
[X, Y] = spiral_data(40, 3, 0.1, 0);  % deterministic synthetic data
params = mlp_init([2 32 3], 1);       % He-initialized net
[params, loss] = mlp_train(params, X, Y, ...
    struct('lr', 1.0, 'epochs', 300, 'batch_size', 40, 'seed', 1));
[~, cls] = max(Y, [], 1);
mean(mlp_predict(params, X) == cls)   % training accuracy
generate_figures                      % writes the PNGs in images/
```

Requires R2020a+ (for `exportgraphics`; implicit expansion needs R2016b+).
Tests are auto-discovered by the repo-level `matlab/run_checks.m`
(checkcode + runtests over `matlab/projects`); standalone: `runtests('tests')`.

## Function inventory

| Function | Signature | Purpose |
|---|---|---|
| `spiral_data.m` | `[X, Y] = spiral_data(n_per_class, k, noise, seed)` | deterministic k-class 2-D spiral dataset; `X` 2×N, `Y` k×N one-hot |
| `mlp_init.m` | `params = mlp_init(layer_sizes, seed)` | params struct (`sizes`, `W{i}`, `b{i}`) with He initialization |
| `mlp_forward.m` | `[probs, cache] = mlp_forward(params, X)` | ReLU hidden layers + max-shifted softmax output; returns caches for backprop |
| `mlp_backward.m` | `grads = mlp_backward(params, cache, Y)` | analytic gradients of mean cross-entropy (`dW{i}`, `db{i}`) |
| `mlp_train.m` | `[params, loss_history] = mlp_train(params, X, Y, opts)` | shuffled mini-batch SGD; `opts`: `lr` (0.1), `epochs` (300), `batch_size` (32), `seed` (0) |
| `mlp_predict.m` | `labels = mlp_predict(params, X)` | argmax class per sample, 1-by-N, deterministic tie-breaking |
| `transfer_learning_demo.m` | `stats = transfer_learning_demo(imds, opts)` | **OPTIONAL** — see below |
| `generate_figures.m` | script | writes `images/*.png` (run from any cwd; it `cd`s to the project root) |

All randomness is behind a default seed argument (0), so everything is reproducible.

## Tests (all synthetic data, generated in code)

| Test file | What it asserts |
|---|---|
| `tests/test_gradient.m` | every weight and bias of a 3-4-2 and a 3-4-3-2 net: analytic gradient vs central finite differences (h = 1e-5) of the same loss `mlp_train` minimizes; max relative error < 1e-4 (entries where both grads are ~0 are skipped as agreeing) |
| `tests/test_overfit.m` | trains on 75 clean spiral points, 2-32-3 net, 400 full-batch steps → > 95% training accuracy and a decreasing loss (the pipeline really learns) |
| `tests/test_shapes.m` | forward/backward shapes for arbitrary layer sizes ([4 6 5 3]), degenerate nets ([2 1 3], [1 3] with zero hidden layers), predict labels ∈ 1..k, 2-epoch history length |
| `tests/test_softmax.m` | softmax rows sum to 1; hand-computed value `exp(2)/(exp(2)+exp(-2))` at logits (2, −2); logits ±5e6 stay finite (max-subtraction trick), argmax preserved both ways |

## Images

Produced by `generate_figures` (not committed; run once):

- `images/spiral_data.png` — 3-class spiral scatter (300 points, noise 0.15)
- `images/loss_curve.png` — training loss per epoch
- `images/decision_region.png` — `mlp_predict` over a 60×60 meshgrid → contourf regions with data overlaid

## Optional bonus: `transfer_learning_demo`

The only file allowed to touch the Deep Learning Toolbox. It is explicitly
gated: without `resnet50` (Deep Learning Toolbox + resnet50 model support
package) it errors with a clear message naming the requirement. When
available it implements the classic frozen-feature workflow — extract resnet50
features, then train this project's own softmax MLP head on them — and returns
train/val accuracy. Fine-tuning resnet50 layers themselves would require
`trainNetwork`/`dlnetwork` and is intentionally out of scope here.

## Math note

For a softmax output plus cross-entropy loss, the chain rule through
`dP_c/dZ_t = P_c (1{c=t} − P_t)` collapses the output jacobian to
`dL/dZ_L = (P − Y)/N` — implemented as one subtraction in `mlp_backward`.
Softmax subtracts each column's max before `exp` because `exp` overflows
above ~709 and softmax is invariant to that shift.

> **Note:** every project in this portfolio defines its own `generate_figures`. Run it from within this project folder, or with only this project's root on the MATLAB path, to avoid same-name function shadowing between sibling projects.
