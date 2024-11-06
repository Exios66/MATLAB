# Data Preprocessing Functions
library(caret)      # For data preprocessing
library(mice)       # For handling missing data
library(outliers)   # For outlier detection
library(recipes)    # For feature engineering
library(lubridate)  # For datetime processing

preprocess_data <- function(data, steps = c("clean", "transform", "engineer")) {
  processed_data <- data
  
  if("clean" %in% steps) {
    processed_data <- clean_data(processed_data)
  }
  if("transform" %in% steps) {
    processed_data <- transform_data(processed_data)
  }
  if("engineer" %in% steps) {
    processed_data <- engineer_features(processed_data)
  }
  
  return(processed_data)
}

clean_data <- function(data) {
  # Handle missing values
  numeric_cols <- sapply(data, is.numeric)
  if(any(is.na(data))) {
    imp_model <- mice(data, method = "pmm", printFlag = FALSE)
    data <- complete(imp_model)
  }
  
  # Remove duplicates
  data <- distinct(data)
  
  # Handle outliers
  for(col in names(data)[numeric_cols]) {
    q1 <- quantile(data[[col]], 0.25)
    q3 <- quantile(data[[col]], 0.75)
    iqr <- q3 - q1
    data <- data %>%
      filter(!!sym(col) >= (q1 - 1.5 * iqr),
             !!sym(col) <= (q3 + 1.5 * iqr))
  }
  
  return(data)
}

transform_data <- function(data) {
  # Normalize numeric columns
  numeric_cols <- sapply(data, is.numeric)
  if(any(numeric_cols)) {
    preProcess_range <- preProcess(data[numeric_cols], method = c("center", "scale"))
    data[numeric_cols] <- predict(preProcess_range, data[numeric_cols])
  }
  
  # Convert categorical to factors
  categorical_cols <- sapply(data, is.character)
  data[categorical_cols] <- lapply(data[categorical_cols], as.factor)
  
  return(data)
}

engineer_features <- function(data) {
  # Date-based features
  date_cols <- sapply(data, inherits, "POSIXct")
  for(col in names(data)[date_cols]) {
    data[[paste0(col, "_year")]] <- year(data[[col]])
    data[[paste0(col, "_month")]] <- month(data[[col]])
    data[[paste0(col, "_day")]] <- day(data[[col]])
    data[[paste0(col, "_wday")]] <- wday(data[[col]])
  }
  
  # Interaction terms for numeric columns
  numeric_cols <- names(data)[sapply(data, is.numeric)]
  if(length(numeric_cols) >= 2) {
    for(i in 1:(length(numeric_cols)-1)) {
      for(j in (i+1):length(numeric_cols)) {
        col_name <- paste0(numeric_cols[i], "_x_", numeric_cols[j])
        data[[col_name]] <- data[[numeric_cols[i]]] * data[[numeric_cols[j]]]
      }
    }
  }
  
  return(data)
} 