**********************************************
*Author: Devon Kristiansen                   *
*Creating comparable IPV indicators - DHS    *
*September 1, 2023                           *
*Variables needed in your data file:         *
*idhspsu, dvweight, idhsstrata, marstat      *
*idvmodule, dvppushfq dvpslapfq dvptwistfq   *
*dvppunchfq dvpchokefq dvpkickfq dvpknifethfq*
*dvehumilfq dveinsultfq dvpsexfq             *
**********************************************

clear

cd "[filepath]" //insert filepath to your downloaded IPUMS DHS data file

use dhs_00###.dta //replace ### with the number of your Stata data file

svyset idhspsu, weight(dvweight) strata(idhsstrata)

**RECONCILING UNIVERSE DIFFERENCES**
*Universe for violence questions is ever-married women (sometimes women who had ever lived with a man as if married) who were selected into the DV module
**only keep women who were selected into the module and could have privacy during the interview
keep if dvmodule == 1
**keep only currently-married or partnered women/drop never married women/unconsummated marriages/widowed/divorced
keep if marstat == 21 | marstat == 22

**CLEANUP**
***recode to No if never or not in the past 12 months, often or sometimes in past 12 months is yes; conservative estimate of timing unknown to no
*Physical violence
foreach var of varlist dvppushfq dvpslapfq dvptwistfq dvppunchfq dvpchokefq dvpkickfq dvpknifethfq dvpsexfq dvpsexothfq dvpsexcoerfq {
	recode `var' (0=0) (11/12=1) (13=0) (20=0) (else=.)
}
*Psychological violence - has different coding than physical violence vars
foreach var of varlist dvehumilfq dveinsultfq dvethreatfq {
	recode `var' (0=0) (21/22=1) (23=0) (10=0) (else=.)
}

***In Egypt 2005, the frequency variables are NIU, and don't have an indicator for not experiencing violence
replace dvehumilfq = 0 if dvehumil == 0 & sample == 81806
replace dveinsultfq = 0 if dveinsult == 0 & sample == 81806
replace dvppushfq = 0 if dvppush == 0 & sample == 81806
replace dvpslapfq = 0 if dvpslap == 0 & sample == 81806
replace dvptwistfq = 0 if dvptwist == 0 & sample == 81806
replace dvppunchfq = 0 if dvppunch == 0 & sample == 81806
replace dvpchokefq = 0 if dvpchoke == 0 & sample == 81806
replace dvpkickfq = 0 if dvpkick == 0 & sample == 81806
replace dvpknifethfq = 0 if dvpknifeth == 0 & sample == 81806
replace dvpsexfq = 0 if dvpsex == 0 & sample == 81806

***CONSTRUCTING COMPARABLE INDICATOR VARIABLES***
*Physical violence = push, slap, twist arm or hair, punch, choke, burn, kick, or threaten with knife or gun
egen dvphysyr = rowmax(dvppushfq dvpslapfq dvptwistfq dvppunchfq dvpchokefq dvpkickfq dvpknifethfq)

*Psychological violence = humiliate, insult
egen dvpsychyr = rowmax(dvehumilfq dveinsultfq)

*Sexual violence = physically forced sex
egen dvsexyr = rowmax(dvpsexfq)


