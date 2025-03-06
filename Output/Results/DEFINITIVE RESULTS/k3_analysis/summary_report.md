# Comprehensive Statistical Analysis

## Dataset Summary

- Total programs analyzed: 1125
- Number of clusters: 3

### Program Type Distribution

- Upskilling programs: 458
- Reskilling programs: 667

### Program Type Distribution by Cluster

| Cluster | Upskilling | Reskilling | Total |
|---------|------------|------------|-------|
| 0 | 80 | 123 | 203 |
| 1 | 124 | 147 | 271 |
| 2 | 254 | 397 | 651 |

## Top 10 Variables Differentiating Clusters

| Variable | Cluster 0 | Cluster 1 | Cluster 2 | p-value | Significance |
|---------|---------|---------|---------|---------|-------------|
| p_target_middleemp | 0.23 | 0.24 | 0.73 | 0.0000 | *** |
| p_target_emp | 0.31 | 0.30 | 0.91 | 0.0000 | *** |
| p_participated_coarse | 2.71 | 1.92 | 1.80 | 0.0000 | *** |
| p_targetemp_emp_Selected | 0.31 | 0.30 | 0.91 | 0.0000 | *** |
| p_targetemp_emp_Not Selected | 0.69 | 0.70 | 0.09 | 0.0000 | *** |
| p_participated_coarse==     3.0000 | 0.79 | 0.15 | 0.25 | 0.0000 | *** |
| p_targetfunc_cust_Not Selected | 0.86 | 0.87 | 0.46 | 0.0000 | *** |
| p_targetfunc_cust_Selected | 0.14 | 0.13 | 0.54 | 0.0000 | *** |
| p_target_all | 0.14 | 0.01 | 0.41 | 0.0000 | *** |
| p_year_end_Ongoing | 0.33 | 0.25 | 0.67 | 0.0000 | *** |

## Top 10 Variables Differentiating Program Types

| Variable | Upskilling | Reskilling | Cohen's d | p-value | Significance |
|---------|-----------|-----------|-----------|---------|-------------|
| Challenge - Ensuring that participants could find a new job | 0.00 | 0.30 | 0.86 | 0.0000 | *** |
| p_hours_long | 0.36 | 0.53 | 0.34 | 0.0000 | *** |
| p_target_topmiddle | 0.33 | 0.47 | 0.29 | 0.0000 | *** |
| p_effect_reverse | 2.45 | 2.59 | 0.28 | 0.0000 | *** |
| p_adv_hr | 0.44 | 0.57 | 0.25 | 0.0001 | *** |
| Union | 9.23 | 12.19 | 0.24 | 0.0001 | *** |
| Criteria - Pre-assessment of motivation | 0.14 | 0.23 | 0.23 | 0.0001 | *** |
| p_year_end_clone2 | 2022.53 | 2022.70 | 0.24 | 0.0002 | *** |
| p_target_all | 0.21 | 0.30 | 0.22 | 0.0003 | *** |
| p_long | 0.27 | 0.37 | 0.21 | 0.0005 | *** |

## Program Type Differentiation Within Clusters


### Cluster 0

| Variable | Upskilling | Reskilling | Cohen's d | p-value | Significance |
|---------|-----------|-----------|-----------|---------|-------------|
| Challenge - Ensuring that participants could find a new job | 0.00 | 0.30 | 0.84 | 0.0000 | *** |
| p_effect_reverse | 2.44 | 2.72 | 0.60 | 0.0001 | *** |
| p_participated_coarse==     3.0000 | 0.86 | 0.75 | -0.28 | 0.0393 | * |
| p_resp_top | 0.26 | 0.40 | 0.29 | 0.0423 | * |
| p_participated_coarse | 2.81 | 2.65 | -0.27 | 0.0484 | * |

### Cluster 1

| Variable | Upskilling | Reskilling | Cohen's d | p-value | Significance |
|---------|-----------|-----------|-----------|---------|-------------|
| Challenge - Ensuring that participants could find a new job | 0.00 | 0.34 | 0.97 | 0.0000 | *** |
| p_year_start_clone2 | 2020.46 | 2021.06 | 0.54 | 0.0000 | *** |
| p_target_middle | 0.49 | 0.72 | 0.48 | 0.0001 | *** |
| p_year_end_clone2 | 2022.10 | 2022.50 | 0.47 | 0.0002 | *** |
| p_hours_long | 0.23 | 0.42 | 0.42 | 0.0005 | *** |

### Cluster 2

| Variable | Upskilling | Reskilling | Cohen's d | p-value | Significance |
|---------|-----------|-----------|-----------|---------|-------------|
| Challenge - Ensuring that participants could find a new job | 0.00 | 0.29 | 0.82 | 0.0000 | *** |
| p_hours_long | 0.31 | 0.49 | 0.38 | 0.0000 | *** |
| Employer | 76.04 | 64.64 | -0.36 | 0.0000 | *** |
| p_target_all | 0.31 | 0.47 | 0.34 | 0.0000 | *** |
| p_target_topbottom | 0.33 | 0.49 | 0.34 | 0.0000 | *** |

## Top 10 Most Important Variables for Program Type Prediction

| Variable | Importance |
|---------|------------|
| Challenge - Ensuring that participants could find a new job | 0.0526 |
| p_roi_Negative ROI | 0.0461 |
| p_eligibility | 0.0292 |
| p_part_exp | 0.0285 |
| p_part | 0.0270 |
| Employer | 0.0226 |
| Government | 0.0171 |
| Employee | 0.0163 |
| p_roi_Not yet_ but intends to | 0.0160 |
| p_year_start_clone2 | 0.0143 |
