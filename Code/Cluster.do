/*---------------------------
   1. Setup and Data Loading
---------------------------*/
clear all
set more off

capture log close
log using "../Output/Results/Program_Clustering_Analysis.log", replace

use "../Data/V1_qualflags_analysis2.dta", clear
display "Dataset loaded with " c(N) " observations and " c(k) " variables."

/*---------------------------
   2. Identify & Prepare Variables
---------------------------*/
// Identify program characteristic variables (starting with "p_")
ds p_*
local pvars `r(varlist)'

local num_pvars : word count `pvars'
display "Found " `num_pvars' " program characteristic variables."

// Select variables with fewer than 100 missing values
local key_p_vars ""
foreach var of local pvars {
    capture confirm numeric variable `var'
    if !_rc {
        quietly count if missing(`var')
        if r(N) < 100 {
            local key_p_vars "`key_p_vars' `var'"
        }
    }
}
local key_count : word count `key_p_vars'
display "Selected " `key_count' " key p_* variables with few missings."

// Drop observations with missing values in any key variable
foreach var of local key_p_vars {
    drop if missing(`var')
}
display "After dropping missings, dataset has " c(N) " observations."

// Standardize key variables and create short names (z1, z2, …)
local zvar_list ""
local i = 1
foreach var of local key_p_vars {
    quietly summarize `var'
    gen z`i' = (`var' - r(mean)) / r(sd)
    label var z`i' "Std `var'"
    local zvar_list "`zvar_list' z`i'"
    local i = `i' + 1
}
local zcount : word count `zvar_list'
display "Created " `zcount' " standardized variables for clustering."

// Save the current dataset (with standardized variables)
tempfile origdata
save `origdata', replace

/*---------------------------
   3. Determine Optimal Number of Clusters using Multiple Methods
---------------------------*/
// 3.1 Calinski-Harabasz (CH) Index
tempfile chresults
postfile chfile int(k) double(ch_index) using `chresults', replace
forvalues k = 2/8 {
    cluster kmed `zvar_list', k(`k') name(kmed_`k') measure(abs) start(random)
    cluster stop kmed_`k', rule(calinski)
    post chfile (`k') (r(calinski))
}
postclose chfile

// 3.2 Duda-Hart Index
tempfile dhresults
postfile dhfile int(k) double(duda) double(hart) using `dhresults', replace
forvalues k = 2/8 {
    capture cluster stop kmed_`k', rule(duda)
    if !_rc {
        post dhfile (`k') (r(duda)) (r(pseudot2))
    }
    else {
        post dhfile (`k') (.) (.)
    }
}
postclose dhfile

// 3.3 Elbow Method (Within-Cluster Sum of Squares)
tempfile wssresults
postfile wssfile int(k) double(wss) using `wssresults', replace
forvalues k = 2/8 {
    // Calculate within-cluster sum of squares
    quietly {
        local total_wss = 0
        forvalues j = 1/`k' {
            // Count observations in this cluster
            count if kmed_`k' == `j'
            if r(N) > 0 {
                // Get cluster centroid
                foreach var of local zvar_list {
                    summarize `var' if kmed_`k' == `j', meanonly
                    local cent_`var' = r(mean)
                }
                
                // Calculate sum of squares for this cluster
                gen double temp_ss = 0
                foreach var of local zvar_list {
                    replace temp_ss = temp_ss + (`var' - `cent_`var'')^2 if kmed_`k' == `j'
                }
                
                summarize temp_ss if kmed_`k' == `j', meanonly
                local total_wss = `total_wss' + r(sum)
                drop temp_ss
            }
        }
    }
    
    post wssfile (`k') (`total_wss')
}
postclose wssfile

// 3.4 Gap Statistic (simplified version without bootstrapping)
tempfile gapresults
postfile gapfile int(k) double(gap) using `gapresults', replace
forvalues k = 2/8 {
    // Use the WSS calculated above and compare to a reference
    // (This is a simplified version; a full gap statistic would use bootstrapping)
    quietly {
        use `wssresults', clear
        keep if k == `k'
        local actual_wss = wss[1]
        
        // Calculate expected WSS under null reference distribution
        // (In a real gap statistic, this would be from bootstrapped random data)
        // Here we use a simple approximation based on dimensionality
        local p = `zcount'
        local n = c(N)
        local expected_wss = `p' * `n' * 2/3  // Simple approximation
        
        // Calculate gap
        local gap_value = log(`expected_wss') - log(`actual_wss')
    }
    
    post gapfile (`k') (`gap_value')
    
    use `origdata', clear
}
postclose gapfile

// Visualize Results

// 3.5 CH Index Plot
use `chresults', clear
twoway (connected ch_index k, sort), ///
    title("Calinski-Harabasz Index vs. Number of Clusters") ///
    xtitle("Number of Clusters") ytitle("CH Index") ///
    xlabel(2(1)8) name(ch_plot, replace)
graph export "../Output/Figures/ch_index.png", replace width(1000)

// 3.6 Duda-Hart Index Plot
use `dhresults', clear
twoway (connected duda k, sort), ///
    title("Duda-Hart Index vs. Number of Clusters") ///
    xtitle("Number of Clusters") ytitle("Duda-Hart Index") ///
    xlabel(2(1)8) name(dh_plot, replace)
graph export "../Output/Figures/duda_hart_index.png", replace width(1000)

twoway (connected hart k, sort), ///
    title("Pseudo T-squared vs. Number of Clusters") ///
    xtitle("Number of Clusters") ytitle("Pseudo T-squared") ///
    xlabel(2(1)8) name(hart_plot, replace)
graph export "../Output/Figures/pseudo_t_squared.png", replace width(1000)

// 3.7 Elbow Method Plot
use `wssresults', clear
twoway (connected wss k, sort), ///
    title("Within-Cluster Sum of Squares vs. Number of Clusters") ///
    xtitle("Number of Clusters") ytitle("Within-Cluster SS") ///
    xlabel(2(1)8) name(elbow_plot, replace)
graph export "../Output/Figures/elbow_method.png", replace width(1000)

// 3.8 Gap Statistic Plot
use `gapresults', clear
twoway (connected gap k, sort), ///
    title("Gap Statistic vs. Number of Clusters") ///
    xtitle("Number of Clusters") ytitle("Gap Statistic") ///
    xlabel(2(1)8) name(gap_plot, replace)
graph export "../Output/Figures/gap_statistic.png", replace width(1000)

// 3.9 Determine optimal k values from each method
// CH Index: highest value
use `chresults', clear
gsort -ch_index
local optk_ch = k[1]
display "Optimal k (CH Index): `optk_ch'"

// Duda-Hart: highest duda combined with lowest Hart
use `dhresults', clear
// Look for high Duda and low pseudot2
// Usually, we'd look for significant jumps
// For simplicity, we'll just take the max Duda
gsort -duda
local optk_dh = k[1]
display "Optimal k (Duda-Hart): `optk_dh'"

// Elbow method: look for the "elbow" point
// This is subjective; for simplicity, we'll check the second derivative
use `wssresults', clear
sort k
gen diff1 = wss - wss[_n-1] if _n > 1
gen diff2 = diff1 - diff1[_n-1] if _n > 2
// Create absolute value variable for sorting
gen abs_diff2 = abs(diff2)
// The point where diff2 is maximum approximates the elbow
gsort -abs_diff2
local optk_elbow = k[1]
if missing(`optk_elbow') local optk_elbow = 2
display "Approximate optimal k (Elbow method): `optk_elbow'"

// Gap statistic: first k where gap[k] ≥ gap[k+1] - se[k+1]
// For simplicity, we'll just take the max gap
use `gapresults', clear
gsort -gap
local optk_gap = k[1]
display "Optimal k (Gap statistic): `optk_gap'"

// Create a table of optimal k values from each method
tempfile opt_k_results
postfile kfile str20(method) int(optk) using `opt_k_results', replace
post kfile ("Calinski-Harabasz") (`optk_ch')
post kfile ("Duda-Hart") (`optk_dh')
post kfile ("Elbow Method") (`optk_elbow')
post kfile ("Gap Statistic") (`optk_gap')
postclose kfile

use `opt_k_results', clear
list, clean
gsort optk
// Most frequently suggested k
egen temp = mode(optk), minmode
local consensus_k = temp[1]
display "Consensus optimal number of clusters: `consensus_k'"

// Save the optimal k table
save "../Output/Results/optimal_k_values.dta", replace
export delimited "../Output/Results/optimal_k_values.csv", replace

// Return to the original data
use `origdata', clear

/*---------------------------
   4. Perform Final Clustering for Each Optimal k Value
---------------------------*/
// 4.1 Generate clusters for each method's optimal k
// CH Index optimal clustering
cluster kmed `zvar_list', k(`optk_ch') name(final_ch) measure(abs) start(random)
gen cluster_ch = final_ch
label variable cluster_ch "Clusters (CH method, k=`optk_ch')"

// Duda-Hart optimal clustering
cluster kmed `zvar_list', k(`optk_dh') name(final_dh) measure(abs) start(random)
gen cluster_dh = final_dh
label variable cluster_dh "Clusters (Duda-Hart method, k=`optk_dh')"

// Elbow method optimal clustering
cluster kmed `zvar_list', k(`optk_elbow') name(final_elbow) measure(abs) start(random)
gen cluster_elbow = final_elbow
label variable cluster_elbow "Clusters (Elbow method, k=`optk_elbow')"

// Gap statistic optimal clustering
cluster kmed `zvar_list', k(`optk_gap') name(final_gap) measure(abs) start(random)
gen cluster_gap = final_gap
label variable cluster_gap "Clusters (Gap method, k=`optk_gap')"

// Consensus clustering (most frequently suggested k)
cluster kmed `zvar_list', k(`consensus_k') name(final_consensus) measure(abs) start(random)
gen cluster_consensus = final_consensus
label variable cluster_consensus "Clusters (Consensus, k=`consensus_k')"

// 4.2 Label all cluster variables
foreach var in cluster_ch cluster_dh cluster_elbow cluster_gap cluster_consensus {
    // Asignar valores específicos para cada variable de cluster
    if "`var'" == "cluster_ch" local k_val = `optk_ch'
    if "`var'" == "cluster_dh" local k_val = `optk_dh'
    if "`var'" == "cluster_elbow" local k_val = `optk_elbow'
    if "`var'" == "cluster_gap" local k_val = `optk_gap'
    if "`var'" == "cluster_consensus" local k_val = `consensus_k'
    
    // Crear etiquetas para cada valor de cluster
    label define `var'_lbl 1 "Cluster 1"
    forvalues i = 2/`k_val' {
        label define `var'_lbl `i' "Cluster `i'", add
    }
    label values `var' `var'_lbl
}

/*---------------------------
   5. Analysis for Each Optimal k Value
---------------------------*/
// Define cluster variables and their corresponding k values
local cluster_vars "cluster_ch cluster_dh cluster_elbow cluster_gap cluster_consensus"
local cluster_methods "CH DudaHart Elbow Gap Consensus"
local k_vals "`optk_ch' `optk_dh' `optk_elbow' `optk_gap' `consensus_k'"
local num_methods: word count `cluster_methods'

// 5.1 Cluster distribution for each method
forvalues i = 1/`num_methods' {
    local current_var: word `i' of `cluster_vars'
    local current_method: word `i' of `cluster_methods'
    local current_k: word `i' of `k_vals'
    
    graph bar, over(`current_var') blabel(total) ///
        title("Distribution of Programs (`current_method', k=`current_k')") ///
        ytitle("Number of Programs")
    graph export "../Output/Figures/distribution_`current_method'.png", replace width(1000)
}

// 5.2 Cluster size table for each method
forvalues i = 1/`num_methods' {
    local current_var: word `i' of `cluster_vars'
    local current_method: word `i' of `cluster_methods'
    local current_k: word `i' of `k_vals'
    
    // Remove hyphens, spaces, and other characters not allowed in matrix names
    local safe_method = subinstr("`current_method'", "-", "", .)
    local safe_method = subinstr("`safe_method'", " ", "", .)
    
    tabulate `current_var', matcell(size_`safe_method')
    matrix list size_`safe_method'
}

// 5.3 Basic characteristics by cluster for each method
forvalues i = 1/`num_methods' {
    local current_var: word `i' of `cluster_vars'
    local current_method: word `i' of `cluster_methods'
    local current_k: word `i' of `k_vals'
    
    // Select 5 key variables for basic description (or fewer if there aren't enough)
    local num_key_vars: word count `key_p_vars'
    local max_vars = min(5, `num_key_vars')
    local key_vars ""
    forvalues j = 1/`max_vars' {
        local var_j: word `j' of `key_p_vars'
        local key_vars "`key_vars' `var_j'"
    }
    
    display _newline "Descriptive statistics for `current_method' (k=`current_k')"
    display "======================================================"
    
    // Descriptive statistics by cluster
    foreach var of local key_vars {
        display _newline "Variable: `var'"
        tabstat `var', by(`current_var') stat(mean sd min max) nototal
    }
}

/*---------------------------
   6. Export Results
---------------------------*/
// 6.1 Save dataset with all cluster assignments
save "../Output/Results/V1_qualflags_analysis2_clustered.dta", replace

// 6.2 Export comparative table of optimal k values
preserve
use `opt_k_results', clear
rename method Method
rename optk optk_value
label variable optk_value "Optimal k"
export delimited "../Output/Results/optimal_k_values_summary.csv", replace
restore

// 6.3 Export cluster assignments for comparison
preserve
export delimited "../Output/Results/comparison_assignments.csv", replace
restore