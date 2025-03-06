# Technical Documentation of Analysis Pipeline

## Dataset Overview
The analysis is performed on a dataset containing information about Upskilling (US) and Reskilling (RS) programs, stored in "V1_qualflags_analysis2_ML.dta".

## 1. XGBoost Feature Analysis (`01_xgboost_feature_analysis.py`)

### Data Used
- **Full Dataset Analysis:**
  - All variables including dummy variables
  - Target variable: Program type (Reskilling = 1, Upskilling = 0)
- **Program Characteristics Analysis:**
  - Only variables with prefix 'p_'
  - Excludes outcome variables

### Key Results
- Model Performance:
  - Training AUC: 0.964
  - Validation AUC: 0.884
- Precision: 0.743
- Recall: 0.690
- F1 Score: 0.716

### Visualizations
- SHAP summary plots for top 10 and 20 features
- Feature importance bar plots
- ROC curves

## 2. UMAP Clustering (`02_umap_clustering.py`)

### Data Used
- Program-specific variables (prefix 'p_')
- Excludes outcome variables
- Data is preprocessed using dummy variables

### Analysis Steps
1. UMAP dimensionality reduction
2. K-means clustering with k=2 and k=3
3. Cluster evaluation using:
   - Elbow method
   - Silhouette scores

### Results
- **2-Cluster Solution:**
  - Cluster 0: 80 programs
  - Cluster 1: 100 programs
- **3-Cluster Solution:**
  - Cluster 0: 60 programs
  - Cluster 1: 70 programs
  - Cluster 2: 50 programs

### Visualizations
- UMAP 2D projections with cluster colorings
- Elbow plot
- Silhouette score plot

## 3. Cluster Statistical Tests (`03_cluster_statistical_tests.py`)

### Data Used
Two separate analyses are performed:
1. **With Dummy Variables:**
   - All program characteristics
   - Binary encoded categorical variables
2. **Without Dummy Variables:**
   - Only continuous variables
   - Original categorical variables

### Analyses Performed
For each clustering solution (2 and 3 clusters):
- ANOVA tests (3 clusters)
- T-tests (2 clusters)
- Mean comparisons
- Standard deviation calculations

### Results
Four distinct results tables are generated:
1. 2-cluster analysis with dummy variables
2. 2-cluster analysis without dummy variables
3. 3-cluster analysis with dummy variables
4. 3-cluster analysis without dummy variables

Each table includes:
- Feature names
- Mean and SD for each cluster
- P-values from statistical tests

## 4. Program Feature Analysis (`Feature_Importance_Program_Chars.py`)

### Data Used
- Only program characteristics (prefix 'p_')
- Excludes all outcome variables
- Variables described in label_mapping dictionary

### Analysis
- XGBoost classifier focusing on program features
- SHAP analysis for feature importance
- Cross-validation for model evaluation

### Results
- Model Performance:
  - AUC score: 0.779
  - Precision: 0.736
  - Recall: 0.690
  - F1 Score: 0.712

### Top Features
1. dd_design_board (0.113)
2. k_review_emp (0.032)
3. inc_wrk_job (0.031)
[Complete list in results]

### Visualizations
- SHAP summary plots
- Feature importance rankings
- ROC curve

## Notes on Reproducibility
- Random seed set to 42 across all analyses
- Train/test split ratio: 80/20
- Validation set split: 20% of training data