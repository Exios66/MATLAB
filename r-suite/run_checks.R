#!/usr/bin/env Rscript
# Run all R suite checks from this directory: parse-check every .R file,
# lint if lintr is installed, then execute tests/run_tests.R if present.
# Exit code 1 on failure, so callers can gate on it.
# Usage: Rscript run_checks.R
ok <- TRUE

files <- list.files(".", pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
files <- files[basename(files) != "run_checks.R"]

for (f in files) {
  res <- tryCatch({ parse(f); TRUE },
                  error = function(e) { message("PARSE FAIL ", f, ": ", conditionMessage(e)); FALSE })
  ok <- ok && res
}
cat("Parsed", length(files), "R files:", if (ok) "ok\n" else "FAILURES\n")

if (ok && requireNamespace("lintr", quietly = TRUE)) {
  hits <- unlist(lapply(files, function(f)
    tryCatch(lintr::lint(f), error = function(e) NULL)))
  cat("lintr:", length(hits), "issues\n")
}

if (ok && dir.exists("tests")) {
  for (t in sort(list.files("tests", pattern = "\\.R$", full.names = TRUE))) {
    res <- tryCatch({ local(source(t, local = new.env(), echo = FALSE)); TRUE },
                    error = function(e) { message("TEST FAIL ", t, ": ", conditionMessage(e)); FALSE })
    ok <- ok && res
  }
}

if (!ok) quit(status = 1)
cat("All checks passed\n")
