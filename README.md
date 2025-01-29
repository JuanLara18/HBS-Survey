# Survey: Upskilling Vs Reskilling Programs

This repository contains an analysis of implementation patterns and quality differences between upskilling and reskilling programs. The analysis combines machine learning techniques, statistical analysis, and clustering approaches to extract actionable insights about program characteristics and effectiveness.

## Repository Structure

```
├── Code/
│   ├── Old/
│   │   ├── 1_all_data.ipynb
│   │   ├── 2_cluster_data_creation.ipynb
│   │   ├── 3_Clusters_Complete_Analysis.ipynb
│   │   └── 4_program_characteristics.ipynb
│   ├── 01_xgboost_feature_analysis.ipynb
│   ├── 02_umap_clustering.ipynb
│   ├── 03_cluster_statistical_tests.ipynb
│   ├── 04_program_feature_analysis.ipynb
│   ├── Cluster analysis.do
│   ├── Feature_Importance_Program_Chars.ipynb
│   └── Update_labels.ipynb
├── Data/
│   └── V1_qualflags_analysis2_ML.dta
├── Output/
│   ├── Figures/
│   │   ├── 2_clusters/
│   │   │   ├── all_vars/
│   │   │   └── no_dummies/
│   │   ├── 3_clusters/
│   │   │   ├── all_vars/
│   │   │   └── no_dummies/
│   │   ├── None_clusters/
│   │   │   └── all_vars/
│   │   ├── cluster_program_distribution.csv
│   │   ├── cluster_program_distribution.png
│   │   └── umap_cluster_program_comparison.png
│   ├── Models/
│   └── Results/
│       ├── clusters_2_construction.csv
│       └── clusters_3_construction.csv
├── Documentation.md
└── README.md
```

## Analysis Components

1. **XGBoost Feature Analysis**: The analysis begins with `01_xgboost_feature_analysis.ipynb`, which implements XGBoost classification to identify key features that differentiate upskilling and reskilling programs. This notebook integrates SHAP values for feature importance interpretation and includes comprehensive model validation.

2. **UMAP Clustering Analysis**: Through `02_umap_clustering.ipynb`, the analysis performs dimensionality reduction using UMAP and applies K-means clustering to identify natural groupings in the data. The notebook explores both 2-cluster and 3-cluster solutions.

3. **Statistical Analysis**: The `03_cluster_statistical_tests.ipynb` notebook conducts rigorous statistical validation of the clustering results, employing ANOVA for 3-cluster solutions and t-tests for 2-cluster solutions. The analysis includes both dummy and non-dummy variable approaches.

4. **Program Feature Analysis**: Using `04_program_feature_analysis.ipynb`, the analysis focuses on program-specific characteristics, examining funding patterns, participation metrics, and program effectiveness indicators.

5. **Additional Analyses**: 
   - `Feature_Importance_Program_Chars.ipynb`: Provides detailed analysis of program characteristics
   - `Update_labels.ipynb`: Manages and updates variable labels
   - `Cluster analysis.do`: Implements additional clustering analysis in Stata

## Output Structure

The analysis generates several types of outputs organized in the Output directory:

1. **Figures**: Located in `Output/Figures/`, containing:
   - Two-cluster analysis visualizations (with and without dummy variables)
   - Three-cluster analysis visualizations (with and without dummy variables)
   - General cluster comparisons and distributions
   - UMAP projections and feature importance plots

2. **Results**: Found in `Output/Results/`, including:
   - Cluster assignments for both 2-cluster and 3-cluster solutions
   - Detailed construction data for each clustering approach

## Installation and Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/JuanLara18/HBS-Survey
   cd HBS-Survey
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Explore the analysis:
   - Start with the Jupyter notebooks in the `Code/` directory for interactive analysis
   - Review results and visualizations in the `Output/` directory
   - Consult `Documentation.md` for technical details and methodology

The analysis documentation and methodology details are available in `Documentation.md`, providing comprehensive information about the dataset, analysis procedures, and interpretation guidelines.