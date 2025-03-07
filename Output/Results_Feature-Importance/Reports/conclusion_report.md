# Feature Importance Analysis: Conclusions

## Key Findings

- The model with the best overall performance (AUC) is: **All variables (with outcomes)**

- The use of categorical variables with encoding resulted in a **better** performance than using dummies:
  - AUC with categorical encoding: 0.7832
  - AUC with dummies: 0.7526

- Including outcome variables results in an **deterioration** of the model:
  - AUC with outcome variables: 0.7938
  - AUC without outcome variables: 0.7938

This analysis demonstrates the importance of feature selection and categorical variable encoding in model performance for distinguishing between Upskilling and Reskilling programs.

## Top Features

The top 5 most important features for distinguishing between program types are:

1. **Union Share 1-25%** (importance: 229.0000)
2. **Manager Incentive - Other Form of Recognition** (importance: 163.0000)
3. **Selection Criteria: Assessment of Skills** (importance: 146.0000)
4. **Firm Size (Numeric)** (importance: 137.0000)
5. **Firm Size: 2500-9999** (importance: 134.0000)
