******************************************
*Author: Devon Kristiansen               *
*Creating comparable IPV indicators - PMA*
*September 1, 2023                       *
*Variables needed in your data file:     *
*eaid, fqweight, marstat,                *
*intgbvprivacy, ipvemoyr, ipvthreatkillyr*
*ipvphysyr, sexforceyr                   *
******************************************

clear

cd "[filepath]" //insert filepath to your downloaded IPUMS PMA data file

use pma_00###.dta //replace ### with the number of your Stata data file
svyset eaid, weight(fqweight)

**RECONCILING UNIVERSE DIFFERENCES**
*Universe for violence questions is currently married or living with a man
**only keep women who were selected into the module and could have privacy during the interview
keep if intgbvprivacy == 1
**keep only currently married or partnered women
keep if marstat == 21 | marstat == 22

***recode to remove missings and non-responses
foreach var of varlist ipvemoyr ipvthreatkillyr ipvphysyr sexpressureyr sexforceyr  {
	recode `var' (0=0) (1=1) (else=.)
}

***CONSTRUCTING COMPARABLE INDICATOR VARIABLES***
*Physical violence = slapped, hit, physically hurt, threatened with a weapon or attempted to strangle or kill
egen dvphysyr = rowmax(ipvphysyr ipvthreatkillyr)

*Psychological violence = Insulted, yelled at, screamed or made humiliating remarks 
gen dvpsychyr = ipvemoyr

*Sexual violence = physically forced sex
gen dvsexyr = sexforceyr

