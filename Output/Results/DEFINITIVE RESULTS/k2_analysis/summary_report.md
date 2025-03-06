# Comprehensive Statistical Analysis

## Dataset Summary

- Total programs analyzed: 1125
- Number of clusters: 2

### Program Type Distribution

- Upskilling programs: 458
- Reskilling programs: 667

### Program Type Distribution by Cluster

| Cluster | Upskilling | Reskilling | Total |
|---------|------------|------------|-------|
| 0 | 216 | 250 | 466 |
| 1 | 242 | 417 | 659 |

## Top 10 Variables Differentiating Clusters

| Variable | Cluster 0 | Cluster 1 | p-value | Significance |
|---------|---------|---------|---------|-------------|
| p_target_top | 0.25 | 0.80 | 0.0000 | *** |
| p_participated_coarse | 1.51 | 2.34 | 0.0000 | *** |
| p_participated_coarse==     1.0000 | 0.63 | 0.12 | 0.0000 | *** |
| p_part | 41.94 | 65.89 | 0.0000 | *** |
| p_target_topmiddle | 0.17 | 0.59 | 0.0000 | *** |
| p_part_exp | 53.18 | 74.05 | 0.0000 | *** |
| Employer | 75.42 | 46.45 | 0.0000 | *** |
| p_ongoing | 0.74 | 0.34 | 0.0000 | *** |
| Union | 5.31 | 15.00 | 0.0000 | *** |
| p_eligibility | 51.36 | 67.39 | 0.0000 | *** |

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
| Challenge - Ensuring that participants could find a new job | 0.00 | 0.20 | 0.67 | 0.0000 | *** |
| p_hours_long | 0.21 | 0.34 | 0.28 | 0.0021 | ** |
| p_long | 0.20 | 0.32 | 0.26 | 0.0041 | ** |
| Criteria - Pre-assessment of motivation | 0.16 | 0.26 | 0.24 | 0.0083 | ** |
| Challenge - Selecting the right participants | 0.38 | 0.48 | 0.21 | 0.0222 | * |

### Cluster 1

| Variable | Upskilling | Reskilling | Cohen's d | p-value | Significance |
|---------|-----------|-----------|-----------|---------|-------------|
| Challenge - Ensuring that participants could find a new job | 0.00 | 0.37 | 0.96 | 0.0000 | *** |
| p_target_middle | 0.64 | 0.84 | 0.47 | 0.0000 | *** |
| p_target_topmiddle | 0.46 | 0.66 | 0.41 | 0.0000 | *** |
| p_year_end_clone2 | 2022.36 | 2022.65 | 0.38 | 0.0000 | *** |
| p_cha_takeup | 0.36 | 0.52 | 0.34 | 0.0000 | *** |

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
