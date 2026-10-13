# MATLAB & R Data Analysis Showcase

Personal portfolio of data-analysis engineering: four **MATLAB algorithm projects implemented from scratch** (no toolboxes), plus a **repaired R Shiny visualization suite**.

![License](https://img.shields.io/badge/license-MIT-green.svg)
![MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-orange.svg)
![R](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)

## MATLAB Projects (`matlab/projects/`)

Each project is base-MATLAB only (no toolboxes), ships function-based tests (`matlab.unittest`), and generates its own figures on demand. Full details in each project's README.

| Project | Showcase | Highlights |
|---|---|---|
| [numerical-methods](matlab/projects/numerical-methods/) | ODE solving, root finding, Monte Carlo, linear algebra | Euler vs RK4 convergence study, Gaussian elimination with partial pivoting |
| [dsp-signal-processing](matlab/projects/dsp-signal-processing/) | Digital filter design & spectral analysis from scratch | Windowed-sinc FIR, analog-prototype + bilinear-transform Butterworth, 2-state Kalman filter |
| [image-processing](matlab/projects/image-processing/) | Computer-vision pipeline without toolboxes | Hand-rolled Sobel, Otsu thresholding, morphological ops, BFS connected components |
| [deep-learning](matlab/projects/deep-learning/) | Backpropagation implemented by hand | From-scratch MLP (He init, ReLU + softmax cross-entropy), numerical gradient checking, optional toolbox-gated transfer-learning demo |

### Quick start (MATLAB)

```matlab
cd matlab
run_checks          % lints all .m files (checkcode) and runs every project's tests
```

Then regenerate a project's figures (writes PNGs into its `images/` folder):

```matlab
cd projects/numerical-methods
generate_figures
```

> **Note:** `generate_figures` uses `exportgraphics` (base MATLAB since R2020a). The tests themselves run on older releases. Figures are not committed — each project generates its own.

## R Visualization Suite (`r-suite/`)

A Shiny dashboard (import → preprocess → visualize → export report). The suite was substantially rewritten: dead dependencies cut (`mice`, `caret`, `corrplot` replaced with base/ggplot2 equivalents), broken dispatch arms deleted, and a fail-fast dependency guard added.

### Quick start (R ≥ 4.0)

```bash
cd r-suite
Rscript run_checks.R    # parse-checks + lints + runs the 22-assertion test suite
Rscript run_app.R       # launches the Shiny app in a browser
```

`run_app.R` fails fast with the exact `install.packages(...)` command for anything missing. Required: `shiny, shinydashboard, shinydashboardPlus, shinyjs, shinyWidgets, DT, waiter, fresh, bs4Dash, plotly, rmarkdown, ggplot2, tidyverse`. Optional, only needed on demand: `readxl` (xlsx upload), `arrow` (feather upload), `igraph` (network layout).

## Verification status (honest)

- The R suite checks **were executed** during development: `Rscript run_checks.R` exits 0 (parse + lint + 22 assertions).
- The MATLAB code was **not executed** here (no MATLAB runtime available); it was developed with line-by-line static verification and numeric mirrors. Run `run_checks` on your first MATLAB session — all tests are included and discoverable by `runtests`.
- Root-level: `matlab/run_checks.m` (MATLAB side), `r-suite/run_checks.R` (R side).

## Repository layout

```
├── matlab/
│   ├── run_checks.m              # one command: lint + test everything
│   └── projects/                 # four self-contained showcase projects
├── r-suite/
│   ├── run_app.R                 # boots the Shiny app
│   ├── run_checks.R              # parse + lint + tests
│   ├── app/                      # Shiny app (global.R, ui.R, server.R, helpers)
│   └── tests/                    # assert-based suite (runs with installed packages)
└── docs/                         # GitHub Pages landing page
```

## License

MIT — see [LICENSE](LICENSE).
