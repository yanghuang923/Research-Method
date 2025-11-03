*******************************************************
* File: vaping-ban-analysis.do
* Purpose: Evaluate parallel trends and estimate the 
*          causal effect of anti-vaping laws (DnD)
* Yang Huang
*******************************************************

cd "/Users/yh3953/Documents/Stata"
import delimited "vaping-ban-panel.csv", varnames(1) clear

*******************************************************
* identify treated states (ever adopt vaping ban)
*******************************************************
bysort stateid: egen ever_treated = max(vapingban)
label variable ever_treated "State Ever Adopted Ban"
tab ever_treated

*******************************************************
* Evaluate the 'parallel trends' assumption
* Use only pre-treatment period (2010–2020)
*******************************************************
preserve
keep if year <= 2020

eststo reg1: reg lunghospitalizations i.year##i.ever_treated, cluster(stateid)
testparm i.year#1.ever_treated   
restore

*******************************************************
* Estimate the DiD treatment effect
* Include state and year fixed effects
*******************************************************
gen post = (year >= 2021)

label variable post "Post-Treatment Period"

eststo reg2: areg lunghospitalizations i.post##i.ever_treated i.year, absorb(stateid) cluster(stateid)

reg lunghospitalizations vapingban i.year i.stateid, cluster(stateid)

testparm i.stateid

*******************************************************
* Export Publication-Quality Table
*******************************************************

label variable ever_treated "Treated State (Adopted Ban)"
label variable post "Post-Policy Period"
label variable lunghospitalizations "Lung-Related Hospitalizations"


esttab reg1 reg2 using "vaping_results_table_clean.rtf", replace se label star(* 0.10 ** 0.05 *** 0.01) b(3) se(3) keep(1.ever_treated 1.post#1.ever_treated) varlabels(1.ever_treated "Treated State (Adopted Ban)" 1.post#1.ever_treated "Post × Treated State (After Ban in Effect)") stats(N r2, fmt(0 3) labels("Observations" "R-squared")) mtitles("Pre-2021 (Parallel Trends)" "DiD (State + Year FE)") title("Dependent Variable: Lung-Related Hospitalizations") compress align(c) nonumber noobs cells(b(star fmt(3)) se(fmt(3) par)) addnotes("Standard errors in parentheses. Model (1): Parallel-trends test using pre-2021 sample (State FE: No, Year FE: Yes). Model (2): Difference-in-Differences estimate with state and year fixed effects (State FE: Yes, Year FE: Yes). Standard errors clustered at the state level. * p<0.10, ** p<0.05, *** p<0.01.")




*******************************************************
* Create canonical Difference-in-Differences line graph
*******************************************************
preserve
collapse (mean) lunghospitalizations, by(year ever_treated)
twoway (line lunghospitalizations year if ever_treated==0, lcolor(blue) lwidth(medthick)) (line lunghospitalizations year if ever_treated==1, lcolor(red) lwidth(medthick)), xline(2021, lcolor(gs10) lpattern(dash)) legend(order(1 "Untreated" 2 "Treated")) title("Difference-in-Differences: Lung Hospitalizations") ytitle("Average Lung Hospitalizations") xtitle("Year") graphregion(color(white))

graph export "/Users/yh3953/Documents/Stata/vaping_did_plot.png", replace width(1200)

restore



