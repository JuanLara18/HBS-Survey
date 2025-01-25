# Documentation

## Objective
This project aims to analyze differences between **Upskilling (US)** and **Reskilling (RS)** programs using machine learning (ML), clustering, and statistical validation techniques.

---

## 1. `01_xgboost_feature_analysis.ipynb`

### Objective:
Identify the most important features differentiating US and RS programs using XGBoost and SHAP.

### Methods:
1. **Data used:**
   - All available data (dummy and categorical variables).
   - Separate analysis excluding outcomes (program characteristics with prefix `p_`).
2. **Model:**
   - XGBoost classifier with cross-validation.
   - Metrics: AUC-ROC to evaluate performance.
3. **Interpretability:**
   - SHAP for feature importance analysis.

### Results:
- **AUC-ROC:**
  - Training: 0.964
  - Validation: 0.884
- **Key features:**
  - Negative ROI: Strongest predictor of US.
  - Cross-departmental networks: Consistently important for both.
  - Higher eligibility criteria: Strongly linked to RS.
- **Outputs:**
  - SHAP importance plots (Top 10 and 20 features).

---

## 2. `02_umap_clustering.ipynb`

### Objective:
Perform dimensionality reduction using UMAP and cluster analysis with K-means.

### Methods:
1. **Data used:**
   - Program-specific variables (`p_`) without outcomes.
2. **Techniques:**
   - UMAP for 2D projection.
   - K-means for clustering (2 and 3 clusters).
   - Optimal number of clusters checked using:
     - Elbow method.
     - Silhouette score.

### Results:
- **Cluster descriptions:**
  - **2 clusters:** Basic vs Advanced programs.
  - **3 clusters:** Basic, Intermediate, and Advanced programs.
- **Cluster characteristics:**
  - Basic: Short programs, limited funding, fewer KPIs.
  - Intermediate: Balance of funding and duration.
  - Advanced: Long programs, high funding, multiple KPIs.
- **Outputs:**
  - UMAP scatterplots for cluster visualization.

---

## 3. `03_cluster_statistical_tests.ipynb`

### Objective:
Statistically validate the clusters identified in the previous file.

### Methods:
1. **Data used:**
   - Program-specific variables (`p_`), excluding outcomes.
2. **Statistical tests:**
   - **ANOVA:** For differences across 3 clusters.
   - **T-tests:** For pairwise comparisons between 2 clusters.

### Results:
- **Significant variables:**
  - Program duration, funding, and eligibility.
- **P-values:**
  - Clear statistical differences across clusters, validating the results.
- **Outputs:**
  - Tables summarizing means, standard deviations, and p-values for key variables.

---

## 4. `04_program_feature_analysis.ipynb`

### Objective:
Explore specific program features and their impact on US vs RS classification.

### Methods:
1. **Data used:**
   - Program characteristics (`p_`) only, excluding outcomes.
2. **Analysis:**
   - Detailed examination of feature distributions between US and RS.

### Results:
- **Reskilling programs (RS):**
  - Longer duration, higher eligibility, and use of certifications.
- **Upskilling programs (US):**
  - Shorter duration, fewer participants, more incentives for managers.
- **Outputs:**
  - Boxplots and histograms comparing key features.

---

## 5. `Feature_Importance_Program_Chars.ipynb`

### Objective:
Re-run feature importance analysis, excluding all outcome variables.

### Methods:
1. **Data used:**
   - Only program-specific characteristics (`p_`).
2. **Model:**
   - XGBoost with SHAP analysis for interpretability.

### Results:
- **Key features:**
  - Program duration: Critical for RS.
  - Manager incentives: Highly relevant for US.
- **Outputs:**
  - SHAP plots showing feature importance without outcomes.

---

## Summary of Leila’s Key Points

### ML Models (Feature Importance with SHAP):
- Results for **all data** (dummy + categorical) and **only program characteristics** (`p_`).
- Feature importance clearly identifies key predictors for US and RS programs.

### Unsupervised Clustering:
- **Optimal number of clusters:**
  - Evaluated using the elbow method and silhouette scores.
- Overlay of US and RS programs within clusters.

### Descriptive Statistics:
- For each cluster:
  - **Mean, Standard Deviation, and P-value** from t-tests.
- Clear differences in funding, duration, and KPIs validate clusters.

---

## Next Steps
1. Finalize results into formatted tables (e.g., LaTeX or Markdown for GitHub).
2. Add overlay of US and RS labels to cluster visualizations.
3. Review interaction effects between features for deeper insights.

