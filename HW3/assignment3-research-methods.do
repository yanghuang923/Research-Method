cd "/Users/yh3953/Documents/Stata"
import delimited "sports-and-education.csv", varnames(1) clear

* install package
ssc install estout, replace

* define global for table formatting (provided starter code)
global balanceopts "prehead(\begin{tabular}{l*{6}{c}}) postfoot(\end{tabular}) noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast) starlevels(* 0.1 ** 0.05 *** 0.01)"

* run t-tests comparing means between ranked (1) vs not ranked (0)
estpost ttest academicquality athleticquality nearbigmarket, by(ranked2017) unequal

* display formatted balance table
esttab using "balance_table.rtf", replace cells("mu_1(fmt(3)) mu_2(fmt(3)) b(fmt(3) star) se(fmt(3)) p(fmt(3))") label title("Balance Table: Ranked vs. Not Ranked Colleges") collabels("Ranked Mean" "Unranked Mean" "Difference" "Std. Error" "p-value") starlevels(* 0.10 ** 0.05 *** 0.01) noobs nonumber compress addnote("Entries show group means, mean differences, standard errors, and p-values from unequal-variance t-tests. * p<0.10, ** p<0.05, *** p<0.01.")

* Estimate a logistic regression model predicting who is ranked
logit ranked2017 academicquality athleticquality nearbigmarket

* Output coefficients in a formatted table using the starter code
esttab using "propensity_model.rtf", replace se starlevels(* 0.10 ** 0.05 *** 0.01) label title("Propensity Score Model: Predicting Which Colleges Were Ranked") $balanceopts addnote("Logistic regression estimating the probability of being ranked based on college characteristics. * p<0.10, ** p<0.05, *** p<0.01.")

* Generate predicted probabilities (propensity scores)
predict propensity_score, pr

* Summarize and visualize the distribution of propensity scores
summarize propensity_score
histogram propensity_score, width(0.05) frequency title("Distribution of Predicted Propensity Scores") xtitle("Propensity Score") ytitle("Number of Colleges")

* Show overlap in predicted propensity scores for ranked vs. unranked colleges
twoway (histogram propensity_score if ranked2017==1, start(0) width(0.05) color(red%40) freq) (histogram propensity_score if ranked2017==0, start(0) width(0.05) color(blue%40) freq), legend(order(1 "Treatment (Ranked)" 2 "Control (Unranked)")) title("Overlap in Propensity Scores: Ranked vs. Unranked Colleges") xtitle("Propensity Score") ytitle("Frequency")

* Sort by predicted propensity score
sort propensity_score

* Create blocks (quartets) based on observation order
gen block = floor((_n-1)/5)

* Summarize average propensity score by block
bysort block: summarize propensity_score ranked2017



* Ensure variable labels are set (these show up nicely in the table)
label var ranked2017 "Ranked in 2017 (1=yes)"
label var academicquality "Academic Quality (0–1)"
label var athleticquality "Athletic Quality (0–1)"
label var nearbigmarket "Near Big Market (1=yes)"
label var alumnidonations2018 "Alumni Donations 2018"


* Regressions with block fixed effects (i.block) and robust SEs
*    Outcome: Alumni Donations 2018
eststo clear
regress alumnidonations2018 ranked2017 academicquality athleticquality nearbigmarket i.block, vce(robust)
estadd local "FE" "Block FE: Yes"
estadd local "Controls" "Controls: AQ, HQ, NBM"

esttab using "treatment_effect_blockFE.rtf", replace b(3) se(3) starlevels(* 0.10 ** 0.05 *** 0.01) label title("Effect of Being Ranked on Alumni Donations (Block FE)") keep(ranked2017 academicquality athleticquality nearbigmarket) order(ranked2017 academicquality athleticquality nearbigmarket) stats(N r2, labels("Observations" "R-squared")) addnote("Outcome is Alumni Donations 2018 (thousands of USD). Model includes block fixed effects (i.block) formed by sorting on the estimated propensity score and grouping every 5 observations. Robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01.")

