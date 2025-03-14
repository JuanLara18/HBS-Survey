/*==============================================================================
  Survey Analysis Do File
  
  This file generates all outputs required for the Excel spreadsheet
  
  The outputs are organized into three parts:
  1. Survey description
  2. In-depth look at training
  3. Firm correlates of reskilling
==============================================================================*/

clear all
set more off
capture log close

// Set up paths
global datadir "../Data"
global outdir "../Output/Results"
global figuresdir "../Output/Figures"

*cd C:\Users\user\Desktop\HBS-Survey\Code

// Create output directories if they don't exist
capture mkdir "$outdir"
capture mkdir "$figuresdir"
capture mkdir "$figuresdir/SummaryStats"
capture mkdir "$figuresdir/SummaryStats/HR"
capture mkdir "$figuresdir/Correlations"

// Start log file
log using "$outdir/survey_analysis.log", replace

// Load the main dataset
use "$datadir/V1_qualflags_analysis2.dta", clear
display "Dataset loaded with " c(N) " observations and " c(k) " variables."


/*==============================================================================
  PART 1: DESCRIBING THE SURVEY
==============================================================================*/

/*------------------------------------------------------------------------------
  Sheet 1: Summary Statistics of Firms (slides 2-3 and map slide 3)
------------------------------------------------------------------------------*/
// Generate firm size and position tables like in Image 1
// Size table
estpost tabulate f_size
esttab using "$outdir/firm_size_stats.csv", ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    nonumber nomtitle noobs replace

// Position/Job title table
estpost tabulate m_role
esttab using "$outdir/position_stats.csv", ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    nonumber nomtitle noobs replace

// Industry distribution table like in Image 2
estpost tabulate f_naics_super
esttab using "$outdir/industry_stats.csv", ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    nonumber nomtitle noobs replace

// Super-industries
estpost tabulate f_naics_super2
esttab using "$outdir/super_industry_stats.csv", ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    nonumber nomtitle noobs replace

// Map of geographical distribution
// HOW??


/*------------------------------------------------------------------------------
  Sheet 2: Summary Statistics on HR Practices
------------------------------------------------------------------------------*/
// Generate summary statistics for HR practice variables
estpost tabstat hr_*, statistics(count mean sd min max) columns(statistics)
esttab using "$outdir/hr_practices_stats.csv", cells("count mean sd min max") replace

// Create overall HR index
// HR indices calculation
* Index for HR 
*1) Index for Inventory 
egen hr_index_inventory=rowtotal(hr_d_sk_description hr_d_sk_inventory hr_d_sk_inventory_use)

tab hr_index_inventory

egen hr_index_inventorylbmarket=rowtotal(hr_d_sk_description hr_d_sk_inventory hr_d_sk_inventory_use hr_d_internalmkt)

tab hr_index_inventorylbmarket
summarize hr_index_inventorylbmarket, detail

*2) Index for HR Strategy 
pwcorr hr_d_workforce hr_d_academy k_review_c k_review_BoD dd_design_c dd_design_board, sig

*3) Just put all together
*dummies
egen hr_indexD_total=rowtotal(hr_d_*)
tab hr_indexD_total

*categorical/dummy 
egen hr_indexCat_total=rowtotal(hr_cat_*)
tab hr_indexCat_total

*standardize 
egen z_hr_indexCat_total = std(hr_indexCat_total)

// Generate visualization of HR practices
*Workforce Planning
graph bar (percent), over(hr_cat_workforce, sort(1) descending) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Engagement in Workforce Activity") ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_workforce.png", replace

*Skill taxonomy 
graph bar (percent), over(hr_cat_skdescription, sort(1) descending) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Skill Taxonomy (skills needed to perform in occup) Existent") ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_skdescription.png", replace

*Skill Inventory 
graph bar (percent), over(hr_cat_skinventory, sort(1) descending) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Inventory of Skills Existent") ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_cat_skinventory.png", replace

*Skill Inventory usefulness 
graph bar (percent), over(hr_cat_skinventory_use, sort(1) descending) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Skill Inventory Usefulness") ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_skinventory_use.png", replace

***Skill Inventory usefulness (coarse)
graph bar (percent), over(hr_coarse_cat_skinventory_use, sort(1) descending) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Skill Inventory Usefulness") ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_skinventory_use_coarse.png", replace

*Academy 
graph bar (percent), over(hr_cat_academy) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Investment in Setting up Internal Academy") ///
legend(label(1 "Yes") label(2 "No") label(3 "No, but planned")) ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_academy.png", replace

*Internal Labor Market 
graph bar (percent), over(hr_cat_internalmkt, sort(1) descending) ///
graphregion(color(white)) intensity(20) ///
blabel(bar, size(small) gap(-4) format(%4.2f)) asyvars ///
title("Advertisement of internal Job & Project Opportunities") ///
ytitle("Share of Responses")
graph export "$figuresdir/SummaryStats/HR/hr_Intlabormarket.png", replace


/*------------------------------------------------------------------------------
  Sheet 3: Summary Statistics on Skills Gaps and Coping Mechanisms (slides 10-13)
------------------------------------------------------------------------------*/
// Generate summary statistics for skills gaps
estpost tabstat sk_* sk_n_* tr_sk_*, statistics(count mean sd) columns(statistics)
esttab using "$outdir/skills_gaps_stats.csv", cells("count mean sd") replace

// Generate skills gap severity chart like in Image 3
graph bar dum_sk_gap1 dum_sk_gap2 dum_sk_gap3, ///
title("Severity of Skills Gap", span size(medium)) ///
graphregion(color(white)) blabel(bar, format(%4.3f)) ///
intensity(20) asyvars ///
legend(label(1 "No skills gap") label(2 "Moderate skills gap") label(3 "Severe skills gap") ///
size(small)) xsize(10) ysize(8)
graph export "$figuresdir/skills_gap_severity.png", replace

* Wide variety of skills demanded 
*** Leadership and digital skills at the top, but wide variety
graph hbar sk_n*, showyvars leg(off) blabel(total, format(%4.2f)) ///
yvar(relabel(1 "Leadership" 2 "Adaptability" 3 "Communication" ///
4 "Problem Solving" 5 "Project Management"  ///
6 "Industry-Specific Knowledge"  7 "Customer Service" 8 "Sales and Marketing" ///
9 "Financial Management" 10 "Human Resources" 11 "Supply Chain and Logistics" ///
 12 "Basic Digital" 13 "Advanced Digital" 14 "Production-Related Digital" ///
15 "Data Analysis and Processing" 16 "Other")) ///
title("Skills currently most acutely needed by organizations", span size(medium)) ///
b1title("Share of responses") ///
graphregion(color(white)) intensity(20) xsize(12) ysize(5)

* Beyond the averages: clusters of skills demanded
* Type 1: only digital skills
* Type 2: wants everything, including digital skills
* Type 3: soft and digital
* Type 4: soft and industry specific
graph bar sk_n*, over(clusplot2)  legend( label (1 "Leadership") label  (2 "Adaptability")  label (3 "Communication") label (4 "Problem Solving") label (5 "Project Management") label (6 "Industry-Specific Knowledge") label (7 "Customer Service" ) label (8 "Sales and Marketing" ) label (9 "Financial Management") label (10 "Human Resources" ) label (11 "Supply Chain and Logistics" ) label (12 "Basic Digital") label (13 "Advanced Digital") label (14 "Production-Related Digital") label (15 "Data Analysis and Processing") label (16 "Other" )) title("Skills currently most acutely needed by organizations", span size(medium)) ///
graphregion(color(white)) intensity(20) xsize(12) ysize(5) ///
ytitle("Share of responses")
graph export "$output/Figures/SummaryStats/Skill_need_cluster.png", replace

/*==============================================================================
  PART 2: IN-DEPTH LOOK AT TRAINING
==============================================================================*/

/*------------------------------------------------------------------------------
  Sheet 4: Fraction of Generic Training, Upskilling, and Reskilling
------------------------------------------------------------------------------*/
// Calculate proportions of each training type
estpost tab program
esttab using "$outdir/training_type_distribution.csv", ///
    cells("freq pct") replace

// Create visualization of training distribution
graph bar pp*, ///
graphregion(color(white)) blabel(bar, format(%4.2f)) ///
intensity(50) asyvars ///
title("Distribution of Training Programs") ///
legend(label(1 "General Training") label(2 "Upskilling") label(3 "Reskilling") ///
size(small)) xsize(12) ysize(8)
graph export "$figuresdir/training_distribution.png", replace

// Alternative visualization as pie chart
graph pie, over(program) ///
    title("Distribution of Training Programs") ///
    plabel(_all percent, format(%9.1f) size(medium))
graph export "$figuresdir/training_distribution_pie.png", replace width(1200)


/*------------------------------------------------------------------------------
  Sheet 5: Summary Statistics of Program Characteristics
------------------------------------------------------------------------------*/
// Overall summary statistics for all programs
estpost tabstat p_participated p_participated_2023 p_duration p_hourstrained ///
    p_cost p_eligibility p_part_exp p_fund_org p_fund_gov p_ongoing ///
    p_mandavolunt p_otjactivities p_targetemp_c p_targetemp_emp, ///
    statistics(count mean sd) columns(statistics)
esttab using "$outdir/program_characteristics_all.csv", ///
    cells("count mean(fmt(%9.2f)) sd(fmt(%9.2f))") replace

// IMPORTANT CHECK
// Program characteristics by program type (upskilling vs reskilling)
/* Compare Upskilling vs Reskilling programs with t-tests
foreach var of varlist p_participated p_participated_2023 p_duration p_hourstrained ///
    p_cost p_eligibility p_part_exp p_fund_org p_fund_gov p_ongoing ///
    p_mandavolunt p_otjactivities p_targetemp_c p_targetemp_emp {
    
    // Run t-test
    ttest `var', by(program) unequal
    
    // Store results
    local t_`var' = r(t)
    local p_`var' = r(p)
}
*/
// Summary statistics by program type with t-test results
estpost tabstat p_participated p_participated_2023 p_duration p_hourstrained ///
    p_cost p_eligibility p_part_exp p_fund_org p_fund_gov p_ongoing ///
    p_mandavolunt p_otjactivities p_targetemp_c p_targetemp_emp, ///
    by(program) statistics(mean sd) columns(statistics)
esttab using "$outdir/program_characteristics_by_type.csv", ///
    cells("mean(fmt(%9.2f)) sd(fmt(%9.2f))") replace

// Visualize program characteristics comparison
graph bar plength_long p_size_coarse3 p_long p_hours_long pcost_high /// duration
p_target_top p_target_middle p_target_emp p_target_topmiddle p_target_middleemp p_target_topbottom p_target_all /// target 
pdelmix /// delivery
dd_clus1 dd_clus2 dd_clus3 dd_clus4 /// bundles
sum_tr_sk /// skills
p_cha_takeup p_cha_during p_cha_support p_cha_scale /// *** Outcomes challenges 
expart_exc roi_yes roi_pos invest_cont veff /// outcomes
p_adv_top p_adv_hr p_resp_top p_resp_hr p_adv_resp_match dd_design_top /// responsibility and advocacy
k_reviewcombined_c k_reviewcombined_hr /// kpi 
pmandatory pappall psel p_criteria_jobtitle p_criteria_tenure p_criteria_qualifications p_criteria_assmskills p_criteria_assmsmotivation p_criteria_managerrec /// selection
p_compfull diff_man inc_man_fin diff_emp inc_emp_fin /// incentives
stand1 nopilot control1 /// implementation
assess1 /// assessment
share_matched ///
fsub /// funding and government interaction
, by(res)
graph export "$figuresdir/program_characteristics_comparison.png", replace width(1200)

// Create visual comparison for key variables
foreach var of varlist p_duration p_hourstrained p_cost p_eligibility {
    graph bar (mean) `var', over(program) ///
        title("Comparison of `var' by Program Type") ///
        ytitle("Mean Value") blabel(bar, format(%9.2f))
    graph export "$figuresdir/`var'_by_program.png", replace width(1200)
}


/*------------------------------------------------------------------------------
  Sheet 6: Clusters of Training Programs (2 cluster analysis)
------------------------------------------------------------------------------*/
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

// Drop observations with missing values in key variables
preserve

foreach var of local key_p_vars {
    drop if missing(`var')
}
display "After dropping missings, dataset has " c(N) " observations."

// Standardize key variables
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

// Perform K-means clustering with k=2
cluster kmed `zvar_list', k(2) name(cluster2) measure(abs) start(random)
gen cluster_2 = cluster2
label variable cluster_2 "Clusters (k=2)"

// Create labels for clusters
label define cluster_2_lbl 1 "Cluster 1" 2 "Cluster 2"
label values cluster_2 cluster_2_lbl

// Analyze cluster composition
tab cluster_2, missing

// Generate descriptive statistics by cluster
estpost tabstat p_participated p_participated_2023 p_duration p_hourstrained ///
    p_cost p_eligibility p_part_exp p_fund_org p_fund_gov p_ongoing ///
    p_mandavolunt p_otjactivities p_targetemp_c p_targetemp_emp, ///
    by(cluster_2) statistics(mean sd) columns(statistics) listwise
esttab using "$outdir/cluster_summary_stats.csv", ///
    cells("mean(fmt(%9.2f)) sd(fmt(%9.2f))") replace

// Perform ANOVA to test differences between clusters
foreach var of varlist p_participated p_duration p_hourstrained p_cost {
    anova `var' cluster_2
}

// Create visualizations of clusters
// Program size and participation
graph bar (mean) p_participated p_participated_2023 p_eligibility p_part_exp, ///
    over(cluster_2) asyvars ///
    title("Program Participation by Cluster") ///
    ytitle("Average Value") ///
    legend(title("Variables") rows(1))
graph export "$figuresdir/participation_by_cluster.png", replace width(1200)

// Program structure and cost
graph bar (mean) p_duration p_hourstrained p_comphours p_cost, ///
    over(cluster_2) asyvars ///
    title("Program Structure and Cost by Cluster") ///
    ytitle("Average Value") ///
    legend(title("Variables") rows(1))
graph export "$figuresdir/structure_by_cluster.png", replace width(1200)

// Program funding sources
graph bar (mean) p_fund_gov p_fund_org p_fund_wrk p_fund_union, ///
    over(cluster_2) asyvars ///
    title("Program Funding by Cluster") ///
    ytitle("Average Percentage") ///
    legend(title("Funding Sources") rows(1))
graph export "$figuresdir/funding_by_cluster.png", replace width(1200)

// Save cluster assignments to dataset
save "$outdir/clustered_programs.dta", replace

restore


/*------------------------------------------------------------------------------
  Sheet 7: Tabulation of Cluster vs Reskilling Dummy
------------------------------------------------------------------------------*/
// Reload the clustered dataset
use "$outdir/clustered_programs.dta", clear

// Tabulate cluster by program type
tab cluster_2 program, row col chi2

// Alternate method using existing clusters if they exist in the dataset
tab clusplot res, row col chi2

// Create a contingency table
estpost tab cluster_2 program
esttab using "$outdir/cluster_program_contingency.csv", ///
    cells("b(fmt(%9.0f)) rowpct(fmt(%9.1f))") replace

// Create a visualization
graph bar (percent), over(program) over(cluster_2) ///
    title("Cluster Composition by Program Type") ///
    ytitle("Percent") ///
    blabel(bar, format(%9.1f))
graph export "$figuresdir/cluster_by_program.png", replace width(1200)

// Look at variation within reskilling programs
estpost tabstat p_participated p_duration p_hourstrained p_cost ///
    p_eligibility p_ongoing p_targetemp_c p_targetemp_emp ///
    if program == 3, /// 
    by(cluster_2) statistics(mean sd) columns(statistics)
esttab using "$outdir/reskilling_by_cluster.csv", ///
    cells("mean(fmt(%9.2f)) sd(fmt(%9.2f))") replace

// Create visualizations for reskilling programs by cluster
graph bar (mean) p_duration p_hourstrained p_cost if program == 3, /// aquí
    over(cluster_2) asyvars ///
    title("Reskilling Program Features by Cluster") ///
    ytitle("Average Value") ///
    legend(title("Features") rows(1))
graph export "$figuresdir/reskilling_features_by_cluster.png", replace width(1200)


/*==============================================================================
  PART 3: FIRM CORRELATES OF RESKILLING
==============================================================================*/

/*------------------------------------------------------------------------------
  Sheet 8: Regression with Reskilling Dummy as Dependent Variable
------------------------------------------------------------------------------*/
// Load the main dataset if needed
use "$datadir/V1_qualflags_analysis2.dta", clear

// Create a binary indicator for reskilling programs if needed
capture gen res = (program == 3) // Assuming 3 is the code for "Reskilling"
label variable res "Reskilling Program (1=Yes, 0=No)"

// Create HR index variable if it doesn't exist
capture confirm variable hr_indexD_total
if _rc {
    // If the variable doesn't exist, create it
    egen hr_indexD_total = rowtotal(hr_d_*)
}

// Set up global variable for HR controls
global hr "hr_indexD_total"

// Checking if the interviewer variable exists
capture confirm variable interviewer
if _rc {
    // If the variable doesn't exist, create a placeholder
    gen interviewer = 1
    global noise "interviewer" 
} 
else {
    global noise "interviewer"
}

// Define noise variables if needed
capture gen noise = 1
label variable noise "Noise control"

// Encode string variables to numeric for factor variable usage
capture confirm variable f_naics_super_num
if _rc {
    // If not, create encoded versions
    encode f_naics_super, gen(f_naics_super_num)
}

capture confirm variable f_naics_super2_num
if _rc {
    // If not, create encoded versions 
    encode f_naics_super2, gen(f_naics_super2_num)
}

// Set up regression table
eststo clear

// 1. Base regression (with no explanatory variables)
eststo base: reg res, rob

// 2. Add firm size
eststo firm_size: reg res f_medium f_large, rob

// 3. Add firm industry - using encoded numeric version
eststo industry: reg res f_medium f_large i.f_naics_super_num, rob

// 4. Add MNE dummy
eststo mne: reg res f_medium f_large i.f_naics_super_num f_mne, rob

// 5. Add publicly listed dummy
eststo public: reg res f_medium f_large i.f_naics_super_num f_mne f_public, rob

// 6. Add union percentage
eststo union: reg res f_medium f_large i.f_naics_super_num f_mne f_public f_union50, rob

// 7. Add skill needs (clusters)
eststo skill_needs: reg res f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2, rob

// 8. Add HR index
eststo hr_index: reg res f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 $hr, rob

// 9. Add skill gap severity
eststo skill_gap: reg res f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 $hr sk_gap_sev, rob

// 10. Full model with all variables
eststo full: reg res f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 $hr sk_gap_sev $noise, rob

// Output the regression table
esttab base firm_size industry mne public union skill_needs hr_index skill_gap full using "$outdir/reskilling_regressions.csv", ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    scalars("r2_a Adjusted R-squared") ///
    keep(f_medium f_large f_mne f_public f_union50 $hr sk_gap_sev *clusplot*) ///
    replace

/*------------------------------------------------------------------------------
  Sheet 9: Regression with Cluster as Dependent Variable
------------------------------------------------------------------------------*/
// Load the clustered dataset created in Sheet 6
use "$outdir/clustered_programs.dta", clear

// Create a numeric version of industry variable if it's a string
capture confirm string variable f_naics_super
if !_rc {
    // If it's a string, encode it
    encode f_naics_super, gen(f_naics_super_num)
}

// Set up regression table
eststo clear

// 1. Base regression
eststo base: reg cluster_2, rob

// 2. Add firm size
eststo firm_size: reg cluster_2 f_medium f_large, rob

// 3. Add firm industry - try both possible variable names
capture confirm variable f_naics_super_num
if !_rc {
    // If f_naics_super_num exists, use it
    eststo industry: reg cluster_2 f_medium f_large i.f_naics_super_num, rob
} 
else {
    // Otherwise, create a simplified model without industry
    eststo industry: reg cluster_2 f_medium f_large, rob
    di "Warning: Industry variable not found or not properly encoded"
}

// 4. Add MNE dummy
capture confirm variable f_mne
if !_rc {
    eststo mne: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne, rob
}
else {
    // If f_mne doesn't exist, repeat previous model
    eststo mne: reg cluster_2 f_medium f_large i.f_naics_super_num, rob
    di "Warning: MNE variable not found"
}

// 5. Add publicly listed dummy
capture confirm variable f_public
if !_rc {
    eststo public: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public, rob
}
else {
    // If f_public doesn't exist, repeat previous model
    eststo public: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne, rob
    di "Warning: Public company variable not found"
}

// 6. Add union percentage
capture confirm variable f_union50
if !_rc {
    eststo union: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50, rob
}
else {
    // If f_union50 doesn't exist, repeat previous model
    eststo union: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public, rob
    di "Warning: Union variable not found"
}

// 7. Add skill needs (clusters)
capture confirm variable clusplot2
if !_rc {
    eststo skill_needs: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2, rob
}
else {
    // If clusplot2 doesn't exist, repeat previous model
    eststo skill_needs: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50, rob
    di "Warning: Skill needs clusters variable not found"
}

// 8. Add HR index
capture confirm variable hr_indexD_total
if !_rc {
    eststo hr_index: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total, rob
}
else {
    // If hr_indexD_total doesn't exist, repeat previous model
    eststo hr_index: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2, rob
    di "Warning: HR index variable not found"
}

// 9. Add skill gap severity
capture confirm variable sk_gap_sev
if !_rc {
    eststo skill_gap: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total sk_gap_sev, rob
}
else {
    // If sk_gap_sev doesn't exist, repeat previous model
    eststo skill_gap: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total, rob
    di "Warning: Skill gap severity variable not found"
}

// 10. Full model with all variables
eststo full: reg cluster_2 f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total sk_gap_sev, rob

// Output the regression table
esttab base firm_size industry mne public union skill_needs hr_index skill_gap full using "$outdir/cluster_regressions.csv", ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    scalars("r2 R-squared" "r2_a Adjusted R-squared") ///
    keep(f_medium f_large f_mne f_public f_union50 hr_indexD_total sk_gap_sev *clusplot*) ///
    replace


/*------------------------------------------------------------------------------
  Sheet 10: Regression with Combined Reskilling & Complex Program as Dependent Variable
------------------------------------------------------------------------------*/
// Load the clustered dataset if not already loaded
use "$outdir/clustered_programs.dta", clear

// Create a binary indicator for complex reskilling programs
// Using cluster_2 (from sheet 6) and res (reskilling indicator)
gen complex_reskilling = (res == 1 & cluster_2 == 2)
label variable complex_reskilling "Complex Reskilling Program"

// Set up regression table
eststo clear

// Run the same models as in Sheet 8 but with complex_reskilling as dependent variable
// 1. Base regression
eststo base: reg complex_reskilling, rob

// 2. Add firm size
eststo firm_size: reg complex_reskilling f_medium f_large, rob

// 3. Add firm industry - using encoded numeric version
capture confirm variable f_naics_super_num
if !_rc {
    eststo industry: reg complex_reskilling f_medium f_large i.f_naics_super_num, rob
} 
else {
    // Try with string variable
    capture confirm variable f_naics_super
    if !_rc {
        // If it's a string, encode it
        encode f_naics_super, gen(f_naics_super_num)
        eststo industry: reg complex_reskilling f_medium f_large i.f_naics_super_num, rob
    }
    else {
        // If neither exists, just repeat the previous model
        eststo industry: reg complex_reskilling f_medium f_large, rob
        di "Warning: Industry variable not found"
    }
}

// 4. Add MNE dummy
capture confirm variable f_mne
if !_rc {
    eststo mne: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne, rob
}
else {
    // If f_mne doesn't exist, repeat previous model
    eststo mne: reg complex_reskilling f_medium f_large i.f_naics_super_num, rob
    di "Warning: MNE variable not found"
}

// 5. Add publicly listed dummy
capture confirm variable f_public
if !_rc {
    eststo public: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public, rob
}
else {
    // If f_public doesn't exist, repeat previous model
    eststo public: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne, rob
    di "Warning: Public company variable not found"
}

// 6. Add union percentage
capture confirm variable f_union50
if !_rc {
    eststo union: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50, rob
}
else {
    // If f_union50 doesn't exist, repeat previous model
    eststo union: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public, rob
    di "Warning: Union variable not found"
}

// 7. Add skill needs (clusters)
capture confirm variable clusplot2
if !_rc {
    eststo skill_needs: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2, rob
}
else {
    // If clusplot2 doesn't exist, repeat previous model
    eststo skill_needs: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50, rob
    di "Warning: Skill needs clusters variable not found"
}

// 8. Add HR index
capture confirm variable hr_indexD_total
if !_rc {
    eststo hr_index: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total, rob
}
else {
    // If hr_indexD_total doesn't exist, repeat previous model
    eststo hr_index: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2, rob
    di "Warning: HR index variable not found"
}

// 9. Add skill gap severity
capture confirm variable sk_gap_sev
if !_rc {
    eststo skill_gap: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total sk_gap_sev, rob
}
else {
    // If sk_gap_sev doesn't exist, repeat previous model
    eststo skill_gap: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total, rob
    di "Warning: Skill gap severity variable not found"
}

// 10. Full model with all variables
eststo full: reg complex_reskilling f_medium f_large i.f_naics_super_num f_mne f_public f_union50 i.clusplot2 hr_indexD_total sk_gap_sev, rob

// Output the regression table
esttab base firm_size industry mne public union skill_needs hr_index skill_gap full using "$outdir/complex_reskilling_regressions.csv", ///
    b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    scalars("r2 R-squared" "r2_a Adjusted R-squared") ///
    keep(f_medium f_large f_mne f_public f_union50 hr_indexD_total sk_gap_sev *clusplot*) ///
    replace

matrix b = e(b)
matrix list b


// Close log file
log close

display "Analysis complete! All results saved to $outdir."