# Survey

## Upskilling vs Reskilling Programs Analysis

This repository contains an analysis of implementation patterns and quality differences between upskilling and reskilling programs. The analysis combines machine learning, statistical techniques, and clustering approaches to extract actionable insights.

## Repository Structure

```
├── Code/
│   ├── Old/
│   │   ├── 1_all_data.ipynb             
│   │   ├── 2_cluster_data_creation.ipynb 
│   │   ├── 3_Clusters_Complete_Analysis.ipynb  
│   │   ├── 4_program_characteristics.ipynb 
│   └── 
│   ├── 01_xgboost_feature_analysis.ipynb  # Feature importance analysis using XGBoost and SHAP values
│   ├── 02_umap_clustering.ipynb           # UMAP dimensionality reduction and K-means clustering
│   ├── 03_cluster_statistical_tests.ipynb # Statistical testing for cluster validation (ANOVA, t-tests)
│   └── 04_program_feature_analysis.ipynb  # Focused analysis on program-specific variables
├── Data/
│   └── V1_qualflags_analysis2_ML.dta      # Input dataset for machine learning and statistical analysis
├── Output/
│   ├── Figures/
│   │   ├── 2_clusters/                    # Visualizations for 2-cluster analysis
│   │   └── 3_clusters/                    # Visualizations for 3-cluster analysis
│   ├── Models/                            
│   └── Results/                           # Results of clustering and statistical tests
└── README.md                              
```

## Analysis Pipeline

1. **01_xgboost_feature_analysis.ipynb**:
   - Uses XGBoost and SHAP values to identify the most important features differentiating upskilling and reskilling programs.
   - Includes feature selection and iterative model refinement.

2. **02_umap_clustering.ipynb**:
   - Applies UMAP for dimensionality reduction.
   - Conducts K-means clustering to explore natural groupings (2 and 3 clusters).

3. **03_cluster_statistical_tests.ipynb**:
   - Performs statistical validation of clusters.
   - Uses ANOVA for 3-cluster solutions and t-tests for 2-cluster solutions.
   - Generates density plots and summary statistics.

4. **04_program_feature_analysis.ipynb**:
   - Focuses on specific program-related characteristics.
   - Analyzes filtered variable sets to draw meaningful conclusions about program implementation patterns.

5. **Old Notebooks**:
   - **1_all_data.ipynb**: Initial exploratory analysis covering all variables.
   - **2_cluster_data_creation.ipynb**: Prepares data for clustering, including feature engineering and cleaning.
   - **3_Clusters_Complete_Analysis.ipynb**: Comprehensive analysis of 3-cluster solutions, integrating multiple methods.
   - **4_program_characteristics.ipynb**: Detailed exploration of program characteristics and their statistical relationships.

## Key Outputs

- **Figures**: Visualizations for cluster analysis and feature importance.
- **Models**: Saved machine learning models for reproducibility.
- **Results**: Cluster assignments, statistical summaries, and key metrics.

## How to Use

1. Clone the repository and set up the required environment.
   ```bash
   git clone <repository-url>
   cd HBS-SURVEY
   pip install -r requirements.txt
   ```
2. Explore the notebooks in the `Code/` directory for detailed analyses.
3. Review outputs in the `Output/` directory for visualizations, models, and results.