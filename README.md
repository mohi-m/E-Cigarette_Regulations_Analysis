# E-Cigarette Policy Analysis
A data-driven analysis of e-cigarette policy stringency and compliance across U.S. states, leveraging time series forecasting and statistical modeling.
Overview
This project examines the evolution of e-cigarette policies and predicts future trends in policy stringency across different U.S. states. Through ARIMA modeling and statistical analysis, we provide insights into policy development patterns and identify regions prone to compliance issues.
Features
Time series analysis using ARIMA models
Policy stringency scoring system
Interactive visualizations
Geographic compliance analysis
Future trend predictions

## Installation

```bash
## Clone the repository
git clone [repository-url]

# Install required packages
install.packages(c("dplyr", "forecast", "ggplot2", "lubridate", "gridExtra"))
```
## Usage
```R
# Run the main analysis 
source("src/Analysis_Script.R")

# Execute analysis with your dataset
results <- run_analysis("path/to/your/data.csv")
```


## Project Structure
```text
├── data/
│   └── CDC_STATE_System_E-Cigarette_Legislation.csv
├── src/
│   └── Analysis_Script.R
├── plots/
│   ├── Top_5_states.png
│   └── Top_10_states.png
├── output/
│   └── runtime_logs.txt
└── README.md
```

## Visualizations
#### Top 10 States by Policy Stringency
![Top_10_states](plots\Top_10_states.png)

#### Time Series Forecasts for Top States
![Top_5_states_time_series](plots\Top_5_states_time_series.png)

The time series plots show forecasted trends with confidence intervals (shaded areas) for key states:
- Washington exhibits stable high stringency with potential for increase
- Iowa maintains consistent policy levels
- Texas shows a stepped increase pattern
- Idaho demonstrates recent policy strengthening
- Montana displays steady stringency levels

## Key Findings
- **Washington leads in expected policy stringency, followed by Iowa and Texas**
- **Most states show an upward trend in policy stringency**
- **Geographic patterns emerge in compliance rates**
- **Time series forecasts indicate continued strengthening of regulations**

## Data Source
The dataset comes from the CDC's State Tobacco Activities Tracking and Evaluation (STATE) System, covering:
- State-level legislative actions
- Youth access regulations
- Enforcement practices
- Historical policy data (1995-2024)

## Contributing
1. Fork the repository
2. Create your feature branch ```git checkout -b feature/improvement```
3. Commit changes ```git commit -am 'Add improvement'```
4. Push to branch ```git push origin feature/improvement```
5. Open a Pull Request

## Acknowledgments
Special thanks to the **_Centers for Disease Control and Prevention (CDC)_** for providing the comprehensive dataset through their **_STATE_** System and **_Prof. Yang Wang_** on providing valuable guidance.