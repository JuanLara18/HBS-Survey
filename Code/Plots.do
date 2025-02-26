/*==========================================================================
    CLUSTER COMPARISON VISUALIZATION
    Creates graphs comparing variables across clusters for all methods
==========================================================================*/

use "../Output/Results/V1_qualflags_analysis2_clustered.dta", clear

// Create output directory
capture mkdir "../Output/Cluster_Visualizations"

// Define cluster variables and their k values
local cluster_vars "cluster_ch cluster_dh cluster_elbow cluster_gap cluster_consensus"
local cluster_methods "CH DudaHart Elbow Gap Consensus"
local cluster_ks "2 2 4 8 2"

// Standardize all variables once at the beginning to avoid errors
// 1. Standardize continuous variables
local key_vars "p_participated p_participated_2023 p_duration p_hourstrained p_cost p_eligibility p_part_exp"
foreach var of varlist `key_vars' {
    quietly summarize `var'
    generate z_`var' = (`var' - r(mean))/r(sd)
    label variable z_`var' "Z-score: `var'"
}

// 2. Standardize binary variables
local binary_vars "p_mandavolunt p_ongoing p_otjactivities p_targetemp_c p_targetemp_mm p_targetemp_emp p_cha_takeup p_cha_scale"
foreach var of varlist `binary_vars' {
    quietly summarize `var'
    generate z_bin_`var' = (`var' - r(mean))/r(sd)
    label variable z_bin_`var' "Z-score: `var'"
}

// Loop through each clustering method
forvalues m = 1/5 {
    local cluster_var : word `m' of `cluster_vars'
    local method : word `m' of `cluster_methods'
    local k : word `m' of `cluster_ks'
    
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
            rows(2) cols(2)) ///
        bar(1, color("57 106 177")) bar(2, color("218 124 48")) ///
        bar(3, color("62 150 81")) bar(4, color("204 37 41"))
            
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
            rows(2) cols(2)) ///
        bar(1, color("83 80 76")) bar(2, color("107 76 154")) ///
        bar(3, color("146 36 40")) bar(4, color("140 140 140"))
            
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
        bar(1, color("57 106 177")) bar(2, color("218 124 48")) ///
        bar(3, color("62 150 81")) bar(4, color("204 37 41")) ///
        bar(5, color("107 76 154"))
            
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
        bar(1, color("57 106 177")) bar(2, color("218 124 48")) ///
        bar(3, color("62 150 81")) bar(4, color("204 37 41"))
            
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
        bar(1, color("57 106 177")) bar(2, color("218 124 48")) ///
        bar(3, color("62 150 81")) bar(4, color("204 37 41")) ///
        bar(5, color("107 76 154")) bar(6, color("146 36 40"))
            
    graph export "../Output/Cluster_Visualizations/target_functions_`method'.png", replace width(1200)

    //===================================================================
    // 6. PROGRAM CHARACTERISTICS
    //===================================================================
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
        bar(1, color("83 80 76")) bar(2, color("107 76 154")) ///
        bar(3, color("146 36 40"))
            
    graph export "../Output/Cluster_Visualizations/characteristics_`method'.png", replace width(1200)

    //===================================================================
    // 7. PROGRAM GOVERNANCE
    //===================================================================
    graph bar (mean) p_advocacy_hier p_responsibility_hier, ///
        over(`cluster_var') asyvars ///
        title("Program Governance by Cluster") ///
        subtitle("`method' Method (k=`k')") ///
        ytitle("Average Value") ///
        legend(title("Governance") ///
            label(1 "Advocacy Hierarchy") ///
            label(2 "Responsibility Hierarchy") ///
            rows(1) cols(2)) ///
        bar(1, color("57 106 177")) bar(2, color("218 124 48"))
            
    graph export "../Output/Cluster_Visualizations/governance_`method'.png", replace width(1200)

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
            bar(1, color("57 106 177")) bar(2, color("218 124 48")) ///
            bar(3, color("62 150 81")) bar(4, color("204 37 41")) ///
            bar(5, color("107 76 154")) bar(6, color("146 36 40"))
    }
    else {
        // For methods with many clusters, use fewer variables and horizontal bars
        graph hbar (mean) p_cha_takeup p_cha_during p_cha_scale p_challenge_learning, ///
            over(`cluster_var') asyvars ///
            title("Program Challenges by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Cluster") ///
            xtitle("Proportion") ///
            legend(title("Challenges") ///
                label(1 "Participant Takeup") ///
                label(2 "During Program") ///
                label(3 "Scaling Program") ///
                label(4 "Learning") ///
                rows(1) cols(4))
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
            bar(1, color("57 106 177")) bar(2, color("218 124 48")) ///
            bar(3, color("62 150 81")) bar(4, color("204 37 41")) ///
            bar(5, color("107 76 154")) bar(6, color("146 36 40")) ///
            bar(7, color("140 140 140"))
    }
    else {
        // For methods with many clusters, use fewer variables
        graph hbar (mean) z_p_participated z_p_participated_2023 z_p_duration z_p_cost, ///
            over(`cluster_var') asyvars ///
            title("Z-Score Profile by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Cluster") ///
            xtitle("Z-score") ///
            xline(0, lcolor(gray) lpattern(dash)) ///
            legend(title("Variables") ///
                label(1 "Total Participants") ///
                label(2 "Participants 2023") ///
                label(3 "Duration") ///
                label(4 "Cost per Person") ///
                rows(1) cols(4))
    }
            
    graph export "../Output/Cluster_Visualizations/zscore_profile_`method'.png", replace width(1200)
    
    //===================================================================
    // 10. COMBINED KEY VARIABLES
    //===================================================================
    // For methods with many clusters, create horizontal plots with key variables
    if `k' <= 4 {
        // Now we can use the binary z-scores without trying to recreate them
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
                rows(2) cols(3))
                
        graph export "../Output/Cluster_Visualizations/key_variables_`method'.png", replace width(1200)
    }
    else {
        // For methods with many clusters, use horizontal bars with fewer variables
        graph hbar (mean) z_p_participated z_p_cost z_bin_p_targetemp_c z_bin_p_targetemp_emp, ///
            over(`cluster_var') asyvars ///
            title("Key Variable Profile by Cluster") ///
            subtitle("`method' Method (k=`k')") ///
            ytitle("Cluster") ///
            xtitle("Z-score") ///
            xline(0, lcolor(gray) lpattern(dash)) ///
            legend(title("Variables") ///
                label(1 "Total Participants") ///
                label(2 "Cost per Person") ///
                label(3 "Target: C-Suite") ///
                label(4 "Target: Employees") ///
                rows(1) cols(4))
                
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
                        p_challenge_learning p_challenge_effectiveness p_challenge_convmanager ///
                        p_advocacy_hier p_responsibility_hier p_difloc, ///
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

// Create cluster size summary table
preserve
    // Count observations by cluster for each method
    gen count = 1
    
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

display "Cluster visualizations complete for all methods! Results saved to ../Output/Cluster_Visualizations/"