***********************************************
*Author: Devon Kristiansen                    *
*Creating comparable IPV indicators - MICS    *
*September 1, 2023                            *
*Variables needed in your data file:          *
*imicspsu, marst, imicscluster, weightwm      *
*dvprivacy, dvppushfreq dvpslapfreq           *
*dvptwistfreq dvppunchfreq dvpbeatfreq        *
*dvpchokefreq dvpweapfreq dvpsexfreq          * 
*dvehumilfreq dveinsultfreq                   *
*(optional) violence variables ending in "num"*
***********************************************

clear

cd "[filepath]" //insert filepath to your downloaded IPUMS MICS do file and MICS data

do mics_00###.dta //replace ### with the number of your Stata do file

**RECONCILING UNIVERSE DIFFERENCES**
*Universe for violence questions is currently or formerly married women who were selected into the DV module
**only keep women who were selected into the module and could have privacy during the interview
drop if dvprivacy == 0 | dvprivacy == 9
**keep only currently married or partnered women to match PMA's universe
keep if marst == 10
*Central African Republic and Chad have clusters rather than PSUs
replace imicspsu = imicscluster if sample == 14840 | sample == 14030
svyset imicspsu, weight(weightwm)

*changing coding of frequency variables to yes if sometimes or often and to No if never (NIU) or not in the past year
foreach var of varlist *freq {
	recode `var' (1/2=1) (3=0) (9=0) (8=.)
}
*changing coding of variables ending in *num for the older samples - they contain abuse frequency data in a different format than the *freq variables
foreach var of varlist dvehumil dvethreat dvpweap dvpweapuse dvpbeat dvpchoke dvppush dvpsex dvpsexact dvpslap {
	cap recode `var'num (0=0) (1/90=1) (else=.)
	cap replace `var'num = 0 if `var' == 0
	cap replace `var'freq = `var'num if `var'freq == . & `var'num != .
}

***CONSTRUCTING COMPARABLE INDICATOR VARIABLES***
*Physical violence = push, slap, twist arm or hair, punch, beat up, choke, burn, brandish a weapon
egen dvphysyr = rowmax(dvppushfreq dvpslapfreq dvptwistfreq dvppunchfreq dvpbeatfreq dvpchokefreq dvpweapfreq)

*Psychological violence = humiliate, insult
egen dvpsychyr = rowmax(dvehumilfreq dveinsultfreq)

*Sexual violence = force sex
gen dvsexyr = dvpsexfreq

