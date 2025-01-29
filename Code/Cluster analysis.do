/*==============================================================================
Project: Upskilling vs Reskilling Analysis
Description: Clustering analysis of program characteristics
Author: Juan Lara
Date: January 2025
==============================================================================*/

* Set working directory to project root and preferences
clear all
set more off
cd ".."  // Move up one level from Code directory

/*------------------------------------------------------------------------------
Import and Prepare Data
------------------------------------------------------------------------------*/
use "Data/V1_qualflags_analysis2_ML.dta", clear

* Keep only program-related variables and program type
ds p_*
local program_vars `r(varlist)'
keep program `program_vars'

* Create dummy for program type (1 = Reskilling, 0 = Upskilling)
gen program_type = (program == "Reskilling")
label var program_type "Reskilling=1, Upskilling=0"

/*------------------------------------------------------------------------------
Data Cleaning and Preprocessing
------------------------------------------------------------------------------*/
* Check for missing values
misstable summarize

* Handle missing values (replace with means for continuous, mode for categorical)
foreach var of varlist `program_vars' {
    * For continuous variables
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = round(r(mean)) if missing(`var')
    }
    * For categorical variables
    else {
        replace `var' = mode if missing(`var')
    }
}

/*------------------------------------------------------------------------------
Perform Clustering Analysis
------------------------------------------------------------------------------*/
* Try different numbers of clusters (2-4)
forvalues k = 2/4 {
    cluster kmed `program_vars', k(`k') name(prog_clus`k') measure(abs) start(lastk)
}

* Evaluate cluster quality
cluster stop prog_clus2, rule(calinski)
cluster stop prog_clus3, rule(calinski)
cluster stop prog_clus4, rule(calinski)

/*------------------------------------------------------------------------------
Create Variables for Analysis
------------------------------------------------------------------------------*/
* Generate cluster membership variables
forvalues k = 2/4 {
    tab prog_clus`k', gen(cluster`k'_)
}

* Label clusters consistently with Python analysis
label define prog_clusters2 1 "Basic Programs" 2 "Advanced Programs"
label values prog_clus2 prog_clusters2

label define prog_clusters3 1 "Basic" 2 "Intermediate" 3 "Advanced"
label values prog_clus3 prog_clusters3

/*------------------------------------------------------------------------------
Statistical Analysis
------------------------------------------------------------------------------*/
* Cross-tabulation with program type
foreach k in 2 3 4 {
    di "Analysis for `k' clusters:"
    tab program prog_clus`k', chi2
}

* Calculate means by cluster
local stat_vars "p_program_length p_hourstrained p_cost p_part p_eligibility"
foreach k in 2 3 {
    di "Mean characteristics for `k' clusters:"
    table prog_clus`k', contents(mean `stat_vars') format(%9.2f)
}

/*------------------------------------------------------------------------------
Export Results
------------------------------------------------------------------------------*/
* Save cluster assignments
preserve
    keep program prog_clus2 prog_clus3 prog_clus4
    export delimited using "Output/Results/stata_cluster_assignments.csv", replace
restore

* Export summary statistics
putexcel set "Output/Results/stata_cluster_analysis.xlsx", replace
putexcel A1 = "Cluster Analysis Results"
putexcel A2 = "2-Cluster Solution"
putexcel A3 = matrix(r(table_2))
putexcel A10 = "3-Cluster Solution"
putexcel A11 = matrix(r(table_3))

/*------------------------------------------------------------------------------
Generate Visualizations
------------------------------------------------------------------------------*/
* Create directories for Stata visualizations if they don't exist
!mkdir "Output/Figures/stata_analysis"

* Boxplots of key characteristics by cluster
foreach var of local stat_vars {
    graph box `var', over(prog_clus2) title("Distribution of `var' by Cluster")
    graph export "Output/Figures/stata_analysis/`var'_by_cluster2.png", replace
}

* Save workspace
save "Output/Results/stata_clustering_results.dta", replace

exit