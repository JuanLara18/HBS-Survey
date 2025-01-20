# Survey

## Upskilling vs Reskilling Programs Analysis

Analysis of implementation patterns and quality differences between upskilling and reskilling programs using machine learning and statistical approaches.

## Repository Structure

```
├── Codes/
│   ├── Old/
│   │   ├── 1_all_variables_analysis.ipynb
│   │   ├── 2_clustering_analysis.ipynb
│   │   ├── 3_statistical_analysis.ipynb
│   │   └── 4_program_characteristics.ipynb
│   ├── 01_xgboost_feature_analysis.ipynb
│   ├── 02_umap_clustering.ipynb
│   ├── 03_cluster_statistical_tests.ipynb
│   └── 04_program_feature_analysis.ipynb
├── Data/
│   └── V1_qualflags_analysis2_ML.dta
└── Output/
    ├── Figures/
    ├── Models/
    └── Results/
```

## Analysis Pipeline

1. **01_xgboost_feature_analysis.ipynb**: Comprehensive XGBoost and SHAP analysis to identify key features distinguishing between upskilling and reskilling programs
   
2. **02_umap_clustering.ipynb**: UMAP dimensionality reduction followed by K-means clustering (2 and 3 clusters) to identify natural groupings in the data

3. **03_cluster_statistical_tests.ipynb**: Statistical validation through ANOVA (3-clusters) and t-tests (2-clusters) with density plot visualizations

4. **04_program_feature_analysis.ipynb**: Focused analysis on program-specific characteristics using filtered variable sets