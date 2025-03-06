/*==========================================================================
    CLUSTER VISUALIZATION
    
    This do-file creates comprehensive visualizations comparing variables 
    across clusters for all clustering methods, along with firm characteristics.
==========================================================================*/

// Setup
clear all
set more off
capture log close
log using "../Output/Results/Unified_Cluster_Analysis.log", replace

// Global scheme and formatting settings
set scheme s1manual
graph set window fontface "Calibri"
graph set window fontfacesans "Calibri"
graph set window fontfaceserif "Calibri"
graph set window fontfacemono "Consolas"

graph set window ysize 0.8

// Load the clustered data
use "../Data/V1_qualflags_analysis2_clustered.dta", clear
display "Dataset loaded with " c(N) " observations and " c(k) " variables."

// Create unified output directory
capture mkdir "../Output/Cluster_Visualizations"

// Define cluster variables and their k values
local cluster_vars "cluster_ch cluster_dh cluster_elbow cluster_gap cluster_consensus"
local cluster_methods "CH DudaHart Elbow Gap Consensus"
local cluster_ks "2 2 4 8 2"

// Define color palette for better visualization
local color1 "57 106 177"
local color2 "218 124 48" 
local color3 "62 150 81"
local color4 "204 37 41"
local color5 "107 76 154"
local color6 "146 36 40"
local color7 "140 140 140"

// Standardize all variables once at the beginning
// 1. Standardize continuous variables
local key_vars "p_participated p_participated_2023 p_duration p_hourstrained p_cost p_eligibility p_part_exp p_program_length p_comphours"
foreach var of varlist `key_vars' {
    capture confirm numeric variable `var'
    if !_rc {
        quietly summarize `var'
        generate z_`var' = (`var' - r(mean))/r(sd)
        label variable z_`var' "Z-score: `var'"
    }
}

// 2. Standardize binary variables
local binary_vars "p_mandavolunt p_ongoing p_otjactivities p_targetemp_c p_targetemp_mm p_targetemp_emp p_cha_takeup p_cha_scale p_selection"
foreach var of varlist `binary_vars' {
    capture confirm numeric variable `var'
    if !_rc {
        quietly summarize `var'
        generate z_bin_`var' = (`var' - r(mean))/r(sd)
        label variable z_bin_`var' "Z-score: `var'"
    }
}

/*==========================================================================
    PART 1: VISUALIZATIONS FOR ALL CLUSTERING METHODS
==========================================================================*/

// Loop through each clustering method
forvalues m = 1/5 {
    local cluster_var : word `m' of `cluster_vars'
    local method : word `m' of `cluster_methods'
    local k : word `m' of `cluster_ks'
    
    display "Creating visualizations for `method' method (k=`k')"
    
    //===================================================================
    // 1. PROGRAM SIZE AND PARTICIPATION
    //===================================================================
    graph bar (mean) p_participated p_participated_2023 p_eligibility p_part_exp, ///
        over(`cluster_var') asyvars ///
        title("Program Participation by Cluster") ///
        subtitle("`method' Method (k=`k')") ///
        ytitle("Average Value") ///
        legend(title("Variables") ///
            label(1 "Total Participants") ///
            label(2 "Participants 2023") ///
            label(3 "Eligibility %") ///
            label(4 "Expected Participation %") ///
            rows(1) cols(4)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'"))
            
    graph export "../Output/Cluster_Visualizations/participation_`method'.png", replace width(1200)

    //===================================================================
    // 2. PROGRAM STRUCTURE AND COST
    //===================================================================
    graph bar (mean) p_duration p_hourstrained p_comphours p_cost, ///
        over(`cluster_var') asyvars ///
        title("Program Structure and Cost by Cluster") ///
        subtitle("`method' Method (k=`k')") ///
        ytitle("Average Value") ///
        legend(title("Variables") ///
            label(1 "Duration") ///
            label(2 "Hours Trained") ///
            label(3 "Compensated Hours") ///
            label(4 "Cost per Person") ///
            rows(1) cols(4)) ///
        bar(1, color("`color5'")) bar(2, color("`color6'")) ///
        bar(3, color("`color3'")) bar(4, color("`color7'"))
            
    graph export "../Output/Cluster_Visualizations/structure_`method'.png", replace width(1200)

    //===================================================================
    // 3. PROGRAM FUNDING SOURCES
    //===================================================================
    graph bar (mean) p_fund_gov p_fund_org p_fund_wrk p_fund_union p_fund_other, ///
        over(`cluster_var') asyvars ///
        title("Program Funding Sources by Cluster") ///
        subtitle("`method' Method (k=`k')") ///
        ytitle("Average Percentage (%)") ///
        legend(title("Funding Sources") ///
            label(1 "Government") ///
            label(2 "Organization") ///
            label(3 "Workers") ///
            label(4 "Union") ///
            label(5 "Other") ///
            rows(1) cols(5)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'")) ///
        bar(5, color("`color5'"))
            
    graph export "../Output/Cluster_Visualizations/funding_`method'.png", replace width(1200)

    //===================================================================
    // 4. TARGET EMPLOYEE GROUPS
    //===================================================================
    graph bar (mean) p_targetemp_c p_targetemp_bul p_targetemp_mm p_targetemp_emp, ///
        over(`cluster_var') asyvars ///
        title("Target Employee Groups by Cluster") ///
        subtitle("`method' Method (k=`k')") ///
        ytitle("Proportion") ///
        blabel(bar, format(%9.2f)) ///
        legend(title("Target Groups") ///
            label(1 "C-Suite") ///
            label(2 "Business Unit Leaders") ///
            label(3 "Middle Managers") ///
            label(4 "Employees") ///
            rows(1) cols(4)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'"))
            
    graph export "../Output/Cluster_Visualizations/target_groups_`method'.png", replace width(1200)

    //===================================================================
    // 5. TARGET FUNCTIONS
    //===================================================================
    graph bar (mean) p_targetfunc_hr p_targetfunc_it p_targetfunc_op p_targetfunc_mrksal p_targetfunc_accfin p_targetfunc_cust, ///
        over(`cluster_var') asyvars ///
        title("Target Functions by Cluster") ///
        subtitle("`method' Method (k=`k')") ///
        ytitle("Proportion") ///
        legend(title("Functions") ///
            label(1 "HR") ///
            label(2 "IT") ///
            label(3 "Operations") ///
            label(4 "Marketing/Sales") ///
            label(5 "Finance") ///
            label(6 "Customer Service") ///
            rows(2) cols(3) pos(6)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'")) ///
        bar(5, color("`color5'")) bar(6, color("`color6'"))
            
    graph export "../Output/Cluster_Visualizations/target_functions_`method'.png", replace width(1200)

    //===================================================================
    // 6. PROGRAM CHARACTERISTICS
    //===================================================================
    capture confirm variable p_selection
    if !_rc {
        graph bar (mean) p_mandavolunt p_ongoing p_otjactivities p_selection, ///
            over(`cluster_var') asyvars ///
            title("Program Characteristics by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Proportion") ///
            blabel(bar, format(%9.2f)) ///
            legend(title("Characteristics") ///
                label(1 "Mandatory(1)/Voluntary(2)") ///
                label(2 "Ongoing Program") ///
                label(3 "On-job Activities") ///
                label(4 "Selection Process") ///
                rows(1) cols(4)) ///
            bar(1, color("`color5'")) bar(2, color("`color6'")) ///
            bar(3, color("`color3'")) bar(4, color("`color2'"))
    }
    else {
        graph bar (mean) p_mandavolunt p_ongoing p_otjactivities, ///
            over(`cluster_var') asyvars ///
            title("Program Characteristics by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Proportion") ///
            blabel(bar, format(%9.2f)) ///
            legend(title("Characteristics") ///
                label(1 "Mandatory(1)/Voluntary(2)") ///
                label(2 "Ongoing Program") ///
                label(3 "On-job Activities") ///
                rows(1) cols(3)) ///
            bar(1, color("`color5'")) bar(2, color("`color6'")) ///
            bar(3, color("`color3'"))
    }
            
    graph export "../Output/Cluster_Visualizations/characteristics_`method'.png", replace width(1200)

    //===================================================================
    // 7. PROGRAM GOVERNANCE
    //===================================================================
    capture confirm variable p_advocacy_hier
    if !_rc & _rc == 0 {
        graph bar (mean) p_advocacy_hier p_responsibility_hier, ///
            over(`cluster_var') asyvars ///
            title("Program Governance by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Average Value") ///
            legend(title("Governance") ///
                label(1 "Advocacy Hierarchy") ///
                label(2 "Responsibility Hierarchy") ///
                rows(1) cols(2)) ///
            bar(1, color("`color1'")) bar(2, color("`color2'"))
                
        graph export "../Output/Cluster_Visualizations/governance_`method'.png", replace width(1200)
    }

    //===================================================================
    // 8. PROGRAM CHALLENGES
    //===================================================================
    // For methods with many clusters, use horizontal bars for better visualization
    if `k' <= 4 {
        graph bar (mean) p_cha_takeup p_cha_during p_cha_support p_cha_scale p_challenge_learning p_challenge_effectiveness, ///
            over(`cluster_var') asyvars ///
            title("Program Challenges by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Proportion") ///
            legend(title("Challenges") ///
                label(1 "Participant Takeup") ///
                label(2 "During Program") ///
                label(3 "External Support") ///
                label(4 "Scaling Program") ///
                label(5 "Learning") ///
                label(6 "Effectiveness") ///
                rows(2) cols(3)) ///
            bar(1, color("`color1'")) bar(2, color("`color2'")) ///
            bar(3, color("`color3'")) bar(4, color("`color4'")) ///
            bar(5, color("`color5'")) bar(6, color("`color6'"))
    }
    else {
        // For methods with many clusters, use fewer variables and horizontal bars
        graph hbar (mean) p_cha_takeup p_cha_during p_cha_scale p_challenge_learning, ///
            over(`cluster_var') asyvars ///
            title("Program Challenges by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Cluster") /// xtitle("Proportion") ///
            legend(title("Challenges") ///
                label(1 "Participant Takeup") ///
                label(2 "During Program") ///
                label(3 "Scaling Program") ///
                label(4 "Learning") ///
                rows(1) cols(4)) ///
            bar(1, color("`color1'")) bar(2, color("`color2'")) ///
            bar(3, color("`color3'")) bar(4, color("`color4'"))
    }
            
    graph export "../Output/Cluster_Visualizations/challenges_`method'.png", replace width(1200)

    //===================================================================
    // 9. Z-SCORE PROFILE
    //===================================================================
    // For methods with many clusters, use fewer variables
    if `k' <= 4 {
        graph bar (mean) z_p_participated z_p_participated_2023 z_p_duration z_p_hourstrained z_p_cost z_p_eligibility z_p_part_exp, ///
            over(`cluster_var') asyvars ///
            title("Z-Score Profile by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Z-score") ///
            yline(0, lcolor(gray) lpattern(dash)) ///
            legend(title("Variables") ///
                label(1 "Total Participants") ///
                label(2 "Participants 2023") ///
                label(3 "Duration") ///
                label(4 "Hours Trained") ///
                label(5 "Cost per Person") ///
                label(6 "Eligibility %") ///
                label(7 "Expected Participation %") ///
                rows(2) cols(4) size(small)) ///
            bar(1, color("`color1'")) bar(2, color("`color2'")) ///
            bar(3, color("`color3'")) bar(4, color("`color4'")) ///
            bar(5, color("`color5'")) bar(6, color("`color6'")) ///
            bar(7, color("`color7'"))
    }
    else {
        // For methods with many clusters, use fewer variables
        graph hbar (mean) z_p_participated z_p_participated_2023 z_p_duration z_p_cost, ///
            over(`cluster_var') asyvars ///
            title("Z-Score Profile by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Cluster") /// xtitle("Z-score") /// xline(0, lcolor(gray) lpattern(dash)) ///
            legend(title("Variables") ///
                label(1 "Total Participants") ///
                label(2 "Participants 2023") ///
                label(3 "Duration") ///
                label(4 "Cost per Person") ///
                rows(1) cols(4)) ///
            bar(1, color("`color1'")) bar(2, color("`color2'")) ///
            bar(3, color("`color3'")) bar(4, color("`color4'"))
    }
            
    graph export "../Output/Cluster_Visualizations/zscore_profile_`method'.png", replace width(1200)
    
    //===================================================================
    // 10. COMBINED KEY VARIABLES
    //===================================================================
    // For methods with many clusters, create horizontal plots with key variables
    if `k' <= 4 {
        // Use binary z-scores
        graph bar (mean) z_p_participated z_p_participated_2023 z_p_duration z_p_cost z_bin_p_targetemp_c z_bin_p_targetemp_emp, ///
            over(`cluster_var') asyvars ///
            title("Key Variable Profile by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Z-score") ///
            yline(0, lcolor(gray) lpattern(dash)) ///
            legend(title("Variables") ///
                label(1 "Total Participants") ///
                label(2 "Participants 2023") ///
                label(3 "Duration") ///
                label(4 "Cost per Person") ///
                label(5 "Target: C-Suite") ///
                label(6 "Target: Employees") ///
                rows(2) cols(3)) ///
            bar(1, color("`color1'")) bar(2, color("`color2'")) ///
            bar(3, color("`color3'")) bar(4, color("`color4'")) ///
            bar(5, color("`color5'")) bar(6, color("`color6'"))
                
        graph export "../Output/Cluster_Visualizations/key_variables_`method'.png", replace width(1200)
    }
    else {
        // For methods with many clusters, use horizontal bars with fewer variables
        graph hbar (mean) z_p_participated z_p_cost z_bin_p_targetemp_c z_bin_p_targetemp_emp, ///
            over(`cluster_var') asyvars ///
            title("Key Variable Profile by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Cluster") /// xtitle("Z-score") /// xline(0, lcolor(gray) lpattern(dash)) ///
            legend(title("Variables") ///
                label(1 "Total Participants") ///
                label(2 "Cost per Person") ///
                label(3 "Target: C-Suite") ///
                label(4 "Target: Employees") ///
                rows(1) cols(4)) /// 
            bar(1, color("`color1'")) bar(2, color("`color2'")) ///
            bar(3, color("`color3'")) bar(4, color("`color4'"))
                
        graph export "../Output/Cluster_Visualizations/key_variables_`method'.png", replace width(1200)
    }
    
    //===================================================================
    // 11. EXPORT SUMMARY TABLE
    //===================================================================
    preserve
        // Calculate means for key variables by cluster
        collapse (mean) p_participated p_participated_2023 p_eligibility p_part_exp ///
                        p_duration p_hourstrained p_comphours p_cost ///
                        p_fund_gov p_fund_org p_fund_wrk p_fund_union p_fund_other ///
                        p_mandavolunt p_ongoing p_otjactivities ///
                        p_targetemp_c p_targetemp_bul p_targetemp_mm p_targetemp_emp ///
                        p_targetfunc_hr p_targetfunc_it p_targetfunc_op p_targetfunc_mrksal p_targetfunc_accfin p_targetfunc_cust ///
                        p_cha_takeup p_cha_during p_cha_support p_cha_scale ///
                        p_challenge_learning p_challenge_effectiveness p_difloc, ///
                    by(`cluster_var')
        
        // Convert binary variables to percentages
        foreach var of varlist p_ongoing p_otjactivities p_targetemp_* p_targetfunc_* p_cha_* p_challenge_* {
            replace `var' = `var' * 100
            label variable `var' "`var' (%)"
        }
        
        // Export table
        export excel using "../Output/Cluster_Visualizations/`method'_cluster_summary.xlsx", firstrow(variables) replace
        export delimited using "../Output/Cluster_Visualizations/`method'_cluster_summary.csv", replace
    restore
}

/*==========================================================================
    PART 2: DETAILED ANALYSIS FOR CH METHOD CLUSTERING
==========================================================================*/

// Focus on cluster_ch for in-depth analysis
tab cluster_ch, missing

// Get number of clusters
quietly tab cluster_ch
local k = r(r)
display "Working with `k' clusters from CH method for detailed analysis."

// 1. CLUSTER COMPOSITION BY FIRM CHARACTERISTICS
//==================================================================

// Create a temporary variable for counting
gen count = 1

// 1.1 Cluster composition by program type
graph bar (percent), over(program) over(cluster_ch) ///
    title("Cluster Composition by Program Type") ///
    subtitle("CH Method") ///
    ytitle("Percent") ///
    blabel(bar, format(%9.1f)) ///
    bar(1, color("`color1'")) bar(2, color("`color2'")) ///
    bar(3, color("`color3'"))
    
graph export "../Output/Cluster_Visualizations/CH_cluster_by_program.png", replace width(1200)

// 1.2 Cluster composition by firm size
capture confirm variable f_size
if !_rc {
    graph bar (percent), over(f_size) over(cluster_ch) ///
        title("Cluster Composition by Firm Size") ///
        subtitle("CH Method") ///
        ytitle("Percent") ///
        blabel(bar, format(%9.1f)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'"))
        
    graph export "../Output/Cluster_Visualizations/CH_cluster_by_firmsize.png", replace width(1200)
}

// 1.3 Cluster composition by industry
capture confirm variable f_naics_super
if !_rc {
    graph bar (percent), over(f_naics_super) over(cluster_ch) ///
        title("Cluster Composition by Industry") ///
        subtitle("CH Method") ///
        ytitle("Percent") ///
        blabel(bar, format(%9.1f)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'"))
        
    graph export "../Output/Cluster_Visualizations/CH_cluster_by_industry.png", replace width(1200)
}

/*==========================================================================
    PART 3: FIRM CHARACTERISTICS BY CLUSTER
==========================================================================*/

// 1. FIRM SIZE VARIABLES
//==================================================================

// 1.1 Firm size (categorical)
capture confirm variable f_size
if !_rc {
    graph bar (percent), over(f_size) over(cluster_ch) ///
        title("Firm Size by Cluster") ///
        subtitle("CH Method") ///
        ytitle("Percent") ///
        blabel(bar, format(%9.1f) size(small)) /// note("Source: V1_qualflags_analysis2_clustered.dta", size(vsmall)) ///
        asyvars bar(1, color("`color1'") fintensity(60)) ///
        bar(2, color("`color2'") fintensity(60)) ///
        bar(3, color("`color3'") fintensity(60)) ///
        bar(4, color("`color4'") fintensity(60))
        
    graph export "../Output/Cluster_Visualizations/firm_size_by_cluster.png", replace width(1200)
}

// 1.2 Firm size indicators
local size_vars ""
foreach var in f_large f_medium {
    capture confirm variable `var'
    if !_rc {
        local size_vars "`size_vars' `var'"
    }
}

// Add any f_size_* variables
ds f_size_*, has(type numeric)
local size_pattern_vars "`r(varlist)'"
local size_vars "`size_vars' `size_pattern_vars'"

if "`size_vars'" != "" {
    graph bar (mean) `size_vars', over(cluster_ch) asyvars ///
        title("Firm Size Indicators by Cluster") ///
        subtitle("CH Method") ///
        ytitle("Proportion") ///
        blabel(bar, format(%9.2f) size(small)) ///
        legend(title("Size Categories", size(small)) rows(1) size(small) position(6)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'"))
        
    graph export "../Output/Cluster_Visualizations/firm_size_indicators_by_cluster.png", replace width(1200)
}

// 2. MULTINATIONAL AND EXPORT INDICATORS
//==================================================================

local intl_vars ""
foreach var in f_mne f_export {
    capture confirm variable `var'
    if !_rc {
        local intl_vars "`intl_vars' `var'"
    }
}

if "`intl_vars'" != "" {
    graph bar (mean) `intl_vars', over(cluster_ch) asyvars ///
        title("Firm International Indicators by Cluster") ///
        subtitle("CH Method") ///
        ytitle("Proportion") ///
        blabel(bar, format(%9.2f) size(small)) ///
        legend(title("Indicators", size(small)) rows(1) position(6) size(small)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'"))
        
    graph export "../Output/Cluster_Visualizations/firm_international_by_cluster.png", replace width(1200)
}

// 3. INDUSTRY CATEGORIES
//==================================================================

local ind_vars ""
foreach var in f_naics_super f_naics_super2 {
    capture confirm variable `var'
    if !_rc {
        local ind_vars "`ind_vars' `var'"
    }
}

if "`ind_vars'" != "" {
    // Determine which variable to use based on number of categories
    local ind_var ""
    foreach var of local ind_vars {
        quietly tab `var'
        local cats = r(r)
        if `cats' <= 6 {
            local ind_var "`var'"
            continue, break
        }
    }
    
    // If all variables have too many categories, use the first one
    if "`ind_var'" == "" & "`ind_vars'" != "" {
        local ind_var : word 1 of `ind_vars'
    }
    
    if "`ind_var'" != "" {
        graph hbar (percent), over(`ind_var') over(cluster_ch) ///
            title("Firm Industry by Cluster") ///
            subtitle("CH Method") ///
            ytitle("Industry") ///
            blabel(bar, format(%9.1f) position(inside) size(small)) ///
            asyvars ///
            bar(1, color("`color1'") fintensity(60)) ///
            bar(2, color("`color2'") fintensity(60))
            
        graph export "../Output/Cluster_Visualizations/firm_industry_by_cluster.png", replace width(1200)
    }
}

// 4. UNION VARIABLES
//==================================================================

// 4.1 Union presence (categorical)
capture confirm variable f_union
if !_rc {
    quietly tab f_union
    if r(r) <= 6 {
        graph bar (percent), over(f_union) over(cluster_ch) ///
            title("Union Presence by Cluster") ///
            subtitle("CH Method") ///
            ytitle("Percent") ///
            blabel(bar, format(%9.1f) size(small)) ///
            asyvars bar(1, color("`color1'") fintensity(70)) ///
            bar(2, color("`color2'") fintensity(70))
            
        graph export "../Output/Cluster_Visualizations/union_presence_by_cluster.png", replace width(1200)
    }
}

// 4.2 Union indicators
local union_vars ""
ds f_*union*
local union_pattern_vars "`r(varlist)'"

capture confirm variable f_union50
if !_rc {
    local union_vars "f_union50"
}

foreach var of local union_pattern_vars {
    capture confirm numeric variable `var'
    if !_rc {
        local union_vars "`union_vars' `var'"
    }
}

if "`union_vars'" != "" {
    graph bar (mean) `union_vars', over(cluster_ch) asyvars ///
        title("Union Indicators by Cluster") ///
        subtitle("CH Method") ///
        ytitle("Proportion") ///
        blabel(bar, format(%9.2f) size(small)) ///
        legend(title("Union Indicators", size(small)) rows(1) size(small) position(6)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'"))
        
    graph export "../Output/Cluster_Visualizations/union_indicators_by_cluster.png", replace width(1200)
}

// 5. OWNERSHIP AND SUBSIDY VARIABLES
//==================================================================

// 5.1 Ownership indicators
local own_vars ""
foreach var in f_public f_subsidy fsub {
    capture confirm variable `var'
    if !_rc {
        local own_vars "`own_vars' `var'"
    }
}

if "`own_vars'" != "" {
    graph bar (mean) `own_vars', over(cluster_ch) asyvars ///
        title("Firm Ownership & Subsidy Indicators by Cluster") ///
        subtitle("CH Method") ///
        ytitle("Proportion") ///
        blabel(bar, format(%9.2f) size(small)) ///
        legend(title("Indicators", size(small)) rows(1) size(small) position(6)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'"))
        
    graph export "../Output/Cluster_Visualizations/firm_ownership_indicators_by_cluster.png", replace width(1200)
}

// 6. COMBINED FIRM CHARACTERISTIC PROFILE
//==================================================================

// Select key firm characteristics that exist in the dataset
local key_firm_vars ""

// Check each potential key variable individually
foreach var in f_large f_medium f_public f_subsidy f_union50 f_mne f_export {
    capture confirm variable `var'
    if !_rc {
        quietly sum `var'
        // Only include if it's a binary variable
        if r(min) >= 0 & r(max) <= 1 {
            local key_firm_vars "`key_firm_vars' `var'"
        }
    }
}

// Create visualization with standardized values if we have enough variables
if wordcount("`key_firm_vars'") >= 3 {
    // Standardize the variables
    foreach var of local key_firm_vars {
        quietly summarize `var'
        capture drop z_`var' 
        generate z_`var' = (`var' - r(mean))/r(sd)
        label variable z_`var' "Z-score: `var'"
    }
    
    // Create z-score variables list
    local z_vars ""
    foreach var of local key_firm_vars {
        local z_vars "`z_vars' z_`var'"
    }
    
    // Create z-score bars
    graph bar (mean) `z_vars', over(cluster_ch) asyvars ///
        title("Key Firm Characteristics by Cluster") ///
        subtitle("CH Method - Standardized Values") ///
        ytitle("Z-score") ///
        yline(0, lcolor(gray) lpattern(dash)) ///
        legend(title("Characteristics") rows(1) position(6)) ///
        bar(1, color("`color1'")) bar(2, color("`color2'")) ///
        bar(3, color("`color3'")) bar(4, color("`color4'")) ///
        bar(5, color("`color5'")) bar(6, color("`color6'")) ///
        bar(7, color("`color7'"))
        
    graph export "../Output/Cluster_Visualizations/firm_profile_by_cluster.png", replace width(1200)
}

/*==========================================================================
    PART 4: STATISTICAL ANALYSIS AND SUMMARY TABLES
==========================================================================*/

// 1. CLUSTER SIZE SUMMARY
//==================================================================

// Create cluster size summary table
preserve
    // Count observations by cluster for each method
    *gen count = 1
    
    // Generate counts for each clustering method
    foreach method of local cluster_methods {
        local i : list posof "`method'" in cluster_methods
        local cluster_var : word `i' of `cluster_vars'
        
        // Count by cluster
        bysort `cluster_var': egen cluster_size_`method' = count(count)
    }
    
    // Create a clean dataset with just cluster information
    keep cluster_ch cluster_dh cluster_elbow cluster_gap cluster_consensus cluster_size_*
    duplicates drop
    
    // Export cluster size summary
    export excel using "../Output/Cluster_Visualizations/cluster_size_summary.xlsx", firstrow(variables) replace
    export delimited using "../Output/Cluster_Visualizations/cluster_size_summary.csv", replace
restore

// 2. ANOVA TESTS FOR KEY CONTINUOUS VARIABLES
//==================================================================

// Key continuous variables for analysis
local key_cont_vars "p_participated p_participated_2023 p_duration p_hourstrained p_cost p_eligibility p_part_exp"

foreach var of local key_cont_vars {
    capture confirm numeric variable `var'
    if !_rc {
        display _newline "Analysis of `var' by cluster_ch"
        display "=============================="
        
        // Display ANOVA table
        anova `var' cluster_ch
        
        // Simple summary by cluster
        tabstat `var', by(cluster_ch) statistics(mean sd n)
    }
}

// 3. CHI-SQUARE TESTS FOR CATEGORICAL VARIABLES
//==================================================================

// Key categorical variables for analysis
local key_cat_vars "program f_size f_naics_super f_union"

foreach var of local key_cat_vars {
    capture confirm variable `var'
    if !_rc {
        display _newline "Chi-square test for `var' by cluster_ch"
        display "================================================="
        tab cluster_ch `var', chi2 row
    }
}

// 4. SUMMARY STATISTICS TABLE
//==================================================================

// Create a summary table of key variables by cluster
estpost tabstat p_participated p_participated_2023 p_duration p_hourstrained ///
    p_cost p_eligibility p_part_exp p_fund_org p_fund_gov p_ongoing ///
    p_mandavolunt p_otjactivities p_targetemp_c p_targetemp_emp, ///
    by(cluster_ch) statistics(mean sd) columns(statistics) listwise
esttab using "../Output/Cluster_Visualizations/cluster_summary_stats.csv", ///
    cells("mean(fmt(%9.2f)) sd(fmt(%9.2f))") replace

// 5. FIRM CHARACTERISTICS SUMMARY TABLE
//==================================================================

// Select firm characteristics for summary table
local firm_sum_vars ""
foreach var in f_large f_medium f_public f_subsidy f_union50 f_mne f_export {
    capture confirm variable `var'
    if !_rc {
        local firm_sum_vars "`firm_sum_vars' `var'"
    }
}

if "`firm_sum_vars'" != "" {
    // Output summary table
    estpost tabstat `firm_sum_vars', by(cluster_ch) statistics(mean sd) columns(statistics) listwise
    esttab using "../Output/Cluster_Visualizations/firm_summary_stats.csv", ///
        cells("mean(fmt(%9.2f)) sd(fmt(%9.2f))") replace
}

// 6. COMBINED DATASET FOR FURTHER ANALYSIS
//==================================================================

// Create a dataset with key variables and cluster membership for further analysis
preserve
    keep cluster_ch program p_participated p_participated_2023 p_duration ///
        p_hourstrained p_cost p_eligibility p_part_exp p_fund_org ///
        p_fund_gov p_ongoing p_mandavolunt p_otjactivities p_targetemp_c ///
        p_targetemp_emp p_targetfunc_* f_*
    
    // Export this for further analysis
    export delimited using "../Output/Cluster_Visualizations/combined_analysis_data.csv", replace
restore

/*==========================================================================
    PART 4: ADITIONAL RESULTS
==========================================================================*/

// 1. NUMBER OF WORKERS
//==================================================================
// Calculate average number of participants by cluster
preserve
    // Focus on the main clustering methods
    foreach method of local cluster_methods {
        local i : list posof "`method'" in cluster_methods
        local cluster_var : word `i' of `cluster_vars'
        
        // Calculate average participation by cluster
        tabstat p_participated p_participated_2023, by(`cluster_var') statistics(mean n) nototal
        
        // Export to a CSV file
        collapse (mean) p_participated p_participated_2023 (count) n=p_participated, by(`cluster_var')
        export delimited using "../Output/Cluster_Visualizations/avg_participation_`method'.csv", replace
        
        // Create a visual of average participation by cluster
        graph bar (mean) p_participated p_participated_2023, over(`cluster_var') ///
            title("Average Participation by Cluster") ///
            subtitle("`method' Method") ///
            ytitle("Average Number of Participants") ///
            blabel(bar, format(%9.0fc)) ///
            legend(title("") label(1 "All-time Participants") label(2 "2023 Participants")) ///
            bar(1, color("`color1'")) bar(2, color("`color2'"))
            
        graph export "../Output/Cluster_Visualizations/avg_participation_`method'_visual.png", replace width(1200)
        
        restore, preserve
    }
restore


// 2. REGRESSION
//==================================================================
// Regression using clusters as dependent variable
// This creates a binary indicator for each cluster
tab cluster_ch, gen(cluster_ch_)

// Run regressions for each cluster indicator
foreach i of numlist 1/`k' {
    // Basic regression with firm characteristics
    regress cluster_ch_`i' f_large f_medium f_mne f_export f_public
    outreg2 using "../Output/Cluster_Visualizations/cluster_regression.xls", replace
    
    // Add industry controls if available
    capture confirm variable f_naics_*
    if !_rc {
        regress cluster_ch_`i' f_large f_medium f_mne f_export f_public i.f_naics_super
        outreg2 using "../Output/Cluster_Visualizations/cluster_regression.xls", append
    }
}

// Close log file
log close

display "Unified cluster visualization complete! All results saved to ../Output/Cluster_Visualizations/"