# Data Preprocessing Functions
# caret/mice/outliers removed during repair: median fill + base scale() do the work.
library(dplyr)     # distinct(), !!!-built filter()
library(rlang)     # sym()/expr() to build column conditions
library(lubridate) # year()/month()/day()/wday()

preprocess_data <- function(data, steps = c("clean", "transform", "engineer")) {
  processed_data <- data

  if ("clean" %in% steps) {
    processed_data <- clean_data(processed_data)
  }
  if ("transform" %in% steps) {
    processed_data <- transform_data(processed_data)
  }
  if ("engineer" %in% steps) {
    processed_data <- engineer_features(processed_data)
  }

  processed_data
}

clean_data <- function(data) {
  # Median-fill missing numeric values (replaces mice; one pass, no NAs required)
  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]
  for (col in numeric_cols) {
    nas <- is.na(data[[col]])
    if (any(nas)) {
      data[[col]][nas] <- median(data[[col]][!nas]) # all-NA columns stay NA
    }
  }

  # Remove duplicates
  data <- distinct(data)

  # Recompute column indices AFTER imputation/dedup (was a stale-indices bug)
  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]

  # IQR bounds per column, all evaluated on the UNFILTERED data first, then one
  # single filter pass (the old sequential per-column filtering was statistically wrong)
  conds <- lapply(numeric_cols, function(col) {
    if (all(is.na(data[[col]]))) return(NULL)
    q <- quantile(data[[col]], c(0.25, 0.75), na.rm = TRUE)
    iqr <- unname(q[2] - q[1])
    if (iqr == 0) return(NULL) # constant columns would otherwise drop unequal rows
    lo <- unname(q[1] - 1.5 * iqr)
    hi <- unname(q[2] + 1.5 * iqr)
    expr(!!sym(col) >= !!lo & !!sym(col) <= !!hi)
  })
  conds <- Filter(Negate(is.null), conds)
  if (length(conds) > 0) data <- filter(data, !!!conds)

  data
}

transform_data <- function(data) {
  # Normalize numeric columns with base scale() (replaces caret::preProcess)
  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]
  sds <- vapply(data[numeric_cols], function(x) sd(x, na.rm = TRUE), numeric(1))
  to_scale <- numeric_cols[is.finite(sds) & sds > 0] # constant/NA columns would become NaN
  if (length(to_scale) > 0) {
    data[to_scale] <- as.data.frame(scale(as.matrix(data[to_scale])))
  }

  # Convert categorical to factors
  categorical_cols <- names(data)[vapply(data, is.character, logical(1))]
  data[categorical_cols] <- lapply(data[categorical_cols], as.factor)

  data
}

engineer_features <- function(data) {
  # Date-based features
  date_cols <- names(data)[vapply(data, inherits, logical(1), "POSIXct")]
  for (col in date_cols) {
    data[[paste0(col, "_year")]] <- year(data[[col]])
    data[[paste0(col, "_month")]] <- month(data[[col]])
    data[[paste0(col, "_day")]] <- day(data[[col]])
    data[[paste0(col, "_wday")]] <- wday(data[[col]])
  }

  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]
  # guard: pairwise interactions add n*(n-1)/2 columns -- skip beyond 8 numerics
  if (length(numeric_cols) >= 2 && length(numeric_cols) <= 8) {
    combos <- utils::combn(numeric_cols, 2)
    for (j in seq_len(ncol(combos))) {
      data[[paste0(combos[1L, j], "_x_", combos[2L, j])]] <-
        data[[combos[1L, j]]] * data[[combos[2L, j]]]
    }
  }

  data
}
