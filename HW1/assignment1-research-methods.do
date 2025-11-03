ssc install estout
insheet using assignment1-research-methods.csv, tab names clear
label variable calledback "Received Callback"
label variable eliteschoolcandidate "Elite School"
label variable malecandidate "Male Candidate"
reg calledback eliteschoolcandidate malecandidate
eststo regression_one
esttab regression_one using assignment1-research-methods.rtf, $tableoptions

