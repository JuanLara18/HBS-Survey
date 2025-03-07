# Feature Importance Analysis: Conclusions

## Key Findings

- The model with the best overall performance (AUC) is: **All variables (with outcomes)**

- The use of categorical variables with encoding resulted in a **better** performance than using dummies:
  - AUC with categorical encoding: 0.7832
  - AUC with dummies: 0.7526

- Including outcome variables results in an **improvement** of the model:
  - AUC with outcome variables: 0.9133
  - AUC without outcome variables: 0.7956

This analysis demonstrates the importance of feature selection and categorical variable encoding in model performance for distinguishing between Upskilling and Reskilling programs.

## Top Features

The top 5 most important features for distinguishing between program types are:

1. **ROI Measured** (importance: 330.0000)
2. **Negative ROI** (importance: 287.0000)
3. **External Redeployment** (importance: 172.0000)
4. **Cross-departmental Networks** (importance: 140.0000)
5. **Union Share 1-25%** (importance: 137.0000)
