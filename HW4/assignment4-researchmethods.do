cd "/Users/yh3953/Documents/Stata"
import delimited "crime-iv.csv", varnames(1) clear

* install package if needed
ssc install estout, replace

* run balance test
estpost ttest defendantid severityofcrime monthsinjail recidivates, by(republicanjudge) unequal

* create balance table
esttab using "balance_table_judgeparty.rtf", replace cells("mu_1(fmt(3)) mu_2(fmt(3)) b(fmt(3) star) se(fmt(3)) p(fmt(3))") label title("Balance Test: Judge Party Assignment") collabels("Rep Judge Mean" "Dem Judge Mean" "Difference" "Std. Error" "p-value") starlevels(* 0.10 ** 0.05 *** 0.01) noobs nonumber compress addnote("Entries show group means, mean differences, standard errors, and p-values from unequal-variance t-tests. * p<0.10, ** p<0.05, *** p<0.01.")

* First stage: 
reg monthsinjail republicanjudge severityofcrime, robust
esttab using "first_stage_table.rtf", replace se label b(%9.3f) se(%9.3f) starlevels(* 0.10 ** 0.05 *** 0.01) title("First Stage: Effect of Judge Party on Months in Jail") mtitles("Months in Jail") coeflabels(republicanjudge "Republican Judge" severityofcrime "Severity of Crime") addnotes("Robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01.")

* Reduced form
reg recidivates republicanjudge severityofcrime, robust
esttab using "reduced_form_table.rtf", replace se label b(%9.3f) se(%9.3f) starlevels(* 0.10 ** 0.05 *** 0.01) title("Reduced Form: Effect of Judge Party on Recidivism") mtitles("Recidivates") coeflabels(republicanjudge "Republican Judge" severityofcrime "Severity of Crime") addnotes("Robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01.")

*ratio of the reduced form
reg recidivates republicanjudge severityofcrime, robust
scalar rf = _b[republicanjudge]

reg monthsinjail republicanjudge severityofcrime, robust
scalar fs = _b[republicanjudge]

display "IV estimate = " rf/fs

* IV regression
ssc install ranktest, replace
ivreg2 recidivates (monthsinjail = republicanjudge) severityofcrime, robust first
esttab using "iv_second_stage_table.rtf", replace se label b(%9.3f) se(%9.3f) starlevels(* 0.10 ** 0.05 *** 0.01) title("IV Second Stage: Effect of Months in Jail on Recidivism") mtitles("Recidivism (2SLS)") coeflabels(monthsinjail "Months in Jail (IV)" severityofcrime "Severity of Crime") addnotes("Robust standard errors in parentheses. Instrument: Republican Judge. * p<0.10, ** p<0.05, *** p<0.01.")





