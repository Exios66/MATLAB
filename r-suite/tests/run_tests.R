#!/usr/bin/env Rscript
# r-suite test suite -- uses ONLY locally installed packages (ggplot2/dplyr/rlang/base).
# Excluded here ON PURPOSE because their runtime packages are not installed locally:
#   - advanced treemap/network branches (need plotly + igraph) and the Shiny boot
#     path (shinydashboard family; see app/global.R guard instead)
#   - report rendering (rmarkdown pipeline)
# preprocess_data, suggest_visualization, visualize_correlation, themes and
# create_visualization have no such deps and are exercised below.

# Locate the suite root no matter where the test is invoked from
# (direct: Rscript tests/run_tests.R; sourced: by run_checks.R, where --file= is run_checks.R)
suite_root <- getwd()
self_file <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(self_file) > 0) {
  candidate <- dirname(dirname(normalizePath(sub("^--file=", "", self_file), mustWork = FALSE)))
  if (file.exists(file.path(candidate, "app", "preprocessing.R"))) suite_root <- candidate
}
setwd(suite_root) # r-suite/

library(ggplot2)
library(rlang)

PASS <- new.env(); PASS$n <- 0L

check <- function(desc, cond) {
  if (!isTRUE(all(cond))) stop("FAIL: ", desc, call. = FALSE)
  PASS$n <- PASS$n + 1L
  invisible(TRUE)
}

# Source app helpers (all top-level library() calls are installed-only files)
helpers <- new.env(parent = globalenv())
for (f in c("preprocessing.R", "themes.R", "visualization_pipeline.R",
            "advanced_visualizations.R", "statistical_visualizations.R")) {
  source(file.path("app", f), local = helpers)
}

# ---- preprocess_data: clean path (median fill, dedup, one-pass outlier cut) ----
synthetic <- data.frame(
  age    = c(25, 32, 47, 51, 37, 29, 44, 40),
  income = c(50, 62, 80, 71, 55, 66, 58, 82) * 1000,
  hours  = c(40, 45, 38, NA, 41, 39, 36, 44),
  dept   = factor(c("A", "B", "A", "C", "B", "A", "B", "C")),
  city   = c("NY", "SF", "NY", "LA", "SF", "LA", "NY", "SF")
)
# one NA in age + one NA in hours drive median fill; the 5e6 row drives the IQR cut
synthetic_bad <- rbind(synthetic, data.frame(age = NA, income = 5e6, hours = 45.5,
                                             dept = "C", city = "NY"))
cleaned <- helpers$clean_data(synthetic_bad)
check("median fill removed all numeric NAs", !anyNA(cleaned[c("age", "income", "hours")]))
check("NA hours was filled with observed median", cleaned$hours[cleaned$income == 71000] == 40.5)
check("outlier row cut in one pass", nrow(cleaned) == 8L || !any(cleaned$income == 5e6))
check("normal rows all survived the cut", sum(sapply(synthetic$income, `%in%`, cleaned$income)) == 8L)

# transform: base scale() + character -> factor
transformed <- helpers$preprocess_data(cleaned, steps = "transform")
check("normalized columns have sd ~1",
      all(vapply(transformed[c("age", "income", "hours")],
                 function(x) abs(sd(x) - 1) < 1e-9, logical(1))))
check("character column became a factor", is.factor(transformed$city))

# engineer: interactions (3 numerics -> 3 pairs) + date features + >8-column guard
engineered <- helpers$preprocess_data(transformed, steps = "engineer")
check("3 interaction columns built", sum(grepl("_x_", names(engineered), fixed = TRUE)) == 3L)
check("interaction math is the product",
      all(engineered$age_x_hours == engineered$age * engineered$hours))
dated <- helpers$engineer_features(data.frame(Stamp = as.POSIXct("2023-03-14 05:00:00", tz = "UTC")))
check("date features engineered",
      dated$Stamp_year == 2023 && dated$Stamp_month == 3 && dated$Stamp_wday %in% 1:7)
wide <- as.data.frame(matrix(rnorm(100), ncol = 10))
check("interaction guard skips >8 numeric columns",
      sum(grepl("_x_", names(helpers$engineer_features(wide)), fixed = TRUE)) == 0L)

# ---- suggest_visualization mapping ----
check("suggest: 2+ numeric -> scatter",
      helpers$suggest_visualization(data.frame(a = 1:5, b = 2:6)) == "scatter")
check("suggest: factor + numeric -> bar",
      helpers$suggest_visualization(data.frame(f = factor(1:5), n = 1:5)) == "bar")
check("suggest: datetime + numeric -> line",
      helpers$suggest_visualization(data.frame(t = as.POSIXct(c("2023-01-01", "2023-01-02")),
                                               n = 1:2)) == "line")
check("suggest: factor only -> bar",
      helpers$suggest_visualization(data.frame(f = factor(1:3))) == "bar")

# ---- visualize_correlation returns a ggplot (with non-numeric columns present) ----
corr_plot <- helpers$visualize_correlation(synthetic)
check("correlation heatmap is a ggplot object", inherits(corr_plot, "ggplot"))

# ---- dep-free theme functions ----
check("theme_modern returns a ggplot theme", inherits(helpers$theme_modern(), "theme"))
check("theme_dark_custom returns a ggplot theme", inherits(helpers$theme_dark_custom(), "theme"))
check("theme_corporate returns a ggplot theme", inherits(helpers$theme_corporate(), "theme"))

# ---- create_visualization builds plots for all surviving types ----
scatter_plot <- helpers$create_visualization(synthetic, "scatter", x = "age", y = "income",
                                             color = "dept", facet = "city",
                                             interactive = FALSE)
check("scatter builds with x/y/color/facet", inherits(scatter_plot, "ggplot"))
check("auto type suggestion flows into scatter",
      inherits(helpers$create_visualization(data.frame(a = 1:5, b = 2:6),
                                            interactive = FALSE), "ggplot"))
check("bar plot builds from defaults",
      inherits(helpers$create_visualization(synthetic, "bar", interactive = FALSE), "ggplot"))
check("line plot builds from defaults",
      inherits(helpers$create_visualization(
        data.frame(t = as.POSIXct(c("2023-01-01", "2023-01-02", "2023-01-03")),
                   v = c(1, 2, 3)),
        "line", interactive = FALSE), "ggplot"))

cat("All", PASS$n, "assertions passed\n")
