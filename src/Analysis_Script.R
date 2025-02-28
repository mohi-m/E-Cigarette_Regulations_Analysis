# Load required libraries
library(dplyr)
library(forecast)
library(ggplot2)
library(lubridate)

# Load and preprocess the dataset
load_and_preprocess_data <- function(file_path) {
  data <- read.csv(file_path)
  
  data <- data %>%
    mutate(
      Effective_Date = as.Date(Effective_Date, format = "%m/%d/%Y"),
      Year_Quarter = paste(YEAR, "Q", Quarter, sep = "")
    ) %>%
    filter(!is.na(Effective_Date))
  
  return(data)
}

# Calculate stringency score
calculate_stringency_score <- function(data) {
  data %>%
    mutate(stringency_score = case_when(
      ProvisionGroupDesc == "Enforcement" & ProvisionDesc == "Enforcement (Type)" ~ 
        case_when(
          grepl("police|sheriff|peace officer", tolower(ProvisionValue)) ~ 7,
          grepl("alcoholic beverage|liquor", tolower(ProvisionValue)) ~ 6,
          grepl("department|commission", tolower(ProvisionValue)) ~ 5,
          grepl("local|mayor", tolower(ProvisionValue)) ~ 3,
          ProvisionValue == "Yes" ~ 2,
          ProvisionValue == "No Provision" ~ 1,
          TRUE ~ 1
        ),
      ProvisionGroupDesc == "Penalties" & ProvisionDesc == "License Suspension or Revocation" ~ 
        case_when(
          ProvisionValue == "Both" ~ 6,
          ProvisionValue == "Revocation" ~ 4,
          ProvisionValue == "Suspension" ~ 3,
          TRUE ~ 1
        ),
      ProvisionGroupDesc == "Restrictions" & ProvisionDesc %in% c("Possession Prohibited", "Purchase Prohibited") & ProvisionValue == "Yes" ~ 8,
      ProvisionGroupDesc == "Restrictions" & ProvisionDesc == "Use Prohibited" & ProvisionValue == "Yes" ~ 7,
      ProvisionGroupDesc == "Restrictions" & ProvisionDesc %in% c("Banned from Location", "Restriction on Access") & ProvisionValue == "Yes" ~ 6,
      ProvisionGroupDesc == "Restrictions" & ProvisionDesc == "Minimum Age (Years)" ~ 
        case_when(
          as.numeric(ProvisionValue) == 21 ~ 5,
          as.numeric(ProvisionValue) == 20 ~ 4,
          as.numeric(ProvisionValue) == 19 ~ 3,
          as.numeric(ProvisionValue) == 18 ~ 2,
          TRUE ~ 1
        ),
      TRUE ~ 1
    ))
}

# Aggregate data by state and year-quarter
aggregate_data <- function(data) {
  data %>%
    group_by(LocationDesc, Year_Quarter) %>%
    summarise(Total_Stringency = sum(stringency_score, na.rm = TRUE), .groups = "drop") %>%
    arrange(LocationDesc, Year_Quarter)
}

# ARIMA modeling and forecasting
arima_forecast <- function(state_data, state_name, forecast_periods = 4) {
  ts_data <- ts(state_data$Total_Stringency, frequency = 4)
  model <- auto.arima(ts_data)
  forecasted <- forecast(model, h = forecast_periods)
  return(list(model = model, forecast = forecasted))
}

# Function to plot time series forecast for a state
plot_forecast <- function(state_name, forecast_result) {
  autoplot(forecast_result$forecast) +
    ggtitle(paste("Time Series Forecast for", state_name)) +
    xlab("Time") +
    ylab("Total Stringency Score")
}

# Main analysis function
run_analysis <- function(file_path) {
  data <- load_and_preprocess_data(file_path)
  data <- calculate_stringency_score(data)
  aggregated_data <- aggregate_data(data)
  
  state_results <- list()
  future_stringency <- data.frame(State = character(), Future_Stringency = numeric())
  
  for (state in unique(aggregated_data$LocationDesc)) {
    state_data <- aggregated_data %>% filter(LocationDesc == state)
    if (nrow(state_data) > 5) {
      result <- arima_forecast(state_data, state)
      state_results[[state]] <- result
      future_stringency <- rbind(future_stringency, 
                                 data.frame(State = state, 
                                            Future_Stringency = mean(result$forecast$mean)))
    }
  }
  
  top_10_states <- future_stringency %>%
    arrange(desc(Future_Stringency)) %>%
    head(10)
  
  top_5_states <- head(top_10_states, 5)
  
  # Plot forecasts for top 5 states
  forecast_plots <- list()
  for (state in top_5_states$State) {
    forecast_result <- state_results[[state]]
    forecast_plots[[state]] <- plot_forecast(state, forecast_result)
  }
  
  # Combine plots into a single figure
  combined_plot <- gridExtra::grid.arrange(grobs = forecast_plots, ncol = 2)
  
  return(list(state_results = state_results, top_10_states = top_10_states))
}

# Run the analysis
file_path <- "C:/Users/mohi2/OneDrive/Documents/MSIM/Fall 2024/IS 507/Project/CDC_STATE_System_E-Cigarette_Legislation_-_Youth_Access_20241028.csv"
results <- run_analysis(file_path)

# Print top 10 states with highest expected stringency
print("Top 10 States with Highest Expected Stringency in the Next Year:")
print(results$top_10_states)

# Plot top 10 states
ggplot(results$top_10_states, aes(x = reorder(State, -Future_Stringency), y = Future_Stringency)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme_minimal() +
  labs(title = "Top 10 States with Highest Expected Stringency",
       x = "State",
       y = "Expected Stringency Score") +
  coord_flip()

