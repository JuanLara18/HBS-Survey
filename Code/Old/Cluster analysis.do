/*==============================================================================
Project: Upskilling vs Reskilling Analysis
Description: Clustering analysis of program characteristics
Author: Juan Lara
Date: January 2025
==============================================================================*/

clear all
set more off

/*------------------------------------------------------------------------------
Import and Prepare Data
------------------------------------------------------------------------------*/
use "Data/V1_qualflags_analysis2_ML.dta", clear

* Examine program variable
describe program
tab program

* Keep only program-related variables and program type
ds p_*
local program_vars `r(varlist)'
keep program `program_vars'

* Create program type indicator using numeric values
gen program_type = (program == 3) if !missing(program)
label var program_type "Program Type (1=Reskilling, 0=Upskilling)"

* Drop General programs (program == 1)
drop if program == 1

/*------------------------------------------------------------------------------
Data Cleaning and Preprocessing
------------------------------------------------------------------------------*/
* Check for missing values
misstable summarize

* Handle missing values - Modified to handle long variable names
foreach var of varlist `program_vars' {
    * For numeric variables
    capture confirm numeric variable `var'
    if !_rc {
        * Create shortened version of variable name for mean calculation
        local shortname = substr("`var'", 1, 20)
        egen mean_`shortname' = mean(`var')
        replace `var' = mean_`shortname' if missing(`var')
        drop mean_`shortname'
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
    tabstat `stat_vars', by(prog_clus`k') stat(mean sd n) col(stat)
}

foreach var of local stat_vars {
    di "ANOVA for `var'"
    oneway `var' prog_clus2, tabulate
}

foreach var of local stat_vars {
    graph box `var', over(prog_clus2) title("`var' by Cluster")
    graph export "cluster_`var'.png", replace
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

/*------------------------------------------------------------------------------
Export Data for UMAP Analysis
------------------------------------------------------------------------------*/
* After clustering analysis but before visualizations
preserve
    * Keep relevant variables
    keep program_type prog_clus2 prog_clus3 prog_clus4 `program_vars'
    
    * Export for Python
    export delimited using "Results/temp_data_for_umap.csv", replace
restore

* Run Python script for UMAP
********************************************************************************
********************************************************************************
* shell python Code/dimension_reduction.py
********************************************************************************
********************************************************************************

/*------------------------------------------------------------------------------
Import and Visualize UMAP Results
------------------------------------------------------------------------------*/
* Import UMAP coordinates
preserve
    * Import the data
    import delimited "Results/umap_coordinates.csv", clear varnames(1)
    
    * Create scatter plots using UMAP coordinates
    * By Program Type
    twoway (scatter umap2 umap1 if program_type==0, mcolor(blue%50)) ///
           (scatter umap2 umap1 if program_type==1, mcolor(red%50)), ///
           title("UMAP Projection by Program Type") ///
           subtitle("Unsupervised Clustering Results") ///
           xtitle("UMAP Dimension 1") ///
           ytitle("UMAP Dimension 2") ///
           legend(order(1 "Upskilling" 2 "Reskilling")) ///
           scheme(s2color)
    graph export "Output/Figures/stata_analysis/umap_by_program_stata.png", replace
    
    * By Cluster Solutions
    foreach k in 2 3 4 {
        * Get unique values for coloring
        levelsof cluster`k', local(levels)
        local scatter_commands ""
        local legend_order ""
        local i = 1
        
        foreach l of local levels {
            local scatter_commands "`scatter_commands' (scatter umap2 umap1 if cluster`k'==`l', mcolor("`=`i'+1'"*%50))"
            local legend_order "`legend_order' `i' "`l'""
            local ++i
        }
        
        twoway `scatter_commands', ///
            title("UMAP Projection with `k' Clusters") ///
            subtitle("Cluster Analysis Results") ///
            xtitle("UMAP Dimension 1") ///
            ytitle("UMAP Dimension 2") ///
            legend(order(`legend_order')) ///
            scheme(s2color)
        graph export "Output/Figures/stata_analysis/umap_cluster`k'_stata.png", replace
    }
restore

exit