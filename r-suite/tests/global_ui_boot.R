#!/usr/bin/env Rscript
# Shiny boot guard: attaches the UI dependencies, sources global.R, then
# evaluates ui.R -- the only execution path the function-level tests cannot
# cover. Skips (silently) when UI deps are missing; fails loudly on any boot
# break. Scoped to catch the review's B1/B3 class of regressions.

run_boot_check <- function() {
  suite_root <- getwd()
  self_file <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(self_file) > 0) {
    candidate <- dirname(dirname(normalizePath(sub("^--file=", "", self_file), mustWork = FALSE)))
    if (file.exists(file.path(candidate, "app", "global.R"))) suite_root <- candidate
  }

  required_pkgs <- c("shiny", "shinydashboard", "shinydashboardPlus", "shinyjs",
                     "shinyWidgets", "DT", "waiter", "fresh", "bs4Dash",
                     "plotly", "rmarkdown", "ggplot2", "tidyverse")
  missing <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    message("SKIP boot check: UI deps not installed (", paste(missing, collapse = ", "), ")")
    return(invisible(TRUE))
  }

  old <- getwd()
  on.exit(setwd(old), add = TRUE)
  setwd(file.path(suite_root, "app"))

  env <- new.env(parent = globalenv())
  source("global.R", local = env)          # guard + attach + sourced helpers
  if (!exists("ui", envir = env) ) stop("global.R did not define the ui object")
  ui_el <- eval(parse("ui.R"), env)        # evaluating ui.R = the real boot surface
  ok <- inherits(ui_el, "shiny.tag") || inherits(ui_el, "shiny.tag.list")
  if (!ok) stop("ui.R did not evaluate to a Shiny tag object")
  cat("Boot check passed: deps attached, ui.R evaluated to", class(ui_el)[1], "\n")
  invisible(TRUE)
}

run_boot_check()
