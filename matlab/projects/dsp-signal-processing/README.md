# dsp-signal-processing

Flagship showcase: classic DSP built from scratch in **base MATLAB, no
toolboxes** — window functions, windowed-sinc FIR design, IIR Butterworth via
analog prototype + bilinear transform, a constant-velocity Kalman filter, and
FFT-based spectral analysis. Follows the repo-wide conventions (one function
per file, H1 help, input validation, deterministic seeds, tests under `tests/`).

Requires MATLAB **R2020a**+ (`exportgraphics`/`xline`). No toolboxes.

## Quick start

```matlab
cd matlab/projects/dsp-signal-processing   % in MATLAB
generate_figures        % writes images/*.png
runtests('tests')       % or run matlab/run_checks.m from the repo root
```

## Function inventory

| Function | Signature | Purpose |
|---|---|---|
| `window_hann.m` | `w = window_hann(N)` | symmetric Hann window straight from the formula (N=1 -> 1) |
| `window_hamming.m` | `w = window_hamming(N)` | symmetric Hamming window straight from the formula |
| `fir_design_lowpass.m` | `b = fir_design_lowpass(fc, N, window)` | windowed-sinc linear-phase FIR lowpass; `fc` normalized (1 = Nyquist); windowed then normalized to unity DC gain |
| `apply_filter.m` | `y = apply_filter(b, x, a)` | filtering via `filter(b, a, x)` (a=1 for FIR). `filter()` is chosen over `conv()` because it is one streaming direct-form recursion shared by FIR and IIR; identical numbers for causal FIR |
| `freq_response.m` | `[h, w] = freq_response(b, a, nfft)` | FFT-based magnitude/phase response `H(e^jw)` on the one-sided grid 0..pi inclusive (freqz equivalent) |
| `butter_lowpass_design.m` | `[b, a] = butter_lowpass_design(fc, order)` | analog Butterworth unit-circle poles -> cutoff pre-warp (Omega_c = tan(w_c/2)) -> bilinear transform -> digital b,a (math documented in-file) |
| `kalman_filter.m` | `[xhat, Phist] = kalman_filter(z, Q, R, x0, P0, seed)` | 2-state (position+velocity) constant-velocity Kalman recursion, standard textbook equations, dt = 1 |
| `spectrum_periodogram.m` | `[f, psd] = spectrum_periodogram(x, fs)` | one-sided Hann-window FFT periodogram; scaling `2*abs(X)^2/(fs*sum(w.^2))` corrects the window's noise-power gain |

`generate_figures.m` renders all figures (run from the project root; writes
PNGs into `images/`).

## Tests (`tests/`)

Function-based, deterministic (fixed `rng` seeds), fast, tolerance-aware.

| Test file | What it asserts |
|---|---|
| `test_fir.m` | impulse response symmetric (=> linear phase) with the hand-derived N=5 tap value 0.4821; passband `abs(H) > 0.9` at 0.3*fc; stopband < -20 dB at 3*fc with Hamming |
| `test_freq_response.m` | grid spans [0, pi]; DC gain exactly 1 for the lowpass; response at cutoff = -6.02 dB +/- 2 (tolerance generous on purpose: windowed-sinc attenuation at the cutoff deviates from the ideal by tenths of a dB once truncated and windowed) |
| `test_butter.m` | b, a finite; b palindromic; a(1) = 1, length order+1; magnitude at cutoff -3.01 dB +/- 2 (pre-warp makes it exact at the analog point); DC gain 1 |
| `test_kalman.m` | position MSE < raw measurement MSE on a noisy slow sine; converged velocity state recovers a true constant v within 0.05 |
| `test_window.m` | Hann/Hamming symmetric to 1e-12; hand-derived N=4 values (`[0 .75 .75 0]`, endpoint 0.08); sums match the closed form (1.5 and 1.7); length/row shape; N=1 edge case = 1 |
| `test_spectrum.m` | on-bin tones at 137 Hz and 319 Hz found within 1 Hz; PSD finite and nonnegative; the integrated PSD equals the true signal power (0.125 + 0.04) within 15% |

Note: each test file `addpath()`s its own parent folder, so the suite works
both under the repo-root `matlab/run_checks.m` and standalone.

> **Note:** every project in this portfolio defines its own `generate_figures`. Run it from within this project folder, or with only this project's root on the MATLAB path, to avoid same-name function shadowing between sibling projects.
