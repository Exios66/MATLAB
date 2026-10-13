# Numerical Methods Showcase

Portfolio-quality, base-MATLAB-only (no toolboxes; needs R2020a+ for `exportgraphics`) implementations of four classic numerical methods, each with input validation, deterministic behavior, function-based tests, and a figure generator. Also sibling-friendly: `run_checks` (one level up the repo) lints and tests everything under `matlab/projects`.

## Quick start

```matlab
cd(fullfile(repoRoot, 'matlab', 'projects', 'numerical-methods'))
addpath(pwd)
runtests('tests')       % function-based tests, self-contained (they addpath themselves)
generate_figures        % writes images/*.png
run_checks              % from repo root: checkcode lint + all project tests
```

- All MC functions take a trailing `seed` argument (default `0`) and call `rng(seed)` first.
- Deterministic by construction: ODE/Newton/Gaussian use no randomness at all.

## Function inventory

| Function | One-liner |
| --- | --- |
| `integrate_euler` | Fixed-step explicit Euler IVP solver; `(f, tspan, y0, h)` → `[t, y]`, one state row per time point (ode45 orientation). |
| `integrate_rk4` | Fixed-step classic RK4 (`(f, tspan, y0, h)` → `[t, y]`), global error O(h^4). |
| `newton_raphson` | Scalar Newton root finding; `(fun, dfun, x0, tol, maxiter)` → `[root, iter, converged]`; raises on vanishing derivative or no convergence. |
| `monte_carlo_integrate` | 1-D Monte Carlo quadrature; `(f, a, b, n, seed)` → `[estimate, stderr]` (needs a vectorized `f`). |
| `mc_pi` | Hit-or-miss MC estimate of pi; `(n, seed)` → `estimate`. |
| `gaussian_solve` | Gaussian elimination with partial pivoting; `(A, b)` → `x` (N-by-1); raises on singular. |
| `generate_figures` | Writes the three showcase PNGs (below) into `images/`. |

## Error identifiers

| Function | Identifier | Raised when |
| --- | --- | --- |
| all | `<func>:badInput` | wrong type/shape of an argument |
| `integrate_euler` / `integrate_rk4` | `<func>:badTspan` | `tspan(2) < tspan(1)` |
| `newton_raphson` | `newton_raphson:zeroDerivative` | `dfun` vanishes at an iterate |
| `newton_raphson` | `newton_raphson:maxiter` | `maxiter` reached, no convergence |
| `monte_carlo_integrate` | `monte_carlo_integrate:notVectorized` | `f` not one value per sample |
| `gaussian_solve` | `gaussian_solve:badShape` | A nonsquare or B wrong length |
| `gaussian_solve` | `gaussian_solve:singular` | pivot ≤ eps*norm(A,inf) encountered |

## What each test asserts

| File | Asserts |
| --- | --- |
| `tests/test_ode.m` | Euler error halves as `h` halves (measured order ~1); RK4 order ~4 across the same grid; both match `ode45` (tight `odeset`) on y' = -y; RK4 vector state on the harmonic oscillator matches `cos`/`-sin` analytically. |
| `tests/test_newton.m` | Finds the famous root of x³−2x−5 (≈2.0945515) and reports `converged`/`iter`; default-arg call works; `x^2+1` from `x0=1` raises `zeroDerivative` (step lands exactly on 0); rootless `exp(x)+1` raises `maxiter`. |
| `tests/test_montecarlo.m` | `mc_pi(2e5)` within ±0.05 of pi (~14σ band); MC ∫x² within ±0.01 of 1/3, `stderr` positive and < 0.01; stderr for n=1e5 far below stderr for n=1e3; same seed → bit-identical results; collapsing non-vectorized integrand raises. |
| `tests/test_linear.m` | 2×2 with dyadic answer equals `[1;3]` exactly (row `b` too); seeded random diagonally-dominant 20×20 matches `A\b` within 1e-8 relative; `[1 2; 2 4]` raises `singular`; wrong shapes raise `badShape`. |

## Images (appear after running `generate_figures`)

- `images/ode_order.png` — log-log max error vs step `h`: Euler slope ≈1, RK4 slope ≈4, with reference guide lines, on y′ = −y.
- `images/newton_trace.png` — semilogy trace of |f(x_k)| per Newton iteration for x³−2x−5 from x₀ = 2 (quadratic convergence).
- `images/mc_convergence.png` — MC estimate ± stderr for ∫₀¹ x² dx vs n (log x-axis), exact 1/3 line, seed 42.

## Notes

- MATLAB base functions only (`ode45`, `rng`, `rand`, `norm`, `exportgraphics`, ...); nothing from a toolbox.
- Deterministic RNGStreams caveat: `rng(seed)` reproducibility is per MATLAB default generator (`twister`) and stable in practice, though not formally guaranteed across releases.
- `gaussian_solve` flags a pivot when it drops to the roundoff scale `eps * norm(A, inf)`; near-singular-but-not-quite systems may still return amplified solutions — production code should prefer `A\b` with `rcond` diagnostics.

> **Note:** every project in this portfolio defines its own `generate_figures`. Run it from within this project folder, or with only this project's root on the MATLAB path, to avoid same-name function shadowing between sibling projects.
